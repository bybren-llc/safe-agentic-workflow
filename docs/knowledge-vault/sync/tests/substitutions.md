---
type: test-suite
title: "Test: Placeholder Substitution Engine"
description: "Covers token replacement, longest-match ordering, non-manifest token preservation, and escaping."
tags: [testing, sync, operations]
timestamp: 2026-07-19
status: active
domain: sync
resource: "tests/test-substitutions.sh"
sources:
  - "scripts/sync-claude-harness.sh"
verified_against: "fd0fc6a"
---

# Test: Placeholder Substitution Engine

Substitution is where a generic upstream template becomes this fork's files. Too little leaves `{{PROJECT_NAME}}` in
shipped docs; too much mangles Mustache templates the sync engine was never meant to touch. This suite pins both edges.

## Overview

Fifteen numbered sections cover `apply_substitutions` in `scripts/sync-claude-harness.sh`, using the same wrapper plus
mocked-network strategy as its siblings. It runs in CI through `.github/workflows/test-fork-sync.yml`. It is also the
only suite that invokes other suites: its three `assert_exit_code` calls all expect 0, from a `bash -n` syntax check
of the sync script and from re-running the manifest-loader and [rename-diff](rename-diff.md) suites as gates.

Executed here on macOS it exits 1, aborting inside Test 14 "Existing tests still pass": the loader suite passes, then
[rename-diff](rename-diff.md) fails on bash 3.2 and `set -e` kills the run before Test 15 and before any summary, so
no pass/fail totals are printed at all. The failure is inherited from that suite's macOS portability defect (bash 3.2),
not from any substitution bug; on a GNU/Linux runner with bash 4+ the nested gate may pass and this suite complete.

## What It Proves

- Identity-derived and explicit substitutions both apply — `{{PROJECT_NAME}}`, `{{TICKET_PREFIX}}`, `{{GITHUB_ORG}}`,
  `{{PROJECT_REPO}}`, `{{PROJECT_SHORT}}`.
- Ordering is longest-match-first: `{{GITHUB_REPO_URL}}` resolves whole while `{{GITHUB_ORG}}` still works alone.
- Tokens absent from the manifest survive untouched — `{{UNKNOWN_PLACEHOLDER}}`, Mustache `{{#items}}`/`{{/items}}`.
- Literal, unbraced substitutions replace bare strings: `SAW-123` becomes `MYP-123`, `[SAW-XXX]` becomes `[MYP-XXX]`.
- `sed` escaping survives URLs with `~`, emails with `@`, and names with dots and dashes.
- Opt-out and edges hold: `--no-placeholders` reports `Skipping placeholder substitutions`, an empty `substitutions{}`
  still applies identity values, a missing file returns `EXIT_OK`, and `apply_all_substitutions` filters extensions.
- **Does not prove**: any non-zero exit. The one failure path covered — a manifest-less sync
  emitting `No manifest found` and pointing at `manifest init` — is asserted on strings, not code. Nor does it check
  that `sync.auto_substitute` is honoured, which is why that key going entirely unread is invisible here.

## Fixtures

- Per-section `mktemp -d` trees with inline files carrying manifest and non-manifest tokens.
- A [manifest](../manifest-schema.md) supplying identity fields plus an explicit `substitutions` map, and a variant
  with that map empty.
- `tests/test-manifest-loader.sh` and `tests/test-rename-diff.sh` act as fixtures: if either is missing, renamed, or
  failing, this suite's regression gates break.

## Citations

- `tests/test-substitutions.sh` — the suite itself (SAW-10).
- [SAW-10 QA validation](../../../agent-outputs/qa-validations/SAW-10-qa-validation.md) — acceptance evidence.
- [Harness Manifest Schema](../../../HARNESS_MANIFEST_SCHEMA.md) — identity and `substitutions`.
