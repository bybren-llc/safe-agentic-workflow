---
type: test-suite
title: "Test: Protected File Enforcement"
description: "Covers manifest and .sync-exclude protection merging, glob matching, de-duplication, and skip reporting."
tags: [testing, sync, operations]
timestamp: 2026-07-19
status: active
domain: sync
resource: "tests/test-protected-files.sh"
sources:
  - "scripts/sync-claude-harness.sh"
verified_against: "fd0fc6a"
---

# Test: Protected File Enforcement

Protection is what stops an upstream sync from overwriting a fork's local customisations. The largest sync suite by
assertion count — 19 sections, 54 executed — and the one testing both polarities: protected and not.

## Overview

It covers `get_protected_patterns`, `is_protected`, `is_manifest_protected`, `is_excluded`, and
`validate_protected_paths` in `scripts/sync-claude-harness.sh`, using the same wrapper plus mocked-network strategy as
its siblings. It runs in CI through `.github/workflows/test-fork-sync.yml`, whose path filter does not list
`tests/test-protected-files.sh`, so a change to this suite alone will not trigger the job. Test 16 is `bash -n` only;
Test 17 shells out to `tests/test-manifest-loader.sh`, so a loader failure fails this suite too.

Executed here on macOS it exits 1: 48 pass, 6 fail. All six are `do_diff` assertions expecting `PROTECTED`/`EXCLUDED`
labels — five in Test 7, one in Test 12; Test 8 passes. All six trace to `declare -A dir_rename_counts` at line 1560
of the sync script, which bash 3.2 rejects. The assertions encode a real product requirement and the product is
genuinely broken on that shell — but this is macOS portability; GNU/Linux CI with bash 4+ may pass all 54.

## What It Proves

- Positive matches hold: `PROTECTED_CLAUDE`, `PROTECTED_SETTINGS`, and `PROTECTED_HOOKS` all yes.
- Negatives are as deliberate: `PROTECTED_SYSARCH`, `GLOB_NOMATCH`, `MERGED_NONE`, `LEGACY_NOEXCL` all `no`.
- Glob semantics are real: `agents/custom-*.md` matches `custom-agent.md` and `custom-devops.md`, not others.
- Two sources merge into one pattern set — manifest `protected[]` and `.claude/.sync-exclude` — with
  `MERGED_MANIFEST`, `MERGED_SYNCEXCL`, and `MERGED_BOTH` all yes; `settings.local.json` in both yields
  `DEDUP_COUNT: 1`.
- Reporting is verified end to end — diff renders `PROTECTED  settings.local.json`, sync emits
  `Skipping protected: CLAUDE.md`, and a stale pattern warns that it matches no local file.
- **Does not prove**: that a protected collision aborts a sync. Partial negatives only — Test 9 asserts protected
  files stay byte-identical after a real `do_sync`, Test 11 the stale-pattern warning; the rest are positive. The
  substring fallback in `is_protected` is never asserted, and the manifest's `replaced` section is not tested at all —
  which is why its total non-enforcement is invisible here.

## Fixtures

- Per-section `mktemp -d` trees with inline `agents/` files driving the glob cases.
- A manifest `protected[]` list and a `.claude/.sync-exclude` file, both needed for merge and de-duplication.
- Two intentionally absent paths — `nonexistent-file.json` and `missing-dir/config.yml` — back the stale warning.

## Citations

- `tests/test-protected-files.sh` — the suite itself (SAW-3).
- [SAW-3 QA validation](../../../agent-outputs/qa-validations/SAW-3-qa-validation.md) — acceptance evidence.
- [Harness Manifest Schema](../../../HARNESS_MANIFEST_SCHEMA.md) — the `protected` field.
