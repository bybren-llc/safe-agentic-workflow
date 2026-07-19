---
type: architecture
title: "Knowledge Vault Subsystem"
description: "OKF v0.1 vault tooling: a zero-dependency validator, gate tests, starter bundle, and build prompts."
tags: [subsystems, okf, gates, ci, process]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "knowledge-vault/README.md"
  - "knowledge-vault/scripts/validate-vault.mjs"
  - "knowledge-vault/tests/test-validator-gates.sh"
  - "knowledge-vault/templates/github/validate-vault.yml"
verified_against: "fd0fc6a"
---

# Knowledge Vault Subsystem

A structural validator plus scaffolding for building a knowledge bundle that stays honest: starter
bundle, build prompts, and a gate suite proving the validator bites. This bundle is its output.

## Overview

The core executable is `knowledge-vault/scripts/validate-vault.mjs` — 461 lines, `node:` builtins
only, zero npm dependencies, which is why it drops into any repo. It finds a vault by locating a
directory holding `_meta/vault-config.json` (or takes `--vault <dir>`), reads that config, walks
every `.md`, `.canvas` and `.base` file, and exits 1 on any error. Other flags:
`--allow-broken-links`, `--strict-orphans`, `--quiet`.

## Design

- **Frontmatter** — required fields, description length, `^\d{4}-\d{2}-\d{2}$` timestamps, plus
  status, domain and every tag checked against the config's vocabularies.
- **Sections and paths** — exact H2 sequence equality against the type's `sections` array, one H1,
  `resource` where `resource_required`, and on-disk existence of every `resource`, `sources` and
  `docs` value; canvas file nodes resolve vault, then bundle, then repo root.
- **Links** — wikilinks, leading-slash paths, repo-host blob/tree/raw URLs, links escaping the repo
  and out-of-bundle links outside `## Citations` all error (index files and `guide` exempt). Any
  `stub: true` type must carry at least one such citation.
- **Manifest sync** — a manifest id with no file errors; a file absent from the manifest *always*
  errors, which is what makes the manifest an allowlist against invented links.

`tests/test-validator-gates.sh` proves the gates bite: 2 clean cases (the starter bundle, and it after
the documented copy-and-rewrite) and 7 error cases — wikilink, repo-host URL, missing resource path,
stub without citation, dangling canvas node, concept missing from the manifest, and a renamed section.
DOC DRIFT: the shipped CI template's header warns that in the origin project the validator "was wired
into no workflow at all", and that holds here — nothing in `.github/workflows` references it, and the
repo ships no `package.json` to hold a script entry. UNKNOWN: whether this bundle held a manifest yet.

## Related Concepts

- [Vault Sync](../skills/vault-sync.md) — repairs the drift a structural validator cannot detect.
- [Harness Sync Engine](../sync/harness-sync-engine.md) — the other manifest-as-allowlist subsystem.

## Citations

- [knowledge-vault/README.md](../../../knowledge-vault/README.md) — subsystem overview.
- [GUIDE.md](../../../knowledge-vault/docs/GUIDE.md) — authoring and validation reference.
