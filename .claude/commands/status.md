---
description: Show current RPI workflow status with Beads integration and SAFe alignment
---

# Status Check

## SAFe Overview

Display current PI and Sprint context:
- **Current PI**: PI-25.1 (check project tracking)
- **Current Sprint**: Sprint N of 5
- **Sprint Goal**: [from sprint planning]
- **Days Remaining**: [calculate from sprint end date]

## Beads Overview

```bash
bd stats --json
```

## Ready Work (Unblocked)

```bash
bd ready --limit 10 --json
```

## In Progress

```bash
bd list --status in_progress --json
```

## Blockers

```bash
bd list --label blocker --status open --json
```

For each blocker, identify:
- What is blocking it
- Who can unblock it
- Escalation needed? (Scrum Master, PO, etc.)

## Recent Research (Spikes)

```bash
bd list --label spike,research --limit 5 --json
```

## Active Plans (Epics)

```bash
bd list -t epic --status open --json
```

For each open epic, show dependency tree:
```bash
bd dep tree [epic-id]
```

## Sprint Burndown Status

If available, show:
- Story points completed
- Story points remaining
- Sprint velocity trend

## Recent Handoffs

List files in `thoughts/shared/handoffs/` from last 7 days.

## Context Window Status

Estimate current context usage and recommend:
- Continue working (if < 30%)
- Consider compaction soon (if 30-40%)
- Compact now (if > 40%)

## SAFe Ceremony Reminders

Check if any ceremonies are upcoming:
- [ ] Daily Stand-up
- [ ] Sprint Review (end of sprint)
- [ ] Sprint Retrospective (end of sprint)
- [ ] PI Planning (quarterly)
- [ ] Backlog Refinement (mid-sprint)

## Quick Actions

Based on status, recommend:
1. **If blocked**: Escalate or context-switch to ready work
2. **If nearing sprint end**: Focus on completing in-flight stories
3. **If capacity available**: Pull from prioritized backlog
