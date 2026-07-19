---
type: script
title: "reorganize-docs.sh"
description: "One-time migration that restructures repository documentation per the repository reorganization plan."
tags: [operations, process]
timestamp: 2026-07-19
status: active
domain: operations
resource: "scripts/reorganize-docs.sh"
sources:
  - "scripts/reorganize-docs.sh"
  - "docs/REPOSITORY-REORGANIZATION-PLAN.md"
verified_against: "fd0fc6a"
---

# reorganize-docs.sh

**Destructive by design**: it moves documentation files to new locations under `docs/`, breaking
every inbound link until its companion repair script runs. About 11.1 KB of bash under `set -e`, the
largest of the doc-maintenance scripts. This migration has already been applied to this repo.

## Overview

It implements the file moves described in the repository reorganization plan — a historical one-time
restructuring, not a routine workflow step. 344 lines of straight-line procedure with no functions.
Three guards run before anything moves: a location check that exits unless both `README.md` and
`.git` are present, a `git diff-index` check that warns and prompts on uncommitted changes, and a
second explicit `y/N` confirmation. It creates `docs/database`, `docs/security`, `docs/ci-cd` and
`docs/archive`, then performs 8 moves: `DATA_DICTIONARY.md`, `RLS_IMPLEMENTATION_GUIDE.md`,
`RLS_POLICY_CATALOG.md` and `RLS_DATABASE_MIGRATION_SOP.md` to `docs/database/`;
`SECURITY_FIRST_ARCHITECTURE.md` to `docs/security/`; `CI-CD-Pipeline-Guide.md` to `docs/ci-cd/`;
`README-TEMPLATE.md` to `docs/archive/`; and `apply-workflow.sh` to `scripts/`. `AGENTS.md` and
`CLAUDE.md` are deliberately left in the root per AI-assistant convention. It then writes `README.md`
index files for the new directories and rewrites references itself — overlapping heavily with
[update-doc-references.sh](update-doc-references.md) and
[fix-remaining-doc-references.sh](fix-remaining-doc-references.md), so three scripts edit one link
set.

## Inputs & Outputs

- **In** no flags — the move mapping is hardcoded in the script body; there is no dry-run.
- **In** working directory — must contain `README.md` and `.git`.
- **Out** relocated documentation files under `docs/`, moved with `git mv`, so rename history **is**
  preserved. The moves are staged but **not committed** — the operator must commit them.
- **Exit** non-zero — when the working directory fails the repository-root guard, or on any command
  failure under `set -e`.
- **Note** re-running is safe: every move is guarded by an existence test, so a second run is a
  no-op rather than an error.

## Invoked By

- Manual, once. No command, hook, or workflow in the repo invokes it.
- Followed by `scripts/update-doc-references.sh`, then `scripts/fix-remaining-doc-references.sh`.

## Citations

- [Repository Reorganization Plan](../../../REPOSITORY-REORGANIZATION-PLAN.md) — the target
  structure this script realizes.
