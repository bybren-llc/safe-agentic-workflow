# Harness Manifest Schema Reference

**Schema version**: 1.1
**File**: `.harness-manifest.yml` (repository root)
**JSON Schema**: `.harness-manifest.schema.json`
**Scope**: Multi-domain (v1.1 — provider, shared, and future release domains)

### What's New in v1.1

- **`sync_scope`**: Array of directories to sync from upstream (default: `[".claude/"]`)
- **Root-relative paths**: All paths in `renames`, `protected`, `replaced` are now repo-root-relative
- **Domain tiers**: Provider (`.claude/`, `.gemini/`, `.codex/`, `.cursor/`), Shared (`.agents/`, `dark-factory/`), Release (`docs/`, `scripts/` — deferred)
- **Backward compat**: v1.0 manifests work unchanged — paths without scope prefix are normalized by prepending `.claude/` during load

## Overview

The harness manifest declares how a downstream fork has customized the
upstream SAFe Agentic Workflow harness. When the sync script
(`scripts/sync-claude-harness.sh`) runs, it reads this manifest to:

1. **Substitute** upstream `{{PLACEHOLDER}}` tokens with the fork's values
2. **Rename** upstream file/directory paths to match the fork's structure
3. **Protect** fork-owned files from being overwritten
4. **Warn** when upstream changes to replaced files need manual review

### Backward Compatibility

If `.harness-manifest.yml` is absent, the sync script falls back to legacy
behavior: file-level copy with `.sync-exclude` pattern matching and no
automatic substitution. This ensures existing forks continue to work
without modification.

---

## Quick Start

After running `scripts/setup-template.sh`, generate your manifest:

```bash
# The setup wizard will create .harness-manifest.yml automatically
# (planned for v2.7.0 setup-template.sh integration)

# For existing forks, create manually:
cp examples/manifests/rendertrust.harness-manifest.yml .harness-manifest.yml
# Then edit identity values and customization sections
```

Validate your manifest:

```bash
# Using yq + jsonschema (Python)
pip install check-jsonschema
check-jsonschema --schemafile .harness-manifest.schema.json .harness-manifest.yml

# Using ajv (Node.js)
npx ajv-cli validate -s .harness-manifest.schema.json -d .harness-manifest.yml
```

---

## Schema Sections

### `manifest_version` (REQUIRED)

```yaml
manifest_version: "1.0"
```

Schema version string in `MAJOR.MINOR` format. The sync script uses this to
handle older manifest formats gracefully. Bump only when the schema itself
changes in a backward-incompatible way.

| Version | Description |
|---------|-------------|
| `1.0`   | Initial schema (v2.7.0). Covers identity, substitutions, renames, protected, replaced, sync. |

---

### `identity` (REQUIRED)

```yaml
identity:
  PROJECT_NAME: "RenderTrust"
  PROJECT_REPO: "rendertrust"
  PROJECT_SHORT: "REN"
  GITHUB_ORG: "ByBren-LLC"
  TICKET_PREFIX: "REN"
  MAIN_BRANCH: "dev"
  # ... all 22 setup-template.sh variables
```

Project identity values that correspond to the `{{...}}` placeholders in
`scripts/setup-template.sh`. The sync script reads these to build the full
substitution map.

**Required fields** (minimum for a valid manifest):

| Field | Description | Example |
|-------|-------------|---------|
| `PROJECT_NAME` | Human-readable project name | `"RenderTrust"` |
| `PROJECT_REPO` | GitHub repository name | `"rendertrust"` |
| `PROJECT_SHORT` | Short name or acronym | `"REN"` |
| `GITHUB_ORG` | GitHub org or username | `"ByBren-LLC"` |
| `TICKET_PREFIX` | Linear ticket prefix | `"REN"` |
| `MAIN_BRANCH` | Default branch name | `"dev"` |

**Optional fields** (all 22 from setup-template.sh):

