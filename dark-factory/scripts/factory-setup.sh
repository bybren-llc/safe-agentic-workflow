#!/usr/bin/env bash
set -euo pipefail

# factory-setup.sh - One-time Dark Factory environment setup
# Usage: ./factory-setup.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FACTORY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_DIR="$HOME/.dark-factory"

die() { echo "ERROR: $*" >&2; exit 1; }
warn() { echo "WARNING: $*" >&2; }
info() { echo "INFO: $*"; }

# Source existing env config if available (for FACTORY_MAIN_BRANCH)
if [[ -f "$CONFIG_DIR/env" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_DIR/env"
fi

# Resolve main branch: env config > placeholder fallback
# Note: cannot use ${:-} syntax because {{MAIN_BRANCH}} contains } characters
if [[ -n "${FACTORY_MAIN_BRANCH:-}" ]]; then
    MAIN_BRANCH="$FACTORY_MAIN_BRANCH"
else
    MAIN_BRANCH="{{MAIN_BRANCH}}"
fi

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

# Check for merge queue requirement via rulesets API (preferred) or branch protection
merge_queue_required=false

# Method 1: Check rulesets for merge_queue rule type
rulesets="$(gh api "repos/${owner}/${repo}/rulesets" 2>/dev/null || echo "[]")"
if echo "$rulesets" | python3 -c "
import sys, json
rulesets = json.load(sys.stdin)
for rs in rulesets:
    detail = json.loads(sys.stdin.read()) if False else None
" 2>/dev/null; then true; fi

# Query each ruleset for merge_queue rule targeting our branch
ruleset_ids="$(echo "$rulesets" | python3 -c "
import sys, json
for rs in json.load(sys.stdin):
    print(rs.get('id', ''))
" 2>/dev/null || true)"

for rs_id in $ruleset_ids; do
    [[ -z "$rs_id" ]] && continue
    rs_detail="$(gh api "repos/${owner}/${repo}/rulesets/${rs_id}" 2>/dev/null || echo "{}")"
    has_mq="$(echo "$rs_detail" | python3 -c "
import sys, json
d = json.load(sys.stdin)
rules = d.get('rules', [])
conditions = d.get('conditions', {})
ref_name = conditions.get('ref_name', {})
includes = ref_name.get('include', [])
branch_match = any('${MAIN_BRANCH}' in inc or inc == '~DEFAULT_BRANCH' for inc in includes)
has_merge_queue = any(r.get('type') == 'merge_queue' for r in rules)
print('yes' if (has_merge_queue and branch_match) else 'no')
" 2>/dev/null || echo "no")"
    if [[ "$has_mq" == "yes" ]]; then
        merge_queue_required=true
        info "Merge queue ruleset found targeting '${MAIN_BRANCH}'."
        break
    fi
done

# Method 2: Fallback — check branch protection for merge queue setting
if [[ "$merge_queue_required" != true ]]; then
    protection="$(gh api "repos/${owner}/${repo}/branches/${MAIN_BRANCH}/protection" 2>/dev/null || echo "{}")"
    has_mq_protection="$(echo "$protection" | python3 -c "
import sys, json
d = json.load(sys.stdin)
# required_pull_request_reviews alone is not enough — we need merge queue
mq = d.get('required_merge_queue', None)
print('yes' if mq is not None else 'no')
" 2>/dev/null || echo "no")"
    if [[ "$has_mq_protection" == "yes" ]]; then
        merge_queue_required=true
        info "Merge queue detected in branch protection on '${MAIN_BRANCH}'."
    fi
fi

if [[ "$merge_queue_required" != true ]]; then
    warn "No merge queue requirement found on '${MAIN_BRANCH}'."
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

if [[ "$merge_queue_required" != true ]] || [[ "$merge_queue_workflow" != true ]]; then
    echo ""
    echo "READINESS GATE FAILED"
    echo "The Dark Factory requires merge queue enforcement for safe parallel merges."
    echo ""
    [[ "$merge_queue_required" != true ]] && echo "  - Enable merge queue on '${MAIN_BRANCH}' via rulesets or branch protection"
    [[ "$merge_queue_workflow" != true ]] && echo "  - Add 'merge_group' trigger to at least one workflow in .github/workflows/"
    echo ""
    echo "See: dark-factory/docs/MERGE-QUEUE-POLICY.md for setup instructions."
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
