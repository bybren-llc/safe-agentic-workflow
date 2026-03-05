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
