# RLS Patterns

![Status](https://img.shields.io/badge/status-production-green)
![Harness](https://img.shields.io/badge/harness-v2.2-blue)

> Row Level Security patterns for database operations. NEVER use direct prisma calls.

## License

**License:** MIT (see [/LICENSE](/LICENSE))
**Copyright:** © 2026 {{AUTHOR_NAME}} ([@{{AUTHOR_HANDLE}}](https://github.com/{{AUTHOR_HANDLE}})) / [{{COMPANY_NAME}}](https://github.com/{{GITHUB_ORG}})
**Attribution:** Required per [/NOTICE](/NOTICE)

## Intellectual Property

The skill system architecture and {{PROJECT_SHORT}} harness methodology are the intellectual property of {{AUTHOR_NAME}} and {{COMPANY_NAME}}.

## Quick Start

This skill activates automatically when you:
- Write any Prisma database query
- Create or modify API routes that access the database
- Implement webhook handlers
- Work with user data, payments, or subscriptions

## What This Skill Does

Enforces Row Level Security (RLS) patterns for all database operations. Ensures data isolation and prevents cross-user data access at the database level. All queries MUST use `withUserContext`, `withAdminContext`, or `withSystemContext` helpers.

## Trigger Keywords

| Primary | Secondary |
|---------|-----------|
| database | prisma |
| query | RLS |
| user data | context |
| findMany | findUnique |

## Related Skills

- [api-patterns](../api-patterns/) - API route implementation
- [security-audit](../security-audit/) - Security validation
- [migration-patterns](../migration-patterns/) - Database schema changes

## Maintenance

| Field | Value |
|-------|-------|
| Last Updated | 2026-01-04 |
| Harness Version | v2.2.0 |

---

*Full implementation details in [SKILL.md](SKILL.md)*
