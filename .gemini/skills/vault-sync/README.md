# Vault Sync

![Status](https://img.shields.io/badge/status-production-green)
![Harness](https://img.shields.io/badge/harness-{{HARNESS_VERSION}}-blue)
![Provider](https://img.shields.io/badge/provider-Gemini_CLI-orange)

> Detect and repair drift between an OKF knowledge vault and the code it describes. Regenerates only what changed, and records the sync.

## License

**License:** MIT (see [/LICENSE](/LICENSE))
**Copyright:** © 2026 J. Scott Graham ([@cheddarfox](https://github.com/cheddarfox)) / [ByBren, LLC](https://github.com/bybren-llc)
**Attribution:** Required per [/NOTICE](/NOTICE)

## Intellectual Property

The skill system architecture and {{PROJECT_SHORT}} harness methodology are the intellectual property of J. Scott Graham and ByBren, LLC.

SAFe® is a registered trademark of Scaled Agile, Inc.

## Quick Start

This skill activates automatically when you mention:

- Syncing, refreshing, or updating the knowledge vault
- Vault drift or stale concepts
- A significant merge that may have invalidated documentation

## What This Skill Does

Drives the five-step loop that keeps a knowledge vault trustworthy: diff `baseline_sha` to HEAD across the watch-list, map changed paths back to the concepts that describe them, regenerate only those, validate, and record the sync.

Staleness is computed rather than guessed — a concept is stale if and only if a file it names in `resource` or `sources` actually changed. Enforces the discipline that keeps the mechanism honest: **a citation is not re-verification**.

## Provider Compatibility

| Provider | Status |
| --- | --- |
| Gemini CLI | ✅ Native (drift detection and validation are shell commands) |
| Claude Code | ✅ Equivalent skill in `.claude/skills/` |

## Related Skills

- [pattern-discovery](../pattern-discovery/) - Find existing concepts first
- [safe-workflow](../safe-workflow/) - Workflow standards
- [linear-sop](../linear-sop/) - Recording the sync against a ticket

## Maintenance

| Field | Value |
| --- | --- |
| Last Updated | 2026-07-19 |
| Harness Version | {{HARNESS_VERSION}} |

---

*Full implementation details in [SKILL.md](SKILL.md)*
