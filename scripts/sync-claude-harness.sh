#!/bin/bash
#
# SAW Harness Sync Script
#
# Syncs harness domains from upstream repository while preserving
# project-specific customizations. Supports multi-domain sync (v2.10.0+).
#
# Usage:
#   ./scripts/sync-claude-harness.sh init              # Initialize sync config
#   ./scripts/sync-claude-harness.sh status            # Check sync status
#   ./scripts/sync-claude-harness.sh version           # Show current harness version
#   ./scripts/sync-claude-harness.sh diff              # Show detailed differences
#   ./scripts/sync-claude-harness.sh sync --dry-run    # Preview changes
#   ./scripts/sync-claude-harness.sh sync --version v2.2.0  # Sync to specific release
#   ./scripts/sync-claude-harness.sh sync --latest     # Sync to latest release
#   ./scripts/sync-claude-harness.sh sync --generate-patches --version v2.6.0  # Generate patches
#   ./scripts/sync-claude-harness.sh manifest init     # Auto-generate manifest from project state
#   ./scripts/sync-claude-harness.sh manifest validate # Validate existing manifest
#   ./scripts/sync-claude-harness.sh rollback          # Restore from backup
#   ./scripts/sync-claude-harness.sh conflicts         # List unresolved conflicts
#   ./scripts/sync-claude-harness.sh help              # Show help

set -e

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="$PROJECT_ROOT/.claude"

# New root-level locations (v2.10.0+)
SYNC_CONFIG="$PROJECT_ROOT/.harness-sync.json"
BACKUP_DIR="$PROJECT_ROOT/.harness-backup"
PATCHES_DIR="$PROJECT_ROOT/.harness-patches"
MANIFEST_FILE="$PROJECT_ROOT/.harness-manifest.yml"
MANIFEST_SCHEMA="$PROJECT_ROOT/.harness-manifest.schema.json"

# Legacy locations (v2.9.0 and earlier) — checked for migration
LEGACY_SYNC_CONFIG="$CLAUDE_DIR/.harness-sync.json"
LEGACY_BACKUP_DIR="$CLAUDE_DIR/.harness-backup"
LEGACY_PATCHES_DIR="$CLAUDE_DIR/.harness-patches"
LEGACY_MANIFEST_FILE="$CLAUDE_DIR/.harness-manifest.yml"

# Legacy exclusion files (stay in .claude/ — fallback only)
EXCLUDE_FILE="$CLAUDE_DIR/.sync-exclude"
EXCLUDE_DEFAULT="$CLAUDE_DIR/.sync-exclude.default"
TMP_DIR="/tmp/claude-harness-sync-$$"
MANIFEST_JSON=""  # Path to cached JSON parse of manifest (set by load_manifest)
HAS_MANIFEST=false

# Upstream configuration (defaults, can be overridden via config)
UPSTREAM_REPO="{{GITHUB_ORG}}/{{PROJECT_REPO}}"
UPSTREAM_BRANCH="main"
UPSTREAM_PATH=".claude"  # Legacy default; overridden by SYNC_SCOPE when manifest has sync_scope

# Multi-domain sync scope (v1.1+)
# Allowed domains — hardcoded allowlist for v2.10.0
ALLOWED_DOMAINS=(".claude" ".gemini" ".codex" ".cursor" ".agents" "dark-factory")
SYNC_SCOPE=()  # Populated by get_sync_scope() after manifest load

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Migrate metadata from .claude/ to repo root (v2.10.0 transition)
# Reads from old+new locations, writes new location only, logs once.
migrate_metadata_to_root() {
    local migrated=false

    # Migrate manifest
    if [ -f "$LEGACY_MANIFEST_FILE" ] && [ ! -f "$MANIFEST_FILE" ]; then
        cp "$LEGACY_MANIFEST_FILE" "$MANIFEST_FILE"
        echo -e "${BLUE}[MIGRATE]${NC} Copied manifest to repo root: .harness-manifest.yml"
        migrated=true
    fi

    # Migrate sync config
    if [ -f "$LEGACY_SYNC_CONFIG" ] && [ ! -f "$SYNC_CONFIG" ]; then
        cp "$LEGACY_SYNC_CONFIG" "$SYNC_CONFIG"
        echo -e "${BLUE}[MIGRATE]${NC} Copied sync config to repo root: .harness-sync.json"
        migrated=true
    fi

    # Migrate backup directory
    if [ -d "$LEGACY_BACKUP_DIR" ] && [ ! -d "$BACKUP_DIR" ]; then
        cp -r "$LEGACY_BACKUP_DIR" "$BACKUP_DIR"
        echo -e "${BLUE}[MIGRATE]${NC} Copied backups to repo root: .harness-backup/"
        migrated=true
    fi

    # Migrate patches directory
    if [ -d "$LEGACY_PATCHES_DIR" ] && [ ! -d "$PATCHES_DIR" ]; then
        cp -r "$LEGACY_PATCHES_DIR" "$PATCHES_DIR"
        echo -e "${BLUE}[MIGRATE]${NC} Copied patches to repo root: .harness-patches/"
        migrated=true
    fi

    # Fallback: if new location doesn't exist but legacy does, read from legacy
    if [ ! -f "$MANIFEST_FILE" ] && [ -f "$LEGACY_MANIFEST_FILE" ]; then
        MANIFEST_FILE="$LEGACY_MANIFEST_FILE"
    fi
    if [ ! -f "$SYNC_CONFIG" ] && [ -f "$LEGACY_SYNC_CONFIG" ]; then
        SYNC_CONFIG="$LEGACY_SYNC_CONFIG"
    fi
    if [ ! -d "$BACKUP_DIR" ] && [ -d "$LEGACY_BACKUP_DIR" ]; then
        BACKUP_DIR="$LEGACY_BACKUP_DIR"
    fi
    if [ ! -d "$PATCHES_DIR" ] && [ -d "$LEGACY_PATCHES_DIR" ]; then
        PATCHES_DIR="$LEGACY_PATCHES_DIR"
    fi

    if [ "$migrated" = true ]; then
        echo -e "${BLUE}[MIGRATE]${NC} Legacy files preserved at .claude/ — safe to remove after verifying new locations."
    fi
}

