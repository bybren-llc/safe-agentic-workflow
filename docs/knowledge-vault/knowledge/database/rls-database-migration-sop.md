---
type: guide
title: "RLS Database Migration SOP (SSoT stub)"
description: "Pointer to the standard operating procedure for RLS-safe database migrations."
tags: [ssot-stub, subsystems, security, process, gates]
timestamp: 2026-07-19
status: active
sources:
  - "docs/database/RLS_DATABASE_MIGRATION_SOP.md"
verified_against: "fd0fc6a"
---

# RLS Database Migration SOP (SSoT stub)

A map-card for `docs/database/RLS_DATABASE_MIGRATION_SOP.md` — at 589 lines the largest file in
`docs/database/`, opening with a Purpose section. It governs how schema changes ship without
leaving a table unguarded, and it is the document to open before you write a migration, not
before you deploy one.

## Why it is this long

A migration touching an RLS-protected schema has two halves that can drift apart: the structural
change and the policy that must accompany it. The SOP exists because the second half is the one
people forget, and forgetting it is silent — the table works, and it works for everybody. The
length is procedure and checklists, which is exactly the material a map-card must not restate.

## A note on typing

It is filed here as a `guide` rather than the vault's `sop` type, which requires a `resource` and
is reserved in this bundle for the [pre-release checklist](../../operations/release/pre-release-checklist.md).
That is a vault bookkeeping decision, not a claim about the document: it is an SOP by title,
content, and intent.

## What it pairs with

The [rls-patterns skill](../../skills/rls-patterns.md) and the
[migration-patterns skill](../../skills/migration-patterns.md) carry the agent-facing version, the
[RLS migration pattern](../../patterns/rls-migration.md) carries the code shape, and
[CLAUDE.md](../root-docs/claude-md.md) carries a condensed migration workflow — create, test
locally, commit the migrations directory, deploy. Never `db push` in production is its own line
there. Any policy change made under this SOP obliges an update to the
[RLS Policy Catalog](rls-policy-catalog.md).

## Citations

- [RLS_DATABASE_MIGRATION_SOP.md](../../../database/RLS_DATABASE_MIGRATION_SOP.md) — the SOP itself.
