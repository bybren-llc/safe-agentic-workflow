---
type: runbook
title: "factory-stop.sh"
description: "Interrupts agent panes, kills the session, removes worktrees, and archives per-agent logs."
tags: [subsystems, operations]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "dark-factory/scripts/factory-stop.sh"
  - "dark-factory/templates/env.template"
  - "dark-factory/scripts/README.md"
verified_against: "fd0fc6a"
---

# factory-stop.sh

The clean shutdown path for one factory session: `factory-stop.sh [session-name]`. It tries to let
agents finish gracefully, then tears down the session, its worktrees, and moves the logs into an
archive. Called with no argument it lists `^factory-` sessions and prompts with `read -rp`, so it
dies when stdin is not a tty — pass the session name explicitly from any script or cron context.

## Overview

Shutdown is polite by design and never escalates. Every pane gets `tmux send-keys C-c`, then the
script polls once a second for up to 30 seconds, using `pgrep -P <pane_pid> -f claude` to decide
whether any agent is still alive. It never sends SIGKILL, so an agent that ignores SIGINT is
terminated only as a side effect of `tmux kill-session`. It dies up front if `tmux has-session`
fails for the named session.

## When To Use

- Ending work on a ticket, before starting a new session with the same name.
- Reclaiming a host whose agents have gone idle per [factory-status.sh](factory-status.md).
- Do NOT use it to detach and leave agents running — that is the tmux detach key, not this script.

## Procedure Map

- Resolve — validate the session name, or prompt for one interactively.
- Config — sources `$HOME/.dark-factory/env` if present for `FACTORY_LOG_DIR`,
  `FACTORY_USE_WORKTREES` and `FACTORY_WORKTREE_DIR`.
- Interrupt — collect pane ids, `C-c` each, poll up to 30 seconds for surviving `claude` children.
- Kill — `tmux kill-session`, which is what actually ends anything still running.
- Worktrees — only when `FACTORY_USE_WORKTREES` is true: `git worktree remove <dir> --force` per
  `agent-*` directory, then `rmdir` the session directory, every failure swallowed with `|| true`.
- Archive — `mv <FACTORY_LOG_DIR>/<session>` to `<FACTORY_LOG_DIR>/archive/<session>`.

Two rough edges to know. The `mv` is unguarded, so re-using a session name and stopping it twice
nests the second archive inside the first rather than replacing it. And DOC DRIFT: step 4 is
commented "Kill remaining panes" and its timeout branch prints "Force-killing remaining panes",
but the code there only re-sends `C-c` and sleeps; the real kill is the `tmux kill-session` in
step 5.

## Citations

- [scripts/README.md](../../../../dark-factory/scripts/README.md) — the operator command table.
