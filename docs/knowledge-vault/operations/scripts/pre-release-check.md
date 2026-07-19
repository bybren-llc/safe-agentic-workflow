---
type: script
title: "pre-release-check.sh"
description: "Automates the pre-release checklist across code quality, docs, template compatibility, compatibility, and git state."
tags: [operations, release, ci, gates]
timestamp: 2026-07-19
status: active
domain: operations
resource: "scripts/pre-release-check.sh"
sources:
  - "scripts/pre-release-check.sh"
  - "docs/release/PRE-RELEASE-CHECKLIST.md"
  - "scripts/sync-claude-harness.sh"
verified_against: "fd0fc6a"
---

# pre-release-check.sh

Runs the release checklist as code and decides whether a release is blocked. 209 lines of bash under
`set -euo pipefail`; it `cd`s to `PROJECT_ROOT` first, so it evaluates the repo and not the cwd no
matter where it is called from.

## Overview

It mechanizes [Pre-Release Checklist](../release/pre-release-checklist.md) in five numbered
sections: Code Quality Gates, Documentation Completeness, Template Compatibility, Backward
Compatibility, and Git State. Every assertion routes through one of three counters — `check_pass`,
`check_fail`, `check_warn` — and only fails block. Section 1 syntax-checks
`scripts/sync-claude-harness.sh` with `bash -n`, greps `*.sh *.md *.json *.toml *.yml *.mdc` for
`<<<<<<` conflict markers (excluding `node_modules`, `.git`, and the checklist docs themselves, so
the gate cannot trip on its own text), then **executes** every `tests/test-*.sh`. Section 3 requires
`scripts/setup-template.sh` to exist; section 4 checks `.harness-manifest.schema.json` and the
`examples/manifests` entries, all as warnings only.

## Inputs & Outputs

- **In** `[version]` — optional positional; defaults to the literal `UNSET` and is only echoed,
  never validated.
- **Out** stdout — per-check PASS / FAIL / WARN lines plus a final verdict banner.
- **Exit** `1` — any FAIL, printed as `RELEASE BLOCKED` (verified at lines 200-202).
- **Exit** `0` — `RELEASE READY WITH WARNINGS` or `ALL CHECKS PASSED`. Warnings never block; section
  5 fails only when the branch is not `main`, warning on a dirty tree and surviving feature branches.
- **Caveat** the suites really are run — line 67 is `timeout 120 bash "$test_file"` — but a suite
  counts as passing **only** if its output matches `grep -q 'ALL.*PASS'`, so one that aborts early
  is reported FAILED rather than errored.
- **Caveat — portability defect, not a missing gate** the loop depends on `timeout` and parses
  counts with `grep -oP`; neither ships with stock macOS (`grep: invalid option -- P`). There every
  suite emits `timeout: command not found`, nothing matches the `ALL...PASS` marker, and **every**
  suite is reported FAILED. The gate over-blocks rather than under-blocks: fail-safe, but broken.

## Invoked By

- Manual, by the release driver before cutting a tag — see [Release Process](../release/release-process.md).
- Not wired into any GitHub Actions workflow at this baseline.

## Citations

- [Pre-Release Checklist](../release/pre-release-checklist.md) — the human checklist this automates.
