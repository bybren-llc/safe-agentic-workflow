---
type: architecture
title: "Pattern Library"
description: "Eighteen reference-implementation patterns in seven categories, distributed to adopters, not run here."
tags: [subsystems, patterns, process]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "patterns_library/README.md"
  - "scripts/apply-workflow.sh"
  - "agent_providers/claude_code/hooks/session-start-pattern-check.sh"
  - "docs/patterns/README.md"
  - "CLAUDE.md"
verified_against: "fd0fc6a"
---

# Pattern Library

Eighteen markdown exemplars in seven category directories — documentation, not code. Nothing in
this repo imports, sources, or executes them; the exemplar *is* the artifact.

## Overview

The library exists so "Search First, Reuse Always" has somewhere to search. Distribution is by copy:
`scripts/apply-workflow.sh` lines 89-91 `cp -r` the whole tree into an adopter repo alongside
`specs_templates` and `linting_configs`. Consumption is by reading — `CLAUDE.md`'s Pattern Discovery
Protocol makes searching it step 1 before any feature, and the
[Pattern Discovery](../skills/pattern-discovery.md) skill plus seven agent prompts route there. Per
`README.md`, BSA and System Architect may add patterns; execution agents consume and report gaps.

## Design

| Category | Count | Examples |
| --- | --- | --- |
| api | 4 | user-context, admin-context, webhook-handler, zod-validation |
| ui | 3 | authenticated-page, form-with-validation, data-table |
| security | 3 | input-sanitization, rate-limiting, secrets-management |
| database, testing, ci, config | 2 each | rls-migration, e2e-user-flow, deployment-pipeline |

Two dialects coexist: eight files are concrete Next.js / Clerk / Prisma / Zod TypeScript, while six
newer ones — input-sanitization, rate-limiting, secrets-management, environment-config,
structured-logging and deployment-pipeline — use `{{LANGUAGE}}` and `{{SOURCE_DIR}}` placeholders.

DOC DRIFT, twice. The only executable mentioning the library, `session-start-pattern-check.sh`,
sets `PATTERN_DIR=docs/patterns` and counts `*.md` there; that directory holds one redirect README,
so the hook reports "Available patterns: 1" and advertises subdirectories that do not exist. The
counts disagree too: `patterns/README.md` says 11, `docs/patterns/README.md` says 18+, and
`patterns_library/README.md` says 18. Eighteen is the listed truth.

## Related Concepts

- [Pattern Discovery Protocol](../methodology/pattern-discovery-protocol.md) — the search-first norm.
- [Session Start Pattern Check](../providers/hooks/session-start-pattern-check.md) — drifting hook.

## Citations

- [patterns_library/README.md](../../../patterns_library/README.md) — index and governance rules.
