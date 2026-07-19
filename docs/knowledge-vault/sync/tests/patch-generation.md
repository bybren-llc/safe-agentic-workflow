---
type: test-suite
title: "Test: Patch Generation Mode"
description: "Covers --generate-patches output, rename and substitution awareness, and git apply --check validity."
tags: [testing, sync, operations]
timestamp: 2026-07-19
status: active
domain: sync
resource: "tests/test-patch-generation.sh"
sources:
  - "scripts/sync-claude-harness.sh"
verified_against: "fd0fc6a"
---

# Test: Patch Generation Mode

Guards the review-first path through the [sync engine](../harness-sync-engine.md): instead of
writing files, `--generate-patches` emits diffs a human reads before anything lands. A patch that
will not apply is worse than no patch, so applicability is the claim this suite exists to defend.

## Overview

Seventeen numbered sections and 50 assertions cover `generate_patch` and `generate_apply_order`,
including the flattened patch filename (`/` replaced by `__`) and the emitted `APPLY_ORDER.md`.
The header states a two-tier strategy: unit tests source sync functions through a wrapper that
strips the main entry point, while integration tests run a mocked copy of the script with
`fetch_upstream` and `get_upstream_sha` stubbed, so no network is touched. It runs in no workflow
— `.github/workflows/test-fork-sync.yml` invokes six of the nine suites and not this one.

Executed here it exits 0 with 50 pass, 0 fail, even on macOS bash 3.2: it never calls `do_diff`, so it sidesteps the
`declare -A` bash 4 requirement that fails the rename-diff and protected-files suites on that shell.

## What It Proves

- Generated patches are actually applicable: the file's single `assert_exit_code` expects 0 from
  `git apply --check` on a generated patch. This is the load-bearing assertion.
- Patch mode reports itself honestly — a `Generating Patches` header, a `patch(es)` count line, and
  `Patch (NEW)` / `Patch (UPD)` labels distinguishing creations from updates.
- Protection is honoured in patch mode too, not only in write mode: `Skipping protected` appears
  for files covered by [protected-file rules](protected-files.md).
- Patches are rename-aware and substitution-aware, so emitted diffs target local paths and local
  token values rather than raw upstream text.
- A no-difference run reports `0 patch(es)` — the closest thing here to a negative case.
- **Does not prove**: any failure behaviour. No assertion expects a non-zero exit, a rejected
  patch, or an aborted run; the malformed-patch and unwritable-output-directory paths are
  uncovered.

## Fixtures

- Per-run `mktemp -d` trees seeded inline; no shared fixture directory is used.
- A mocked copy of `scripts/sync-claude-harness.sh` with the two fetch functions stubbed stands in
  for the upstream remote.
- The wrapper that strips the main entry point is what makes the sync functions sourceable.

## Citations

- `tests/test-patch-generation.sh` — the suite itself (SAW-4).
- [Harness Sync Guide](../../../HARNESS_SYNC_GUIDE.md) — patch mode from the operator's side.
