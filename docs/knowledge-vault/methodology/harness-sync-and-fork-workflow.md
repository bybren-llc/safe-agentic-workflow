---
type: process
title: "Harness Sync and Fork Workflow"
description: "How an adopting fork pulls upstream harness releases without losing customizations, via a required manifest and a rollback path."
tags: [methodology, sync, process, release, operations]
timestamp: 2026-07-20
status: active
domain: sync
sources:
  - "README.md"
  - "TEMPLATE_SETUP.md"
  - "docs/guides/WORKSPACE-ADOPTION-GUIDE.md"
  - "docs/HARNESS_SYNC_GUIDE.md"
  - "docs/HARNESS_MANIFEST_SCHEMA.md"
  - "scripts/sync-claude-harness.sh"
  - ".harness-manifest.yml"
  - ".harness-manifest.schema.json"
  - "docs/releases/v2.10.0-UPGRADE.md"
verified_against: "0c26121"
---

# Harness Sync and Fork Workflow

A fork that customizes the harness still needs upstream releases. This process pulls them in
without overwriting local work, using a manifest recording what was renamed, substituted, and
protected. It prevents the upgrade that silently reverts a fork's own decisions.

## Overview

Two update paths exist by design. The automated path runs `scripts/sync-claude-harness.sh` over the
domains in the manifest's `sync` scope; since v2.10.0 the manifest is required, and without one only
`--dry-run` is permitted. Everything outside that scope — `docs/`, `scripts/`, `patterns_library/` —
is updated by git remote and checkout, then `sync-claude-harness.sh --dry-run` previews and applies.

## Flow

- **Bootstrap.** Run `init`, then `manifest init --yes`, then `sync`; skipping it leaves the fork
  dry-run-only.
- **Inspect first.** `status`, `version`, `diff`, and `releases` preview an upgrade; `conflicts`
  lists what rename-aware diffing could not reconcile automatically.
- **Sync.** Flags: `--dry-run`, `--version <tag>`, `--latest`, `--scope <comma-list>`,
  `--generate-patches`, `--no-placeholders`, `--skip-preflight`. `--scope` overrides manifest
  scope for one invocation and does not rewrite it. See [Sync Scope](../sync/sync-scope.md).
- **Recover.** `rollback` restores the pre-sync backup — no partial revert. Legacy forks first run
  a six-step migration moving the old `.sync-exclude` file into the manifest's `protected` section.

Version consistency: README's badge, automated `sync --version` examples, and the manual
`git diff v2.10.0..v2.11.0` now all read v2.11.0, and `SECURITY.md` lists 2.11.x as current. One
residual pointer: the manual path still links the v2.10.0 upgrade guide for rollback options.

## Roles Involved

- **Fork maintainer** — owns the manifest, decides scope, runs sync and rollback.
- **ARCHitect-in-CLI** — reviews conflicts and protected-file decisions before a sync merges. See
  [Harness Sync Engine](../sync/harness-sync-engine.md).

## Citations

- [HARNESS_SYNC_GUIDE.md](../../HARNESS_SYNC_GUIDE.md) — the authoritative sync procedure.
