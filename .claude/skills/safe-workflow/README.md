# SAFe Workflow

![Status](https://img.shields.io/badge/status-production-green)
![Harness](https://img.shields.io/badge/harness-v2.2-blue)

> SAFe development workflow guidance including branch naming conventions, commit message format, rebase-first workflow, and CI validation.

## License

**License:** MIT (see [/LICENSE](/LICENSE))
**Copyright:** © 2026 {{AUTHOR_NAME}} ([@{{AUTHOR_HANDLE}}](https://github.com/{{AUTHOR_HANDLE}})) / [{{COMPANY_NAME}}](https://github.com/{{GITHUB_ORG}})
**Attribution:** Required per [/NOTICE](/NOTICE)

## Intellectual Property

The skill system architecture and {{PROJECT_SHORT}} harness methodology are the intellectual property of {{AUTHOR_NAME}} and {{COMPANY_NAME}}.

SAFe® is a registered trademark of Scaled Agile, Inc.

## Quick Start

This skill activates automatically when you:
- Start work on a Linear ticket (e.g., "I'm starting {{TICKET_PREFIX}}-447")
- Create a commit or branch
- Ask about PR workflow or contribution guidelines
- Reference CONTRIBUTING.md

## What This Skill Does

Enforces SAFe-compliant development workflow with proper branch naming (`{{TICKET_PREFIX}}-{number}-{description}`), standardized commit messages (type, scope, description), and rebase-first git workflow. Ensures all work is traceable to Linear tickets.

## Trigger Keywords

| Primary | Secondary |
|---------|-----------|
| branch | git workflow |
| commit | contributing |
| PR | pull request |
| Linear ticket | rebase |

## Related Skills

- [release-patterns](../release-patterns/) - PR creation and CI/CD validation
- [git-advanced](../git-advanced/) - Complex git operations (rebase, bisect)

## Maintenance

| Field | Value |
|-------|-------|
| Last Updated | 2026-01-04 |
| Harness Version | v2.2.0 |

---

*Full implementation details in [SKILL.md](SKILL.md)*
