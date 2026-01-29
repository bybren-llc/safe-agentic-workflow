---
description: Sync current work with Linear ticket status
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob, mcp__linear-mcp__*]
---

Synchronize current branch work with Linear ticket, ensuring ticket reflects actual progress.

## Sync Workflow

### 1. Get Current Ticket

Extract WOR number from branch:

```bash
git branch --show-current | grep -oE '{{TICKET_PREFIX}}-[0-9]+'
```

Fetch ticket details:

```text
mcp__linear-mcp__get_issue {{{TICKET_PREFIX}}-number}
```

### 2. Analyze Work Done

Check commits since dev:

```bash
git log origin/dev..HEAD --oneline
git diff origin/dev --stat
```

Analyze:

- Number of commits
- Files changed
- Lines added/removed
- Work scope

### 3. Determine Status

Based on work analysis:

**If commits exist but incomplete**:

- Status: "In Progress"
- Add progress comment

**If work complete, no PR**:

- Status: "Ready for Review" or keep "In Progress"
- Add completion comment

**If PR created**:

- Status: "In Review"
- Link PR in comment

**If PR merged**:

- Status: "Done"
- Add completion timestamp

**If blocked**:

- Status: "Blocked"
- Document blocker

### 4. Update Ticket Status

Use Linear MCP to update:

```text
mcp__linear-mcp__update_issue
```

Update fields:

- Status (based on analysis)
- Progress percentage (if tracked)
- Labels (add "in-progress", "blocked", etc.)

### 5. Add Progress Comment

Create detailed comment:

```markdown
## Progress Update - {date}

### Work Completed

- {commit 1 summary}
- {commit 2 summary}
- {commit 3 summary}

### Files Modified

- {file list with line counts}

### Next Steps

1. {next task}
2. {next task}

### Blockers

- {blocker if any}

### Timeline

- Started: {date}
- Current: {percentage}% complete
- Est. completion: {date/unknown}
```

Add comment via:

```text
mcp__linear-mcp__create_comment
```

### 6. Link Related Items

If applicable:

- Link to PR (if created)
- Link to related tickets
- Link to documentation
- Reference design docs

### 7. Update Labels

Add appropriate labels:

- `in-progress` - Active work
- `blocked` - Waiting on something
- `needs-review` - Ready for review
- `needs-testing` - Ready for QA

### 8. Notify Stakeholders

If status change is significant:

- Tag relevant people in comment
- Update project board (if used)
- Mention in team standup notes

## Common Scenarios

### Scenario: Starting Work

```text
Status: Todo → In Progress
Comment: "Starting work on {ticket}. Plan: {approach}"
```

### Scenario: Mid-Work Update

```text
Status: In Progress (no change)
Comment: Progress update with work done, next steps
```

### Scenario: Work Complete

```text
Status: In Progress → Ready for Review
Comment: "Work complete. PR: {link}. Ready for review."
```

### Scenario: Blocked

```text
Status: In Progress → Blocked
Comment: "Blocked by {issue}. Need: {what}. Impact: {timeline}"
```

### Scenario: PR Created

```text
Status: Ready for Review → In Review
Comment: "PR #{number} created: {link}"
Link: Add PR link to ticket
```

## Success Criteria

- ✅ Ticket status matches actual work state
- ✅ Progress is documented
- ✅ Stakeholders informed
- ✅ Next steps clear
- ✅ Timeline updated

## Sync Frequency

Sync ticket:

- **Daily**: If active work
- **Before standup**: Team visibility
- **After major progress**: Keep stakeholders informed
- **When blocked**: Immediate notification
- **PR created/merged**: Status transitions

This keeps Linear as single source of truth for project status.
