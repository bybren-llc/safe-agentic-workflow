---
name: release-patterns
description: PR creation, CI/CD validation, and release coordination patterns. Use when creating pull requests, running pre-PR validation, checking CI status, or coordinating merges.
---

# Release Patterns Skill

## Purpose

Ensure consistent PR creation, CI/CD validation, and release coordination following rebase-first workflow.

## When This Skill Applies

Invoke this skill when:

- Creating pull requests
- Running pre-PR validation (`bun lint && bun typecheck && bun test`)
- Checking CI/CD status
- Coordinating merge timing
- Verifying rebase status

## Stop-the-Line Conditions

### FORBIDDEN Patterns

```bash
# FORBIDDEN: Missing ticket reference
gh pr create --title "feat: add feature"  # Missing [ConTS-XXX]

# FORBIDDEN: Using squash/merge commits
gh pr merge --squash  # Breaks linear history
gh pr merge --merge   # Creates merge commit

# FORBIDDEN: Skipping CI validation
git push origin feature  # Without bun lint && bun test first

# FORBIDDEN: Pushing without rebase
git push origin feature  # When branch is behind main
```

### CORRECT Patterns

```bash
# CORRECT: Ticket reference in title
gh pr create --title "feat(scope): description [ConTS-XXX]"

# CORRECT: Rebase merge only
gh pr merge --rebase --delete-branch

# CORRECT: CI validation before push
bun lint && bun typecheck && bun test && git push --force-with-lease

# CORRECT: Always rebase first
git fetch origin && git rebase origin/main
git push --force-with-lease origin ConTS-XXX-description
```

## Pre-PR Checklist (MANDATORY)

Before creating any PR:

- [ ] Branch name: `ConTS-{number}-{description}` or `feature/{description}`
- [ ] Commits follow: `type(scope): description [ConTS-XXX]`
- [ ] Rebased on latest main: `git fetch origin && git rebase origin/main`
- [ ] CI passes locally: `bun lint && bun typecheck && bun test`
- [ ] Linear history: No merge commits (`git log --oneline --graph -10`)

## CI/CD Validation Command

```bash
# MANDATORY before any PR
bun lint && bun typecheck && bun test && echo "READY FOR PR" || echo "FIX ISSUES FIRST"
```

## PR Creation Template

````bash
gh pr create --title "feat(scope): description [ConTS-XXX]" --body "$(cat <<'EOF'
## Summary

Implements [feature/fix] as specified in Beads issue ConTS-XXX.

**Beads Issue**: `bd show ConTS-XXX`
**Linear Evidence** (if applicable): https://linear.app/{LINEAR_WORKSPACE}/issue/ConTS-XXX

## Changes Made

- Change 1
- Change 2

## Testing

```bash
bun lint && bun typecheck && bun test
# All checks passed
````

## Pre-merge Checklist

- [x] Rebased on latest main
- [x] CI passes
- [x] Beads issue referenced

Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"

````

## Merge Strategy

**ONLY** use rebase merge:

```bash
# CORRECT
gh pr merge --rebase --delete-branch

# NEVER
gh pr merge --squash   # Loses commit history
gh pr merge --merge    # Creates merge commits
````

## QAS Gate (MANDATORY)

Before merging any PR, invoke QAS for independent review:

```text
Task tool: QAS subagent
Prompt: "Review PR #XXX for ConTS-YYY. Validate commit format, CI status, patterns."
```

## Authoritative References

- **PR Template**: `.github/PR-BEAD-001-DESCRIPTION.md`
- **Workflow Guide**: `CLAUDE.md` (Git Workflow & Branch Management section)
- **CI/CD Pipeline**: `.github/workflows/`
- **RPI Workflow**: `CLAUDE.md` (RPI Workflow Integration section)
