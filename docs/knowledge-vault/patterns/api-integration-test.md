---
type: pattern
title: "API Integration Test Pattern"
description: "Jest integration test for route handlers with mocked Clerk auth and database, asserting RLS behaviour."
resource: "patterns_library/testing/api-integration-test.md"
tags: [patterns, subsystems, testing]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "patterns_library/README.md"
  - "scripts/apply-workflow.sh"
verified_against: "fd0fc6a"
---

# API Integration Test Pattern

The reference implementation for testing an API route end-to-end inside Jest: mock the auth
provider, mock the database, invoke the handler, and assert that row-level security held.

## Overview

The pattern imports its harness from `@jest/globals` and stubs identity with a `jest.mock` of
`@clerk/nextjs/server`, so the handler under test sees a controlled user without a live session.
Requests are built by constructing `NextRequest` objects directly rather than spinning up a
server, which keeps the test at the route-handler boundary. Reach for it when a route's contract
includes an RLS guarantee that a pure unit test cannot demonstrate; reach for a Playwright test
instead when the thing under test is a user journey rather than a handler.

Its 341-line file follows the library's fixed section order — what it does, when to use it, the
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
[testing-patterns](../skills/testing-patterns.md) skill routes test-authoring work here on its
`.agents` surface only — its `.claude` copy names no `patterns_library` path at all.

An open question travels with it: whether this code was ever compiled or executed anywhere is
unknown, because no test, fixture, or CI job in this repo references it. Its correctness rests on
review, not on a gate. Treat the imports and helper names as the contract to satisfy in your own
codebase.

## Citations

- [patterns_library README](../../../patterns_library/README.md) — the category index.
- [CLAUDE.md](../../../CLAUDE.md) — the Pattern Discovery Protocol that routes agents here.
