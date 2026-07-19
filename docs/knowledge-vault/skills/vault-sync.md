---
type: skill
title: "Skill: vault-sync"
description: "Detects and repairs drift between an OKF knowledge vault and the code it describes, gated by a validator."
resource: ".claude/skills/vault-sync/SKILL.md"
tags: [skills, sync, okf, operations]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".agents/skills/vault-sync/SKILL.md"
  - "knowledge-vault/scripts/validate-vault.mjs"
verified_against: "fd0fc6a"
---

# Skill: vault-sync

The maintenance loop for this bundle: diff the code since the recorded baseline, find the concepts
those changes invalidated, re-derive them, and refuse to finish until the validator passes.

## Overview

The only skill in the harness declaring `user-invocable: true` explicitly, and model-invocable too,
so it appears in the runtime available-skills listing and can also be called by name. Its
`allowed-tools` are `Read`, `Grep`, `Glob`, `Bash` — `Bash` because the validator is a script that
must actually run.

Eight H2s carry it: Purpose, When This Skill Applies, Key Files, Procedure, Invariants (do not
relax), Anti-Patterns (Do NOT use), Authoritative References, Routes To. Step one diffs
`baseline_sha` against `HEAD` over a per-project watch-list of source paths; that watermark makes
drift detection cheap instead of a full re-read. The two surfaces differ by only 15 lines.

## Routes To

- `knowledge-vault/scripts/validate-vault.mjs` — labelled "The gate"; the run is not done until it
  passes.
- `_meta/vault-config.json`, `_meta/CONVENTIONS.md`, `_meta/manifest.json`, `_meta/templates/`, and
  the bundle's `log.md` — the Key Files table.

The gate script lives outside this bundle: it sits under `knowledge-vault/` while this vault's
`_meta/` lives under `docs/knowledge-vault/`, so the two are in different trees and any path
assumption that they share a root will fail.

Related: [Knowledge Vault](../subsystems/knowledge-vault.md),
[Harness Sync and Fork Workflow](../methodology/harness-sync-and-fork-workflow.md).

## Used By Roles

No role definition under `.claude/agents/` references this skill, which fits its shape: it is a
maintenance entry point a human runs after a merge, not a step inside anyone's delivery loop.
[Tech Writer](../roles/tech-writer.md) is the closest role by remit, but the binding is not
declared.

## Citations

- [vault GUIDE.md](../../../knowledge-vault/docs/GUIDE.md) — the authoritative vault procedure.
- [BUILD-PROMPT.md](../../../knowledge-vault/docs/BUILD-PROMPT.md) — how a bundle is built and re-derived.
