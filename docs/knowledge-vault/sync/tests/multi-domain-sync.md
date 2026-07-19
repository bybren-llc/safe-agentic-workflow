---
type: test-suite
title: "Test: Multi-Domain Sync"
description: "Covers sync_scope parsing, root-relative paths, cross-domain protection and renames, and migration."
tags: [testing, sync, operations]
timestamp: 2026-07-19
status: active
domain: sync
resource: "tests/test-multi-domain-sync.sh"
sources:
  - "scripts/sync-claude-harness.sh"
  - ".harness-manifest.yml"
verified_against: "fd0fc6a"
---

# Test: Multi-Domain Sync

The suite holding the harness to its promise that one run can serve `.claude`, `.gemini`, `.codex`,
`.cursor`, `.agents`, and `dark-factory` at once without leaking rules across the boundary.

## Overview

Fourteen numbered sections and 43 assertions exercise [scope parsing](../sync-scope.md), root-relative path
resolution, per-domain protection and rename lookup, and legacy metadata migration, against functions sourced from
`scripts/sync-claude-harness.sh` into throwaway `mktemp -d` trees. It is the only suite using `#!/usr/bin/env bash`
with `set -euo pipefail`; the other eight use `#!/bin/bash` and `set -e`. **It runs in no workflow** —
`.github/workflows/test-fork-sync.yml` invokes six of the nine suites and not this one, so it is manual-only.

## What It Proves

- All six allowed domains parse out of `sync_scope`, and an unknown domain is dropped rather than
  fatal — `SCOPE:.claude .gemini` keeps the valid pair.
- Two failure paths are proven by sentinel string: `BLOCKED:manifest required` for a run with no
  manifest, and `Ignoring unknown sync domain` for a rejected domain.
- Protection is domain-scoped: `PROTECTED:gemini-settings` and `PROTECTED:claude-hooks` hold while
  `NOT_PROTECTED:gemini-commands` proves patterns do not bleed sideways.
- Renames resolve root-relative across domains, including a directory rename reaching
  `.gemini/skills/payment-patterns/webhook.md`, with `NO_RENAME` for unmapped paths.
- `compare_file_with_paths` honours `DOMAIN_TMP`/`DOMAIN_DIR` (MODIFIED, UNCHANGED, NEW), both domains share one
  `SYNC_TIMESTAMP`, and `validate_protected_paths` reports "does not match" for a `.gemini` typo pattern.
- **Does not prove**: anything at all on macOS. `make_sourceable` at line 68 of the suite strips the case dispatch
  with `head -n -3`, a GNU-only negative line count; BSD `head` answers `head: illegal line count -- -3`, and under
  `set -euo pipefail` the run dies inside Test 1, so ZERO of the 14 tests execute. Every claim above is read off the
  source, not off a passing run. This is an environment defect in the test harness, not in `sync_scope`; whether the
  suite passes on a GNU-coreutils Linux runner is UNKNOWN and not verifiable here. Even when it runs, its 43
  assertions include a single `assert_not_contains` and no `assert_exit_code` helper — a positive-path suite.

## Fixtures

- Per-section `mktemp -d` trees built inline; there is no shared fixture directory.
- A v1.1 [manifest](../manifest-schema.md) fixture drives `ROOT_PATHS:true`; a legacy `.claude/`
  metadata layout drives the `MIGRATE` assertion.
- `tests/fixtures/sync/` belongs to the fork-sync suite, not this one.

## Citations

- `tests/test-multi-domain-sync.sh` — the suite itself (SAW-37).
- [Harness Sync Guide](../../../HARNESS_SYNC_GUIDE.md) — operator-facing sync behaviour.
