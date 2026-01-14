# WTFB Commands

These slash commands are part of the **Words To Film By™** multi-agent harness.

## License

**License:** MIT (see [/LICENSE](/LICENSE))
**Copyright:** © 2026 J. Scott Graham ([@cheddarfox](https://github.com/cheddarfox)) / [Bybren LLC](https://github.com/bybren-llc)
**Attribution:** Required per [/NOTICE](/NOTICE)

## Intellectual Property

The command architecture and workflow methodology are intellectual property of Bybren LLC.

## Commands Included

| Command | Purpose |
|---------|---------|
| `/start-work` | Begin work on Linear ticket |
| `/pre-pr` | Run validation before PR |
| `/end-work` | Complete work session |
| `/check-workflow` | Check workflow status |
| `/remote-deploy` | Deploy to remote staging |
| `/remote-status` | Check remote Docker status |
| `/remote-health` | Remote health dashboard |
| `/remote-logs` | View remote container logs |
| `/remote-rollback` | Rollback remote deployment |
| `/local-sync` | Sync after git pull |
| `/local-deploy` | Deploy locally |
| `/quick-fix` | Fast-track small fixes |
| `/update-docs` | Update documentation |
| `/retro` | Session retrospective |
| `/sync-linear` | Sync with Linear ticket |
| `/test-pr-docker` | Test PR Docker workflow |
| `/audit-deps` | Dependency audit |
| `/search-pattern` | Search code patterns |

## YAML Frontmatter

All commands use YAML frontmatter for metadata:

```yaml
---
description: What this command does
argument-hint: [optional arguments]
---
```

This enables:

- Claude to understand command purpose
- Automated help generation
- IDE autocomplete support

For complete documentation, see [/.claude/README.md](../README.md).
