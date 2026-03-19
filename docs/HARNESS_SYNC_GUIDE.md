# Harness Sync Guide

Keep your project's harness directories synchronized with the
upstream [SAFe Agentic Workflow](https://github.com/ByBren-LLC/safe-agentic-workflow)
repository using the manifest-based sync system.

**Version**: 2.10.0 | **Scope**: Multi-domain (v2.10.0)

---

## Quick Start for Fork Maintainers

Get manifest-based sync working in five steps.

### 1. Install the sync script

```bash
curl -o scripts/sync-claude-harness.sh \
  https://raw.githubusercontent.com/ByBren-LLC/safe-agentic-workflow/template/scripts/sync-claude-harness.sh
chmod +x scripts/sync-claude-harness.sh
```

### 2. Initialize sync metadata

```bash
./scripts/sync-claude-harness.sh init
```

This creates `.harness-sync.json` at the repo root (tracks upstream version
and sync history) and `.claude/.sync-exclude` (legacy exclusion patterns).

### 3. Create your manifest

Copy the example closest to your setup and edit it:

```bash
# Minimal manifest (no renames, Python/FastAPI project)
cp examples/manifests/rendertrust.harness-manifest.yml .harness-manifest.yml

# Or: heavy customization (agent renames, replaced files, three-way merge)
cp examples/manifests/keryk-ai.harness-manifest.yml .harness-manifest.yml
```

Edit `.harness-manifest.yml` and fill in your project's identity values:

```yaml
manifest_version: "1.0"

identity:
  PROJECT_NAME: "MyProject"
  PROJECT_REPO: "my-project"
  PROJECT_SHORT: "MP"
  GITHUB_ORG: "my-org"
  TICKET_PREFIX: "MP"
  MAIN_BRANCH: "main"
```

### 4. Preview what would change

```bash
./scripts/sync-claude-harness.sh sync --dry-run --version v2.7.0
```

### 5. Sync

```bash
./scripts/sync-claude-harness.sh sync --version v2.7.0
```

Done. Your harness is updated and your project identity is preserved.

---

## How It Works

When you run `sync`, the script performs these steps in order:

1. **Load manifest** -- Reads `.harness-manifest.yml` and validates it
   against the JSON schema. If no manifest exists, sync fails with an
   error (except `--dry-run`, which is allowed for inspection).
2. **Fetch upstream** -- Downloads the upstream `.claude/` directory as a
   tarball from the specified version or branch.
3. **Apply substitutions** -- Replaces `{{PLACEHOLDER}}` tokens in upstream
   files with your manifest's identity values (e.g., `{{TICKET_PREFIX}}`
   becomes `REN`).
4. **Build sync plan** -- Enumerates every file that would be written,
   resolving renames from upstream paths to local paths.
5. **Run preflight** -- Validates scope (all files within `.claude/`),
   checks for unreplaced tokens, and confirms no protected files would be
   modified.
6. **Create backup** -- Archives your current `.claude/` directory with a
   timestamp before any changes.
7. **Apply changes** -- Copies new and modified files (or generates patches
   if `--generate-patches` is used). Skips protected and replaced files.
8. **Record provenance** -- Updates `.harness-sync.json` with the source
   commit SHA, version tag, timestamp, and file counts.

```text
Upstream repo                    Your fork
  .claude/                         .claude/
  agents/                          agents/
    fe-developer.md  ---rename-->    ui-engineer.md
    system-architect.md             system-architect.md  [replaced - skipped]
  skills/                          skills/
    stripe-patterns/ ---rename-->    payment-patterns/
  hooks-config.json                hooks-config.json    [protected - skipped]
  commands/                        commands/
    start-work.md   ---substitute-->  start-work.md ({{TICKET_PREFIX}} -> SCA)
```

---

## Scope Contract

**v2.10.0 sync operates on any domain listed in `sync_scope`.**

The sync script syncs only the directories declared in your manifest's
`sync_scope` array (default: `[".claude/"]`). All paths in the manifest
(`renames`, `protected`, `replaced`) are repo-root-relative. The preflight
safety check enforces that all target paths fall within a declared scope
domain -- any file targeting a path outside the allowed domains causes
the sync to abort. Use `--scope` to override the manifest scope for a
single run (e.g., `--scope .claude/ .gemini/`).

Files that are always excluded from sync (hardcoded):

