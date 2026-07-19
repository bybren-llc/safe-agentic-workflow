---
type: pattern
title: "Input Sanitization Pattern"
description: "Defense-in-depth sanitization against XSS, SQL injection, and path traversal at API boundaries."
resource: "patterns_library/security/input-sanitization.md"
tags: [patterns, subsystems, security]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "patterns_library/README.md"
  - "scripts/apply-workflow.sh"
verified_against: "fd0fc6a"
---

# Input Sanitization Pattern

The reference implementation for handling untrusted input at an API boundary, covering the three
classic injection routes: cross-site scripting, SQL injection, and path traversal.

## Overview

The pattern is defense-in-depth rather than a single filter. It ships an `encodeHtml` utility
built on an entity map for the XSS case, insists on parameterized queries rather than escaped
string interpolation for the SQL case, and gives path-normalization guidance for the traversal
case. It is written language-agnostically, using `{{LANGUAGE}}`, `{{SOURCE_DIR}}`, and `{{EXT}}`
tokens instead of concrete TypeScript. Reach for it at every boundary where external data enters;
it complements schema validation rather than replacing it — a value can be well-typed and still
hostile.

At 262 lines it is one of the more compact files in the library, and it follows the fixed section
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
library's own README indexes it under the `security` category. The
[security-audit](../skills/security-audit.md) skill covers the reviewing side of the same ground.

For security code especially, note the open question: whether this code was ever compiled or
executed anywhere is unknown, since nothing in this repo tests it. Hand-rolled escaping deserves
its own tests in the adopting codebase before it is trusted.

## Citations

- [patterns_library README](../../../patterns_library/README.md) — the category index.
- [CLAUDE.md](../../../CLAUDE.md) — the Pattern Discovery Protocol that routes agents here.
