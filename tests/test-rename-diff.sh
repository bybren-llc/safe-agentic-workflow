#!/bin/bash
# =============================================================================
# Test: Rename-Aware Diff and Status (SAW-5)
# =============================================================================
# Tests all AC items for the rename-aware diff/status feature.
# Run from repo root: bash tests/test-rename-diff.sh
#
# Strategy:
#   - Unit tests source functions via a wrapper that strips the main
#     entry point from the sync script.
#   - Integration tests use a mocked version of the sync script that
#     stubs out network calls (fetch_upstream, get_upstream_sha, etc.)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SYNC_SCRIPT="$REPO_ROOT/scripts/sync-claude-harness.sh"

# Create a temporary project structure for testing
TEST_DIR=$(mktemp -d /tmp/rename-diff-test-XXXXXX)
trap "rm -rf $TEST_DIR" EXIT

PASS=0
FAIL=0
TOTAL=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

assert_contains() {
    local output="$1"
    local expected="$2"
    local label="$3"
    TOTAL=$((TOTAL + 1))
    if echo "$output" | grep -qF "$expected"; then
        echo -e "  ${GREEN}PASS${NC} $label"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $label (expected to find: $expected)"
        echo -e "  ${YELLOW}  Output (first 30 lines):${NC}"
        echo "$output" | head -30 | sed 's/^/    /'
        FAIL=$((FAIL + 1))
    fi
}

assert_not_contains() {
    local output="$1"
    local expected="$2"
    local label="$3"
    TOTAL=$((TOTAL + 1))
    if ! echo "$output" | grep -qF "$expected"; then
        echo -e "  ${GREEN}PASS${NC} $label"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $label (did NOT expect to find: $expected)"
        FAIL=$((FAIL + 1))
    fi
}

assert_exit_code() {
    local actual="$1"
    local expected="$2"
    local label="$3"
    TOTAL=$((TOTAL + 1))
    if [ "$actual" -eq "$expected" ]; then
        echo -e "  ${GREEN}PASS${NC} $label"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $label (expected exit $expected, got $actual)"
        FAIL=$((FAIL + 1))
    fi
}

assert_file_exists() {
    local path="$1"
    local label="$2"
    TOTAL=$((TOTAL + 1))
    if [ -f "$path" ]; then
        echo -e "  ${GREEN}PASS${NC} $label"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $label (file not found: $path)"
        FAIL=$((FAIL + 1))
    fi
}

assert_file_not_exists() {
    local path="$1"
    local label="$2"
    TOTAL=$((TOTAL + 1))
    if [ ! -f "$path" ]; then
        echo -e "  ${GREEN}PASS${NC} $label"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $label (file should not exist: $path)"
        FAIL=$((FAIL + 1))
    fi
}

# Setup: create a fake project with the sync script
setup_project() {
    local proj_dir="$TEST_DIR/project-$1"
    mkdir -p "$proj_dir/.claude"
    mkdir -p "$proj_dir/scripts"
    cp "$SYNC_SCRIPT" "$proj_dir/scripts/sync-claude-harness.sh"
    chmod +x "$proj_dir/scripts/sync-claude-harness.sh"
    echo "$proj_dir"
}

# Create a valid manifest with renames
create_manifest_with_renames() {
    local proj_dir="$1"
    cat > "$proj_dir/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "TestProject"
  PROJECT_REPO: "test-project"
  PROJECT_SHORT: "TST"
  GITHUB_ORG: "test-org"
  TICKET_PREFIX: "TST"
  MAIN_BRANCH: "main"
renames:
  "agents/fe-developer.md": "agents/ui-engineer.md"
  "agents/be-developer.md": "agents/api-engineer.md"
  "skills/rls-patterns/": "skills/firestore-security/"
  "skills/stripe-patterns/": "skills/payment-patterns/"
YAML
}

