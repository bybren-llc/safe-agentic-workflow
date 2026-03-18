#!/bin/bash
#
# Claude Code Harness Sync Script
#
# Syncs .claude/ directory from upstream repository while preserving
# project-specific customizations.
#
# Usage:
#   ./scripts/sync-claude-harness.sh init              # Initialize sync config
#   ./scripts/sync-claude-harness.sh status            # Check sync status
#   ./scripts/sync-claude-harness.sh version           # Show current harness version
#   ./scripts/sync-claude-harness.sh diff              # Show detailed differences
#   ./scripts/sync-claude-harness.sh sync --dry-run    # Preview changes
#   ./scripts/sync-claude-harness.sh sync --version v2.2.0  # Sync to specific release
#   ./scripts/sync-claude-harness.sh sync --latest     # Sync to latest release
#   ./scripts/sync-claude-harness.sh rollback          # Restore from backup
#   ./scripts/sync-claude-harness.sh conflicts         # List unresolved conflicts
#   ./scripts/sync-claude-harness.sh help              # Show help

set -e

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="$PROJECT_ROOT/.claude"
SYNC_CONFIG="$CLAUDE_DIR/.harness-sync.json"
EXCLUDE_FILE="$CLAUDE_DIR/.sync-exclude"
EXCLUDE_DEFAULT="$CLAUDE_DIR/.sync-exclude.default"
BACKUP_DIR="$CLAUDE_DIR/.harness-backup"
MANIFEST_FILE="$CLAUDE_DIR/.harness-manifest.yml"
MANIFEST_SCHEMA="$PROJECT_ROOT/.harness-manifest.schema.json"
TMP_DIR="/tmp/claude-harness-sync-$$"
MANIFEST_JSON=""  # Path to cached JSON parse of manifest (set by load_manifest)
HAS_MANIFEST=false

