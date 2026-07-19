---
type: guide
title: "RLS Policy Catalog (SSoT stub)"
description: "Pointer to the catalog enumerating Row Level Security policies per table."
tags: [ssot-stub, subsystems, security]
timestamp: 2026-07-19
status: active
sources:
  - "docs/database/RLS_POLICY_CATALOG.md"
verified_against: "fd0fc6a"
---

# RLS Policy Catalog (SSoT stub)

A map-card for `docs/database/RLS_POLICY_CATALOG.md`, 356 lines opening with an Overview. It is
the table-by-table enumeration of which Row Level Security policies exist and what each one
permits — the lookup you reach for when a query returns fewer rows than you expected.

## What kind of document it is

Enumerative reference, not narrative. There is no reading order and no argument being made; you
scan for your table and stop. That makes it the least useful of the four database documents to
read end to end and the most useful to have open while debugging an access decision.

## Its standing hazard

Because it enumerates, it goes stale on any policy or schema change that does not also edit it.
Nothing in the harness diffs the catalog against live policies, so a mismatch surfaces as a
surprise at runtime rather than as a failing check. Treat the catalog as a strong hint and the
database as the authority. The [RLS Database Migration SOP](rls-database-migration-sop.md) is
where the obligation to update it belongs, and the [vault-sync skill](../../skills/vault-sync.md)
is the general mechanism for catching drift of exactly this shape.

## Related

Read the [RLS Implementation Guide](rls-implementation-guide.md) first for the context helpers the
policies are evaluated against; see the [Data Dictionary](data-dictionary.md) for what the columns
these policies guard actually mean.

## Citations

- [RLS_POLICY_CATALOG.md](../../../database/RLS_POLICY_CATALOG.md) — the catalog itself.
