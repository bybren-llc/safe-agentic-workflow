#!/bin/bash
#
# generate-changelog.sh -- Auto-generate structured changelog from git diff
#
# Compares two git refs and produces a structured changelog matching the
# HARNESS_CHANGELOG.yml schema (v1.0.0). Categorizes .claude/ file changes
# into NEW_FILE, UPDATED_FILE, METHODOLOGY, BREAKING, and CONFIG.
#
# Usage:
#   ./scripts/generate-changelog.sh --from v2.6.0 --to v2.7.0
#   ./scripts/generate-changelog.sh --from v2.6.0 --to HEAD --format markdown
#   ./scripts/generate-changelog.sh --from v2.6.0 --to v2.7.0 --version 2.7.0
#   ./scripts/generate-changelog.sh --help
#
# Part of the SAFe Agentic Workflow harness.

set -euo pipefail

# -----------------------------------------------------------------------------
# Constants
# -----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SCHEMA_VERSION="1.0.0"

# Colors (disabled if stdout is not a terminal)
if [ -t 1 ]; then
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    NC='\033[0m'
else
    BLUE='' YELLOW='' RED='' NC=''
fi

# -----------------------------------------------------------------------------
# Defaults
# -----------------------------------------------------------------------------
FROM_REF=""
TO_REF=""
OUTPUT_FORMAT="yaml"
RELEASE_VERSION=""
RELEASE_SUMMARY=""

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------

usage() {
    cat <<'USAGE'
generate-changelog.sh -- Auto-generate structured changelog from git diff

USAGE:
  ./scripts/generate-changelog.sh --from <ref> --to <ref> [OPTIONS]

REQUIRED:
  --from <ref>       Starting git ref (tag, SHA, or branch)
  --to <ref>         Ending git ref (tag, SHA, or branch)

OPTIONS:
  --format <fmt>     Output format: "yaml" (default) or "markdown"
  --version <ver>    Release version string (e.g., "2.7.0"). If omitted,
                     derived from --to ref (strips leading "v").
  --summary <text>   One-line release summary. If omitted, auto-generated.
  --help             Show this help message and exit.

EXAMPLES:
  # Generate YAML changelog between two tags
  ./scripts/generate-changelog.sh --from v2.6.0 --to v2.7.0

  # Generate markdown summary from a tag to HEAD
  ./scripts/generate-changelog.sh --from v2.6.0 --to HEAD --format markdown

  # Specify version and summary explicitly
  ./scripts/generate-changelog.sh --from v2.6.0 --to v2.7.0 \
      --version 2.7.0 --summary "Changelog schema and sync automation"

OUTPUT:
  YAML format matches the HARNESS_CHANGELOG.yml schema (v1.0.0).
  Markdown format provides a human-readable summary grouped by category.

CATEGORY HEURISTIC:
  .claude/agents/*.md                        -> METHODOLOGY
  .claude/skills/*/SKILL.md                  -> METHODOLOGY
  .claude/commands/*.md (new)                -> NEW_FILE
  .claude/commands/*.md (modified)           -> UPDATED_FILE
  .claude/*.json (team-config, hooks-config) -> CONFIG
  .claude/*.md (README, SETUP, etc.)         -> UPDATED_FILE
  .claude/hooks/*                            -> CONFIG
  Renames / deletions                        -> BREAKING (override)
USAGE
}

die() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" >&2
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

# Validate that a git ref exists
validate_ref() {
    local ref="$1"
    local label="$2"
    if ! git -C "$PROJECT_ROOT" rev-parse --verify "$ref" >/dev/null 2>&1; then
        die "$label ref '$ref' is not a valid git reference."
    fi
}

# Classify a .claude/ file path into a category.
# Arguments: $1 = path, $2 = git status code (A, M, D, R)
# Outputs: category string
classify_file() {
    local path="$1"
    local status="$2"

    # Override: renames and deletions are always BREAKING
    if [[ "$status" == R* ]] || [[ "$status" == "D" ]]; then
        echo "BREAKING"
        return
    fi

    # .claude/agents/*.md -> METHODOLOGY
    if [[ "$path" =~ ^\.claude/agents/.*\.md$ ]]; then
        echo "METHODOLOGY"
        return
    fi

    # .claude/skills/*/SKILL.md -> METHODOLOGY
    if [[ "$path" =~ ^\.claude/skills/.*/SKILL\.md$ ]]; then
        echo "METHODOLOGY"
        return
    fi

    # .claude/commands/*.md
    if [[ "$path" =~ ^\.claude/commands/.*\.md$ ]]; then
        if [[ "$status" == "A" ]]; then
            echo "NEW_FILE"
        else
            echo "UPDATED_FILE"
        fi
        return
    fi

    # .claude/*.json (top-level JSON config files)
    if [[ "$path" =~ ^\.claude/[^/]*\.json$ ]]; then
        echo "CONFIG"
        return
    fi

    # .claude/hooks/* -> CONFIG
    if [[ "$path" =~ ^\.claude/hooks/ ]]; then
        echo "CONFIG"
        return
    fi

    # .claude/*.md (top-level markdown: README, SETUP, TROUBLESHOOTING, etc.)
    if [[ "$path" =~ ^\.claude/[^/]*\.md$ ]]; then
        echo "UPDATED_FILE"
        return
    fi

    # New files that don't match a more specific pattern
    if [[ "$status" == "A" ]]; then
        echo "NEW_FILE"
        return
    fi

    # Default: UPDATED_FILE
    echo "UPDATED_FILE"
}