- `.harness-sync.json` (sync metadata, repo root)
- `.harness-manifest.yml` (manifest itself, repo root)
- `.sync-exclude` (legacy exclusion patterns)
- `.sync-exclude.default`
- `.harness-backup/` (backup directory, repo root)
- `.harness-patches/` (generated patches, repo root)

---

## Creating a Manifest

The manifest file `.harness-manifest.yml` lives in your repository root.
It declares how your fork has customized the upstream harness so the sync
script can preserve those customizations automatically.

For the full schema reference, see
[HARNESS_MANIFEST_SCHEMA.md](HARNESS_MANIFEST_SCHEMA.md).

### `identity` (required)

Your project's identity values. These correspond to the `{{...}}`
placeholders from `scripts/setup-template.sh`:

```yaml
identity:
  PROJECT_NAME: "RenderTrust"
  PROJECT_REPO: "rendertrust"
  PROJECT_SHORT: "REN"
  GITHUB_ORG: "ByBren-LLC"
  TICKET_PREFIX: "REN"
  MAIN_BRANCH: "dev"
  AUTHOR_NAME: "J. Scott Graham"
  AUTHOR_HANDLE: "cheddarfox"
  AUTHOR_EMAIL: "scott@cheddarfox.com"
  # ... all 22 fields supported (6 required, 16 optional)
```

The six required fields are `PROJECT_NAME`, `PROJECT_REPO`, `PROJECT_SHORT`,
`GITHUB_ORG`, `TICKET_PREFIX`, and `MAIN_BRANCH`. The sync script derives
additional values automatically:

| Derived Variable | Computed From | Example |
| --- | --- | --- |
| `TICKET_PREFIX_LOWER` | `lowercase(TICKET_PREFIX)` | `ren` |
| `AUTHOR_INITIALS` | First letters of first/last name | `S. G.` |
| `GITHUB_REPO_URL` | `GITHUB_ORG` + `PROJECT_REPO` | `https://github.com/ByBren-LLC/rendertrust` |
| `HARNESS_VERSION` | Release tag from sync | `v2.7.0` |

### `substitutions` (optional)

Override or extend the automatic substitution map. Only needed for custom
tokens not in the standard 22 identity fields:

```yaml
substitutions:
  CUSTOM_CDN_URL: "https://cdn.myproject.com"
  INTERNAL_API_HOST: "api.internal.myproject.com"
```

Keys must be `UPPER_SNAKE_CASE`. During sync, every `{{TOKEN}}` in upstream
files is replaced with the corresponding value. Substitutions are applied
only to text files matching `sync.substitution_extensions`.

### `renames` (optional)

Map upstream file or directory paths to your fork's local paths. All paths
are relative to `.claude/`:

```yaml
renames:
  # File rename
  "agents/fe-developer.md": "agents/ui-engineer.md"
  "agents/be-developer.md": "agents/api-engineer.md"

  # Directory rename (trailing / required)
  "skills/stripe-patterns/": "skills/payment-patterns/"
```

**File renames** use exact match. When the sync script encounters
`agents/fe-developer.md` from upstream, it writes to
`agents/ui-engineer.md` locally.

**Directory renames** use prefix match with a trailing `/`. All files under
the source directory are mapped to the target directory, preserving
subdirectory structure. For example, upstream
`skills/stripe-patterns/webhook-handler.md` becomes
`skills/payment-patterns/webhook-handler.md`.

File renames take precedence over directory renames (more specific wins).

### `protected` (optional)

Glob patterns for files the sync script must never overwrite:

```yaml
protected:
  - "hooks-config.json"
  - "settings.local.json"
  - "agents/custom-*.md"
  - "skills/internal-*/**"
```

Use `protected` for fork-specific configuration files and custom files that
have no upstream counterpart. Protected patterns support `*`, `**`, `?`,
and `[abc]` character classes. Patterns are evaluated against local paths
(after rename resolution).

### `replaced` (optional)

Files that exist in both upstream and your fork, but where your fork's
version is authoritative:

```yaml
replaced:
  - "agents/system-architect.md"
  - "AGENT_OUTPUT_GUIDE.md"
```

During sync, replaced files are not overwritten. If the upstream version has
changed since the last sync, the script emits a warning so you can manually
review the upstream diff and decide whether to incorporate changes.

**When to use `protected` vs `replaced`:**

