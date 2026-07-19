---
type: pattern
title: "Environment Configuration Pattern"
description: "Typed, schema-validated environment configuration validated once at application startup."
resource: "patterns_library/config/environment-config.md"
tags: [patterns, subsystems]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "patterns_library/README.md"
  - "scripts/apply-workflow.sh"
verified_against: "fd0fc6a"
---

# Environment Configuration Pattern

The reference implementation for reading configuration: parse the environment against a schema
once at startup, hand typed values to the rest of the app, and fail loudly if anything is missing.

## Overview

The pattern declares the schema file the single source of truth for configuration — every key the
application depends on is named in one place, so a missing variable surfaces as a startup error
rather than an undefined value three layers deep. It is written language-agnostically, using
`{{LANGUAGE}}`, `{{SOURCE_DIR}}`, and `{{EXT}}` tokens, and names Zod and Pydantic as
interchangeable validation libraries. Reach for it in any service with more than a couple of
settings; skip it for a script whose entire configuration is one variable.

Its 421-line file follows the library's fixed section order — what it does, when to use it, the
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
library's own README indexes it under the `config` category.

Two things constrain an adopter. The template tokens must be substituted before any of it runs,
and whether this code was ever compiled or executed anywhere is unknown — no test, fixture, or CI
job in this repo references it, so its correctness rests on review rather than on a gate.

## Citations

- [patterns_library README](../../../patterns_library/README.md) — the category index.
- [CLAUDE.md](../../../CLAUDE.md) — the Pattern Discovery Protocol that routes agents here.
