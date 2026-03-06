#!/usr/bin/env bash
# Story Team Layout: TDM (lead) + BE Developer + QAS
# Usage: sourced by factory-start.sh (SESSION_NAME must be set)
set -euo pipefail

# Layout:
# ┌──────────────────────────────┐
# │         TDM (lead)           │
# ├──────────────┬───────────────┤
# │  BE Developer│     QAS       │
# └──────────────┴───────────────┘

# Pane 1 is already created (TDM -- team lead)
tmux select-pane -t "${SESSION_NAME}:1.1" -T "TDM (lead)"

# Split bottom half horizontally for BE and QAS
tmux split-window -t "${SESSION_NAME}:1" -v
tmux select-pane -t "${SESSION_NAME}:1.2" -T "BE Developer"

tmux split-window -t "${SESSION_NAME}:1.2" -h
tmux select-pane -t "${SESSION_NAME}:1.3" -T "QAS"

# Start agents in each pane
CLAUDE_FLAGS=""
if [[ "${FACTORY_AUTO_PERMISSIONS:-false}" == "true" ]]; then
  CLAUDE_FLAGS="--dangerously-skip-permissions"
fi

# Resolve per-pane work directories (worktree-aware)
DIR_1="$(agent_workdir 1)"
DIR_2="$(agent_workdir 2)"
DIR_3="$(agent_workdir 3)"

# TDM (team lead) -- starts first, will orchestrate
tmux send-keys -t "${SESSION_NAME}:1.1" \
  "cd ${DIR_1} && claude ${CLAUDE_FLAGS} -p 'You are the TDM (Technical Delivery Manager) for this session. Act as team lead. Use the SAFe workflow from CLAUDE.md. Create PRs with gh pr create, then enqueue with gh pr merge --auto --squash. Never merge directly.'" Enter

# BE Developer
tmux send-keys -t "${SESSION_NAME}:1.2" \
  "cd ${DIR_2} && claude ${CLAUDE_FLAGS}" Enter

# QAS
tmux send-keys -t "${SESSION_NAME}:1.3" \
  "cd ${DIR_3} && claude ${CLAUDE_FLAGS}" Enter

# Select TDM pane as active
tmux select-pane -t "${SESSION_NAME}:1.1"
