---
type: runbook
title: "Epic Team Layout"
description: "Nine-pane tmux layout starting the full SAFe agent team led by the TDM."
tags: [subsystems, orchestration, agents]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "dark-factory/templates/team-layouts/epic-team.sh"
  - "dark-factory/scripts/factory-start.sh"
verified_against: "fd0fc6a"
---

# Epic Team Layout

The largest team the factory ships: nine panes covering the full SAFe roster, matching the
`pane_count=9` branch in [factory-start.sh](factory-start.md) and therefore nine worktrees when
worktrees are enabled. Like the smaller layouts it is a sourced fragment that expects
`SESSION_NAME` and the exported `agent_workdir` function to already exist.

## Overview

Eight `split-window` calls on top of the initial pane produce nine panes. Titles are set during
splitting and then wholly overwritten by an explicit re-title block, which the file itself labels
"best-effort labels" because indices shift as splits happen. The resulting mapping is 1 TDM (lead),
2 BSA, 3 BE Developer, 4 QAS, 5 RTE, 6 ARCH, 7 FE Developer, 8 Security, 9 Data Engineer. Only
pane 1 receives a `-p` prompt, phrased for "an epic-level effort".

## When To Use

- Work spanning multiple features that needs architecture, security and data roles resident, not
  consulted — the full team of [TDM](../../roles/tdm.md), BSA, architect, security, backend,
  frontend, data, QAS and RTE.
- Do NOT invoke this file directly; run `factory-start.sh epic [ticket-id]`.
- Do NOT choose it for a feature-sized unit of work — nine idle agents cost tokens and attention.
  Use [Feature Team Layout](feature-team-layout.md) or [Story Team Layout](story-team-layout.md).

## Procedure Map

- Splits — eight splits, each launching `claude` in that pane's `agent_workdir` directory.
- Permissions — `CLAUDE_FLAGS` gains `--dangerously-skip-permissions` only when
  `FACTORY_AUTO_PERMISSIONS` is true.
- Lead prompt — pane 1 only, carrying the same PR-and-merge-queue instructions as the smaller
  layouts. See [Merge Queue Policy](merge-queue-policy.md).
- Bare agents — panes 2 through 9 launch plain `claude`, awaiting direction from the lead or a
  human operator.
- Re-title — the explicit pass that establishes the final index-to-role mapping.

DOC DRIFT: the ASCII grid comment orders the roles TDM / BSA ARCH Security / BE FE Data / QAS RTE,
which does not match the mapping the re-title block actually produces. Trust the pane titles.

## Citations

- [templates/README.md](../../../../dark-factory/templates/README.md) — what each template and team
  layout is for; `templates/team-layouts/epic-team.sh` is the definition itself.
