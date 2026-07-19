---
type: command
title: "/update-docs"
description: "Scans the branch diff to identify and update every doc the change touches, before the PR."
tags: [commands, operations, process, workflow]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".claude/commands/update-docs.md"
sources:
  - ".gemini/commands/workflow/update-docs.toml"
verified_against: "fd0fc6a"
---

# /update-docs

Run before opening a PR, to satisfy the contributing rule that documentation related to the work
ships inside the same PR. It reads the diff, decides what that implies, and edits.

## Overview

Four assessment steps then a six-step workflow. Assessment categorises the changed files into
architecture or workflow changes, new features or APIs, process modifications, configuration changes,
and schema changes; the workflow maps those to docs, runs a checklist, and executes the updates.

## Invocation

- `/update-docs` — no arguments.
- `/workflow:update-docs` on the Gemini surface.
- Precondition: a branch with commits to diff against the integration branch.

## What It Does

- Issues exactly one shell command in the whole file: `git diff origin/dev --name-only`.
- Routes changes to docs by category: `CLAUDE.md` when commands, workflow or tech stack change;
  `CONTRIBUTING.md` when process changes; `docs/database/` for schema, RLS and migrations;
  `docs/api/` for routes and webhooks; feature docs, inline comments, feature-directory READMEs, and
  `docs/adr/` for significant architecture decisions.
- Applies a per-doc checklist: content accuracy, examples updated, commands and code samples tested,
  links validated, markdown lint passed — running the markdown lint fix task for each update.
- **Pauses for human confirmation**: the list of intended updates is presented to the user before
  any edit is executed.
- **Writes**: edits the documentation files and stages them into the current commit.

Open question: `docs/api/` and `docs/adr/` are routing targets but neither directory exists in this
repository at the verified commit, so those branches of the routing table are currently unreachable.

## Provider Parity

- Gemini — section-for-section identical apart from the diff; the closest parity in the mirrored set
  after [`/retro`](retro.md).
- Gemini — diffs against `origin/main` where Claude diffs against `origin/dev`, and wraps the diff
  for pre-execution rather than issuing it as a step.

## Citations

- [CONTRIBUTING.md](../../../CONTRIBUTING.md) — the rule that docs related to the work are updated
  within the PR.
