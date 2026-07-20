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
# An unmatched glob must expand to nothing, not to the literal pattern. Without this the
# empty-directory guard below is unreachable: awk fails on the literal "*.md", and set -e
# kills the script before the guard can report anything useful.
shopt -s nullglob

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
# claude-?* not claude-*: the bare prefix "claude-" names no model.
is_valid_model() {
    case "$1" in
        sonnet|opus|haiku|fable|inherit) return 0 ;;
        claude-?*) return 0 ;;
        *) return 1 ;;
    esac
}

# Extract the frontmatter `model:` value from an agent definition.
#
# Three things this has to survive, each of which silently broke an earlier version:
#   - CRLF line endings. /^---$/ does not match "---\r", so the frontmatter fence is never
#     recognised, no value is extracted, and a bogus model reads as "omitted" and PASSES.
#     A validator that degrades to accept-everything is worse than none, and a forked repo
#     with core.autocrlf=true produces exactly this.
#   - A body line starting with "model:". The n==1 guard confines matching to frontmatter.
#   - Quoted or trailing-padded values. `model: "opus"` is what a YAML-aware formatter writes,
#     and a trailing space is invisible; both are valid and must not be reported as failures.
# Note: CR is stripped inside awk rather than by piping through `tr`. With a pipe, awk's
# early `exit` closes it while tr is still writing a large agent file; tr takes SIGPIPE,
# and under `set -o pipefail` that fails the whole script. Single process, no pipe, no race.
extract_model() {
    awk '
        { sub(/\r$/, "") }
        /^---$/ { n++; next }
        n == 1 && /^model:/ {
            sub(/^model:[[:space:]]*/, "")
            sub(/[[:space:]]+$/, "")
            gsub(/^["'"'"']|["'"'"']$/, "")
            print
            exit
        }' "$1"
}

echo -e "\n${CYAN}=== Test 1: every agent declares a valid model ===${NC}\n"

agent_count=0
for f in "$AGENTS_DIR"/*.md; do
    name=$(basename "$f" .md)
    [ "$name" = "README" ] && continue
    agent_count=$((agent_count + 1))

    # Read model: from the frontmatter block only (first --- ... --- section).
    model=$(extract_model "$f")

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
    model=$(extract_model "$f")
    if [ -z "$model" ] || [ "$model" = "inherit" ]; then
        echo "    note: $name inherits the session model"
        inherited=$((inherited + 1))
    fi
done
pass "$inherited of $agent_count agents inherit the session model (informational)"

echo -e "\n${CYAN}=== Test 4: frontmatter parsing survives real-world formatting ===${NC}\n"
# Each case below silently broke an earlier revision of this script. They are pinned here
# because every one of them fails in the dangerous direction — reporting a bad config as fine.

T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

# Valid YAML that a formatter or editor will produce. Must be ACCEPTED.
printf -- '---\nname: q\nmodel: "opus"\ndescription: x\n---\nbody\n'   > "$T/quoted.md"
printf -- '---\nname: t\nmodel: opus   \ndescription: x\n---\nbody\n'  > "$T/trailing.md"
printf -- "---\nname: s\nmodel: 'fable'\ndescription: x\n---\nbody\n" > "$T/single.md"
for f in quoted trailing single; do
    got=$(extract_model "$T/$f.md")
    if is_valid_model "$got"; then pass "$f: parsed '$got' and accepted"
    else fail "$f: parsed '$got' and REJECTED it — valid YAML must not fail"; fi
done

# CRLF. Must still extract, so a bad value is still caught rather than read as "omitted".
printf -- '---\r\nname: c\r\nmodel: gpt-5-bogus\r\ndescription: x\r\n---\r\nbody\r\n' > "$T/crlf.md"
got=$(extract_model "$T/crlf.md")
if [ "$got" = "gpt-5-bogus" ]; then pass "crlf: extracted '$got' (bad value still visible)"
else fail "crlf: extracted '$got' — CRLF hides the value and a bad model would PASS"; fi

# A body line starting with model: must not be mistaken for frontmatter.
printf -- '---\nname: b\nmodel: opus\ndescription: x\n---\nmodel: bogus-in-body\n' > "$T/body.md"
got=$(extract_model "$T/body.md")
if [ "$got" = "opus" ]; then pass "body: read frontmatter '$got', ignored body line"
else fail "body: read '$got' — body content leaked into the frontmatter parse"; fi

# The bare prefix names no model.
if is_valid_model "claude-"; then fail "'claude-' wrongly accepted — it names no model"
else pass "rejects bare 'claude-'"; fi

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
