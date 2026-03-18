# Codex CLI Dark Factory Guide

How to run parallel Codex CLI agent teams in a Dark Factory using codex-yolo
for auto-approval.

---

## Table of Contents

1. [Overview](#overview)
2. [What Is codex-yolo?](#what-is-codex-yolo)
3. [Prerequisites](#prerequisites)
4. [Installation](#installation)
5. [How It Works](#how-it-works)
6. [Mapping SAFe Roles to Codex Agents](#mapping-safe-roles-to-codex-agents)
7. [Launching a Codex Dark Factory](#launching-a-codex-dark-factory)
8. [Monitoring and Audit Logs](#monitoring-and-audit-logs)
9. [Safety Warnings](#safety-warnings)
10. [Comparison with Claude Code Dark Factory](#comparison-with-claude-code-dark-factory)
11. [Troubleshooting](#troubleshooting)
12. [FAQ](#faq)

---

## Overview

The Claude Code Dark Factory (documented in [DARK-FACTORY-GUIDE.md](DARK-FACTORY-GUIDE.md))
runs parallel Claude Code agents in tmux. This guide covers the equivalent setup
for **OpenAI Codex CLI** agents, using [codex-yolo](https://github.com/codex-yolo/codex-yolo)
as the auto-approval daemon.

The core idea is identical: each SAFe agent role gets its own tmux window (not
pane -- Codex CLI sessions are full-screen), Codex CLI runs with a role-specific
`.codex/agents/*.toml` config, and codex-yolo handles the approval prompts that
would otherwise block autonomous execution.

---

## What Is codex-yolo?

[codex-yolo](https://github.com/codex-yolo/codex-yolo) is a third-party tool
that enables fully autonomous Codex CLI execution by running an approver daemon
alongside each Codex session. It:

- Monitors tmux panes via `tmux capture-pane` for Codex approval prompts
- Automatically approves file writes and command execution
- Writes a timestamped audit log of every approval decision
- Runs entirely within tmux -- no modifications to Codex CLI itself

codex-yolo is the Codex CLI equivalent of Claude Code's
`--dangerously-skip-permissions` flag, but implemented externally as a daemon
rather than a built-in flag.

---

## Prerequisites

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| tmux | 3.0+ | Session and window management |
| Codex CLI | Latest | AI agent runtime (`npm install -g @openai/codex`) |
| codex-yolo | Latest | Auto-approval daemon |
| GitHub CLI (`gh`) | 2.0+ | PR creation and merge queue |
| git | 2.30+ | Worktree support |
| Node.js | 22+ | Required by Codex CLI |

**Environment variables required:**

| Variable | Purpose |
|----------|---------|
| `OPENAI_API_KEY` | OpenAI API key for Codex CLI |

---

## Installation

### Codex CLI

```bash
npm install -g @openai/codex
```

### codex-yolo

```bash
# One-liner install from GitHub
curl -fsSL https://raw.githubusercontent.com/codex-yolo/codex-yolo/main/install.sh | bash
```

Or clone and install manually:

```bash
git clone https://github.com/codex-yolo/codex-yolo.git
cd codex-yolo
chmod +x codex-yolo.sh
sudo cp codex-yolo.sh /usr/local/bin/codex-yolo
```

### Verify installation

```bash
codex --version        # Should print Codex CLI version
codex-yolo --help      # Should print usage information
tmux -V                # Should print tmux 3.x+
```

---

## How It Works

### Architecture

```
+------------------------------ Remote Server ----------------------------+
|                                                                         |
|  tmux session: codex-factory-{{TICKET_PREFIX}}-123                      |
|  +-------------------------------------------------------------------+ |
|  | Window 1: TDM (lead)          | Window 2: BE Developer            | |
|  |   codex --agent tdm           |   codex --agent be-developer      | |
|  |   codex-yolo (approver)       |   codex-yolo (approver)           | |
|  +-------------------------------+-----------------------------------+ |
|  | Window 3: QAS                 | Window 4: RTE                     | |
|  |   codex --agent qas           |   codex --agent qas               | |
|  |   codex-yolo (approver)       |   codex-yolo (approver)           | |
|  +-------------------------------+-----------------------------------+ |
|  | Window 5: Control                                                  | |
|  |   tail -f ~/.codex-yolo/audit.log                                 | |
|  +-------------------------------------------------------------------+ |
|                                                                         |
|  ~/.codex-yolo/                                                         |
|    audit.log          <-- timestamped approval decisions                |
|                                                                         |
|  .codex/agents/       <-- SAFe role configs (from SAW-27)               |
|    tdm.toml                                                             |
|    be-developer.toml                                                    |
|    qas.toml                                                             |
|    rte.toml                                                             |
|    ...                                                                  |
+-------------------------------------------------------------------------+
```

### Execution Flow

1. The tmux template script creates a session with one **window** per agent role
2. In each window, `codex-yolo` launches as a background daemon
3. `codex --agent <role>` starts with the role-specific TOML config from
   `.codex/agents/`
4. When Codex requests approval (file write, command execution), codex-yolo
   detects the prompt via `tmux capture-pane` and sends an approval keystroke
5. Every approval is logged to `~/.codex-yolo/audit.log` with timestamp, pane
   ID, and the action that was approved
6. A **control window** tails the audit log for real-time visibility

### Why Windows Instead of Panes

The Claude Code Dark Factory uses tmux **panes** (split views within one
window). Codex CLI sessions benefit from full-screen **windows** instead because:

- Codex CLI renders rich terminal UI that needs full width
- codex-yolo's `capture-pane` works more reliably on full-size panes
- You switch between agents with `Prefix+n` / `Prefix+p` (next/previous window)
- The status bar shows all agent windows at a glance

---

## Mapping SAFe Roles to Codex Agents

The `.codex/agents/` directory (created by SAW-27) contains TOML configs for
every SAFe role. Each config defines the agent's `name`, `model`,
`developer_instructions`, and sandbox policy.

| SAFe Role | TOML Config | Model | Sandbox Mode |
|-----------|-------------|-------|-------------|
| TDM (lead) | `tdm.toml` | gpt-5.4 | workspace-write |
| BE Developer | `be-developer.toml` | gpt-5.4 | workspace-write |
| FE Developer | `fe-developer.toml` | gpt-5.4 | workspace-write |
| QAS | `qas.toml` | gpt-5.4 | read-only |
| RTE | `rte.toml` | gpt-5.4 | workspace-write |
| BSA | `bsa.toml` | gpt-5.4 | workspace-write |
| System Architect | `system-architect.toml` | gpt-5.4 | workspace-write |
| Security Engineer | `security-engineer.toml` | gpt-5.4 | workspace-write |
| Data Engineer | `data-engineer.toml` | gpt-5.4 | workspace-write |

### Codex Multi-Agent Coordination

Codex CLI supports multi-agent coordination via subagents. When the TDM agent
needs to delegate work, it can spawn subagents that inherit the project context:

```bash
# TDM spawns a subagent for backend work
codex --agent be-developer "Implement the API endpoint per spec"
```

In the Dark Factory context, each window runs an independent Codex instance with
its own agent config. Cross-agent coordination happens through:

- Shared git branches and worktrees
- Linear ticket updates
- File-based handoff signals (e.g., `docs/agent-outputs/`)

---

## Launching a Codex Dark Factory

### Using the Template Script

```bash
# 1. Customize the template for your project
cp dark-factory/templates/codex-factory.sh /tmp/my-codex-factory.sh
# Edit: replace {{PLACEHOLDER}} tokens

# 2. Run the factory
bash /tmp/my-codex-factory.sh
```

### Manual Launch (Step by Step)

This example launches a story-level team: TDM + BE Developer + QAS.

```bash
# Create the tmux session
tmux new-session -d -s "codex-factory-{{TICKET_PREFIX}}-123"

# Window 1: TDM (team lead)
tmux rename-window -t "codex-factory-{{TICKET_PREFIX}}-123:1" "TDM"
tmux send-keys -t "codex-factory-{{TICKET_PREFIX}}-123:TDM" \
  "cd {{PROJECT_PATH}} && codex-yolo codex --agent tdm \
  'You are leading work on {{TICKET_PREFIX}}-123. Read the spec and coordinate.'" Enter

# Window 2: BE Developer
tmux new-window -t "codex-factory-{{TICKET_PREFIX}}-123" -n "BE-Dev"
tmux send-keys -t "codex-factory-{{TICKET_PREFIX}}-123:BE-Dev" \
  "cd {{PROJECT_PATH}} && codex-yolo codex --agent be-developer" Enter

# Window 3: QAS
tmux new-window -t "codex-factory-{{TICKET_PREFIX}}-123" -n "QAS"
tmux send-keys -t "codex-factory-{{TICKET_PREFIX}}-123:QAS" \
  "cd {{PROJECT_PATH}} && codex-yolo codex --agent qas" Enter

# Window 4: Control (audit log)
tmux new-window -t "codex-factory-{{TICKET_PREFIX}}-123" -n "Control"
tmux send-keys -t "codex-factory-{{TICKET_PREFIX}}-123:Control" \
  "tail -f ~/.codex-yolo/audit.log" Enter

# Attach
tmux attach -t "codex-factory-{{TICKET_PREFIX}}-123"
```

---

## Monitoring and Audit Logs

### Audit Log

codex-yolo writes every approval decision to `~/.codex-yolo/audit.log`:

```
2026-03-18T14:32:01Z [window:TDM] APPROVED: file_write -> specs/REN-123-feature-spec.md
2026-03-18T14:32:15Z [window:BE-Dev] APPROVED: command_exec -> npm test
2026-03-18T14:32:44Z [window:QAS] APPROVED: file_read -> src/api/routes.ts
```

The control window in the factory template tails this log automatically.

### Switching Between Agent Windows

```
Prefix + n          Next window
Prefix + p          Previous window
Prefix + <number>   Jump to window by number
Prefix + w          Interactive window list
```

### Checking Agent Status

```bash
# List all windows in the session
tmux list-windows -t "codex-factory-{{TICKET_PREFIX}}-123"

# Check if codex processes are running
pgrep -a codex

# Check resource usage
ps aux | grep codex | grep -v grep
```

### Using the Claude Code Status Dashboard

The existing `factory-status.sh` script works with Codex factory sessions too.
It detects running processes per pane/window:

```bash
./dark-factory/scripts/factory-status.sh
```

---

## Safety Warnings

**IMPORTANT: Read this section before using codex-yolo in any environment.**

codex-yolo auto-approves ALL actions that Codex CLI requests, including:

- Writing and overwriting any file in the workspace
- Executing arbitrary shell commands
- Making network requests
- Installing packages

### Mandatory Safety Requirements

1. **Isolated infrastructure only.** Run the Codex Dark Factory on a dedicated
   remote server, VM, or container -- never on your development laptop or
   corporate workstation.

2. **No production credentials.** The environment must not have access to
   production databases, APIs, or secrets. Use test/staging credentials only.

3. **Network isolation.** Restrict outbound network access to only what is
   needed (package registries, GitHub, OpenAI API). Block access to internal
   services.

4. **Merge queue enforcement.** The Dark Factory setup script (`factory-setup.sh`)
   requires merge queue enforcement before any factory session can start. This
   ensures agents cannot push directly to protected branches.

5. **Review all audit logs.** After every factory session, review
   `~/.codex-yolo/audit.log` to understand what actions were auto-approved.

6. **Ephemeral environments.** Prefer disposable VMs or containers that are
   destroyed after each factory session.

> **From the codex-yolo documentation:**
> "DO NOT USE ON CORPORATE HARDWARE. This tool auto-approves all actions.
> Use only on isolated, disposable infrastructure where the blast radius
> of any action is acceptable."

---

## Comparison with Claude Code Dark Factory

| Aspect | Claude Code Factory | Codex CLI Factory |
|--------|-------------------|------------------|
| **Agent runtime** | Claude Code CLI | Codex CLI |
| **Auto-approval** | `--dangerously-skip-permissions` (built-in) | codex-yolo (external daemon) |
| **Agent configs** | `.claude/agents/` (markdown) | `.codex/agents/` (TOML) |
| **Layout** | tmux panes (split view) | tmux windows (full-screen per agent) |
| **Multi-agent** | Agent Teams (experimental) | Subagents (built-in) |
| **Audit trail** | Per-agent log files via `pipe-pane` | `~/.codex-yolo/audit.log` |
| **Model** | Claude (Anthropic) | GPT/o-series (OpenAI) |
| **Sandbox** | File permissions in Claude Code | `sandbox_mode` in TOML config |
| **Coordination** | `TeamCreate`/`SendMessage` | Subagent spawning, shared files |
| **Setup script** | `factory-setup.sh` | Same (shared infrastructure) |
| **Merge guard** | Merge queue readiness gate | Same (shared infrastructure) |

### When to Use Which

- **Claude Code Factory**: Best when your team already uses Claude Code, needs
  Agent Teams cross-pane coordination, or prefers Anthropic models.
- **Codex CLI Factory**: Best when your team uses OpenAI models, wants TOML-based
  agent configs, or needs Codex subagent coordination.
- **Both**: The SAFe harness supports both. You can run Claude Code and Codex
  factories side by side on the same server, using different tmux sessions.

---

## Troubleshooting

### codex-yolo not approving prompts

- Verify codex-yolo is running: `pgrep -a codex-yolo`
- Check that the tmux session name matches what codex-yolo expects
- Ensure the terminal width is sufficient for codex-yolo's `capture-pane` parsing
- Review `~/.codex-yolo/audit.log` for error entries

### "Agent not found" when using `--agent`

- Verify `.codex/agents/<name>.toml` exists in the project root
- Check that the TOML file has a valid `name` field matching the `--agent` argument
- Run `codex --agent <name> --dry-run` to test config loading

### Codex CLI exits immediately

- Check `OPENAI_API_KEY` is set and valid
- Verify Node.js version is 22+ (`node --version`)
- Check Codex CLI version: `codex --version`

### tmux session conflicts

- Ensure session names are unique per ticket
- Stop existing sessions before restarting: `tmux kill-session -t <name>`

### Permission errors in sandbox

- QAS agent uses `sandbox_mode = "read-only"` -- it cannot write files by design
- If an agent needs write access, verify its TOML config has
  `sandbox_mode = "workspace-write"`

---

## FAQ

**Q: Can I mix Claude Code and Codex agents in the same factory session?**
A: Not in the same tmux session. Each session should use one agent runtime.
Run separate sessions for Claude Code and Codex agents.

**Q: Does codex-yolo work with all Codex CLI versions?**
A: codex-yolo parses terminal output, so it may need updates when Codex CLI
changes its prompt format. Always use the latest version of both tools.

**Q: How much memory does a Codex CLI factory session use?**
A: Each Codex CLI process uses approximately 100-300MB RSS. A story team
(3 agents + control window) typically uses 300-900MB total.

**Q: Can I use git worktrees with the Codex factory?**
A: Yes. The `codex-factory.sh` template supports worktrees. Set
`FACTORY_USE_WORKTREES=true` in your `~/.dark-factory/env` config and
uncomment the worktree section in the template.

**Q: Is codex-yolo officially supported by OpenAI?**
A: No. codex-yolo is a third-party community tool. Use it at your own risk
and only on isolated infrastructure.
