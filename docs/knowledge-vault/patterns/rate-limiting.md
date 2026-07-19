---
type: pattern
title: "Rate Limiting Pattern"
description: "Sliding-window rate limiting with per-user limits, IP fallback, and in-memory or Redis backends."
resource: "patterns_library/security/rate-limiting.md"
tags: [patterns, subsystems, security]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "patterns_library/README.md"
  - "scripts/apply-workflow.sh"
verified_against: "fd0fc6a"
---

# Rate Limiting Pattern

A sliding-window limiter keyed on the authenticated user where there is one and the client IP where
there is not, with two interchangeable backends behind a single configuration shape.

## Overview

A `RateLimitConfig` interface carries `maxRequests`, `windowSeconds`, and `keyPrefix`; the same
config drives either an in-memory counter, correct only on a single instance, or a Redis-backed
counter for distributed deployments. Choosing the in-memory backend behind more than one process is
the mistake this pattern is written to make obvious. Reach for it on authentication routes, on
anything expensive, and on public endpoints. Unlike the `api/` patterns, this file is written
language-agnostically with `{{LANGUAGE}}`, `{{SOURCE_DIR}}`, and `{{EXT}}` placeholders, so adopters
substitute before use.

Its 398-line file follows the library's fixed order: what it does, when to use it, the code
pattern, then per-file supporting sections.

**This pattern is not executed by this repository.** Nothing imports or runs it, and no test,
fixture, or CI job references it. That is by design — the harness *distributes* patterns, and for
a reference implementation the exemplar is the artifact. It reaches adopters wholesale, via
`scripts/apply-workflow.sh` recursively copying `patterns_library/` into the target project.

## Exemplars

- `patterns_library/security/rate-limiting.md` — the reference implementation itself, carried in
  `resource`; no second in-repo instance exists to compare it against.

Discovery is the intended route in: `CLAUDE.md` and the
[pattern-discovery](../skills/pattern-discovery.md) skill point at `patterns_library/`, the
[security-audit](../skills/security-audit.md) skill covers the same ground when auditing routes,
and the library README indexes this file under `security`.

**Open question:** whether this code has ever been compiled or executed anywhere. Nothing in this
repo exercises it, and the placeholders mean it cannot run as written — correctness rests on review.

## Citations

- [patterns_library README](../../../patterns_library/README.md) — the category index.
- [CLAUDE.md](../../../CLAUDE.md) — the Pattern Discovery Protocol that routes agents here.