| Field | Description | Default |
|-------|-------------|---------|
| `PROJECT_DOMAIN` | Project domain | *(none)* |
| `COMPANY_NAME` | Organization display name | *(none)* |
| `AUTHOR_NAME` | Primary author full name | *(none)* |
| `AUTHOR_FIRST_NAME` | Author first name | *(none)* |
| `AUTHOR_LAST_NAME` | Author last name | *(none)* |
| `AUTHOR_HANDLE` | Author GitHub handle | *(none)* |
| `AUTHOR_EMAIL` | Author email | *(none)* |
| `AUTHOR_WEBSITE` | Author website URL | *(none)* |
| `SECURITY_EMAIL` | Security contact email | *(none)* |
| `ARCHITECT_GITHUB_HANDLE` | Architect's GitHub handle | *(none)* |
| `LINEAR_WORKSPACE` | Linear workspace slug | *(none)* |
| `MCP_LINEAR_SERVER` | MCP server name for Linear | `"linear-mcp"` |
| `MCP_CONFLUENCE_SERVER` | MCP server name for Confluence | `"confluence-mcp"` |
| `DB_USER` | Database username | *(none)* |
| `DB_PASSWORD` | Database password | *(none)* |
| `DB_NAME` | Database name | *(none)* |
| `DB_CONTAINER` | Database container name | *(none)* |
| `DEV_CONTAINER` | Dev container name | *(none)* |
| `STAGING_CONTAINER` | Staging container name | *(none)* |
| `CONTAINER_REGISTRY` | Container registry URL | *(none)* |

**Derived values** (computed automatically by the sync script):

| Derived Variable | Computed From | Example |
|-----------------|---------------|---------|
| `TICKET_PREFIX_LOWER` | `lowercase(TICKET_PREFIX)` | `"ren"` |
| `AUTHOR_INITIALS` | `AUTHOR_FIRST_NAME[0]. AUTHOR_LAST_NAME[0].` | `"S. G."` |
| `GITHUB_REPO_URL` | `https://github.com/{GITHUB_ORG}/{PROJECT_REPO}` | `"https://github.com/ByBren-LLC/rendertrust"` |
| `HARNESS_VERSION` | Set by sync script from release tag | `"v2.7.0"` |

Derived values do not need to appear in the manifest unless you want to
override the automatic derivation.

---

### `substitutions` (OPTIONAL)

```yaml
substitutions:
  TICKET_PREFIX: "REN"
  GITHUB_ORG: "ByBren-LLC"
  PROJECT_NAME: "RenderTrust"
```

Explicit map of placeholder token name to the fork's resolved value. During
sync, every occurrence of `{{TOKEN}}` in incoming upstream files is replaced
with the corresponding value before writing to disk.

**When to use `substitutions` vs `identity`:**

- `identity` is the canonical source of all project values
- `substitutions` is only needed to override or add values not derivable
  from `identity`
- If `sync.auto_substitute` is `true` (default), the sync script
  automatically builds the substitution map from `identity` + derived values
- Use `substitutions` for custom tokens not in the standard 22

**Rules:**

- Keys must be `UPPER_SNAKE_CASE`
- Values are plain strings (no `{{...}}` wrapping)
- Substitutions are applied only to files matching `sync.substitution_extensions`
- The order of replacement follows the same "longer first" rule as
  `setup-template.sh` to avoid partial matches

---

### `renames` (OPTIONAL)

```yaml
renames:
  # File rename
  "agents/fe-developer.md": "agents/ui-engineer.md"

  # Directory rename (trailing / required)
  "skills/stripe-patterns/": "skills/payment-patterns/"
```

Map of upstream path to local path. All paths are relative to `.claude/`.

**File renames:**

When the sync script encounters an upstream file at the source path, it
writes it to the target path instead.

```
Upstream: .claude/agents/fe-developer.md
Manifest: "agents/fe-developer.md" -> "agents/ui-engineer.md"
Result:   .claude/agents/ui-engineer.md (with substitutions applied)
```

