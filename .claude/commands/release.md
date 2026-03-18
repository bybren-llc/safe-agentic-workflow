---
description: Execute full version release — merge PRs, version bump, tag, GitHub Release, sync branches, cleanup
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
argument-hint: "<version> (e.g., v2.7.0)"
---

> **📋 TEMPLATE**: This command uses `{{MAIN_BRANCH}}`, `{{TICKET_PREFIX}}`, and `{{GITHUB_ORG}}/{{GITHUB_REPO}}` placeholders. Replace with your project values.

You are executing a full version release. Follow each phase in order. **Do not skip phases.** Report status after each.

## Input

The user provides a version number (e.g., `v2.7.0`). If not provided, determine the next version by:

```bash
git tag -l 'v*' | sort -V | tail -1
```

Then bump the minor version (or ask the user for major/minor/patch).

---

## Phase 1: Pre-Release Validation

### 1.1 Verify Clean State

```bash
git status                    # Must be clean
git branch --show-current     # Must be on {{MAIN_BRANCH}}
git fetch origin
git log --oneline origin/{{MAIN_BRANCH}}..HEAD  # Must be empty (in sync)
```

**BLOCKER**: Working tree must be clean and branch must be current with remote.

### 1.2 Check Open PRs

```bash
gh pr list --state open
```

**Decision point**: If there are open PRs intended for this release, merge them first (Phase 2). If none, skip to Phase 3.

### 1.3 Verify CI Status

For each open PR to merge:

```bash
gh pr view <NUMBER> --json mergeStateStatus,statusCheckRollup \
  --jq '{state: .mergeStateStatus, checks: [.statusCheckRollup[] | "\(.name): \(.conclusion // .status)"]}'
```

**BLOCKER**: All checks must pass. Do not merge PRs with failing required checks.

---

## Phase 2: Merge Open PRs (if any)

### 2.1 Merge in Dependency Order

For each PR (merge in order — base dependencies first):

```bash
# Squash merge with proper commit message
gh pr merge <NUMBER> --squash --subject "type(scope): description [{{TICKET_PREFIX}}-XXX]"
```

### 2.2 Rebase Dependent PRs

After each merge, rebase any remaining PRs that target the same base:

```bash
git fetch origin
git checkout <dependent-branch>
git rebase origin/{{MAIN_BRANCH}}
git push --force-with-lease origin <dependent-branch>
```

Wait for CI to re-run before merging the next PR.

### 2.3 Sync Local After All Merges

```bash
git checkout {{MAIN_BRANCH}}
git pull origin {{MAIN_BRANCH}}
```

---

## Phase 3: Version Bump

### 3.1 Find and Update Version References

Search for current version references:

```bash
# Find version strings in key files
grep -rn "v[0-9]\+\.[0-9]\+" README.md CLAUDE.md CONTRIBUTING.md --include="*.md" | grep -v node_modules | grep -v releases/ | grep -v whitepapers/
```

Update **only active version references** (not historical references in changelogs, upgrade guides, or KT docs):

- `README.md` — version badges, "now at **vX.Y**" text, caveats section
- Any other files with active version references

### 3.2 Commit Version Bump

```bash
git add -A
git commit -m "chore(release): bump version references to <VERSION>

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

### 3.3 Push Version Bump

```bash
git push origin {{MAIN_BRANCH}}
```

---

## Phase 4: Tag and Release

### 4.1 Generate Release Notes

Gather changes since the last tag:

```bash
LAST_TAG=$(git tag -l 'v*' | sort -V | tail -1)
git log --oneline "$LAST_TAG"..HEAD
```

Group changes by type:
- **Features** (`feat:`)
- **Fixes** (`fix:`)
- **Documentation** (`docs:`)
- **Chores** (`chore:`)

### 4.2 Create Annotated Tag

```bash
git tag -a <VERSION> -m "<VERSION> — <SHORT_SUMMARY>

