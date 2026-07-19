---
type: process
title: "Multi-Domain Sync Scope Resolution"
description: "How the sync engine decides which provider directories to sync: manifest, flag, then hardcoded allowlist."
tags: [sync, process, workflow, providers]
timestamp: 2026-07-19
status: active
domain: sync
sources:
  - "scripts/sync-claude-harness.sh"
  - ".harness-manifest.yml"
  - ".harness-manifest.schema.json"
  - "tests/test-multi-domain-sync.sh"
verified_against: "fd0fc6a"
---

# Multi-Domain Sync Scope Resolution

A harness sync can touch several provider directories, not just `.claude/`. Scope resolution decides
which ones, and exists to stop a sync silently rewriting a provider the fork never opted into.

## Overview

`get_sync_scope()` runs before the per-domain loop in `do_sync`. It ignores the parsed manifest
JSON — it greps the raw YAML for `sync_scope:` and reads the following `-` lines with `sed`,
stripping quotes and trailing slashes, to dodge JSON parsing issues per its inline comment. That
grep is indentation-insensitive, matching `sync.sync_scope` nested under `sync:` as readily as a
top-level key, and stops at the first line not starting with `-`. The schema lists the same six
domains with trailing slashes; both forms resolve, and the in-repo manifest declares all six.

## Flow

- **Filter against the allowlist.** `ALLOWED_DOMAINS` is hardcoded as `.claude`, `.gemini`,
  `.codex`, `.cursor`, `.agents`, `dark-factory`; anything else warns and is dropped non-fatally.
  If `HAS_MANIFEST` is false or nothing survives, scope falls back to `.claude` alone.
- **Apply `--scope` if given.** The comma-separated override clears the list, trims slashes and
  whitespace via `xargs`, re-applies the allowlist, and returns 1 only when zero valid domains
  remain. It is per-invocation and never rewrites `.harness-manifest.yml`.
- **Loop sequentially.** `do_sync` echoes `Sync domains: <list>`, then runs one fetch/compare/apply
  pass per domain, setting `CURRENT_DOMAIN` and `DOMAIN_TMP` each iteration.
- **Share safety state across domains.** `SYNC_TIMESTAMP` is cleared once before the loop so every
  domain lands in one backup `do_rollback` restores together, and `.harness-patches/<version>/` is
  made once so later domains cannot wipe earlier patches.

`enumerate_upstream_files` errors nothing when a domain is absent upstream. The suite covering this,
[Test Suite: Multi-Domain Sync](tests/multi-domain-sync.md), does not run in CI and aborts on a
GNU-only `head -n -3`. Open question: how per-domain failure reaches `do_sync`'s return value.

## Roles Involved

- **Fork maintainer** — owns `sync.sync_scope`, the durable declaration of intent.
- **Sync operator** — picks `--scope` for a one-off narrower run, accepting that it is transient.
- **The engine** — final authority via `ALLOWED_DOMAINS`; an unknown domain is warned and dropped.

## Citations

- [Harness Sync Guide](../../HARNESS_SYNC_GUIDE.md) — documents the `--scope` flag and domain list.
- [Harness Manifest Schema](../../HARNESS_MANIFEST_SCHEMA.md) — the `sync_scope` enum and default.
