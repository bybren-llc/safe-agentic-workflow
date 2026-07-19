---
type: integration
title: "Fork Sync Compatibility Workflow (test-fork-sync.yml)"
description: "Path-filtered workflow running the fork-sync and sync unit test suites against fixture manifests."
resource: ".github/workflows/test-fork-sync.yml"
tags: [operations, ci, gates, testing, sync]
timestamp: 2026-07-19
status: active
domain: operations
sources:
  - ".github/workflows/test-fork-sync.yml"
  - "tests/test-fork-sync.sh"
  - "tests/test-manifest-loader.sh"
  - "tests/test-rename-diff.sh"
  - "tests/test-substitutions.sh"
  - "tests/test-protected-files.sh"
  - "tests/test-preflight.sh"
verified_against: "fd0fc6a"
---

# Fork Sync Compatibility Workflow (test-fork-sync.yml)

The only workflow here that runs real test suites, exercising the sync engine in `--dry-run` against
fork fixtures. A path filter narrows its reach: a PR touching only `.claude/` or `docs/` triggers no
*test* workflow — `pr-validation.yml` has no path filter, so its rebase check still gates that PR.

## Overview

One job, `fork-sync-compat`, `ubuntu-latest`, `timeout-minutes: 10`. Triggered by push and pull
request to `main`, filtered to `scripts/sync-claude-harness.sh`, `.harness-manifest.schema.json`,
`tests/fixtures/sync/**`, `tests/test-fork-sync.sh`, and itself: it guards the
[Harness Sync Engine](../../sync/harness-sync-engine.md) and nothing else.

## Touchpoints

| Touchpoint | Direction | Artifact |
| --- | --- | --- |
| Path-filtered push and PR trigger | inbound | `.github/workflows/test-fork-sync.yml` |
| Toolchain setup | outbound | `actions/checkout@v4`, `actions/setup-node@v4`, `actions/setup-python@v5` |
| Fork-sync suite | outbound | `bash tests/test-fork-sync.sh` |
| Combined unit suites, each with `\|\| exit 1` | outbound | five `tests/test-*.sh` scripts |

## Configuration

- Node 20 via `setup-node`; Python 3.11 via `setup-python`. No secrets.
- `pip install pyyaml` — the one external dependency; manifest parsing fails without it.
- Fixtures live under `tests/fixtures/sync/`; the header names `rendertrust` and `keryk-ai`.

## Failure Modes & Health

- **Path filter miss** — changes outside the filter go untested, though [PR Validation](pr-validation.md) runs.
- The 10-minute timeout and a missing `pyyaml` both fail the job; suites chain with `|| exit 1`.
- Never invoked here: `test-manifest-init.sh`, `test-multi-domain-sync.sh`, `test-patch-generation.sh`.
- **UNKNOWN**: whether these are required status checks; branch protection is not declared in-repo.

## Citations

- [CI/CD Pipeline Guide](../../../ci-cd/CI-CD-Pipeline-Guide.md) — branch protection as manual step.
