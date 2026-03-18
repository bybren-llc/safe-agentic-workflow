# Pattern Discovery

![Status](https://img.shields.io/badge/status-production-green)
![Harness](https://img.shields.io/badge/harness-{{HARNESS_VERSION}}-blue)
![Provider](https://img.shields.io/badge/provider-Codex_CLI-purple)

> Pattern library discovery for pattern-first development. Use BEFORE implementing any new feature, creating components, writing API routes, or adding database operations. Ensures existing patterns are checked first.

## License

**License:** MIT (see [/LICENSE](/LICENSE))
**Copyright:** (c) 2026 J. Scott Graham ([@cheddarfox](https://github.com/cheddarfox)) / [ByBren, LLC](https://github.com/bybren-llc)
**Attribution:** Required per [/NOTICE](/NOTICE)

## Intellectual Property

The skill system architecture and {{PROJECT_SHORT}} harness methodology are the intellectual property of J. Scott Graham and ByBren, LLC.

SAFe is a registered trademark of Scaled Agile, Inc.

## Quick Start

This skill provides context for:
- Before implementing new features
- When creating components or API routes
- Database operations

Load via: `codex --instructions .codex/skills/pattern-discovery/SKILL.md`

## What This Skill Does

Ensures existing patterns are checked before writing new code. Implements 'Search First, Reuse Always, Create Only When Necessary'.

## Provider Compatibility

| Provider | Status |
|----------|--------|
| Codex CLI | Native |
| Claude Code | Equivalent skill in `.claude/skills/` |
| Gemini CLI | Equivalent skill in `.gemini/skills/` |

## Related Skills

- [safe-workflow](../safe-workflow/) - SAFe development workflow
- [testing-patterns](../testing-patterns/) - Test patterns

## Maintenance

| Field | Value |
|-------|-------|
| Last Updated | 2026-03-18 |
| Harness Version | {{HARNESS_VERSION}} |

---

*Full implementation details in [SKILL.md](SKILL.md)*
