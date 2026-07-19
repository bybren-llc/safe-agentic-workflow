---
type: pattern
title: "Data Table Pattern"
description: "Server-rendered sortable, filterable table built on shadcn/ui Table with row action menus."
resource: "patterns_library/ui/data-table.md"
tags: [patterns, subsystems]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "patterns_library/README.md"
  - "scripts/apply-workflow.sh"
verified_against: "fd0fc6a"
---

# Data Table Pattern

The reference implementation for a listing view: a shadcn/ui table with sorting, filtering, row
action menus, and pagination done on the server rather than in the browser.

## Overview

The pattern imports the shadcn `Table` component family alongside `Button`, `Badge`, and
`DropdownMenu`, composing them into a single listing surface instead of pulling in a table
library. Per the library index, pagination is server-side — the page fetches only the rows it
renders, which is what keeps the pattern usable past a few hundred records. Reach for it whenever
a screen shows a collection with per-row operations; reach for a plain list when there are no
columns to sort and no actions to hang off a row.

At 513 lines it is one of the larger files in the library, and it follows the fixed section
order: what it does, when to use it, the code pattern, then per-file supporting sections.

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
[frontend-patterns](../skills/frontend-patterns.md) skill routes component work to the same place.

An open question travels with it: whether this code was ever compiled or executed anywhere is
unknown, because no test, fixture, or CI job in this repo references it. Its correctness rests on
review, not on a gate.

## Citations

- [patterns_library README](../../../patterns_library/README.md) — the category index.
- [CLAUDE.md](../../../CLAUDE.md) — the Pattern Discovery Protocol that routes agents here.
