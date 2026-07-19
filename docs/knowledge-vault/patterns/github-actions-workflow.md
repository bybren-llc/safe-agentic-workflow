---
type: pattern
title: "GitHub Actions CI Workflow Pattern"
description: "Standard CI workflow with lint, type-check, test, and build gates plus matrix and caching."
resource: "patterns_library/ci/github-actions-workflow.md"
tags: [patterns, subsystems, ci]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "patterns_library/README.md"
  - "scripts/apply-workflow.sh"
verified_against: "fd0fc6a"
---

# GitHub Actions CI Workflow Pattern

The reference implementation for a pull-request CI workflow: lint, type-check, test, and build as
explicit gates, with matrix runtimes, dependency caching, and artifact upload.

## Overview

The workflow triggers on `pull_request` and on push against `[{{MAIN_BRANCH}}]`, and carries a
`concurrency` block that cancels in-progress runs — the detail that keeps a rapid push sequence
from burning minutes on results nobody will read. Beyond the four gates it covers running the
matrix across runtime versions, caching dependencies between runs, and uploading build artifacts
for later jobs. Reach for it when standing up CI on a new repository; an existing pipeline should
be compared against it rather than replaced by it.

Its 344-line file follows the library's fixed section order — what it does, when to use it, the
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
library's own README indexes it under the `ci` category. Its downstream sibling is the
[Deployment Pipeline Pattern](deployment-pipeline.md), which ships what these gates approve.

An open question travels with it: whether this workflow was ever run anywhere is unknown, because
nothing in this repo references it. `{{MAIN_BRANCH}}` is a template token, not a branch name, and
must be substituted before the workflow will trigger.

## Citations

- [patterns_library README](../../../patterns_library/README.md) — the category index.
- [CLAUDE.md](../../../CLAUDE.md) — the Pattern Discovery Protocol that routes agents here.
