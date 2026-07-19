---
type: command
title: "/local-sync"
description: "Post-pull local sync: branch cleanup, pull, change-gated install and Prisma generate."
tags: [commands, operations, workflow, onboarding]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".claude/commands/local-sync.md"
sources:
  - ".claude/commands/local-sync.md"
  - ".gemini/commands/local/sync.toml"
verified_against: "fd0fc6a"
---

# /local-sync

Run after pulling, when the working copy is behind and it is unclear whether dependencies or the
schema moved with it. Its design choice of note: expensive steps are gated on what actually changed.

## Overview

Nine ordered steps: get onto a clean `dev`, pull, prune merged and stale branches, detect what
changed, then conditionally install dependencies and regenerate Prisma. CI validation is offered but
skipped by default. Ends with a container check, a sync report, and documented recovery paths.

## Invocation

- `/local-sync` — no arguments; infers everything from git state. `/local:sync` on Gemini.
- Precondition: a repo with `origin/dev`; a dirty tree is handled by stashing, not refused.

## What It Does

- Stashes if dirty, checks out `dev`, pulls with a stash/pop fallback.
- Prunes via `git branch --merged dev`, `git fetch --prune`, and a `git for-each-ref` stale listing.
- Sets `DEPS_CHANGED` and `SCHEMA_CHANGED` by diffing `HEAD@{1}..HEAD` over lockfile and `prisma/`.
- Runs `yarn install` only when `DEPS_CHANGED` is non-empty.
- Runs `npx prisma generate` and `npx prisma migrate status` only when `SCHEMA_CHANGED` is non-empty.
- Runs `yarn ci:validate` on explicit opt-in — documented as type-check, lint and `test:unit` — then
  checks running containers and prints a sync report.

Open question: gating reads `HEAD@{1}`; behaviour on a no-op pull or rewritten reflog is UNKNOWN.

## Provider Parity

| Surface | Behaviour |
| --- | --- |
| Claude | checks out and pulls `dev` |
| Gemini | checks out, pulls and merges against `main` — a real branch divergence |
| Gemini | drops stale-branch listing, `SCHEMA_CHANGED` detection, and the report template |
| Gemini | wraps commands in `!{...}` with `\|\| echo` fallbacks, swallowing failures |

Its Related Commands section names `/local-health`, `/local-restart` and `/local-logs`, none of which
exist under `.claude/commands/`; unlike [`/local-deploy`](local-deploy.md), it never says so.

## Citations

- [CONTRIBUTING.md](../../../CONTRIBUTING.md) — branch conventions the cleanup step assumes.
