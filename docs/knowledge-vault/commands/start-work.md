---
type: command
title: "/start-work"
description: "Opens work on a Linear ticket behind a mandatory stop-the-line AC/DoD gate, then branches from latest dev."
resource: ".claude/commands/start-work.md"
tags: [commands, operations, gates, workflow, methodology]
timestamp: 2026-07-19
status: active
domain: operations
sources:
  - ".gemini/commands/workflow/start-work.toml"
verified_against: "fd0fc6a"
---

# /start-work

The entry point for ticketed work: less "make a branch" than "refuse to start until it is ready".

## Overview

Runs a five-item pre-flight: confirm the ticket exists and is Todo or In Progress, apply the
stop-the-line AC/DoD gate, derive the branch name, sync `dev`, then cut the branch. Only the gate
can hard-block; `CONTRIBUTING.md` remains the northstar for conventions.

## Invocation

- `/start-work [<ticket-number>]` — an `argument-hint` is declared; with no argument the command
  asks for the number rather than guessing.
- `/workflow:start-work` on the Gemini surface.

Its Claude frontmatter grants a wildcard Linear MCP scope alongside the standard file and shell
tools — one of only two commands to do so, the other being [`/sync-linear`](sync-linear.md).

## What It Does

- Verifies the ticket via the Linear MCP and checks its status.
- **Applies the [stop-the-line gate](../methodology/stop-the-line-gate.md)**: if AC or DoD are
  missing or unclear it STOPS and routes back to BSA or POPM. Implementing roles are explicitly
  not responsible for inventing them.
- Derives a lowercase hyphenated branch name from ticket number and description.
- Syncs `dev` and verifies a clean tree before cutting the branch.

## Provider Parity

| Surface | Behaviour |
| --- | --- |
| Claude | branches from `dev`; full Linear MCP verification |
| Gemini | branches from `main`, not `dev` — a real divergence, not wording |
| Gemini | no Linear MCP, so verification degrades to "check the web UI or CLI" |
| Gemini | swaps Claude's `## Workflow` routing section for a pre-executed `!{git status}` block |

The stop-the-line gate text is preserved verbatim across both providers — the part that most
needed to survive the port.

## Citations

- [CONTRIBUTING.md](../../../CONTRIBUTING.md) — branch naming and commit conventions.
- [Agent Workflow SOP](../../sop/AGENT_WORKFLOW_SOP.md) — the gate's place in the workflow contract.
