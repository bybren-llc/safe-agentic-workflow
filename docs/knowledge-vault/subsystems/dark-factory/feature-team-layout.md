---
type: runbook
title: "Feature Team Layout"
description: "Five-pane tmux layout starting TDM lead plus BE, FE, QAS, and RTE agents."
tags: [subsystems, orchestration, agents]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "dark-factory/templates/team-layouts/feature-team.sh"
  - "dark-factory/scripts/factory-start.sh"
verified_against: "fd0fc6a"
---

# Feature Team Layout

The middle of the three team sizes: five panes, one TDM lead and four specialists, matching the
`pane_count=5` branch in [factory-start.sh](factory-start.md). It is a sourced fragment, not a
standalone script — it expects `SESSION_NAME` and the exported `agent_workdir` function to already
exist in the calling shell.

## Overview

Four `split-window` calls on top of the initial pane produce five panes. Titles are assigned during
splitting and then a second re-title pass overwrites them, because pane indices shift as splits
happen. The final mapping is what matters: 1 TDM (lead), 2 BE Developer, 3 QAS, 4 FE Developer,
5 RTE. Only pane 1 gets a `-p` prompt; panes 2 through 5 launch bare `claude` sessions that a human
or the lead must direct. The file ends by selecting pane 1.

## When To Use

- A feature-sized unit of work needing backend, frontend, test and release-train coverage.
- Do NOT invoke this file directly; run `factory-start.sh feature [ticket-id]`, which creates the
  session, the five worktrees, and the pane logging around it.
- Do NOT reach for it when the work is a single story ([Story Team Layout](story-team-layout.md))
  or spans multiple features ([Epic Team Layout](epic-team-layout.md)).

## Procedure Map

- Splits — four splits, each launching `claude` in the pane's `agent_workdir` directory.
- Permissions — `CLAUDE_FLAGS` becomes `--dangerously-skip-permissions` only when
  `FACTORY_AUTO_PERMISSIONS` is true; otherwise agents prompt and will block unattended.
- Lead prompt — pane 1 only, instructing the TDM to open PRs with `gh pr create` and enqueue with
  `gh pr merge --auto --squash`, never merging directly. See
  [Merge Queue Policy](merge-queue-policy.md).
- Re-title — the explicit pass that fixes the index-to-role mapping after the splits.
- Focus — `select-pane` back to 1 so an attaching operator lands on the lead.

DOC DRIFT: the ASCII layout comment at the top of the file draws row two as BE | FE and row three
as QAS | RTE, but the final re-title pass puts QAS at index 3 and FE at index 4. The pane titles
are the truth; the comment is stale.

## Citations

- [templates/README.md](../../../../dark-factory/templates/README.md) — what each template and
  team layout is for; `templates/team-layouts/feature-team.sh` is the definition itself.
