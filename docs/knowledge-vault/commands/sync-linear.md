---
type: command
title: "/sync-linear"
description: "Derives ticket status from branch commits and writes status, labels and a comment back to Linear."
tags: [commands, operations, sync, workflow]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".claude/commands/sync-linear.md"
sources:
  - ".gemini/commands/workflow/sync-linear.toml"
verified_against: "fd0fc6a"
---

# /sync-linear

Closes the gap between what git knows and what the ticket says. On Claude it writes without asking.

## Overview

Eight steps: identify the ticket from the branch, read the git state, map it to a status, update the
issue, comment, link artefacts, apply labels, tag stakeholders. It asserts Linear as the single
source of truth for status — the claim that justifies the write. Cadence: daily during active work,
before standup, after major progress, on blockage, and on PR create or merge.

## Invocation

- `/sync-linear` — no arguments; the ticket comes from the branch name.
- `/workflow:sync-linear` on the Gemini surface.
- Its Claude frontmatter grants a wildcard Linear MCP scope.

## What It Does

- Extracts the ticket ID from `git branch --show-current` via `grep -oE`, then fetches it over MCP.
- Reads `git log origin/dev..HEAD --oneline` and `git diff origin/dev --stat`.
- **Writes to Linear**: updates status, progress percentage and labels, then posts a Progress Update
  comment. There is no confirmation step in the source.
- Links the PR, tickets and docs; applies `in-progress`, `blocked`, `needs-review` or `needs-testing`.

| Work state | Ticket status |
| --- | --- |
| Commits present, incomplete | In Progress |
| Complete, no PR | Ready for Review, or stay In Progress |
| PR created | In Review |
| PR merged | Done — usually auto-synced for tickets named in commits; child stories closed by hand |
| Blocked | Blocked |

## Provider Parity

- Gemini — makes no MCP calls. Update and comment degrade to "use the Linear web UI or CLI", so on
  Gemini the command is advisory and writes nothing.
- Gemini — diffs against `origin/main` where Claude diffs against `origin/dev`, greps the branch with
  a generic `[A-Z]+-[0-9]+`, and drops the label and notify-stakeholders steps.

## Citations

- [Agent Workflow SOP](../../sop/AGENT_WORKFLOW_SOP.md) — the status contract this command enforces.
