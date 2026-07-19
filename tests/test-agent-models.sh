#!/usr/bin/env bash
# =============================================================================
# Agent Model Configuration Tests (SAW-62)
# =============================================================================
# Validates the `model:` field of every Claude Code subagent definition.
#
# WHY THIS TEST EXISTS
# Claude Code resolves an unusable subagent model by SILENTLY falling back to
# the inherited model. The docs state this for org-excluded models ("skips a
# value that resolves to an excluded model and runs the subagent on the
# inherited model instead") and do not document behaviour for a plain typo.
# There is also no documented way to check which model a subagent actually ran
# on afterwards.
#
# So a misconfigured model produces no error and cannot be detected at runtime.
# Validation has to happen at config time, which is what this suite does.
#
# Valid values per code.claude.com/docs/en/sub-agents.md:
#   aliases: sonnet | opus | haiku | fable
#   full ids: anything matching claude-*
#   inherit: use the main conversation's model
#   omitted: defaults to inherit
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENTS_DIR="$PROJECT_ROOT/.claude/agents"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS=0
FAIL=0

pass() { echo -e "  ${GREEN}PASS${NC} $1"; PASS=$((PASS + 1)); }
fail() { echo -e "  ${RED}FAIL${NC} $1"; FAIL=$((FAIL + 1)); }

# Returns 0 if the value is a documented-valid subagent model.
is_valid_model() {
    case "$1" in
        sonnet|opus|haiku|fable|inherit) return 0 ;;
        claude-*) return 0 ;;
        *) return 1 ;;
    esac
}

echo -e "\n${CYAN}=== Test 1: every agent declares a valid model ===${NC}\n"

agent_count=0
for f in "$AGENTS_DIR"/*.md; do
    name=$(basename "$f" .md)
    [ "$name" = "README" ] && continue
    agent_count=$((agent_count + 1))

    # Read model: from the frontmatter block only (first --- ... --- section).
    model=$(awk '/^---$/{n++; next} n==1 && /^model:/{sub(/^model:[[:space:]]*/,""); print; exit}' "$f")

    if [ -z "$model" ]; then
        # Omitted is legal and means inherit.
        pass "$name: model omitted (defaults to inherit)"
    elif is_valid_model "$model"; then
        pass "$name: model '$model' is valid"
    else
        fail "$name: model '$model' is NOT a documented value (expected sonnet|opus|haiku|fable|inherit|claude-*)"
    fi
done

echo ""
if [ "$agent_count" -gt 0 ]; then
    pass "found $agent_count agent definitions to check"
else
    fail "no agent definitions found under .claude/agents/ — the test would vacuously pass"
fi

echo -e "\n${CYAN}=== Test 2: the validator actually rejects a bad value ===${NC}\n"
# A gate that only ever passes proves nothing. Prove the negative case.

for bad in "opus-4" "gpt-5.4" "Opus" "sonet" ""; do
    label="${bad:-<empty>}"
    if is_valid_model "$bad"; then
        fail "is_valid_model wrongly ACCEPTED '$label'"
    else
        pass "rejects '$label'"
    fi
done

for good in "opus" "sonnet" "haiku" "fable" "inherit" "claude-opus-4-8" "claude-sonnet-5"; do
    if is_valid_model "$good"; then
        pass "accepts '$good'"
    else
        fail "is_valid_model wrongly REJECTED '$good'"
    fi
done

echo -e "\n${CYAN}=== Test 3: no agent silently inherits by accident ===${NC}\n"
# Inheriting is legal, but it should be a decision. Flag it as informational so
# a reviewer sees it rather than discovering it at runtime, where it is invisible.

inherited=0
for f in "$AGENTS_DIR"/*.md; do
    name=$(basename "$f" .md)
    [ "$name" = "README" ] && continue
    model=$(awk '/^---$/{n++; next} n==1 && /^model:/{sub(/^model:[[:space:]]*/,""); print; exit}' "$f")
    if [ -z "$model" ] || [ "$model" = "inherit" ]; then
        echo "    note: $name inherits the session model"
        inherited=$((inherited + 1))
    fi
done
pass "$inherited of $agent_count agents inherit the session model (informational)"

echo -e "\n${CYAN}=== Test Results ===${NC}\n"
echo -e "  Total:  $((PASS + FAIL))"
echo -e "  ${GREEN}Passed: ${PASS}${NC}"
echo -e "  ${RED}Failed: ${FAIL}${NC}"
echo ""

if [ "$FAIL" -gt 0 ]; then
    echo -e "${RED}AGENT MODEL TESTS FAILED${NC}"
    exit 1
fi
echo -e "${GREEN}ALL AGENT MODEL TESTS PASSED${NC}"
exit 0
