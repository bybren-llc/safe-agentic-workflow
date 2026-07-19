---
type: architecture
title: "Dark Factory"
description: "Self-contained tmux subsystem that runs persistent SAFe agent teams on a headless machine."
tags: [subsystems, orchestration, operations, agents]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "dark-factory/README.md"
  - "dark-factory/scripts/factory-start.sh"
  - "dark-factory/docs/DARK-FACTORY-GUIDE.md"
  - ".harness-manifest.yml"
verified_against: "fd0fc6a"
---

# Dark Factory

A self-contained subsystem that parks a full SAFe agent team inside a long-lived tmux session on a
headless machine, so work continues while nobody is watching. Five operator scripts, three team
layouts, four templates, four docs; no daemon, no service, no CI integration.

## Overview

The problem is persistence: an agent team that dies with your SSH connection cannot run an epic.
tmux supplies the persistence and the scripts supply the shape — one pane per agent, one worktree
per agent, one log file per pane. All mutable state lives under `$HOME/.dark-factory` (`env`,
`logs/<session>/`, `logs/archive/`, `worktrees/<session>/agent-N`), and every script finds its
sessions by the literal `^factory-` prefix, named `factory-<ticket-id>` or `factory-<timestamp>`.

## Design

| Component | Responsibility | Notes |
| --- | --- | --- |
| `factory-setup.sh` | Prereq check and merge-queue readiness gate | Exits 1 if no queue |
| `factory-start.sh` | Session, worktrees, layout, pane logging | Hardcodes 3/5/9 panes |
| `factory-status.sh` | Read-only active/idle/dead dashboard | 300s idle threshold |
| `factory-stop.sh` | SIGINT panes, kill session, archive logs | Never SIGKILLs |
| `factory-attach.sh` | List sessions, or attach to session and pane | Assumes window index 1 |

The Claude Code path is pane-per-agent and fully scripted; the Codex path is window-per-agent and
ships only as a token template (`{{PROJECT_PATH}}`, `{{TICKET_ID}}`, `{{TEAM_SIZE}}`) that
`factory-start.sh` never calls. `scripts/apply-workflow.sh` does not distribute this subsystem —
it copies only the pattern library, spec templates and linting configs — but `dark-factory/` is a
shared path in `.harness-manifest.yml`. DOC DRIFT: the README tree labels the layouts "2-3", "4-5"
and "6-9 agent" while the code hardcodes exactly 3, 5 and 9 panes.

## Related Concepts

- [factory-setup.sh](dark-factory/factory-setup.md) — the gate every other script depends on.
- [factory-start.sh](dark-factory/factory-start.md) — creates the session the rest operate on.
- [Merge Queue Policy](dark-factory/merge-queue-policy.md) — the single path to trunk.
- [tmux Topology](dark-factory/tmux-topology.md) — the pane, window and index conventions.

## Citations

- [Dark Factory README](../../../dark-factory/README.md) — inventory and quick start.
- [DARK-FACTORY-GUIDE.md](../../../dark-factory/docs/DARK-FACTORY-GUIDE.md) — operator guide.
