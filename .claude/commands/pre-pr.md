---
description: Run complete validation workflow before creating PR
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
---

> **📋 TEMPLATE**: This command is a template. See "Customization Guide" below to adapt for your infrastructure.

You are preparing to create a Pull Request. Execute the MANDATORY @CONTRIBUTING.md validation workflow:

## Validation Checklist

### 1. Code Quality Validation

Run CI validation suite:

```bash
yarn ci:validate
```

This runs:

- TypeScript type checking
- ESLint validation
- Unit tests
- Format checking

**BLOCKER**: Must pass before proceeding. Fix any failures.

### 2. Documentation Linting

Auto-fix markdown formatting:

```bash
yarn lint:md:fix
```

Verify no errors remain:

```bash
yarn lint:md
```

### 3. Git Status Check

Verify all changes committed:

```bash
git status
```

**BLOCKER**: No uncommitted changes allowed in PR.

### 4. Rebase onto Latest Dev

Fetch and rebase:

```bash
git fetch origin
git rebase origin/dev
```

**BLOCKER**: Must be up-to-date with dev branch.

### 5. Commit Message Validation

Check all commits follow SAFe format:

```bash
git log origin/dev..HEAD --oneline
```

**Required format**: `type(scope): description [{TICKET_PREFIX}-XXX]`

**BLOCKER**: All commits must reference Linear ticket.

### 6. Documentation Updates

Verify related docs updated:

- [ ] CLAUDE.md (if architecture/workflow changed)
- [ ] CONTRIBUTING.md (if process changed)
- [ ] Specialized docs (feature-specific)

### 7. PR Template Ready

Confirm you can fill out ALL sections:

- 📋 Summary with Linear ticket link
- 🎯 Changes Made
- 🧪 Testing
- 📊 Impact Analysis
- 🔄 Multi-Team Coordination
- ✅ Pre-merge Checklist

## Workflow

Execute steps 1-6 in order.

Report results for each step:

- ✅ PASS: Step completed successfully
- ⚠️ WARNING: Non-blocking issue found
- ❌ BLOCKER: Must fix before PR

## Success Criteria

All validation steps pass. Ready to create PR with:

```bash
git push --force-with-lease origin {branch-name}
gh pr create --title "..." --body "..."
```

Report final status and any remaining blockers.

## Customization Guide

To adapt this command for your infrastructure, replace these placeholders:

| Placeholder       | Description               | Example               |
| ----------------- | ------------------------- | --------------------- |
| `{TICKET_PREFIX}` | Your Linear ticket prefix | `WOR`, `PROJ`, `TASK` |