# Map git status code to change_type string
status_to_change_type() {
    local status="$1"
    case "$status" in
        A)  echo "added" ;;
        M)  echo "modified" ;;
        D)  echo "deleted" ;;
        R*) echo "renamed" ;;
        *)  echo "modified" ;;
    esac
}

# Determine if a change is breaking
is_breaking() {
    local status="$1"
    if [[ "$status" == "D" ]] || [[ "$status" == R* ]]; then
        echo "true"
    else
        echo "false"
    fi
}

# Generate a description for a file change
generate_description() {
    local path="$1"
    local status="$2"
    local renamed_from="${3:-}"

    local basename
    basename="$(basename "$path")"

    case "$status" in
        A)  echo "Added $basename." ;;
        M)  echo "Modified $basename." ;;
        D)  echo "Deleted $basename." ;;
        R*) echo "Renamed from $renamed_from to $path." ;;
        *)  echo "Changed $basename." ;;
    esac
}

# Escape a string for safe YAML output (always double-quoted)
yaml_quote() {
    local value="$1"
    # Escape internal backslashes and double quotes, then wrap
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    echo "\"$value\""
}

# -----------------------------------------------------------------------------
# Parse arguments
# -----------------------------------------------------------------------------
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --from)
                [[ $# -lt 2 ]] && die "--from requires a value"
                FROM_REF="$2"
                shift 2
                ;;
            --to)
                [[ $# -lt 2 ]] && die "--to requires a value"
                TO_REF="$2"
                shift 2
                ;;
            --format)
                [[ $# -lt 2 ]] && die "--format requires a value"
                OUTPUT_FORMAT="$2"
                if [[ "$OUTPUT_FORMAT" != "yaml" ]] && [[ "$OUTPUT_FORMAT" != "markdown" ]]; then
                    die "--format must be 'yaml' or 'markdown'"
                fi
                shift 2
                ;;
            --version)
                [[ $# -lt 2 ]] && die "--version requires a value"
                RELEASE_VERSION="$2"
                shift 2
                ;;
            --summary)
                [[ $# -lt 2 ]] && die "--summary requires a value"
                RELEASE_SUMMARY="$2"
                shift 2
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            *)
                die "Unknown argument: $1. Use --help for usage."
                ;;
        esac
    done

    # Validate required args
    [[ -z "$FROM_REF" ]] && die "--from is required. Use --help for usage."
    [[ -z "$TO_REF" ]]   && die "--to is required. Use --help for usage."

    # Validate refs
    validate_ref "$FROM_REF" "--from"
    validate_ref "$TO_REF" "--to"

    # Derive version from --to ref if not provided
    if [[ -z "$RELEASE_VERSION" ]]; then
        RELEASE_VERSION="${TO_REF#v}"
    fi

    # Auto-generate summary if not provided
    if [[ -z "$RELEASE_SUMMARY" ]]; then
        local change_count
        change_count="$(git -C "$PROJECT_ROOT" diff --name-only "$FROM_REF" "$TO_REF" -- .claude/ | wc -l | tr -d ' ')"
        RELEASE_SUMMARY="$change_count file(s) changed in .claude/ between $FROM_REF and $TO_REF"
    fi
}

# -----------------------------------------------------------------------------
# Collect changes
# -----------------------------------------------------------------------------

# Globals populated by collect_changes
declare -a CHANGE_STATUSES=()
declare -a CHANGE_PATHS=()
declare -a CHANGE_RENAMED_FROM=()

collect_changes() {
    local status path renamed_from

    while IFS=$'\t' read -r status path renamed_from_field; do
        # git diff --name-status -M outputs:
        #   A\tpath          (added)
        #   M\tpath          (modified)
        #   D\tpath          (deleted)
        #   Rnnn\told\tnew   (renamed, nnn = similarity %)
        # For renames, the first field after status is old path, second is new path.
        if [[ "$status" == R* ]]; then
            # Rename: status=Rnnn, path=old_path, renamed_from_field=new_path
            renamed_from="$path"
            path="$renamed_from_field"
        else
            renamed_from=""
        fi

        CHANGE_STATUSES+=("$status")
        CHANGE_PATHS+=("$path")
        CHANGE_RENAMED_FROM+=("$renamed_from")
    done < <(git -C "$PROJECT_ROOT" diff --name-status -M "$FROM_REF" "$TO_REF" -- .claude/)
}

# -----------------------------------------------------------------------------
# YAML output
# -----------------------------------------------------------------------------
emit_yaml() {
    local generated_at
    generated_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    local release_date
    release_date="$(date -u +"%Y-%m-%d")"

    local total="${#CHANGE_PATHS[@]}"
    if [[ "$total" -eq 0 ]]; then
        warn "No .claude/ changes detected between $FROM_REF and $TO_REF."
        cat <<EOF
# HARNESS_CHANGELOG.yml -- Auto-generated (no changes detected)
schema_version: "$SCHEMA_VERSION"
generated_at: "$generated_at"
releases: []
EOF
        return
    fi

    # Categorize all changes
    local -a categories=()
    local -a change_types=()
    local -a breakings=()
    local -a descriptions=()
    local i

    for (( i=0; i<total; i++ )); do
        local status="${CHANGE_STATUSES[$i]}"
        local path="${CHANGE_PATHS[$i]}"
        local renamed_from="${CHANGE_RENAMED_FROM[$i]}"

        categories+=("$(classify_file "$path" "$status")")
        change_types+=("$(status_to_change_type "$status")")
        breakings+=("$(is_breaking "$status")")
        descriptions+=("$(generate_description "$path" "$status" "$renamed_from")")
    done

    # Determine which categories have entries (for ordered output)
    local -A has_category
    for cat in "${categories[@]}"; do
        has_category["$cat"]=1
    done

    # Collect migration notes for breaking changes
    local -a migration_notes=()
    for (( i=0; i<total; i++ )); do
        if [[ "${breakings[$i]}" == "true" ]]; then
            local status="${CHANGE_STATUSES[$i]}"
            local path="${CHANGE_PATHS[$i]}"
            local renamed_from="${CHANGE_RENAMED_FROM[$i]}"
            if [[ "$status" == R* ]]; then
                migration_notes+=("Renamed: $renamed_from -> $path. Update any local references.")
            elif [[ "$status" == "D" ]]; then
                migration_notes+=("Deleted: $path. Remove from your fork if present.")
            fi
        fi
    done

    # Emit YAML
    cat <<EOF
# =============================================================================
# HARNESS_CHANGELOG.yml -- Auto-generated by generate-changelog.sh
# =============================================================================
# Schema version: $SCHEMA_VERSION
# Generated from: $FROM_REF..$TO_REF

schema_version: "$SCHEMA_VERSION"

generated_at: "$generated_at"

releases:
  - version: $(yaml_quote "$RELEASE_VERSION")
    date: "$release_date"
    summary: $(yaml_quote "$RELEASE_SUMMARY")
    changes:
EOF

    # Emit changes grouped by category (in canonical order)
    local category_order="NEW_FILE METHODOLOGY UPDATED_FILE CONFIG BREAKING"
    for cat in $category_order; do
        [[ -z "${has_category[$cat]:-}" ]] && continue

        echo ""
        echo "      # --- $cat ---"

        for (( i=0; i<total; i++ )); do
            [[ "${categories[$i]}" != "$cat" ]] && continue

            local path="${CHANGE_PATHS[$i]}"
            local change_type="${change_types[$i]}"
            local breaking="${breakings[$i]}"
            local description="${descriptions[$i]}"
            local renamed_from="${CHANGE_RENAMED_FROM[$i]}"
            local status="${CHANGE_STATUSES[$i]}"

            cat <<EOF
      - path: $(yaml_quote "$path")
        category: $cat
        change_type: $change_type
        description: $(yaml_quote "$description")
        breaking: $breaking
EOF

            # Conditional fields
            if [[ "$change_type" == "renamed" ]] && [[ -n "$renamed_from" ]]; then
                echo "        renamed_from: $(yaml_quote "$renamed_from")"
                echo "        migration_action: \"Rename $renamed_from to $path in your fork. Update any references.\""
            fi

            if [[ "$change_type" == "deleted" ]]; then
                echo "        migration_action: \"Remove $path from your fork if present.\""
            fi

        done
    done

    # Emit migration_notes if any breaking changes
    if [[ "${#migration_notes[@]}" -gt 0 ]]; then
        echo ""
        echo "    migration_notes:"
        for note in "${migration_notes[@]}"; do
            echo "      - $(yaml_quote "$note")"
        done
    fi
}

# -----------------------------------------------------------------------------
# Markdown output
# -----------------------------------------------------------------------------
emit_markdown() {
    local release_date
    release_date="$(date -u +"%Y-%m-%d")"

    local total="${#CHANGE_PATHS[@]}"
    if [[ "$total" -eq 0 ]]; then
        warn "No .claude/ changes detected between $FROM_REF and $TO_REF."
        echo "# Changelog: $RELEASE_VERSION"
        echo ""
        echo "No changes to \`.claude/\` directory between \`$FROM_REF\` and \`$TO_REF\`."
        return
    fi

    # Categorize all changes
    local -a categories=()
    local -a change_types=()
    local -a breakings=()
    local -a descriptions=()
    local i

    for (( i=0; i<total; i++ )); do
        local status="${CHANGE_STATUSES[$i]}"
        local path="${CHANGE_PATHS[$i]}"
        local renamed_from="${CHANGE_RENAMED_FROM[$i]}"

        categories+=("$(classify_file "$path" "$status")")
        change_types+=("$(status_to_change_type "$status")")
        breakings+=("$(is_breaking "$status")")
        descriptions+=("$(generate_description "$path" "$status" "$renamed_from")")
    done

    # Determine which categories are present
    local -A has_category
    for cat in "${categories[@]}"; do
        has_category["$cat"]=1
    done

    # Category display names
    declare -A cat_labels=(
        ["NEW_FILE"]="New Files"
        ["METHODOLOGY"]="Methodology Changes"
        ["UPDATED_FILE"]="Updated Files"
        ["CONFIG"]="Configuration Changes"
        ["BREAKING"]="Breaking Changes"
    )

    # Header
    echo "# Changelog: $RELEASE_VERSION"
    echo ""
    echo "**Date**: $release_date"
    echo "**Refs**: \`$FROM_REF\`..\`$TO_REF\`"
    echo "**Summary**: $RELEASE_SUMMARY"
    echo ""

    # Stats
    local -A cat_counts
    for cat in "${categories[@]}"; do
        cat_counts["$cat"]=$(( ${cat_counts[$cat]:-0} + 1 ))
    done

    echo "## Overview"
    echo ""
    echo "| Category | Count |"
    echo "| --- | --- |"
    local category_order="NEW_FILE METHODOLOGY UPDATED_FILE CONFIG BREAKING"
    for cat in $category_order; do
        [[ -z "${has_category[$cat]:-}" ]] && continue
        echo "| ${cat_labels[$cat]} | ${cat_counts[$cat]} |"
    done
    echo ""

    # Emit sections by category
    for cat in $category_order; do
        [[ -z "${has_category[$cat]:-}" ]] && continue

        echo "## ${cat_labels[$cat]}"
        echo ""

        for (( i=0; i<total; i++ )); do
            [[ "${categories[$i]}" != "$cat" ]] && continue

            local path="${CHANGE_PATHS[$i]}"
            local change_type="${change_types[$i]}"
            local description="${descriptions[$i]}"
            local renamed_from="${CHANGE_RENAMED_FROM[$i]}"

            echo "- **\`$path\`** ($change_type): $description"

            if [[ "$change_type" == "renamed" ]] && [[ -n "$renamed_from" ]]; then
                echo "  - Renamed from: \`$renamed_from\`"
                echo "  - **Migration**: Rename \`$renamed_from\` to \`$path\` in your fork."
            fi

            if [[ "$change_type" == "deleted" ]]; then
                echo "  - **Migration**: Remove \`$path\` from your fork if present."
            fi
        done
        echo ""
    done

    # Breaking changes summary
    if [[ -n "${has_category[BREAKING]:-}" ]]; then
        echo "---"
        echo ""
        echo "## Migration Notes"
        echo ""
        for (( i=0; i<total; i++ )); do
            [[ "${breakings[$i]}" != "true" ]] && continue
            local path="${CHANGE_PATHS[$i]}"
            local renamed_from="${CHANGE_RENAMED_FROM[$i]}"
            local status="${CHANGE_STATUSES[$i]}"

            if [[ "$status" == R* ]]; then
                echo "- Renamed: \`$renamed_from\` -> \`$path\`. Update any local references."
            elif [[ "$status" == "D" ]]; then
                echo "- Deleted: \`$path\`. Remove from your fork if present."
            fi
        done
        echo ""
    fi

    echo "---"
    echo "*Generated by \`generate-changelog.sh\` on $release_date*"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    parse_args "$@"

    info "Generating changelog: $FROM_REF..$TO_REF (format: $OUTPUT_FORMAT)"

    collect_changes

    local total="${#CHANGE_PATHS[@]}"
    info "Found $total .claude/ file change(s)."

    case "$OUTPUT_FORMAT" in
        yaml)     emit_yaml ;;
        markdown) emit_markdown ;;
    esac
}

main "$@"
