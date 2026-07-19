---
type: command
title: "/end-work"
description: "Session-close checklist: commits outstanding work, updates Linear and preserves context."
tags: [commands, operations, workflow, process]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".claude/commands/end-work.md"
sources:
  - ".claude/commands/end-work.md"
  - ".gemini/commands/workflow/end-work.toml"
verified_against: "fd0fc6a"
---

# /end-work

Reached at the end of a working session — not at the end of a ticket. Its job is to leave the tree,
the ticket, and the next operator's memory in a state that survives a context switch.

## Overview

Six ordered steps: classify the outcome, commit, run a documentation checklist, write the Linear
ticket, capture a Session Context block if work is unfinished, then decide the branch's fate. It
closes the loop opened by [`/start-work`](start-work.md) and hands off to
[`/pre-pr`](pre-pr.md) when the work is genuinely ready for review.

## Invocation

- `/end-work` — no arguments; the command reads state from git and Linear itself.
- `/workflow:end-work` on Gemini. Preconditions: a git repo with `origin/dev`, plus Linear MCP.

## What It Does

- Classifies the session Complete, In Progress or Blocked from `git status` and the dev-to-HEAD log.
- **Writes to the repository**: runs `git add .` then commits in SAFe format — one of the few
  commands that stages the whole tree rather than a scoped set, so untracked strays go in too.
- Walks a doc checklist covering inline comments, `README.md`, `CLAUDE.md`, `CONTRIBUTING.md`.
- Updates Linear via `update_issue` and `create_comment`, branching on the three statuses.
- Emits a Session Context markdown block when stopping mid-work.
- Offers three branch endings: push, keep local, or open a WIP PR.
- Notes that the GitHub-Linear integration auto-closes tickets referenced in commit messages on PR
  merge — child stories never referenced must be closed by hand.

## Provider Parity

| Surface | Behaviour |
| --- | --- |
| Claude | classifies against `origin/dev`; runs the commit itself |
| Gemini | classifies against `origin/main` — a real branch divergence |
| Gemini | step 4 is prose only; no Linear MCP calls are issued |
| Gemini | suggests committing rather than running `git add`/`git commit` |
| Gemini | drops the "If Experimental" WIP-PR ending from step 6 |

## Citations

- [CONTRIBUTING.md](../../../CONTRIBUTING.md) — commit message format and branch conventions.
- [Agent Workflow SOP](../../sop/AGENT_WORKFLOW_SOP.md) — where session close sits in the contract.
