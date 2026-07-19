---
type: test-suite
title: "Test Suite: Fork Sync Scenarios"
description: "End-to-end fork simulation over two fixtures; the primary suite gating the sync CI workflow."
tags: [sync, testing, ci]
timestamp: 2026-07-19
status: active
domain: sync
resource: "tests/test-fork-sync.sh"
sources:
  - "tests/fixtures/sync/rendertrust/.harness-manifest.yml"
  - "tests/fixtures/sync/keryk-ai/.harness-manifest.yml"
  - "scripts/sync-claude-harness.sh"
  - ".github/workflows/test-fork-sync.yml"
verified_against: "fd0fc6a"
---

# Test Suite: Fork Sync Scenarios

`tests/test-fork-sync.sh` is the closest thing the sync engine has to a real customer: it builds two
throwaway forks from fixtures, syncs them against a mocked upstream, and asserts the forks survived.
It is the largest sync suite by file size and the first one CI runs.

## Overview

Four sections cover a RenderTrust fork, a rename-heavy Keryk AI fork, invalid-manifest detection,
and a YAML sanity check on the fixture manifests, using six assert helpers. Network access is
stubbed by source rewriting: a `python3` regex turns the real script into `scripts/sync-patched.sh`,
replacing the bodies of `fetch_upstream`, `get_upstream_sha`, `get_latest_release` and
`check_dependencies`. `setup_fork_project` copies the fixture `.claude/` tree, installs the fixture
manifest, and writes a stub `.harness-sync.json`. CI runs it first, then chains five more suites.

## What It Proves

- Renames resolve on a fork that renamed agents and a skill directory — all five rename assertions
  pass, including a deliberate `assert_not_contains` that `fe-developer.md` is never created.
- An invalid manifest is rejected: Section 3.1 strips `identity` entirely and asserts validation
  fails — but only two of the suite's five `assert_exit_code` calls expect non-zero at all.
- Substitution fires — the mock upstream carries `{{PROJECT_NAME}}`, `{{TICKET_PREFIX}}` and
  `{{MAIN_BRANCH}}`, so an unsubstituted file would show.
- **Does not prove** anything about real fetch, release resolution, or dependency checking — all
  four functions are replaced before the run.
- **Proves nothing on a full run today.** It exits 1 without reaching its Results block, so
  nothing downstream of the abort is verified.

## Fixtures

- `tests/fixtures/sync/rendertrust/` — the unrenamed baseline; if absent the suite prints SKIP.
- `tests/fixtures/sync/keryk-ai/` — the rename-heavy fork. Tests up to 2.4 pass against it.
- `tests/fixtures/sync/keryk-ai/.claude/settings.local.json` — **missing**. Test 2.5 `cat`s it
  twice, `cat` errors, `set -e` aborts the suite; this persists with `FORCE_COLOR=0`.
- With `FORCE_COLOR` set, ANSI-wrapped `manifest_count` output cascades 12 more failures from 1.1.

## Citations

- `tests/test-fork-sync.sh` — the suite itself and the source of truth for its assertions.
- [Workflow: Fork Sync Tests](../../operations/workflows/test-fork-sync.md) — the CI job running it.
- [Sync Test Fixtures](../fixtures.md) — what the two fork trees contain.
