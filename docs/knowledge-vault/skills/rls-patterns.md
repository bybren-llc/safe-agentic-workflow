---
type: skill
title: "Skill: rls-patterns"
description: "Enforces withUserContext / withAdminContext / withSystemContext wrappers; forbids direct ORM calls."
resource: ".claude/skills/rls-patterns/SKILL.md"
tags: [skills, security, patterns, gates]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".agents/skills/rls-patterns/SKILL.md"
  - ".claude/skills/rls-patterns/README.md"
verified_against: "fd0fc6a"
---

# Skill: rls-patterns

The rule that no database call escapes a row-level-security context, and the three helpers that are
the only sanctioned way to make one.

## Overview

Model-invoked only — `user-invocable: false` with `allowed-tools` limited to `Read`, `Grep`, and
`Glob`, so it shapes behaviour but cannot write or execute. It fires whenever a role is about to
touch data access: ORM code, API routes that read or write, and webhook handlers. Nine H2s carry
it, including Critical Rules, Context Helper Reference, Protected Tables, and Testing Requirements.

The three helpers it names are the ones actually enforced across the harness: `withUserContext`,
`withAdminContext`, and `withSystemContext`. Direct ORM client calls are prohibited outright. The
two surfaces are close in size (219 lines against 212) but differ in concreteness: `.agents`
replaces concrete imports with `{{AUTH_IMPORT}}`, `{{DB_IMPORT}}`, and `{{RLS_IMPORT}}` tokens.

## Routes To

- `withUserContext`, `withAdminContext`, `withSystemContext` — the mandated call wrappers.
- The RLS test and validation commands, tokenized on the portable surface.

The Claude copy points at `scripts/rls-phase4-final-validation.sql` and
`scripts/test-rls-phase3-simple.js`; neither exists on disk. The `.agents` copy drops both for
`{{RLS_TEST_COMMAND}}` and `{{RLS_VALIDATION_COMMAND}}`, so the portable surface is the accurate one.

Related: [User Context API](../patterns/user-context-api.md),
[Admin Context API](../patterns/admin-context-api.md), [RLS Migration](../patterns/rls-migration.md).

## Used By Roles

| Role | Why it loads this skill |
| --- | --- |
| [BE Developer](../roles/be-developer.md) | every data-access path in API routes and handlers |
| [Data Engineer](../roles/data-engineer.md) | schema and migration work that defines the policies |
| [System Architect](../roles/system-architect.md) | reviewing that no path bypasses a helper |

Three roles name it directly — behind safe-workflow's six and pattern-discovery's five.

## Citations

- [RLS_IMPLEMENTATION_GUIDE.md](../../database/RLS_IMPLEMENTATION_GUIDE.md) — the helper contract.
- [RLS_POLICY_CATALOG.md](../../database/RLS_POLICY_CATALOG.md) — the protected-table inventory.
