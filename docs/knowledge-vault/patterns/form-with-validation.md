---
type: pattern
title: "Form with Validation Pattern"
description: "Client form built from React Hook Form, Zod resolver, and shadcn/ui form primitives."
resource: "patterns_library/ui/form-with-validation.md"
tags: [patterns, subsystems]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "patterns_library/README.md"
  - "scripts/apply-workflow.sh"
verified_against: "fd0fc6a"
---

# Form with Validation Pattern

The reference implementation for a data-entry form: one Zod schema drives both the field types and
the error messages, with React Hook Form managing state and shadcn/ui rendering the controls.

## Overview

The component is marked `'use client'` and wires `zodResolver` from `@hookform/resolvers/zod` into
`useForm`, so the schema is the only place validation rules are written — the same schema shape
the server route should re-validate against, since client validation is ergonomics, not a
boundary. It imports the shadcn `Form` component family for field composition and `useRouter` for
post-submit navigation. Reach for it for any form beyond a single search box.

At 570 lines it is the largest file in the library, and it follows the fixed section order: what
it does, when to use it, the code pattern, then per-file supporting sections. Because of that
size, read it in the source rather than expecting a summary to substitute.

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
[frontend-patterns](../skills/frontend-patterns.md) skill routes form work to the same place.

An open question travels with it: whether this code was ever compiled or executed anywhere is
unknown, because no test, fixture, or CI job in this repo references it.

## Citations

- [patterns_library README](../../../patterns_library/README.md) — the category index.
- [CLAUDE.md](../../../CLAUDE.md) — the Pattern Discovery Protocol that routes agents here.
