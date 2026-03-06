#!/usr/bin/env bash
set -euo pipefail

# factory-attach.sh - Quick attach to a Dark Factory tmux session
# Usage: ./factory-attach.sh [session-name] [pane-index]

die() { echo "ERROR: $*" >&2; exit 1; }

# ── Step 1: No args — list sessions and exit ──────────────────────────────────
if [[ $# -eq 0 ]]; then
    sessions="$(tmux list-sessions -F '#{session_name}' 2>/dev/null | grep '^factory-' || true)"

    if [[ -z "$sessions" ]]; then
        echo "No dark factory sessions running."
        exit 0
    fi

    echo "Factory sessions:"
    echo ""

    for session in $sessions; do
        echo "  $session"
        tmux list-panes -t "$session" -F '    [#{pane_index}] #{pane_title} (#{pane_current_command})' 2>/dev/null || true
        echo ""
    done

    echo "Usage: $0 <session-name> [pane-index]"
    exit 0
fi

# ── Step 2: Session only — attach to session ──────────────────────────────────
session="$1"

if ! tmux has-session -t "$session" 2>/dev/null; then
    die "Session '$session' does not exist."
fi

if [[ $# -eq 1 ]]; then
    exec tmux attach -t "$session"
fi

# ── Step 3: Session + pane — select pane then attach ──────────────────────────
pane_index="$2"
tmux select-pane -t "${session}:1.${pane_index}" 2>/dev/null \
    || die "Pane index '$pane_index' not found in session '$session'."
exec tmux attach -t "$session"