# Upstream configuration (defaults, can be overridden via config)
UPSTREAM_REPO="{{GITHUB_ORG}}/{{PROJECT_REPO}}"
UPSTREAM_BRANCH="main"
UPSTREAM_PATH=".claude"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

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
# When .claude/.harness-manifest.yml exists, parse it and make its data
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

    if [ ! -d "$TMP_DIR/.claude" ]; then
        return 0
    fi

    # Check each rename source path against the fetched upstream
    node -e "
        const fs = require('fs');
        const path = require('path');
        try {
            const data = JSON.parse(fs.readFileSync('$MANIFEST_JSON', 'utf8'));
            const renames = data.renames || {};
            const upstreamBase = '$TMP_DIR/.claude';
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
compare_file_with_paths() {
    local upstream_rel_path="$1"
    local local_rel_path="$2"
    local upstream_file="$TMP_DIR/.claude/$upstream_rel_path"
    local local_file="$CLAUDE_DIR/$local_rel_path"

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

    # Get all local file paths relative to .claude/
    local local_files_list="$TMP_DIR/local_files_for_protected.txt"
    mkdir -p "$TMP_DIR"
    if [ -d "$CLAUDE_DIR" ]; then
        find "$CLAUDE_DIR" -type f ! -path "$BACKUP_DIR/*" -print0 2>/dev/null | \
            while IFS= read -r -d '' f; do
                echo "${f#$CLAUDE_DIR/}"
            done > "$local_files_list"
    else
        touch "$local_files_list"
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

# Create backup before sync
create_backup() {
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local backup_path="$BACKUP_DIR/$timestamp"

    print_info "Creating backup at $backup_path"

    mkdir -p "$backup_path"

    # Copy all files except metadata
    while IFS= read -r -d '' file; do
        local rel_path="${file#$CLAUDE_DIR/}"
        local dest="$backup_path/$rel_path"
        mkdir -p "$(dirname "$dest")"
        cp "$file" "$dest"
    done < <(find "$CLAUDE_DIR" -type f ! -name ".harness-sync.json" ! -name ".sync-exclude" \
        ! -path "$BACKUP_DIR/*" -print0 2>/dev/null)

    # Prune old backups (keep last 3)
    local count=0
    for dir in $(ls -1dt "$BACKUP_DIR"/*/ 2>/dev/null); do
        count=$((count + 1))
        if [ $count -gt 3 ]; then
            rm -rf "$dir"
            print_info "Pruned old backup: $(basename "$dir")"
        fi
    done

    print_success "Backup created"
    echo "$timestamp"
}

# Restore from backup
do_rollback() {
    print_header "Rollback"

    if [ ! -d "$BACKUP_DIR" ]; then
        print_error "No backups found"
        return 1
    fi

    # Get most recent backup
    local latest_backup
    latest_backup=$(ls -1dt "$BACKUP_DIR"/*/ 2>/dev/null | head -1)

    if [ -z "$latest_backup" ]; then
        print_error "No backups available"
        return 1
    fi

    local backup_name
    backup_name=$(basename "$latest_backup")
    print_info "Restoring from backup: $backup_name"

    # Restore files
    local restored=0
    while IFS= read -r -d '' file; do
        local rel_path="${file#$latest_backup/}"
        local dest="$CLAUDE_DIR/$rel_path"
        mkdir -p "$(dirname "$dest")"
        cp "$file" "$dest"
        restored=$((restored + 1))
    done < <(find "$latest_backup" -type f -print0)

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

    print_success "Rollback complete from $backup_name"
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
    # Associative arrays: dir_rename_counts["src|dst"] = count
    declare -A dir_rename_counts

    # Check upstream files
    while IFS= read -r -d '' file; do
        local rel_path="${file#$TMP_DIR/.claude/}"

        if is_excluded "$rel_path"; then
            # Distinguish PROTECTED (manifest) from EXCLUDED (.sync-exclude / hardcoded)
            if is_manifest_protected "$rel_path"; then
                echo -e "${YELLOW}PROTECTED${NC}  $rel_path (upstream has changes, skipping per manifest)"
                protected=$((protected + 1))
            else
                echo -e "${YELLOW}EXCLUDED${NC}  $rel_path"
                excluded=$((excluded + 1))
            fi
            continue
        fi

        # Resolve rename: map upstream path to local path
        local local_path
        local rtype
        local_path=$(resolve_rename "$rel_path")
        rtype=$(rename_type "$rel_path")

        # Also check exclusion for the resolved local path
        if [ "$local_path" != "$rel_path" ] && is_excluded "$local_path"; then
            if is_manifest_protected "$local_path"; then
                echo -e "${YELLOW}PROTECTED${NC}  $local_path (upstream has changes, skipping per manifest)"
                protected=$((protected + 1))
            else
                echo -e "${YELLOW}EXCLUDED${NC}  $local_path (renamed from $rel_path)"
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
    done < <(find "$TMP_DIR/.claude" -type f -print0 2>/dev/null)

    # Check for files only in local (deleted from upstream)
    # Build a set of all resolved local paths from upstream for efficient lookup
    local resolved_local_paths_file="$TMP_DIR/resolved_local_paths.txt"
    while IFS= read -r -d '' file; do
        local rel_path="${file#$TMP_DIR/.claude/}"
        resolve_rename "$rel_path"
    done < <(find "$TMP_DIR/.claude" -type f -print0 2>/dev/null) > "$resolved_local_paths_file"

    while IFS= read -r -d '' file; do
        local rel_path="${file#$CLAUDE_DIR/}"

        # Skip metadata and excluded files
        [[ "$rel_path" == .harness-* ]] && continue
        [[ "$rel_path" == .sync-* ]] && continue
        is_excluded "$rel_path" && continue

        # Check if this local path is accounted for (either as direct upstream or as rename target)
        local upstream_file="$TMP_DIR/.claude/$rel_path"
        if [ -f "$upstream_file" ]; then
            continue
        fi

        # Check if this local path is a rename target
        if grep -qxF "$rel_path" "$resolved_local_paths_file" 2>/dev/null; then
            continue
        fi

        echo -e "${RED}LOCAL ONLY${NC} $rel_path"
        deleted=$((deleted + 1))
    done < <(find "$CLAUDE_DIR" -type f ! -path "$BACKUP_DIR/*" -print0 2>/dev/null)

    # Show directory rename summary lines
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

# Perform sync
do_sync() {
    local dry_run=false
    local version=""
    local use_latest=false
    local no_placeholders=false

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
            *)
                shift
                ;;
        esac
    done

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

    if [ "$dry_run" = true ]; then
        print_header "Dry Run - No changes will be made"
    else
        print_header "Syncing Harness"
    fi

    fetch_upstream "$ref" || return 1

    # Validate rename sources against fetched upstream tree
    validate_renames_against_upstream

    # Validate protected patterns against local files (warn on typos)
    validate_protected_paths

    # Create backup before sync (unless dry run)
    if [ "$dry_run" = false ]; then
        create_backup
    fi

    local updated=0 skipped=0 conflicts=0 new_files=0 protected_count=0
    local sha
    sha=$(get_upstream_sha "$ref")

    # Process upstream files
    while IFS= read -r -d '' file; do
        local rel_path="${file#$TMP_DIR/.claude/}"

        if is_excluded "$rel_path"; then
            # Distinguish protected (manifest) from excluded (.sync-exclude / hardcoded)
            if is_manifest_protected "$rel_path"; then
                print_warning "Skipping protected: $rel_path (upstream has changes, skipping per manifest)"
                protected_count=$((protected_count + 1))
            else
                print_warning "Skipping excluded: $rel_path"
            fi
            skipped=$((skipped + 1))
            continue
        fi

        # Resolve rename: map upstream path to local path
        local local_path
        local_path=$(resolve_rename "$rel_path")
        local local_file="$CLAUDE_DIR/$local_path"

        # Also check exclusion for the resolved local path
        if [ "$local_path" != "$rel_path" ] && is_excluded "$local_path"; then
            if is_manifest_protected "$local_path"; then
                print_warning "Skipping protected: $local_path (upstream has changes, skipping per manifest)"
                protected_count=$((protected_count + 1))
            else
                print_warning "Skipping excluded: $local_path (renamed from $rel_path)"
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
                    cp "$file" "$local_file"
                fi
                print_success "Added: $display_path"
                new_files=$((new_files + 1))
                updated=$((updated + 1))
                ;;
            modified)
                if [ "$dry_run" = false ]; then
                    # Check if local has custom modifications we should preserve
                    # For now, just copy upstream (user can rollback if needed)
                    cp "$file" "$local_file"
                fi
                print_success "Updated: $display_path"
                updated=$((updated + 1))
                ;;
            unchanged)
                # No action needed
                ;;
        esac
    done < <(find "$TMP_DIR/.claude" -type f -print0 2>/dev/null)

    # Apply placeholder substitutions after file copy (SAW-10)
    # Backup retains upstream originals; substitution happens on local copies.
    if [ "$dry_run" = false ] && [ "$no_placeholders" = false ] && [ "$HAS_MANIFEST" = "true" ]; then
        apply_all_substitutions "$CLAUDE_DIR"
    elif [ "$no_placeholders" = true ]; then
        print_info "Skipping placeholder substitutions (--no-placeholders)"
    fi

    # Update sync metadata (unless dry run)
    if [ "$dry_run" = false ]; then
        update_sync_metadata "$sha" "$ref" "$updated" "$skipped" "$conflicts"
    fi

    echo ""
    local sync_summary="Summary: $updated updated ($new_files new), $skipped skipped, $conflicts conflicts"
    if [ "$protected_count" -gt 0 ]; then
        sync_summary="$sync_summary, $protected_count protected"
    fi
    print_info "$sync_summary"

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

            // Update main fields
            data.last_synced_commit = '$commit';
            data.last_synced_version = '$version';
            data.last_synced_at = '$timestamp';

            // Add to sync history (keep last 10)
            const historyEntry = {
                commit: '$commit',
                version: '$version',
                synced_at: '$timestamp',
                files_updated: $updated,
                files_skipped: $skipped,
                conflicts: $conflicts
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

# Show help
show_help() {
    cat <<EOF
Claude Code Harness Sync Script

Syncs .claude/ directory from upstream repository while preserving
project-specific customizations.

USAGE:
    $0 <command> [options]

COMMANDS:
    init              Initialize sync configuration
    status            Show sync status and check for updates
    version           Show current harness version
    diff              Show detailed differences with upstream
    sync              Sync from upstream
    rollback          Restore from most recent backup
    conflicts         List unresolved conflicts
    releases          List available releases
    help              Show this help

SYNC OPTIONS:
    --dry-run           Preview changes without applying
    --version <tag>     Sync to specific release tag (e.g., v2.2.0)
    --latest            Sync to latest release
    --no-placeholders   Skip placeholder substitution step

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

    # If something breaks
    $0 rollback

CONFIGURATION:
    Metadata:   .claude/.harness-sync.json
    Exclusions: .claude/.sync-exclude
    Manifest:   .claude/.harness-manifest.yml (optional, enables smart sync)
    Schema:     .harness-manifest.schema.json
    Backups:    .claude/.harness-backup/

MANIFEST:
    When .claude/.harness-manifest.yml is present, the sync script loads
    and validates it on every command invocation (fail-fast). The manifest
    declares renames, substitutions, protected files, and sync preferences.
    Without a manifest, the script uses legacy file-level copy behavior.

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
        echo "Usage: $0 {init|status|version|diff|sync|rollback|conflicts|releases|help}"
        echo "Run '$0 help' for more information"
        exit 1
        ;;
esac
