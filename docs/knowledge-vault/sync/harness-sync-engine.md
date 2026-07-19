---
type: architecture
title: "Harness Sync Engine"
description: "Bash engine that syncs harness domains from upstream while preserving fork renames and protected files."
tags: [sync, subsystems, operations, workflow]
timestamp: 2026-07-19
status: active
domain: sync
sources:
  - "scripts/sync-claude-harness.sh"
  - ".harness-manifest.yml"
  - ".harness-manifest.schema.json"
verified_against: "fd0fc6a"
---

# Harness Sync Engine

`scripts/sync-claude-harness.sh` is the entire engine: 3366 lines, 57 functions, `set -e`, ten subcommands on `$1`.

## Overview

Every non-help command runs `migrate_metadata_to_root` first, lifting `.harness-manifest.yml`, `.harness-sync.json`,
`.harness-backup/` and `.harness-patches/` to the repo root unless a root copy already exists. `status`, `version`,
`diff` and `sync` then chain `load_config`, `load_manifest` and `validate_manifest`, exiting on failure, while `init`
treats validation as non-fatal. `load_manifest` never aborts: missing `python3` or PyYAML warns and returns 0.

## Design

| Component | Responsibility | Notes |
| --- | --- | --- |
| `do_sync` | Fetch, compare, apply per domain | Returns 1 without a manifest unless `--dry-run`; always overwrites |
| `run_preflight` | Gate every write | Traversal, stray tokens, protected on both path sides |
| `apply_substitutions` | Rewrite identity and explicit tokens | One `sed -i`; branches GNU versus BSD |
| `is_protected` | Refuse to overwrite fork-owned files | Substring-matches too, so short patterns over-match |
| `do_rollback` | Restore from `.harness-backup/` | One `SYNC_TIMESTAMP` rolls all domains back |
| `do_diff` | Rename and protected summaries | Bash 4 only (`declare -A`, line 1560); silent on macOS bash 3.2 |
| `do_conflicts` | List `*.conflict` files | Scans only `$CLAUDE_DIR`; no writer for that suffix exists anywhere |
| `manifest_count` | Count manifest entries | Emits `node` output; `FORCE_COLOR` ANSI-wraps it, breaking arithmetic |

`sync.conflict_strategy` is decorative — read at line 2453 only to print `Conflict: <value>` in `do_status`. No branch
implements `upstream-wins`, `local-wins`, `prompt` or `three-way`, `do_sync` unconditionally overwrites, the conflicts
counter is hardcoded 0, and the example manifest in `tests/fixtures/sync/keryk-ai/` still ships `three-way`. `replaced`
is never enforced: `get_protected_patterns` reads only `data.protected` and `Skipped (replaced):` occurs zero times, so
those files are counted in status, then overwritten. `auto_substitute` and `substitution_extensions` are unread too —
only `--no-placeholders` skips substitution, and its extension list is hardcoded (`.bib`/`.cff` extra).
`show_help` promises a no-manifest fallback `do_sync` refuses outside `--dry-run`. The bash 3.2 gap is a macOS
portability defect, not a logic error: 12/50 rename-diff and 6/54 protected-files failures; GNU/Linux CI runs bash 4+.

## Related Concepts

- [Harness Manifest and Schema](manifest-schema.md) — the contract this engine loads and validates.
- [Multi-Domain Sync Scope Resolution](sync-scope.md) — how the domain list driving `do_sync` is set.
- [Test Suite: Fork Sync Scenarios](tests/fork-sync.md) — the end-to-end suite that exercises it.

## Citations

- [Harness Sync Guide](../../HARNESS_SYNC_GUIDE.md) — operator-facing description of the commands.
- [Harness Manifest Schema](../../HARNESS_MANIFEST_SCHEMA.md) — the documented manifest contract.
