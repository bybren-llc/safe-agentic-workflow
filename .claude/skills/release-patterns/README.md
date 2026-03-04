# Release Patterns

![Status](https://img.shields.io/badge/status-production-green)
![Harness](https://img.shields.io/badge/harness-{{HARNESS_VERSION}}-blue)

> PR creation, CI/CD validation, and release coordination patterns.

## License

**License:** MIT (see [/LICENSE](/LICENSE))
**Copyright:** © 2026 {{AUTHOR_NAME}} ([@{{AUTHOR_HANDLE}}](https://github.com/{{AUTHOR_HANDLE}})) / [{{COMPANY_NAME}}](https://github.com/{{GITHUB_ORG}})
**Attribution:** Required per [/NOTICE](/NOTICE)

## Intellectual Property

The skill system architecture and {{PROJECT_SHORT}} harness methodology are the intellectual property of {{AUTHOR_NAME}} and {{COMPANY_NAME}}.

## Quick Start

This skill activates automatically when you:
- Create pull requests
- Run pre-PR validation (`yarn ci:validate`)
- Check CI/CD status
- Coordinate merge timing

## What This Skill Does

Ensures consistent PR creation with proper ticket references, validates CI/CD pipelines pass before merge, and coordinates release timing. Enforces rebase-first workflow with linear history.

## Trigger Keywords

| Primary | Secondary |
|---------|-----------|
| release | merge |
| CI | CD |
| deploy | pipeline |
| PR create | ci:validate |

## Related Skills

- [safe-workflow](../safe-workflow/) - Branch naming and commit format
- [deployment-sop](../deployment-sop/) - Post-merge deployment procedures

## Maintenance

| Field | Value |
|-------|-------|
| Last Updated | 2026-01-04 |
| Harness Version | {{HARNESS_VERSION}} |

---

*Full implementation details in [SKILL.md](SKILL.md)*
