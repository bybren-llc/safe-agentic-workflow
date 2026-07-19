---
type: pattern
title: "Authenticated Page Pattern"
description: "Server-rendered protected page with auth redirect, RLS-scoped data fetch, and forced dynamic rendering."
resource: "patterns_library/ui/authenticated-page.md"
tags: [patterns, subsystems]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "patterns_library/README.md"
  - "scripts/apply-workflow.sh"
verified_against: "fd0fc6a"
---

# Authenticated Page Pattern

The reference implementation for a protected server-rendered page: bounce unauthenticated
visitors, then fetch that user's data under an RLS context rather than around it.

## Overview

The page exports `const dynamic = 'force-dynamic'` so auth context resolves per request instead of
being frozen at build time — the detail that most often goes wrong when this is written from
memory. Unauthenticated visitors are sent away with `redirect` from `next/navigation`, and data is
read through `withUserContext` or, for privileged views, `withAdminContext`. Reach for it for any
page whose content is scoped to the signed-in user; do not reach for it on a public marketing page,
where forcing dynamic rendering throws away caching for nothing.

Its 349-line file follows the library's fixed section order — what it does, when to use it, the
code pattern, then per-file supporting sections.

**This pattern is not executed by this repository.** Nothing here imports or runs it, and no test,
fixture, or CI job references it. That is not a defect: the harness *distributes* patterns, and
for a reference implementation the exemplar is the artifact. It reaches adopters by being copied
wholesale — `scripts/apply-workflow.sh` recursively copies `patterns_library/` into the target
project. Read it as a template to adapt, not as live code with a call graph.

## Exemplars

The single exemplar is the library file itself, carried in `resource`. Agents are expected to
find it through the Pattern Discovery Protocol rather than by browsing: both `CLAUDE.md` and the
[pattern-discovery](../skills/pattern-discovery.md) skill point at `patterns_library/`, and the
library's own README indexes it under the `ui` category. The
[frontend-patterns](../skills/frontend-patterns.md) skill routes page-building work to the same
place, and [rls-patterns](../skills/rls-patterns.md) governs the context helpers it calls.

An open question travels with it: whether this code was ever compiled or executed anywhere is
unknown, because no test, fixture, or CI job in this repo references it. Its correctness rests on
review, not on a gate.

## Citations

- [patterns_library README](../../../patterns_library/README.md) — the category index.
- [CLAUDE.md](../../../CLAUDE.md) — the Pattern Discovery Protocol that routes agents here.
