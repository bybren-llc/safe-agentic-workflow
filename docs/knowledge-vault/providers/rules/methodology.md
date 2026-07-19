---
type: guide
title: "Cursor Rules: Methodology Family (03-04)"
description: "Manual-activation Cursor rules for SAFe x AI-DLC program cadence and OKF knowledge-vault conventions."
tags: [providers, methodology, gates, okf]
timestamp: 2026-07-19
status: active
domain: providers
sources:
  - ".cursor/rules/03-safe-ai-dlc.mdc"
  - ".cursor/rules/04-knowledge-vault.mdc"
  - ".cursor/rules/README.md"
verified_against: "fd0fc6a"
---

# Cursor Rules: Methodology Family (03-04)

Two rules you have to ask for. Both set `alwaysApply: false` with no globs, so they load only when
you type `@03-safe-ai-dlc` or `@04-knowledge-vault`. They are the newest addition to the numbering
scheme of the [Cursor surface](../cursor.md), and each mirrors a skill that also exists in the
Claude, Gemini, and portable agent surfaces.

## 03-safe-ai-dlc.mdc — program cadence

81 lines, scoped to work that spans multiple issues and needs cadence. It renames the SAFe unit
vocabulary for agent-speed delivery: a Bolt (hours to days, swarmed) replaces the sprint, a Unit of
Work replaces the Feature, and Mob Elaboration plus a human-in-the-loop validation gate bracket the
run. See [SAFe x AI-DLC](../../methodology/safe-ai-dlc.md) for the methodology itself.

Its most useful line is the exclusion: single isolated tickets are routed to
`01-git-workflow.mdc` instead, in the [Core Family](core.md). Invoking program cadence for one
ticket is the failure mode this rule was written to prevent.

## 04-knowledge-vault.mdc — OKF conventions

70 lines covering the frontmatter contract, link rules, `verified_against` drift discipline, and
the vault-sync loop described in [Knowledge Vault](../../subsystems/knowledge-vault.md).

Two definitions in it are load-bearing. `timestamp` means the date last *verified* against sources,
not last edited — the distinction that makes staleness detectable. And YAML is restricted to a
subset (scalars, double-quoted strings, inline lists, two-space block lists; no nested maps, no
multiline scalars) explicitly so the validator can parse frontmatter without a YAML library. Link
rule 4 forbids linking any concept ID absent from `_meta/manifest.json` and requires naming the
missing concept in prose instead.

## Cross-check and one disagreement

The contract in 04 matches `docs/knowledge-vault/_meta/vault-config.json` exactly on the six
required fields, the six optional fields, and `max_description_length` 160.

DOC DRIFT: 04's prose calls a concept a "~50-line map-card" while `vault-config.json` sets
`max_concept_lines` to 60. The machine-enforced limit is 60; the prose is stricter advice, and the
two have not been reconciled.

## Citations

- [.cursor rules README](../../../../.cursor/rules/README.md) — the family labels and numbering.
