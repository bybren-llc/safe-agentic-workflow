---
type: guide
title: "Cursor SSH Guide"
description: "Setting up Cursor Remote-SSH to observe and intervene in a remote Dark Factory session."
tags: [subsystems, operations, onboarding]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "dark-factory/docs/CURSOR-SSH-GUIDE.md"
  - "dark-factory/scripts/factory-attach.sh"
  - "dark-factory/templates/tmux.conf"
verified_against: "fd0fc6a"
---

# Cursor SSH Guide

For the operator whose [Dark Factory](../dark-factory.md) runs on a machine that is not the one in
front of them: SSH configuration, the Cursor Remote-SSH extension, and the observation recipes
that let you watch nine agents without disturbing any of them.

## Getting connected

The SSH block enables `ForwardAgent` so remote agents can push with your credentials, and sets
`ServerAliveInterval` and `ServerAliveCountMax` so an idle tunnel does not die. Then install
Microsoft's Remote - SSH extension in Cursor, connect, and open the project folder.

The document uses `{{REMOTE_USER}}`, `{{REMOTE_HOST}}`, `{{SSH_KEY_PATH}}`, `{{PROJECT_PATH}}` and
`{{TICKET_PREFIX}}` placeholders. Their intended homes are the `FACTORY_SSH_KEY`,
`FACTORY_REMOTE_HOST` and `FACTORY_REMOTE_USER` keys in `env.template` — but no script in the
subsystem reads any of them, so today they are documentation, not config.

## Watching without touching

- [factory-status.sh](factory-status.md) for the dashboard; wrap it in `watch` to keep it live.
- `tmux attach -t <session> -r` for a genuinely read-only attach. Prefer this when you only want
  to observe: [factory-attach.sh](factory-attach.md) has no read-only mode.
- `tail -f` over `~/.dark-factory/logs/<session>/*.log` for history rather than the live screen.
- [factory-attach.sh](factory-attach.md) with a session and pane index when you do intend to act.

## Moving around a session

Four keys cover almost everything: `prefix q` to flash pane numbers, `prefix o` to cycle,
`prefix z` to zoom a pane full-screen, and `Alt+arrow` to move directionally. Only the last is
custom — `templates/tmux.conf` binds it with `-n`, no prefix; the rest are tmux defaults.

One trap: running tmux inside Cursor's integrated terminal nests two servers whose prefix keys
collide. The guide suggests a separate server, `tmux -L dark-factory`, rather than rebinding.

## Working out who did what

Use `git blame`. It attributes changes to the agent that made them because each agent commits on
its own `<session>-agent-N` branch inside its own worktree — a property created by
[factory-start.sh](factory-start.md), not by Cursor. Read that concept next.

## Citations

- [CURSOR-SSH-GUIDE.md](../../../../dark-factory/docs/CURSOR-SSH-GUIDE.md) — full setup procedure.
