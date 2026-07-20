---
type: architecture
title: "Knowledge Vault Subsystem"
description: "OKF v0.1 vault tooling: a zero-dependency validator, gate tests, starter bundle, and build prompts."
tags: [subsystems, okf, gates, ci, process]
timestamp: 2026-07-20
status: active
domain: subsystems
sources:
  - "knowledge-vault/README.md"
  - "knowledge-vault/scripts/validate-vault.mjs"
  - "knowledge-vault/tests/test-validator-gates.sh"
  - "knowledge-vault/templates/github/validate-vault.yml"
verified_against: "a79c2bd"
---

# Knowledge Vault Subsystem

A structural validator plus scaffolding for building a knowledge bundle that stays honest: starter
bundle, build prompts, and a gate suite proving the validator bites. This bundle is its output.

## Overview

The core executable is `knowledge-vault/scripts/validate-vault.mjs` — 461 lines, `node:` builtins
only, zero npm dependencies, so it drops into any repo. It finds a vault by locating a directory
holding `_meta/vault-config.json` (or takes `--vault <dir>`), reads that config, walks every `.md`,
`.canvas` and `.base` file, exits 1 on any error, and takes `--allow-broken-links`,
`--strict-orphans` and `--quiet`.

## Design

- **Frontmatter** — required fields, description length, `^\d{4}-\d{2}-\d{2}$` timestamps, plus
  status, domain and every tag checked against the config's vocabularies.
- **Sections and paths** — exact H2 sequence equality against the type's `sections` array, one H1,
  `resource` where `resource_required`, and on-disk existence of every `resource`, `sources` and
  `docs` value; canvas file nodes resolve vault, then bundle, then repo root.
- **Links** — wikilinks, leading-slash paths, repo-host blob/tree/raw URLs, links escaping the repo,
  and out-of-bundle links outside `## Citations` all error (index files and `guide` exempt); any
  `stub: true` type must carry one such citation.
- **Manifest sync** — a manifest id with no file errors; a file absent from the manifest *always*
  errors, making the manifest an allowlist against invented links.

`tests/test-validator-gates.sh` proves the gates bite: 2 clean cases and 7 error cases — wikilink,
repo-host URL, missing resource path, uncited stub, dangling canvas node, unmanifested concept,
renamed section. The gate is wired here: `.github/workflows/validate-vault.yml` runs it with
`--strict-orphans` (never `--allow-broken-links`) on PRs touching the vault or any cited source, via
`node` since the repo ships no `package.json`. Content drift (same path, changed meaning) stays
outside it. Obsidian is the reading layer, not a dependency: the README credits graph view (orphans
shown deliberately), canvases, and Bases for the drift dashboard over `verified_against`.

## Related Concepts

- [Vault Sync](../skills/vault-sync.md) — repairs the drift a structural validator cannot detect.
- [Harness Sync Engine](../sync/harness-sync-engine.md) — the other manifest-as-allowlist subsystem.

## Citations

- [knowledge-vault/README.md](../../../knowledge-vault/README.md) — subsystem overview.
- [GUIDE.md](../../../knowledge-vault/docs/GUIDE.md) — authoring and validation reference.
