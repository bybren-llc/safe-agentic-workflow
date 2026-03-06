# {{PROJECT_SHORT}} Commands

These slash commands are part of the **{{PROJECT_NAME}}™** multi-agent harness.

## License

**License:** MIT (see [/LICENSE](/LICENSE))
**Copyright:** © 2026 {{AUTHOR_NAME}} ([@{{AUTHOR_HANDLE}}](https://github.com/{{AUTHOR_HANDLE}})) / [{{COMPANY_NAME}}](https://github.com/{{GITHUB_ORG}})
**Attribution:** Required per [/NOTICE](/NOTICE)

## Intellectual Property

The command architecture and workflow methodology are the intellectual property of {{AUTHOR_NAME}} and {{COMPANY_NAME}}.

## Commands Included (24 total)

### Workflow Commands

| Command | Purpose |
|---------|---------|
| `/start-work` | Begin work on Linear ticket |
| `/pre-pr` | Run validation before PR |
| `/release` | Full version release (merge, tag, publish, sync, cleanup) |
| `/end-work` | Complete work session |
| `/check-workflow` | Check workflow status |
| `/update-docs` | Update documentation |
| `/retro` | Session retrospective |
| `/sync-linear` | Sync with Linear ticket |
| `/quick-fix` | Fast-track small fixes |

### Local Operations

| Command | Purpose |
|---------|---------|
| `/local-sync` | Sync after git pull |
| `/local-deploy` | Deploy locally |

### Remote Operations

| Command | Purpose |
|---------|---------|
| `/remote-status` | Check remote Docker status |
| `/remote-deploy` | Deploy to remote staging |
| `/remote-health` | Remote health dashboard |
| `/remote-logs` | View remote container logs |
| `/remote-rollback` | Rollback remote deployment |

### Other Commands

| Command | Purpose |
|---------|---------|
| `/test-pr-docker` | Test PR Docker workflow |
| `/audit-deps` | Dependency audit |
| `/search-pattern` | Search code patterns |

### Deprecated Aliases

These commands are thin wrappers pointing to canonical `/remote-*` commands.

| Command | Alias For | Note |
|---------|-----------|------|
| `/check-docker-status` | `/remote-status` | Deprecated |
| `/deploy-dev` | `/remote-deploy` | Deprecated |
| `/dev-health` | `/remote-health` | Deprecated |
| `/dev-logs` | `/remote-logs` | Deprecated |
| `/rollback-dev` | `/remote-rollback` | Deprecated |

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
