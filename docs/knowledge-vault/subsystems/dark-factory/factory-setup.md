---
type: runbook
title: "factory-setup.sh"
description: "One-time Dark Factory setup that checks tools, creates ~/.dark-factory, and gates on merge queue."
tags: [subsystems, operations, gates, ci]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "dark-factory/scripts/factory-setup.sh"
  - "dark-factory/templates/env.template"
  - "dark-factory/docs/MERGE-QUEUE-POLICY.md"
  - "dark-factory/scripts/README.md"
verified_against: "fd0fc6a"
---

# factory-setup.sh

The one-time entry point to the Dark Factory, run once per machine before any session exists. It
verifies tooling, creates `$HOME/.dark-factory`, and refuses to declare the machine ready unless
the repository actually enforces a GitHub merge queue. No arguments; `set -euo pipefail`.

## Overview

The script's real job is the readiness gate. Autonomous agents opening PRs without a queue would
merge into each other, so setup fails closed: `READINESS GATE FAILED` and exit 1. It sources
`$HOME/.dark-factory/env` when present, purely for `FACTORY_MAIN_BRANCH`; if that key is unset,
`MAIN_BRANCH` stays the literal `{{MAIN_BRANCH}}` token and every `gh api` call is nonsense.

## When To Use

- First time standing up a factory host, before [factory-start.sh](factory-start.md); and after
  changing the trunk branch name or the repository's ruleset configuration.
- When `factory-start.sh` dies reporting that `$HOME/.dark-factory/env` is missing.
- Do NOT use it to restart a running session — that is `factory-stop.sh` then `factory-start.sh`.

## Procedure Map

- Prereqs — `command -v` for exactly `tmux`, `claude`, `git`, `gh`; dies listing all missing.
- State — `mkdir -p` on `logs/` and `worktrees/` under `$HOME/.dark-factory`.
- Config — copies `env.template` to `$HOME/.dark-factory/env` only when absent; warns and
  continues if the template is missing.
- Gate A — resolves the repo with `gh repo view`, then accepts any ruleset carrying a `merge_queue`
  rule whose `conditions.ref_name.include` names the branch or `~DEFAULT_BRANCH`; falls back to
  branch protection with a non-null `required_merge_queue`.
- Gate B — `grep -rl merge_group` over `.github/workflows/*.yml`.
- Advisory — warns but does not fail when `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` is unset.

All JSON parsing runs through inline `python3` heredocs, yet `python3` is absent from the
prerequisite loop and from both prerequisite tables. Exit codes: 0 on success, 1 on missing tools,
an unresolvable repo, or a failed gate. DOC DRIFT: `env.template` labels `FACTORY_MERGE_METHOD`
and `FACTORY_REQUIRE_QUEUE` "enforced by factory-setup.sh", but the script never reads either;
Gate B greps only `*.yml`, so a `merge_group` trigger in a `*.yaml` workflow is invisible.

## Citations

- [MERGE-QUEUE-POLICY.md](../../../../dark-factory/docs/MERGE-QUEUE-POLICY.md) — the policy gated.
- [scripts/README.md](../../../../dark-factory/scripts/README.md) — operator-facing script table.
