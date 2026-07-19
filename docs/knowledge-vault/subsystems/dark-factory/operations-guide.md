---
type: guide
title: "Dark Factory Guide"
description: "Comprehensive setup, operation, worktree, logging, and troubleshooting guide for the Claude Code factory."
tags: [subsystems, operations, onboarding]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "dark-factory/docs/DARK-FACTORY-GUIDE.md"
  - "dark-factory/README.md"
  - "dark-factory/scripts/factory-setup.sh"
  - "dark-factory/scripts/factory-start.sh"
  - "dark-factory/scripts/factory-status.sh"
  - "dark-factory/scripts/factory-stop.sh"
  - "dark-factory/scripts/factory-attach.sh"
verified_against: "fd0fc6a"
---

# Dark Factory Guide

The operator's manual for [Dark Factory](../dark-factory.md): 485 lines across 14 numbered
sections, from prerequisites through FAQ. Read it if you are about to start, watch, or tear down a
multi-agent tmux session on a machine you are responsible for.

## The Arc It Walks

Overview, Prerequisites, Installation, Starting a Session, Monitoring, Stopping, Git Worktrees,
Log Management, Session Durability and Recovery, Security Considerations, Integrating with SAFe
Workflow, Companion Tools, Troubleshooting, FAQ. The middle third maps one-to-one onto the
lifecycle scripts — [factory-setup](factory-setup.md), [factory-start](factory-start.md),
[factory-status](factory-status.md), [factory-attach](factory-attach.md), and
[factory-stop](factory-stop.md) — so read a script's concept beside its section rather than
instead of it. The guide uses `{{MAIN_BRANCH}}`, `{{GITHUB_ORG}}` and `{{PROJECT_REPO}}`
substitution tokens throughout; they are placeholders an adopter fills, not literal values.

## Where It Is Thinner Than It Sounds

The prerequisite table lists tmux 3.0+, Claude Code 2.1+, gh 2.0+ and git 2.30+, and claims
`factory-setup.sh` "validates all prerequisites automatically." That script additionally depends
on `python3` for every `gh api` JSON parse and never checks for it, so the table is incomplete and
setup can fail *after* the prerequisite step reports success. Its described five setup steps do
match the script's real order.

Two more honest edges the FAQ itself raises: tmux sessions do not survive a reboot, and the
recommended remedy is tmux-resurrect, which this subsystem neither ships nor configures. And
Agent Teams is optional — panes are independent `claude` processes — which is consistent with the
layouts, all of which start a bare `claude` in every non-lead pane.

## Budgeting the Machine

The guide quotes roughly 200-500MB RSS per Claude process, so a five-agent feature team wants
1-2.5GB before anything else runs — check that against your host before scaling pane count.

## Citations

- [DARK-FACTORY-GUIDE.md](../../../../dark-factory/docs/DARK-FACTORY-GUIDE.md) — the full manual.
- [dark-factory/README.md](../../../../dark-factory/README.md) — the short orientation.
