# /rebase-and-sync - Sync Feature Branch with Main

Rebase current feature branch on latest main to stay up-to-date.

**Usage**: `/rebase-and-sync` or `/rebase-and-sync --merge` (to merge after rebase)

## Steps

### 1. Safety Checks
```bash
# Ensure not on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" = "main" ]; then
  echo "ERROR: Already on main branch. Nothing to rebase."
  exit 1
fi

# Ensure no uncommitted changes
if ! git diff-index --quiet HEAD --; then
  echo "BLOCKED: Uncommitted changes detected"
  echo "Commit or stash changes first:"
  git status --short
  exit 1
fi

echo "Safety checks passed"
```

### 2. Execute Rebase
```bash
echo "Rebasing $CURRENT_BRANCH on latest main..."

# Fetch latest from origin
git fetch origin main

# Perform rebase
git rebase origin/main

if [ $? -ne 0 ]; then
  echo "Rebase failed. Resolve conflicts and continue:"
  echo "1. Fix conflicts in each file"
  echo "2. git add <resolved-files>"
  echo "3. git rebase --continue"
  echo "4. Re-run /rebase-and-sync"
  exit 1
fi

echo "Rebase successful"
```

### 3. Run Quality Gates (Post-Rebase)
```bash
echo "Running quality gates after rebase..."

# Lint
npm run lint || echo "Linting issues detected"

# Type check
npm run typecheck || echo "Type errors detected"

# Tests
npm run test || echo "Test failures detected"

echo "Quality gates complete"
```

### 4. Force Push to Remote
```bash
echo "Pushing rebased branch to remote..."

# Force push is needed after rebase
git push --force-with-lease origin "$CURRENT_BRANCH"

if [ $? -ne 0 ]; then
  echo "Push failed. Branch may have been updated by another agent."
  echo "Pull latest and retry."
  exit 1
fi

echo "Branch synced with remote"
```

### 5. Optional: Auto-Merge to Main
```bash
if [[ "$ARGUMENTS" == *"--merge"* ]]; then
  echo "--merge flag detected. Proceeding with merge to main..."
  
  # Switch to main
  git checkout main
  git pull origin main
  
  # Merge feature branch
  git merge --no-ff "$CURRENT_BRANCH" -m "Merge $CURRENT_BRANCH into main"
  
  if [ $? -ne 0 ]; then
    echo "Merge failed. Resolve conflicts."
    exit 1
  fi
  
  git push origin main
  
  echo "Feature branch merged to main"
  echo "Run /planBranch to start next work chunk"
else
  echo "Rebase complete. Feature branch synced with main."
  echo ""
  echo "Next Options:"
  echo "  - Continue working on this branch"
  echo "  - Run '/rebase-and-sync --merge' when ready to merge"
  echo "  - Run '/gitFlow' to complete work and generate handoff"
fi
```

### 6. Update Beads Status
```bash
echo "Updating Beads..."

# Note the sync in relevant issues
bd update [issue-id] --notes "Branch rebased on latest main"
```

## Summary

This command:
1. Validates no uncommitted changes
2. Rebases feature branch on latest main
3. Runs quality gates post-rebase
4. Force pushes rebased branch
5. Optionally merges to main with `--merge` flag

**Use when**:
- Feature branch is >10 commits behind main
- Before creating PR
- Daily sync during long work sessions
- After other team members merge to main

**Flags**:
- `--merge`: Merge to main after successful rebase

**ConTS Note**: Update relevant ConTS tickets with rebase status
