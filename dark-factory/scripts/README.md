# Dark Factory Scripts

Shell scripts for managing Dark Factory tmux sessions. All scripts use
`#!/usr/bin/env bash` with `set -euo pipefail` and standard `{{PLACEHOLDER}}`
tokens.

## Scripts

| Script | Usage | Purpose |
|--------|-------|---------|
| `factory-setup.sh` | `./factory-setup.sh` | One-time setup. Checks prerequisites (tmux, claude, git, gh), creates `~/.dark-factory/` config directory, copies env template, and **enforces the merge queue readiness gate** (fails if merge queue is not configured). |
| `factory-start.sh` | `./factory-start.sh <story\|feature\|epic> [ticket-id]` | Launch a tmux session with an agent team. Creates named session, applies team layout, sets up per-pane logging, and optionally creates git worktrees. |
| `factory-stop.sh` | `./factory-stop.sh [session-name]` | Graceful shutdown. Sends Ctrl-C to all panes, waits 30s for exit, kills session, cleans worktrees, archives logs. |
| `factory-status.sh` | `./factory-status.sh` | Status dashboard. Lists all factory sessions with per-pane health (green/yellow/red), aggregate stats, and resource usage. |
| `factory-attach.sh` | `./factory-attach.sh [session] [pane]` | Quick attach. No args lists sessions; one arg attaches to session; two args selects specific pane. |

## Typical Workflow

```bash
# 1. First time only
./factory-setup.sh
# Edit ~/.dark-factory/env with your project settings

# 2. Start a session
./factory-start.sh feature WOR-123

# 3. Monitor
./factory-status.sh

# 4. Observe specific agent
./factory-attach.sh factory-WOR-123 2

# 5. When done
./factory-stop.sh factory-WOR-123
```

## Configuration

Scripts read `~/.dark-factory/env` for runtime configuration. Key variables:

| Variable | Description |
|----------|-------------|
| `FACTORY_PROJECT_DIR` | Absolute path to project root |
| `FACTORY_USE_WORKTREES` | `true` to create per-agent git worktrees |
| `FACTORY_AUTO_PERMISSIONS` | `true` to use `--dangerously-skip-permissions` |
| `FACTORY_AUTO_ATTACH` | `true` to auto-attach after start |
| `FACTORY_LOG_DIR` | Log output directory (default: `~/.dark-factory/logs`) |

See [env.template](../templates/env.template) for all variables.
