# Claude Harness Sync Guide

This guide explains how to keep your project's `.claude/` harness directory synchronized with the upstream `{{PROJECT_REPO}}` repository.

## Overview

The `sync-claude-harness.sh` script allows projects using this harness to:

- Check for upstream updates
- Preview changes before applying
- Sync to specific versions or latest release
- Preserve project-specific customizations via exclusion file
- Rollback if needed (automatic backups before each sync)

## Prerequisites

The sync script requires the following tools to be installed:

- **curl** - for downloading upstream tarballs and querying the GitHub API
- **node** (Node.js) - for JSON parsing and manipulation
- **gh** (GitHub CLI) - optional, used for faster release lookups when available

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

   This creates two files:
   - `.claude/.harness-sync.json` - Sync metadata and upstream configuration
   - `.claude/.sync-exclude` - File exclusion patterns (gitignore-style)

## Usage

### Check Current Status

See if updates are available:

```bash
./scripts/sync-claude-harness.sh status
```

### Show Current Version

Display the currently synced harness version:

```bash
./scripts/sync-claude-harness.sh version
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
./scripts/sync-claude-harness.sh sync --version {{HARNESS_VERSION}}
```

### View Detailed Differences

See exactly what files differ between your local version and upstream:

```bash
./scripts/sync-claude-harness.sh diff
```

### List Available Releases

See what upstream releases are available:

```bash
./scripts/sync-claude-harness.sh releases
```

### Check for Conflict Files

List any `.conflict` files remaining in the harness directory:

```bash
./scripts/sync-claude-harness.sh conflicts
```

### Rollback Changes

Restore from the most recent automatic backup:

```bash
./scripts/sync-claude-harness.sh rollback
```

## Configuration

### Excluding Files from Sync

Project-specific files that should never be overwritten are listed in `.claude/.sync-exclude`. This file uses gitignore-style patterns, one per line:

```text
# Claude Harness Sync Exclusions
# Files listed here will NEVER be overwritten by upstream sync
# Uses gitignore-style patterns

# Project-specific configurations (CONFIGS only, not scripts!)
settings.local.json
hooks-config.json

# Add any project-specific files below:
# my-custom-agent.md
```

The following files are always excluded automatically (hardcoded in the script):
- `.harness-sync.json` (sync metadata)
- `.sync-exclude` (this exclusion file itself)
- `.sync-exclude.default`
- `.harness-backup/*` (backup directory)

### Sync Metadata

The `.claude/.harness-sync.json` file stores upstream configuration and sync history. It is created by `init` and updated automatically after each sync. It tracks:

- `upstream_repo` - The GitHub repository to sync from
- `upstream_branch` - The default branch to sync from
- `last_synced_commit` - The exact commit hash of the last sync
- `last_synced_version` - The version tag or branch name synced (e.g., {{HARNESS_VERSION}})
- `last_synced_at` - Timestamp of the last sync
- `sync_history` - History of the last 10 syncs
- `project_customizations` - Project-specific settings (ticket prefix, project name, main branch)

## How Sync Works

Understanding the sync behavior is important:

1. The script downloads the upstream `.claude/` directory as a tarball
2. A backup of your current `.claude/` directory is created automatically
3. Each upstream file is compared against your local copy
4. **New files** (exist upstream but not locally) are added
5. **Modified files** (differ between upstream and local) are **overwritten with the upstream version** -- local modifications are replaced, not merged
6. **Excluded files** (listed in `.sync-exclude`) are skipped entirely
7. **Unchanged files** are left as-is
8. Sync metadata is updated in `.harness-sync.json`

**Important**: The sync does NOT perform any merge or conflict resolution. If a file has been modified both locally and upstream, the upstream version wins. Use `--dry-run` first to preview what will change, and use `rollback` if you need to restore your previous state.

## Best Practices

1. **Always Preview First**: Run `--dry-run` before actual sync
2. **Review Changes**: Use `diff` to understand what's changing
3. **Commit Before Sync**: Have a clean git state before syncing
4. **Test After Sync**: Run your project's tests after syncing
5. **Exclude Custom Files**: Add any project-specific files to `.claude/.sync-exclude`
6. **Use Version Tags**: Prefer `--version <tag>` over `--latest` for reproducibility

## Backup and Recovery

The script automatically creates a timestamped backup before each sync at:

```
.claude/.harness-backup/<timestamp>/
```

Only the 3 most recent backups are retained; older backups are pruned automatically.

To restore from the most recent backup:

```bash
./scripts/sync-claude-harness.sh rollback
# Or manually copy from the backup directory
```

## Troubleshooting

### "No releases found"

This means the upstream repository has no tagged releases. Use `--version` with a branch name or commit ref instead:

```bash
./scripts/sync-claude-harness.sh sync --version main
```

### "Failed to fetch upstream"

Check that:
1. You have network connectivity: `curl -I https://api.github.com`
2. The upstream repository is accessible
3. The ref (branch/tag) you specified exists

### Files Were Overwritten Unexpectedly

If a sync overwrote local changes you needed to keep:

1. Run `./scripts/sync-claude-harness.sh rollback` to restore from backup
2. Add the affected files to `.claude/.sync-exclude` to prevent future overwrites
3. Re-run the sync

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
