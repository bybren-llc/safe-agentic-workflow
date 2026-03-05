#!/usr/bin/env bash
# Epic Team Layout: TDM + BSA + ARCH + Security + BE + FE + Data + QAS + RTE
# Usage: sourced by factory-start.sh (SESSION_NAME must be set)
set -euo pipefail

# Layout:
# ┌──────────────────────────────┐
# │         TDM (lead)           │
# ├────────┬────────┬────────────┤
# │  BSA   │  ARCH  │  Security  │
# ├────────┼────────┼────────────┤
# │   BE   │   FE   │   Data     │
# ├────────┴────────┼────────────┤
# │      QAS        │    RTE     │
# └─────────────────┴────────────┘

# Pane 1 is already created (TDM -- team lead)
tmux select-pane -t "${SESSION_NAME}:1.1" -T "TDM (lead)"

# --- Row 2: BSA | ARCH | Security ---
tmux split-window -t "${SESSION_NAME}:1" -v
tmux select-pane -t "${SESSION_NAME}:1.2" -T "BSA"

tmux split-window -t "${SESSION_NAME}:1.2" -h
tmux select-pane -t "${SESSION_NAME}:1.3" -T "ARCH"

tmux split-window -t "${SESSION_NAME}:1.3" -h
tmux select-pane -t "${SESSION_NAME}:1.4" -T "Security"

# --- Row 3: BE | FE | Data ---
tmux split-window -t "${SESSION_NAME}:1.2" -v
tmux select-pane -t "${SESSION_NAME}:1.3" -T "BE Developer"

tmux split-window -t "${SESSION_NAME}:1.4" -v
tmux select-pane -t "${SESSION_NAME}:1.5" -T "FE Developer"

tmux split-window -t "${SESSION_NAME}:1.6" -v
tmux select-pane -t "${SESSION_NAME}:1.7" -T "Data Engineer"

# --- Row 4: QAS | RTE ---
tmux split-window -t "${SESSION_NAME}:1.3" -v
tmux select-pane -t "${SESSION_NAME}:1.4" -T "QAS"

tmux split-window -t "${SESSION_NAME}:1.4" -h
tmux select-pane -t "${SESSION_NAME}:1.5" -T "RTE"

# Re-title all panes (indices shift during complex splits)
# Use list-panes to be safe; these are best-effort labels
tmux select-pane -t "${SESSION_NAME}:1.1" -T "TDM (lead)"
tmux select-pane -t "${SESSION_NAME}:1.2" -T "BSA"
tmux select-pane -t "${SESSION_NAME}:1.3" -T "BE Developer"
tmux select-pane -t "${SESSION_NAME}:1.4" -T "QAS"
tmux select-pane -t "${SESSION_NAME}:1.5" -T "RTE"
tmux select-pane -t "${SESSION_NAME}:1.6" -T "ARCH"
tmux select-pane -t "${SESSION_NAME}:1.7" -T "FE Developer"
tmux select-pane -t "${SESSION_NAME}:1.8" -T "Security"
tmux select-pane -t "${SESSION_NAME}:1.9" -T "Data Engineer"

# Start agents in each pane
CLAUDE_FLAGS=""
if [[ "${FACTORY_AUTO_PERMISSIONS:-false}" == "true" ]]; then
  CLAUDE_FLAGS="--dangerously-skip-permissions"
fi

# TDM (team lead) -- starts first, will orchestrate
tmux send-keys -t "${SESSION_NAME}:1.1" \
  "cd ${FACTORY_PROJECT_DIR} && claude ${CLAUDE_FLAGS} -p 'You are the TDM (Technical Delivery Manager) for this session. Act as team lead for an epic-level effort. Use the SAFe workflow from CLAUDE.md. Create PRs with gh pr create, then enqueue with gh pr merge --auto --squash. Never merge directly.'" Enter

# BSA
tmux send-keys -t "${SESSION_NAME}:1.2" \
  "cd ${FACTORY_PROJECT_DIR} && claude ${CLAUDE_FLAGS}" Enter

# BE Developer
tmux send-keys -t "${SESSION_NAME}:1.3" \
  "cd ${FACTORY_PROJECT_DIR} && claude ${CLAUDE_FLAGS}" Enter

# QAS
tmux send-keys -t "${SESSION_NAME}:1.4" \
  "cd ${FACTORY_PROJECT_DIR} && claude ${CLAUDE_FLAGS}" Enter

# RTE
tmux send-keys -t "${SESSION_NAME}:1.5" \
  "cd ${FACTORY_PROJECT_DIR} && claude ${CLAUDE_FLAGS}" Enter

# ARCH
tmux send-keys -t "${SESSION_NAME}:1.6" \
  "cd ${FACTORY_PROJECT_DIR} && claude ${CLAUDE_FLAGS}" Enter

# FE Developer
tmux send-keys -t "${SESSION_NAME}:1.7" \
  "cd ${FACTORY_PROJECT_DIR} && claude ${CLAUDE_FLAGS}" Enter

# Security
tmux send-keys -t "${SESSION_NAME}:1.8" \
  "cd ${FACTORY_PROJECT_DIR} && claude ${CLAUDE_FLAGS}" Enter

# Data Engineer
tmux send-keys -t "${SESSION_NAME}:1.9" \
  "cd ${FACTORY_PROJECT_DIR} && claude ${CLAUDE_FLAGS}" Enter

# Select TDM pane as active
tmux select-pane -t "${SESSION_NAME}:1.1"
