---
type: pattern
title: "Zod Validation API Pattern"
description: "Type-safe route handlers driven by Zod schemas for runtime validation and inferred types."
resource: "patterns_library/api/zod-validation-api.md"
tags: [patterns, subsystems]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "patterns_library/README.md"
  - "scripts/apply-workflow.sh"
verified_against: "fd0fc6a"
---

# Zod Validation API Pattern

One schema per route, doing two jobs at once: rejecting bad input at runtime and supplying the
handler's TypeScript types by inference, so the validated shape and the declared shape cannot drift.

## Overview

The handler declares Zod schemas for body and query, authenticates via `auth` from
`@clerk/nextjs/server`, and runs its Prisma work inside `withUserContext`. Constraints carry their
own error messages — `min(1)` and `max(255)` are the worked examples — so a rejection tells the
caller which field failed and why rather than returning a bare 400. Reach for it on any route
accepting client input. It is not an alternative to the [user context pattern](user-context-api.md)
but a thickening of it; the two compose, and this file is the fuller of the two.

At 451 lines it is the largest of the `api/` patterns, and it follows the library's fixed order:
what it does, when to use it, the code pattern, then per-file supporting sections.

**This pattern is not executed by this repository.** Nothing imports or runs it, and no test,
fixture, or CI job references it. That is by design — the harness *distributes* patterns, and for
a reference implementation the exemplar is the artifact. It reaches adopters wholesale, via
`scripts/apply-workflow.sh` recursively copying `patterns_library/` into the target project.

## Exemplars

- `patterns_library/api/zod-validation-api.md` — the reference implementation itself, carried in
  `resource`; no second in-repo instance exists to compare it against.

Agents are expected to arrive by discovery, not browsing: `CLAUDE.md` and the
[pattern-discovery](../skills/pattern-discovery.md) skill both point at `patterns_library/`, the
[api-patterns](../skills/api-patterns.md) skill names schema validation as a route requirement, and
the library README indexes this file under `api`. The client-side counterpart is the
[form with validation](form-with-validation.md) pattern.

**Open question:** whether this code has ever been compiled or executed anywhere. Nothing in this
repo exercises it, so correctness rests on review alone. Treat the schema shapes as a contract to
satisfy in your own codebase, not as verified working code.

## Citations

- [patterns_library README](../../../patterns_library/README.md) — the category index.
- [CLAUDE.md](../../../CLAUDE.md) — the Pattern Discovery Protocol that routes agents here.
