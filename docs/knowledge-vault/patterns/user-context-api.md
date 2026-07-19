---
type: pattern
title: "User Context API Pattern"
description: "Authenticated API route enforcing RLS via withUserContext so users reach only their own rows."
resource: "patterns_library/api/user-context-api.md"
tags: [patterns, subsystems]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "patterns_library/README.md"
  - "scripts/apply-workflow.sh"
verified_against: "fd0fc6a"
---

# User Context API Pattern

The baseline shape for any authenticated read: resolve the caller, then run every query inside a
per-user RLS context so the database — not the handler — decides which rows are visible.

## Overview

A Next.js route handler pulls the caller from `auth` (`@clerk/nextjs/server`), then wraps its
Prisma work in `withUserContext` from `@/lib/rls-context`, with `prisma` imported from
`@/lib/prisma`. Query-string input passes through an optional Zod `QuerySchema` that coerces
`limit` and `offset` before they reach the query. Reach for it whenever a route serves data owned
by the requesting user. Do not reach for it when the route needs elevated visibility — that is the
[admin context pattern](admin-context-api.md) — or when an external system, not a user, is the
caller, which is the [webhook handler](webhook-handler.md).

At 245 lines this is the smallest of the `api/` patterns, and it is the one the other two vary
from. Its file follows the library's fixed order: what it does, when to use it, the code pattern,
then per-file supporting sections.

**This pattern is not executed by this repository.** Nothing imports or runs it, and no test,
fixture, or CI job references it. That is by design — the harness *distributes* patterns, and for
a reference implementation the exemplar is the artifact. It reaches adopters wholesale, via
`scripts/apply-workflow.sh` recursively copying `patterns_library/` into the target project.

## Exemplars

- `patterns_library/api/user-context-api.md` — the reference implementation itself, carried in
  `resource`; there is no second in-repo instance to compare it against.

Agents are meant to find it through discovery rather than browsing: both `CLAUDE.md` and the
[pattern-discovery](../skills/pattern-discovery.md) skill route to `patterns_library/`, and the
library README indexes it under `api`. The [rls-patterns](../skills/rls-patterns.md) skill enforces
the same helper choice from the other direction.

**Open question:** whether this code has ever been compiled or executed anywhere. Nothing in this
repo exercises it, so its correctness rests on review alone. Treat the imports and helper names as
a contract to satisfy in your own codebase, not as verified working code.

## Citations

- [patterns_library README](../../../patterns_library/README.md) — the category index.
- [CLAUDE.md](../../../CLAUDE.md) — the Pattern Discovery Protocol that routes agents here.
