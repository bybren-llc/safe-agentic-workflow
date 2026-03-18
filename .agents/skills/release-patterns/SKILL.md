---
name: release-patterns
description: >
  PR creation, CI/CD validation, merge coordination, and release patterns.
  Use when creating pull requests, running pre-PR validation, checking CI
  status, coordinating merges, or managing releases. Do NOT use for routine
  development commits -- see safe-workflow skill instead.
---

# Release Patterns Skill

> **TEMPLATE**: This skill uses `{{PLACEHOLDER}}` tokens. Replace with your project values before use.

## Purpose

Ensure consistent PR creation, CI/CD validation, and release coordination following rebase-first workflow.

## When This Skill Applies

- Creating pull requests
- Running pre-PR validation
- Checking CI/CD status
- Coordinating merge timing
- Verifying rebase status

## Stop-the-Line Conditions

### FORBIDDEN Patterns

```bash
# FORBIDDEN: Missing ticket reference
gh pr create --title "feat: add feature"  # Missing [{{TICKET_PREFIX}}-XXX]

# FORBIDDEN: Using squash/merge commits (breaks linear history)
gh pr merge --squash
gh pr merge --merge

# FORBIDDEN: Skipping CI validation
git push origin feature  # Without {{CI_VALIDATE_COMMAND}} first

# FORBIDDEN: Pushing without rebase
git push origin feature  # When branch is behind {{MAIN_BRANCH}}
```

### CORRECT Patterns

```bash
# CORRECT: Ticket reference in title
gh pr create --title "feat(scope): description [{{TICKET_PREFIX}}-XXX]"

# CORRECT: Rebase merge only
gh pr merge --rebase --delete-branch

# CORRECT: CI validation before push
{{CI_VALIDATE_COMMAND}} && git push --force-with-lease

# CORRECT: Always rebase first
git fetch origin && git rebase origin/{{MAIN_BRANCH}}
git push --force-with-lease origin {{TICKET_PREFIX}}-XXX-description
```

## Pre-PR Checklist (MANDATORY)

Before creating any PR:

- [ ] Branch name: `{{TICKET_PREFIX}}-{number}-{description}`
- [ ] Commits follow: `type(scope): description [{{TICKET_PREFIX}}-XXX]`
- [ ] Rebased on latest {{MAIN_BRANCH}}: `git fetch origin && git rebase origin/{{MAIN_BRANCH}}`
- [ ] CI passes locally: `{{CI_VALIDATE_COMMAND}}`
- [ ] Linear history: No merge commits (`git log --oneline --graph -10`)

## CI/CD Validation Command

```bash
# MANDATORY before any PR
{{CI_VALIDATE_COMMAND}} && echo "READY FOR PR" || echo "FIX ISSUES FIRST"
```

## PR Creation Template

```bash
gh pr create --title "feat(scope): description [{{TICKET_PREFIX}}-XXX]" --body "$(cat <<'EOF'
## Summary

Implements [feature/fix] as specified in ticket {{TICKET_PREFIX}}-XXX.

**Ticket**: https://linear.app/{{LINEAR_WORKSPACE}}/issue/{{TICKET_PREFIX}}-XXX

## Changes Made

- Change 1
- Change 2

## Testing

{{CI_VALIDATE_COMMAND}}
# All checks passed

## Pre-merge Checklist

- [x] Rebased on latest {{MAIN_BRANCH}}
- [x] CI passes
- [x] Ticket referenced
EOF
)"
```

## Merge Strategy

**ONLY** use rebase merge:

```bash
# CORRECT
gh pr merge --rebase --delete-branch

# NEVER
gh pr merge --squash   # Loses commit history
gh pr merge --merge    # Creates merge commits
```

## QAS Gate (MANDATORY)

Before merging any PR, invoke QAS for independent review:

```text
Prompt: "Review PR #XXX for {{TICKET_PREFIX}}-YYY. Validate commit format,
CI status, patterns."
```

## Release Workflow

### Version Bump

```bash
# Determine version bump based on commits
# feat: -> minor bump
# fix: -> patch bump
# feat!: or BREAKING CHANGE -> major bump

# Tag the release
git tag -a v{{VERSION}} -m "Release v{{VERSION}}"
git push origin v{{VERSION}}
```

### GitHub Release

```bash
gh release create v{{VERSION}} --title "v{{VERSION}}" --notes "$(cat <<'EOF'
## Changes

- feat(scope): description [{{TICKET_PREFIX}}-XXX]
- fix(scope): description [{{TICKET_PREFIX}}-YYY]

## Breaking Changes

None

## Migration Steps

None required
EOF
)"
```

### Branch Sync (Post-Release)

```bash
# After release merge, sync branches
git checkout {{MAIN_BRANCH}} && git pull origin {{MAIN_BRANCH}}
git checkout dev && git pull origin dev
git merge {{MAIN_BRANCH}}  # Only case where merge commits are allowed
git push origin dev
```

## Authoritative References

- **PR Template**: `.github/pull_request_template.md`
- **Workflow Guide**: `CONTRIBUTING.md` (Pull Request Process section)
- **CI/CD Pipeline**: `docs/ci-cd/CI-CD-Pipeline-Guide.md`
- **Agent Workflow SOP**: `docs/sop/AGENT_WORKFLOW_SOP.md`
