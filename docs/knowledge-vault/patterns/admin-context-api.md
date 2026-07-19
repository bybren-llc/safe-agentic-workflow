---
type: pattern
title: "Admin Context API Pattern"
description: "Admin-only API route using verifyAdminAndGetUserId and withAdminContext for elevated RLS access."
resource: "patterns_library/api/admin-context-api.md"
tags: [patterns, subsystems]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "patterns_library/README.md"
  - "scripts/apply-workflow.sh"
verified_against: "fd0fc6a"
---

# Admin Context API Pattern

The reference implementation for an admin-only API route: authenticate, elevate, then query under
an admin RLS context rather than bypassing row-level security.

## Overview

The pattern pairs an admin identity check with an elevated database context — `verifyAdminAndGetUserId`
for the former, `withAdminContext` for the latter — so privileged reads still travel through RLS
instead of around it. Request input is validated with a schema before it reaches the query.

Its file follows the library's fixed section order: what it does, when to use it, the code
pattern, then per-file supporting sections.

**This pattern is not executed by this repository.** Nothing here imports or runs it, and no test,
fixture, or CI job references it. That is not a defect — the harness *distributes* patterns, and
for a reference implementation the exemplar is the artifact. It reaches adopters by being copied
wholesale: `scripts/apply-workflow.sh` recursively copies `patterns_library/` into the target
project. Read it as a template to adapt, not as live code with a call graph.

## Exemplars

The single exemplar is the library file itself, carried in `resource`. Agents are expected to find
it through the Pattern Discovery Protocol rather than by browsing: both `CLAUDE.md` and the
[pattern-discovery](../skills/pattern-discovery.md) skill point at `patterns_library/`, and the
library's own README indexes it under the `api` category.

Because the code has never been compiled or executed inside this repo, its correctness rests on
review rather than on any gate. An adopter should treat the imports and helper names as the
contract to satisfy in their own codebase, not as verified working code.

## Citations

- [patterns_library README](../../../patterns_library/README.md) — the category index.
- [CLAUDE.md](../../../CLAUDE.md) — the Pattern Discovery Protocol that routes agents here.
