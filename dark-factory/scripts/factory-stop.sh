#!/usr/bin/env bash
set -euo pipefail

# factory-stop.sh - Gracefully stop a Dark Factory tmux session
# Usage: ./factory-stop.sh [session-name]

CONFIG_DIR="$HOME/.dark-factory"

die() { echo "ERROR: $*" >&2; exit 1; }
info() { echo "INFO: $*"; }

# Source config for log/worktree paths
if [[ -f "$CONFIG_DIR/env" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_DIR/env"
fi

FACTORY_LOG_DIR="${FACTORY_LOG_DIR:-$CONFIG_DIR/logs}"
FACTORY_USE_WORKTREES="${FACTORY_USE_WORKTREES:-false}"
FACTORY_WORKTREE_DIR="${FACTORY_WORKTREE_DIR:-$CONFIG_DIR/worktrees}"

# ── Step 1: Determine session name ────────────────────────────────────────────
SESSION_NAME="${1:-}"

if [[ -z "$SESSION_NAME" ]]; then
    sessions="$(tmux list-sessions -F '#{session_name}' 2>/dev/null | grep '^factory-' || true)"

    if [[ -z "$sessions" ]]; then
        die "No dark factory sessions found."
    fi

    if [[ -t 0 ]]; then
        echo "Running factory sessions:"
        echo "$sessions" | nl -ba
        echo ""
        read -rp "Enter session name to stop: " SESSION_NAME
    else
        die "No session name provided and stdin is not a terminal. Pass session name as argument."
    fi
fi

if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    die "Session '$SESSION_NAME' does not exist."
fi

info "Stopping session: $SESSION_NAME"

# ── Step 2: Send Ctrl-C to all panes ─────────────────────────────────────────
pane_ids="$(tmux list-panes -t "$SESSION_NAME" -F '#{pane_id}')"

for pane_id in $pane_ids; do
    tmux send-keys -t "$pane_id" C-c 2>/dev/null || true
done

info "Sent interrupt to all panes. Waiting for graceful shutdown..."

# ── Step 3: Wait up to 30 seconds for graceful exit ──────────────────────────
timeout=30
elapsed=0
while [[ $elapsed -lt $timeout ]]; do
    still_running=false
    for pane_id in $pane_ids; do
        pane_pid="$(tmux display-message -t "$pane_id" -p '#{pane_pid}' 2>/dev/null || true)"
        if [[ -n "$pane_pid" ]] && pgrep -P "$pane_pid" -f "claude" &>/dev/null; then
            still_running=true
            break
        fi
    done

    if [[ "$still_running" != true ]]; then
        info "All agents stopped gracefully."
        break
    fi

    sleep 1
    elapsed=$((elapsed + 1))
done

if [[ $elapsed -ge $timeout ]]; then
    info "Timeout reached. Force-killing remaining panes."
fi

# ── Step 4: Kill remaining panes ──────────────────────────────────────────────
for pane_id in $pane_ids; do
    tmux send-keys -t "$pane_id" C-c 2>/dev/null || true
done
sleep 1

# ── Step 5: Kill tmux session ────────────────────────────────────────────────
tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true
info "Session '$SESSION_NAME' terminated."

# ── Step 6: Clean up worktrees if enabled ─────────────────────────────────────
if [[ "$FACTORY_USE_WORKTREES" == "true" ]]; then
    worktree_session_dir="$FACTORY_WORKTREE_DIR/$SESSION_NAME"
    if [[ -d "$worktree_session_dir" ]]; then
        info "Cleaning up worktrees..."
        repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"

        if [[ -n "$repo_root" ]]; then
            for wt_dir in "$worktree_session_dir"/agent-*; do
                if [[ -d "$wt_dir" ]]; then
                    git -C "$repo_root" worktree remove "$wt_dir" --force 2>/dev/null || true
                fi
            done
        fi

        rmdir "$worktree_session_dir" 2>/dev/null || true
        info "Worktrees cleaned up."
    fi
fi

# ── Step 7: Archive logs ──────────────────────────────────────────────────────
session_log_dir="$FACTORY_LOG_DIR/$SESSION_NAME"
archive_dir="$FACTORY_LOG_DIR/archive"

if [[ -d "$session_log_dir" ]]; then
    mkdir -p "$archive_dir"
    mv "$session_log_dir" "$archive_dir/"
    info "Logs archived to $archive_dir/$SESSION_NAME/"
fi

# ── Step 8: Print cleanup summary ─────────────────────────────────────────────
echo ""
echo "========================================"
echo "  Dark Factory Session Stopped"
echo "========================================"
echo "  Session:   $SESSION_NAME"
echo "  Logs:      $archive_dir/$SESSION_NAME/"
echo "========================================"
