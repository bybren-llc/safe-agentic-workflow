---
name: git-advanced
description: Advanced git operations including rebase, bisect, cherry-pick, and conflict resolution. Use when rebasing branches, debugging with bisect, cherry-picking commits, or resolving complex merge conflicts.
---

# Git Advanced Skill

## Purpose

Provide guidance for advanced git operations with safety considerations. This project uses a **rebase-first workflow** with linear history—understand these patterns to avoid breaking the codebase.

## When This Skill Applies

- Rebasing feature branches onto main
- Using git bisect to find bugs
- Cherry-picking commits between branches
- Resolving complex merge conflicts
- Recovering from git mistakes

## Stop-the-Line Conditions

### FORBIDDEN Operations

```bash
# FORBIDDEN: Force push to protected branches
git push --force origin main    # NEVER
git push --force origin master  # NEVER

# FORBIDDEN: Merge commits on main branch
git merge feature-branch       # Use rebase-and-merge PR strategy

# FORBIDDEN: Skip pre-commit hooks
git commit --no-verify         # Hooks exist for a reason

# FORBIDDEN: Rewriting shared history
git rebase -i HEAD~5 && git push --force  # If already pushed
```

### SAFE Operations

```bash
# SAFE: Force-with-lease on your feature branch
git push --force-with-lease origin {{TICKET_PREFIX}}-XXX-feature  # Safe

# SAFE: Interactive rebase before first push
git rebase -i origin/main   # Squash/clean local commits

# SAFE: Force push after conflict resolution
git rebase origin/main && git push --force-with-lease origin {{TICKET_PREFIX}}-XXX-feature
```

## Rebase Workflow (Standard)

### Before Creating PR

```bash
# 1. Fetch latest changes
git fetch origin main

# 2. Rebase onto latest main
git rebase origin/main

# 3. If conflicts, resolve them
git status                   # See conflicted files
# ... edit files to resolve ...
git add <resolved-files>
git rebase --continue

# 4. Push with force-with-lease
git push --force-with-lease origin {{TICKET_PREFIX}}-XXX-feature
```

### During PR Review (After Feedback)

```bash
# 1. Make requested changes
git add . && git commit -m "fix: address PR feedback [{{TICKET_PREFIX}}-XXX]"

# 2. Fetch and rebase again
git fetch origin main
git rebase origin/main

# 3. Push update
git push --force-with-lease origin {{TICKET_PREFIX}}-XXX-feature
```

## Git Bisect (Finding Bugs)

### When to Use

Use bisect when you know a bug was introduced at some point but don't know which commit.

### Bisect Workflow

```bash
# 1. Start bisect
git bisect start

# 2. Mark current state (has bug)
git bisect bad

# 3. Mark a known good commit
git bisect good <commit-sha>
# e.g., git bisect good abc1234

# 4. Git checks out middle commit - test it
yarn test:unit  # or manual test

# 5. Tell git if this commit is good or bad
git bisect good  # or
git bisect bad

# 6. Repeat until found
# Git will tell you the first bad commit

# 7. End bisect
git bisect reset
```

### Automated Bisect

```bash
# Run a test script automatically
git bisect start HEAD abc1234
git bisect run yarn test:specific-test
```

## Cherry-Pick (Selective Commits)

### When to Use

- Backporting a fix to an older branch
- Pulling a specific commit from one branch to another
- Selective feature extraction

### Cherry-Pick Workflow

```bash
# 1. Find the commit SHA
git log --oneline branch-name | head -20

# 2. Cherry-pick to current branch
git cherry-pick <commit-sha>

# 3. If conflicts, resolve them
git status
# ... resolve conflicts ...
git add <resolved-files>
git cherry-pick --continue

# 4. Push the result
git push origin current-branch
```

### Cherry-Pick Multiple Commits

```bash
# Range of commits (oldest..newest, exclusive of oldest)
git cherry-pick abc123^..def456

# Specific commits
git cherry-pick abc123 def456 ghi789
```

## Conflict Resolution

### Common Conflict Scenarios

| Scenario                 | Resolution Strategy             |
| ------------------------ | ------------------------------- |
| Same line edited         | Choose one version or combine   |
| File deleted vs modified | Decide: keep modified or delete |
| Rename conflicts         | Decide which name to use        |
| Binary file conflicts    | Choose one version explicitly   |

### Conflict Resolution Steps

```bash
# 1. See what's conflicted
git status

# 2. Open conflicted file, look for markers
<<<<<<< HEAD
your changes
=======
their changes
>>>>>>> branch-name

# 3. Edit file to resolve (remove markers, keep correct code)

# 4. Mark as resolved
git add <resolved-file>

# 5. Continue rebase/merge
git rebase --continue
# or
git merge --continue
```

### Conflict Prevention

```bash
# Rebase frequently to avoid large conflicts
git fetch origin main
git rebase origin/main  # Do this daily during long features

# Check for potential conflicts before rebase
git diff origin/main...HEAD --stat
```

## Recovery Commands

### Abort Operations

```bash
# Abort rebase
git rebase --abort

# Abort merge
git merge --abort

# Abort cherry-pick
git cherry-pick --abort
```

### Undo Last Commit

```bash
# Keep changes staged
git reset --soft HEAD~1

# Keep changes unstaged
git reset HEAD~1

# Discard changes (DANGEROUS)
git reset --hard HEAD~1
```

### Recover Lost Commits

```bash
# Find lost commits in reflog
git reflog

# Restore to a specific state
git reset --hard HEAD@{n}

# Cherry-pick a lost commit
git cherry-pick <sha-from-reflog>
```

## Safety Guidelines

### When to Ask Before Force Push

**ALWAYS ask first if:**

- You've pushed commits that others might have pulled
- You're working on a shared branch
- You're not 100% sure what will happen
- The branch has been open for > 1 week

### Safe Force Push Pattern

```bash
# 1. Verify you're on correct branch
git branch

# 2. Verify what will be pushed
git log origin/{{TICKET_PREFIX}}-XXX-feature..HEAD --oneline

# 3. Use force-with-lease (protects against overwriting others' work)
git push --force-with-lease origin {{TICKET_PREFIX}}-XXX-feature
```

### Pre-Push Checklist

- [ ] Running `yarn ci:validate` passes
- [ ] On correct branch (not main or master)
- [ ] Commits have proper message format
- [ ] No sensitive data in commits

## Reference

- **CONTRIBUTING.md**: Branch naming and commit format
- **safe-workflow skill**: Complete workflow patterns
- **release-patterns skill**: PR and merge patterns
