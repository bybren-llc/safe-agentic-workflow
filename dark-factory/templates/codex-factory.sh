#!/usr/bin/env bash
set -euo pipefail

# codex-factory.sh - Launch a Codex CLI Dark Factory tmux session
#
# Creates a tmux session with one window per SAFe agent role, each running
# Codex CLI with codex-yolo for auto-approval. A control window tails the
# audit log for real-time visibility.
#
# Prerequisites:
#   - tmux 3.0+
#   - Codex CLI (npm install -g @openai/codex)
#   - codex-yolo (https://github.com/codex-yolo/codex-yolo)
#   - .codex/agents/*.toml configs (from SAW-27)
#   - OPENAI_API_KEY set in environment
#
# Usage:
#   1. Copy this file and replace all {{PLACEHOLDER}} tokens
#   2. Run: bash codex-factory.sh
#
# See: dark-factory/docs/CODEX-DARK-FACTORY-GUIDE.md
# =============================================================================

# ── Configuration (replace {{PLACEHOLDER}} tokens) ──────────────────────────

PROJECT_PATH="{{PROJECT_PATH}}"               # Absolute path to project root
TICKET_PREFIX="{{TICKET_PREFIX}}"             # e.g., REN, SAW
TICKET_ID="{{TICKET_ID}}"                    # e.g., 123
TEAM_SIZE="{{TEAM_SIZE}}"                    # story | feature | epic

# Optional overrides
CODEX_MODEL="${CODEX_MODEL:-}"               # Override model from TOML configs
FACTORY_USE_WORKTREES="${FACTORY_USE_WORKTREES:-false}"
FACTORY_WORKTREE_DIR="${FACTORY_WORKTREE_DIR:-$HOME/.dark-factory/worktrees}"

# ── Derived values ───────────────────────────────────────────────────────────

SESSION_NAME="codex-factory-${TICKET_PREFIX}-${TICKET_ID}"
AUDIT_LOG="${HOME}/.codex-yolo/audit.log"

# ── Validation ───────────────────────────────────────────────────────────────

die() { echo "ERROR: $*" >&2; exit 1; }
info() { echo "INFO: $*"; }

# Check required tools
for cmd in tmux codex codex-yolo git gh; do
    command -v "$cmd" &>/dev/null || die "Required tool not found: $cmd"
done

# Check environment
[[ -n "${OPENAI_API_KEY:-}" ]] || die "OPENAI_API_KEY is not set"
[[ -d "$PROJECT_PATH" ]] || die "PROJECT_PATH does not exist: $PROJECT_PATH"
[[ -d "$PROJECT_PATH/.codex/agents" ]] || die "No .codex/agents/ directory found in $PROJECT_PATH"

# Check for duplicate session
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    die "Session '$SESSION_NAME' already exists. Kill it first: tmux kill-session -t $SESSION_NAME"
fi

# Validate team size
case "$TEAM_SIZE" in
    story|feature|epic) ;;
    *) die "Invalid TEAM_SIZE '$TEAM_SIZE'. Must be one of: story, feature, epic" ;;
esac

# ── Agent role definitions by team size ──────────────────────────────────────
# Each entry: "window_name:agent_toml_name:initial_prompt_or_empty"

declare -a AGENTS

case "$TEAM_SIZE" in
    story)
        # Story team: TDM + BE Developer + QAS (3 agents)
        AGENTS=(
            "TDM:tdm:You are leading work on ${TICKET_PREFIX}-${TICKET_ID}. Read the spec at specs/${TICKET_PREFIX}-${TICKET_ID}-*-spec.md and coordinate the BE Developer and QAS agents."
            "BE-Dev:be-developer:"
            "QAS:qas:"
        )
        ;;
    feature)
        # Feature team: TDM + BE + FE + QAS + RTE (5 agents)
        AGENTS=(
            "TDM:tdm:You are leading work on ${TICKET_PREFIX}-${TICKET_ID}. Read the spec at specs/${TICKET_PREFIX}-${TICKET_ID}-*-spec.md and coordinate the full feature team."
            "BE-Dev:be-developer:"
            "FE-Dev:fe-developer:"
            "QAS:qas:"
            "RTE:rte:"
        )
        ;;
    epic)
        # Epic team: TDM + BSA + ARCH + Security + BE + FE + Data + QAS + RTE (9 agents)
        AGENTS=(
            "TDM:tdm:You are leading an epic-level effort on ${TICKET_PREFIX}-${TICKET_ID}. Read the spec and coordinate the full SAFe team."
            "BSA:bsa:"
            "ARCH:system-architect:"
            "Security:security-engineer:"
            "BE-Dev:be-developer:"
            "FE-Dev:fe-developer:"
            "Data-Eng:data-engineer:"
            "QAS:qas:"
            "RTE:rte:"
        )
        ;;
esac

# ── Worktree setup (optional) ───────────────────────────────────────────────

if [[ "$FACTORY_USE_WORKTREES" == "true" ]]; then
    info "Creating git worktrees..."
    repo_root="$(git -C "$PROJECT_PATH" rev-parse --show-toplevel 2>/dev/null)" \
        || die "Not in a git repository. Worktrees require a git repo."
    current_branch="$(git -C "$repo_root" rev-parse --abbrev-ref HEAD)"

    for i in "${!AGENTS[@]}"; do
        agent_idx=$((i + 1))
        worktree_path="$FACTORY_WORKTREE_DIR/${SESSION_NAME}/agent-${agent_idx}"
        branch_name="${SESSION_NAME}-agent-${agent_idx}"

        if [[ ! -d "$worktree_path" ]]; then
            git -C "$repo_root" worktree add -b "$branch_name" "$worktree_path" "$current_branch" 2>/dev/null \
                || info "Worktree for agent-${agent_idx} may already exist, skipping."
        fi
    done
    info "Worktrees created at $FACTORY_WORKTREE_DIR/${SESSION_NAME}/"
