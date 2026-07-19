---
type: test-suite
title: "Test Suite: Manifest Loader"
description: "Covers manifest parsing, required-field validation, and legacy fallback with no manifest; 24 assertions."
tags: [sync, testing, ci]
timestamp: 2026-07-19
status: active
domain: sync
resource: "tests/test-manifest-loader.sh"
sources:
  - "scripts/sync-claude-harness.sh"
  - ".github/workflows/test-fork-sync.yml"
verified_against: "fd0fc6a"
---

# Test Suite: Manifest Loader

`tests/test-manifest-loader.sh` holds the engine's front door to account: does `load_manifest`
parse what it should, reject what it must, and degrade rather than die when it cannot. Twelve
numbered tests, 24 assertions, the smallest of the nine sync suites.

## Overview

The surface is `load_config`, `load_manifest` and `validate_manifest`, driven through four assert
helpers. At this baseline it reports 24 passed, 0 failed, exit 0 with `FORCE_COLOR=0`, and aborts
early under `FORCE_COLOR=3` like every other suite here. It runs in CI as the second suite in
`.github/workflows/test-fork-sync.yml`, and it doubles as a regression gate: three other suites
re-run it inline as their own late test.

## What It Proves

- Malformed input does not stop a sync: Test 12 encodes the degrade-not-abort contract — invalid
  YAML warns and falls back to legacy behaviour, matching `load_manifest` returning 0 on a parse
  failure. This is a contract, not a bug, and the suite is where it is written down.
- Required-field validation actually rejects: Tests 3, 4, 5 and 6 cover missing required fields,
  an invalid version format, missing identity fields, and a missing `identity` block entirely.
- Backward compatibility holds: Test 1 covers the no-manifest legacy path, Test 9 legacy
  behaviour, Test 8 that empty sections yield zero counts.
- Exclusion covers the metadata itself: Test 11 asserts `is_excluded` matches
  `.harness-manifest.yml`, so a sync cannot overwrite the file describing the sync.
- **Proven asymmetrically.** Failure is established by five `assert_not_contains` checks — the
  absence of expected output — and never by asserting a non-zero exit status. There are zero
  non-zero `assert_exit_code` calls, so "the engine exits correctly on bad input" is not covered.

## Fixtures

- No fixture directory; manifests are written inline per test, which is what keeps it the smallest
  suite and lets it be re-run cheaply as a sub-test elsewhere.
- Re-run as a nested gate inside `tests/test-substitutions.sh` Test 14,
  `tests/test-rename-diff.sh` Test 18 and `tests/test-protected-files.sh` Test 17 — a failure here
  therefore surfaces four times over.

## Citations

- `tests/test-manifest-loader.sh` — the suite and the source of truth for its assertions.
- [Harness Manifest and Schema](../manifest-schema.md) — the contract being loaded and validated.
- [Workflow: Fork Sync Tests](../../operations/workflows/test-fork-sync.md) — the CI job running it.
