# Dark Factory

Dark Factory is a self-contained module for running persistent, autonomous AI
agent teams on a remote headless machine using tmux. Each agent runs its own
Claude Code instance inside an isolated tmux pane, coordinated by a TDM (Technical
Delivery Manager) agent that orchestrates work through the SAFe workflow. The
entire factory is observable and controllable from Cursor IDE via SSH.

## Architecture

```
 +------------------------------ Remote Server ----------------------------+
 |                                                                         |
 |  tmux session: factory-{{TICKET_PREFIX}}-123                            |
 |  +-------------------------------------------------------------------+ |
 |  |                    TDM (lead)                                     | |
 |  |                    Claude Code                                    | |
 |  +----------------+------------------+---------------+---------------+ |
 |  | BE Developer   | FE Developer     | QAS           | RTE           | |
 |  | Claude Code    | Claude Code      | Claude Code   | Claude Code   | |
 |  +----------------+------------------+---------------+---------------+ |
 |                                                                         |
 |  ~/.dark-factory/                                                       |
 |    logs/<session>/     <-- per-agent output logs                        |
 |    worktrees/<session>/<-- per-agent git worktrees                      |
 +-------------------------------------------------------------------------+
         ^
         | SSH / mosh
         v
 +-- Developer Machine --+
 |  Cursor IDE            |
 |  Remote-SSH extension  |
 +------------------------+
```

## Prerequisites

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| tmux | 3.0+ | Session and pane management |
| Claude Code | 2.1+ | AI agent runtime |
| GitHub CLI (`gh`) | 2.0+ | PR creation and merge queue |
| git | 2.30+ | Worktree support |

## Quick Start

```bash
# 1. One-time setup (validates prerequisites and merge queue)
./dark-factory/scripts/factory-setup.sh

# 2. Launch a feature-sized agent team for a ticket
./dark-factory/scripts/factory-start.sh feature {{TICKET_PREFIX}}-123

# 3. Check on running sessions
./dark-factory/scripts/factory-status.sh
```

## Operator's Quick Reference

### Daily Workflow

```bash
# Morning: Start a team for today's ticket
./dark-factory/scripts/factory-start.sh feature {{TICKET_PREFIX}}-42

# Throughout the day: Check on your agents
./dark-factory/scripts/factory-status.sh

# Auto-refreshing dashboard (updates every 5 seconds)
watch -n 5 ./dark-factory/scripts/factory-status.sh

# Tail all agent logs live
tail -f ~/.dark-factory/logs/factory-{{TICKET_PREFIX}}-42/*.log

# Jump into a specific agent's pane to observe
./dark-factory/scripts/factory-attach.sh factory-{{TICKET_PREFIX}}-42 2

# End of day: Graceful shutdown
./dark-factory/scripts/factory-stop.sh factory-{{TICKET_PREFIX}}-42
```

### Status Dashboard Output

The status dashboard shows health for every agent in every session:

```
========================================
  Dark Factory Status Dashboard
========================================

Session: factory-{{TICKET_PREFIX}}-42
  Created: 2026-03-06 09:15:00
  Panes:
    [1] TDM (lead)           active        ← Claude running, recent output
    [2] BE Developer         active
    [3] FE Developer         idle (342s)   ← Claude running, no activity 5+ min
    [4] QAS                  dead          ← Claude process exited
    [5] RTE                  active

Aggregate Stats
  Sessions:  1
  Agents:    5 (3 active, 1 idle, 1 dead)
  Processes: 4 claude process(es), ~1200MB RSS
```

**Color codes**: green = active, yellow = idle, red = dead.

**If a pane shows "dead"**: Attach and check for errors:
```bash
./dark-factory/scripts/factory-attach.sh factory-{{TICKET_PREFIX}}-42 4
# In the pane, restart: claude --dangerously-skip-permissions
```

### Observing from Cursor IDE (Remote SSH)

1. Connect Cursor to your server via Remote-SSH
2. Open a terminal: `Ctrl+\``
3. Attach read-only: `tmux attach -t factory-{{TICKET_PREFIX}}-42 -r`
4. Navigate panes: `Alt+Arrow` or `Prefix+q` (show numbers)
5. Zoom one pane: `Prefix+z` (toggle)
6. See file changes: Open worktree in Cursor's file explorer

See [Cursor SSH Guide](docs/CURSOR-SSH-GUIDE.md) for full setup.

### All Commands at a Glance

| Command | What It Does |
|---------|-------------|
| `factory-setup.sh` | One-time setup (prerequisites + merge queue gate) |
| `factory-start.sh story\|feature\|epic [TICKET]` | Launch a team session |
| `factory-status.sh` | Color-coded health dashboard |
| `factory-attach.sh [SESSION] [PANE]` | List sessions or jump into a pane |
| `factory-stop.sh [SESSION]` | Graceful shutdown + log archive |
| `watch -n 5 factory-status.sh` | Auto-refreshing monitoring |
| `tail -f ~/.dark-factory/logs/SESSION/*.log` | Live agent output |
| `tmux attach -t SESSION -r` | Read-only tmux observation |

---

## Directory Structure

```
dark-factory/
+-- README.md                          # This file
+-- docs/
|   +-- DARK-FACTORY-GUIDE.md         # Comprehensive setup and usage guide
|   +-- CURSOR-SSH-GUIDE.md           # Cursor IDE remote observation guide
|   +-- MERGE-QUEUE-POLICY.md         # Merge queue enforcement policy
+-- scripts/
|   +-- factory-setup.sh              # One-time environment setup
|   +-- factory-start.sh              # Launch a factory session
|   +-- factory-status.sh             # Dashboard for running sessions
|   +-- factory-attach.sh             # Attach to a session or specific pane
|   +-- factory-stop.sh               # Graceful session shutdown
+-- templates/
    +-- env.template                   # Environment config template
    +-- tmux.conf                      # tmux configuration for agent sessions
    +-- team-layouts/
        +-- story-team.sh             # 2-3 agent layout (TDM + BE + QAS)
        +-- feature-team.sh           # 4-5 agent layout (TDM + BE + FE + QAS + RTE)
        +-- epic-team.sh              # 6-9 agent layout (full SAFe team)
    +-- github/
        +-- merge-queue-ruleset.json  # GitHub merge queue ruleset template
```

## Detailed Guides

- [Dark Factory Guide](docs/DARK-FACTORY-GUIDE.md) -- Full setup, usage, and troubleshooting
- [Cursor SSH Guide](docs/CURSOR-SSH-GUIDE.md) -- Observe your factory from Cursor IDE
- [Merge Queue Policy](docs/MERGE-QUEUE-POLICY.md) -- Why and how squash merge queue is enforced

## Relationship to Main Harness

This module is additive. It does not modify any files in `.claude/`, `.gemini/`,
or `docs/`. Your existing harness configuration is untouched. Dark Factory
scripts reference the same `CLAUDE.md`, `AGENTS.md`, and `patterns_library/`
that your interactive workflow uses -- agents in the factory follow the same
SAFe conventions as agents run locally.

## License

Copyright (c) {{YEAR}} {{AUTHOR_NAME}}, {{COMPANY_NAME}}. All rights reserved.

Licensed under the terms specified in the root [LICENSE](../LICENSE) file.
