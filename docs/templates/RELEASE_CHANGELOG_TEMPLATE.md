# Release Changelog Template

This document describes the format and conventions for populating `HARNESS_CHANGELOG.yml` when preparing a new harness release. It serves as a human-readable companion to the machine-readable YAML schema.

## When to Update the Changelog

Update `HARNESS_CHANGELOG.yml` as part of every tagged release that modifies files within the `.claude/` directory. The changelog entry should be authored **before** the release tag is created so that downstream forks can consume it immediately upon upgrade.

## Release Entry Structure

Each release entry in the YAML file follows this structure:

```yaml
- version: "X.Y.Z"
  date: "YYYY-MM-DD"
  summary: "One-line description of the release theme."
  upgrade_doc: "docs/releases/vX.Y.Z-UPGRADE.md"  # optional
  changes:
    - path: ".claude/path/to/file"
      category: CATEGORY
      change_type: added | modified | renamed | deleted
      description: "What changed and why."
      breaking: true | false
      # Additional fields depending on category (see below)
  migration_notes:  # optional, only if breaking changes exist
    - "Free-form migration instruction for fork maintainers."
```

## Categories

Every changed file must be assigned exactly one category.

### NEW_FILE

Files added since the last release. Downstream forks can safely copy these without conflict.

```yaml
- path: ".claude/skills/new-skill/SKILL.md"
  category: NEW_FILE
  change_type: added
  description: "New skill for X capability."
  breaking: false
```

### UPDATED_FILE

Existing files that were modified. Fork maintainers should diff-review before applying.

```yaml
- path: ".claude/commands/pre-pr.md"
  category: UPDATED_FILE
  change_type: modified
  description: "Added changelog validation step."
  breaking: false
```

### METHODOLOGY

Changes that affect agent roles, skills, or standard operating procedures. These alter how agents behave and require workflow awareness during upgrade.

```yaml
- path: ".claude/agents/qas.md"
  category: METHODOLOGY
  change_type: modified
  description: "Expanded QAS gate to include regression checklist."
  breaking: false
```

### CONFIG

Changes to JSON configuration files or hook scripts. Include the `config_keys` field to document specific key paths that were added, changed, or removed.

```yaml
- path: ".claude/team-config.json"
  category: CONFIG
  change_type: modified
  description: "Added new paths entry for changelog."
  breaking: false
  config_keys:
    - key_path: "paths.changelog"
      action: added
      description: "Path to HARNESS_CHANGELOG.yml."
    - key_path: "quality_gates.changelog_check"
      action: added
      description: "New gate requiring changelog validation before release."
```

### BREAKING

Renames, deletions, or structural changes that will break downstream forks if applied without adaptation. Always include `migration_action`.

```yaml
- path: ".claude/skills/deploy-patterns/SKILL.md"
  category: BREAKING
  change_type: renamed
  description: "Renamed from deployment-sop for naming consistency."
  breaking: true
  renamed_from: ".claude/skills/deployment-sop/SKILL.md"
  migration_action: >
    Rename .claude/skills/deployment-sop/ to .claude/skills/deploy-patterns/
    in your fork. Update any references in custom scripts or configs.
```

## File Classification Heuristic

Use this table to determine the correct category for a file based on its path pattern. Override rules take precedence.

| Path Pattern | Default Category | Notes |
| --- | --- | --- |
| `.claude/agents/*.md` | METHODOLOGY | Agent role definitions |
| `.claude/skills/*/SKILL.md` | METHODOLOGY | Skill behavior definitions |
| `.claude/commands/*.md` (new) | NEW_FILE | New commands are safe to copy |
| `.claude/commands/*.md` (modified) | UPDATED_FILE | Existing commands need diff review |
| `.claude/*.json` | CONFIG | team-config, hooks-config, settings |
| `.claude/*.md` | UPDATED_FILE | README, SETUP, TROUBLESHOOTING, etc. |
| `.claude/hooks/*` | CONFIG | Hook scripts and configuration |

### Override Rules

1. **Renames and deletions** are always `BREAKING`, regardless of path pattern.
2. **New agent or skill files** use `METHODOLOGY` as the primary category (not `NEW_FILE`), because they introduce workflow changes.
3. **CONFIG changes that alter agent behavior** should note the methodology impact in their `description` field.

