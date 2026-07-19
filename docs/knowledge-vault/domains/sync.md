---
type: domain
title: "Sync Domain"
description: "The engine, manifest, and tests that let a fork pull upstream harness releases without losing its edits."
tags: [sync, testing, ci, workflow, okf]
timestamp: 2026-07-19
status: active
domain: sync
verified_against: "fd0fc6a"
---

# Sync Domain

The hardest problem the harness solves: shipping updates into repos that have already been edited.

## Overview

Owns the update path — the 3366-line bash engine, the manifest declaring a fork's customizations,
scope resolution, fixtures, and the nine suites that hold it honest. It does not own the surfaces
being synced ([Providers](providers.md)) nor the release producing a syncable tag
([Operations](operations.md)). Its theme: the gap between documented and enforced.

## Members

- [Fork Workflow](../methodology/harness-sync-and-fork-workflow.md) — the two update paths.
- [Manifest Schema](../sync/manifest-schema.md) — seven sections; validated by bash, not the schema.
- [Sync Scope](../sync/sync-scope.md) — six allowed domains; unknown ones are silently dropped.
- [Harness Sync Engine](../sync/harness-sync-engine.md) — ten subcommands, backups, rollback,
  patches; degrades to legacy sync when PyYAML is absent.
- [Fixtures](../sync/fixtures.md) — two synthetic forks, one with renames and one without.

Proof, and the current state of it:

- [preflight](../sync/tests/preflight.md) — the strongest negative suite, 45 of 45 green.
- [protected-files](../sync/tests/protected-files.md), [fork-sync](../sync/tests/fork-sync.md),
  [multi-domain-sync](../sync/tests/multi-domain-sync.md), [rename-diff](../sync/tests/rename-diff.md),
  [manifest-loader](../sync/tests/manifest-loader.md), [manifest-init](../sync/tests/manifest-init.md),
  [substitutions](../sync/tests/substitutions.md), [patch-generation](../sync/tests/patch-generation.md).
- [test-fork-sync workflow](../operations/workflows/test-fork-sync.md) — CI runs six of the nine.

## Key Flows

**A sync run.** `sync` resolves scope (manifest, or a `--scope` override that never rewrites the
manifest), fetches the upstream tarball, substitutes tokens in the temp tree *before* preflight so
the scanner sees post-substitution state, plans by exclusion then rename resolution then comparison,
preflights, backs up, copies. One `SYNC_TIMESTAMP` spans all domains, so `rollback` undoes the lot.

**A customization surviving.** A fork declares renames and `protected` patterns; renames resolve
file-first then directory-prefix, protected paths are skipped. `replaced` is documented but NOT
enforced — only `protected` holds, and no suite exercises `replaced` at all.

**Red on a laptop.** Five of the nine suites fail on macOS: `declare -A` in `do_diff` and `head -n -3`
in a test helper are bash-3.2 and BSD-coreutils gaps — a portability signal, not a regression.

## Citations

- [HARNESS_SYNC_GUIDE.md](../../HARNESS_SYNC_GUIDE.md) — operator-facing sync procedure.
- [HARNESS_MANIFEST_SCHEMA.md](../../HARNESS_MANIFEST_SCHEMA.md) — the documented manifest contract.
