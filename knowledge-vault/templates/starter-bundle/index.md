---
type: meta
title: "Knowledge Vault"
description: "Root index for this OKF knowledge bundle: the map of the system and the institutional knowledge around it."
tags: [okf]
timestamp: 2026-07-19
okf_version: "0.1"
---

# Knowledge Vault

This vault is a **map, not the territory**. Single-source-of-truth documents stay where they
live; the code stays authoritative over everything, including this vault. Concepts here are
short map-cards that summarize and link — they never restate their sources.

> **This is the starter bundle.** It validates clean as shipped. Replace this content with your
> own, keep the structure, and delete this callout.

## Start Here

- [Start Here](start-here.md) — the ordered onboarding path, where every step says why it comes there

## Sections

Create one directory per section, each with its own `index.md`. Suggested starting set — keep what
fits your system, delete what does not:

- **Architecture** — cross-cutting views that have no single underlying file
- **Domains** — business-domain hubs that re-group artifacts by what they are *for*
- **Integrations** — third-party services and what they touch
- **Operations** — environments, CI, runbooks
- **Knowledge** — patterns, ADRs, SOPs, agent roles, skills, process

## Process

- [Vault Maintenance](process/vault-maintenance.md) — how this vault stays honest as the code moves

## Maps

Obsidian canvases live under `maps/`. See the Obsidian guide for the layout conventions.

## Views

Obsidian Bases live under `bases/`. `stale-concepts.base` is the maintenance queue — it sorts
concepts by how long it has been since anyone verified them against source.

## Conventions

Every concept is one file with an exact frontmatter contract and a fixed section list for its
type. Links are relative markdown only; concept-to-concept links never leave this bundle, and
links that do leave appear only under `## Citations`. Link only to IDs that exist in
`_meta/manifest.json` — never invent a link. The rules live in
[CONVENTIONS.md](_meta/CONVENTIONS.md); the machine-readable form is `_meta/vault-config.json`,
enforced by the validator.

## Log

- [Log](log.md) — dated changelog, newest first
