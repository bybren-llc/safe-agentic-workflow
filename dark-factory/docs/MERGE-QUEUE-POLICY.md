# Merge Queue Policy

The Dark Factory enforces merge queue + squash merge as the single path to
trunk. This policy exists because multiple autonomous agents creating PRs
simultaneously require serialized, safe merging.

---

## Why Merge Queue + Squash

| Concern | Solution |
|---------|----------|
| Multiple agents pushing PRs concurrently | Merge queue serializes merges |
| Readable git history under high bot throughput | Squash: 1 PR = 1 commit on trunk |
| Easy rollback of bad agent work | `git revert <single_commit>` |
| No rebase SHA churn from long-running branches | Squash avoids it entirely |
| Granular work archaeology | PR body + Linear artifacts + agent logs |

---

## Enforcement Architecture

```
Agent creates PR
    |
    v
gh pr merge --auto --squash     <-- only allowed merge command
    |
    v
GitHub Merge Queue picks up PR
    |
    v
CI runs on merge_group event    <-- required workflows must have this trigger
    |
    v
Queue merges (squash) to {{MAIN_BRANCH}}
```

**There is no other path to trunk.** No direct push, no manual merge, no
`--merge-queue` flag (that's not a real `gh` option). The queue is enforced by
GitHub branch rulesets, not by client-side flags.

---

## GitHub Ruleset Configuration

Import the provided ruleset template via GitHub Settings > Rules > Rulesets:

```
dark-factory/templates/github/merge-queue-ruleset.json
```

### What the Ruleset Enforces

1. **Merge queue required** on `{{MAIN_BRANCH}}`
   - Merge method: `squash`
   - Max entries: 5 (parallel queue groups)
   - Timeout: 30 minutes per check
   - Strategy: `ALLGREEN` (all checks must pass)

2. **Required status checks**
   - `strict_required_status_checks_policy: false` (queue handles serialization,
     no manual rebase requirement)
   - Customize the `required_status_checks` array for your CI jobs

3. **No bypass actors** (enforce for everyone, including admins)

### Manual Setup Steps

If you cannot import the JSON ruleset:

1. Go to **Settings > Rules > Rulesets > New ruleset**
2. Name: `dark-factory-merge-queue`
3. Target: Branch `{{MAIN_BRANCH}}`
4. Add rule: **Require merge queue**
   - Merge method: Squash
   - Min entries: 1
   - Max entries: 5
   - Wait time: 1 minute
   - Grouping: ALLGREEN
5. Add rule: **Require status checks**
   - Disable "Require branches to be up to date" (queue handles this)
   - Add your required CI check names
6. Add rule: **Block force pushes**
7. Save

---

## CI Workflow Requirements

All required CI workflows MUST include the `merge_group` trigger. Without it,
the merge queue cannot run CI on queued PRs.

### Required Trigger Configuration

```yaml
on:
  pull_request:
    branches: ["{{MAIN_BRANCH}}"]
  merge_group:
    branches: ["{{MAIN_BRANCH}}"]
```

Both triggers are required:
- `pull_request` -- runs CI when PR is created/updated (pre-queue feedback)
- `merge_group` -- runs CI when PR enters the queue (actual gate)

### Verification Script

Run this to audit all workflow files:

```bash
#!/usr/bin/env bash
# Verify all required workflows have merge_group trigger

workflow_dir=".github/workflows"
if [[ ! -d "$workflow_dir" ]]; then
    echo "No .github/workflows/ directory found."
    exit 1
fi

exit_code=0

for workflow in "$workflow_dir"/*.yml; do
    name="$(basename "$workflow")"

    # Check if this workflow runs on pull_request (it's a required check)
    if grep -q 'pull_request' "$workflow"; then
        if grep -q 'merge_group' "$workflow"; then
            echo "OK:   $name (has merge_group trigger)"
        else
            echo "FAIL: $name (missing merge_group trigger)"
            exit_code=1
        fi
    else
        echo "SKIP: $name (not a PR workflow)"
    fi
done

exit $exit_code
```

The `factory-setup.sh` readiness gate runs an equivalent check automatically.

---

## Rebase Policy Adjustment

The existing harness recommends "rebase on base before PR." With merge queue
enabled, this creates unnecessary churn:

- The queue serializes merges -- it handles conflicts
- Manual rebase before enqueue means re-running CI on rebased SHAs
- Long-running agent branches would need frequent rebasing

**With merge queue**: `strict_required_status_checks_policy` is set to `false`
in the ruleset. This means PRs do not need to be up-to-date with
`{{MAIN_BRANCH}}` before entering the queue. The queue itself ensures
consistency.

**Without merge queue** (interactive workflow): the existing rebase-first policy
in `CONTRIBUTING.md` still applies. This policy change only affects queued merges.

---

## Agent Behavior

### Creating PRs

Agents create PRs using:
```bash
gh pr create --title "type(scope): description [{{TICKET_PREFIX}}-XXX]" --body "..."
```

### Enqueuing for Merge

Agents enqueue PRs using:
```bash
gh pr merge --auto --squash
```

This tells GitHub: "merge this PR automatically via the queue when all checks
pass." The `--squash` flag is advisory -- the queue's configured merge method
(squash) takes precedence.

### What Agents Must NOT Do

- `git push origin {{MAIN_BRANCH}}` -- blocked by branch protection
- `gh pr merge` without `--auto` -- blocked by merge queue requirement
- `gh pr merge --merge` or `--rebase` -- queue enforces squash
- Any form of direct merge bypass

### Stop-the-Line

If the merge queue is unavailable or broken:
- **Agents stop creating PRs**
- **TDM reports the blocker**
- **No fallback to direct merge** -- ever

This is a hard policy. The queue is the single source of truth for merging.

---

## Squash Commit Messages

With squash merge, the PR title becomes the commit message on trunk. Therefore:

- PR titles MUST follow: `type(scope): description [{{TICKET_PREFIX}}-XXX]`
- The PR body is preserved in the squash commit description
- Linear auto-close works because the ticket reference is in the commit message

---

## Monitoring the Queue

```bash
# View queue status for a specific PR
gh pr checks <PR-NUMBER>

# View all queued PRs
gh pr list --state open --json number,title,mergeStateStatus

# View merge queue (requires GitHub UI or API)
gh api repos/{owner}/{repo}/mergequeue
```

The TDM agent monitors queue status and reports blockers to the team.