| Scenario | Use |
| --- | --- |
| Fork-specific config, no upstream equivalent | `protected` |
| Custom files you added (not in upstream) | `protected` |
| File exists upstream but you maintain your own version | `replaced` |

### `sync` (optional)

Tuning knobs for sync behavior:

```yaml
sync:
  auto_substitute: true          # Apply {{TOKEN}} replacement (default: true)
  backup: true                   # Create backup before sync (default: true)
  conflict_strategy: "prompt"    # How to handle conflicts (default: "prompt")
  substitution_extensions:       # File types to apply substitutions to
    - ".md"
    - ".json"
    - ".yml"
    - ".yaml"
    - ".sh"
    - ".py"
    - ".ts"
    - ".mjs"
    - ".txt"
    - ".toml"
```

Conflict strategies:

| Strategy | Behavior |
| --- | --- |
| `upstream-wins` | Always take upstream version. Local changes recoverable from backup. |
| `local-wins` | Always keep local version. Logs a warning about skipped upstream changes. |
| `prompt` | Writes upstream version as `<file>.upstream` for manual review. |
| `three-way` | Attempts three-way merge using last-synced version as base. Falls back to `prompt` on conflict. |

---

## Commands Reference

All commands are run from your project root.

### `init` -- Initialize sync configuration

```bash
./scripts/sync-claude-harness.sh init
```

Creates `.harness-sync.json` (repo root) and `.claude/.sync-exclude`. Run
this once after installing the sync script.

### `status` -- Show sync status

```bash
./scripts/sync-claude-harness.sh status
```

Displays the last synced version, checks for newer releases, and shows
manifest summary (rename count, protected count, conflict strategy).

### `version` -- Show current harness version

```bash
./scripts/sync-claude-harness.sh version
```

Outputs one line: `Harness v2.7.0 (synced 2026-03-17)`.

### `diff` -- Show detailed differences

```bash
./scripts/sync-claude-harness.sh diff
./scripts/sync-claude-harness.sh diff v2.7.0
```

Compares your local `.claude/` against upstream. Labels each file:

| Label | Meaning |
| --- | --- |
| `NEW` | Exists upstream, not locally |
| `MODIFIED` | Differs between upstream and local |
| `LOCAL ONLY` | Exists locally, not upstream |
| `EXCLUDED` | Matched by `.sync-exclude` pattern |
| `PROTECTED` | Matched by manifest `protected` pattern |
| `RENAMED` | Directory rename summary with file count |

Renames are shown as `local-path (upstream: original-path)`.

### `sync` -- Sync from upstream

```bash
# Sync to specific version (recommended)
./scripts/sync-claude-harness.sh sync --version v2.7.0

# Sync to latest release
./scripts/sync-claude-harness.sh sync --latest

# Preview without changes
./scripts/sync-claude-harness.sh sync --dry-run --version v2.7.0
```

**Sync options:**

| Flag | Purpose |
| --- | --- |
| `--version <tag>` | Sync to a specific release tag (e.g., `v2.7.0`) |
| `--latest` | Sync to the most recent tagged release |
| `--dry-run` | Preview changes without modifying any files |
| `--scope <dirs...>` | Override manifest `sync_scope` for this run (e.g., `--scope .claude/ .gemini/`) |
| `--no-placeholders` | Skip placeholder substitution (sync raw upstream files) |
| `--skip-preflight` | Bypass preflight safety checks (advanced users only) |
| `--generate-patches` | Generate `.patch` files instead of overwriting (see below) |

### `releases` -- List available releases

```bash
./scripts/sync-claude-harness.sh releases
```

### `conflicts` -- List unresolved conflicts

```bash
./scripts/sync-claude-harness.sh conflicts
```

Lists any `.upstream` or `.conflict` files remaining in synced domains.

### `rollback` -- Restore from backup

```bash
./scripts/sync-claude-harness.sh rollback
```

Restores from the most recent timestamped backup at
`.harness-backup/<domain>/<timestamp>/`. The three most recent backups per
domain are retained; older ones are pruned automatically.

---

## Features

### Rename-Aware Diffing

When your manifest declares renames, the `diff` and `sync` commands map
upstream paths to their local equivalents automatically. This means the
script compares the right files even when your fork has reorganized the
directory structure.

For example, with this rename:

```yaml
renames:
  "agents/fe-developer.md": "agents/ui-engineer.md"
```

