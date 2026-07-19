---
type: pattern
title: "RLS Migration Pattern"
description: "Prisma schema plus migration that adds a user-owned table with Row Level Security policies."
resource: "patterns_library/database/rls-migration.md"
tags: [patterns, subsystems]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "patterns_library/README.md"
  - "scripts/apply-workflow.sh"
verified_against: "fd0fc6a"
---

# RLS Migration Pattern

Adding a user-owned table is two artifacts, not one: the Prisma model and the migration SQL that
turns row-level security on for it. Shipping the first without the second is the failure this
pattern exists to prevent.

## Overview

The worked example is a `user_preferences` model keyed on a `user_id` of `VarChar(255)`, related to
`user` with `onDelete: Cascade`, paired with migration SQL that enables RLS and installs the
policies. Reach for it whenever a new table holds rows belonging to individual users. It is not
needed for reference or lookup tables with no owner column, and it does not replace the context
helpers — the policies it writes are what those helpers rely on at query time. Prefer proper
migrations here; `db push` skips the SQL half entirely.

Its 294-line file follows the library's fixed order: what it does, when to use it, the code
pattern, then per-file supporting sections.

**This pattern is not executed by this repository.** Nothing imports or runs it, and no test,
fixture, or CI job references it. That is by design — the harness *distributes* patterns, and for
a reference implementation the exemplar is the artifact. It reaches adopters wholesale, via
`scripts/apply-workflow.sh` recursively copying `patterns_library/` into the target project.

## Exemplars

- `patterns_library/database/rls-migration.md` — the reference implementation itself, carried in
  `resource`; no second in-repo instance exists to compare it against.

Agents are meant to arrive by discovery: `CLAUDE.md` and the
[pattern-discovery](../skills/pattern-discovery.md) skill point at `patterns_library/`, the
[migration-patterns](../skills/migration-patterns.md) and
[rls-patterns](../skills/rls-patterns.md) skills both land here, and the library README indexes the
file under `database`.

**Open question:** whether this schema and SQL have ever been applied anywhere. Nothing in this
repo migrates against them, so correctness rests on review alone.

## Citations

- [patterns_library README](../../../patterns_library/README.md) — the category index.
- [CLAUDE.md](../../../CLAUDE.md) — the migration workflow and Pattern Discovery Protocol.
