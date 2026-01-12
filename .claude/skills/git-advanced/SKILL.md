---
name: git-advanced
description: Advanced Git operations for teams using rebase-first workflow with linear history. Includes quality gates, handoff generation, and safe merge patterns.
---

# Git Advanced Patterns

## Purpose
Guide safe Git operations with rebase-first workflow, quality gates, and automated handoff generation.

## Forbidden Operations

| Operation | Why | Safe Alternative |
|-----------|-----|------------------|
| `git push --force` to main | Destroys shared history | Never force push main |
| `git push --force` to dev | Team disruption | `git push --force-with-lease` |
| Merge commits on feature branches | Non-linear history | Rebase instead |
| Skip pre-commit hooks | Quality bypass | Fix the issues |
| Rewrite pushed history | Breaks collaborators | Only before first push |

## Quality Gates (MANDATORY)

Before ANY commit/merge, run:

```bash
# All checks must pass
bun run lint && bun run typecheck && bun run test
```

## The gitFlow Workflow

Complete workflow for finishing work and merging to main:

### Step 1: Pre-Flight Checks

```bash
# Ensure on feature branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" = "main" ]; then
  echo "ERROR: Cannot run gitFlow on main branch"
  exit 1
fi

# Check for uncommitted changes
git status
```

### Step 2: Run Quality Gates

```bash
echo "Running quality gates..."

if ! bun run lint; then
  echo "Lint failed. Fix errors and try again."
  exit 1
fi

if ! bun run typecheck; then
  echo "Type check failed. Fix errors and try again."
  exit 1
fi

if ! bun run test; then
  echo "Tests failed. Fix tests and try again."
  exit 1
fi

echo "All quality gates passed"
```

### Step 3: Commit Remaining Changes

```bash
git add .
git commit -m "feat: your commit message [ConTS-XXX]"
```

### Step 4: Rebase and Merge

```bash
# Fetch latest main
git fetch origin main

# Rebase onto main
git rebase origin/main

# If conflicts, resolve them:
# 1. Edit conflicting files
# 2. git add <resolved-files>
# 3. git rebase --continue

# Switch to main and merge
git checkout main
git pull origin main
git merge --ff-only $CURRENT_BRANCH

# Push main
git push origin main

# Clean up feature branch
git branch -d $CURRENT_BRANCH
git push origin --delete $CURRENT_BRANCH
```

### Step 5: Generate Handoff Document

```bash
HANDOFF_FILE="handoffs/handoff-$(date +%Y%m%d-%H%M).md"

cat > "$HANDOFF_FILE" << EOF
# Handoff Document - $(date +%Y-%m-%d %H:%M)

## Work Completed

**Branch**: $CURRENT_BRANCH
**Merged to**: main
**Date**: $(date +%Y-%m-%d)

## Changes Summary

$(git log --oneline -5)

## Files Modified

$(git diff --name-only HEAD~5..HEAD)

## Testing Status

- [x] Lint: PASSED
- [x] Type checks: PASSED
- [x] Unit tests: PASSED
- [ ] E2E tests: [Manual verification needed]

## Next Steps for Incoming Agent

1. Review this handoff document
2. Run /planBranch [next-feature-name] to start new work
3. Ensure all quality gates pass before proceeding

---

Ready for: /clear -> Paste this handoff -> /planBranch
EOF
```

## Rebase Workflow (Daily)

Keep your feature branch up to date:

```bash
# Fetch latest
git fetch origin main

# Rebase your work onto main
git rebase origin/main

# If conflicts:
# 1. Resolve conflicts in files
# 2. git add <resolved-files>
# 3. git rebase --continue

# Push your updated branch
git push --force-with-lease origin feature/your-branch
```

## Cherry-Pick Pattern

For selective commit extraction:

```bash
# Single commit
git cherry-pick <commit-sha>

# Range of commits
git cherry-pick <start-sha>^..<end-sha>

# If conflicts, resolve and continue:
git cherry-pick --continue
```

## Git Bisect for Bug Hunting

```bash
# Start bisect
git bisect start
git bisect bad HEAD
git bisect good <last-known-good-commit>

# Git will checkout commits for testing
# After testing each:
git bisect good  # or
git bisect bad

# When done, get the bad commit
# Then reset
git bisect reset
```

## Pre-Push Checklist

Before pushing any branch:

- [ ] All tests pass (`bun run test`)
- [ ] Type check passes (`bun run typecheck`)
- [ ] Lint passes (`bun run lint`)
- [ ] Correct branch selected
- [ ] Commit messages follow convention
- [ ] No sensitive data in commits

## Commit Message Format

```
type(scope): description [ConTS-XXX]

Types:
- feat: New feature
- fix: Bug fix
- docs: Documentation
- refactor: Code change (no feature/fix)
- test: Adding tests
- chore: Maintenance

Examples:
- feat(convex): add user authentication [ConTS-123]
- fix(auth): resolve token refresh race condition [ConTS-456]
- docs(readme): update setup instructions
```

## Recovery Tools

### Undo Last Commit (Not Pushed)
```bash
git reset --soft HEAD~1
```

### Find Lost Commits
```bash
git reflog
git checkout <lost-commit-sha>
```

### Abort Rebase in Progress
```bash
git rebase --abort
```

## Safe Alternatives Summary

| Risky | Safe |
|-------|------|
| `git push -f` | `git push --force-with-lease` |
| `git reset --hard` | `git stash` first |
| `git checkout .` | Check status first |
| Delete branch | Merge first |
