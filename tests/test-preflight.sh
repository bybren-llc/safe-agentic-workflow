#!/bin/bash
# =============================================================================
# Test: Preflight Safety Check + Provenance Tracking (SAW-2)
# =============================================================================
# Tests all AC items for the preflight safety check and provenance features.
# Run from repo root: bash tests/test-preflight.sh
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
TEST_DIR=$(mktemp -d /tmp/preflight-test-XXXXXX)
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

# Strip ANSI escape codes for reliable text matching
strip_ansi() {
    sed 's/\x1b\[[0-9;]*m//g'
}

assert_contains() {
    local output="$1"
    local expected="$2"
    local label="$3"
    TOTAL=$((TOTAL + 1))
    if echo "$output" | strip_ansi | grep -qF -- "$expected"; then
        echo -e "  ${GREEN}PASS${NC} $label"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $label (expected to find: $expected)"
        echo -e "  ${YELLOW}  Output (first 40 lines):${NC}"
        echo "$output" | strip_ansi | head -40 | sed 's/^/    /'
        FAIL=$((FAIL + 1))
    fi
}

assert_not_contains() {
    local output="$1"
    local expected="$2"
    local label="$3"
    TOTAL=$((TOTAL + 1))
    if ! echo "$output" | strip_ansi | grep -qF -- "$expected"; then
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

assert_file_content() {
    local path="$1"
    local expected="$2"
    local label="$3"
    TOTAL=$((TOTAL + 1))
    if [ -f "$path" ] && grep -qF "$expected" "$path"; then
        echo -e "  ${GREEN}PASS${NC} $label"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $label (expected content: $expected in $path)"
        if [ -f "$path" ]; then
            echo -e "  ${YELLOW}  File contents (first 20 lines):${NC}"
            head -20 "$path" | sed 's/^/    /'
        fi
        FAIL=$((FAIL + 1))
    fi
}

assert_json_field() {
    local file="$1"
    local field="$2"
    local expected="$3"
    local label="$4"
    TOTAL=$((TOTAL + 1))
    local actual
    actual=$(node -e "
        const fs = require('fs');
        try {
            const data = JSON.parse(fs.readFileSync('$file', 'utf8'));
            const keys = '$field'.split('.');
            let val = data;
            for (const k of keys) {
                if (val === null || val === undefined) { val = undefined; break; }
                if (/^\d+$/.test(k)) { val = val[parseInt(k)]; } else { val = val[k]; }
            }
            console.log(val === undefined || val === null ? 'null' : String(val));
        } catch(e) { console.log('ERROR: ' + e.message); }
    ")
    if [ "$actual" = "$expected" ]; then
        echo -e "  ${GREEN}PASS${NC} $label"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $label (expected '$expected', got '$actual')"
        FAIL=$((FAIL + 1))
    fi
}

assert_json_not_null() {
    local file="$1"
    local field="$2"
    local label="$3"
    TOTAL=$((TOTAL + 1))
    local actual
    actual=$(node -e "
        const fs = require('fs');
        try {
            const data = JSON.parse(fs.readFileSync('$file', 'utf8'));
            const keys = '$field'.split('.');
            let val = data;
            for (const k of keys) {
                if (val === null || val === undefined) { val = undefined; break; }
                if (/^\d+$/.test(k)) { val = val[parseInt(k)]; } else { val = val[k]; }
            }
            console.log(val === undefined || val === null ? 'null' : 'not_null');
        } catch(e) { console.log('ERROR: ' + e.message); }
    ")
    if [ "$actual" = "not_null" ]; then
        echo -e "  ${GREEN}PASS${NC} $label"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $label (expected non-null, got null)"
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

# Create a sourceable version of the sync script.
create_sourceable_script() {
    local proj_dir="$1"
    local sourceable="$TEST_DIR/sourceable-$(basename "$proj_dir").sh"

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
            if (line.match(/^set -e$/)) continue;
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
            'get_upstream_sha() { echo \"abc12345abc12345abc12345abc12345abc12345\"; }\nget_upstream_sha_ORIG() {'
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

# Create a valid manifest with substitutions and protected entries
create_manifest_with_subs() {
    local proj_dir="$1"
    cat > "$proj_dir/.claude/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "TestProject"
  PROJECT_REPO: "test-project"
  PROJECT_SHORT: "TST"
  GITHUB_ORG: "test-org"
  TICKET_PREFIX: "TST"
  MAIN_BRANCH: "main"
substitutions:
  "{{PROJECT_NAME}}": "TestProject"
  "{{GITHUB_ORG}}": "test-org"
  "{{TICKET_PREFIX}}": "TST"
protected:
  - "CLAUDE.md"
  - "settings.local.json"
YAML
}

# =============================================================================
echo -e "\n${CYAN}=== Test 1: scan_unreplaced_tokens -- clean file ===${NC}\n"
# AC: Validates no {{...}} tokens remain post-substitution
# =============================================================================
PROJ=$(setup_project "token-clean")
create_manifest_with_subs "$PROJ"
"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1
SOURCEABLE=$(create_sourceable_script "$PROJ")

# Create a file with NO unreplaced tokens
mkdir -p "$TEST_DIR/token-clean-file"
cat > "$TEST_DIR/token-clean-file/clean.md" <<'EOF'
# TestProject README
This is the test-org project.
Ticket prefix: TST
EOF

output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.claude/.harness-manifest.yml"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest

    if scan_unreplaced_tokens "$TEST_DIR/token-clean-file/clean.md" "clean.md" 2>&1; then
        echo "SCAN_RESULT: clean"
    else
        echo "SCAN_RESULT: dirty"
    fi
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "SCAN_RESULT: clean" "Clean file passes token scan"

# =============================================================================
echo -e "\n${CYAN}=== Test 2: scan_unreplaced_tokens -- file with unreplaced tokens ===${NC}\n"
# AC: Detects unreplaced manifest tokens with file:line
# =============================================================================
mkdir -p "$TEST_DIR/token-dirty-file"
cat > "$TEST_DIR/token-dirty-file/dirty.md" <<'EOF'
# {{PROJECT_NAME}} README
This is the {{GITHUB_ORG}} project.
Line 3 is fine.
Ticket prefix: {{TICKET_PREFIX}}
EOF

output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.claude/.harness-manifest.yml"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest

    result=$(scan_unreplaced_tokens "$TEST_DIR/token-dirty-file/dirty.md" "dirty.md" 2>&1) || true
    echo "$result"
    if [ -n "$result" ]; then
        echo "SCAN_RESULT: dirty"
    else
        echo "SCAN_RESULT: clean"
    fi
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "SCAN_RESULT: dirty" "File with unreplaced tokens detected"
assert_contains "$output" "dirty.md:1: unreplaced token {{PROJECT_NAME}}" "Reports file:line for PROJECT_NAME"
assert_contains "$output" "dirty.md:2: unreplaced token {{GITHUB_ORG}}" "Reports file:line for GITHUB_ORG"
assert_contains "$output" "dirty.md:4: unreplaced token {{TICKET_PREFIX}}" "Reports file:line for TICKET_PREFIX"

# =============================================================================
echo -e "\n${CYAN}=== Test 3: scan_unreplaced_tokens -- ignores non-manifest tokens ===${NC}\n"
# AC: {{...}} tokens NOT in manifest are ignored
# =============================================================================
mkdir -p "$TEST_DIR/token-ignore-file"
cat > "$TEST_DIR/token-ignore-file/example.md" <<'EOF'
# TestProject
Use {{SOME_OTHER_TOKEN}} in your template.
Also {{NOT_A_MANIFEST_KEY}} is fine.
EOF

output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.claude/.harness-manifest.yml"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest

    if scan_unreplaced_tokens "$TEST_DIR/token-ignore-file/example.md" "example.md" 2>&1; then
        echo "SCAN_RESULT: clean"
    else
        echo "SCAN_RESULT: dirty"
    fi
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "SCAN_RESULT: clean" "Non-manifest {{...}} tokens are ignored"

# =============================================================================
echo -e "\n${CYAN}=== Test 4: run_preflight -- clean sync plan passes ===${NC}\n"
# AC: Preflight runs automatically before sync
# =============================================================================
output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.claude/.harness-manifest.yml"
    EXCLUDE_FILE="$PROJ/.claude/.sync-exclude"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest

    # Create a fake upstream file (clean, no unreplaced tokens)
    mkdir -p "$TMP_DIR/.claude/agents"
    echo "# TestProject content" > "$TMP_DIR/.claude/agents/readme.md"

    sync_plan="new|agents/readme.md|agents/readme.md"
    if run_preflight "$sync_plan" "$PROJ/.claude" 2>&1; then
        echo "PREFLIGHT_RESULT: pass"
    else
        echo "PREFLIGHT_RESULT: fail"
    fi
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "PREFLIGHT_RESULT: pass" "Clean sync plan passes preflight"
assert_contains "$output" "Preflight passed" "Preflight success message shown"

# =============================================================================
echo -e "\n${CYAN}=== Test 5: run_preflight -- scope violation detected ===${NC}\n"
# AC: Validates (a) no files outside manifest scope modified
# =============================================================================
output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.claude/.harness-manifest.yml"
    EXCLUDE_FILE="$PROJ/.claude/.sync-exclude"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest

    mkdir -p "$TMP_DIR/.claude"
    # Don't actually create the file -- just test the plan validation
    sync_plan="new|../../etc/passwd|../../etc/passwd"
    if run_preflight "$sync_plan" "$PROJ/.claude" 2>&1; then
        echo "PREFLIGHT_RESULT: pass"
    else
        echo "PREFLIGHT_RESULT: fail"
    fi
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "PREFLIGHT_RESULT: fail" "Scope violation causes preflight failure"
assert_contains "$output" "Scope violation" "Scope violation error message shown"

# =============================================================================
echo -e "\n${CYAN}=== Test 6: run_preflight -- protected file violation ===${NC}\n"
# AC: Validates (c) no protected files being modified
# =============================================================================
output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.claude/.harness-manifest.yml"
    EXCLUDE_FILE="$PROJ/.claude/.sync-exclude"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest

    mkdir -p "$TMP_DIR/.claude"
    echo "# Modified CLAUDE.md" > "$TMP_DIR/.claude/CLAUDE.md"

    sync_plan="modified|CLAUDE.md|CLAUDE.md"
    if run_preflight "$sync_plan" "$PROJ/.claude" 2>&1; then
        echo "PREFLIGHT_RESULT: pass"
    else
        echo "PREFLIGHT_RESULT: fail"
    fi
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "PREFLIGHT_RESULT: fail" "Protected file violation causes preflight failure"
assert_contains "$output" "Protected file violation" "Protected file error message shown"

# =============================================================================
echo -e "\n${CYAN}=== Test 7: run_preflight -- unreplaced token violation ===${NC}\n"
# AC: Validates (b) no {{...}} tokens remain post-substitution
# =============================================================================
output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.claude/.harness-manifest.yml"
    EXCLUDE_FILE="$PROJ/.claude/.sync-exclude"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest

    mkdir -p "$TMP_DIR/.claude"
    echo "# {{PROJECT_NAME}} has unreplaced tokens" > "$TMP_DIR/.claude/readme.md"

    sync_plan="new|readme.md|readme.md"
    if run_preflight "$sync_plan" "$PROJ/.claude" 2>&1; then
        echo "PREFLIGHT_RESULT: pass"
    else
        echo "PREFLIGHT_RESULT: fail"
    fi
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "PREFLIGHT_RESULT: fail" "Unreplaced token causes preflight failure"
assert_contains "$output" "Unreplaced token violation" "Token violation error message shown"
assert_contains "$output" "readme.md:1: unreplaced token {{PROJECT_NAME}}" "Token location reported"

# =============================================================================
echo -e "\n${CYAN}=== Test 8: --skip-preflight flag ===${NC}\n"
# AC: --skip-preflight flag for advanced users
# =============================================================================
PROJ2=$(setup_project "skip-preflight")
create_manifest_with_subs "$PROJ2"
"$PROJ2/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

# Create mock upstream with a protected file (would normally fail preflight)
MOCK_DIR="$TEST_DIR/mock-upstream-skip"
mkdir -p "$MOCK_DIR/.claude/agents"
echo "# Protected but skipping preflight" > "$MOCK_DIR/.claude/CLAUDE.md"
echo "# Normal file" > "$MOCK_DIR/.claude/agents/readme.md"

MOCKED=$(create_mocked_script "$PROJ2" "$MOCK_DIR")

# The sync should proceed despite protected file because preflight is skipped
output=$(bash "$MOCKED" sync --skip-preflight 2>&1) || true

assert_contains "$output" "Preflight check SKIPPED" "Skip preflight warning is logged"
assert_not_contains "$output" "Preflight FAILED" "Preflight failure message NOT shown when skipped"

# =============================================================================
echo -e "\n${CYAN}=== Test 9: Preflight runs automatically on sync (not just --dry-run) ===${NC}\n"
# AC: Preflight runs automatically before sync (not just --dry-run)
# =============================================================================
PROJ3=$(setup_project "auto-preflight")
create_manifest_with_subs "$PROJ3"
"$PROJ3/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

# Create mock upstream with ONLY unreplaced tokens (will fail preflight)
MOCK_DIR3="$TEST_DIR/mock-upstream-auto"
mkdir -p "$MOCK_DIR3/.claude"
echo "# {{PROJECT_NAME}} still has tokens" > "$MOCK_DIR3/.claude/some-file.md"

MOCKED3=$(create_mocked_script "$PROJ3" "$MOCK_DIR3")

# Run without --dry-run -- should still run preflight and fail
output=$(bash "$MOCKED3" sync 2>&1) || true
rc=$?

assert_contains "$output" "Preflight Safety Check" "Preflight header shown during sync"
# The file should have tokens replaced by substitution engine before preflight,
# so this should actually PASS if substitutions work correctly.
# Let's verify the full flow works.
assert_contains "$output" "Preflight passed" "Preflight passes when substitutions replace tokens"

# =============================================================================
echo -e "\n${CYAN}=== Test 10: Preflight skips token check with --no-placeholders ===${NC}\n"
# AC: --no-placeholders intentionally disables token scanning in preflight
# (user opted out of substitution, so unreplaced tokens are expected)
# =============================================================================
PROJ4=$(setup_project "no-placeholders-preflight")
create_manifest_with_subs "$PROJ4"
"$PROJ4/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

MOCK_DIR4="$TEST_DIR/mock-upstream-noplaceholders"
mkdir -p "$MOCK_DIR4/.claude"
echo "# {{PROJECT_NAME}} still has tokens" > "$MOCK_DIR4/.claude/some-file.md"

MOCKED4=$(create_mocked_script "$PROJ4" "$MOCK_DIR4")

# Run with --no-placeholders -- token check should be skipped in preflight
output=$(bash "$MOCKED4" sync --no-placeholders 2>&1) || true

assert_contains "$output" "Preflight passed" "Preflight passes when --no-placeholders skips token check"
assert_not_contains "$output" "Unreplaced token violation" "Token violation NOT reported with --no-placeholders"
# Verify tokens are preserved in the output file
assert_file_content "$PROJ4/.claude/some-file.md" "{{PROJECT_NAME}}" "Tokens preserved in file with --no-placeholders"

# =============================================================================
echo -e "\n${CYAN}=== Test 11: Provenance tracking in .harness-sync.json ===${NC}\n"
# AC: Provenance tracking: source commit SHA, upstream version, sync timestamp
# =============================================================================
PROJ5=$(setup_project "provenance")
create_manifest_with_subs "$PROJ5"
"$PROJ5/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

# Create mock upstream with clean files
MOCK_DIR5="$TEST_DIR/mock-upstream-provenance"
mkdir -p "$MOCK_DIR5/.claude/agents"
echo "# TestProject agent readme" > "$MOCK_DIR5/.claude/agents/readme.md"

MOCKED5=$(create_mocked_script "$PROJ5" "$MOCK_DIR5")

# Run sync
output=$(bash "$MOCKED5" sync 2>&1) || true

SYNC_JSON="$PROJ5/.claude/.harness-sync.json"
assert_file_exists "$SYNC_JSON" ".harness-sync.json exists after sync"

# Check provenance fields
assert_json_not_null "$SYNC_JSON" "last_sync_timestamp" "last_sync_timestamp is set"
assert_json_not_null "$SYNC_JSON" "last_sync_version" "last_sync_version is set"
assert_json_field "$SYNC_JSON" "last_sync_commit" "abc12345abc12345abc12345abc12345abc12345" "last_sync_commit matches mock SHA"

# Check sync_history entry has provenance
assert_json_field "$SYNC_JSON" "sync_history.0.source_commit_sha" "abc12345abc12345abc12345abc12345abc12345" "History entry has source_commit_sha"
assert_json_not_null "$SYNC_JSON" "sync_history.0.upstream_version" "History entry has upstream_version"
assert_json_not_null "$SYNC_JSON" "sync_history.0.sync_timestamp" "History entry has sync_timestamp"

# =============================================================================
echo -e "\n${CYAN}=== Test 12: Provenance -- sync_history keeps last 10 ===${NC}\n"
# AC: sync_history append entry (keep last 10)
# =============================================================================
# Run sync multiple times to build history
for i in $(seq 1 12); do
    bash "$MOCKED5" sync >/dev/null 2>&1 || true
done

history_count=$(node -e "
    const fs = require('fs');
    try {
        const data = JSON.parse(fs.readFileSync('$SYNC_JSON', 'utf8'));
        console.log((data.sync_history || []).length);
    } catch(e) { console.log(0); }
")

TOTAL=$((TOTAL + 1))
if [ "$history_count" -le 10 ]; then
    echo -e "  ${GREEN}PASS${NC} sync_history capped at 10 entries (got $history_count)"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} sync_history should be capped at 10 (got $history_count)"
    FAIL=$((FAIL + 1))
fi

# =============================================================================
echo -e "\n${CYAN}=== Test 13: Provenance -- timestamp is ISO 8601 ===${NC}\n"
# AC: sync timestamp in ISO 8601
# =============================================================================
timestamp=$(node -e "
    const fs = require('fs');
    try {
        const data = JSON.parse(fs.readFileSync('$SYNC_JSON', 'utf8'));
        console.log(data.last_sync_timestamp || '');
    } catch(e) { console.log(''); }
")

TOTAL=$((TOTAL + 1))
if echo "$timestamp" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$'; then
    echo -e "  ${GREEN}PASS${NC} last_sync_timestamp is ISO 8601 format ($timestamp)"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} last_sync_timestamp not ISO 8601 (got: $timestamp)"
    FAIL=$((FAIL + 1))
fi

# =============================================================================
echo -e "\n${CYAN}=== Test 14: run_preflight -- empty plan passes ===${NC}\n"
# Edge case: no files to sync should pass preflight
# =============================================================================
output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.claude/.harness-manifest.yml"
    EXCLUDE_FILE="$PROJ/.claude/.sync-exclude"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest

    if run_preflight "" "$PROJ/.claude" 2>&1; then
        echo "PREFLIGHT_RESULT: pass"
    else
        echo "PREFLIGHT_RESULT: fail"
    fi
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "PREFLIGHT_RESULT: pass" "Empty sync plan passes preflight"

# =============================================================================
echo -e "\n${CYAN}=== Test 15: run_preflight -- absolute path violation ===${NC}\n"
# AC: Scope check catches absolute paths
# =============================================================================
output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.claude/.harness-manifest.yml"
    EXCLUDE_FILE="$PROJ/.claude/.sync-exclude"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest

    mkdir -p "$TMP_DIR/.claude"

    sync_plan="new|/etc/shadow|/etc/shadow"
    if run_preflight "$sync_plan" "$PROJ/.claude" 2>&1; then
        echo "PREFLIGHT_RESULT: pass"
    else
        echo "PREFLIGHT_RESULT: fail"
    fi
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "PREFLIGHT_RESULT: fail" "Absolute path causes preflight failure"
assert_contains "$output" "Scope violation" "Scope violation for absolute path"

# =============================================================================
echo -e "\n${CYAN}=== Test 16: Help text includes --skip-preflight ===${NC}\n"
# AC: --skip-preflight documented in help
# =============================================================================
help_output=$(bash "$SYNC_SCRIPT" help 2>&1) || true

assert_contains "$help_output" "--skip-preflight" "Help text documents --skip-preflight flag"
assert_contains "$help_output" "PREFLIGHT" "Help text includes PREFLIGHT section"
assert_contains "$help_output" "PROVENANCE" "Help text includes PROVENANCE section"

# =============================================================================
echo -e "\n${CYAN}=== Test 17: run_preflight -- multiple violations reported ===${NC}\n"
# All three violation types at once should all be reported
# =============================================================================
output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.claude/.harness-manifest.yml"
    EXCLUDE_FILE="$PROJ/.claude/.sync-exclude"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest

    mkdir -p "$TMP_DIR/.claude"
    echo "# {{PROJECT_NAME}} token" > "$TMP_DIR/.claude/readme.md"

    # Plan with scope violation, protected violation, and token violation
    sync_plan="new|../escape.txt|../escape.txt
modified|CLAUDE.md|CLAUDE.md
new|readme.md|readme.md"
    if run_preflight "$sync_plan" "$PROJ/.claude" 2>&1; then
        echo "PREFLIGHT_RESULT: pass"
    else
        echo "PREFLIGHT_RESULT: fail"
    fi
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "PREFLIGHT_RESULT: fail" "Multiple violations cause failure"
assert_contains "$output" "Scope violation" "Scope violation reported in multi-violation"
assert_contains "$output" "Protected file violation" "Protected violation reported in multi-violation"
assert_contains "$output" "Unreplaced token violation" "Token violation reported in multi-violation"

# =============================================================================
echo -e "\n${CYAN}=== Test 18: Integration -- full sync with preflight pass ===${NC}\n"
# AC: End-to-end: sync with manifest, substitutions, and preflight all passing
# =============================================================================
PROJ6=$(setup_project "integration-pass")
create_manifest_with_subs "$PROJ6"
"$PROJ6/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

MOCK_DIR6="$TEST_DIR/mock-upstream-integration"
mkdir -p "$MOCK_DIR6/.claude/agents"
echo "# {{PROJECT_NAME}} agent" > "$MOCK_DIR6/.claude/agents/be-developer.md"
echo "# Plain file no tokens" > "$MOCK_DIR6/.claude/agents/readme.md"

MOCKED6=$(create_mocked_script "$PROJ6" "$MOCK_DIR6")

output=$(bash "$MOCKED6" sync 2>&1) || true
rc=$?

assert_contains "$output" "Preflight Safety Check" "Preflight ran during integration sync"
assert_contains "$output" "Preflight passed" "Preflight passed in integration"
assert_contains "$output" "Summary:" "Sync summary shown"
# Verify substitutions were applied (tokens replaced)
if [ -f "$PROJ6/.claude/agents/be-developer.md" ]; then
    assert_file_content "$PROJ6/.claude/agents/be-developer.md" "TestProject" "Substitution applied to synced file"
fi

# =============================================================================
# Summary
# =============================================================================
echo -e "\n${CYAN}=============================${NC}"
echo -e "${CYAN} Test Summary (SAW-2)${NC}"
echo -e "${CYAN}=============================${NC}"
echo -e " Total:  $TOTAL"
echo -e " Passed: ${GREEN}$PASS${NC}"
echo -e " Failed: ${RED}$FAIL${NC}"
echo ""

if [ "$FAIL" -gt 0 ]; then
    echo -e "${RED}SOME TESTS FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}ALL TESTS PASSED${NC}"
    exit 0
fi
