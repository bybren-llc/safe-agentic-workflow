---
type: test-suite
title: "Test Suite: Manifest Init"
description: "Covers manifest generation from team-config, tokens, and .sync-exclude; 52 assertions, all passing."
tags: [sync, testing]
timestamp: 2026-07-19
status: active
domain: sync
resource: "tests/test-manifest-init.sh"
sources:
  - "scripts/sync-claude-harness.sh"
  - ".harness-manifest.schema.json"
verified_against: "fd0fc6a"
---

# Test Suite: Manifest Init

`tests/test-manifest-init.sh` covers the one command a fork runs before it ever syncs: generating
a `.harness-manifest.yml` from the project's own `team-config.json`. Fourteen numbered tests, 52
assertions, and the only place in the repository where the JSON Schema is genuinely applied.

## Overview

The surface under test is the `manifest` subcommand — dry run, `--yes` write, derived values,
`.sync-exclude` ingestion, MCP server detection, and the help text — exercised through five assert
helpers. At this baseline the suite reports 52 passed, 0 failed, exit 0, but only with
`FORCE_COLOR` unset or 0; under `FORCE_COLOR=3` it aborts early on the ANSI-wrapped number bug in
`manifest_count`. No `.github/workflows` file references it, so despite being the healthiest suite
in the sync set it gates nothing.

## What It Proves

- Generation is idempotent-safe: Test 8 proves the command refuses to clobber an existing
  manifest, one of four deliberate non-zero exit assertions.
- Bad inputs are detected rather than papered over: Test 4 rejects an unreplaced template
  `team-config.json`, Test 5 handles its absence, Test 9 handles validating a manifest that is not
  there — two `assert_file_not_exists` checks confirm nothing was written in those paths.
- The generated manifest is schema-valid: Test 7 applies `.harness-manifest.schema.json` as an
  actual schema. This is the sole runtime application of that file anywhere in the repo.
- Population is real, not just structural: Tests 3, 6, 11, 12, 13 and 14 assert `.sync-exclude`
  patterns become protected entries, substitutions and sync preferences are filled, derived values
  computed, a partial `team-config.json` still works, and MCP server names are detected.
- **Does not prove** that any of the emitted `sync.*` keys are honoured — `auto_substitute`,
  `backup` and `substitution_extensions` are written here and read nowhere by the engine.
- **Does not gate anything**, since no workflow invokes it.

## Fixtures

- No fixture directory: the suite writes its own `team-config.json` variants into temporary
  projects, which is why the template and partial-config cases are cheap to cover.
- `.harness-manifest.schema.json` — a live repository file, not a copy, so schema drift would show
  up here first.

## Citations

- `tests/test-manifest-init.sh` — the suite and the source of truth for its assertions.
- [Harness Manifest and Schema](../manifest-schema.md) — the contract this suite generates and checks.
- [Harness Manifest Schema](../../../HARNESS_MANIFEST_SCHEMA.md) — the documented field contract.