# Create a sourceable version of the sync script.
# Strips "set -e" and the main case statement so we can source the functions.
create_sourceable_script() {
    local proj_dir="$1"
    local sourceable="$TEST_DIR/sourceable-$(basename "$proj_dir").sh"

    # Remove set -e, the exit trap, and everything from the main command handler onward
    node -e "
        const fs = require('fs');
        const src = fs.readFileSync('$proj_dir/scripts/sync-claude-harness.sh', 'utf8');
        const lines = src.split('\n');
        const result = [];
        let skipMain = false;
        for (const line of lines) {
            if (line.match(/^# Main command handler/)) {
                skipMain = true;
                continue;
            }
            if (skipMain) continue;
            // Skip set -e so sourcing doesn't affect caller
            if (line.match(/^set -e$/)) continue;
            // Skip the trap so it doesn't interfere
            if (line.match(/^trap cleanup EXIT$/)) continue;
            result.push(line);
        }
        fs.writeFileSync('$sourceable', result.join('\n'));
    "

    echo "$sourceable"
}

# Create a mocked sync script that replaces network functions.
create_mocked_script() {
    local proj_dir="$1"
    local mock_upstream_dir="$2"
    local mocked_script="$proj_dir/scripts/sync-claude-harness-mocked.sh"

    # Replace fetch_upstream, get_upstream_sha, get_latest_release with mocks
    node -e "
        const fs = require('fs');
        let src = fs.readFileSync('$proj_dir/scripts/sync-claude-harness.sh', 'utf8');

        // Replace fetch_upstream function
        src = src.replace(
            /^fetch_upstream\(\) \{/m,
            'fetch_upstream() {\n    TMP_DIR=\"${mock_upstream_dir}\"\n    return 0\n}\nfetch_upstream_ORIG() {'
        );

        // Replace get_upstream_sha function
        src = src.replace(
            /^get_upstream_sha\(\) \{/m,
            'get_upstream_sha() { echo \"abc12345\"; }\nget_upstream_sha_ORIG() {'
        );

        // Replace get_latest_release function
        src = src.replace(
            /^get_latest_release\(\) \{/m,
            'get_latest_release() { echo \"v2.6.0\"; }\nget_latest_release_ORIG() {'
        );

        fs.writeFileSync('$mocked_script', src);
    "

    chmod +x "$mocked_script"
    echo "$mocked_script"
}

# =============================================================================
echo -e "\n${CYAN}=== Test 1: resolve_rename -- file rename (exact match) ===${NC}\n"
# AC: File rename: upstream agents/fe-developer.md compared to local agents/ui-engineer.md
# =============================================================================
PROJ=$(setup_project "resolve-file")
create_manifest_with_renames "$PROJ"
"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1
SOURCEABLE=$(create_sourceable_script "$PROJ")

output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.harness-manifest.yml"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest
    echo "FILE_RENAME: $(resolve_rename 'agents/fe-developer.md')"
    echo "FILE_RENAME2: $(resolve_rename 'agents/be-developer.md')"
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "FILE_RENAME: agents/ui-engineer.md" "file rename resolves fe-developer.md -> ui-engineer.md"
assert_contains "$output" "FILE_RENAME2: agents/api-engineer.md" "file rename resolves be-developer.md -> api-engineer.md"

# =============================================================================
echo -e "\n${CYAN}=== Test 2: resolve_rename -- directory rename (prefix match) ===${NC}\n"
# AC: Directory rename: all files under renamed directory correctly mapped
# =============================================================================
PROJ=$(setup_project "resolve-dir")
create_manifest_with_renames "$PROJ"
"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1
SOURCEABLE=$(create_sourceable_script "$PROJ")

output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.harness-manifest.yml"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest
    echo "DIR_SKILL: $(resolve_rename 'skills/rls-patterns/SKILL.md')"
    echo "DIR_README: $(resolve_rename 'skills/rls-patterns/README.md')"
    echo "DIR_DEEP: $(resolve_rename 'skills/rls-patterns/sub/nested.md')"
    echo "DIR_STRIPE: $(resolve_rename 'skills/stripe-patterns/webhook.md')"
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "DIR_SKILL: skills/firestore-security/SKILL.md" "directory rename resolves rls-patterns/SKILL.md"
assert_contains "$output" "DIR_README: skills/firestore-security/README.md" "directory rename resolves rls-patterns/README.md"
assert_contains "$output" "DIR_DEEP: skills/firestore-security/sub/nested.md" "directory rename resolves nested paths"
assert_contains "$output" "DIR_STRIPE: skills/payment-patterns/webhook.md" "directory rename resolves stripe-patterns/webhook.md"

# =============================================================================
echo -e "\n${CYAN}=== Test 3: resolve_rename -- no rename (passthrough) ===${NC}\n"
# =============================================================================
PROJ=$(setup_project "resolve-none")
create_manifest_with_renames "$PROJ"
"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1
SOURCEABLE=$(create_sourceable_script "$PROJ")

output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.harness-manifest.yml"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest
    echo "PASSTHROUGH: $(resolve_rename 'agents/system-architect.md')"
    echo "PASSTHROUGH2: $(resolve_rename 'commands/pr-review.md')"
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "PASSTHROUGH: agents/system-architect.md" "unrenamed file passes through unchanged"
assert_contains "$output" "PASSTHROUGH2: commands/pr-review.md" "unrenamed file passes through unchanged (2)"

# =============================================================================
echo -e "\n${CYAN}=== Test 4: resolve_rename -- no manifest (backward compatible) ===${NC}\n"
# AC: No manifest = no rename resolution (backward compatible)
# =============================================================================
PROJ=$(setup_project "resolve-nomanifest")
# No manifest, no init
SOURCEABLE=$(create_sourceable_script "$PROJ")

output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.harness-manifest.yml"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    # Do NOT call load_manifest - manifest file doesn't exist
    echo "NO_MANIFEST: $(resolve_rename 'agents/fe-developer.md')"
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "NO_MANIFEST: agents/fe-developer.md" "no manifest means path returned unchanged"

# =============================================================================
echo -e "\n${CYAN}=== Test 5: resolve_rename -- file rename takes precedence over directory ===${NC}\n"
# AC: File renames take precedence over directory renames
# =============================================================================
PROJ=$(setup_project "resolve-precedence")

cat > "$PROJ/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "TestProject"
  PROJECT_REPO: "test-project"
  PROJECT_SHORT: "TST"
  GITHUB_ORG: "test-org"
  TICKET_PREFIX: "TST"
  MAIN_BRANCH: "main"
renames:
  "skills/rls-patterns/SKILL.md": "skills/custom-skill.md"
  "skills/rls-patterns/": "skills/firestore-security/"
YAML

"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1
SOURCEABLE=$(create_sourceable_script "$PROJ")

output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.harness-manifest.yml"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest
    echo "FILE_WINS: $(resolve_rename 'skills/rls-patterns/SKILL.md')"
    echo "DIR_APPLIES: $(resolve_rename 'skills/rls-patterns/README.md')"
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "FILE_WINS: skills/custom-skill.md" "file rename takes precedence over directory rename"
assert_contains "$output" "DIR_APPLIES: skills/firestore-security/README.md" "directory rename still applies to other files"

# =============================================================================
echo -e "\n${CYAN}=== Test 6: rename_type -- correctly identifies rename types ===${NC}\n"
# =============================================================================
PROJ=$(setup_project "rename-type")
create_manifest_with_renames "$PROJ"
"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1
SOURCEABLE=$(create_sourceable_script "$PROJ")

output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.harness-manifest.yml"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest
    echo "TYPE_FILE: $(rename_type 'agents/fe-developer.md')"
    echo "TYPE_DIR: $(rename_type 'skills/rls-patterns/SKILL.md')"
    echo "TYPE_NONE: $(rename_type 'agents/system-architect.md')"
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "TYPE_FILE: file" "rename_type returns 'file' for file renames"
assert_contains "$output" "TYPE_DIR: directory" "rename_type returns 'directory' for dir renames"
assert_contains "$output" "TYPE_NONE: none" "rename_type returns 'none' for unrenamed paths"

# =============================================================================
echo -e "\n${CYAN}=== Test 7: do_diff -- shows renamed files with correct local path ===${NC}\n"
# AC: Diff shows correct local path (not upstream path) for renamed files
# AC: sync diff uses manifest renames when comparing upstream -> local
# =============================================================================
PROJ=$(setup_project "diff-renamed")
create_manifest_with_renames "$PROJ"
"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

# Create local .claude directory structure with renamed files
mkdir -p "$PROJ/.claude/agents"
mkdir -p "$PROJ/.claude/skills/firestore-security"
mkdir -p "$PROJ/.claude/skills/payment-patterns"

echo "# UI Engineer" > "$PROJ/.claude/agents/ui-engineer.md"
echo "# API Engineer" > "$PROJ/.claude/agents/api-engineer.md"
echo "# System Architect" > "$PROJ/.claude/agents/system-architect.md"
echo "# Firestore Skill" > "$PROJ/.claude/skills/firestore-security/SKILL.md"
echo "# Firestore README" > "$PROJ/.claude/skills/firestore-security/README.md"
echo "# Firestore Rules" > "$PROJ/.claude/skills/firestore-security/rules.md"
echo "# Payment Webhook" > "$PROJ/.claude/skills/payment-patterns/webhook.md"

# Create mock upstream directory structure
MOCK_UPSTREAM="$TEST_DIR/mock-upstream-diff"
mkdir -p "$MOCK_UPSTREAM/.claude/agents"
mkdir -p "$MOCK_UPSTREAM/.claude/skills/rls-patterns"
mkdir -p "$MOCK_UPSTREAM/.claude/skills/stripe-patterns"

echo "# FE Developer" > "$MOCK_UPSTREAM/.claude/agents/fe-developer.md"
echo "# BE Developer" > "$MOCK_UPSTREAM/.claude/agents/be-developer.md"
echo "# System Architect" > "$MOCK_UPSTREAM/.claude/agents/system-architect.md"
echo "# RLS Skill" > "$MOCK_UPSTREAM/.claude/skills/rls-patterns/SKILL.md"
echo "# RLS README" > "$MOCK_UPSTREAM/.claude/skills/rls-patterns/README.md"
echo "# RLS Rules" > "$MOCK_UPSTREAM/.claude/skills/rls-patterns/rules.md"
echo "# Stripe Webhook" > "$MOCK_UPSTREAM/.claude/skills/stripe-patterns/webhook.md"

MOCKED_SCRIPT=$(create_mocked_script "$PROJ" "$MOCK_UPSTREAM")

output=$("$MOCKED_SCRIPT" diff 2>&1 || true)

# All local files match upstream paths via renames, content differs -> MODIFIED
assert_contains "$output" "agents/ui-engineer.md (upstream: agents/fe-developer.md)" "diff shows local path for file-renamed agent"
assert_contains "$output" "agents/api-engineer.md (upstream: agents/be-developer.md)" "diff shows local path for file-renamed agent (2)"
assert_contains "$output" "skills/firestore-security/SKILL.md (upstream: skills/rls-patterns/SKILL.md)" "diff shows local path for dir-renamed file"
assert_contains "$output" "skills/payment-patterns/webhook.md (upstream: skills/stripe-patterns/webhook.md)" "diff shows local path for dir-renamed stripe file"

# RENAMED summary lines for directory renames
assert_contains "$output" "RENAMED" "RENAMED summary line present"
assert_contains "$output" "skills/rls-patterns/ -> skills/firestore-security/" "RENAMED line for rls-patterns directory"
assert_contains "$output" "skills/stripe-patterns/ -> skills/payment-patterns/" "RENAMED line for stripe-patterns directory"

# =============================================================================
echo -e "\n${CYAN}=== Test 8: do_diff -- unrenamed files show original path ===${NC}\n"
# =============================================================================
assert_not_contains "$output" "system-architect.md (upstream:" "unrenamed files do not show rename annotation"

# =============================================================================
echo -e "\n${CYAN}=== Test 9: RENAMED directory summary with file count ===${NC}\n"
# AC: Status output labels renamed files: RENAMED rls-patterns/ -> firestore-security/ (3 files)
# =============================================================================
assert_contains "$output" "skills/rls-patterns/ -> skills/firestore-security/ (3 files)" "RENAMED shows correct file count (3) for rls-patterns"
assert_contains "$output" "skills/stripe-patterns/ -> skills/payment-patterns/ (1 files)" "RENAMED shows correct file count (1) for stripe-patterns"

# =============================================================================
echo -e "\n${CYAN}=== Test 10: do_diff -- renamed count in summary ===${NC}\n"
# =============================================================================
assert_contains "$output" "renamed" "diff summary includes renamed count"

# =============================================================================
echo -e "\n${CYAN}=== Test 11: do_diff -- no manifest backward compatibility ===${NC}\n"
# AC: No manifest = no rename resolution (backward compatible)
# =============================================================================
PROJ=$(setup_project "diff-nomanifest")
"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

mkdir -p "$PROJ/.claude/agents"
echo "# FE Dev" > "$PROJ/.claude/agents/fe-developer.md"

MOCK_UPSTREAM2="$TEST_DIR/mock-upstream-nomnfst"
mkdir -p "$MOCK_UPSTREAM2/.claude/agents"
echo "# FE Developer Updated" > "$MOCK_UPSTREAM2/.claude/agents/fe-developer.md"

MOCKED_SCRIPT2=$(create_mocked_script "$PROJ" "$MOCK_UPSTREAM2")

output=$("$MOCKED_SCRIPT2" diff 2>&1 || true)

assert_contains "$output" "agents/fe-developer.md" "no-manifest diff shows original path"
assert_not_contains "$output" "(upstream:" "no-manifest diff has no rename annotation"
assert_not_contains "$output" "RENAMED" "no-manifest diff has no RENAMED lines"

# =============================================================================
echo -e "\n${CYAN}=== Test 12: do_status -- shows rename details ===${NC}\n"
# AC: Status output shows rename mappings
# =============================================================================
PROJ=$(setup_project "status-renames")
create_manifest_with_renames "$PROJ"
"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

MOCKED_SCRIPT3=$(create_mocked_script "$PROJ" "$TEST_DIR/empty-upstream")
mkdir -p "$TEST_DIR/empty-upstream/.claude"
output=$("$MOCKED_SCRIPT3" status 2>&1 || true)

assert_contains "$output" "Renames:       4" "status shows 4 total renames"
assert_contains "$output" "Rename mappings (upstream -> local):" "status shows rename mappings header"
assert_contains "$output" "agents/fe-developer.md -> agents/ui-engineer.md (file)" "status lists file rename"
assert_contains "$output" "skills/rls-patterns/ -> skills/firestore-security/ (dir)" "status lists directory rename"
assert_contains "$output" "skills/stripe-patterns/ -> skills/payment-patterns/ (dir)" "status lists stripe directory rename"

# =============================================================================
echo -e "\n${CYAN}=== Test 13: do_status -- no rename details without manifest ===${NC}\n"
# =============================================================================
PROJ=$(setup_project "status-norenames")
"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

MOCKED_SCRIPT4=$(create_mocked_script "$PROJ" "$TEST_DIR/empty-upstream2")
mkdir -p "$TEST_DIR/empty-upstream2/.claude"
output=$("$MOCKED_SCRIPT4" status 2>&1 || true)

assert_not_contains "$output" "Rename mappings" "no rename mappings without manifest"
assert_contains "$output" "No manifest found" "shows legacy mode message"

# =============================================================================
echo -e "\n${CYAN}=== Test 14: compare_file_with_paths -- different upstream and local paths ===${NC}\n"
# =============================================================================
PROJ=$(setup_project "compare-paths")
"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

MOCK_UP_CMP="$TEST_DIR/mock-upstream-compare"
mkdir -p "$MOCK_UP_CMP/.claude/agents"
echo "# Same Content" > "$MOCK_UP_CMP/.claude/agents/fe-developer.md"

mkdir -p "$PROJ/.claude/agents"
echo "# Same Content" > "$PROJ/.claude/agents/ui-engineer.md"
echo "# Different Content" > "$PROJ/.claude/agents/api-engineer.md"

SOURCEABLE=$(create_sourceable_script "$PROJ")

output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.harness-manifest.yml"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR="$MOCK_UP_CMP"
    echo "SAME: $(compare_file_with_paths 'agents/fe-developer.md' 'agents/ui-engineer.md')"
    echo "DIFF: $(compare_file_with_paths 'agents/fe-developer.md' 'agents/api-engineer.md')"
    echo "MISSING: $(compare_file_with_paths 'agents/fe-developer.md' 'agents/nonexistent.md')"
)

assert_contains "$output" "SAME: unchanged" "compare_file_with_paths detects unchanged content across different paths"
assert_contains "$output" "DIFF: modified" "compare_file_with_paths detects modified content across different paths"
assert_contains "$output" "MISSING: new" "compare_file_with_paths detects new file when local missing"

# =============================================================================
echo -e "\n${CYAN}=== Test 15: do_diff -- local-only detection with renames ===${NC}\n"
# Files at renamed local paths should NOT show as LOCAL ONLY
# =============================================================================
PROJ=$(setup_project "diff-localonly")
create_manifest_with_renames "$PROJ"
"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

mkdir -p "$PROJ/.claude/agents"
mkdir -p "$PROJ/.claude/skills/firestore-security"
echo "# UI Engineer" > "$PROJ/.claude/agents/ui-engineer.md"
echo "# Firestore Skill" > "$PROJ/.claude/skills/firestore-security/SKILL.md"
echo "# Custom Agent" > "$PROJ/.claude/agents/custom-agent.md"

MOCK_UPSTREAM6="$TEST_DIR/mock-upstream-localonly"
mkdir -p "$MOCK_UPSTREAM6/.claude/agents"
mkdir -p "$MOCK_UPSTREAM6/.claude/skills/rls-patterns"
echo "# FE Developer" > "$MOCK_UPSTREAM6/.claude/agents/fe-developer.md"
echo "# RLS Skill" > "$MOCK_UPSTREAM6/.claude/skills/rls-patterns/SKILL.md"

MOCKED_SCRIPT5=$(create_mocked_script "$PROJ" "$MOCK_UPSTREAM6")
output=$("$MOCKED_SCRIPT5" diff 2>&1 || true)

assert_not_contains "$output" "LOCAL ONLY agents/ui-engineer.md" "renamed file target is NOT shown as local-only"
assert_not_contains "$output" "LOCAL ONLY skills/firestore-security/SKILL.md" "renamed dir target is NOT shown as local-only"
assert_contains "$output" "LOCAL ONLY" "truly local-only file IS detected"
assert_contains "$output" "custom-agent.md" "custom-agent.md listed in output"

# =============================================================================
echo -e "\n${CYAN}=== Test 16: do_sync -- uses renames for file placement ===${NC}\n"
# Sync should write upstream files to their renamed local paths
# =============================================================================
PROJ=$(setup_project "sync-renamed")
create_manifest_with_renames "$PROJ"
"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

MOCK_UPSTREAM7="$TEST_DIR/mock-upstream-sync"
mkdir -p "$MOCK_UPSTREAM7/.claude/agents"
mkdir -p "$MOCK_UPSTREAM7/.claude/skills/rls-patterns"
echo "# FE Developer" > "$MOCK_UPSTREAM7/.claude/agents/fe-developer.md"
echo "# RLS Skill" > "$MOCK_UPSTREAM7/.claude/skills/rls-patterns/SKILL.md"

MOCKED_SCRIPT6=$(create_mocked_script "$PROJ" "$MOCK_UPSTREAM7")
output=$("$MOCKED_SCRIPT6" sync 2>&1 || true)

assert_contains "$output" "agents/ui-engineer.md (upstream: agents/fe-developer.md)" "sync reports renamed path for added file"
assert_contains "$output" "skills/firestore-security/SKILL.md (upstream: skills/rls-patterns/SKILL.md)" "sync reports renamed path for added dir file"

# Verify files exist at renamed paths
assert_file_exists "$PROJ/.claude/agents/ui-engineer.md" "file written to renamed path agents/ui-engineer.md"
assert_file_exists "$PROJ/.claude/skills/firestore-security/SKILL.md" "file written to renamed path skills/firestore-security/SKILL.md"

# Verify files do NOT exist at original upstream paths
assert_file_not_exists "$PROJ/.claude/agents/fe-developer.md" "file NOT written to upstream path agents/fe-developer.md"
assert_file_not_exists "$PROJ/.claude/skills/rls-patterns/SKILL.md" "file NOT written to upstream path skills/rls-patterns/SKILL.md"

# =============================================================================
echo -e "\n${CYAN}=== Test 17: Script syntax validation ===${NC}\n"
# =============================================================================
syntax_output=$(bash -n "$SYNC_SCRIPT" 2>&1)
syntax_ec=$?
assert_exit_code "$syntax_ec" 0 "sync script has valid bash syntax"

# =============================================================================
echo -e "\n${CYAN}=== Test 18: Existing manifest loader tests still pass ===${NC}\n"
# =============================================================================
ml_output=$(bash "$REPO_ROOT/tests/test-manifest-loader.sh" 2>&1)
ml_ec=$?
assert_exit_code "$ml_ec" 0 "manifest loader tests (SAW-6) still pass"

# =============================================================================
# Summary
# =============================================================================
echo -e "\n${CYAN}=== Test Results ===${NC}\n"
echo -e "  Total:  $TOTAL"
echo -e "  ${GREEN}Passed: $PASS${NC}"
if [ $FAIL -gt 0 ]; then
    echo -e "  ${RED}Failed: $FAIL${NC}"
    exit 1
else
    echo -e "  Failed: 0"
    echo -e "\n  ${GREEN}ALL TESTS PASSED${NC}\n"
    exit 0
fi
