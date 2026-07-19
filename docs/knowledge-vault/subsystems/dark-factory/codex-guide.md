---
type: guide
title: "Codex Dark Factory Guide"
description: "How to run the window-based Codex CLI factory with the third-party codex-yolo auto-approval daemon."
tags: [subsystems, providers, operations, agents]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "dark-factory/docs/CODEX-DARK-FACTORY-GUIDE.md"
  - "dark-factory/templates/codex-factory.sh"
verified_against: "fd0fc6a"
---

# Codex Dark Factory Guide

For operators who want the [Dark Factory](../dark-factory.md) shape but with OpenAI's Codex CLI
instead of Claude Code. The less-travelled runtime: 421 lines of source guide, and a launcher that
is still a template. Read the Claude path first.

## What changes: windows, not panes

Codex CLI sessions are full-screen, so each role gets its own tmux **window** rather than a pane.
That cascades: pane-index navigation, the `factory-status.sh` classifier, and pane-level
`pipe-pane` logging all assume the Claude layout. Roles map to `.codex/agents/*.toml` configs —
`tdm`, `bsa`, `system-architect`, `security-engineer`, `be-developer`, `fe-developer`,
`data-engineer`, `qas`, `rte` — and QAS runs `sandbox_mode` read-only by design.

## The approval problem, and codex-yolo

Autonomous agents stall on interactive approval prompts. Claude Code has
`--dangerously-skip-permissions`; Codex CLI does not, so the guide reaches for `codex-yolo`, a
third-party daemon that watches `tmux capture-pane` output for approval prompts, auto-approves
writes and command execution, and appends to `~/.codex-yolo/audit.log`. Treat this as the security
boundary of the document: the guide itself states codex-yolo is not officially supported by OpenAI
and should run only on isolated infrastructure. A daemon that blanket-approves commands by
pattern-matching terminal output is as dangerous as it sounds; the audit log is your only record.

## Prerequisites

On top of tmux, `gh` and `git`: the Codex CLI, codex-yolo, Node.js 22+, and `OPENAI_API_KEY`.

## Two places the guide does not match the code

- **Worktrees.** The FAQ says to enable them by setting `FACTORY_USE_WORKTREES` in
  `~/.dark-factory/env` and uncommenting the template's worktree section. Neither half holds:
  `codex-factory.sh` never sources that file — it reads the variable from the process environment
  only — and its worktree block is live code.
- **Launching.** The guide describes running `codex-factory.sh`, but it is a template: its
  `{{PROJECT_PATH}}`, `{{TICKET_PREFIX}}`, `{{TICKET_ID}}` and `{{TEAM_SIZE}}` tokens need
  hand-replacing before it runs, and no script in the subsystem invokes it.

Next: [Merge Queue Policy](merge-queue-policy.md), then [Cursor SSH Guide](cursor-ssh-guide.md).

## Citations

- [CODEX-DARK-FACTORY-GUIDE.md](../../../../dark-factory/docs/CODEX-DARK-FACTORY-GUIDE.md) — all 12
  sections: role configs, codex-yolo setup, FAQ.
