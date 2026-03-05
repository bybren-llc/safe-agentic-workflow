#!/usr/bin/env bash
set -euo pipefail

# factory-start.sh - Launch a Dark Factory tmux session with agent team
# Usage: ./factory-start.sh <story|feature|epic> [ticket-id]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FACTORY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_DIR="$HOME/.dark-factory"

die() { echo "ERROR: $*" >&2; exit 1; }
info() { echo "INFO: $*"; }

# ── Step 1: Parse arguments ──────────────────────────────────────────────────
usage() {
    echo "Usage: $0 <team-size> [ticket-id]"
    echo ""
    echo "  team-size   One of: story, feature, epic"
    echo "  ticket-id   Optional ticket identifier (e.g., {{TICKET_PREFIX}}-123)"
    echo ""
    echo "Examples:"
    echo "  $0 story {{TICKET_PREFIX}}-456"
    echo "  $0 feature"
    exit 1
}

if [[ $# -lt 1 ]]; then
    usage
fi

team_size="$1"
ticket_id="${2:-}"

case "$team_size" in
    story|feature|epic) ;;
    *) die "Invalid team-size '$team_size'. Must be one of: story, feature, epic" ;;
esac

# ── Step 2: Source config ─────────────────────────────────────────────────────
if [[ -f "$CONFIG_DIR/env" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_DIR/env"
else
    die "Config file not found at $CONFIG_DIR/env. Run factory-setup.sh first."
fi

FACTORY_LOG_DIR="${FACTORY_LOG_DIR:-$CONFIG_DIR/logs}"
FACTORY_USE_WORKTREES="${FACTORY_USE_WORKTREES:-false}"
FACTORY_WORKTREE_DIR="${FACTORY_WORKTREE_DIR:-$CONFIG_DIR/worktrees}"
FACTORY_AUTO_ATTACH="${FACTORY_AUTO_ATTACH:-true}"

# ── Step 3: Validate team layout file ─────────────────────────────────────────
layout_file="$FACTORY_DIR/templates/team-layouts/${team_size}-team.sh"
if [[ ! -f "$layout_file" ]]; then
    die "Team layout not found: $layout_file"
fi

# ── Step 4: Create session name ───────────────────────────────────────────────
if [[ -n "$ticket_id" ]]; then
    SESSION_NAME="factory-${ticket_id}"
else
    SESSION_NAME="factory-$(date +%Y%m%d-%H%M%S)"
fi

# Check for duplicate session
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    die "Session '$SESSION_NAME' already exists. Stop it first or use a different ticket-id."
fi

export SESSION_NAME
export FACTORY_DIR
export FACTORY_LOG_DIR
export FACTORY_USE_WORKTREES
export FACTORY_WORKTREE_DIR

info "Starting Dark Factory session: $SESSION_NAME"
info "Team size: $team_size"
info "Layout: $layout_file"

# ── Step 5: Create tmux session ───────────────────────────────────────────────
tmux_conf="$FACTORY_DIR/templates/tmux.conf"
if [[ -f "$tmux_conf" ]]; then
    tmux -f "$tmux_conf" new-session -d -s "$SESSION_NAME"
else
    info "No custom tmux.conf found, using defaults."
    tmux new-session -d -s "$SESSION_NAME"
fi

# ── Step 6: Source team layout (creates panes and starts agents) ──────────────
info "Applying team layout: ${team_size}-team..."
# shellcheck source=/dev/null
source "$layout_file"

# ── Step 7: Create worktrees if enabled ───────────────────────────────────────
if [[ "$FACTORY_USE_WORKTREES" == "true" ]]; then
    info "Creating git worktrees..."
    repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" \
        || die "Not in a git repository. Worktrees require a git repo."

    current_branch="$(git -C "$repo_root" rev-parse --abbrev-ref HEAD)"

    # Get pane count from the session
    pane_count="$(tmux list-panes -t "$SESSION_NAME" -F '#{pane_index}' | wc -l)"

    for i in $(seq 0 $((pane_count - 1))); do
        worktree_path="$FACTORY_WORKTREE_DIR/${SESSION_NAME}/agent-${i}"
        branch_name="${SESSION_NAME}-agent-${i}"

        if [[ ! -d "$worktree_path" ]]; then
            git -C "$repo_root" worktree add -b "$branch_name" "$worktree_path" "$current_branch" 2>/dev/null \
                || info "Worktree for agent-${i} may already exist, skipping."
        fi
    done

    info "Worktrees created at $FACTORY_WORKTREE_DIR/${SESSION_NAME}/"
fi

# ── Step 8: Set up logging ────────────────────────────────────────────────────
session_log_dir="$FACTORY_LOG_DIR/$SESSION_NAME"
mkdir -p "$session_log_dir"

pane_list="$(tmux list-panes -t "$SESSION_NAME" -F '#{pane_index}:#{pane_title}')"

while IFS=: read -r pane_index pane_title; do
    log_name="${pane_title:-pane-${pane_index}}"
    # Sanitize log name
    log_name="$(echo "$log_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9_-')"
    tmux pipe-pane -t "${SESSION_NAME}:1.${pane_index}" \
        "cat >> '${session_log_dir}/${log_name}.log'"
done <<< "$pane_list"

info "Logging to $session_log_dir/"

# ── Step 9: Print status summary ──────────────────────────────────────────────
echo ""
echo "========================================"
echo "  Dark Factory Session Started"
echo "========================================"
echo "  Session:    $SESSION_NAME"
echo "  Team size:  $team_size"
echo "  Panes:      $(tmux list-panes -t "$SESSION_NAME" | wc -l)"
echo "  Logs:       $session_log_dir/"
if [[ "$FACTORY_USE_WORKTREES" == "true" ]]; then
echo "  Worktrees:  $FACTORY_WORKTREE_DIR/${SESSION_NAME}/"
fi
echo "========================================"
echo ""
echo "Commands:"
echo "  Attach:     tmux attach -t $SESSION_NAME"
echo "  Status:     ./factory-status.sh"
echo "  Stop:       ./factory-stop.sh $SESSION_NAME"
echo ""

# ── Step 10: Optionally attach ────────────────────────────────────────────────
if [[ "$FACTORY_AUTO_ATTACH" == "true" ]]; then
    exec tmux attach -t "$SESSION_NAME"
fi
