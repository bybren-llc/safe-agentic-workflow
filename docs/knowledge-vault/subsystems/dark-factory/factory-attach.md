---
type: runbook
title: "factory-attach.sh"
description: "Lists running factory sessions and panes, or attaches to a session and optional pane."
tags: [subsystems, operations]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "dark-factory/scripts/factory-attach.sh"
  - "dark-factory/docs/CURSOR-SSH-GUIDE.md"
  - "dark-factory/scripts/README.md"
verified_against: "fd0fc6a"
---

# factory-attach.sh

The way in. One small script with three behaviours selected purely by argument count: list, attach
to a session, or attach with a specific agent pane already selected. It is the script an operator
runs most often, and the one place where a stray keystroke reaches a live agent.

## Overview

With no arguments it lists every tmux session matching `^factory-` and, for each, runs
`tmux list-panes` to show `[index] title (current_command)` — enough to pick an agent by role. It
exits 0 even when nothing is running. With one argument it checks `tmux has-session`, dying if
that fails, then `exec tmux attach -t <session>`. With two it first runs
`tmux select-pane -t <session>:1.<pane-index>`, dies if that fails, and then attaches.

## When To Use

- Inspecting or steering one agent whose pane index you got from the zero-argument listing.
- Landing directly on the TDM lead pane (index 1) to give the team a new instruction.
- Do NOT use it when you only want to observe: it attaches read-write. The Cursor SSH guide tells
  operators to run `tmux attach -t <session> -r` directly for a read-only view, because this
  script offers no such mode.

## Procedure Map

- List — `factory-attach.sh` with no arguments, to discover sessions and pane numbering.
- Attach — `factory-attach.sh <session>`, landing wherever tmux last had focus.
- Target — `factory-attach.sh <session> <pane-index>` to select a specific agent first.
- Leave — detach with the tmux detach key; the session and its agents keep running.

Both attach paths use `exec`, replacing the shell, so nothing in the script runs afterwards. The
window index `1` is hardcoded into the `select-pane` target, which resolves only because
`dark-factory/templates/tmux.conf` sets both `base-index 1` and `pane-base-index 1`; a session
started without that config would not match. See [factory-start.sh](factory-start.md) for where
the config is applied and [tmux Topology](tmux-topology.md) for the indexing convention itself.

## Citations

- [CURSOR-SSH-GUIDE.md](../../../../dark-factory/docs/CURSOR-SSH-GUIDE.md) — read-only attach and
  remote observation recipes.
- [scripts/README.md](../../../../dark-factory/scripts/README.md) — the operator command table.
