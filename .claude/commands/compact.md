---
description: Compact current session into a SAFe-aligned handoff document
---

# Session Compaction Protocol

## Purpose

Create a handoff document that captures the essential context for the next session, keeping the persistent knowledge in Beads while creating a lean startup document aligned with SAFe practices.

## Process

### Step 1: Summarize Session Work

What was accomplished this session:
- ConTS- issues worked on (from Beads)
- Files modified
- Key decisions made
- Problems encountered
- Sprint/PI progress updates

### Step 2: Update Beads

For each issue worked on:
```bash
bd update [issue-id] --notes "[Session summary: what was done, what's next]"
```

Ensure all discovered issues are filed with ConTS- prefix.

### Step 3: Create Handoff Document

Create file: `thoughts/shared/handoffs/YYYY-MM-DD-HHmm-handoff.md`

```markdown
---
date: [ISO timestamp]
session_duration: [approximate]
context_usage: [estimated percentage]
sprint: [current sprint, e.g., "PI-25.1 Sprint 3"]
---

# Session Handoff

## SAFe Context

**PI**: [e.g., PI-25.1 (Jan-Mar 2025)]
**Sprint**: [e.g., Sprint 3 of 5]
**Sprint Goal**: [current sprint goal]

## Work Completed

| ConTS ID | Type | Status | Summary |
|----------|------|--------|---------|
| ConTS-xxxx | story | done | Completed auth feature |
| ConTS-yyyy | enabler | in_progress | Started RLS migration, blocked on schema |

## Key Files Modified

- `/src/auth/handler.ts` - Added token refresh logic
- `/src/api/routes.ts` - New OAuth endpoints

## Current State

[What's the codebase state right now?]

## Immediate Next Steps

1. `bd ready` shows: [list of ready issues]
2. Continue with: [specific recommendation]

## Context to Preserve

[Any critical context that is not captured in Beads or code comments]

## Blockers / Waiting On

- [Human decision needed on X]
- [Waiting for API access to Y]
- [Dependency on ConTS-ZZZZ]

## Sprint Impact

- Story Points Completed: [X]
- Remaining in Sprint: [Y]
- Any velocity adjustments needed: [yes/no]
```

### Step 4: Sync Beads

```bash
bd sync
```

### Step 5: Provide Next Session Prompt

Output a prompt that can be used to start the next session:

```markdown
## Next Session Startup

Run this at the start of your next session:

1. `bd sync` - Get latest from git
2. `bd ready --json` - See what is unblocked
3. Read: `thoughts/shared/handoffs/YYYY-MM-DD-HHmm-handoff.md`
4. Continue with: ConTS-[specific issue ID or task]

**Sprint Context**: PI-XX.X Sprint Y - [Sprint Goal]
```
