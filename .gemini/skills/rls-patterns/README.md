# RLS Patterns

![Status](https://img.shields.io/badge/status-production-green)
![Harness](https://img.shields.io/badge/harness-{{HARNESS_VERSION}}-blue)
![Provider](https://img.shields.io/badge/provider-Gemini_CLI-orange)

> Row Level Security patterns for database operations. Use when writing Prisma/database code, creating API routes that access data, or implementing webhooks. Enforces withUserContext, withAdminContext, or withSystemContext helpers. NEVER use direct prisma calls.

## License

**License:** MIT (see [/LICENSE](/LICENSE))
**Copyright:** © 2026 {{AUTHOR_NAME}} ([@{{AUTHOR_HANDLE}}](https://github.com/{{AUTHOR_HANDLE}})) / [{{COMPANY_NAME}}](https://github.com/{{GITHUB_ORG}})
**Attribution:** Required per [/NOTICE](/NOTICE)

## Intellectual Property

The skill system architecture and {{PROJECT_SHORT}} harness methodology are the intellectual property of {{AUTHOR_NAME}} and {{COMPANY_NAME}}.

SAFe® is a registered trademark of Scaled Agile, Inc.

## Quick Start

This skill activates automatically when you mention:
- Writing Prisma/database code
- Creating API routes
- Implementing webhooks

## What This Skill Does

Row Level Security patterns for database operations. Enforces withUserContext, withAdminContext, or withSystemContext helpers.

## Provider Compatibility

| Provider | Status |
|----------|--------|
| Gemini CLI | ✅ Native |
| Claude Code | ✅ Equivalent skill in `.claude/skills/` |

## Related Skills

- [api-patterns](../api-patterns/) - API route patterns
- [security-audit](../security-audit/) - Security validation

## Maintenance

| Field | Value |
|-------|-------|
| Last Updated | 2026-01-14 |
| Harness Version | {{HARNESS_VERSION}} |

---

*Full implementation details in [SKILL.md](SKILL.md)*
