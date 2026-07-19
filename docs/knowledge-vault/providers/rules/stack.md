---
type: guide
title: "Cursor Rules: Stack Family (10-16)"
description: "Seven glob-auto-attached Cursor rules that load when matching backend, frontend, database, test, spec, deploy, or payment files open."
tags: [providers, patterns, testing, operations]
timestamp: 2026-07-19
status: active
domain: providers
sources:
  - ".cursor/rules/10-backend-python.mdc"
  - ".cursor/rules/11-frontend-react.mdc"
  - ".cursor/rules/12-database-sql.mdc"
  - ".cursor/rules/13-testing.mdc"
  - ".cursor/rules/14-spec-creation.mdc"
  - ".cursor/rules/15-deployment.mdc"
  - ".cursor/rules/16-stripe-payments.mdc"
  - ".cursor/rules/README.md"
verified_against: "fd0fc6a"
---

# Cursor Rules: Stack Family (10-16)

These seven are the only rules in the [Cursor surface](../cursor.md) with a `globs` key, all also
`alwaysApply: false`. They attach when you open or edit a matching file and are otherwise absent —
you never invoke them, you trigger them by what you touch.

## What attaches when

- `10-backend-python.mdc` — `core/**/*.py`, `edgekit/**/*.py`. FastAPI, SQLAlchemy 2.x, Alembic.
- `11-frontend-react.mdc` — `sdk/**/*.tsx,.ts,.jsx,.js`. React 18, Electron, ShadCN, Tailwind.
- `12-database-sql.mdc` — `alembic/**`, `**/models.py`, `**/schemas.py`, `**/models/**`. Postgres
  16, migrations, RLS.
- `13-testing.mdc` — `tests/**/*.py`, `tests/**`. pytest, integration, E2E under Docker.
- `14-spec-creation.mdc` — `specs/**/*.md`, `specs_templates/**/*.md`. Templates, AC/DoD, demos.
- `15-deployment.mdc` — `docker-compose*.yml`, `Dockerfile*`, `scripts/deploy*`, `.coolify/**` and
  `scripts/dev-docker*`. Coolify deploy, smoke tests, rollback.
- `16-stripe-payments.mdc` — `core/**/billing/**`, `core/**/payments/**`, `core/**/stripe/**`,
  `**/webhook*stripe*`. Webhooks, checkout, subscriptions, idempotency, test-mode safety.

## The thing to know before you copy this harness

This family names a concrete Python/FastAPI/SQLAlchemy/Alembic stack, while root
[CLAUDE.md](../../../../CLAUDE.md) templates that territory with `{{FRONTEND_FRAMEWORK}}` and
`{{ORM_TOOL}}` and keeps Prisma-shaped migration guidance. The Cursor globs are not
tokenized, so a fork on a different stack inherits seven rules whose paths never match and whose
advice is for someone else's system. Fix the globs before wondering why no rule ever fires.

## Weight and drift

Line counts run 74 to 117; `15-deployment.mdc` and `16-stripe-payments.mdc` are the surface's two
largest rules at 117 each, still inside the README's under-200 principle.

DOC DRIFT: the README's rule-index table abbreviates the globs for 11, 12, 15, and 16 — listing
11 as `.tsx`/`.ts` when the file also matches `.jsx` and `.js`. Frontmatter is authoritative.

## Citations

- [.cursor rules README](../../../../.cursor/rules/README.md) — the rule index this page corrects.
