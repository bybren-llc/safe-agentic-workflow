---
type: pattern
title: "Deployment Pipeline Pattern"
description: "Staging-then-production deployment with smoke tests, a manual approval gate, and a rollback path."
resource: "patterns_library/ci/deployment-pipeline.md"
tags: [patterns, subsystems, ci]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "patterns_library/README.md"
  - "scripts/apply-workflow.sh"
verified_against: "fd0fc6a"
---

# Deployment Pipeline Pattern

The reference implementation for shipping a change: deploy to staging, prove it with smoke tests,
hold at a human approval gate, then promote to production with a documented way back.

## Overview

The deploy workflow triggers on push to `[{{MAIN_BRANCH}}]` and also on `workflow_dispatch` with a
required environment input, so the same definition serves both automatic promotion and a
deliberate operator-driven deploy. The rollback path is documented as zero-downtime, which is the
part worth reading before an incident rather than during one. Reach for it when an application has
more than one environment and a real production audience; a single-environment side project pays
the ceremony without getting the safety.

Its 451-line file follows the library's fixed section order — what it does, when to use it, the
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
library's own README indexes it under the `ci` category. Its CI-side sibling is the
[GitHub Actions CI Workflow Pattern](github-actions-workflow.md), which gates what this one ships.

An open question travels with it: whether this workflow was ever run anywhere is unknown, because
no test, fixture, or CI job in this repo references it. Note that `{{MAIN_BRANCH}}` is a template
token, not a branch name — an adopter must substitute it before the workflow will trigger at all.

## Citations

- [patterns_library README](../../../patterns_library/README.md) — the category index.
- [CLAUDE.md](../../../CLAUDE.md) — the Pattern Discovery Protocol that routes agents here.
