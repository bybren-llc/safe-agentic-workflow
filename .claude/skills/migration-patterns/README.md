# Migration Patterns

![Status](https://img.shields.io/badge/status-production-green)
![Harness](https://img.shields.io/badge/harness-v2.2-blue)

> Database migration creation with mandatory RLS policies and ARCHitect approval workflow.

## Quick Start

This skill activates automatically when you:
- Create database migrations
- Add new tables (all tables need RLS)
- Update Prisma schema
- Plan data migrations

## What This Skill Does

Guides database migration creation with mandatory RLS policies following security-first architecture. Ensures all new tables have proper RLS policies in the same migration file and enforces ARCHitect approval for schema changes.

## Trigger Keywords

| Primary | Secondary |
|---------|-----------|
| migration | schema |
| database | prisma |
| table | GRANT |
| RLS policy | data migration |

## Related Skills

- [rls-patterns](../rls-patterns/) - RLS implementation patterns
- [security-audit](../security-audit/) - Security validation

## Maintenance

| Field | Value |
|-------|-------|
| Last Updated | 2026-01-04 |
| Harness Version | v2.2.0 |

---

*Full implementation details in [SKILL.md](SKILL.md)*