fi

# ── Helper: resolve work directory for an agent index ────────────────────────

agent_workdir() {
    local agent_idx="$1"
    if [[ "$FACTORY_USE_WORKTREES" == "true" ]]; then
        local wt_path="$FACTORY_WORKTREE_DIR/${SESSION_NAME}/agent-${agent_idx}"
        if [[ -d "$wt_path" ]]; then
            echo "$wt_path"
            return
        fi
    fi
    echo "$PROJECT_PATH"
}

# ── Create tmux session ─────────────────────────────────────────────────────

info "Creating tmux session: $SESSION_NAME"
info "Team size: $TEAM_SIZE (${#AGENTS[@]} agents)"

# Use the Dark Factory tmux config if available
TMUX_CONF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/tmux.conf"
if [[ -f "$TMUX_CONF" ]]; then
    tmux -f "$TMUX_CONF" new-session -d -s "$SESSION_NAME"
else
    tmux new-session -d -s "$SESSION_NAME"
fi

# Ensure audit log directory exists
mkdir -p "$(dirname "$AUDIT_LOG")"

# ── Build model flag if override is set ──────────────────────────────────────

MODEL_FLAG=""
if [[ -n "$CODEX_MODEL" ]]; then
    MODEL_FLAG="--model $CODEX_MODEL"
fi

# ── Create agent windows ────────────────────────────────────────────────────

for i in "${!AGENTS[@]}"; do
    IFS=':' read -r window_name agent_toml initial_prompt <<< "${AGENTS[$i]}"
    agent_idx=$((i + 1))
    workdir="$(agent_workdir "$agent_idx")"

    if [[ $i -eq 0 ]]; then
        # First window already exists (created with session)
        tmux rename-window -t "${SESSION_NAME}:1" "$window_name"
    else
        tmux new-window -t "$SESSION_NAME" -n "$window_name"
    fi

    # Build the codex command
    codex_cmd="cd ${workdir} && codex-yolo codex --agent ${agent_toml} ${MODEL_FLAG}"
    if [[ -n "$initial_prompt" ]]; then
        codex_cmd="${codex_cmd} '${initial_prompt}'"
    fi

    tmux send-keys -t "${SESSION_NAME}:${window_name}" "$codex_cmd" Enter
done

# ── Control window (audit log tail) ─────────────────────────────────────────

tmux new-window -t "$SESSION_NAME" -n "Control"
tmux send-keys -t "${SESSION_NAME}:Control" \
    "echo '=== Codex Dark Factory Control ===' && echo 'Session: ${SESSION_NAME}' && echo 'Agents: ${#AGENTS[@]}' && echo 'Audit log: ${AUDIT_LOG}' && echo '===================================' && echo '' && tail -f ${AUDIT_LOG}" Enter

# ── Set up per-agent logging ────────────────────────────────────────────────

SESSION_LOG_DIR="$HOME/.dark-factory/logs/$SESSION_NAME"
mkdir -p "$SESSION_LOG_DIR"

for i in "${!AGENTS[@]}"; do
    IFS=':' read -r window_name _ _ <<< "${AGENTS[$i]}"
    log_name="$(echo "$window_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9_-')"
    # Each window has a single pane (pane index 0 in Codex factory)
    tmux pipe-pane -t "${SESSION_NAME}:${window_name}" \
        "cat >> '${SESSION_LOG_DIR}/${log_name}.log'"
done

info "Logging to $SESSION_LOG_DIR/"

# ── Select first window (TDM) ───────────────────────────────────────────────

tmux select-window -t "${SESSION_NAME}:1"

# ── Print status summary ────────────────────────────────────────────────────

echo ""
echo "========================================"
echo "  Codex Dark Factory Session Started"
echo "========================================"
echo "  Session:    $SESSION_NAME"
echo "  Team size:  $TEAM_SIZE"
echo "  Agents:     ${#AGENTS[@]}"
echo "  Logs:       $SESSION_LOG_DIR/"
echo "  Audit log:  $AUDIT_LOG"
if [[ "$FACTORY_USE_WORKTREES" == "true" ]]; then
echo "  Worktrees:  $FACTORY_WORKTREE_DIR/${SESSION_NAME}/"
fi
echo "========================================"
echo ""
echo "Commands:"
echo "  Attach:     tmux attach -t $SESSION_NAME"
echo "  Read-only:  tmux attach -t $SESSION_NAME -r"
echo "  Windows:    tmux list-windows -t $SESSION_NAME"
echo "  Stop:       tmux kill-session -t $SESSION_NAME"
echo ""
echo "Navigation (inside tmux):"
echo "  Prefix+n    Next agent window"
echo "  Prefix+p    Previous agent window"
echo "  Prefix+w    Interactive window list"
echo "  Prefix+0-9  Jump to window by number"
echo ""

# ── Attach to session ───────────────────────────────────────────────────────

exec tmux attach -t "$SESSION_NAME"
