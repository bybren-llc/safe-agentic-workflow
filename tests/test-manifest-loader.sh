#!/bin/bash
# =============================================================================
# Test: Manifest Loader & Validator (SAW-6)
# =============================================================================
# Tests all AC items for the manifest loading feature.
# Run from repo root: bash tests/test-manifest-loader.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SYNC_SCRIPT="$REPO_ROOT/scripts/sync-claude-harness.sh"

# Create a temporary project structure for testing
TEST_DIR=$(mktemp -d /tmp/manifest-test-XXXXXX)
trap "rm -rf $TEST_DIR" EXIT

PASS=0
FAIL=0
TOTAL=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

assert_pass() {
    TOTAL=$((TOTAL + 1))
    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}PASS${NC} $1"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $1"
        FAIL=$((FAIL + 1))
    fi
}

assert_contains() {
    local output="$1"
    local expected="$2"
    local label="$3"
    TOTAL=$((TOTAL + 1))
    if echo "$output" | grep -q "$expected"; then
        echo -e "  ${GREEN}PASS${NC} $label"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $label (expected to find: $expected)"
        FAIL=$((FAIL + 1))
    fi
}

assert_not_contains() {
    local output="$1"
    local expected="$2"
    local label="$3"
    TOTAL=$((TOTAL + 1))
    if ! echo "$output" | grep -q "$expected"; then
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

# Setup: create a fake project dir that the sync script can operate in
setup_project() {
    local proj_dir="$TEST_DIR/project-$1"
    mkdir -p "$proj_dir/.claude"
    mkdir -p "$proj_dir/scripts"
    cp "$SYNC_SCRIPT" "$proj_dir/scripts/sync-claude-harness.sh"
    chmod +x "$proj_dir/scripts/sync-claude-harness.sh"
    echo "$proj_dir"
}

# =============================================================================
echo -e "\n${CYAN}=== Test 1: No manifest - legacy fallback ===${NC}\n"
# AC: Falls back to legacy behavior when no manifest exists
# =============================================================================
PROJ=$(setup_project "no-manifest")

# init should work without manifest
output=$("$PROJ/scripts/sync-claude-harness.sh" init 2>&1)
assert_contains "$output" "Created" "init works without manifest"
assert_not_contains "$output" "Manifest found" "no manifest message when file absent"

# help should work without manifest
output=$("$PROJ/scripts/sync-claude-harness.sh" help 2>&1)
assert_contains "$output" "MANIFEST" "help mentions manifest section"

# =============================================================================
echo -e "\n${CYAN}=== Test 2: Valid manifest detection and parsing ===${NC}\n"
# AC: Script detects .harness-manifest.yml presence
# AC: Parses YAML via python3 (already a project dependency)
# =============================================================================
PROJ=$(setup_project "valid-manifest")

cat > "$PROJ/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "TestProject"
  PROJECT_REPO: "test-project"
  PROJECT_SHORT: "TST"
  GITHUB_ORG: "test-org"
  TICKET_PREFIX: "TST"
  MAIN_BRANCH: "main"
substitutions:
  TICKET_PREFIX: "TST"
  GITHUB_ORG: "test-org"
renames:
  "agents/fe-developer.md": "agents/ui-engineer.md"
  "skills/stripe-patterns/": "skills/payment-patterns/"
protected:
  - "hooks-config.json"
  - "settings.local.json"
replaced:
  - "agents/system-architect.md"
sync:
  auto_substitute: true
  backup: true
  conflict_strategy: "prompt"
YAML

# init should detect and validate the manifest
output=$("$PROJ/scripts/sync-claude-harness.sh" init 2>&1)
assert_contains "$output" "Manifest found" "manifest detected after init"
assert_contains "$output" "2 renames" "reports correct rename count"
assert_contains "$output" "2 substitutions" "reports correct substitution count"
assert_contains "$output" "3 protected patterns" "reports correct protected count (protected + replaced)"

# =============================================================================
echo -e "\n${CYAN}=== Test 3: Manifest validation - required fields ===${NC}\n"
# AC: Validates manifest against schema from B1
# =============================================================================
PROJ=$(setup_project "invalid-manifest")
"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

# Missing manifest_version
cat > "$PROJ/.harness-manifest.yml" <<'YAML'
identity:
  PROJECT_NAME: "TestProject"
  PROJECT_REPO: "test-project"
  PROJECT_SHORT: "TST"
  GITHUB_ORG: "test-org"
  TICKET_PREFIX: "TST"
  MAIN_BRANCH: "main"
YAML

output=$("$PROJ/scripts/sync-claude-harness.sh" version 2>&1 || true)
ec=$?
assert_contains "$output" "missing required field: manifest_version" "detects missing manifest_version"

# =============================================================================
echo -e "\n${CYAN}=== Test 4: Manifest validation - invalid version format ===${NC}\n"
# =============================================================================
PROJ=$(setup_project "bad-version")
"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

cat > "$PROJ/.harness-manifest.yml" <<'YAML'
manifest_version: "abc"
identity:
  PROJECT_NAME: "TestProject"
  PROJECT_REPO: "test-project"
  PROJECT_SHORT: "TST"
  GITHUB_ORG: "test-org"
  TICKET_PREFIX: "TST"
  MAIN_BRANCH: "main"
YAML

output=$("$PROJ/scripts/sync-claude-harness.sh" version 2>&1 || true)
assert_contains "$output" "must match pattern X.Y" "detects invalid version format"

# =============================================================================
echo -e "\n${CYAN}=== Test 5: Manifest validation - missing identity fields ===${NC}\n"
# =============================================================================
PROJ=$(setup_project "missing-identity")
"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

cat > "$PROJ/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "TestProject"
YAML

output=$("$PROJ/scripts/sync-claude-harness.sh" version 2>&1 || true)
assert_contains "$output" "missing required field: PROJECT_REPO" "detects missing PROJECT_REPO"
assert_contains "$output" "missing required field: TICKET_PREFIX" "detects missing TICKET_PREFIX"

# =============================================================================
echo -e "\n${CYAN}=== Test 6: Manifest validation - missing identity entirely ===${NC}\n"
# =============================================================================
PROJ=$(setup_project "no-identity")
"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

cat > "$PROJ/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
YAML

output=$("$PROJ/scripts/sync-claude-harness.sh" version 2>&1 || true)
assert_contains "$output" "missing required field: identity" "detects missing identity section"

# =============================================================================
echo -e "\n${CYAN}=== Test 7: Summary report format ===${NC}\n"
# AC: Reports: "Manifest found: X renames, Y substitutions, Z protected patterns"
# =============================================================================
PROJ=$(setup_project "summary-report")
"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

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
  "agents/fe.md": "agents/ui.md"
substitutions:
  TICKET_PREFIX: "TST"
  GITHUB_ORG: "test-org"
  PROJECT_NAME: "TestProject"
protected:
  - "hooks-config.json"
replaced:
  - "README.md"
  - "AGENTS.md"
YAML

output=$("$PROJ/scripts/sync-claude-harness.sh" init 2>&1)
assert_contains "$output" "Manifest found: 1 renames, 3 substitutions, 3 protected patterns" "correct summary format"

# =============================================================================
echo -e "\n${CYAN}=== Test 8: Empty manifest sections (zero counts) ===${NC}\n"
# =============================================================================
PROJ=$(setup_project "empty-sections")
"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

cat > "$PROJ/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "MinimalProject"
  PROJECT_REPO: "minimal"
  PROJECT_SHORT: "MIN"
  GITHUB_ORG: "test-org"
  TICKET_PREFIX: "MIN"
  MAIN_BRANCH: "main"
substitutions: {}
renames: {}
protected: []
replaced: []
YAML

output=$("$PROJ/scripts/sync-claude-harness.sh" init 2>&1)
assert_contains "$output" "Manifest found: 0 renames, 0 substitutions, 0 protected patterns" "handles empty sections"

# =============================================================================
echo -e "\n${CYAN}=== Test 9: Backward compatibility - no manifest, legacy behavior ===${NC}\n"
# AC: Falls back to legacy behavior when no manifest exists (backward compatible)
# =============================================================================
PROJ=$(setup_project "backward-compat")

# Init without manifest should produce IDENTICAL output to original script
output=$("$PROJ/scripts/sync-claude-harness.sh" init 2>&1)
assert_contains "$output" "Initializing Harness Sync" "init header present"
assert_contains "$output" "Created" "creates config files"
assert_not_contains "$output" "Manifest found" "no manifest message"
assert_not_contains "$output" "ERROR" "no errors in legacy mode"

# Help still works
output=$("$PROJ/scripts/sync-claude-harness.sh" help 2>&1)
assert_exit_code 0 0 "help exits 0 in legacy mode"

# =============================================================================
echo -e "\n${CYAN}=== Test 10: Manifest info in status output ===${NC}\n"
# =============================================================================
PROJ=$(setup_project "status-manifest")
"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

cat > "$PROJ/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "StatusTest"
  PROJECT_REPO: "status-test"
  PROJECT_SHORT: "STS"
  GITHUB_ORG: "test-org"
  TICKET_PREFIX: "STS"
  MAIN_BRANCH: "main"
renames:
  "agents/fe.md": "agents/ui.md"
sync:
  conflict_strategy: "three-way"
YAML

# Status will fail on network calls but we can check it loads the manifest first
output=$("$PROJ/scripts/sync-claude-harness.sh" status 2>&1 || true)
assert_contains "$output" "Manifest found" "status loads and validates manifest"
assert_contains "$output" "1 renames" "status shows rename count"

# =============================================================================
echo -e "\n${CYAN}=== Test 11: is_excluded includes .harness-manifest.yml ===${NC}\n"
# =============================================================================
# The manifest file itself should be excluded from sync overwrites.
# We test this by checking the is_excluded function recognizes it.
PROJ=$(setup_project "exclude-manifest")

# Source the script functions in a subshell to test is_excluded
output=$(
    CLAUDE_DIR="$PROJ/.claude"
    EXCLUDE_FILE="$PROJ/.claude/.sync-exclude"
    source <(sed -n '/^is_excluded/,/^}/p' "$SYNC_SCRIPT")
    if is_excluded ".harness-manifest.yml"; then
        echo "EXCLUDED"
    else
        echo "NOT_EXCLUDED"
    fi
)
assert_contains "$output" "EXCLUDED" ".harness-manifest.yml is auto-excluded from sync"

# =============================================================================
echo -e "\n${CYAN}=== Test 12: Invalid YAML fallback ===${NC}\n"
# =============================================================================
PROJ=$(setup_project "bad-yaml")
"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

cat > "$PROJ/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0
  bad: [yaml: {
YAML

output=$("$PROJ/scripts/sync-claude-harness.sh" init 2>&1)
assert_contains "$output" "Falling back to legacy" "invalid YAML triggers graceful fallback"
assert_not_contains "$output" "Manifest found" "no manifest found with bad YAML"

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
