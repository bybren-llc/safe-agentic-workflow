---
type: command
title: "/check-workflow"
description: "Traffic-light workflow health check covering branch naming, Linear ticket linkage, commit format, rebase status and docs."
resource: ".claude/commands/check-workflow.md"
tags: [commands, operations, workflow, gates]
timestamp: 2026-07-19
status: active
domain: operations
sources:
  - ".gemini/commands/workflow/check-workflow.toml"
verified_against: "fd0fc6a"
---

# /check-workflow

A mid-session sanity check: am I on a properly named branch, against the right ticket, with commits
that will survive review? It reads and reports, and changes nothing — the cheap way to find out you
have drifted before a PR tells you.

## Overview

Five inspections produce a single GREEN / YELLOW / RED verdict plus a list of specific issues. It
makes no commits, no pushes, and no Linear writes. `CONTRIBUTING.md` is referenced as the source of
the requirements it checks against, so the command grades but does not define the rules.

## Invocation

- `/check-workflow` — no arguments; state is inferred entirely from the working tree.
- `/workflow:check-workflow` on the Gemini surface.
- Preconditions: a git repo with `origin/dev` reachable, and the Linear MCP configured for the
  ticket lookup.

## What It Does

- Runs `git status` and `git branch --show-current` to establish working state.
- Extracts the ticket number from the branch name and fetches the issue via the Linear MCP.
- Lists commits ahead with `git log origin/dev..HEAD --oneline` and checks message format.
- Runs `git fetch origin`, then `git log HEAD..origin/dev --oneline` to detect rebase lag.
- Prompts a check of `CLAUDE.md`, `CONTRIBUTING.md`, and feature docs for needed updates.
- Emits the three-state verdict and the issue list.

Note the body says "Extract WOR number from branch name" — a hardcoded `WOR` prefix leaking through
the ticket-prefix templating.

## Provider Parity

| Surface | Behaviour |
| --- | --- |
| Claude | compares against `origin/dev` throughout |
| Gemini | compares against `origin/main` in steps 1, 3 and 4 — a real branch divergence |
| Gemini | no Linear MCP; greps the branch for `[A-Z]+-[0-9]+` and defers to the web UI or CLI |
| Gemini | wraps git calls in `!{...}` for pre-execution where Claude issues agent Bash calls |

## Citations

- [CONTRIBUTING.md](../../../CONTRIBUTING.md) — the branch, commit and rebase requirements checked.
- [Agent Workflow SOP](../../sop/AGENT_WORKFLOW_SOP.md) — the workflow contract being graded.
