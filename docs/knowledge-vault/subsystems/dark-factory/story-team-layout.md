---
type: runbook
title: "Story Team Layout"
description: "Three-pane tmux layout starting TDM lead, BE Developer, and QAS agents."
tags: [subsystems, orchestration, agents]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "dark-factory/templates/team-layouts/story-team.sh"
  - "dark-factory/scripts/factory-start.sh"
verified_against: "fd0fc6a"
---

# Story Team Layout

The smallest Dark Factory team: three panes for a single story. `story-team.sh` is *sourced*, not
executed, by `factory-start.sh`, so it inherits `SESSION_NAME` and the exported `agent_workdir`
function from its caller and cannot be run standalone.

## Overview

Pane 1 already exists from `tmux new-session`; two splits bring the total to three. Titles are
assigned with `tmux select-pane -T`: pane 1 TDM (lead), pane 2 BE Developer, pane 3 QAS. Unlike
the feature and epic layouts, there is no re-title pass after the splits. Working directories come
from `agent_workdir`, resolved into `DIR_1` through `DIR_3`. The script ends by selecting pane 1.
A good outcome is three live `claude` processes with pane borders reading the three role names.

## When To Use

- The unit of work is one story, matching the `pane_count=3` branch in `factory-start.sh`.
- You want a lead that opens and enqueues the PR, plus one implementer and one verifier.
- Do NOT use it for multi-story features or epics — pick
  [Feature Team Layout](feature-team-layout.md) or [Epic Team Layout](epic-team-layout.md).

## Procedure Map

- `factory-start.sh` sources the layout after creating the session — see
  [factory-start](factory-start.md) for the surrounding lifecycle.
- `CLAUDE_FLAGS` resolves to `--dangerously-skip-permissions` when `FACTORY_AUTO_PERMISSIONS` is
  true, and to an empty string otherwise.
- Pane 1 runs `cd <dir> && claude <flags> -p <TDM prompt>`; the prompt tells the agent to act as
  team lead, follow the SAFe workflow in `CLAUDE.md`, open PRs with `gh pr create`, enqueue with
  `gh pr merge --auto --squash`, and never merge directly — the discipline described in
  [Merge Queue Policy](merge-queue-policy.md).
- Panes 2 and 3 run a bare `cd <dir> && claude <flags>` with no role prompt at all. The BE
  Developer and QAS roles therefore exist only as pane titles; whoever attaches must supply the
  role framing by hand.
- Selecting pane 1 leaves the operator on the lead.

## Citations

- [DARK-FACTORY-GUIDE.md](../../../../dark-factory/docs/DARK-FACTORY-GUIDE.md) — session
  lifecycle, monitoring, and teardown procedure.
