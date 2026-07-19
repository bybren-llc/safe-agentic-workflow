---
type: guide
title: "Database Documentation Index (SSoT stub)"
description: "Pointer to the docs/database index over the dictionary, RLS guide, catalog and migration SOP."
tags: [ssot-stub, subsystems, onboarding]
timestamp: 2026-07-19
status: active
sources:
  - "docs/database/README.md"
verified_against: "fd0fc6a"
---

# Database Documentation Index (SSoT stub)

A map-card for `docs/database/README.md`, the 62-line index that fronts the database
documentation set. Its whole job is routing, which makes it the right first stop when you know you
need database knowledge but not which of the four documents holds it.

## What it indexes

Under a "Documentation Files" section it lists exactly the four files that make up
`docs/database/`, and nothing else lives there:

| File | Vault concept |
| --- | --- |
| `DATA_DICTIONARY.md` | [Data Dictionary](data-dictionary.md) |
| `RLS_IMPLEMENTATION_GUIDE.md` | [RLS Implementation Guide](rls-implementation-guide.md) |
| `RLS_POLICY_CATALOG.md` | [RLS Policy Catalog](rls-policy-catalog.md) |
| `RLS_DATABASE_MIGRATION_SOP.md` | [RLS Migration SOP](rls-database-migration-sop.md) |

## How to read the set

Take the implementation guide before the catalog: the guide establishes which context helper wraps
a query, and the catalog's per-table policies only mean something once you know a policy is
evaluated against a context you set deliberately. The migration SOP comes last because it assumes
both — a migration that adds a table without a policy is the mistake it is written to catch.

## Citations

- [docs/database/README.md](../../../database/README.md) — the index itself.
