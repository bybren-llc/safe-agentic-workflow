---
type: guide
title: "Cursor Rules: Methodology Family (03-04)"
description: "Manual-activation Cursor rules for SAFe x AI-DLC program cadence and this project's knowledge-vault authoring conventions for OKF bundles."
tags: [providers, methodology, gates, okf]
timestamp: 2026-07-20
status: active
domain: providers
sources:
  - ".cursor/rules/03-safe-ai-dlc.mdc"
  - ".cursor/rules/04-knowledge-vault.mdc"
  - ".cursor/rules/README.md"
verified_against: "c4f9d6d"
---

# Cursor Rules: Methodology Family (03-04)

Two rules you have to ask for. Both set `alwaysApply: false` with no globs, so they load only when
you type `@03-safe-ai-dlc` or `@04-knowledge-vault`. They are the newest addition to the numbering
scheme of the [Cursor surface](../cursor.md), and each mirrors a skill that also exists in the
Claude, Gemini, and portable agent surfaces.

## 03-safe-ai-dlc.mdc — program cadence

82 lines, scoped to work spanning multiple issues that needs cadence. Inside a program that adopts
the fusion the sprint gives way to a Bolt (hours to days, swarmed), a Unit of Work replaces the
Feature, and Mob Elaboration plus a human-in-the-loop gate bracket the run. Adoption is a
per-program choice and the standard sprint path stays valid; the `description` frontmatter carries
the same scoping. See [SAFe x AI-DLC](../../methodology/safe-ai-dlc.md) for the method itself.

Its most useful line is the exclusion: single isolated tickets route to `01-git-workflow.mdc` in
the [Core Family](core.md). Invoking program cadence for one ticket is the failure mode this rule
was written to prevent.

## 04-knowledge-vault.mdc — vault authoring conventions

70 lines covering the frontmatter contract, link rules, `verified_against` drift discipline, and
the vault-sync loop described in [Knowledge Vault](../../subsystems/knowledge-vault.md). The six
required fields are a local tightening applied to OKF bundles, not the OKF format, which requires
only `type`; the rule's `description` attributes them to this project accordingly.

Two definitions are load-bearing. `timestamp` means the date last *verified* against sources, not
last edited — the distinction that makes staleness detectable. YAML is restricted to a subset
(scalars, double-quoted strings, inline lists, two-space block lists; no nested maps or multiline
scalars) so the validator can parse frontmatter without a YAML library. Link rule 4 forbids linking
any concept ID absent from `_meta/manifest.json`, requiring the name in prose instead.

## Cross-check and two disagreements

The contract in 04 matches `docs/knowledge-vault/_meta/vault-config.json` on the six required
fields and `max_description_length` 160. Two things it does not match:

DOC DRIFT: `vault-config.json` declares seven optional fields; 04 lists six, omitting `okf_version`.

DOC DRIFT: 04 calls a concept a "~50-line map-card" while `vault-config.json` sets
`max_concept_lines` to 60. Neither number blocks: the validator only *warns* past 60 and exits 0.

## Citations

- [.cursor rules README](../../../../.cursor/rules/README.md) — the family labels and numbering.