The `diff` command compares upstream `agents/fe-developer.md` against your
local `agents/ui-engineer.md` and reports:

```text
MODIFIED  agents/ui-engineer.md (upstream: agents/fe-developer.md)
```

Directory renames show a summary line:

```text
RENAMED  skills/stripe-patterns/ -> skills/payment-patterns/ (4 files)
```

The sync script validates rename sources against the fetched upstream tree.
If a rename source path does not exist upstream (possible after an upstream
restructuring), a warning is emitted.

### Placeholder Substitution

The substitution engine replaces `{{PLACEHOLDER}}` tokens in incoming
upstream files with your fork's identity values before writing to disk.
This prevents upstream methodology updates from reverting your project
name, ticket prefix, or other identity values.

How it works:

1. The sync script builds a substitution map from `identity` + `substitutions`
   + derived values.
2. Keys are sorted by length descending (longest-match-first) to prevent
   partial matches. For example, `{{GITHUB_REPO_URL}}` is replaced before
   `{{GITHUB_ORG}}`.
3. Each `{{KEY}}` token in text files is replaced with the corresponding
   value via `sed`.
4. Only files with extensions listed in `sync.substitution_extensions` are
   processed. Binary files are always copied verbatim.

To skip substitution for a single sync (useful for debugging):

```bash
./scripts/sync-claude-harness.sh sync --no-placeholders --version v2.7.0
```

To disable substitution permanently, set `sync.auto_substitute: false` in
your manifest.

### Protected Files

The `protected` section in your manifest lists glob patterns for files that
must never be overwritten. Protection is enforced at three points:

1. **During sync** -- Protected files are skipped entirely, even if upstream
   has changes.
2. **During preflight** -- If the sync plan would modify a protected file,
   the preflight check aborts the sync.
3. **During diff** -- Protected files are labeled `PROTECTED` instead of
   `MODIFIED`.

Protected patterns support full glob syntax (`*`, `**`, `?`, `[abc]`).
Patterns from the manifest and `.sync-exclude` are merged, with the manifest
checked first.

The sync script also validates protected patterns against your local
`.claude/` directory. If a pattern does not match any local file, a warning
is emitted (possible typo).

### Preflight Safety Check

Before every sync, an automatic preflight check validates three conditions:

**(a) Scope check** -- All target files are within a declared `sync_scope`
domain. Any path containing `../` or targeting outside the allowed domains
causes an abort.

**(b) Token check** -- After substitution, no manifest keys remain as
unreplaced `{{KEY}}` tokens. Each violation is reported with file and line
number. This check is skipped when `--no-placeholders` is used.

**(c) Protected check** -- None of the target files match a protected
pattern.

If any check fails, the sync aborts with clear error messages and no files
are modified:

```text
[ERROR] Preflight failed: 2 issue(s) found
  agents/system-architect.md: would modify protected file
  commands/start-work.md:12: unreplaced token {{PROJECT_NAME}}
[INFO] Use --skip-preflight to bypass (advanced users only)
```

To bypass preflight (not recommended for normal use):

```bash
./scripts/sync-claude-harness.sh sync --skip-preflight --version v2.7.0
```

### Provenance Tracking

After each sync, `.harness-sync.json` (at repo root) records full provenance:

```json
{
  "last_sync_commit": "abc1234def5678...",
  "last_sync_version": "v2.7.0",
  "last_sync_timestamp": "2026-03-17T14:30:00Z",
  "sync_history": [
    {
      "commit": "abc1234def5678...",
      "version": "v2.7.0",
      "synced_at": "2026-03-17T14:30:00Z",
      "files_updated": 12,
      "files_skipped": 3,
      "conflicts": 0,
      "source_commit_sha": "abc1234def5678...",
      "upstream_version": "v2.7.0",
      "sync_timestamp": "2026-03-17T14:30:00Z"
    }
  ]
}
```

The `sync_history` array retains the last 10 sync entries, giving you a
complete audit trail of when, what version, and how many files were touched
in each sync.

### Patch Generation Mode

Instead of overwriting files directly, generate unified diff patches for
manual review and selective application:

```bash
./scripts/sync-claude-harness.sh sync --generate-patches --version v2.7.0
```

Patches are written to `.harness-patches/v2.7.0/` with an
`APPLY_ORDER.md` summary that groups patches by category (`NEW`,
`UPDATED`) and lists `git apply` commands in recommended order.

