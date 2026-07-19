---
type: agent-role
title: "Data Engineer - Schema and Migrations"
description: "Owns schema changes and migrations; cannot apply a migration without explicit ARCHitect approval."
resource: ".claude/agents/data-engineer.md"
tags: [methodology, agents, gates, patterns, process]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".codex/agents/data-engineer.toml"
  - "agent_providers/claude_code/prompts/data-engineer.md"
verified_against: "fd0fc6a"
---

# Data Engineer - Schema and Migrations

The only role whose output is irreversible in production, and the only one gated on a human twice.

## Overview

The role implements schema changes and migrations from database patterns. Its distinguishing
constraint is a hard approval gate: applying a migration without ARCHitect approval is an explicit
must-not, and executing a production migration additionally requires the repository owner to be
present. Everything else about the role — pattern-first execution, atomic commits, a green
validation loop — is shared with the other implementation roles.

## Responsibilities

- Owns schema changes, migration files, and commits of the form `feat(db): ... [{{TICKET_PREFIX}}-XXX]`.
- Owns the production migration plan, built on the Tech Writer's migration checklist template,
  plus schema impact analysis, retention policy, and RLS policy updates.
- Does not apply migrations without documented ARCHitect approval in the ticket.
- Does not create PRs, merge to `dev` or `master`, or invent acceptance criteria.

## Skills & SOPs

- [migration-patterns](../skills/migration-patterns.md) — migration authoring and rollout.
- [rls-patterns](../skills/rls-patterns.md) — the context helpers and policy expectations.
- [pattern-discovery](../skills/pattern-discovery.md) — the pre-implementation search.
- [safe-workflow](../skills/safe-workflow.md) — branch, commit, and rebase sequence.

## Handoffs

- **Receives from** [BSA](bsa.md) — a spec with AC/DoD covering the schema change.
- **Hands off to** [QAS](qas.md) — exit state `Ready for QAS`, only after ARCHitect approval is
  recorded. The exit checklist requires the migration tested locally, RLS verified as enabled,
  type-check and lint green, migration files attached to Linear, and the data dictionary updated.
- **Escalates** anything touching the security model or core schema shape to ARCHitect.

The provider mirror is stale: it drops the declared skills block and downgrades the model, so the
provider variant loads none of the skills above automatically.

## Citations

- [Data Dictionary](../../database/DATA_DICTIONARY.md) — schema source of truth it must update.
- [RLS Policy Catalog](../../database/RLS_POLICY_CATALOG.md) — policy expectations per table.
- [AGENTS.md](../../../AGENTS.md) — role roster and invocation patterns.
