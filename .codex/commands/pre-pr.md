# Pre-PR Validation Command

You are preparing to create a Pull Request. Execute the MANDATORY validation workflow per CONTRIBUTING.md.

## Validation Checklist

### 1. Code Quality Validation

Run CI validation suite:

```bash
{{CI_VALIDATE_COMMAND}}
```

This runs:
- TypeScript type checking
- Linting validation
- Unit tests
- Format checking

**BLOCKER**: Must pass before proceeding. Fix any failures.

### 2. Documentation Linting

Auto-fix markdown formatting:

```bash
{{LINT_FIX_COMMAND}}
```

Verify no errors remain:

```bash
{{LINT_COMMAND}}
```

### 3. Git Status Check

Verify all changes committed:

```bash
git status
```

**BLOCKER**: No uncommitted changes allowed in PR.

### 4. Rebase onto Latest Main

Fetch and rebase:

```bash
git fetch origin
git log HEAD..origin/{{MAIN_BRANCH}} --oneline
```

If commits exist upstream, run:
```bash
git rebase origin/{{MAIN_BRANCH}}
```

**BLOCKER**: Must be up-to-date with main branch.

### 5. Commit Message Validation

Check all commits follow SAFe format:

```bash
git log origin/{{MAIN_BRANCH}}..HEAD --oneline
```

**Required format**: `type(scope): description [{{TICKET_PREFIX}}-XXX]`

**BLOCKER**: All commits must reference Linear ticket.

### 6. Documentation Updates

Verify related docs updated:
- [ ] CODEX.md / CLAUDE.md (if architecture/workflow changed)
- [ ] CONTRIBUTING.md (if process changed)
- [ ] Specialized docs (feature-specific)

### 7. PR Template Ready

Confirm you can fill out ALL sections:
- Summary with Linear ticket link
- Changes Made
- Testing
- Impact Analysis
- Pre-merge Checklist

## Output

Report results for each step:
- PASS: Step completed successfully
- WARNING: Non-blocking issue found
- BLOCKER: Must fix before PR

## Success Criteria

All validation steps pass. Ready to create PR with:

```bash
git push --force-with-lease origin {branch-name}
gh pr create --title "..." --body "..."
```

Report final status and any remaining blockers.