Patch characteristics:

- **Rename-aware** -- Patch headers use your fork's local paths, not
  upstream paths.
- **Substitution-aware** -- Patches contain your fork's placeholder values,
  not upstream `{{TOKENS}}`.
- **Valid for `git apply`** -- Each `.patch` file can be checked and applied
  individually.

Apply patches selectively:

```bash
# Dry-run check (recommended first)
git apply --check .harness-patches/v2.7.0/0001-agents-ui-engineer.patch

# Apply a single patch
git apply .harness-patches/v2.7.0/0001-agents-ui-engineer.patch

# Apply all patches in order
for patch in .harness-patches/v2.7.0/*.patch; do
  git apply "$patch"
done
```

---

## Migration from `.sync-exclude`

If your fork currently uses `.claude/.sync-exclude` for sync management
(the pre-manifest approach), follow these steps to adopt the manifest.

### Step 1: Create the manifest

```bash
cp examples/manifests/rendertrust.harness-manifest.yml .harness-manifest.yml
```

### Step 2: Fill in identity values

Copy your project values from `.claude/team-config.json` or from the
variables you used with `scripts/setup-template.sh` into the manifest's
`identity` section.

### Step 3: Convert `.sync-exclude` to `protected`

Each line in your `.sync-exclude` becomes an entry in the manifest's
`protected` array:

```yaml
# Before (.claude/.sync-exclude):
# hooks-config.json
# settings.local.json

# After (.harness-manifest.yml):
protected:
  - "hooks-config.json"
  - "settings.local.json"
```

### Step 4: Identify replaced files

Any file you have heavily customized that also exists upstream belongs in
`replaced`. A good heuristic: if running `diff .claude/<file>` against the
upstream version shows more than 50% of lines changed, list it as replaced.

### Step 5: Validate

```bash
# Using check-jsonschema (Python)
pip install check-jsonschema
check-jsonschema --schemafile .harness-manifest.schema.json .harness-manifest.yml

# Using ajv (Node.js)
npx ajv-cli validate -s .harness-manifest.schema.json -d .harness-manifest.yml
```

### Step 6: Keep `.sync-exclude` during transition

The sync script checks the manifest first and only falls back to
`.sync-exclude` when no manifest is found. During the transition period,
you can keep both files. Once you have confirmed the manifest works
correctly, the `.sync-exclude` entries are redundant (though they are
still merged for backward compatibility).

---

## Troubleshooting

### "No releases found"

The upstream repository has no tagged releases yet. Use `--version` with a
branch name instead:

```bash
./scripts/sync-claude-harness.sh sync --version template
```

### "Failed to fetch upstream"

Check that:

1. You have network connectivity: `curl -I https://api.github.com`
2. The upstream repository is accessible (not private, or you have auth)
3. The ref (branch/tag) you specified exists in the upstream repo

### Files were overwritten unexpectedly

1. Run `./scripts/sync-claude-harness.sh rollback` to restore from backup.
2. Add the affected files to the `protected` section of your manifest.
3. Re-run the sync.

### Preflight fails with "unreplaced token"

Your manifest `identity` section is missing a value that appears as
`{{TOKEN}}` in upstream files. Add the missing key to `identity` or
`substitutions`:

```yaml
identity:
  MISSING_KEY: "your-value"
```

If the token is intentional (you want to keep it as a placeholder), use
`--skip-preflight` for that sync.

### Rename source not found in upstream

The `diff` and `sync` commands validate rename source paths against the
fetched upstream tree. If a rename source no longer exists upstream (the
file was moved or deleted), update your manifest's `renames` section to
match the new upstream path structure.

### Protected pattern matches nothing

The sync script warns when a `protected` pattern does not match any file
in your local `.claude/` directory. This is usually a typo in the glob
pattern. Verify the pattern matches the intended files:

```bash
# List files matching the pattern
ls .claude/agents/custom-*.md
```

### Manifest validation fails

Run the JSON schema validator for detailed errors:

```bash
check-jsonschema --schemafile .harness-manifest.schema.json .harness-manifest.yml
```

Common issues:

- Missing required `identity` fields (`PROJECT_NAME`, `PROJECT_REPO`,
  `PROJECT_SHORT`, `GITHUB_ORG`, `TICKET_PREFIX`, `MAIN_BRANCH`)
