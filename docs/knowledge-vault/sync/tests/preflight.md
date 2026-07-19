---
type: test-suite
title: "Test: Preflight Safety Check"
description: "Covers preflight scope, protected, and unreplaced-token violations plus provenance recording."
tags: [testing, sync, operations, gates]
timestamp: 2026-07-19
status: active
domain: sync
resource: "tests/test-preflight.sh"
sources:
  - "scripts/sync-claude-harness.sh"
verified_against: "fd0fc6a"
---

# Test: Preflight Safety Check

Preflight is the gate that refuses a sync before it writes anything, and this is the suite that
proves the gate can say no. Of the nine sync suites it has by far the strongest negative coverage:
five distinct violation cases, each asserted to fail.

## Overview

Eighteen numbered sections and 45 assertions exercise `run_preflight` and
`scan_unreplaced_tokens` in `scripts/sync-claude-harness.sh`, using the same two-tier strategy as
its siblings — a function-sourcing wrapper for units, a mocked script with stubbed network calls
for integration. It runs in CI: `.github/workflows/test-fork-sync.yml` invokes it after the
fork-sync suite. Note the workflow's path filter does not include `tests/test-preflight.sh`, so
editing this suite alone does not trigger the job that runs it. Executed here it exits 0 with 45 pass, 0 fail, even
on macOS bash 3.2 — it never calls `do_diff`, so it never hits the `declare -A` bash 4 defect.

## What It Proves

- Preflight fails on scope violations of both shapes — relative path traversal and an absolute
  path — each asserting `PREFLIGHT_RESULT: fail`.
- It fails on a protected-file collision, and on an unreplaced placeholder token.
- Multiple violations surface together: one case asserts `Scope violation` and
  `Protected file violation` both appear in a single report.
- Token scanning is precise to the line: `dirty.md:1: unreplaced token {{PROJECT_NAME}}`, then
  `:2: {{GITHUB_ORG}}` and `:4: {{TICKET_PREFIX}}`.
- No false positives — `SCAN_RESULT` is clean for a clean file and for `{{...}}` tokens absent
  from the manifest.
- Bypasses are loud, not silent: `--skip-preflight` logs `Preflight check SKIPPED`, and
  `--no-placeholders` suppresses only the token check while preflight still passes.
- **Does not prove**: that the sync process exits non-zero on violation. Failure is asserted
  through the `PREFLIGHT_RESULT` sentinel and human-readable error strings, never an exit code.

## Fixtures

- Per-section `mktemp -d` trees, including a deliberately dirty file carrying three tokens.
- An empty sync plan, used to assert `PREFLIGHT_RESULT: pass` on the trivial case.
- Help-text assertions depend on `--skip-preflight`, `PREFLIGHT`, and `PROVENANCE` remaining
  present in the script's usage output.

## Citations

- `tests/test-preflight.sh` — the suite itself (SAW-2).
- [SAW-2 QA validation](../../../agent-outputs/qa-validations/SAW-2-qa-validation.md) — acceptance evidence.
- [Harness Sync Guide](../../../HARNESS_SYNC_GUIDE.md) — preflight and provenance behaviour.
