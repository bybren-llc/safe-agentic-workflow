---
type: environment
title: "Dark Factory Runtime Topology"
description: "The tmux, filesystem, and environment-key topology a running Dark Factory session occupies."
tags: [subsystems, operations, orchestration]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "dark-factory/templates/tmux.conf"
  - "dark-factory/templates/env.template"
  - "dark-factory/templates/codex-factory.sh"
  - "dark-factory/scripts/factory-start.sh"
  - "dark-factory/docs/CURSOR-SSH-GUIDE.md"
verified_against: "fd0fc6a"
---

# Dark Factory Runtime Topology

Where a running factory lives: one tmux session of numbered panes, a `$HOME/.dark-factory` tree, and
a set of `FACTORY_*` keys. Often misread as a deployment target; nothing here is provisioned.

## Overview

The session is the environment: panes are agent slots, the tree is state, the env file is config. It
holds no application data and no durability — a reboot ends it. Its job is to hold several
[Dark Factory](../dark-factory.md) agents side by side long enough to produce PRs.

## Topology

| Location | Contents | Notes |
| --- | --- | --- |
| `$HOME/.dark-factory/env` | config, copied from `templates/env.template` | not versioned |
| `.dark-factory/logs/<session>/` | one `<agent>.log` per pane | archived to `logs/archive/` on stop |
| `.dark-factory/worktrees/<session>/agent-N` | git worktrees | one per pane, branch per agent |
| `$HOME/.codex-yolo/audit.log` | codex-yolo approval audit trail | Codex path only, outside the tree |

`tmux.conf` sets `default-terminal screen-256color`, `history-limit 50000`, `mouse on`,
`status-interval 5`, `pane-border-status top` with `#{pane_title}`, `allow-rename off`,
`automatic-rename off`, `monitor-activity on`, and `base-index 1` plus `pane-base-index 1` — that pair
load-bearing, since every script addresses panes as `<session>:1.<pane>`. Alt+arrow binds with `-n`;
`prefix + L` tails the logs in a `display-popup`. The Codex variant gives each agent its own tmux
*window* plus a `Control` window — see [Codex Guide](codex-guide.md).

## Access & Deployment

- Remote access is SSH or Cursor Remote-SSH per [Cursor SSH Guide](cursor-ssh-guide.md); read-only
  observation is `tmux attach -r`, and [factory-attach](factory-attach.md) wraps the read-write path.
- `env.template` declares key names only. Thirteen carry a `FACTORY_` prefix — PROJECT_DIR,
  MAIN_BRANCH, TICKET_PREFIX, SSH_KEY, REMOTE_HOST, REMOTE_USER, LOG_DIR, WORKTREE_DIR, USE_WORKTREES,
  AUTO_PERMISSIONS, AUTO_ATTACH, MERGE_METHOD, REQUIRE_QUEUE — plus `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`.
- `factory-start.sh` reads PROJECT_DIR, LOG_DIR, USE_WORKTREES, WORKTREE_DIR and AUTO_ATTACH; the
  layouts read AUTO_PERMISSIONS; `factory-setup.sh` reads MAIN_BRANCH. SSH_KEY, REMOTE_HOST,
  REMOTE_USER and TICKET_PREFIX are read by nothing — documentation, not config.

## Citations

- [CURSOR-SSH-GUIDE.md](../../../../dark-factory/docs/CURSOR-SSH-GUIDE.md) — remote access setup.
