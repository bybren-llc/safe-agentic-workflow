# Dark Factory Guide

Comprehensive guide for setting up and operating a Dark Factory -- persistent,
autonomous AI agent teams running 24/7 on a remote headless machine via tmux.

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Starting a Factory Session](#starting-a-factory-session)
5. [Monitoring Agents](#monitoring-agents)
6. [Stopping a Session](#stopping-a-session)
7. [Git Worktrees](#git-worktrees)
8. [Log Management](#log-management)
9. [Session Durability and Recovery](#session-durability-and-recovery)
10. [Security Considerations](#security-considerations)
11. [Integrating with SAFe Workflow](#integrating-with-safe-workflow)
12. [Companion Tools](#companion-tools)
13. [Troubleshooting](#troubleshooting)
14. [FAQ](#faq)

---

## Overview

The Dark Factory runs a team of Claude Code agents inside a tmux session on a
remote server. Each agent occupies its own pane, with the TDM (Technical
Delivery Manager) acting as team lead. Agents follow the same SAFe workflow
defined in `CLAUDE.md` and `AGENTS.md` -- they create PRs, enqueue them via
merge queue, and never merge directly.

**Key properties:**
- Self-contained in `dark-factory/` -- does not modify the main harness
- Merge queue + squash enforced from day 1 (readiness gate blocks setup otherwise)
- Observable from Cursor IDE via SSH
- Per-agent git worktrees for isolation (optional)
- Per-agent log files for post-session review

---

## Prerequisites

| Tool | Minimum Version | Install |
|------|----------------|---------|
| tmux | 3.0+ | `apt install tmux` / `brew install tmux` |
| Claude Code | 2.1+ | `npm install -g @anthropic-ai/claude-code` |
| GitHub CLI (`gh`) | 2.0+ | `apt install gh` / `brew install gh` |
| git | 2.30+ | System package manager |

The `factory-setup.sh` script validates all prerequisites automatically.

---

## Installation

```bash
# Clone the repo on your remote server
git clone git@github.com:{{GITHUB_ORG}}/{{PROJECT_REPO}}.git
cd {{PROJECT_REPO}}

# Run one-time setup
./dark-factory/scripts/factory-setup.sh
```

Setup performs:
1. Checks all prerequisites are installed
2. Creates `~/.dark-factory/` config directory with `logs/` and `worktrees/`
3. Copies `env.template` to `~/.dark-factory/env`
4. **Readiness gate**: verifies merge queue enforcement on `{{MAIN_BRANCH}}`
5. Checks `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` env var

**Edit your config** after setup:

```bash
$EDITOR ~/.dark-factory/env
```

Replace all `{{...}}` placeholders with your actual values.

---

## Starting a Factory Session

```bash
# Story-level work (2-3 agents: TDM + BE + QAS)
./dark-factory/scripts/factory-start.sh story {{TICKET_PREFIX}}-456

# Feature-level work (4-5 agents: TDM + BE + FE + QAS + RTE)
./dark-factory/scripts/factory-start.sh feature {{TICKET_PREFIX}}-123

# Epic-level work (6-8 agents: full SAFe team)
./dark-factory/scripts/factory-start.sh epic {{TICKET_PREFIX}}-789
```

The session name follows the pattern `factory-{{TICKET_PREFIX}}-XXX` (or
`factory-YYYYMMDD-HHMMSS` if no ticket is provided).

### Team Layouts

**Story Team (3 panes):**
```
+------------------------------+
|         TDM (lead)           |
+--------------+---------------+
|  BE Developer|     QAS       |
+--------------+---------------+
```

**Feature Team (5 panes):**
```
+------------------------------+
|         TDM (lead)           |
+--------------+---------------+
|  BE Developer|  FE Developer |
+--------------+---------------+
|     QAS      |     RTE       |
+--------------+---------------+
```

**Epic Team (9 panes):**
```
+------------------------------+
|         TDM (lead)           |
+--------+--------+------------+
|  BSA   |  ARCH  |  Security  |
+--------+--------+------------+
|   BE   |   FE   |   Data     |
+--------+--------+------------+
|      QAS        |    RTE     |
+-----------------+------------+
```

---

## Monitoring Agents

### Status Dashboard

```bash
./dark-factory/scripts/factory-status.sh
```

Shows all factory sessions with per-pane status:
- **Green** = active (Claude process running, recent activity)
- **Yellow** = idle (Claude running but no activity for 5+ minutes)
- **Red** = dead (no Claude process detected)

Also shows aggregate resource usage (process count, memory).

### Attach to a Session

```bash
# List all sessions and their panes
./dark-factory/scripts/factory-attach.sh

# Attach to a specific session
./dark-factory/scripts/factory-attach.sh factory-{{TICKET_PREFIX}}-123

# Attach with a specific pane selected
./dark-factory/scripts/factory-attach.sh factory-{{TICKET_PREFIX}}-123 2
```

### From Another Terminal

```bash
# Standard tmux attach
tmux attach -t factory-{{TICKET_PREFIX}}-123

# Read-only mode (observe without interfering)
tmux attach -t factory-{{TICKET_PREFIX}}-123 -r
```

### Quick Navigation (Inside tmux)

| Key | Action |
|-----|--------|
| Alt+Arrow | Switch panes (no prefix needed) |
| Prefix+L | Show live log tail popup |
| Prefix+z | Zoom current pane (toggle) |
| Prefix+q | Show pane numbers |

---

## Stopping a Session

```bash
# Interactive -- lists sessions and prompts
./dark-factory/scripts/factory-stop.sh

# Direct -- stop specific session
./dark-factory/scripts/factory-stop.sh factory-{{TICKET_PREFIX}}-123
```

Stop performs:
1. Sends Ctrl-C to all panes
2. Waits up to 30 seconds for graceful shutdown
3. Kills the tmux session
4. Cleans up git worktrees (if enabled)
5. Archives logs to `~/.dark-factory/logs/archive/`

---

## Git Worktrees

When `FACTORY_USE_WORKTREES=true` in your config, each agent pane gets its own
git worktree. This prevents agents from conflicting when they edit files
simultaneously.

Worktrees are created at:
```
~/.dark-factory/worktrees/<session-name>/agent-0/
~/.dark-factory/worktrees/<session-name>/agent-1/
...
```

Each worktree gets its own branch: `<session-name>-agent-<N>`.

**Cleanup**: worktrees are automatically removed when `factory-stop.sh` runs.

---

## Log Management

All agent output is captured via `tmux pipe-pane`:

```
~/.dark-factory/logs/<session-name>/
  tdm-lead.log
  be-developer.log
  qas.log
  ...
```

On session stop, logs move to `~/.dark-factory/logs/archive/`.

**Tail live logs:**
```bash
tail -f ~/.dark-factory/logs/factory-{{TICKET_PREFIX}}-123/*.log
```

---

## Session Durability and Recovery

### Limitations

Claude Code Agent Teams does not currently support session resumption. If the
lead agent's session dies, team coordination state is lost. However:

- **Work persists** in git branches and worktrees
- **Commits persist** -- agents commit as they go
- **PRs persist** -- any created PRs remain in GitHub

### Recovery

If a session crashes or an agent pane dies:

```bash
# Check which panes are still alive
./dark-factory/scripts/factory-status.sh

# For a single dead pane, re-attach and manually restart
./dark-factory/scripts/factory-attach.sh factory-{{TICKET_PREFIX}}-123 3
# Then in the pane: claude --dangerously-skip-permissions

# For a full session restart
./dark-factory/scripts/factory-stop.sh factory-{{TICKET_PREFIX}}-123
./dark-factory/scripts/factory-start.sh feature {{TICKET_PREFIX}}-123
```

### Recommendations for 24/7 Operation

- Use `mosh` instead of SSH for persistent connections
- Run `factory-status.sh` periodically (cron or watch) to detect dead agents
- Keep session durations reasonable -- restart daily or per-ticket
- The TDM agent will re-spawn lost teammates if using Agent Teams

---

## Security Considerations

### `--dangerously-skip-permissions`

When `FACTORY_AUTO_PERMISSIONS=true`, agents run with
`--dangerously-skip-permissions`. This means agents can execute any shell
command, write any file, and make network requests without confirmation.

**Mitigations:**
- Run on an isolated machine (not your laptop)
- Use dedicated SSH keys with limited scope
- Network-level isolation (firewall rules)
- Per-agent git worktrees prevent cross-contamination
- Merge queue prevents direct pushes to `{{MAIN_BRANCH}}`
- All PRs still require CI checks and review stages

### Environment Variables

The `~/.dark-factory/env` file may contain sensitive values (SSH keys, API
tokens). Ensure:
- File permissions: `chmod 600 ~/.dark-factory/env`
- Not committed to git (it lives in `$HOME`, not the repo)

---

## Integrating with SAFe Workflow

Dark Factory agents follow the same workflow as interactive sessions:

1. **TDM** reads the Linear ticket and coordinates work
2. **Implementers** (BE, FE, Data) write code following `CONTRIBUTING.md`
3. **QAS** validates against acceptance criteria
4. **RTE** creates PRs with `gh pr create`
5. **Merge** via `gh pr merge --auto --squash` (queue handles the rest)

### Commit Format

Agents use the standard commit format:
```
type(scope): description [{{TICKET_PREFIX}}-XXX]
```

### PR Flow

```
Agent creates PR --> CI runs --> QAS validates --> HITL reviews --> Merge queue
```

No agent ever runs `git push` to `{{MAIN_BRANCH}}` or `gh pr merge` without
`--auto --squash`. The merge queue is the single point of entry to trunk.

---

## Companion Tools

These community tools complement the Dark Factory:

| Tool | Purpose | Link |
|------|---------|------|
| **agent-deck** | TUI dashboard with MCP connection pooling | github.com/anthropics/agent-deck |
| **claude-tmux** | tmux popup integration + session management | github.com/anthropics/claude-tmux |
| **ntm** | Named Tmux Manager for complex session layouts | github.com/anthropics/ntm |
| **mosh** | Mobile shell for persistent SSH connections | mosh.org |
| **tmux-resurrect** | Save/restore tmux sessions across restarts | github.com/tmux-plugins/tmux-resurrect |

---

## Troubleshooting

### "READINESS GATE FAILED" during setup

Your repository does not have merge queue enforcement configured. See
[MERGE-QUEUE-POLICY.md](MERGE-QUEUE-POLICY.md) for setup instructions.

### Agents not starting in panes

Check that `FACTORY_PROJECT_DIR` in `~/.dark-factory/env` points to a valid
directory with a `CLAUDE.md` file.

### Panes show "dead" in status

The Claude process exited. Attach to the pane and check for error output:
```bash
./dark-factory/scripts/factory-attach.sh <session> <pane-index>
```

### tmux "no server running" error

Start a tmux server first: `tmux start-server`

### Permission denied on scripts

```bash
chmod +x dark-factory/scripts/*.sh
chmod +x dark-factory/templates/team-layouts/*.sh
```

---

## FAQ

**Q: Does this modify my existing harness?**
A: No. Dark Factory is self-contained in `dark-factory/`. It reads `CLAUDE.md`
and `AGENTS.md` but does not modify them.

**Q: Can I run multiple factory sessions simultaneously?**
A: Yes. Each session has a unique name and its own worktrees/logs.

**Q: What happens if the remote machine reboots?**
A: tmux sessions are lost. Use `tmux-resurrect` for session persistence, and
restart with `factory-start.sh`. Work is safe in git branches.

**Q: Can I use this without Agent Teams experimental flag?**
A: Yes. Each pane runs an independent Claude instance. Agent Teams adds
cross-pane coordination via `TeamCreate`/`SendMessage` but is not required.

**Q: How much memory does a factory session use?**
A: Each Claude Code process uses approximately 200-500MB RSS. A feature team
(5 agents) typically uses 1-2.5GB total.
