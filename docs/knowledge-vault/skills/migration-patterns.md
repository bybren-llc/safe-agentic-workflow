---
type: skill
title: "Skill: migration-patterns"
description: "Database migration workflow with mandatory RLS policies, GRANTs and ARCHitect approval before production."
resource: ".claude/skills/migration-patterns/SKILL.md"
tags: [skills, security, gates, process]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".claude/skills/migration-patterns/SKILL.md"
  - ".agents/skills/migration-patterns/SKILL.md"
  - ".claude/skills/migration-patterns/README.md"
  - ".claude/agents/data-engineer.md"
  - "docs/database/RLS_DATABASE_MIGRATION_SOP.md"
  - "docs/database/DATA_DICTIONARY.md"
  - "docs/database/RLS_POLICY_CATALOG.md"
verified_against: "fd0fc6a"
---

# Skill: migration-patterns

The schema-change card: no migration ships without RLS policies, GRANTs, and an architect signature.

## Overview

User-invocable only — `disable-model-invocation: true`, no `argument-hint`, and `allowed-tools` of
`Read`, `Bash`, `Grep`, and `Glob`. Like deployment-sop it is absent from the model's runtime skill
listing, so a human starts it. Eight H2 sections carry a mandatory workflow, RLS policy templates, a
checklist, and production requirements. The gate is the point: a table's security properties are
decided with the table, not after it.

## Routes To

- `docs/database/RLS_DATABASE_MIGRATION_SOP.md` — the authoritative migration procedure.
- `docs/database/DATA_DICTIONARY.md` — the schema source of truth.
- `docs/database/RLS_POLICY_CATALOG.md`, `docs/database/RLS_IMPLEMENTATION_GUIDE.md` — policy and
  implementation reference. All four resolve on disk.
- DOC DRIFT: both surfaces cite `docs/guides/SECURITY_FIRST_ARCHITECTURE.md`, which does not exist; the
  file is at `docs/security/SECURITY_FIRST_ARCHITECTURE.md`, the path `CLAUDE.md` uses.

Related: [rls-migration](../patterns/rls-migration.md) and [Stop-the-Line Gate](../methodology/stop-the-line-gate.md).

## Used By Roles

- [Data Engineer](../roles/data-engineer.md) — named at line 15 of the agent definition.
- [System Architect](../roles/system-architect.md) is the approver the production gate requires — a
  human handshake, not a wired step.

Unusually, the portable copy is the longer one: `.agents` runs 196 lines to Claude's 191, one of only
four skills de-vendoring grew (with release-patterns, stripe-patterns, vault-sync). It renames "PROD
Migration Requirements" to "Production", drops `{{AUTHOR_HANDLE}}`, and adds `{{MIGRATIONS_DIR}}`.

## Citations

- [migration-patterns SKILL.md](../../../.claude/skills/migration-patterns/SKILL.md) — the authoritative procedure.
- [RLS Database Migration SOP](../../database/RLS_DATABASE_MIGRATION_SOP.md) — the governing migration standard.
- [Security-First Architecture](../../security/SECURITY_FIRST_ARCHITECTURE.md) — the real path behind the drift.
