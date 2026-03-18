# Check Workflow Command

Perform a quick workflow health check against CONTRIBUTING.md requirements.

## Status Checks

### 1. Git Status

```bash
git status
git branch --show-current
```

Verify:
- Current branch follows `{{TICKET_PREFIX}}-{number}-{description}` format
- No uncommitted changes (or document what's uncommitted)
- Branch relationship to origin/{{MAIN_BRANCH}}

### 2. Linear Ticket Connection

Extract ticket number from branch name.

```bash
git branch --show-current | grep -oE '[A-Z]+-[0-9]+'
```

Check ticket status via Linear web UI or CLI.

Verify:
- Ticket exists
- Ticket is in appropriate status
- Work aligns with ticket description

### 3. Commit History

Review commits since main:

```bash
git log origin/{{MAIN_BRANCH}}..HEAD --oneline
```

Verify:
- All commits follow SAFe format: `type(scope): description [{{TICKET_PREFIX}}-XXX]`
- All commits reference correct Linear ticket
- Commit messages are descriptive

### 4. Rebase Status

Check if branch needs rebasing:

```bash
git fetch origin
git log HEAD..origin/{{MAIN_BRANCH}} --oneline
```

Report:
- How many commits behind main
- Whether rebase is needed

### 5. Documentation Status

Check if docs need updating:
- CODEX.md / CLAUDE.md (architecture/commands changed?)
- CONTRIBUTING.md (process changed?)
- Feature-specific docs created?

## Output Format

Provide traffic-light status:
- GREEN: All checks pass, workflow healthy
- YELLOW: Minor issues, can proceed with caution
- RED: Blockers present, must fix before PR

List specific issues found and recommendations.