## Authoring Checklist

Use this checklist when writing a changelog entry for a new release:

- [ ] Set `version` to the release tag (without the "v" prefix)
- [ ] Set `date` to the actual release date (YYYY-MM-DD)
- [ ] Write a concise `summary` (one sentence, under 100 characters)
- [ ] List every changed `.claude/` file in `changes`
- [ ] Assign the correct `category` using the heuristic table above
- [ ] Set `change_type` accurately: `added`, `modified`, `renamed`, or `deleted`
- [ ] Write a `description` that explains both what changed and why
- [ ] Set `breaking: true` for any rename, deletion, or structural change
- [ ] Include `config_keys` for all CONFIG category entries
- [ ] Include `renamed_from` for all renamed files
- [ ] Include `migration_action` for all breaking changes
- [ ] Add `migration_notes` if any breaking changes exist
- [ ] Validate the YAML: `python3 -c "import yaml; yaml.safe_load(open('HARNESS_CHANGELOG.yml'))"`
- [ ] Optionally link the `upgrade_doc` if a release upgrade guide was written

## Validation

Before tagging a release, verify the changelog is valid YAML and contains an entry for the release version:

```bash
# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('HARNESS_CHANGELOG.yml'))" && echo "Valid YAML"

# Verify the target version exists in the file
grep "version:" HARNESS_CHANGELOG.yml | grep "X.Y.Z"
```

## How sync-claude-harness.sh Consumes This File

The sync script reads `HARNESS_CHANGELOG.yml` to:

1. **Identify new files** (category `NEW_FILE`) that can be copied without conflict.
2. **Flag files needing review** (category `UPDATED_FILE`, `METHODOLOGY`) for manual diff.
3. **Warn about breaking changes** (category `BREAKING`) and display migration actions.
4. **Apply config changes** (category `CONFIG`) with key-level granularity.

The `change_type` field tells the script what operation to perform:

- `added` -- Copy the file from upstream.
- `modified` -- Show a diff and prompt for review.
- `renamed` -- Move the local file and update references.
- `deleted` -- Warn the user and prompt for removal.

## Example: Complete Release Entry

```yaml
releases:
  - version: "2.7.0"
    date: "2026-04-01"
    summary: "Changelog schema, sync automation, and expanded QAS gate"
    upgrade_doc: "docs/releases/v2.7.0-UPGRADE.md"
    changes:
      - path: "HARNESS_CHANGELOG.yml"
        category: NEW_FILE
        change_type: added
        description: "Machine-readable changelog for downstream fork sync automation."
        breaking: false

      - path: ".claude/agents/qas.md"
        category: METHODOLOGY
        change_type: modified
        description: "Added regression testing checklist to QAS gate criteria."
        breaking: false

      - path: ".claude/commands/pre-pr.md"
        category: UPDATED_FILE
        change_type: modified
        description: "Added changelog validation step to pre-PR checklist."
        breaking: false

      - path: ".claude/team-config.json"
        category: CONFIG
        change_type: modified
        description: "Added changelog path and updated QAS validation command."
        breaking: false
        config_keys:
          - key_path: "paths.changelog"
            action: added
            description: "Path to HARNESS_CHANGELOG.yml for sync script."
          - key_path: "agents.qas.validation_command"
            action: changed
            description: "Now includes changelog validation in the gate."

      - path: ".claude/skills/deployment-sop/SKILL.md"
        category: BREAKING
        change_type: renamed
        description: "Renamed directory from deployment-sop to deploy-patterns."
        breaking: true
        renamed_from: ".claude/skills/deployment-sop/SKILL.md"
        migration_action: >
          Rename .claude/skills/deployment-sop/ to .claude/skills/deploy-patterns/.
          Update any references in custom scripts or agent configs.

    migration_notes:
      - >
        Forks referencing .claude/skills/deployment-sop/ by path must rename
        the directory to .claude/skills/deploy-patterns/.
```

---

*This template is part of the SAFe Agentic Workflow harness. See `HARNESS_CHANGELOG.yml` at the repository root for the live changelog.*
