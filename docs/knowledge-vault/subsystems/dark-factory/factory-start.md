---
type: runbook
title: "factory-start.sh"
description: "Creates a tmux session, optional per-agent worktrees, applies a team layout, and pipes pane logs."
tags: [subsystems, operations, orchestration, agents]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "dark-factory/scripts/factory-start.sh"
  - "dark-factory/templates/tmux.conf"
  - "dark-factory/templates/env.template"
  - "dark-factory/scripts/README.md"
verified_against: "fd0fc6a"
---

# factory-start.sh

The script that turns a configured host into a running agent team. Usage is
`factory-start.sh <story|feature|epic> [ticket-id]`; any other team size dies immediately. It is
the only script that creates *session* state — sessions, worktrees and pane logs. The
`$HOME/.dark-factory` tree and its `env` come from [factory-setup.sh](factory-setup.md) first.

## Overview

Order matters: worktrees are created before the layout, so each agent's shell can `cd` into its
own checkout. Pane count is hardcoded per team size (story 3, feature 5, epic 9), and for each
index it runs `git worktree add -b <session>-agent-<i>` off the current branch, demoting any
failure to an INFO "may already exist". The session is `factory-<ticket-id>`, or
`factory-$(date +%Y%m%d-%H%M%S)` with no ticket; it dies if `tmux has-session` already matches.

## When To Use

- Starting agents on a ticket, after [factory-setup.sh](factory-setup.md) has passed its gate.
- Resuming after a clean [factory-stop.sh](factory-stop.md); a stale session name will refuse.
- Do NOT use it to reattach to an existing session — that is [factory-attach.sh](factory-attach.md).

## Procedure Map

- Config — dies if `$HOME/.dark-factory/env` is missing; reads `FACTORY_LOG_DIR`,
  `FACTORY_USE_WORKTREES`, `FACTORY_WORKTREE_DIR`, `FACTORY_AUTO_ATTACH`, `FACTORY_PROJECT_DIR`.
- Worktrees — one branch and directory per pane under `<FACTORY_WORKTREE_DIR>/<session>/agent-N`.
- Session — detached, with `tmux -f dark-factory/templates/tmux.conf` when present and plain
  `tmux new-session -d` otherwise. Window index 1 is targeted throughout, which resolves only
  because that config sets `base-index 1`; under default tmux settings it would not.
- Layout — sources `templates/team-layouts/<team-size>-team.sh`, which creates the panes and sends
  the `claude` lines: [Feature Team Layout](feature-team-layout.md), [Epic](epic-team-layout.md).
- Logging — per pane, `tmux pipe-pane 'cat >> <FACTORY_LOG_DIR>/<session>/<title>.log'`; the title
  is lowercased, spaces to dashes, then `tr -cd 'a-z0-9_-'`, so "TDM (lead)" becomes `tdm-lead`.
- Attach — ends with `exec tmux attach` when `FACTORY_AUTO_ATTACH` is true.

One subtlety: the script `export`s the associative array `FACTORY_PANE_WORKDIRS`, which bash cannot
do; it works only because the layout is sourced into the same shell rather than executed. The
companion `agent_workdir <pane_index>` is properly `export -f`'d, and is what the layouts call.

## Citations

- [scripts/README.md](../../../../dark-factory/scripts/README.md) — the operator command table.
