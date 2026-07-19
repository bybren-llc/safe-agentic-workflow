---
type: pattern
title: "E2E User Flow Pattern"
description: "Playwright end-to-end test covering a full authenticated user journey."
resource: "patterns_library/testing/e2e-user-flow.md"
tags: [patterns, subsystems, testing]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "patterns_library/README.md"
  - "scripts/apply-workflow.sh"
verified_against: "fd0fc6a"
---

# E2E User Flow Pattern

The reference implementation for a Playwright test that walks a signed-in user through a complete
journey in a real browser, rather than asserting against a handler in isolation.

## Overview

The test is organised as a `test.describe` block whose `beforeEach` signs in through `/sign-in`,
so every case in the group starts authenticated instead of repeating login steps. The `Page`
fixture is typed, which is what makes the flow readable as a sequence of user actions. Reach for
it when the thing at risk is the seam between pages — auth, navigation, form submission, redirect
— and prefer the [API Integration Test Pattern](api-integration-test.md) when the contract under
test belongs to a single route handler.

Its 354-line file follows the library's fixed section order — what it does, when to use it, the
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
library's own README indexes it under the `testing` category. The
[testing-patterns](../skills/testing-patterns.md) skill routes Playwright work to the same place.

An open question travels with it: whether this test was ever run anywhere is unknown, because no
test, fixture, or CI job in this repo references it. Its correctness rests on review, not on a
gate.

## Citations

- [patterns_library README](../../../patterns_library/README.md) — the category index.
- [CLAUDE.md](../../../CLAUDE.md) — the Pattern Discovery Protocol that routes agents here.
