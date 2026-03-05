#!/usr/bin/env bash
set -euo pipefail

# factory-setup.sh - One-time Dark Factory environment setup
# Usage: ./factory-setup.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FACTORY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_DIR="$HOME/.dark-factory"
MAIN_BRANCH="{{MAIN_BRANCH}}"

die() { echo "ERROR: $*" >&2; exit 1; }
warn() { echo "WARNING: $*" >&2; }
info() { echo "INFO: $*"; }

# ── Step 1: Check prerequisites ──────────────────────────────────────────────
info "Checking prerequisites..."

missing=()
for cmd in tmux claude git gh; do
    if ! command -v "$cmd" &>/dev/null; then
        missing+=("$cmd")
    fi
done

if [[ ${#missing[@]} -gt 0 ]]; then
    die "Missing required tools: ${missing[*]}. Install them before running setup."
fi

info "All prerequisites found."

# ── Step 2: Create config directory structure ─────────────────────────────────
info "Creating config directory at $CONFIG_DIR..."

mkdir -p "$CONFIG_DIR/logs"
mkdir -p "$CONFIG_DIR/worktrees"

info "Config directories created."

# ── Step 3: Copy env.template if env doesn't exist ────────────────────────────
if [[ ! -f "$CONFIG_DIR/env" ]]; then
    if [[ -f "$FACTORY_DIR/templates/env.template" ]]; then
        cp "$FACTORY_DIR/templates/env.template" "$CONFIG_DIR/env"
        info "Copied env.template to $CONFIG_DIR/env -- edit it with your settings."
    else
        warn "No env.template found at $FACTORY_DIR/templates/env.template."
        warn "Create $CONFIG_DIR/env manually before running factory-start.sh."
    fi
else
    info "Config file $CONFIG_DIR/env already exists, skipping."
fi

# ── Step 4: Readiness gate — verify merge queue enforcement ───────────────────
info "Verifying merge queue readiness gate..."

repo_slug="$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null)" \
    || die "Could not determine repo. Ensure you are in a git repo with a GitHub remote."

owner="${repo_slug%%/*}"
repo="${repo_slug##*/}"

# Check branch protection rules via GitHub API
protection_ok=false
if gh api "repos/${owner}/${repo}/branches/${MAIN_BRANCH}/protection" &>/dev/null; then
    info "Branch protection detected on '${MAIN_BRANCH}'."
    protection_ok=true
else
    warn "No branch protection found on '${MAIN_BRANCH}'."
fi

# Check for merge_group trigger in workflow files
merge_queue_workflow=false
workflow_dir="$(git rev-parse --show-toplevel 2>/dev/null)/.github/workflows"
if [[ -d "$workflow_dir" ]]; then
    if grep -rl 'merge_group' "$workflow_dir"/*.yml 2>/dev/null | head -1 >/dev/null 2>&1; then
        merge_queue_workflow=true
        info "Found merge_group trigger in workflow files."
    fi
fi

if [[ "$protection_ok" != true ]] || [[ "$merge_queue_workflow" != true ]]; then
    echo ""
    echo "READINESS GATE FAILED"
    echo "The Dark Factory requires merge queue enforcement for safe parallel merges."
    echo ""
    [[ "$protection_ok" != true ]] && echo "  - Enable branch protection on '${MAIN_BRANCH}'"
    [[ "$merge_queue_workflow" != true ]] && echo "  - Add 'merge_group' trigger to at least one workflow in .github/workflows/"
    echo ""
    echo "See: dark-factory/docs/ for setup instructions."
    exit 1
fi

# ── Step 5: Check agent teams env var ─────────────────────────────────────────
if [[ -z "${CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS:-}" ]]; then
    warn "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS is not set."
    warn "Set it to '1' to enable agent teams: export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1"
fi

# ── Step 6: Print success summary ─────────────────────────────────────────────
echo ""
echo "========================================"
echo "  Dark Factory Setup Complete"
echo "========================================"
echo "  Config dir:  $CONFIG_DIR"
echo "  Logs dir:    $CONFIG_DIR/logs"
echo "  Worktrees:   $CONFIG_DIR/worktrees"
echo "  Repo:        $repo_slug"
echo "  Branch:      $MAIN_BRANCH"
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. Edit $CONFIG_DIR/env with your project settings"
echo "  2. Run: ./factory-start.sh <story|feature|epic> [ticket-id]"