- Rename targets that collide (two sources mapping to the same target)
- `manifest_version` not in `MAJOR.MINOR` format

---

## FAQ

### Do I need a manifest to use the sync script?

Yes. As of v2.10.0, a manifest is required. Without one, sync fails with
an error (except `--dry-run`, which is allowed for inspection). Run
`./scripts/sync-claude-harness.sh manifest init` to auto-generate one
from your project state.

### What happens if upstream restructures files I have renamed?

The sync script validates rename sources against the fetched upstream tree.
If a source path no longer exists, you get a warning. Update your
`renames` section to map the new upstream path to your local path.

### Can I use both `.sync-exclude` and the manifest?

Yes. When a manifest is present, both sources are merged. The manifest's
`protected` patterns are checked first, then `.sync-exclude` patterns.
Duplicates are de-duplicated.

### How do I sync without applying substitutions?

Use the `--no-placeholders` flag:

```bash
./scripts/sync-claude-harness.sh sync --no-placeholders --version v2.7.0
```

This syncs raw upstream files without replacing `{{TOKEN}}` placeholders.
The preflight token check is automatically skipped in this mode.

### What is the difference between `--dry-run` and `--generate-patches`?

`--dry-run` shows what would change but writes nothing.
`--generate-patches` writes `.patch` files that you can review and apply
selectively with `git apply`. Use `--dry-run` for a quick overview, and
`--generate-patches` when you want fine-grained control over which changes
to accept.

### Where are backups stored?

At `.harness-backup/<domain>/<timestamp>/` (repo root). The three most
recent backups per domain are kept; older ones are pruned automatically
after each sync.

### Can the sync script modify files outside `.claude/`?

Yes, as of v2.10.0. The sync script operates on any domain listed in your
manifest's `sync_scope` (e.g., `.claude/`, `.gemini/`, `.codex/`). The
preflight check enforces that all paths fall within declared scope domains
-- any path traversal attempt (e.g., `../`) or write to an undeclared
domain aborts the sync immediately.

### How do I validate my manifest before syncing?

Use a JSON Schema validator:

```bash
# Python
check-jsonschema --schemafile .harness-manifest.schema.json .harness-manifest.yml

# Node.js
npx ajv-cli validate -s .harness-manifest.schema.json -d .harness-manifest.yml
```

The sync script also performs runtime validation beyond what the schema
catches (rename collisions, missing identity values, path escapes).

---

## Prerequisites

The sync script requires:

- **curl** -- downloading upstream tarballs and querying the GitHub API
- **node** (Node.js) -- JSON parsing, manifest loading, and YAML processing
- **gh** (GitHub CLI) -- optional, used for faster release lookups when
  available

---

## Integration with CI/CD

Check for harness updates in your CI pipeline:

```yaml
- name: Check Harness Updates
  run: |
    ./scripts/sync-claude-harness.sh status
    if [[ $? -eq 1 ]]; then
      echo "::warning::Harness updates available"
    fi
```

Validate manifest on every PR:

```yaml
- name: Validate Harness Manifest
  run: |
    pip install check-jsonschema
    check-jsonschema --schemafile .harness-manifest.schema.json .harness-manifest.yml
```

---

## File Reference

| File | Location | Purpose |
| --- | --- | --- |
| Sync script | `scripts/sync-claude-harness.sh` | The sync tool itself |
| Manifest | `.harness-manifest.yml` | Fork customization declaration (repo root) |
| JSON Schema | `.harness-manifest.schema.json` | Manifest validation schema |
| Sync metadata | `.harness-sync.json` | Provenance and sync history (repo root) |
| Legacy exclusions | `.claude/.sync-exclude` | Pre-manifest exclusion patterns |
| Backups | `.harness-backup/<domain>/` | Timestamped pre-sync backups (repo root) |
| Patches | `.harness-patches/<version>/` | Generated patch files (repo root) |
| Schema docs | `docs/HARNESS_MANIFEST_SCHEMA.md` | Full schema reference |
| Example (minimal) | `examples/manifests/rendertrust.harness-manifest.yml` | No renames, REN prefix |
| Example (advanced) | `examples/manifests/keryk-ai.harness-manifest.yml` | Renames, replaced files |

---

## Contributing

Improvements to the sync script should be contributed back to the upstream
repository: <https://github.com/ByBren-LLC/safe-agentic-workflow>
