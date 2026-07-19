---
type: meta
title: "SAW Knowledge Vault"
description: "Root index for the SAFe Agentic Workflow knowledge bundle: both doors into 220 evidence-verified concepts."
tags: [okf]
timestamp: 2026-07-19
status: active
okf_version: "0.1"
---

# SAW Knowledge Vault

This vault is a **map of the SAFe Agentic Workflow harness, not the harness itself**. Every concept
here is a short card that summarizes and links its sources; the code stays authoritative. Each card
records `verified_against` — the git SHA its claims were last checked at. That is what makes
staleness *computed* rather than felt: when a card's SHA falls behind the current baseline, the card
is provably unverified, whether or not anything in it happens to still be true. A citation is not
re-verification. Only re-deriving a card from source moves its SHA forward.

**Baseline: `fd0fc6a`.** Cards verified against that SHA are current; anything behind it is in the
drift queue below.

## Two doors

Pick by what you are doing, not by what you want to know:

- [Start Here](start-here.md) — the **learning door**. An ordered path where every step explains why
  it comes where it does. Take this if the harness is new to you.
- This page — the **reference door**. A cascade of curated indexes, every link annotated with what
  you will find there. Take this if you know what you want and need to find it.

## Structural indexes — where things live

The harness by its own filing system. Each index groups its concepts by what they do and says what
each group is for.

- [Providers](providers/index.md) — the five AI-tool surfaces, plus Cursor rule families, hooks, and
  the Augment rule slots (two written, four empty)
- [Roles](roles/index.md) — the eleven SAFe agent roles, grouped by what they do to a piece of work,
  with each role's authority and boundary
- [Skills](skills/index.md) — twenty skills the model invokes on its own, grouped by the moment in
  the work where it would reach for them
- [Commands](commands/index.md) — thirty-five commands you invoke by name, including the eleven
  Gemini-only media commands and six deprecated aliases
- [Subsystems](subsystems/index.md) — the self-contained units the harness ships: dark factory,
  pattern library, spec templates, linting, this vault
- [Sync](sync/index.md) — the engine, manifest schema and fixtures that let a fork take upstream
  releases without losing local edits
- [Operations](operations/index.md) — CI workflows, environments, release process, maintenance
  scripts
- [Methodology](methodology/index.md) — the method documents themselves: gates, philosophy,
  workflow contracts, architecture layers
- [Patterns](patterns/index.md) — the reusable implementation patterns agents copy from rather than
  writing fresh
- [Knowledge](knowledge/index.md) — the surrounding documentation corpus: onboarding, guides,
  security, database, SOPs, whitepapers

## Semantic index — how things work

- [Domains](domains/index.md) — the five cross-cuts (methodology, providers, subsystems, operations,
  sync). Structural indexes answer *where does X live*; domains answer *how does X work here*, by
  pulling together concepts that sit in different directories.

## Maps

Obsidian canvases. Open these when a list is the wrong shape for the question.

- [Delivery flow](maps/delivery-flow.canvas) — one ticket, left to right, with the gates, skills and
  evidence attached to each step
- [Harness architecture](maps/harness-architecture.canvas) — the three layers (hooks, commands,
  skills) beneath the eleven roles and the five provider surfaces

## Views

Obsidian Bases. Saved queries over the same 220 concepts.

- [Drift dashboard](bases/stale-concepts.base) — the maintenance queue: every concept whose
  `verified_against` is not `fd0fc6a`. This is the one to open first after a merge.
- [By domain](bases/by-domain.base) — the whole vault regrouped along the semantic axis
- [By type](bases/by-type.base) — grouped by concept type, for checking template coverage
- [Coverage](bases/coverage.base) — grouped by status, for finding deprecated and planned cards

## Conventions

Every concept is one file with an exact frontmatter contract and a fixed section list for its type.
Links are relative markdown only; links that leave the bundle appear only under `## Citations`, and
concept links must resolve to an ID in `_meta/manifest.json` — never invent one. The rules are in
[CONVENTIONS.md](_meta/CONVENTIONS.md); the machine-readable form is
[vault-config.json](_meta/vault-config.json), enforced by the validator. Note what is *not*
enforced — CONVENTIONS.md says so explicitly, and a clean validator run is not proof the whole
constitution was followed.

## Log

- [Log](log.md) — dated changelog, newest first
