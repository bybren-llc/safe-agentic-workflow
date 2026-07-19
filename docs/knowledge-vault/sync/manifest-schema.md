---
type: architecture
title: "Harness Manifest and Schema"
description: "The .harness-manifest.yml contract declaring identity, renames, protected files, and sync scope."
tags: [sync, subsystems, operations, process]
timestamp: 2026-07-19
status: active
domain: sync
sources:
  - ".harness-manifest.schema.json"
  - ".harness-manifest.yml"
  - "scripts/sync-claude-harness.sh"
verified_against: "fd0fc6a"
---

# Harness Manifest and Schema

`.harness-manifest.yml` makes a fork legible to the sync engine: it declares who the project is,
what it renamed, what it owns, and which directories are in scope. A sibling JSON Schema documents
that contract, and nothing at sync time reads it.

## Overview

The schema sets `additionalProperties: false`, requires `manifest_version` plus `identity`, and
declares seven top-level properties: those two plus `substitutions`, `renames`, `protected`,
`replaced` and `sync`. `identity` holds 26 flat keys of which six are required — `PROJECT_NAME`,
`PROJECT_REPO`, `PROJECT_SHORT`, `GITHUB_ORG`, `TICKET_PREFIX`, `MAIN_BRANCH` — the rest naming
author, Linear, MCP and container values. `validate_manifest` re-implements only a subset of that in
bash and never opens the `.json` at all.

## Design

| Property | Shape | Enforced where |
| --- | --- | --- |
| `manifest_version` | Version string; repo declares `"1.1"` | Regex in `validate_manifest` |
| `identity` | 26 flat keys, 6 required | `validate_manifest` checks the 6 |
| `substitutions`, `renames` | Free-form objects | Rename path structure only |
| `protected` | String array | Glob- and substring-matched by `is_protected` |
| `replaced` | String array | Nowhere; `do_sync` overwrites these files silently |

Path semantics turn on the version: `1.0` uses domain-relative paths, `1.1` and above root-relative,
via `USE_ROOT_PATHS` — a lexicographic compare against the literal `"1.1"`, which branches correctly
for every X.Y string `validate_manifest`'s regex admits, `1.10` included. Because no runtime reader
opens the schema, `additionalProperties: false` and both enums go unenforced; the only place it is
genuinely applied is Test 7 of `tests/test-manifest-init.sh`. Three documented knobs are fiction too:
`sync.auto_substitute`, `sync.backup` and `sync.substitution_extensions` are never read — substitution
is always on, backup unconditional, the extension list hardcoded; `conflict_strategy` only gets printed.

## Related Concepts

- [Harness Sync Engine](harness-sync-engine.md) — the only consumer of this file.
- [Multi-Domain Sync Scope Resolution](sync-scope.md) — how `sync_scope` is actually read.
- [Test Suite: Manifest Init](tests/manifest-init.md) — generates and schema-checks a manifest.

## Citations

- [Harness Manifest Schema](../../HARNESS_MANIFEST_SCHEMA.md) — the documented field-by-field contract.
- [Harness Sync Guide](../../HARNESS_SYNC_GUIDE.md) — how the manifest is authored and used.