<CATEGORIZED_CHANGES>"
git push origin <VERSION>
```

### 4.3 Create GitHub Release

```bash
gh release create <VERSION> --title "<VERSION> — <SHORT_SUMMARY>" --notes "$(cat <<'EOF'
## What's New

### Features
- <list features>

### Fixes
- <list fixes>

### Documentation
- <list doc changes>

## Stats
- **X files changed**, Y insertions, Z deletions
- **N Linear tickets** closed
- Fully backward-compatible with <PREVIOUS_VERSION>

## Upgrade
<brief upgrade instructions or "No breaking changes.">
EOF
)"
```

---

## Phase 5: Branch Sync

### 5.1 Sync All Long-Lived Branches

If the repository has multiple long-lived branches (e.g., `main` and `template`, or `main` and `dev`), sync them:

```bash
# Sync secondary branches to match primary
git push origin {{MAIN_BRANCH}}:<SECONDARY_BRANCH>
```

Verify sync:

```bash
git log --oneline origin/{{MAIN_BRANCH}}..origin/<SECONDARY_BRANCH>  # Should be empty
git log --oneline origin/<SECONDARY_BRANCH>..origin/{{MAIN_BRANCH}}  # Should be empty
```

### 5.2 Verify All Tags Pushed

```bash
git tag -l 'v*' | sort -V | tail -5
gh api repos/{{GITHUB_ORG}}/{{GITHUB_REPO}}/tags --jq '.[0:5] | .[].name'
```

---

## Phase 6: Cleanup

### 6.1 Delete Merged PR Branches

```bash
# List remote branches that are not main/dev/template
gh api repos/{{GITHUB_ORG}}/{{GITHUB_REPO}}/branches --jq '.[].name' | grep -v '^main$\|^dev$'
```

For each stale branch from a merged PR:

```bash
gh api -X DELETE repos/{{GITHUB_ORG}}/{{GITHUB_REPO}}/git/refs/heads/<BRANCH_NAME>
```

### 6.2 Clean Local

```bash
# Delete local branches that were merged
git branch --merged {{MAIN_BRANCH}} | grep -v '^\*\|{{MAIN_BRANCH}}' | xargs -r git branch -d

# Prune stale remote tracking refs
git fetch --prune origin

# Garbage collect
git gc --prune=now
```

### 6.3 Final Verification

```bash
echo "=== Local ===" && git branch -v
echo "=== Remote ===" && gh api repos/{{GITHUB_ORG}}/{{GITHUB_REPO}}/branches --jq '.[].name'
echo "=== Tags ===" && git tag -l 'v*' | sort -V | tail -5
echo "=== Release ===" && gh release view <VERSION> --json tagName,publishedAt,isDraft --jq '.'
echo "=== Open PRs ===" && gh pr list --state open
```

---

## Output Format

Report final release status:

- ✅ PRs merged: (list with numbers)
- ✅ Version bumped: `<OLD>` → `<NEW>`
- ✅ Tag created: `<VERSION>`
- ✅ GitHub Release published: (URL)
- ✅ Branches synced: (list)
- ✅ Stale branches deleted: (count)
- ✅ Local cleaned and synced

Or flag blockers:

- ❌ BLOCKER: (description and recommended action)

## Success Criteria

- Tag exists locally and on remote
- GitHub Release is published (not draft)
- All long-lived branches are in sync
- No stale merged-PR branches remain
- Local working tree is clean on {{MAIN_BRANCH}}
- Zero open PRs intended for this release

## Customization Guide

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `{{MAIN_BRANCH}}` | Primary branch name | `main`, `template` |
| `{{TICKET_PREFIX}}` | Linear/Jira ticket prefix | `WOR`, `SCA`, `PROJ` |
| `{{GITHUB_ORG}}` | GitHub organization | `bybren-llc` |
| `{{GITHUB_REPO}}` | GitHub repository name | `safe-agentic-workflow` |
