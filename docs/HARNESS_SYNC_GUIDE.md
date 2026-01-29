# Claude Harness Sync Guide

This guide explains how to keep your project's `.claude/` harness directory synchronized with the upstream `{{PROJECT_REPO}}` repository.

## Overview

The `sync-claude-harness.sh` script allows projects using this harness to:

- Check for upstream updates
- Preview changes before applying
- Sync to specific versions or latest release
- Preserve project-specific customizations
- Rollback if needed

## Installation

1. Copy `scripts/sync-claude-harness.sh` to your project's `scripts/` directory:

   ```bash
   curl -o scripts/sync-claude-harness.sh \
     https://raw.githubusercontent.com/{{GITHUB_ORG}}/{{PROJECT_REPO}}/main/scripts/sync-claude-harness.sh
   chmod +x scripts/sync-claude-harness.sh
   ```

2. Initialize the sync configuration:

   ```bash
   ./scripts/sync-claude-harness.sh init
   ```

## Usage

### Check Current Status

See if updates are available:

```bash
./scripts/sync-claude-harness.sh status
```

### Preview Changes (Dry Run)

See what would change without modifying files:

```bash
./scripts/sync-claude-harness.sh sync --dry-run
```

### Sync to Latest Release

Update to the most recent tagged release:

```bash
./scripts/sync-claude-harness.sh sync --latest
```

### Sync to Specific Version

Update to a specific version:

```bash
./scripts/sync-claude-harness.sh sync --version v2.2.0
```

### View Detailed Differences

See exactly what changed between your version and upstream:

```bash
./scripts/sync-claude-harness.sh diff
```

### Rollback Changes

Restore from the automatic backup:

```bash
./scripts/sync-claude-harness.sh rollback
```

## Configuration

### Excluding Files

Project-specific files that should never be overwritten can be excluded by creating `.claude/.harness-sync.json`:

```json
{
  "exclude_patterns": [
    "hooks-config.json",
    "settings.local.json",
    "custom-agent.md"
  ],
  "project_customizations": {
    "ticket_prefix": "{{TICKET_PREFIX}}-",
    "project_name": "MyProject",
    "main_branch": "dev"
  }
}
```

### Tracked Metadata

After syncing, the script updates `.claude/.harness-sync.json` with:

- `last_synced_commit` - The exact commit hash synced
- `last_synced_version` - The version tag (e.g., v2.2.0)
- `last_synced_at` - Timestamp of the sync
- `sync_history` - History of all syncs

## Best Practices

1. **Always Preview First**: Run `--dry-run` before actual sync
2. **Review Changes**: Use `diff` to understand what's changing
3. **Commit Before Sync**: Have a clean git state before syncing
4. **Test After Sync**: Run your project's tests after syncing
5. **Keep Custom Files Excluded**: Add project-specific files to exclusions

## Backup and Recovery

The script automatically creates backups before each sync at:

```
.claude/.harness-backup/<timestamp>/
```

To restore:

```bash
./scripts/sync-claude-harness.sh rollback
# Or manually copy from backup directory
```

## Troubleshooting

### "Branch is not ahead of base"

This means your harness is already up to date. Check with:

```bash
./scripts/sync-claude-harness.sh version
```

### Merge Conflicts

If automatic merge fails:

1. The script will report conflicts
2. Manually resolve conflicts in listed files
3. Run `./scripts/sync-claude-harness.sh conflicts` to see remaining issues
4. After resolving, commit your changes

### Network Issues

If GitHub is unreachable:

```bash
# Check connectivity
curl -I https://api.github.com

# Use cached version if available
./scripts/sync-claude-harness.sh sync --offline
```

## Integration with CI/CD

Add to your CI pipeline to check for updates:

```yaml
- name: Check Harness Updates
  run: |
    ./scripts/sync-claude-harness.sh status
    if [[ $? -eq 1 ]]; then
      echo "::warning::Harness updates available"
    fi
```

## Contributing

Improvements to the sync script should be contributed back to:
https://github.com/{{GITHUB_ORG}}/{{PROJECT_REPO}}

## Version History

- **v1.0.0** - Initial release with basic sync functionality
- **v1.1.0** - Added dry-run, diff, and rollback commands
- **v1.2.0** - Added version-specific sync and exclusion patterns
