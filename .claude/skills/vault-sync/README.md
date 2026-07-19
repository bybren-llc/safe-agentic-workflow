# Vault Sync

![Status](https://img.shields.io/badge/status-production-green)
![Harness](https://img.shields.io/badge/harness-{{HARNESS_VERSION}}-blue)

> Detect and repair drift between an OKF knowledge vault and the code it describes. Regenerates only what changed, and records the sync.

## License

**License:** MIT (see [/LICENSE](/LICENSE))
**Copyright:** © 2026 J. Scott Graham ([@cheddarfox](https://github.com/cheddarfox)) / [ByBren, LLC](https://github.com/bybren-llc)
**Attribution:** Required per [/NOTICE](/NOTICE)

## Intellectual Property

The skill system architecture and {{PROJECT_SHORT}} harness methodology are the intellectual property of J. Scott Graham and ByBren, LLC.

SAFe® is a registered trademark of Scaled Agile, Inc.

## Quick Start

This skill activates automatically when you:

- Merge a significant change to schema, interfaces, workflows, or agent config
- Ask to sync, refresh, or update the knowledge vault
- Run a staleness review
- Suspect a concept has gone out of date

## What This Skill Does

Drives the five-step maintenance loop that keeps a knowledge vault trustworthy: read `baseline_sha` and diff it to HEAD across the watch-list, map changed paths back to the concepts that claim to describe them, regenerate **only** those, validate, and record the sync in the log.

Staleness is computed, not guessed — a concept is stale if and only if a file it names in `resource` or `sources` actually changed. The skill also enforces the discipline that keeps the mechanism honest: **a citation is not re-verification**, and only re-deriving a concept from source bumps its `timestamp` and `verified_against`.

## Trigger Keywords

| Primary | Secondary |
| --- | --- |
| vault | drift |
| knowledge base | stale |
| sync | Obsidian |
| concepts | verified_against |

## Related Skills

- [pattern-discovery](../pattern-discovery/) - Find existing concepts before writing new ones
- [safe-workflow](../safe-workflow/) - Branch, commit, and PR conventions
- [linear-sop](../linear-sop/) - Recording the sync against a ticket

## Maintenance

| Field | Value |
| --- | --- |
| Last Updated | 2026-07-19 |
| Harness Version | {{HARNESS_VERSION}} |

---

*Full implementation details in [SKILL.md](SKILL.md)*
