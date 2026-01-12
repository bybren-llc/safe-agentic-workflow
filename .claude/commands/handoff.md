---
description: End-of-session protocol - sync Beads and create SAFe-aligned handoff
---

# Session End Protocol

This is the "landing the plane" protocol for WTFB development sessions. Run this before ending any session.

## Step 1: File Outstanding Work

Review what was done this session. For any incomplete work or discoveries:

```bash
bd create "ConTS-[description]" -t [type] -p [priority] -l [labels] --json
```

**Issue Types (SAFe Aligned)**:
- `story` - User stories for sprint work
- `enabler` - Technical enabler tasks
- `bug` - Defects found during development
- `spike` - Investigation/research items
- `epic` - Large features spanning multiple sprints

## Step 2: Update Issue Status

For each issue touched this session:
```bash
bd update [issue-id] --status [status] --notes "[what was done]"
```

**Valid Statuses**:
- `backlog` - In sprint backlog, not started
- `in_progress` - Active development
- `blocked` - Waiting on dependency or decision
- `review` - Ready for code review
- `done` - Completed and verified

Close completed issues:
```bash
bd close [issue-id] --reason "[completion summary]"
```

## Step 3: Run Quality Gates (if code changed)

```bash
npm test
npm run lint
npm run typecheck
```

If anything fails, create P0 issue:
```bash
bd create "ConTS-Build broken: [description]" -t bug -p 0 -l broken-build,blocker --json
```

## Step 4: Sync Beads

```bash
bd sync
```

Verify clean sync:
```bash
git status
bd list --status in_progress --json
```

## Step 5: Create Handoff

Run `/compact` to create the handoff document.

## Step 6: Commit and Push

```bash
git add .
git commit -m "[type]: [summary of session work]

ConTS-XXXX"
git push
```

## Step 7: Provide Next Session Prompt

[Same as /compact output]

## SAFe Alignment Notes

- Reference sprint/PI in handoff if applicable (e.g., "PI-25.1 Sprint 3")
- Tag blockers that need Scrum Master escalation
- Note any capacity changes for sprint planning