# Read sync_scope from manifest. Falls back to [".claude"] if absent.
# Must be called AFTER load_manifest.
get_sync_scope() {
    SYNC_SCOPE=()
    if [ "$HAS_MANIFEST" = "true" ]; then
        # Extract sync_scope array items directly from manifest YAML
        # Avoids JSON parsing issues — reads YAML array items with simple grep/sed
        local in_scope=false
        while IFS= read -r line; do
            # Detect sync_scope: array start
            if echo "$line" | grep -q '^\s*sync_scope:'; then
                in_scope=true
                continue
            fi
            # Stop at next non-array line (not starting with -)
            if [ "$in_scope" = true ]; then
                if echo "$line" | grep -q '^\s*-'; then
                    # Extract value: strip leading whitespace, dash, quotes, trailing /
                    local domain
                    domain=$(echo "$line" | sed 's/^\s*-\s*//; s/^["'"'"']//; s/["'"'"']$//; s|/$||; s/\s*$//')
                    [ -z "$domain" ] && continue
                    # Validate against allowed domains
                    local valid=false
                    for allowed in "${ALLOWED_DOMAINS[@]}"; do
                        if [ "$domain" = "$allowed" ]; then
                            valid=true
                            break
                        fi
                    done
                    if [ "$valid" = true ]; then
                        SYNC_SCOPE+=("$domain")
                    else
                        echo -e "${YELLOW}[WARN]${NC} Ignoring unknown sync domain: $domain"
                    fi
                else
                    in_scope=false
                fi
            fi
        done < "$MANIFEST_FILE"
    fi
    # Default to .claude if no scope found
    if [ ${#SYNC_SCOPE[@]} -eq 0 ]; then
        SYNC_SCOPE=(".claude")
    fi
}

# Enumerate upstream files for a given domain in the temp directory.
# Usage: enumerate_upstream_files ".claude" | while read -r file; do ...
enumerate_upstream_files() {
    local domain="$1"
    find "$TMP_DIR/$domain" -type f -print0 2>/dev/null
}

# Check for required dependencies
check_dependencies() {
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}[ERROR]${NC} curl is required but not installed."
        echo "Install with: sudo apt install curl"
        exit 1
    fi
    if ! command -v node &> /dev/null; then
        echo -e "${RED}[ERROR]${NC} node is required but not installed."
        echo "This project requires Node.js - install via nvm or package manager"
        exit 1
    fi
}

# JSON query helper - uses node.js (guaranteed in this project)
# Usage: json_get "file.json" "key.nested.path" "default_value"
json_get() {
    local file="$1"
    local path="$2"
    local default="${3:-null}"

    if [ ! -f "$file" ]; then
        echo "$default"
        return
    fi

    node -e "
        const fs = require('fs');
        try {
            const data = JSON.parse(fs.readFileSync('$file', 'utf8'));
            const path = '$path'.split('.');
            let value = data;
            for (const key of path) {
                if (value === null || value === undefined) break;
                value = value[key];
            }
            console.log(value ?? '$default');
        } catch(e) {
            console.log('$default');
        }
    "
}

# JSON set helper - modifies a value in a JSON file
# Usage: json_set "file.json" "key" "value"
json_set() {
    local file="$1"
    local key="$2"
    local value="$3"

    if [ ! -f "$file" ]; then
        return 1
    fi

    node -e "
        const fs = require('fs');
        const data = JSON.parse(fs.readFileSync('$file', 'utf8'));
        data['$key'] = '$value';
        fs.writeFileSync('$file', JSON.stringify(data, null, 2));
    "
}

# JSON update helper - updates multiple values in a JSON file
# Usage: json_update "file.json" '{"key": "value", "key2": "value2"}'
json_update() {
    local file="$1"
    local updates="$2"

    if [ ! -f "$file" ]; then
        return 1
    fi

    node -e "
        const fs = require('fs');
        const data = JSON.parse(fs.readFileSync('$file', 'utf8'));
        const updates = $updates;
        Object.assign(data, updates);
        fs.writeFileSync('$file', JSON.stringify(data, null, 2));
    "
}

# JSON add to array helper
# Usage: json_array_prepend "file.json" "array_key" '{"item": "value"}'
json_array_prepend() {
    local file="$1"
    local key="$2"
    local item="$3"
    local max_items="${4:-10}"

    node -e "
        const fs = require('fs');
        const data = JSON.parse(fs.readFileSync('$file', 'utf8'));
        const item = $item;
        if (!data['$key']) data['$key'] = [];
        data['$key'] = [item, ...data['$key']].slice(0, $max_items);
        fs.writeFileSync('$file', JSON.stringify(data, null, 2));
    "
}

# Output functions
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_header() { echo -e "\n${CYAN}=== $1 ===${NC}\n"; }

# Cleanup temp files
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# Load configuration from .harness-sync.json
load_config() {
    if [ -f "$SYNC_CONFIG" ]; then
        UPSTREAM_REPO=$(json_get "$SYNC_CONFIG" "upstream_repo" "{{GITHUB_ORG}}/{{PROJECT_REPO}}")
        UPSTREAM_BRANCH=$(json_get "$SYNC_CONFIG" "upstream_branch" "main")
    fi
}

# =============================================================================
# Manifest Loading & Validation (SAW-6)
# =============================================================================
# When .harness-manifest.yml exists, parse it and make its data
# available to all sync commands. Falls back to legacy behavior when absent.
# =============================================================================

# Load and parse .harness-manifest.yml if present
# Sets HAS_MANIFEST=true and MANIFEST_JSON to cached JSON path on success.
# Called once during initialization; result is cached for the session.
load_manifest() {
    if [ ! -f "$MANIFEST_FILE" ]; then
        HAS_MANIFEST=false
        return 0
    fi

    # Check for python3 (required for YAML parsing)
    if ! command -v python3 &> /dev/null; then
        print_warning "python3 not found; manifest loading requires Python 3 with PyYAML"
        print_warning "Falling back to legacy sync (no manifest)"
        HAS_MANIFEST=false
        return 0
    fi

    # Parse YAML to JSON using python3 + PyYAML
    MANIFEST_JSON="$TMP_DIR/manifest.json"
    mkdir -p "$TMP_DIR"

    local parse_err=""
    local parse_rc=0
    parse_err=$(python3 -c "
import sys, json
try:
    import yaml
except ImportError:
    print('PyYAML not installed. Install with: pip install pyyaml', file=sys.stderr)
    sys.exit(1)
try:
    with open(sys.argv[1], 'r') as f:
        data = yaml.safe_load(f)
    if data is None:
        data = {}
    with open(sys.argv[2], 'w') as f:
        json.dump(data, f, indent=2)
except yaml.YAMLError as e:
    print(str(e), file=sys.stderr)
    sys.exit(2)
except Exception as e:
    print(str(e), file=sys.stderr)
    sys.exit(3)
" "$MANIFEST_FILE" "$MANIFEST_JSON" 2>&1) || parse_rc=$?

    if [ "$parse_rc" -ne 0 ]; then
        print_warning "Failed to parse manifest YAML: $parse_err"
        print_warning "Falling back to legacy sync (no manifest)"
        HAS_MANIFEST=false
        MANIFEST_JSON=""
        return 0
    fi

    HAS_MANIFEST=true
    return 0
}

# Query a value from the cached manifest JSON
# Usage: manifest_get "key.nested.path" "default_value"
manifest_get() {
    local path="$1"
    local default="${2:-}"

    if [ "$HAS_MANIFEST" != "true" ] || [ -z "$MANIFEST_JSON" ] || [ ! -f "$MANIFEST_JSON" ]; then
        echo "$default"
        return
    fi

    json_get "$MANIFEST_JSON" "$path" "$default"
}

# Get the count of entries in a manifest object or array
# Usage: manifest_count "renames" -> number of key-value pairs or array items
manifest_count() {
    local key="$1"

    if [ "$HAS_MANIFEST" != "true" ] || [ -z "$MANIFEST_JSON" ] || [ ! -f "$MANIFEST_JSON" ]; then
        echo "0"
        return
    fi

    node -e "
        const fs = require('fs');
        try {
            const data = JSON.parse(fs.readFileSync('$MANIFEST_JSON', 'utf8'));
            const val = data['$key'];
            if (Array.isArray(val)) {
                console.log(val.length);
            } else if (val && typeof val === 'object') {
                console.log(Object.keys(val).length);
            } else {
                console.log(0);
            }
        } catch(e) {
            console.log(0);
        }
    "
}

# Validate manifest against schema requirements
# Returns 0 on success, 1 on validation failure (with errors printed).
# Must be called after load_manifest().
validate_manifest() {
    if [ "$HAS_MANIFEST" != "true" ]; then
        return 0
    fi

    local errors=0
    local warnings=0

    # --- Required field: manifest_version ---
    local manifest_version
    manifest_version=$(manifest_get "manifest_version")
    if [ -z "$manifest_version" ] || [ "$manifest_version" = "null" ] || [ "$manifest_version" = "undefined" ]; then
        print_error "Manifest missing required field: manifest_version"
        errors=$((errors + 1))
    elif ! echo "$manifest_version" | grep -qE '^[0-9]+\.[0-9]+$'; then
        print_error "Manifest manifest_version must match pattern X.Y (got: $manifest_version)"
        errors=$((errors + 1))
    fi

    # --- Required field: identity (object with required sub-fields) ---
    local has_identity
    has_identity=$(node -e "
        const fs = require('fs');
        try {
            const data = JSON.parse(fs.readFileSync('$MANIFEST_JSON', 'utf8'));
            console.log(data.identity && typeof data.identity === 'object' ? 'yes' : 'no');
        } catch(e) { console.log('no'); }
    ")
    if [ "$has_identity" != "yes" ]; then
        print_error "Manifest missing required field: identity"
        errors=$((errors + 1))
    else
        # Validate required identity sub-fields per schema
        local required_identity_fields="PROJECT_NAME PROJECT_REPO PROJECT_SHORT GITHUB_ORG TICKET_PREFIX MAIN_BRANCH"
        for field in $required_identity_fields; do
            local value
            value=$(manifest_get "identity.$field")
            if [ -z "$value" ] || [ "$value" = "null" ] || [ "$value" = "undefined" ]; then
                print_error "Manifest identity missing required field: $field"
                errors=$((errors + 1))
            fi
        done
    fi

    # --- Validate rename paths (structural checks) ---
    local rename_count
    rename_count=$(manifest_count "renames")
    if [ "$rename_count" -gt 0 ]; then
        # Validate path structure: no absolute paths, no ".." traversals, no empty entries
        node -e "
            const fs = require('fs');
            try {
                const data = JSON.parse(fs.readFileSync('$MANIFEST_JSON', 'utf8'));
                const renames = data.renames || {};
                for (const [src, dst] of Object.entries(renames)) {
                    if (src.startsWith('/') || src.includes('..')) {
                        console.log('ERROR:' + src + ' (source must be relative, no ..)');
                    }
                    if (dst.startsWith('/') || dst.includes('..')) {
                        console.log('ERROR:' + dst + ' (target must be relative, no ..)');
                    }
                    if (!src || !dst) {
                        console.log('ERROR:(empty rename entry)');
                    }
                }
            } catch(e) {}
        " | while IFS= read -r line; do
            local detail="${line#ERROR:}"
            print_warning "Invalid rename: $detail"
        done

        # Count warnings from rename validation
        local rename_warnings
        rename_warnings=$(node -e "
            const fs = require('fs');
            try {
                const data = JSON.parse(fs.readFileSync('$MANIFEST_JSON', 'utf8'));
                const renames = data.renames || {};
                let count = 0;
                for (const [src, dst] of Object.entries(renames)) {
                    if (src.startsWith('/') || src.includes('..') || !src) count++;
                    if (dst.startsWith('/') || dst.includes('..') || !dst) count++;
                }
                console.log(count);
            } catch(e) { console.log(0); }
        ")
        warnings=$((warnings + rename_warnings))
    fi

    # --- Compute summary counts ---
    local sub_count protected_count replaced_count
    sub_count=$(manifest_count "substitutions")
    protected_count=$(manifest_count "protected")
    replaced_count=$(manifest_count "replaced")

    # --- Fail on errors ---
    if [ "$errors" -gt 0 ]; then
        print_error "Manifest validation failed with $errors error(s)"
        return 1
    fi

    # --- Success: report summary ---
    print_success "Manifest found: $rename_count renames, $sub_count substitutions, $((protected_count + replaced_count)) protected patterns"

    if [ "$warnings" -gt 0 ]; then
        print_warning "$warnings rename warning(s) found"
    fi

    return 0
}

# Validate rename sources against fetched upstream (call after fetch_upstream)
# Warns when a rename source path does not exist in the upstream tree.
validate_renames_against_upstream() {
    if [ "$HAS_MANIFEST" != "true" ]; then
        return 0
    fi

    local rename_count
    rename_count=$(manifest_count "renames")
    if [ "$rename_count" -eq 0 ]; then
        return 0
    fi

    # Determine upstream base: v1.1 paths are root-relative, v1.0 are .claude/-relative
    local manifest_ver
    manifest_ver=$(manifest_get "manifest_version" 2>/dev/null || echo "1.0")
    local upstream_base="$TMP_DIR/.claude"
    if [ "$manifest_ver" = "1.1" ] || [[ "$manifest_ver" > "1.1" ]]; then
        upstream_base="$TMP_DIR"
    fi

    # Check each rename source path against the fetched upstream
    node -e "
        const fs = require('fs');
        const path = require('path');
        try {
            const data = JSON.parse(fs.readFileSync('$MANIFEST_JSON', 'utf8'));
            const renames = data.renames || {};
            const upstreamBase = '$upstream_base';
            for (const [src, dst] of Object.entries(renames)) {
                const fullPath = path.join(upstreamBase, src);
                const isDir = src.endsWith('/');
                if (isDir) {
                    if (!fs.existsSync(fullPath) || !fs.statSync(fullPath).isDirectory()) {
                        console.log('WARN:' + src);
                    }
                } else {
                    if (!fs.existsSync(fullPath)) {
                        console.log('WARN:' + src);
                    }
                }
            }
        } catch(e) {}
    " | while IFS= read -r line; do
        local src_path="${line#WARN:}"
        print_warning "Rename source does not exist in upstream: $src_path"
    done
}

# =============================================================================
# End Manifest Loading & Validation
# =============================================================================

# =============================================================================
# Rename Resolution (SAW-5)
# =============================================================================
# When a manifest declares renames, these functions resolve upstream paths
# to their local equivalents. File renames take precedence over directory
# renames (more specific wins).
# =============================================================================

# Resolve an upstream relative path to its local equivalent using manifest renames.
# File renames (exact match) take precedence over directory renames (prefix match).
# Returns the resolved local path on stdout.
# Usage: resolve_rename "agents/fe-developer.md" -> "agents/ui-engineer.md"
resolve_rename() {
    local upstream_path="$1"

    if [ "$HAS_MANIFEST" != "true" ] || [ -z "$MANIFEST_JSON" ] || [ ! -f "$MANIFEST_JSON" ]; then
        echo "$upstream_path"
        return
    fi

    node -e "
        const fs = require('fs');
        try {
            const data = JSON.parse(fs.readFileSync('$MANIFEST_JSON', 'utf8'));
            const renames = data.renames || {};
            const upPath = '$upstream_path';

            // 1. Check file renames first (exact match, more specific wins)
            if (renames[upPath] !== undefined) {
                console.log(renames[upPath]);
                process.exit(0);
            }

            // 2. Check directory renames (prefix match with trailing /)
            for (const [src, dst] of Object.entries(renames)) {
                if (!src.endsWith('/')) continue;  // Skip file renames
                if (upPath.startsWith(src)) {
                    // Replace the directory prefix
                    console.log(dst + upPath.slice(src.length));
                    process.exit(0);
                }
            }

            // 3. No rename found — return original
            console.log(upPath);
        } catch(e) {
            console.log('$upstream_path');
        }
    "
}

# Check if an upstream path has a rename defined in the manifest.
# Returns "file", "directory", or "none" on stdout.
# Usage: rename_type "agents/fe-developer.md" -> "file"
#        rename_type "skills/rls-patterns/SKILL.md" -> "directory"
rename_type() {
    local upstream_path="$1"

    if [ "$HAS_MANIFEST" != "true" ] || [ -z "$MANIFEST_JSON" ] || [ ! -f "$MANIFEST_JSON" ]; then
        echo "none"
        return
    fi

    node -e "
        const fs = require('fs');
        try {
            const data = JSON.parse(fs.readFileSync('$MANIFEST_JSON', 'utf8'));
            const renames = data.renames || {};
            const upPath = '$upstream_path';

            // Check file renames first (exact match)
            if (renames[upPath] !== undefined) {
                console.log('file');
                process.exit(0);
            }

            // Check directory renames (prefix match)
            for (const [src, dst] of Object.entries(renames)) {
                if (!src.endsWith('/')) continue;
                if (upPath.startsWith(src)) {
                    console.log('directory');
                    process.exit(0);
                }
            }

            console.log('none');
        } catch(e) {
            console.log('none');
        }
    "
}

# Get all directory renames from the manifest as "src|dst" lines.
# Usage: get_directory_renames -> lines like "skills/rls-patterns/|skills/firestore-security/"
get_directory_renames() {
    if [ "$HAS_MANIFEST" != "true" ] || [ -z "$MANIFEST_JSON" ] || [ ! -f "$MANIFEST_JSON" ]; then
        return
    fi

    node -e "
        const fs = require('fs');
        try {
            const data = JSON.parse(fs.readFileSync('$MANIFEST_JSON', 'utf8'));
            const renames = data.renames || {};
            for (const [src, dst] of Object.entries(renames)) {
                if (src.endsWith('/')) {
                    console.log(src + '|' + dst);
                }
            }
        } catch(e) {}
    "
}

# Compare an upstream file to a local file at a (possibly different) path.
# Usage: compare_file_with_paths "upstream_rel_path" "local_rel_path"
# Uses DOMAIN_TMP and DOMAIN_DIR globals (set by domain loop in do_sync)
# Falls back to .claude paths when called outside domain loop (legacy compat)
compare_file_with_paths() {
    local upstream_rel_path="$1"
    local local_rel_path="$2"
    local upstream_file="${DOMAIN_TMP:-$TMP_DIR/.claude}/$upstream_rel_path"
    local local_file="${DOMAIN_DIR:-$CLAUDE_DIR}/$local_rel_path"

    if [ ! -f "$upstream_file" ]; then
        echo "deleted"
    elif [ ! -f "$local_file" ]; then
        echo "new"
    elif diff -q "$upstream_file" "$local_file" > /dev/null 2>&1; then
        echo "unchanged"
    else
        echo "modified"
    fi
}

# =============================================================================
# End Rename Resolution
# =============================================================================

# =============================================================================
# Placeholder Substitution Engine (SAW-10)
# =============================================================================
# After fetching upstream files, re-apply fork-specific values from the
# manifest substitutions section. This prevents upstream methodology updates
# from reverting the fork's project identity.
#
# Key design decisions:
#   - Substitutions sorted by key length descending (longest-match-first)
#     to prevent partial matches (e.g., {{GITHUB_REPO_URL}} before {{GITHUB_ORG}})
#   - Only explicit manifest keys are substituted (not arbitrary {{...}} patterns)
#   - Both {{PLACEHOLDER}} tokens and literal strings are supported
#   - Identity values are also applied as {{KEY}} -> value substitutions
# =============================================================================

# Apply manifest substitutions to a single file.
# Reads substitution entries from the manifest, sorts by key length descending,
# and applies sed replacements. Only substitutes keys explicitly listed in the
# manifest -- does NOT match arbitrary {{...}} patterns in content.
#
# Usage: apply_substitutions "/path/to/file"
apply_substitutions() {
    local file_path="$1"

    if [ "$HAS_MANIFEST" != "true" ] || [ -z "$MANIFEST_JSON" ] || [ ! -f "$MANIFEST_JSON" ]; then
        return 0
    fi

    if [ ! -f "$file_path" ]; then
        return 0
    fi

    # Generate sed commands from manifest substitutions + identity,
    # sorted by key length descending (longest-match-first).
    # Output format: one sed 's|...|...|g' command per line.
    local sed_commands
    sed_commands=$(node -e "
        const fs = require('fs');
        try {
            const data = JSON.parse(fs.readFileSync('$MANIFEST_JSON', 'utf8'));
            const subs = data.substitutions || {};
            const identity = data.identity || {};

            // Build combined substitution map:
            // 1. Explicit substitutions (literal key -> value)
            // 2. Identity values as {{KEY}} -> value (lower priority)
            const combined = {};

            // Identity values: add as {{KEY}} -> value
            for (const [key, value] of Object.entries(identity)) {
                if (typeof value === 'string' && value.length > 0) {
                    combined['{{' + key + '}}'] = value;
                }
            }

            // Explicit substitutions override identity-derived ones.
            // Keys can be either '{{PLACEHOLDER}}' tokens or literal strings.
            for (const [key, value] of Object.entries(subs)) {
                if (typeof value === 'string') {
                    // If the key does not already have {{ }}, also add the
                    // braced form derived from identity (already handled above).
                    // The explicit key always wins.
                    combined[key] = value;
                    // Also ensure the {{KEY}} form maps to the same value
                    if (!key.startsWith('{{')) {
                        combined['{{' + key + '}}'] = value;
                    }
                }
            }

            // Sort by key length descending (longest-match-first)
            const sortedKeys = Object.keys(combined).sort((a, b) => b.length - a.length);

            for (const key of sortedKeys) {
                const value = combined[key];
                // Escape sed BRE special characters in key and value.
                // In BRE: . * [ ] ^ $ \ are special. { } ( ) + ? are literal.
                // We use | as delimiter so escape | too.
                // Do NOT escape { } -- in BRE they are literal unescaped,
                // and \\{ \\} would activate interval expressions.
                const escKey = key.replace(/[|&\\\\\\[\\]\\^\\$\\.\\*]/g, '\\\\\\&');
                const escVal = value.replace(/[|&\\\\]/g, '\\\\\\&');
                console.log('s|' + escKey + '|' + escVal + '|g');
            }
        } catch(e) {
            // Silent failure — no substitutions applied
        }
    ")

    if [ -z "$sed_commands" ]; then
        return 0
    fi

    # Build a single sed invocation with all commands
    local sed_args=()
    while IFS= read -r cmd; do
        [ -z "$cmd" ] && continue
        sed_args+=(-e "$cmd")
    done <<< "$sed_commands"

    if [ ${#sed_args[@]} -eq 0 ]; then
        return 0
    fi

    # Apply substitutions in-place using cross-platform sed
    if sed --version 2>/dev/null | grep -q 'GNU'; then
        sed -i "${sed_args[@]}" "$file_path"
    else
        sed -i '' "${sed_args[@]}" "$file_path"
    fi
}

# Apply substitutions to all synced files in a directory.
# Walks .claude/ and applies substitutions to each file.
#
# Usage: apply_all_substitutions "/path/to/.claude"
apply_all_substitutions() {
    local claude_dir="$1"
    local count=0

    if [ "$HAS_MANIFEST" != "true" ]; then
        return 0
    fi

    local sub_count
    sub_count=$(manifest_count "substitutions")
    local identity_count
    identity_count=$(manifest_count "identity")

    if [ "$sub_count" -eq 0 ] && [ "$identity_count" -eq 0 ]; then
        return 0
    fi

    while IFS= read -r -d '' file; do
        local rel_path="${file#$claude_dir/}"

        # Skip binary files and metadata
        [[ "$rel_path" == .harness-* ]] && continue
        [[ "$rel_path" == .sync-* ]] && continue
        [[ "$rel_path" == .harness-backup* ]] && continue

        # Only process text files (by extension)
        case "$rel_path" in
            *.md|*.json|*.yml|*.yaml|*.sh|*.py|*.txt|*.toml|*.ts|*.mjs|*.bib|*.cff)
                apply_substitutions "$file"
                count=$((count + 1))
                ;;
        esac
    done < <(find "$claude_dir" -type f -print0 2>/dev/null)

    if [ "$count" -gt 0 ]; then
        print_success "Applied substitutions to $count file(s)"
    fi
}

# =============================================================================
# End Placeholder Substitution Engine
# =============================================================================

# =============================================================================
# Protected File Enforcement (SAW-3)
# =============================================================================
# The manifest `protected` section lists glob patterns (relative to .claude/)
# for files that must NEVER be modified during sync, even if upstream has
# changes. This supersedes .sync-exclude but both sources are merged for
# backward compatibility.
#
# Precedence: manifest protected patterns checked first, then .sync-exclude.
# Duplicate patterns are de-duplicated. Hardcoded metadata exclusions
# (.harness-sync.json, .harness-manifest.yml, etc.) always apply.
# =============================================================================

# Get all protected patterns from manifest and .sync-exclude (merged).
# Manifest patterns are listed first; .sync-exclude patterns appended.
# Outputs one pattern per line.
get_protected_patterns() {
    local patterns=()

    # 1. Manifest protected section (primary source)
    if [ "$HAS_MANIFEST" = "true" ] && [ -n "$MANIFEST_JSON" ] && [ -f "$MANIFEST_JSON" ]; then
        while IFS= read -r pat; do
            [ -n "$pat" ] && patterns+=("$pat")
        done < <(node -e "
            const fs = require('fs');
            try {
                const data = JSON.parse(fs.readFileSync('$MANIFEST_JSON', 'utf8'));
                const prot = data.protected || [];
                if (Array.isArray(prot)) {
                    prot.forEach(p => console.log(p));
                }
            } catch(e) {}
        ")
    fi

    # 2. .sync-exclude patterns (fallback / merged)
    if [ -f "$EXCLUDE_FILE" ]; then
        while IFS= read -r pattern || [ -n "$pattern" ]; do
            # Skip comments and empty lines
            [[ "$pattern" =~ ^#.*$ ]] && continue
            [[ -z "$pattern" ]] && continue
            [[ "$pattern" =~ ^[[:space:]]*$ ]] && continue
            # Trim whitespace
            pattern=$(echo "$pattern" | xargs)
            # De-duplicate: only add if not already present
            local already=false
            for existing in "${patterns[@]}"; do
                if [ "$existing" = "$pattern" ]; then
                    already=true
                    break
                fi
            done
            if [ "$already" = false ]; then
                patterns+=("$pattern")
            fi
        done < "$EXCLUDE_FILE"
    fi

    # Output all patterns
    for p in "${patterns[@]}"; do
        echo "$p"
    done
}

# Check if a file path matches any protected pattern (manifest + .sync-exclude merged).
# Returns 0 (true) if protected, 1 (false) otherwise.
# Usage: is_protected "path/to/file.md"
is_protected() {
    local file="$1"

    # Always protect sync metadata, manifest, and backups (hardcoded)
    [[ "$file" == .harness-sync.json ]] && return 0
    [[ "$file" == .harness-manifest.yml ]] && return 0
    [[ "$file" == .sync-exclude ]] && return 0
    [[ "$file" == .sync-exclude.default ]] && return 0
    [[ "$file" == .harness-backup* ]] && return 0

    # Check against merged protected patterns
    while IFS= read -r pattern; do
        [ -z "$pattern" ] && continue
        # Glob match (supports *, **, ?)
        if [[ "$file" == $pattern ]]; then
            return 0
        fi
        # Also check substring match for backward compat with .sync-exclude behavior
        if [[ "$file" == *"$pattern"* ]]; then
            return 0
        fi
    done < <(get_protected_patterns)

    return 1
}

# Check if a file is protected specifically by the manifest protected section
# (not counting .sync-exclude). Used for PROTECTED label distinction in diff.
# Returns 0 if manifest-protected, 1 otherwise.
is_manifest_protected() {
    local file="$1"

    if [ "$HAS_MANIFEST" != "true" ] || [ -z "$MANIFEST_JSON" ] || [ ! -f "$MANIFEST_JSON" ]; then
        return 1
    fi

    # Write JS to temp file to avoid bash escaping issues with regex
    local js_file="$TMP_DIR/_is_manifest_protected.js"
    mkdir -p "$TMP_DIR"
    cat > "$js_file" << 'JSEOF'
const fs = require('fs');
try {
    const manifestPath = process.argv[2];
    const filePath = process.argv[3];
    const data = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
    const prot = data.protected || [];
    if (!Array.isArray(prot)) { console.log('no'); process.exit(0); }
    for (const pattern of prot) {
        // Convert glob to regex: escape regex chars except * and ?, then handle globs
        let re = pattern.replace(/[.+^${}()|[\]\\]/g, '\\$&');
        re = re.replace(/\*\*/g, '{{GLOBSTAR}}');
        re = re.replace(/\*/g, '[^/]*');
        re = re.replace(/\{\{GLOBSTAR\}\}/g, '.*');
        re = re.replace(/\?/g, '.');
        re = '^' + re + '$';
        if (new RegExp(re).test(filePath)) {
            console.log('yes');
            process.exit(0);
        }
        // Also check substring match for simple patterns without globs
        if (!pattern.includes('*') && !pattern.includes('?') && filePath.includes(pattern)) {
            console.log('yes');
            process.exit(0);
        }
    }
    console.log('no');
} catch(e) {
    console.log('no');
}
JSEOF

    local result
    result=$(node "$js_file" "$MANIFEST_JSON" "$file")

    [ "$result" = "yes" ] && return 0
    return 1
}

# Validate that protected patterns in the manifest match at least one local file.
# Warns if a pattern does not match anything (possible typo).
# Must be called after load_manifest().
validate_protected_paths() {
    if [ "$HAS_MANIFEST" != "true" ] || [ -z "$MANIFEST_JSON" ] || [ ! -f "$MANIFEST_JSON" ]; then
        return 0
    fi

    local protected_count
    protected_count=$(manifest_count "protected")
    if [ "$protected_count" -eq 0 ]; then
        return 0
    fi

    # Get all local file paths — for v1.1 root-relative, scan all sync domains
    # For v1.0, scan .claude/ only
    local local_files_list="$TMP_DIR/local_files_for_protected.txt"
    mkdir -p "$TMP_DIR"
    : > "$local_files_list"

    local manifest_ver
    manifest_ver=$(manifest_get "manifest_version" 2>/dev/null || echo "1.0")

    if [ "$manifest_ver" = "1.1" ] || [[ "$manifest_ver" > "1.1" ]]; then
        # v1.1: scan all sync scope domains, paths are root-relative
        get_sync_scope
        for domain in "${SYNC_SCOPE[@]}"; do
            local domain_dir="$PROJECT_ROOT/$domain"
            if [ -d "$domain_dir" ]; then
                find "$domain_dir" -type f ! -path "$BACKUP_DIR/*" -print0 2>/dev/null | \
                    while IFS= read -r -d '' f; do
                        echo "$domain/${f#$domain_dir/}"
                    done >> "$local_files_list"
            fi
        done
    else
        # v1.0: scan .claude/ only, paths are domain-relative
        if [ -d "$CLAUDE_DIR" ]; then
            find "$CLAUDE_DIR" -type f ! -path "$BACKUP_DIR/*" -print0 2>/dev/null | \
                while IFS= read -r -d '' f; do
                    echo "${f#$CLAUDE_DIR/}"
                done > "$local_files_list"
        fi
    fi

    # Write JS to temp file to avoid bash escaping issues with regex
    local js_file="$TMP_DIR/_validate_protected.js"
    cat > "$js_file" << 'JSEOF'
const fs = require('fs');
try {
    const manifestPath = process.argv[2];
    const localFilesPath = process.argv[3];
    const data = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
    const prot = data.protected || [];
    if (!Array.isArray(prot)) process.exit(0);

    const localFiles = fs.readFileSync(localFilesPath, 'utf8').split('\n').filter(Boolean);

    for (const pattern of prot) {
        // Convert glob to regex: escape regex chars except * and ?, then handle globs
        let re = pattern.replace(/[.+^${}()|[\]\\]/g, '\\$&');
        re = re.replace(/\*\*/g, '{{GLOBSTAR}}');
        re = re.replace(/\*/g, '[^/]*');
        re = re.replace(/\{\{GLOBSTAR\}\}/g, '.*');
        re = re.replace(/\?/g, '.');
        re = '^' + re + '$';
        const regex = new RegExp(re);

        const hasGlob = pattern.includes('*') || pattern.includes('?');
        const hasMatch = localFiles.some(f => {
            if (regex.test(f)) return true;
            if (!hasGlob && f.includes(pattern)) return true;
            return false;
        });

        if (!hasMatch) {
            console.log('WARN:' + pattern);
        }
    }
} catch(e) {}
JSEOF

    # Execute and process warnings
    node "$js_file" "$MANIFEST_JSON" "$local_files_list" | while IFS= read -r line; do
        local pat="${line#WARN:}"
        print_warning "Protected pattern does not match any local file: $pat (possible typo in manifest)"
    done
}

# =============================================================================
# End Protected File Enforcement
# =============================================================================

# =============================================================================
# Preflight Safety Check (SAW-2)
# =============================================================================
# Adapted from keryk-ai pattern: allowlist safety gate + unreplaced token
# scanner. Runs automatically before every sync (unless --skip-preflight).
#
# Three checks:
#   (a) Scope check: all files are within .claude/ (manifest scope)
#   (b) Token check: no manifest substitution keys remain as {{KEY}} tokens
#       after substitution (only checks keys from manifest, not arbitrary)
#   (c) Protected check: none of the target files are protected
#
# Returns 0 on pass, 1 on fail (sync aborted with clear error messages).
# =============================================================================

# Scan a single file for unreplaced {{KEY}} tokens where KEY is a manifest
# substitution or identity key. Reports file:line for each found.
# Only flags tokens that SHOULD have been replaced (not arbitrary {{...}}).
#
# Usage: scan_unreplaced_tokens "/path/to/file" "rel_path"
# Output: lines like "rel_path:42: unreplaced token {{PROJECT_NAME}}"
# Returns: 0 if clean, 1 if unreplaced tokens found
scan_unreplaced_tokens() {
    local file_path="$1"
    local rel_path="$2"

    if [ "$HAS_MANIFEST" != "true" ] || [ -z "$MANIFEST_JSON" ] || [ ! -f "$MANIFEST_JSON" ]; then
        return 0
    fi

    if [ ! -f "$file_path" ]; then
        return 0
    fi

    # Get all manifest substitution and identity keys
    local keys_json
    keys_json=$(node -e "
        const fs = require('fs');
        try {
            const data = JSON.parse(fs.readFileSync('$MANIFEST_JSON', 'utf8'));
            const keys = new Set();
            // Identity keys
            const identity = data.identity || {};
            for (const key of Object.keys(identity)) {
                keys.add(key);
            }
            // Substitution keys (extract KEY from {{KEY}} patterns)
            const subs = data.substitutions || {};
            for (const key of Object.keys(subs)) {
                const m = key.match(/^\{\{(.+)\}\}$/);
                if (m) {
                    keys.add(m[1]);
                } else {
                    keys.add(key);
                }
            }
            console.log(JSON.stringify([...keys]));
        } catch(e) {
            console.log('[]');
        }
    ")

    if [ "$keys_json" = "[]" ]; then
        return 0
    fi

    # Scan file for unreplaced tokens matching manifest keys
    local found
    found=$(node -e "
        const fs = require('fs');
        try {
            const keys = $keys_json;
            const content = fs.readFileSync('$file_path', 'utf8');
            const lines = content.split('\n');
            const results = [];
            for (let i = 0; i < lines.length; i++) {
                for (const key of keys) {
                    const token = '{{' + key + '}}';
                    if (lines[i].includes(token)) {
                        results.push('$rel_path:' + (i + 1) + ': unreplaced token ' + token);
                    }
                }
            }
            if (results.length > 0) {
                results.forEach(r => console.log(r));
            }
        } catch(e) {}
    ")

    if [ -n "$found" ]; then
        echo "$found"
        return 1
    fi
    return 0
}

# Run preflight safety checks on the sync plan.
# Takes a newline-separated list of "action|upstream_rel_path|local_rel_path"
# entries representing what WOULD be written.
#
# Checks:
#   (a) All target files are within configured sync domains
#   (b) No unreplaced manifest tokens remain post-substitution
#   (c) No protected files being modified
#
# Usage: run_preflight "$sync_plan" "$claude_dir" [skip_token_check]
# Returns: 0 on pass, 1 on fail
run_preflight() {
    local sync_plan="$1"
    local claude_dir="$2"
    local skip_token_check="${3:-false}"
    local errors=0
    local scope_violations=""
    local token_violations=""
    local protected_violations=""

    print_header "Preflight Safety Check"

    if [ -z "$sync_plan" ]; then
        print_success "Preflight passed (no files to sync)"
        return 0
    fi

    while IFS='|' read -r action upstream_rel local_rel; do
        [ -z "$action" ] && continue

        # --- Check (a): scope check -- no path traversal outside sync domain ---
        # The local_rel path is relative to the sync domain, check for escapes
        if [[ "$local_rel" == ../* ]] || [[ "$local_rel" == /* ]] || [[ "$local_rel" == */../* ]]; then
            scope_violations="${scope_violations}  - $local_rel (path traversal detected)\n"
            errors=$((errors + 1))
        fi

        # --- Check (c): protected file check ---
        if is_protected "$local_rel"; then
            protected_violations="${protected_violations}  - $local_rel (protected by manifest or .sync-exclude)\n"
            errors=$((errors + 1))
        fi
        # Also check upstream path for protection
        if [ "$upstream_rel" != "$local_rel" ] && is_protected "$upstream_rel"; then
            protected_violations="${protected_violations}  - $upstream_rel -> $local_rel (upstream path is protected)\n"
            errors=$((errors + 1))
        fi

        # --- Check (b): unreplaced token check ---
        # Only check files that will be written (new or modified)
        # We scan the upstream copy (in TMP_DIR) post-substitution simulation
        # Skip this check when --no-placeholders is used (tokens are expected)
        if [ "$skip_token_check" != "true" ]; then
            local upstream_file="${DOMAIN_TMP:-$TMP_DIR/.claude}/$upstream_rel"
            if [ -f "$upstream_file" ] && [ "$action" != "skip" ]; then
                local token_output
                token_output=$(scan_unreplaced_tokens "$upstream_file" "$local_rel") || true
                if [ -n "$token_output" ]; then
                    token_violations="${token_violations}${token_output}\n"
                    errors=$((errors + 1))
                fi
            fi
        fi

    done <<< "$sync_plan"

    # Report results
    if [ -n "$scope_violations" ]; then
        print_error "Scope violation: files outside .claude/ would be modified:"
        echo -e "$scope_violations"
    fi

    if [ -n "$protected_violations" ]; then
        print_error "Protected file violation: sync would modify protected files:"
        echo -e "$protected_violations"
    fi

    if [ -n "$token_violations" ]; then
        print_error "Unreplaced token violation: manifest tokens still present after substitution:"
        echo -e "$token_violations"
    fi

    if [ "$errors" -gt 0 ]; then
        print_error "Preflight FAILED with $errors error(s). Sync aborted."
        print_info "Use --skip-preflight to bypass (advanced users only)"
        return 1
    fi

    print_success "Preflight passed: all files within scope, no protected conflicts, no unreplaced tokens"
    return 0
}

# =============================================================================
# End Preflight Safety Check
# =============================================================================

# Get current upstream commit SHA
get_upstream_sha() {
    local ref="${1:-$UPSTREAM_BRANCH}"
    local response
    response=$(curl -sH "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$UPSTREAM_REPO/commits/$ref" 2>/dev/null)
    echo "$response" | node -e "
        let d=''; process.stdin.on('data',c=>d+=c);
        process.stdin.on('end',()=>{try{console.log(JSON.parse(d).sha||'')}catch(e){console.log('')}});
    "
}

# Get latest release tag
get_latest_release() {
    # Try gh CLI first (faster, handles auth)
    if command -v gh &> /dev/null; then
        local result
        result=$(gh release list --repo "$UPSTREAM_REPO" --limit 1 --json tagName 2>/dev/null)
        if [ -n "$result" ]; then
            echo "$result" | node -e "
                let d=''; process.stdin.on('data',c=>d+=c);
                process.stdin.on('end',()=>{try{const arr=JSON.parse(d);console.log(arr[0]?.tagName||'')}catch(e){console.log('')}});
            "
            return
        fi
    fi
    # Fallback to API
    curl -sH "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$UPSTREAM_REPO/releases/latest" 2>/dev/null | \
        node -e "
            let d=''; process.stdin.on('data',c=>d+=c);
            process.stdin.on('end',()=>{try{console.log(JSON.parse(d).tag_name||'')}catch(e){console.log('')}});
        "
}

# List available releases
list_releases() {
    print_header "Available Releases"
    if command -v gh &> /dev/null; then
        gh release list --repo "$UPSTREAM_REPO" --limit 10
    else
        curl -sH "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/repos/$UPSTREAM_REPO/releases?per_page=10" | \
            node -e "
                let d=''; process.stdin.on('data',c=>d+=c);
                process.stdin.on('end',()=>{
                    try {
                        const releases = JSON.parse(d);
                        releases.forEach(r => {
                            console.log(r.tag_name + '\t' + r.published_at + '\t' + (r.name || ''));
                        });
                    } catch(e) {
                        console.error('Failed to parse releases');
                    }
                });
            "
    fi
}

# Download upstream .claude directory
fetch_upstream() {
    local ref="${1:-$UPSTREAM_BRANCH}"
    print_info "Fetching upstream from $UPSTREAM_REPO ($ref)..."

    mkdir -p "$TMP_DIR"

    # Download tarball and extract
    local tarball_url="https://api.github.com/repos/$UPSTREAM_REPO/tarball/$ref"
    if ! curl -sL "$tarball_url" | tar xz -C "$TMP_DIR" --strip-components=1 2>/dev/null; then
        print_error "Failed to fetch upstream. Check repository access and ref: $ref"
        return 1
    fi

    if [ ! -d "$TMP_DIR/.claude" ]; then
        print_error "No .claude directory found in upstream repository"
        return 1
    fi

    local sha
    sha=$(get_upstream_sha "$ref")
    print_success "Fetched upstream (${sha:0:8})"
}

# Check if file is excluded from sync.
# When a manifest is present, checks BOTH manifest protected patterns AND
# .sync-exclude (merged, manifest takes precedence). Without a manifest,
# uses only .sync-exclude (legacy behavior, backward compatible).
is_excluded() {
    local file="$1"

    # Always exclude sync metadata, manifest, and backups
    [[ "$file" == .harness-sync.json ]] && return 0
    [[ "$file" == .harness-manifest.yml ]] && return 0
    [[ "$file" == .sync-exclude ]] && return 0
    [[ "$file" == .sync-exclude.default ]] && return 0
    [[ "$file" == .harness-backup* ]] && return 0

    # When manifest is present, use merged protected check (manifest + .sync-exclude)
    if [ "$HAS_MANIFEST" = "true" ]; then
        is_protected "$file"
        return $?
    fi

    # Legacy fallback: .sync-exclude only
    if [ ! -f "$EXCLUDE_FILE" ]; then
        return 1
    fi

    # Check against exclude patterns
    while IFS= read -r pattern || [ -n "$pattern" ]; do
        # Skip comments and empty lines
        [[ "$pattern" =~ ^#.*$ ]] && continue
        [[ -z "$pattern" ]] && continue
        [[ "$pattern" =~ ^[[:space:]]*$ ]] && continue

        # Trim whitespace
        pattern=$(echo "$pattern" | xargs)

        # Match pattern (supports * glob)
        if [[ "$file" == $pattern ]] || [[ "$file" == *"$pattern"* ]]; then
            return 0
        fi
    done < "$EXCLUDE_FILE"

    return 1
}

# Compare files and determine sync action
compare_file() {
    local rel_path="$1"
    local upstream_file="$TMP_DIR/.claude/$rel_path"
    local local_file="$CLAUDE_DIR/$rel_path"

    if [ ! -f "$upstream_file" ]; then
        echo "deleted"
    elif [ ! -f "$local_file" ]; then
        echo "new"
    elif diff -q "$upstream_file" "$local_file" > /dev/null 2>&1; then
        echo "unchanged"
    else
        echo "modified"
    fi
}

# Shared sync timestamp — set once per do_sync invocation so all domains share it
SYNC_TIMESTAMP=""

# Create backup before sync
create_backup() {
    local backup_target="${DOMAIN_DIR:-$CLAUDE_DIR}"
    local domain_name
    domain_name=$(basename "$backup_target")
    # Use shared timestamp so rollback can find all domains from same sync
    if [ -z "$SYNC_TIMESTAMP" ]; then
        SYNC_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    fi
    local backup_path="$BACKUP_DIR/$domain_name/$SYNC_TIMESTAMP"

    print_info "Creating backup of $domain_name at $backup_path"

    mkdir -p "$backup_path"

    # Copy all files except metadata
    while IFS= read -r -d '' file; do
        local rel_path="${file#$backup_target/}"
        local dest="$backup_path/$rel_path"
        mkdir -p "$(dirname "$dest")"
        cp "$file" "$dest"
    done < <(find "$backup_target" -type f ! -name ".harness-sync.json" ! -name ".sync-exclude" \
        ! -path "$BACKUP_DIR/*" -print0 2>/dev/null)

    # Prune old backups for this domain (keep last 3 timestamps)
    local domain_backup_dir="$BACKUP_DIR/$domain_name"
    local prune_count=0
    while IFS= read -r old_dir; do
        prune_count=$((prune_count + 1))
        if [ $prune_count -gt 3 ]; then
            rm -rf "$old_dir"
            print_info "Pruned old backup: $domain_name/$(basename "$old_dir")"
        fi
    done < <(find "$domain_backup_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort -r)

    print_success "Backup created"
    echo "$SYNC_TIMESTAMP"
}

# Restore from backup
do_rollback() {
    print_header "Rollback"

    if [ ! -d "$BACKUP_DIR" ]; then
        print_error "No backups found at $BACKUP_DIR"
        return 1
    fi

    # Backup structure: .harness-backup/<domain>/<timestamp>/...
    # Find the most recent timestamp across all domain subdirs
    local latest_timestamp=""
    local latest_epoch=0
    while IFS= read -r ts_dir; do
        local ts_name
        ts_name=$(basename "$ts_dir")
        # Parse ISO timestamp to epoch for comparison
        local epoch
        epoch=$(date -d "$ts_name" +%s 2>/dev/null || echo 0)
        if [ "$epoch" -gt "$latest_epoch" ]; then
            latest_epoch=$epoch
            latest_timestamp="$ts_name"
        fi
    done < <(find "$BACKUP_DIR" -mindepth 2 -maxdepth 2 -type d 2>/dev/null)

    if [ -z "$latest_timestamp" ]; then
        print_error "No backups available"
        return 1
    fi

    print_info "Restoring from backup timestamp: $latest_timestamp"

    # Restore files from all domain backups with this timestamp
    local restored=0
    while IFS= read -r domain_dir; do
        local domain_name
        domain_name=$(basename "$domain_dir")
        local ts_backup="$domain_dir/$latest_timestamp"
        if [ -d "$ts_backup" ]; then
            print_info "Restoring domain: $domain_name"
            while IFS= read -r -d '' file; do
                local rel_path="${file#$ts_backup/}"
                local dest="$PROJECT_ROOT/$domain_name/$rel_path"
                mkdir -p "$(dirname "$dest")"
                cp "$file" "$dest"
                restored=$((restored + 1))
            done < <(find "$ts_backup" -type f -print0)
        fi
    done < <(find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)

    # Update metadata
    if [ -f "$SYNC_CONFIG" ]; then
        local rb_timestamp
        rb_timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        node -e "
            const fs = require('fs');
            const data = JSON.parse(fs.readFileSync('$SYNC_CONFIG', 'utf8'));
            data.last_rollback_at = '$rb_timestamp';
            fs.writeFileSync('$SYNC_CONFIG', JSON.stringify(data, null, 2));
        "
    fi

    print_success "Rollback complete from $latest_timestamp"
}

# Show diff between local and upstream
do_diff() {
    local ref="${1:-$UPSTREAM_BRANCH}"

    fetch_upstream "$ref" || return 1

    # Validate rename sources against fetched upstream tree
    validate_renames_against_upstream

    # Validate protected patterns against local files (warn on typos)
    validate_protected_paths

    print_header "Differences (local vs upstream)"

    local new=0 modified=0 deleted=0 excluded=0 unchanged=0 renamed=0 protected=0

    # Track directory rename file counts for summary output
    declare -A dir_rename_counts

    # Determine manifest version for path handling
    local manifest_ver=""
    if [ "$HAS_MANIFEST" = "true" ]; then
        manifest_ver=$(manifest_get "manifest_version" 2>/dev/null || echo "1.0")
    fi
    local use_root=false
    if [ "$manifest_ver" = "1.1" ] || [[ "$manifest_ver" > "1.1" ]]; then
        use_root=true
    fi

    # Get sync scope
    get_sync_scope

    for CURRENT_DOMAIN in "${SYNC_SCOPE[@]}"; do
        local DOMAIN_DIR="$PROJECT_ROOT/$CURRENT_DOMAIN"
        local DOMAIN_TMP="$TMP_DIR/$CURRENT_DOMAIN"

        if [ ! -d "$DOMAIN_TMP" ]; then
            continue
        fi
        if [ ! -d "$DOMAIN_DIR" ]; then
            continue
        fi

        echo -e "\n${CYAN}━━━ $CURRENT_DOMAIN ━━━${NC}"

    # Check upstream files
    while IFS= read -r -d '' file; do
        local rel_path="${file#$DOMAIN_TMP/}"
        local manifest_path
        if [ "$use_root" = true ]; then manifest_path="$CURRENT_DOMAIN/$rel_path"; else manifest_path="$rel_path"; fi

        if is_excluded "$manifest_path"; then
            # Distinguish PROTECTED (manifest) from EXCLUDED (.sync-exclude / hardcoded)
            if is_manifest_protected "$manifest_path"; then
                echo -e "${YELLOW}PROTECTED${NC}  $manifest_path (skipping per manifest)"
                protected=$((protected + 1))
            else
                echo -e "${YELLOW}EXCLUDED${NC}  $manifest_path"
                excluded=$((excluded + 1))
            fi
            continue
        fi

        # Resolve rename: use manifest_path for lookup, extract domain-relative for file ops
        local local_manifest_path
        local rtype
        local_manifest_path=$(resolve_rename "$manifest_path")
        rtype=$(rename_type "$manifest_path")
        local local_path
        if [ "$use_root" = true ]; then local_path="${local_manifest_path#$CURRENT_DOMAIN/}"; else local_path="$local_manifest_path"; fi

        # Also check exclusion for the resolved local path
        if [ "$local_manifest_path" != "$manifest_path" ] && is_excluded "$local_manifest_path"; then
            if is_manifest_protected "$local_manifest_path"; then
                echo -e "${YELLOW}PROTECTED${NC}  $local_manifest_path (skipping per manifest)"
                protected=$((protected + 1))
            else
                echo -e "${YELLOW}EXCLUDED${NC}  $local_manifest_path (renamed from $manifest_path)"
                excluded=$((excluded + 1))
            fi
            continue
        fi

        local status
        status=$(compare_file_with_paths "$rel_path" "$local_path")

        # Track directory rename file counts
        if [ "$rtype" = "directory" ]; then
            # Find the directory rename key for this file
            local dir_key=""
            while IFS='|' read -r src dst; do
                if [[ "$rel_path" == "$src"* ]]; then
                    dir_key="${src}|${dst}"
                    break
                fi
            done < <(get_directory_renames)
            if [ -n "$dir_key" ]; then
                dir_rename_counts["$dir_key"]=$(( ${dir_rename_counts["$dir_key"]:-0} + 1 ))
            fi
        fi

        case "$status" in
            new)
                if [ "$local_path" != "$rel_path" ]; then
                    echo -e "${GREEN}NEW${NC}       $local_path (upstream: $rel_path)"
                else
                    echo -e "${GREEN}NEW${NC}       $rel_path"
                fi
                new=$((new + 1))
                ;;
            modified)
                if [ "$local_path" != "$rel_path" ]; then
                    echo -e "${BLUE}MODIFIED${NC}  $local_path (upstream: $rel_path)"
                else
                    echo -e "${BLUE}MODIFIED${NC}  $rel_path"
                fi
                modified=$((modified + 1))
                ;;
            unchanged)
                unchanged=$((unchanged + 1))
                ;;
        esac
    done < <(find "$DOMAIN_TMP" -type f -print0 2>/dev/null)

    # Check for files only in local (deleted from upstream)
    local resolved_local_paths_file="$TMP_DIR/resolved_local_paths_${CURRENT_DOMAIN}.txt"
    while IFS= read -r -d '' file; do
        local rel_path="${file#$DOMAIN_TMP/}"
        local mp; if [ "$use_root" = true ]; then mp="$CURRENT_DOMAIN/$rel_path"; else mp="$rel_path"; fi
        resolve_rename "$mp"
    done < <(find "$DOMAIN_TMP" -type f -print0 2>/dev/null) > "$resolved_local_paths_file"

    while IFS= read -r -d '' file; do
        local rel_path="${file#$DOMAIN_DIR/}"

        # Skip metadata and excluded files
        [[ "$rel_path" == .harness-* ]] && continue
        [[ "$rel_path" == .sync-* ]] && continue
        local mp; if [ "$use_root" = true ]; then mp="$CURRENT_DOMAIN/$rel_path"; else mp="$rel_path"; fi
        is_excluded "$mp" && continue

        # Check if this local path is accounted for in upstream
        local upstream_file="$DOMAIN_TMP/$rel_path"
        if [ -f "$upstream_file" ]; then
            continue
        fi

        # Check if this local path is a rename target
        if grep -qxF "$mp" "$resolved_local_paths_file" 2>/dev/null; then
            continue
        fi

        echo -e "${RED}LOCAL ONLY${NC} $mp"
        deleted=$((deleted + 1))
    done < <(find "$DOMAIN_DIR" -type f ! -path "$BACKUP_DIR/*" -print0 2>/dev/null)

    # Show directory rename summary lines for this domain
    if [ ${#dir_rename_counts[@]} -gt 0 ]; then
        echo ""
        for dir_key in "${!dir_rename_counts[@]}"; do
            local src_dir="${dir_key%%|*}"
            local dst_dir="${dir_key##*|}"
            local count="${dir_rename_counts[$dir_key]}"
            echo -e "${CYAN}RENAMED${NC}  ${src_dir} -> ${dst_dir} ($count files)"
            renamed=$((renamed + count))
        done
    fi

    done  # End of SYNC_SCOPE domain loop for diff

    # Count file renames (not part of directory renames)
    if [ "$HAS_MANIFEST" = "true" ] && [ -n "$MANIFEST_JSON" ] && [ -f "$MANIFEST_JSON" ]; then
        local file_rename_count
        file_rename_count=$(node -e "
            const fs = require('fs');
            try {
                const data = JSON.parse(fs.readFileSync('$MANIFEST_JSON', 'utf8'));
                const renames = data.renames || {};
                let count = 0;
                for (const src of Object.keys(renames)) {
                    if (!src.endsWith('/')) count++;
                }
                console.log(count);
            } catch(e) { console.log(0); }
        ")
        renamed=$((renamed + file_rename_count))
    fi

    echo ""
    local summary="Summary: $new new, $modified modified, $deleted local-only, $excluded excluded, $unchanged unchanged"
    if [ "$protected" -gt 0 ]; then
        summary="$summary, $protected protected"
    fi
    if [ "$renamed" -gt 0 ]; then
        summary="$summary, $renamed renamed"
    fi
    print_info "$summary"
}

# =============================================================================
# Patch Generation Mode (SAW-4)
# =============================================================================
# Instead of overwriting files during sync, generate unified diff patches
# into .harness-patches/<version>/. Patches are rename-aware
# (use fork's local paths in headers) and substitution-aware (use fork's
# placeholder values). Each patch is valid for `git apply --check`.
#
# An APPLY_ORDER.md summary file groups patches by category (NEW, UPDATED)
# and lists them in recommended application order.
# =============================================================================

# Generate a unified diff patch for a single file.
# For NEW files, generates a diff against /dev/null.
# For MODIFIED files, generates a diff between current local and upstream.
#
# Uses fork's resolved local paths in patch headers (rename-aware).
# The upstream file in TMP_DIR has already been substituted (substitution-aware).
#
# Usage: generate_patch "upstream_rel_path" "local_rel_path" "status" "patches_dir" "claude_dir"
# Returns: path to generated .patch file, or empty string on skip
generate_patch() {
    local upstream_rel="$1"
    local local_rel="$2"
    local status="$3"
    local patches_dir="$4"
    local claude_dir="$5"

    local upstream_file="${DOMAIN_TMP:-$TMP_DIR/.claude}/$upstream_rel"
    local local_file="$claude_dir/$local_rel"

    # Create sanitized patch filename (replace / with __ for flat structure)
    local patch_name
    patch_name=$(echo "$local_rel" | sed 's|/|__|g')
    local patch_file="$patches_dir/${patch_name}.patch"

    mkdir -p "$patches_dir"

    case "$status" in
        new)
            # For new files, diff against /dev/null
            # Use git-compatible header: a/dev/null -> b/.claude/<local_rel>
            diff -u /dev/null "$upstream_file" \
                --label "a/dev/null" \
                --label "b/$CURRENT_DOMAIN/$local_rel" \
                > "$patch_file" 2>/dev/null || true
            # diff returns 1 when files differ, which is expected
            if [ -s "$patch_file" ]; then
                echo "$patch_file"
            fi
            ;;
        modified)
            # For modified files, diff between current local and substituted upstream
            if [ -f "$local_file" ]; then
                diff -u "$local_file" "$upstream_file" \
                    --label "a/$CURRENT_DOMAIN/$local_rel" \
                    --label "b/$CURRENT_DOMAIN/$local_rel" \
                    > "$patch_file" 2>/dev/null || true
                if [ -s "$patch_file" ]; then
                    echo "$patch_file"
                fi
            else
                # Local file missing but expected -- treat as new
                diff -u /dev/null "$upstream_file" \
                    --label "a/dev/null" \
                    --label "b/$CURRENT_DOMAIN/$local_rel" \
                    > "$patch_file" 2>/dev/null || true
                if [ -s "$patch_file" ]; then
                    echo "$patch_file"
                fi
            fi
            ;;
    esac
}

# Generate the APPLY_ORDER.md summary file.
# Groups patches by category (NEW, UPDATED) and lists git apply commands.
#
# Usage: generate_apply_order "patches_dir" "version"
# Reads entry files:
#   $patches_dir/._new_entries.txt - newline-separated "local_rel|patch_filename" entries
#   $patches_dir/._updated_entries.txt - same format for updated files
generate_apply_order() {
    local patches_dir="$1"
    local version="$2"
    local new_entries_file="$patches_dir/._new_entries.txt"
    local updated_entries_file="$patches_dir/._updated_entries.txt"
    local apply_order_file="$patches_dir/APPLY_ORDER.md"

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    cat > "$apply_order_file" << HEADER
# Harness Patch Apply Order

**Version**: ${version}
**Generated**: ${timestamp}
**Base directory**: Run all commands from the project root.

## How to apply

Review each patch, then apply:

\`\`\`bash
# Dry-run check (recommended first)
git apply --check .harness-patches/${version}/<patch-file>.patch

# Apply a single patch
git apply .harness-patches/${version}/<patch-file>.patch

# Apply all patches in order
cat .harness-patches/${version}/APPLY_ORDER.md  # review this file first
\`\`\`

HEADER

    # NEW files section
    local new_count=0
    if [ -f "$new_entries_file" ]; then
        new_count=$(wc -l < "$new_entries_file" | tr -d ' ')
    fi

    if [ "$new_count" -gt 0 ]; then
        cat >> "$apply_order_file" << 'SECTION_NEW'
## NEW files

These patches add files that do not yet exist locally.

| # | File | Patch | Command |
|---|------|-------|---------|
SECTION_NEW

        local idx=1
        while IFS='|' read -r local_rel patch_name; do
            [ -z "$local_rel" ] && continue
            echo "| ${idx} | \`${local_rel}\` | \`${patch_name}\` | \`git apply .harness-patches/${version}/${patch_name}\` |" >> "$apply_order_file"
            idx=$((idx + 1))
        done < "$new_entries_file"
        echo "" >> "$apply_order_file"
    fi

    # UPDATED files section
    local updated_count=0
    if [ -f "$updated_entries_file" ]; then
        updated_count=$(wc -l < "$updated_entries_file" | tr -d ' ')
    fi

    if [ "$updated_count" -gt 0 ]; then
        cat >> "$apply_order_file" << 'SECTION_UPDATED'
## UPDATED files

These patches modify existing local files. Review changes carefully.

| # | File | Patch | Command |
|---|------|-------|---------|
SECTION_UPDATED

        local idx=1
        while IFS='|' read -r local_rel patch_name; do
            [ -z "$local_rel" ] && continue
            echo "| ${idx} | \`${local_rel}\` | \`${patch_name}\` | \`git apply .harness-patches/${version}/${patch_name}\` |" >> "$apply_order_file"
            idx=$((idx + 1))
        done < "$updated_entries_file"
        echo "" >> "$apply_order_file"
    fi

    # Apply-all command
    local total=$((new_count + updated_count))
    cat >> "$apply_order_file" << FOOTER
## Apply all patches

\`\`\`bash
# Apply all ${total} patch(es) in recommended order
for patch in \\
FOOTER

    # List new patches first, then updated
    if [ -f "$new_entries_file" ]; then
        while IFS='|' read -r local_rel patch_name; do
            [ -z "$local_rel" ] && continue
            echo "    .harness-patches/${version}/${patch_name} \\" >> "$apply_order_file"
        done < "$new_entries_file"
    fi
    if [ -f "$updated_entries_file" ]; then
        while IFS='|' read -r local_rel patch_name; do
            [ -z "$local_rel" ] && continue
            echo "    .harness-patches/${version}/${patch_name} \\" >> "$apply_order_file"
        done < "$updated_entries_file"
    fi

    # Close the for loop
    cat >> "$apply_order_file" << 'LOOP_END'
    ; do
    git apply --check "$patch" && git apply "$patch"
done
```
LOOP_END

    # Clean up temp entry files
    rm -f "$new_entries_file" "$updated_entries_file"

    echo "$apply_order_file"
}

# =============================================================================
# End Patch Generation Mode
# =============================================================================

# Perform sync
do_sync() {
    local dry_run=false
    local version=""
    local use_latest=false
    local no_placeholders=false
    local skip_preflight=false
    local generate_patches=false
    local scope_override=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)
                dry_run=true
                shift
                ;;
            --version)
                version="$2"
                shift 2
                ;;
            --latest)
                use_latest=true
                shift
                ;;
            --no-placeholders)
                no_placeholders=true
                shift
                ;;
            --skip-preflight)
                skip_preflight=true
                shift
                ;;
            --generate-patches)
                generate_patches=true
                shift
                ;;
            --scope)
                scope_override="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    # Require manifest for non-legacy sync (SA decision: no manifest = fail)
    if [ "$HAS_MANIFEST" != "true" ]; then
        if [ "$dry_run" = true ]; then
            print_warning "No manifest found. Dry-run preview uses legacy .claude/-only scope."
        else
            print_error "No manifest found. Run './scripts/sync-claude-harness.sh manifest init' first."
            print_error "Sync requires a manifest for substitution, protection, and domain selection."
            return 1
        fi
    fi

    # Determine sync scope
    get_sync_scope
    if [ -n "$scope_override" ]; then
        # --scope overrides manifest for this command only (does NOT rewrite manifest)
        SYNC_SCOPE=()
        IFS=',' read -ra scope_parts <<< "$scope_override"
        for part in "${scope_parts[@]}"; do
            part=$(echo "$part" | sed 's|/$||' | xargs)  # strip trailing / and whitespace
            local valid=false
            for allowed in "${ALLOWED_DOMAINS[@]}"; do
                if [ "$part" = "$allowed" ]; then
                    valid=true
                    break
                fi
            done
            if [ "$valid" = true ]; then
                SYNC_SCOPE+=("$part")
            else
                print_warning "Ignoring unknown scope: $part"
            fi
        done
        if [ ${#SYNC_SCOPE[@]} -eq 0 ]; then
            print_error "No valid domains in --scope. Allowed: ${ALLOWED_DOMAINS[*]}"
            return 1
        fi
        print_info "Scope override: ${SYNC_SCOPE[*]}"
    fi

    echo -e "${CYAN}Sync domains: ${SYNC_SCOPE[*]}${NC}"

    # Reset shared timestamp so all domains in this sync get the same one
    SYNC_TIMESTAMP=""

    # Determine ref to sync
    local ref="$UPSTREAM_BRANCH"
    if [ -n "$version" ]; then
        ref="$version"
        print_info "Syncing to version: $version"
    elif [ "$use_latest" = true ]; then
        ref=$(get_latest_release)
        if [ -z "$ref" ]; then
            print_error "No releases found. Use --version to specify a tag or branch."
            return 1
        fi
        print_info "Syncing to latest release: $ref"
    fi

    if [ "$generate_patches" = true ]; then
        print_header "Generating Patches (no files will be overwritten)"
    elif [ "$dry_run" = true ]; then
        print_header "Dry Run - No changes will be made"
    else
        print_header "Syncing Harness"
    fi

    fetch_upstream "$ref" || return 1

    # Validate rename sources against fetched upstream tree
    validate_renames_against_upstream

    # Validate protected patterns against local files (warn on typos)
    validate_protected_paths

    # --- Multi-domain sync loop (SAW-35) ---
    # Determine manifest path style: v1.0 uses domain-relative, v1.1+ uses root-relative
    local MANIFEST_VERSION=""
    if [ "$HAS_MANIFEST" = "true" ]; then
        MANIFEST_VERSION=$(manifest_get "manifest_version" 2>/dev/null || echo "1.0")
    fi
    # For v1.0 manifests, paths in renames/protected/replaced are domain-relative (e.g., "agents/bsa.md")
    # For v1.1+ manifests, paths are root-relative (e.g., ".claude/agents/bsa.md")
    # We need to construct the correct lookup key for manifest functions
    local USE_ROOT_PATHS=false
    if [ "$MANIFEST_VERSION" = "1.1" ] || [[ "$MANIFEST_VERSION" > "1.1" ]]; then
        USE_ROOT_PATHS=true
    fi

    # Pre-create patches directory (outside domain loop so domains don't wipe each other)
    local patches_version_dir=""
    if [ "$generate_patches" = true ]; then
        local patch_version="$ref"
        if [ -z "$patch_version" ] || [ "$patch_version" = "$UPSTREAM_BRANCH" ]; then
            patch_version="$(date -u +%Y%m%d-%H%M%S)"
        fi
        patches_version_dir="$PATCHES_DIR/$patch_version"
        if [ -d "$patches_version_dir" ]; then
            rm -rf "$patches_version_dir"
        fi
        mkdir -p "$patches_version_dir"
    fi

    # Process each domain in SYNC_SCOPE sequentially
    local sha
    sha=$(get_upstream_sha "$ref")

    for CURRENT_DOMAIN in "${SYNC_SCOPE[@]}"; do
        local DOMAIN_DIR="$PROJECT_ROOT/$CURRENT_DOMAIN"
        local DOMAIN_TMP="$TMP_DIR/$CURRENT_DOMAIN"

        # Skip domains not present in upstream
        if [ ! -d "$DOMAIN_TMP" ]; then
            print_warning "Domain '$CURRENT_DOMAIN' not found in upstream — skipping"
            continue
        fi

        # Skip domains not present locally (no auto-creation in v2.10.0)
        if [ ! -d "$DOMAIN_DIR" ]; then
            print_warning "Domain '$CURRENT_DOMAIN' not found locally — skipping (create manually to include)"
            continue
        fi

        echo -e "\n${CYAN}━━━ Syncing domain: $CURRENT_DOMAIN ━━━${NC}"

    # Apply substitutions to upstream copies in TMP_DIR BEFORE preflight
    # so the token scanner checks post-substitution state (SAW-2)
    if [ "$no_placeholders" = false ] && [ "$HAS_MANIFEST" = "true" ]; then
        apply_all_substitutions "$DOMAIN_TMP"
    fi

    # --- Build sync plan (SAW-2) ---
    # Enumerate what WOULD be written, for preflight validation
    local sync_plan=""

    while IFS= read -r -d '' file; do
        local rel_path="${file#$DOMAIN_TMP/}"
        # For manifest lookups (v1.1 root-relative): prepend domain
        local manifest_path; if [ "$USE_ROOT_PATHS" = true ]; then manifest_path="$CURRENT_DOMAIN/$rel_path"; else manifest_path="$rel_path"; fi

        if is_excluded "$manifest_path"; then
            continue
        fi

        # Resolve rename: map root-relative upstream path to root-relative local path
        local local_manifest_path
        local_manifest_path=$(resolve_rename "$manifest_path")
        # Extract domain-relative local path for file operations
        local local_path; if [ "$USE_ROOT_PATHS" = true ]; then local_path="${local_manifest_path#$CURRENT_DOMAIN/}"; else local_path="$local_manifest_path"; fi

        # Also check exclusion for the resolved local path
        if [ "$local_manifest_path" != "$manifest_path" ] && is_excluded "$local_manifest_path"; then
            continue
        fi

        local status
        status=$(compare_file_with_paths "$rel_path" "$local_path")

        case "$status" in
            new|modified)
                sync_plan="${sync_plan}${status}|${rel_path}|${local_path}\n"
                ;;
        esac
    done < <(find "$DOMAIN_TMP" -type f -print0 2>/dev/null)

    # --- Run preflight (SAW-2) ---
    if [ "$skip_preflight" = true ]; then
        print_warning "Preflight check SKIPPED (--skip-preflight). Proceeding without safety validation."
    else
        local plan_text
        plan_text=$(echo -e "$sync_plan")
        if ! run_preflight "$plan_text" "$DOMAIN_DIR" "$no_placeholders"; then
            continue  # Skip this domain, try next
        fi
    fi

    # --- Patch generation mode (SAW-4) ---
    if [ "$generate_patches" = true ]; then
        # patches_version_dir already created outside domain loop
        # Entry files initialized outside domain loop — append per domain
        local new_entries_file="$patches_version_dir/._new_entries.txt"
        local updated_entries_file="$patches_version_dir/._updated_entries.txt"

        local patch_count=0 skipped=0 protected_count=0 new_patches=0 updated_patches=0

        while IFS= read -r -d '' file; do
            local rel_path="${file#$DOMAIN_TMP/}"
            local manifest_path; if [ "$USE_ROOT_PATHS" = true ]; then manifest_path="$CURRENT_DOMAIN/$rel_path"; else manifest_path="$rel_path"; fi

            if is_excluded "$manifest_path"; then
                if is_manifest_protected "$manifest_path"; then
                    print_warning "Skipping protected: $manifest_path"
                    protected_count=$((protected_count + 1))
                else
                    print_warning "Skipping excluded: $manifest_path"
                fi
                skipped=$((skipped + 1))
                continue
            fi

            local local_manifest_path
            local_manifest_path=$(resolve_rename "$manifest_path")
            local local_path; if [ "$USE_ROOT_PATHS" = true ]; then local_path="${local_manifest_path#$CURRENT_DOMAIN/}"; else local_path="$local_manifest_path"; fi

            if [ "$local_manifest_path" != "$manifest_path" ] && is_excluded "$local_manifest_path"; then
                if is_manifest_protected "$local_manifest_path"; then
                    print_warning "Skipping protected: $local_manifest_path"
                    protected_count=$((protected_count + 1))
                fi
                skipped=$((skipped + 1))
                continue
            fi

            local status
            status=$(compare_file_with_paths "$rel_path" "$local_path")

            case "$status" in
                new|modified)
                    local patch_file
                    patch_file=$(generate_patch "$rel_path" "$local_path" "$status" "$patches_version_dir" "$DOMAIN_DIR")
                    if [ -n "$patch_file" ]; then
                        local patch_basename
                        patch_basename=$(basename "$patch_file")
                        local display_path="$local_path"
                        if [ "$local_path" != "$rel_path" ]; then
                            display_path="$local_path (upstream: $rel_path)"
                        fi
                        if [ "$status" = "new" ]; then
                            print_success "Patch (NEW): $display_path -> $patch_basename"
                            echo "${CURRENT_DOMAIN}/${local_path}|${patch_basename}" >> "$new_entries_file"
                            new_patches=$((new_patches + 1))
                        else
                            print_success "Patch (UPD): $display_path -> $patch_basename"
                            echo "${CURRENT_DOMAIN}/${local_path}|${patch_basename}" >> "$updated_entries_file"
                            updated_patches=$((updated_patches + 1))
                        fi
                        patch_count=$((patch_count + 1))
                    fi
                    ;;
                unchanged)
                    # No patch needed
                    ;;
            esac
        done < <(find "$DOMAIN_TMP" -type f -print0 2>/dev/null)

        echo ""
        print_info "[$CURRENT_DOMAIN] $patch_count patch(es), $skipped skipped"
        continue  # Next domain
    fi

    # Create backup before sync (unless dry run)
    if [ "$dry_run" = false ]; then
        create_backup
    fi

    local updated=0 skipped=0 conflicts=0 new_files=0 protected_count=0

    # Process upstream files
    while IFS= read -r -d '' file; do
        local rel_path="${file#$DOMAIN_TMP/}"
        local manifest_path; if [ "$USE_ROOT_PATHS" = true ]; then manifest_path="$CURRENT_DOMAIN/$rel_path"; else manifest_path="$rel_path"; fi

        if is_excluded "$manifest_path"; then
            if is_manifest_protected "$manifest_path"; then
                print_warning "Skipping protected: $manifest_path (upstream has changes, skipping per manifest)"
                protected_count=$((protected_count + 1))
            else
                print_warning "Skipping excluded: $manifest_path"
            fi
            skipped=$((skipped + 1))
            continue
        fi

        # Resolve rename: root-relative manifest path → root-relative local path
        local local_manifest_path
        local_manifest_path=$(resolve_rename "$manifest_path")
        local local_path; if [ "$USE_ROOT_PATHS" = true ]; then local_path="${local_manifest_path#$CURRENT_DOMAIN/}"; else local_path="$local_manifest_path"; fi
        local local_file="$DOMAIN_DIR/$local_path"

        # Also check exclusion for the resolved local path
        if [ "$local_manifest_path" != "$manifest_path" ] && is_excluded "$local_manifest_path"; then
            if is_manifest_protected "$local_manifest_path"; then
                print_warning "Skipping protected: $local_manifest_path (upstream has changes, skipping per manifest)"
                protected_count=$((protected_count + 1))
            else
                print_warning "Skipping excluded: $local_manifest_path (renamed from $manifest_path)"
            fi
            skipped=$((skipped + 1))
            continue
        fi

        local status
        status=$(compare_file_with_paths "$rel_path" "$local_path")

        local display_path="$local_path"
        if [ "$local_path" != "$rel_path" ]; then
            display_path="$local_path (upstream: $rel_path)"
        fi

        case "$status" in
            new)
                if [ "$dry_run" = false ]; then
                    mkdir -p "$(dirname "$local_file")"
                    # Copy the already-substituted file from TMP_DIR
                    cp "$file" "$local_file"
                fi
                print_success "Added: $display_path"
                new_files=$((new_files + 1))
                updated=$((updated + 1))
                ;;
            modified)
                if [ "$dry_run" = false ]; then
                    # Copy the already-substituted file from TMP_DIR
                    cp "$file" "$local_file"
                fi
                print_success "Updated: $display_path"
                updated=$((updated + 1))
                ;;
            unchanged)
                # No action needed
                ;;
        esac
    done < <(find "$DOMAIN_TMP" -type f -print0 2>/dev/null)

    # Note: Substitutions were already applied to TMP_DIR copies before preflight.
    # The substituted files are what get copied to the domain directory above.
    if [ "$no_placeholders" = true ]; then
        print_info "Skipping placeholder substitutions (--no-placeholders)"
    fi

    # Update sync metadata with provenance (unless dry run) (SAW-2)
    if [ "$dry_run" = false ]; then
        update_sync_metadata "$sha" "$ref" "$updated" "$skipped" "$conflicts"
    fi

    echo ""
    local sync_summary="[$CURRENT_DOMAIN] Summary: $updated updated ($new_files new), $skipped skipped, $conflicts conflicts"
    if [ "$protected_count" -gt 0 ]; then
        sync_summary="$sync_summary, $protected_count protected"
    fi
    print_info "$sync_summary"

    done  # End of SYNC_SCOPE domain loop

    # Generate APPLY_ORDER.md AFTER all domains processed (so entries accumulate)
    if [ "$generate_patches" = true ] && [ -n "$patches_version_dir" ]; then
        if [ -f "$patches_version_dir/._new_entries.txt" ] || [ -f "$patches_version_dir/._updated_entries.txt" ]; then
            local total_patches
            total_patches=$(find "$patches_version_dir" -name "*.patch" 2>/dev/null | wc -l)
            if [ "$total_patches" -gt 0 ]; then
                generate_apply_order "$patches_version_dir" "$(basename "$patches_version_dir")"
                print_success "Generated APPLY_ORDER.md with $total_patches patch(es) across ${#SYNC_SCOPE[@]} domain(s)"
                print_info "Patches written to: $patches_version_dir"
            fi
            rm -f "$patches_version_dir/._new_entries.txt" "$patches_version_dir/._updated_entries.txt"
        fi
    fi

    if [ "$dry_run" = true ]; then
        print_info "Run without --dry-run to apply changes"
    fi
}

# Update sync metadata file
update_sync_metadata() {
    local commit="$1"
    local version="$2"
    local updated="$3"
    local skipped="$4"
    local conflicts="$5"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    if [ -f "$SYNC_CONFIG" ]; then
        node -e "
            const fs = require('fs');
            const data = JSON.parse(fs.readFileSync('$SYNC_CONFIG', 'utf8'));

            // Update main provenance fields (SAW-2)
            data.last_synced_commit = '$commit';
            data.last_synced_version = '$version';
            data.last_synced_at = '$timestamp';

            // Provenance tracking (SAW-2): explicit source provenance fields
            data.last_sync_timestamp = '$timestamp';
            data.last_sync_version = '$version';
            data.last_sync_commit = '$commit';

            // Add to sync history (keep last 10) with provenance (SAW-2)
            const historyEntry = {
                commit: '$commit',
                version: '$version',
                synced_at: '$timestamp',
                files_updated: $updated,
                files_skipped: $skipped,
                conflicts: $conflicts,
                source_commit_sha: '$commit',
                upstream_version: '$version',
                sync_timestamp: '$timestamp'
            };
            data.sync_history = [historyEntry, ...(data.sync_history || [])].slice(0, 10);

            fs.writeFileSync('$SYNC_CONFIG', JSON.stringify(data, null, 2));
        "
    fi
}

# Show sync status
do_status() {
    print_header "Harness Sync Status"

    if [ ! -f "$SYNC_CONFIG" ]; then
        print_warning "Sync not initialized. Run: ./scripts/sync-claude-harness.sh init"
        return 1
    fi

    local last_commit last_version last_date
    last_commit=$(json_get "$SYNC_CONFIG" "last_synced_commit" "never")
    last_version=$(json_get "$SYNC_CONFIG" "last_synced_version" "unknown")
    last_date=$(json_get "$SYNC_CONFIG" "last_synced_at" "never")

    echo "Upstream:      $UPSTREAM_REPO"
    echo "Branch:        $UPSTREAM_BRANCH"
    echo "Last Synced:   ${last_commit:0:8} ($last_version)"
    echo "Synced At:     $last_date"
    echo ""

    # Check latest release
    local latest_release
    latest_release=$(get_latest_release)
    if [ -n "$latest_release" ]; then
        echo "Latest Release: $latest_release"
        if [ "$last_version" != "$latest_release" ]; then
            print_warning "Update available! Run: ./scripts/sync-claude-harness.sh sync --version $latest_release"
        else
            print_success "Up to date with latest release"
        fi
    fi

    # Check current upstream
    local current_sha
    current_sha=$(get_upstream_sha)
    if [ -n "$current_sha" ] && [ "$last_commit" != "$current_sha" ]; then
        echo ""
        print_info "Branch $UPSTREAM_BRANCH has newer commits (${current_sha:0:8})"
    fi

    # Show manifest info when present
    if [ "$HAS_MANIFEST" = "true" ]; then
        echo ""
        local mv rename_count sub_count protected_count replaced_count
        mv=$(manifest_get "manifest_version" "?")
        rename_count=$(manifest_count "renames")
        sub_count=$(manifest_count "substitutions")
        protected_count=$(manifest_count "protected")
        replaced_count=$(manifest_count "replaced")
        local conflict_strategy
        conflict_strategy=$(manifest_get "sync.conflict_strategy" "prompt")
        echo "Manifest:      v${mv} ($MANIFEST_FILE)"
        echo "  Renames:       $rename_count"
        echo "  Substitutions: $sub_count"
        echo "  Protected:     $protected_count"
        echo "  Replaced:      $replaced_count"
        echo "  Conflict:      $conflict_strategy"

        # Show rename details when renames exist
        if [ "$rename_count" -gt 0 ]; then
            echo ""
            echo "  Rename mappings (upstream -> local):"
            node -e "
                const fs = require('fs');
                try {
                    const data = JSON.parse(fs.readFileSync('$MANIFEST_JSON', 'utf8'));
                    const renames = data.renames || {};
                    for (const [src, dst] of Object.entries(renames)) {
                        const type = src.endsWith('/') ? 'dir' : 'file';
                        console.log('    ' + src + ' -> ' + dst + ' (' + type + ')');
                    }
                } catch(e) {}
            "
        fi
    else
        echo ""
        print_info "No manifest found (using legacy sync mode)"
    fi
}

# Show current harness version
do_version() {
    if [ ! -f "$SYNC_CONFIG" ]; then
        print_warning "Sync not initialized"
        return 1
    fi

    local version date_full date
    version=$(json_get "$SYNC_CONFIG" "last_synced_version" "unknown")
    date_full=$(json_get "$SYNC_CONFIG" "last_synced_at" "never")
    date=$(echo "$date_full" | cut -dT -f1)

    echo "Harness $version (synced $date)"
}

# Initialize sync configuration
do_init() {
    print_header "Initializing Harness Sync"

    mkdir -p "$BACKUP_DIR"

    # Create sync config
    if [ ! -f "$SYNC_CONFIG" ]; then
        cat > "$SYNC_CONFIG" <<EOF
{
  "upstream_repo": "$UPSTREAM_REPO",
  "upstream_branch": "$UPSTREAM_BRANCH",
  "last_synced_commit": null,
  "last_synced_version": null,
  "last_synced_at": null,
  "sync_history": [],
  "project_customizations": {
    "ticket_prefix": "{{TICKET_PREFIX}}-",
    "project_name": "{{PROJECT_SHORT}}",
    "main_branch": "dev"
  }
}
EOF
        print_success "Created $SYNC_CONFIG"
    else
        print_info "Config already exists: $SYNC_CONFIG"
    fi

    # Create default exclude file if not exists
    if [ ! -f "$EXCLUDE_FILE" ]; then
        cat > "$EXCLUDE_FILE" <<EOF
# Claude Harness Sync Exclusions
# Files listed here will NEVER be overwritten by upstream sync
# Uses gitignore-style patterns

# Project-specific configurations (CONFIGS only, not scripts!)
settings.local.json
hooks-config.json

# Add any project-specific files below:
# my-custom-file.md
EOF
        print_success "Created $EXCLUDE_FILE"
    else
        print_info "Exclude file already exists: $EXCLUDE_FILE"
    fi

    echo ""
    print_info "Edit $EXCLUDE_FILE to customize what files are synced"
    print_info "Run './scripts/sync-claude-harness.sh status' to check for updates"
}

# List conflicts
do_conflicts() {
    print_header "Checking for Conflicts"

    local count=0
    while IFS= read -r -d '' conflict; do
        echo "  - ${conflict#$CLAUDE_DIR/}"
        count=$((count + 1))
    done < <(find "$CLAUDE_DIR" -name "*.conflict" -print0 2>/dev/null)

    if [ $count -eq 0 ]; then
        print_success "No conflicts found"
    else
        print_warning "$count conflict(s) found"
        echo ""
        echo "To resolve:"
        echo "  1. Review the .conflict file"
        echo "  2. Choose upstream or local version"
        echo "  3. Delete the .conflict file"
    fi
}

# =============================================================================
# Manifest Init Wizard (SAW-12)
# =============================================================================
# Auto-generates .harness-manifest.yml by analyzing the current
# project state: reads team-config.json for identity values, detects which
# setup-template.sh placeholders have been replaced, reads .sync-exclude
# for protected patterns, and outputs a valid manifest.
#
# Subcommands:
#   manifest init              Generate manifest from project state
#   manifest init --dry-run    Print to stdout without writing
#   manifest init --yes        Skip confirmation prompts
#   manifest validate          Run existing validation on manifest
# =============================================================================

# Check if a value looks like an unreplaced template placeholder.
# Returns 0 (true) if the value is a placeholder like {{FOO}}.
is_placeholder() {
    local val="$1"
    [[ "$val" =~ ^\{\{[A-Z_]+\}\}$ ]]
}

# Read identity values from team-config.json.
# Outputs lines: "KEY=VALUE" for each detected non-placeholder identity value.
# Values that are still {{PLACEHOLDER}} are skipped.
read_team_config_identity() {
    local team_config="$1"

    if [ ! -f "$team_config" ]; then
        return 0
    fi

    node -e "
        const fs = require('fs');
        try {
            const data = JSON.parse(fs.readFileSync('$team_config', 'utf8'));
            const map = [
                ['project.name', 'PROJECT_NAME'],
                ['project.repo', 'PROJECT_REPO'],
                ['project.short_name', 'PROJECT_SHORT'],
                ['project.domain', 'PROJECT_DOMAIN'],
                ['project.github_org', 'GITHUB_ORG'],
                ['project.company', 'COMPANY_NAME'],
                ['workflow.ticket_prefix', 'TICKET_PREFIX'],
                ['workflow.main_branch', 'MAIN_BRANCH'],
                ['workflow.linear_workspace', 'LINEAR_WORKSPACE'],
                ['mcp_servers.linear', 'MCP_LINEAR_SERVER'],
                ['mcp_servers.confluence', 'MCP_CONFLUENCE_SERVER'],
                ['review_stages.stage_2.reviewer', 'ARCHITECT_GITHUB_HANDLE'],
                ['review_stages.stage_3.reviewer', 'AUTHOR_HANDLE'],
            ];

            for (const [path, key] of map) {
                const parts = path.split('.');
                let val = data;
                for (const p of parts) {
                    if (val == null) break;
                    val = val[p];
                }
                if (typeof val === 'string' && val.length > 0) {
                    // Skip unreplaced placeholders
                    if (/^\{\{[A-Z_]+\}\}$/.test(val)) continue;
                    console.log(key + '=' + val);
                }
            }
        } catch(e) {}
    "
}

# Scan for additional derived substitutions from known identity values.
# Given a set of known identity values, computes derived values such as
# TICKET_PREFIX_LOWER and GITHUB_REPO_URL.
#
# Outputs lines: "KEY=VALUE" for derived substitutions.
# Arguments:
#   $1 - path to .claude/ directory
#   $2 - newline-separated KEY=VALUE pairs already discovered from team-config
scan_for_additional_substitutions() {
    local claude_dir="$1"
    local known_pairs="$2"

    if [ -z "$known_pairs" ]; then
        return 0
    fi

    # Build a JSON object of known values for node to consume
    local known_json
    known_json=$(echo "$known_pairs" | node -e "
        const lines = require('fs').readFileSync(0, 'utf8').split('\n').filter(Boolean);
        const obj = {};
        for (const line of lines) {
            const eq = line.indexOf('=');
            if (eq > 0) obj[line.slice(0, eq)] = line.slice(eq + 1);
        }
        console.log(JSON.stringify(obj));
    ")

    node -e "
        const known = $known_json;
        const derived = {};

        // Derive TICKET_PREFIX_LOWER if we have TICKET_PREFIX
        if (known['TICKET_PREFIX']) {
            derived['TICKET_PREFIX_LOWER'] = known['TICKET_PREFIX'].toLowerCase();
        }
        // Derive GITHUB_REPO_URL if we have both
        if (known['GITHUB_ORG'] && known['PROJECT_REPO']) {
            derived['GITHUB_REPO_URL'] = 'https://github.com/' + known['GITHUB_ORG'] + '/' + known['PROJECT_REPO'];
        }

        // Output derived values
        for (const [key, val] of Object.entries(derived)) {
            console.log(key + '=' + val);
        }
    "
}

# Read .sync-exclude and convert entries to protected patterns.
# Returns one pattern per line (comments and empty lines stripped).
read_sync_exclude_patterns() {
    local exclude_file="$1"

    if [ ! -f "$exclude_file" ]; then
        return 0
    fi

    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^[[:space:]]*$ ]] && continue
        # Trim whitespace
        line=$(echo "$line" | xargs)
        echo "$line"
    done < "$exclude_file"
}

# Generate YAML manifest content from discovered values.
# Arguments:
#   $1 - newline-separated KEY=VALUE identity pairs
#   $2 - newline-separated KEY=VALUE substitution pairs (identity + derived)
#   $3 - newline-separated protected patterns
# Outputs the complete YAML manifest to stdout.
generate_manifest_yaml() {
    local identity_pairs="$1"
    local substitution_pairs="$2"
    local protected_patterns="$3"

    node -e "
        const identity_lines = \`$identity_pairs\`.split('\n').filter(Boolean);
        const sub_lines = \`$substitution_pairs\`.split('\n').filter(Boolean);
        const protected_lines = \`$protected_patterns\`.split('\n').filter(Boolean);

        // Parse KEY=VALUE pairs
        function parsePairs(lines) {
            const obj = {};
            for (const line of lines) {
                const eq = line.indexOf('=');
                if (eq > 0) {
                    obj[line.slice(0, eq)] = line.slice(eq + 1);
                }
            }
            return obj;
        }

        const identity = parsePairs(identity_lines);
        const subs = parsePairs(sub_lines);

        // All identity fields from the schema (in order)
        const allIdentityFields = [
            'PROJECT_NAME', 'PROJECT_REPO', 'PROJECT_SHORT', 'PROJECT_DOMAIN',
            'GITHUB_ORG', 'COMPANY_NAME',
            'AUTHOR_NAME', 'AUTHOR_FIRST_NAME', 'AUTHOR_LAST_NAME',
            'AUTHOR_HANDLE', 'AUTHOR_EMAIL', 'AUTHOR_WEBSITE',
            'SECURITY_EMAIL', 'ARCHITECT_GITHUB_HANDLE',
            'TICKET_PREFIX', 'LINEAR_WORKSPACE', 'MAIN_BRANCH',
            'MCP_LINEAR_SERVER', 'MCP_CONFLUENCE_SERVER',
            'DB_USER', 'DB_PASSWORD', 'DB_NAME',
            'DB_CONTAINER', 'DEV_CONTAINER', 'STAGING_CONTAINER',
            'CONTAINER_REGISTRY'
        ];

        // Build YAML output
        let yaml = '';
        yaml += '# =============================================================================\n';
        yaml += '# Harness Manifest - Auto-generated by manifest init\n';
        yaml += '# =============================================================================\n';
        yaml += '#\n';
        yaml += '# Generated from project state analysis. Review and adjust values as needed.\n';
        yaml += '# Schema: .harness-manifest.schema.json\n';
        yaml += '# Docs: docs/HARNESS_MANIFEST_SCHEMA.md\n';
        yaml += '#\n';
        yaml += '# Fields marked with \"{{...}}\" were not detected and should be filled manually.\n';
        yaml += '# =============================================================================\n';
        yaml += '\n';

        // Schema version
        yaml += 'manifest_version: \"1.0\"\n';
        yaml += '\n';

        // Identity section
        yaml += '# Project identity values from team-config.json and project scan\n';
        yaml += 'identity:\n';
        for (const field of allIdentityFields) {
            const val = identity[field] || subs[field];
            if (val) {
                yaml += '  ' + field + ': \"' + val.replace(/\"/g, '\\\\\"') + '\"\n';
            } else {
                yaml += '  ' + field + ': \"{{' + field + '}}\"\n';
            }
        }
        yaml += '\n';

        // Substitutions section: only include non-derived identity values
        // that were actually detected (not placeholders)
        yaml += '# Substitution map: upstream {{TOKEN}} -> fork value during sync\n';
        yaml += '# Derived values (TICKET_PREFIX_LOWER, AUTHOR_INITIALS, GITHUB_REPO_URL,\n';
        yaml += '# HARNESS_VERSION) are computed automatically and do not need listing.\n';
        const subEntries = {};
        for (const [key, val] of Object.entries(identity)) {
            // Only include as substitution if it is a real (non-placeholder) value
            if (val && !/^\{\{[A-Z_]+\}\}$/.test(val)) {
                subEntries[key] = val;
            }
        }
        // Also include derived values from scan
        for (const [key, val] of Object.entries(subs)) {
            if (val && !identity[key] && !/^\{\{[A-Z_]+\}\}$/.test(val)) {
                subEntries[key] = val;
            }
        }

        if (Object.keys(subEntries).length > 0) {
            yaml += 'substitutions:\n';
            for (const [key, val] of Object.entries(subEntries)) {
                yaml += '  ' + key + ': \"' + val.replace(/\"/g, '\\\\\"') + '\"\n';
            }
        } else {
            yaml += 'substitutions: {}\n';
        }
        yaml += '\n';

        // Renames section (empty by default -- user adds manually)
        yaml += '# Rename mappings: upstream path -> local path (relative to .claude/)\n';
        yaml += '# Add entries if you have renamed files or directories from upstream.\n';
        yaml += 'renames: {}\n';
        yaml += '\n';

        // Protected section from .sync-exclude
        if (protected_lines.length > 0) {
            yaml += '# Protected files: never overwritten during sync\n';
            yaml += '# Imported from .sync-exclude\n';
            yaml += 'protected:\n';
            for (const pat of protected_lines) {
                yaml += '  - \"' + pat.replace(/\"/g, '\\\\\"') + '\"\n';
            }
        } else {
            yaml += '# Protected files: never overwritten during sync\n';
            yaml += 'protected: []\n';
        }
        yaml += '\n';

        // Replaced section (empty by default)
        yaml += '# Replaced files: fork maintains independently, warn if upstream changes\n';
        yaml += 'replaced: []\n';
        yaml += '\n';

        // Sync preferences
        yaml += '# Sync behavior preferences\n';
        yaml += 'sync:\n';
        yaml += '  auto_substitute: true\n';
        yaml += '  backup: true\n';
        yaml += '  conflict_strategy: \"prompt\"\n';
        yaml += '  substitution_extensions:\n';
        yaml += '    - \".md\"\n';
        yaml += '    - \".json\"\n';
        yaml += '    - \".yml\"\n';
        yaml += '    - \".yaml\"\n';
        yaml += '    - \".sh\"\n';
        yaml += '    - \".py\"\n';
        yaml += '    - \".ts\"\n';
        yaml += '    - \".mjs\"\n';
        yaml += '    - \".txt\"\n';
        yaml += '    - \".toml\"\n';

        process.stdout.write(yaml);
    "
}

# Main manifest init function.
# Analyzes the project state and generates .harness-manifest.yml (repo root).
do_manifest_init() {
    local dry_run=false
    local skip_confirm=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)
                dry_run=true
                shift
                ;;
            --yes|-y)
                skip_confirm=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    print_header "Manifest Init Wizard"

    # Check if manifest already exists
    if [ -f "$MANIFEST_FILE" ] && [ "$dry_run" = false ]; then
        print_warning "Manifest already exists at $MANIFEST_FILE"
        if [ "$skip_confirm" = false ]; then
            echo ""
            read -rp "Overwrite? (y/N): " confirm
            if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
                print_info "Aborted. Existing manifest preserved."
                return 0
            fi
        fi
    fi

    # --- Step 1: Read team-config.json for identity values ---
    local team_config="$CLAUDE_DIR/team-config.json"
    local identity_pairs=""

    if [ -f "$team_config" ]; then
        print_info "Reading team-config.json..."
        identity_pairs=$(read_team_config_identity "$team_config")
        local identity_count
        identity_count=$(echo "$identity_pairs" | grep -c '.' 2>/dev/null || echo "0")
        print_success "Found $identity_count identity value(s) in team-config.json"
    else
        print_warning "No team-config.json found at $team_config"
        print_info "Identity section will use placeholder values"
    fi

    # --- Step 2: Scan for additional substitutions ---
    print_info "Scanning for additional substitutions..."
    local additional_pairs=""
    additional_pairs=$(scan_for_additional_substitutions "$CLAUDE_DIR" "$identity_pairs")
    if [ -n "$additional_pairs" ]; then
        local add_count
        add_count=$(echo "$additional_pairs" | grep -c '.' 2>/dev/null || echo "0")
        print_success "Found $add_count derived substitution(s)"
    fi

    # Merge identity + additional pairs for substitutions
    local all_sub_pairs=""
    if [ -n "$identity_pairs" ]; then
        all_sub_pairs="$identity_pairs"
    fi
    if [ -n "$additional_pairs" ]; then
        if [ -n "$all_sub_pairs" ]; then
            all_sub_pairs="$all_sub_pairs"$'\n'"$additional_pairs"
        else
            all_sub_pairs="$additional_pairs"
        fi
    fi

    # --- Step 3: Read .sync-exclude for protected patterns ---
    local protected_patterns=""
    if [ -f "$EXCLUDE_FILE" ]; then
        print_info "Reading .sync-exclude for protected patterns..."
        protected_patterns=$(read_sync_exclude_patterns "$EXCLUDE_FILE")
        if [ -n "$protected_patterns" ]; then
            local prot_count
            prot_count=$(echo "$protected_patterns" | grep -c '.' 2>/dev/null || echo "0")
            print_success "Found $prot_count protected pattern(s) from .sync-exclude"
        fi
    else
        print_info "No .sync-exclude found; protected section will be empty"
    fi

    # --- Step 4: Generate YAML ---
    print_info "Generating manifest..."
    local yaml_content
    yaml_content=$(generate_manifest_yaml "$identity_pairs" "$all_sub_pairs" "$protected_patterns")

    if [ -z "$yaml_content" ]; then
        print_error "Failed to generate manifest YAML"
        return 1
    fi

    # --- Step 5: Validate generated manifest ---
    # Write to temp file for validation
    local tmp_manifest="$TMP_DIR/manifest-init-check.yml"
    mkdir -p "$TMP_DIR"
    echo "$yaml_content" > "$tmp_manifest"

    # Parse YAML to JSON for validation
    local tmp_json="$TMP_DIR/manifest-init-check.json"
    local parse_ok=true
    python3 -c "
import sys, json
try:
    import yaml
except ImportError:
    print('PyYAML not installed', file=sys.stderr)
    sys.exit(1)
try:
    with open(sys.argv[1], 'r') as f:
        data = yaml.safe_load(f)
    if data is None:
        data = {}
    with open(sys.argv[2], 'w') as f:
        json.dump(data, f, indent=2)
except Exception as e:
    print(str(e), file=sys.stderr)
    sys.exit(2)
" "$tmp_manifest" "$tmp_json" 2>/dev/null || parse_ok=false

    if [ "$parse_ok" = true ]; then
        # Validate required fields
        local validation_ok=true
        local val_output=""
        val_output=$(node -e "
            const fs = require('fs');
            try {
                const data = JSON.parse(fs.readFileSync('$tmp_json', 'utf8'));
                const errors = [];
                if (!data.manifest_version) errors.push('missing manifest_version');
                if (!data.identity) errors.push('missing identity');
                if (data.identity) {
                    const required = ['PROJECT_NAME', 'PROJECT_REPO', 'PROJECT_SHORT', 'GITHUB_ORG', 'TICKET_PREFIX', 'MAIN_BRANCH'];
                    for (const f of required) {
                        const val = data.identity[f];
                        if (!val || /^\{\{[A-Z_]+\}\}$/.test(val)) {
                            errors.push('identity.' + f + ' is still a placeholder');
                        }
                    }
                }
                if (errors.length > 0) {
                    console.log('WARN:' + errors.join('|'));
                } else {
                    console.log('OK');
                }
            } catch(e) {
                console.log('WARN:parse error');
            }
        ")

        if [[ "$val_output" == OK ]]; then
            print_success "Generated manifest passes schema validation"
        else
            local warnings="${val_output#WARN:}"
            print_warning "Generated manifest has incomplete fields (fill manually):"
            echo "$warnings" | tr '|' '\n' | while IFS= read -r w; do
                echo "  - $w"
            done
        fi
    else
        print_warning "Could not validate generated manifest (PyYAML unavailable)"
    fi

    # --- Output ---
    if [ "$dry_run" = true ]; then
        echo ""
        print_header "Generated Manifest (dry-run)"
        echo "$yaml_content"
        echo ""
        print_info "Dry run complete. No files written."
        print_info "Run without --dry-run to write to $MANIFEST_FILE"
        return 0
    fi

    # Confirm before writing (unless --yes)
    if [ "$skip_confirm" = false ]; then
        echo ""
        echo "$yaml_content"
        echo ""
        read -rp "Write manifest to $MANIFEST_FILE? (y/N): " confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            print_info "Aborted. No files written."
            return 0
        fi
    fi

    # Write manifest
    mkdir -p "$(dirname "$MANIFEST_FILE")"
    echo "$yaml_content" > "$MANIFEST_FILE"
    print_success "Manifest written to $MANIFEST_FILE"

    # Load and validate the written manifest
    load_manifest
    if [ "$HAS_MANIFEST" = "true" ]; then
        validate_manifest || true  # Non-fatal; user can fix manually
    fi

    echo ""
    print_info "Next steps:"
    print_info "  1. Review the manifest: cat $MANIFEST_FILE"
    print_info "  2. Fill any remaining {{...}} placeholders manually"
    print_info "  3. Add renames if you have renamed upstream files"
    print_info "  4. Validate: $0 manifest validate"
}

# Handle the manifest subcommand dispatcher.
do_manifest_command() {
    local subcmd="${1:-}"
    shift 2>/dev/null || true

    case "$subcmd" in
        init)
            do_manifest_init "$@"
            ;;
        validate)
            load_manifest
            if [ "$HAS_MANIFEST" != "true" ]; then
                print_error "No manifest found at $MANIFEST_FILE"
                print_info "Run '$0 manifest init' to generate one"
                return 1
            fi
            validate_manifest
            ;;
        *)
            echo "Usage: $0 manifest {init|validate} [options]"
            echo ""
            echo "Subcommands:"
            echo "  init       Generate .harness-manifest.yml from project state"
            echo "  validate   Validate existing manifest against schema"
            echo ""
            echo "Init options:"
            echo "  --dry-run   Print manifest to stdout without writing"
            echo "  --yes       Skip confirmation prompts"
            return 1
            ;;
    esac
}

# =============================================================================
# End Manifest Init Wizard
# =============================================================================

# Show help
show_help() {
    cat <<EOF
Claude Code Harness Sync Script

Syncs harness domains from upstream repository while preserving
project-specific customizations. Supports multi-domain sync via sync_scope.

USAGE:
    $0 <command> [options]

COMMANDS:
    init              Initialize sync configuration
    status            Show sync status and check for updates
    version           Show current harness version
    diff              Show detailed differences with upstream
    sync              Sync from upstream
    manifest          Manifest management (init, validate)
    rollback          Restore from most recent backup
    conflicts         List unresolved conflicts
    releases          List available releases
    help              Show this help

SYNC OPTIONS:
    --dry-run           Preview changes without applying
    --version <tag>     Sync to specific release tag (e.g., v2.10.0)
    --latest            Sync to latest release
    --scope <domains>   Override sync_scope for this command (comma-separated)
                        Example: --scope .claude,.gemini,.codex
                        Does NOT modify .harness-manifest.yml
    --no-placeholders   Skip placeholder substitution step
    --skip-preflight    Skip preflight safety checks (advanced users only)
    --generate-patches  Generate .patch files instead of overwriting

    NOTE: sync requires a manifest (.harness-manifest.yml). Without one,
    sync will fail. Run 'manifest init' first. Only --dry-run is allowed
    without a manifest.

PREFLIGHT (SAW-2):
    A preflight safety check runs automatically before every sync.
    It validates:
      (a) All files are within configured sync domains (no path traversal)
      (b) No manifest substitution tokens remain unreplaced
      (c) No protected files would be modified
    Use --skip-preflight to bypass (logged as warning).

PROVENANCE (SAW-2):
    After each sync, .harness-sync.json records:
      - last_sync_commit: upstream source commit SHA
      - last_sync_version: upstream version/tag synced to
      - last_sync_timestamp: ISO 8601 timestamp
      - sync_history: last 10 sync entries with full provenance

EXAMPLES:
    # First time setup
    $0 init

    # Check for updates
    $0 status

    # Preview changes
    $0 sync --dry-run

    # Sync to specific release (RECOMMENDED)
    $0 sync --version v2.2.0

    # Sync to latest release
    $0 sync --latest

    # Sync without applying substitutions
    $0 sync --latest --no-placeholders

    # Sync bypassing preflight (advanced)
    $0 sync --latest --skip-preflight

    # Generate patches instead of overwriting files (SAW-4)
    $0 sync --generate-patches --version v2.6.0

    # If something breaks
    $0 rollback

CONFIGURATION:
    Metadata:   .harness-sync.json (repo root; migrated from .claude/ automatically)
    Exclusions: .claude/.sync-exclude (legacy fallback)
    Manifest:   .harness-manifest.yml (repo root; migrated from .claude/ automatically)
    Schema:     .harness-manifest.schema.json
    Backups:    .harness-backup/ (repo root; migrated from .claude/ automatically)
    Patches:    .harness-patches/<version>/  (generated by --generate-patches)

PATCH GENERATION (SAW-4):
    --generate-patches creates unified diff patches instead of overwriting.
    Patches are:
      - Rename-aware: use fork's local paths in patch headers
      - Substitution-aware: use fork's placeholder values
      - Valid for git apply --check
    Output: .harness-patches/<version>/ with APPLY_ORDER.md

MANIFEST:
    When .harness-manifest.yml is present, the sync script loads
    and validates it on every command invocation (fail-fast). The manifest
    declares renames, substitutions, protected files, and sync preferences.
    Without a manifest, the script uses legacy file-level copy behavior.

MANIFEST INIT (SAW-12):
    The 'manifest init' command auto-generates a manifest by analyzing:
      - .claude/team-config.json for identity values
      - Replaced {{PLACEHOLDER}} tokens from setup-template.sh
      - .sync-exclude for protected file patterns
    Options:
      --dry-run   Print generated manifest to stdout without writing
      --yes       Skip confirmation prompts

    Examples:
      $0 manifest init               # Interactive generation
      $0 manifest init --dry-run     # Preview without writing
      $0 manifest init --yes         # Non-interactive generation
      $0 manifest validate           # Validate existing manifest

EOF
}

# Main command handler
# Check dependencies for commands that need them
case "${1:-}" in
    help|--help|-h)
        # No dependencies needed for help
        ;;
    *)
        check_dependencies
        migrate_metadata_to_root
        ;;
esac

case "${1:-}" in
    init)
        do_init
        # After init, load manifest to report its status (informational only)
        load_manifest
        if [ "$HAS_MANIFEST" = "true" ]; then
            validate_manifest || true  # Non-fatal during init
        fi
        exit 0
        ;;
    status)
        load_config
        load_manifest
        if [ "$HAS_MANIFEST" = "true" ]; then
            validate_manifest || exit 1
        fi
        do_status
        exit $?
        ;;
    version)
        load_manifest
        if [ "$HAS_MANIFEST" = "true" ]; then
            validate_manifest || exit 1
        fi
        do_version
        exit $?
        ;;
    diff)
        load_config
        load_manifest
        if [ "$HAS_MANIFEST" = "true" ]; then
            validate_manifest || exit 1
        fi
        do_diff "${2:-}"
        exit $?
        ;;
    sync)
        load_config
        load_manifest
        if [ "$HAS_MANIFEST" = "true" ]; then
            validate_manifest || exit 1
        fi
        shift
        do_sync "$@"
        exit $?
        ;;
    manifest)
        shift
        do_manifest_command "$@"
        exit $?
        ;;
    rollback)
        do_rollback
        exit $?
        ;;
    conflicts)
        do_conflicts
        exit $?
        ;;
    releases)
        load_config
        list_releases
        exit $?
        ;;
    help|--help|-h)
        show_help
        exit 0
        ;;
    *)
        echo "Usage: $0 {init|status|version|diff|sync|manifest|rollback|conflicts|releases|help}"
        echo "Run '$0 help' for more information"
        exit 1
        ;;
esac