**Directory renames:**

A trailing `/` marks a directory rename. All files under the source
directory are mapped to the target directory, preserving subdirectory
structure.

```
Upstream: .claude/skills/stripe-patterns/webhook-handler.md
Manifest: "skills/stripe-patterns/" -> "skills/payment-patterns/"
Result:   .claude/skills/payment-patterns/webhook-handler.md
```

**Precedence rules:**

1. Exact file renames take precedence over directory renames
2. More specific directory renames take precedence over less specific ones
3. If no rename matches, the file keeps its upstream path

---

### `protected` (OPTIONAL)

```yaml
protected:
  - "hooks-config.json"
  - "settings.local.json"
  - "agents/custom-*.md"
```

List of glob patterns (relative to `.claude/`) that the sync script must
**never overwrite**. Protected files are completely skipped during sync.

**Use cases:**

- Fork-specific configuration files (`hooks-config.json`)
- Local settings that differ per developer (`settings.local.json`)
- Custom agents/skills not present in upstream (`agents/custom-*.md`)
- Any file where the fork's version must always be preserved

**Glob syntax:**

| Pattern | Matches |
|---------|---------|
| `*` | Any sequence of non-separator characters |
| `**` | Any sequence including path separators (recursive) |
| `?` | Any single non-separator character |
| `[abc]` | Character class |

**Interaction with renames:**

Protected patterns are evaluated against the **local** path (after rename
mapping). If a file has been renamed, use the local name in `protected`.

---

### `replaced` (OPTIONAL)

```yaml
replaced:
  - "agents/system-architect.md"
  - "AGENT_OUTPUT_GUIDE.md"
```

List of paths (relative to `.claude/`) that the fork has completely
rewritten. These files exist in both upstream and the fork, but the fork's
version is authoritative.

**Behavior during sync:**

1. The file is **not** overwritten
2. The sync script logs: `Skipped (replaced): agents/system-architect.md`
3. If the upstream version has changed since last sync, the script emits a
   warning: `WARNING: Upstream changed replaced file: agents/system-architect.md`
4. The maintainer can then manually review the upstream diff and decide
   whether to incorporate changes

**`replaced` vs `protected` -- when to use which:**

| Scenario | Use |
|----------|-----|
| File is fork-specific config (no upstream equivalent) | `protected` |
| File exists upstream but fork maintains its own version | `replaced` |
| File has minor customizations you want auto-merged | Neither -- let sync handle it with `conflict_strategy` |

---

### `sync` (OPTIONAL)

```yaml
sync:
  auto_substitute: true
  backup: true
  conflict_strategy: "prompt"
  substitution_extensions:
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

Tuning knobs for sync behavior. All fields have sensible defaults.

#### `auto_substitute` (default: `true`)

When `true`, the sync script automatically replaces `{{TOKEN}}` placeholders
in incoming upstream files using values from `identity`, `substitutions`,
and derived variables.

Set to `false` if you want to sync raw upstream files and handle
substitution separately (e.g., via a post-sync hook).

#### `backup` (default: `true`)

When `true`, the sync script creates a timestamped backup of `.claude/`
before each sync. Backups are stored at `.claude/.harness-backup/<timestamp>/`.

The three most recent backups are retained; older ones are pruned
automatically.

#### `conflict_strategy` (default: `"prompt"`)

Strategy for resolving conflicts when both upstream and local have changed a
file since the last sync:

| Strategy | Behavior |
|----------|----------|
| `upstream-wins` | Always take the upstream version (after substitution). Local changes are lost (recoverable from backup). |
| `local-wins` | Always keep the local version. Logs a warning that upstream changes were skipped. |
| `prompt` | Writes the upstream version as `<file>.upstream` alongside the local file. Maintainer resolves manually. |
| `three-way` | Attempts a three-way merge using the last-synced version as the common ancestor. Falls back to `prompt` on conflict. |

#### `substitution_extensions` (default: see above)

File extensions that substitutions are applied to. Files with extensions
**not** in this list are copied verbatim. This prevents binary file
corruption (images, compiled files, etc.).

---

## Complete Example

See the `examples/manifests/` directory for ready-to-use examples:

- **`rendertrust.harness-manifest.yml`** -- Minimal customization (no renames,
  REN prefix, dev branch, Python/FastAPI stack)
- **`keryk-ai.harness-manifest.yml`** -- Heavy customization (agent renames,
  skill directory rename, replaced files, three-way merge)

---

## Migration from Legacy Sync

If your fork currently uses `.claude/.sync-exclude` for sync management,
migrate to the manifest format:

### Step 1: Create the manifest

```bash
cp examples/manifests/rendertrust.harness-manifest.yml .harness-manifest.yml
```

### Step 2: Fill in identity values

Copy values from your `.claude/team-config.json` project section into the
manifest's `identity` section.

### Step 3: Convert .sync-exclude to protected

Each line in `.sync-exclude` becomes an entry in `protected`:

```yaml
# Before (.sync-exclude):
# hooks-config.json
# settings.local.json

