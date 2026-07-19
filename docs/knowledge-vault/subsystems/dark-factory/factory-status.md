---
type: runbook
title: "factory-status.sh"
description: "Color-coded dashboard classifying every factory pane as active, idle, or dead."
tags: [subsystems, operations]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "dark-factory/scripts/factory-status.sh"
  - "dark-factory/README.md"
  - "dark-factory/scripts/README.md"
verified_against: "fd0fc6a"
---

# factory-status.sh

The one read-only script in the set: it takes no arguments, never touches tmux state, and always
exits 0. Run it to answer "is anything still working?" without attaching to a session and risking
a stray keystroke into an agent's prompt. The README suggests wrapping it in `watch -n 5`.

## Overview

For every tmux session matching `^factory-` it prints a creation time and then one line per pane,
colour-coded green, yellow or red. With no matching session it prints "No dark factory sessions
running." and stops. Creation time comes from `date -d @<epoch>`, falling back to `date -r <epoch>`
and then the literal "unknown" — the two-step fallback exists because those flags are GNU and BSD
spellings of the same idea.

## When To Use

- Routine check on a long-running epic session, locally or over the Cursor SSH connection.
- Deciding whether an agent has genuinely stalled before interrupting it.
- Do NOT use it to interact with a pane; that is [factory-attach.sh](factory-attach.md).

## Procedure Map

- Enumerate — `tmux list-sessions` filtered on `^factory-`.
- Read — per pane, `pane_index`, `pane_title`, `pane_pid`, `pane_current_command`,
  `pane_last_activity`.
- Classify — no `claude` child is dead (red); a `claude` child with more than 300 seconds since
  last activity is idle (yellow); anything else is active (green). The 300-second threshold is
  hardcoded.
- Aggregate — a process count from `pgrep -f claude` and a total RSS from `ps -C claude -o rss=`
  summed with awk.

Three caveats matter when reading the output. Liveness is `pgrep -P <pane_pid> -f claude`, which
only sees `claude` as a *direct* child of the pane shell, so an agent launched through a wrapper
reads as dead. The aggregate `pgrep -f claude` matches any command line containing the substring,
including the script's own greps, so the count runs high. And `ps -C` is a procps flag that BSD
and macOS `ps` do not accept, so on macOS the memory total is empty and the dashboard reports
roughly 0MB while simultaneously claiming live processes.

## Citations

- [Dark Factory README](../../../../dark-factory/README.md) — the `watch -n 5` monitoring recipe.
- [scripts/README.md](../../../../dark-factory/scripts/README.md) — the operator command table.
