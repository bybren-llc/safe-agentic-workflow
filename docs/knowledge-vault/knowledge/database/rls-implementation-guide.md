---
type: guide
title: "RLS Implementation Guide (SSoT stub)"
description: "Pointer to the guide for implementing Row Level Security in database access code."
tags: [ssot-stub, subsystems, security, patterns]
timestamp: 2026-07-19
status: active
sources:
  - "docs/database/RLS_IMPLEMENTATION_GUIDE.md"
verified_against: "fd0fc6a"
---

# RLS Implementation Guide (SSoT stub)

A map-card for `docs/database/RLS_IMPLEMENTATION_GUIDE.md`, 313 lines opening with an Overview.
This is the document that turns "we use Row Level Security" from a database setting into a rule
about how application code is written, so read it before your first query, not after.

## The rule it backs

Every database access goes through one of three context helpers — `withUserContext`,
`withAdminContext`, or `withSystemContext` — rather than a direct ORM client call. The helper is
what sets the session context the policies evaluate against; a direct call runs with no identity
established, which is why the prohibition is absolute rather than stylistic.
[CLAUDE.md](../root-docs/claude-md.md) states the same rule at the top level.

## What actually enforces it

Prose does not. The harness ships a pre-Bash hook,
[pre-bash-rls-validation](../../providers/hooks/pre-bash-rls-validation.md), that inspects commands
before they run, and the [rls-patterns skill](../../skills/rls-patterns.md) routes agents to the
correct helper at authoring time. The [security-audit skill](../../skills/security-audit.md)
covers the review end. The guide is the reference those three point back at.

## Where to go next

For the concrete code shape, use the vault's [user-context API pattern](../../patterns/user-context-api.md)
and [admin-context API pattern](../../patterns/admin-context-api.md). For which policy applies to
which table, the [RLS Policy Catalog](rls-policy-catalog.md). For changing schema without breaking
either, the [RLS Database Migration SOP](rls-database-migration-sop.md).

## Citations

- [RLS_IMPLEMENTATION_GUIDE.md](../../../database/RLS_IMPLEMENTATION_GUIDE.md) — the guide itself.
