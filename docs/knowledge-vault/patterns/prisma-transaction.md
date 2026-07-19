---
type: pattern
title: "Prisma Transaction Pattern"
description: "Atomic multi-step database work executed inside an RLS-enforced transaction context."
resource: "patterns_library/database/prisma-transaction.md"
tags: [patterns, subsystems]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "patterns_library/README.md"
  - "scripts/apply-workflow.sh"
verified_against: "fd0fc6a"
---

# Prisma Transaction Pattern

Multi-step writes that must land together or not at all — held inside a transaction that still runs
under an RLS context, so atomicity is bought without giving up row-level enforcement.

## Overview

The file imports all three context helpers — `withUserContext`, `withAdminContext`, and
`withSystemContext` — because the correct one depends on who is writing, and the transaction shape
is the same in each case. Its worked example, `createResourceWithRelations`, writes a main record
plus its related rows in one unit. Reach for it whenever a failure partway through would leave the
database inconsistent. Do not reach for it for a single write, where the transaction is overhead,
and do not use it to escape a context helper: the transaction goes inside the context, never around
it.

At 460 lines it is the largest pattern in the `database/` category, and it follows the library's
fixed order: what it does, when to use it, the code pattern, then per-file supporting sections.

**This pattern is not executed by this repository.** Nothing imports or runs it, and no test,
fixture, or CI job references it. That is by design — the harness *distributes* patterns, and for
a reference implementation the exemplar is the artifact. It reaches adopters wholesale, via
`scripts/apply-workflow.sh` recursively copying `patterns_library/` into the target project.

## Exemplars

- `patterns_library/database/prisma-transaction.md` — the reference implementation itself, carried
  in `resource`; no second in-repo instance exists to compare it against.

Discovery is the intended route in: `CLAUDE.md` and the
[pattern-discovery](../skills/pattern-discovery.md) skill both point at `patterns_library/`, the
[rls-patterns](../skills/rls-patterns.md) skill enforces the same three helpers, and the library
README indexes this file under `database`.

**Open question:** whether this code has ever been compiled or executed anywhere. Nothing in this
repo exercises it, so correctness rests on review alone. Treat the helper names as a contract to
satisfy in your own codebase, not as verified working code.

## Citations

- [patterns_library README](../../../patterns_library/README.md) — the category index.
- [CLAUDE.md](../../../CLAUDE.md) — the Pattern Discovery Protocol and the database guidelines.
