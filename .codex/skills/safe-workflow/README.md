# SAFe Workflow

![Status](https://img.shields.io/badge/status-production-green)
![Harness](https://img.shields.io/badge/harness-{{HARNESS_VERSION}}-blue)
![Provider](https://img.shields.io/badge/provider-Codex_CLI-purple)

> SAFe development workflow guidance including branch naming conventions, commit message format, rebase-first workflow, and CI validation. Use when starting work on a Linear ticket, preparing commits, creating branches, writing PR descriptions, or asking about contribution guidelines.

## License

**License:** MIT (see [/LICENSE](/LICENSE))
**Copyright:** (c) 2026 J. Scott Graham ([@cheddarfox](https://github.com/cheddarfox)) / [ByBren, LLC](https://github.com/bybren-llc)
**Attribution:** Required per [/NOTICE](/NOTICE)

## Intellectual Property

The skill system architecture and {{PROJECT_SHORT}} harness methodology are the intellectual property of J. Scott Graham and ByBren, LLC.

SAFe is a registered trademark of Scaled Agile, Inc.

## Quick Start

This skill provides context for:
- Branch naming, commits, PRs
- Linear tickets
- Contributing guidelines

Load via: `codex --instructions .codex/skills/safe-workflow/SKILL.md`

## What This Skill Does

Enforces SAFe-compliant development workflow with proper branch naming, standardized commit messages, and rebase-first git workflow.

## Provider Compatibility

| Provider | Status |
|----------|--------|
| Codex CLI | Native |
| Claude Code | Equivalent skill in `.claude/skills/` |
| Gemini CLI | Equivalent skill in `.gemini/skills/` |

## Related Skills

- [pattern-discovery](../pattern-discovery/) - Pattern library search
- [testing-patterns](../testing-patterns/) - Test patterns

## Maintenance

| Field | Value |
|-------|-------|
| Last Updated | 2026-03-18 |
| Harness Version | {{HARNESS_VERSION}} |

---

*Full implementation details in [SKILL.md](SKILL.md)*
