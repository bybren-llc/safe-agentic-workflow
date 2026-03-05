#!/usr/bin/env bash
# Feature Team Layout: TDM (lead) + BE Developer + FE Developer + QAS + RTE
# Usage: sourced by factory-start.sh (SESSION_NAME must be set)
set -euo pipefail

# Layout:
# ┌──────────────────────────────┐
# │         TDM (lead)           │
# ├──────────────┬───────────────┤
# │  BE Developer│  FE Developer │
# ├──────────────┼───────────────┤
# │     QAS      │     RTE       │
# └──────────────┴───────────────┘

# Pane 1 is already created (TDM -- team lead)
tmux select-pane -t "${SESSION_NAME}:1.1" -T "TDM (lead)"

# Split for bottom two-thirds
tmux split-window -t "${SESSION_NAME}:1" -v
tmux select-pane -t "${SESSION_NAME}:1.2" -T "BE Developer"

# Split BE row horizontally for FE
tmux split-window -t "${SESSION_NAME}:1.2" -h
tmux select-pane -t "${SESSION_NAME}:1.3" -T "FE Developer"

# Split BE pane vertically for QAS row
tmux split-window -t "${SESSION_NAME}:1.2" -v
tmux select-pane -t "${SESSION_NAME}:1.3" -T "QAS"

# Split QAS horizontally for RTE
tmux split-window -t "${SESSION_NAME}:1.3" -h
tmux select-pane -t "${SESSION_NAME}:1.4" -T "RTE"

# Rename panes after all splits (indices shift during splits)
tmux select-pane -t "${SESSION_NAME}:1.1" -T "TDM (lead)"
tmux select-pane -t "${SESSION_NAME}:1.2" -T "BE Developer"
tmux select-pane -t "${SESSION_NAME}:1.3" -T "QAS"
tmux select-pane -t "${SESSION_NAME}:1.4" -T "FE Developer"
tmux select-pane -t "${SESSION_NAME}:1.5" -T "RTE"

# Start agents in each pane
CLAUDE_FLAGS=""
if [[ "${FACTORY_AUTO_PERMISSIONS:-false}" == "true" ]]; then
  CLAUDE_FLAGS="--dangerously-skip-permissions"
fi

# TDM (team lead) -- starts first, will orchestrate
tmux send-keys -t "${SESSION_NAME}:1.1" \
  "cd ${FACTORY_PROJECT_DIR} && claude ${CLAUDE_FLAGS} -p 'You are the TDM (Technical Delivery Manager) for this session. Act as team lead. Use the SAFe workflow from CLAUDE.md. Create PRs with gh pr create, then enqueue with gh pr merge --auto --squash. Never merge directly.'" Enter

# BE Developer
tmux send-keys -t "${SESSION_NAME}:1.2" \
  "cd ${FACTORY_PROJECT_DIR} && claude ${CLAUDE_FLAGS}" Enter

# QAS
tmux send-keys -t "${SESSION_NAME}:1.3" \
  "cd ${FACTORY_PROJECT_DIR} && claude ${CLAUDE_FLAGS}" Enter

# FE Developer
tmux send-keys -t "${SESSION_NAME}:1.4" \
  "cd ${FACTORY_PROJECT_DIR} && claude ${CLAUDE_FLAGS}" Enter

# RTE
tmux send-keys -t "${SESSION_NAME}:1.5" \
  "cd ${FACTORY_PROJECT_DIR} && claude ${CLAUDE_FLAGS}" Enter

# Select TDM pane as active
tmux select-pane -t "${SESSION_NAME}:1.1"
