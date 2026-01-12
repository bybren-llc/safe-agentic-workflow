# /gitFlow - Complete Check-In and Merge Workflow

Complete current work chunk, merge to main, and prepare for handoff.

## Steps

### 1. Pre-Flight Checks
```bash
# Ensure we are on a feature branch (not main)
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" = "main" ]; then
  echo "ERROR: Cannot run /gitFlow on main branch"
  echo "This command is for feature branches only"
  exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
  echo "Uncommitted changes detected. Committing..."
fi
```

### 2. Run Quality Gates
```bash
echo "Running quality gates..."

# Lint check
if ! npm run lint; then
  echo "Lint failed. Fix errors and try again."
  exit 1
fi

# Type check
if ! npm run typecheck; then
  echo "Type check failed. Fix errors and try again."
  exit 1
fi

# Run tests
if ! npm run test; then
  echo "Tests failed. Fix tests and try again."
  exit 1
fi

echo "All quality gates passed"
```

### 3. Commit Any Remaining Changes
```bash
# Stage all changes
git add .

# Create commit with conventional commit message and ConTS reference
echo "Enter commit message (e.g., 'feat: add new feature'):"
read COMMIT_MSG
echo "Enter ConTS ticket (e.g., 'ConTS-1234'):"
read CONTS_TICKET

git commit -m "$COMMIT_MSG

$CONTS_TICKET" || echo "No changes to commit"
```

### 4. Execute Git Rebase and Merge
```bash
echo "Rebasing and merging to main..."

# Fetch latest main
git fetch origin main

# Rebase on main
git rebase origin/main

if [ $? -ne 0 ]; then
  echo "Rebase failed. Resolve conflicts:"
  echo "1. Fix conflicts in each file"
  echo "2. git add <resolved-files>"
  echo "3. git rebase --continue"
  exit 1
fi

# Switch to main and merge
git checkout main
git pull origin main
git merge --no-ff "$CURRENT_BRANCH" -m "Merge $CURRENT_BRANCH into main

$CONTS_TICKET"

if [ $? -ne 0 ]; then
  echo "Merge failed. Check conflicts and resolve manually."
  exit 1
fi

git push origin main

echo "Successfully merged $CURRENT_BRANCH to main"
```

### 5. Update Beads
```bash
echo "Updating Beads issues..."

# Close the associated story/task
bd close [issue-id] --reason "Merged to main in $CURRENT_BRANCH"

# Sync Beads
bd sync
```

### 6. Generate Handoff Document
```bash
HANDOFF_FILE="thoughts/shared/handoffs/handoff-$(date +%Y%m%d-%H%M).md"
mkdir -p thoughts/shared/handoffs

cat > "$HANDOFF_FILE" << HANDOFF_EOF
# Handoff Document - $(date +%Y-%m-%d %H:%M)

## Work Completed

**Branch**: $CURRENT_BRANCH
**Merged to**: main
**Date**: $(date +%Y-%m-%d)
**ConTS Ticket**: $CONTS_TICKET

## SAFe Context

**PI**: [Current PI]
**Sprint**: [Current Sprint]

## Changes Summary

$(git log --oneline -5)

## Files Modified

$(git diff --name-only HEAD~5..HEAD)

## Testing Status

- [x] Unit tests: PASSED
- [x] Type checks: PASSED
- [x] Linting: PASSED
- [ ] E2E tests: [Manual verification needed]

## Beads Status

- ConTS issues closed: [list]
- ConTS issues remaining: [list]

## Next Steps for Incoming Agent

1. Review this handoff document
2. Run \`bd sync\` to get latest Beads state
3. Run \`bd ready --json\` to see unblocked work
4. Run \`/planBranch [next-feature-name]\` to start new work

## Notes

[Add any important context for the next agent]

---

**Ready for**: \`/clear\` -> Paste this handoff -> \`/planBranch\`
HANDOFF_EOF

echo "Handoff document created: $HANDOFF_FILE"
```

### 7. Clean Up Feature Branch
```bash
# Delete local feature branch
git branch -d "$CURRENT_BRANCH"

# Delete remote feature branch (optional)
# git push origin --delete "$CURRENT_BRANCH"

echo "Feature branch cleaned up"
```

### 8. Final Output
```bash
echo ""
echo "/gitFlow Complete!"
echo ""
echo "Feature branch merged to main"
echo "Handoff document ready: $HANDOFF_FILE"
echo "Beads synced"
echo ""
echo "Next Steps:"
echo "1. Review handoff document"
echo "2. Run /clear to reset context"
echo "3. Paste handoff content into fresh context"
echo "4. Run /planBranch [next-feature-name]"
echo ""
```

## Summary

This command automates:
1. Quality gate validation (lint, typecheck, test)
2. Commit remaining changes with ConTS reference
3. Rebase and merge to main
4. Update Beads issues
5. Generate handoff document
6. Clean up merged branch

**Use when**: Completing a work chunk and preparing for handoff
**Next command**: `/planBranch` (after `/clear`)
