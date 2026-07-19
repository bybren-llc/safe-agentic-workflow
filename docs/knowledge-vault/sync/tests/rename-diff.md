---
type: test-suite
title: "Test: Rename-Aware Diff and Status"
description: "Covers file and directory rename resolution, precedence, and rename-aware diff and status output."
tags: [testing, sync, operations]
timestamp: 2026-07-19
status: active
domain: sync
resource: "tests/test-rename-diff.sh"
sources:
  - "scripts/sync-claude-harness.sh"
verified_against: "fd0fc6a"
---

# Test: Rename-Aware Diff and Status

A fork that renames an upstream file must not see it as deleted upstream and re-added locally. This suite pins the
rename mapping layer and the diff and status output that reads it.

## Overview

Eighteen numbered sections and 50 assertions cover `resolve_rename`, `rename_type`,
`get_directory_renames`, `do_diff`, and `do_status` in `scripts/sync-claude-harness.sh`, using the
same wrapper plus mocked-network strategy as its siblings. Test 17 is `bash -n` only; Test 18 shells out to
`tests/test-manifest-loader.sh`, a nested dependency. It runs in CI through
`.github/workflows/test-fork-sync.yml`, and is re-run as a regression gate by the
[substitutions suite](substitutions.md), which asserts it exits 0.

Executed here on macOS it exits 1: 38 pass, 12 fail. All 12 failures are `do_diff` assertions (Tests 7, 9, 10, 11, 15)
and have one cause — `declare -A dir_rename_counts` at line 1560 of the sync script, which bash 3.2 rejects. This is a
macOS portability defect (bash 3.2, BSD tooling), not a broken suite; a GNU/Linux CI runner with bash 4+ may pass all
50. The failing assertion in the substitutions suite is inherited from this one.

## What It Proves

- File renames resolve: `FILE_RENAME` for `agents/ui-engineer.md`, `FILE_RENAME2` for `agents/api-engineer.md`.
- Directory renames apply recursively — `skills/firestore-security/SKILL.md`, `sub/nested.md`, `webhook.md`.
- Precedence is asserted directly: `FILE_WINS` on `skills/custom-skill.md` proves an exact file rename beats an
  overlapping directory rename, while `DIR_APPLIES` proves that directory rename still covers its other files.
- `rename_type` classifies a mapping as file, directory, or none.
- Output is rename-aware: diff prints `agents/ui-engineer.md (upstream: agents/fe-developer.md)`, summaries carry
  per-directory counts such as `(3 files)`, and status prints `Renames:       4` above a mappings block.
- **Does not prove**: any failure behaviour. Weak negatives only — `assert_not_contains` x7 and
  `assert_file_not_exists` x3 that the pre-rename name is never created, plus `PASSTHROUGH`, `NO_MANIFEST`,
  `TYPE_NONE`. No assertion expects a non-zero exit code or an error message.

## Fixtures

- Per-section `mktemp -d` trees; no shared fixture directory.
- A [manifest](../manifest-schema.md) `renames` map supplying file and directory entries, plus one deliberately
  overlapping pair for the precedence case.
- A no-manifest case, used for the `NO_MANIFEST` passthrough assertion.

## Citations

- `tests/test-rename-diff.sh` — the suite itself (SAW-5).
- [SAW-5 QA validation](../../../agent-outputs/qa-validations/SAW-5-qa-validation.md) — acceptance evidence.
- [Harness Manifest Schema](../../../HARNESS_MANIFEST_SCHEMA.md) — the `renames` field.
