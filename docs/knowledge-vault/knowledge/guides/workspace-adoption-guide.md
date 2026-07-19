---
type: guide
title: "Workspace Adoption Guide"
description: "SSoT stub: authoritative reference for adopting the harness into existing single or multi-repo workspaces and keeping it updated."
tags: [ssot-stub, onboarding, sync, operations]
timestamp: 2026-07-19
status: active
domain: sync
sources:
  - "docs/guides/WORKSPACE-ADOPTION-GUIDE.md"
verified_against: "fd0fc6a"
---

# Workspace Adoption Guide

A pointer card. `docs/guides/WORKSPACE-ADOPTION-GUIDE.md` is 467 lines and covers the path
[Getting Started](getting-started.md) does not: bringing the harness into a repo that already has
code in it. The README links here from both "Adopting into an existing repo" and "Upgrading from
a previous version".

## What It Is Authoritative For

Six H2 sections: Overview, Single Repo Adoption, Multi-Repo Strategy, Dark Factory on Remote
Server, Keeping the Harness Updated, and Customization After Adoption.

Its Overview enumerates the five harness directories an adopter installs — `.claude/`, `.gemini/`,
`.codex/`, `.cursor/`, and `.agents/`. That list is the concrete definition of "the harness" for
adoption purposes, and it is worth reading before deciding which providers you actually want.

## When To Read It

Read it when the adopter did **not** use the GitHub template, or when planning a harness rollout
across several repositories at once. Multi-repo is where adoption decisions become expensive to
reverse, so the strategy section earns its place before the first install rather than after.

## Boundaries

Its "Keeping the Harness Updated" section is the user-facing narrative of the two update
mechanisms — enough to act on, not enough to debug. The full command and manifest reference is
`docs/HARNESS_SYNC_GUIDE.md`, summarised at
[Harness Sync and Fork Workflow](../../methodology/harness-sync-and-fork-workflow.md) with the
implementation at [Harness Sync Engine](../../sync/harness-sync-engine.md).

Remote Dark Factory setup appears here as a configuration step; the subsystem itself is
[Dark Factory](../../subsystems/dark-factory.md).

## Citations

- [WORKSPACE-ADOPTION-GUIDE.md](../../../guides/WORKSPACE-ADOPTION-GUIDE.md) — the authority.
- [HARNESS_SYNC_GUIDE.md](../../../HARNESS_SYNC_GUIDE.md) — the full update reference.
- [README.md](../../../../README.md) — links here from two adoption entry points.