# After (.harness-manifest.yml):
protected:
  - "hooks-config.json"
  - "settings.local.json"
```

### Step 4: Identify replaced files

Any file you have heavily customized that also exists upstream should go in
`replaced`. A good heuristic: if `diff .claude/<file> upstream/.claude/<file>`
shows more than 50% of lines changed, it is a replaced file.

### Step 5: Validate

```bash
check-jsonschema --schemafile .harness-manifest.schema.json .harness-manifest.yml
```

### Step 6: Keep .sync-exclude (transitional)

The `.sync-exclude` file can remain as a fallback during the v2.7.0
transition period. The sync script checks the manifest first and only falls
back to `.sync-exclude` if no manifest is found.

---

## Validation

### JSON Schema Validation

The `.harness-manifest.schema.json` file provides a JSON Schema (2020-12)
for validating manifest files. Use any YAML-aware JSON Schema validator:

```bash
# Python (check-jsonschema)
pip install check-jsonschema
check-jsonschema --schemafile .harness-manifest.schema.json .harness-manifest.yml

# Node.js (ajv-cli)
npx ajv-cli validate -s .harness-manifest.schema.json -d .harness-manifest.yml

# VS Code / IDE
# Add to .vscode/settings.json:
# "yaml.schemas": {
#   ".harness-manifest.schema.json": ".harness-manifest.yml"
# }
```

### Sync Script Validation

The sync script performs runtime validation beyond what JSON Schema catches:

- Rename targets do not collide (two sources mapping to the same target)
- Protected patterns do not overlap with replaced paths
- Identity values that are required for substitution are present
- Paths do not escape `.claude/` scope (no `../` traversal)

---

## Design Decisions

### Why YAML over JSON?

- Human readability: manifests are edited by hand, not generated
- Comments: YAML supports inline comments for documentation
- Consistency: most CI/CD and DevOps tooling uses YAML

### Why a separate manifest file vs extending `.harness-sync.json`?

- Separation of concerns: the manifest declares **what** the fork customized;
  `.harness-sync.json` tracks **when** the last sync happened
- The manifest is committed to the repository; sync metadata is ephemeral
- Different lifecycle: manifest changes rarely; sync metadata changes on
  every sync

### Why `identity` separate from `substitutions`?

- `identity` is the canonical, structured source of project values
- `substitutions` is a flat override map for edge cases
- The sync script computes derived values from `identity` automatically
- Keeping them separate avoids redundancy: identity is always present,
  substitutions are only needed for overrides

### Why paths relative to `.claude/`?

- v2.7.0 scope is `.claude/` only; this avoids scope creep
- When future versions expand scope, `manifest_version` can introduce
  a new path resolution mode
- Relative paths prevent portability issues across machines
