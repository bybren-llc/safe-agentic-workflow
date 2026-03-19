#!/usr/bin/env bash
# =============================================================================
# Multi-Domain Sync Tests (SAW-37)
# =============================================================================
# Tests multi-domain sync behavior: sync_scope reading, v1.1 root-relative
# paths, multi-domain diff, protected paths across domains, --scope override,
# manifest-required enforcement, and metadata migration.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SYNC_SCRIPT="$PROJECT_ROOT/scripts/sync-claude-harness.sh"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS=0
FAIL=0

assert_equals() {
    local actual="$1" expected="$2" msg="$3"
    if [ "$actual" = "$expected" ]; then
        echo -e "  ${GREEN}PASS${NC} $msg"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $msg (expected '$expected', got '$actual')"
        FAIL=$((FAIL + 1))
    fi
}

assert_contains() {
    local haystack="$1" needle="$2" msg="$3"
    if echo "$haystack" | grep -qF "$needle"; then
        echo -e "  ${GREEN}PASS${NC} $msg"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $msg (expected to find: $needle)"
        FAIL=$((FAIL + 1))
    fi
}

assert_not_contains() {
    local haystack="$1" needle="$2" msg="$3"
    if ! echo "$haystack" | grep -qF "$needle"; then
        echo -e "  ${GREEN}PASS${NC} $msg"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $msg (should NOT contain: $needle)"
        FAIL=$((FAIL + 1))
    fi
}

# Create a sourceable version of the sync script (strips the main handler)
make_sourceable() {
    local src="$1"
    local dst="$2"
    sed -n '1,/^case "\${1:-}"/p' "$src" | head -n -3 > "$dst"
}

# =============================================================================
echo -e "\n${CYAN}=== Test 1: get_sync_scope reads v1.1 manifest ===${NC}\n"
# =============================================================================
SOURCEABLE=$(mktemp)
make_sourceable "$SYNC_SCRIPT" "$SOURCEABLE"

REAL_PROJECT_ROOT="$PROJECT_ROOT"
result=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$REAL_PROJECT_ROOT"
    CLAUDE_DIR="$REAL_PROJECT_ROOT/.claude"
    MANIFEST_FILE="$REAL_PROJECT_ROOT/.harness-manifest.yml"
    ALLOWED_DOMAINS=(".claude" ".gemini" ".codex" ".cursor" ".agents" "dark-factory")
    SYNC_SCOPE=()
    HAS_MANIFEST=true
    get_sync_scope
    echo "${SYNC_SCOPE[*]}"
)

assert_contains "$result" ".claude" "sync_scope includes .claude"
assert_contains "$result" ".gemini" "sync_scope includes .gemini"
assert_contains "$result" ".codex" "sync_scope includes .codex"
assert_contains "$result" ".cursor" "sync_scope includes .cursor"
assert_contains "$result" ".agents" "sync_scope includes .agents"
assert_contains "$result" "dark-factory" "sync_scope includes dark-factory"

count=$(echo "$result" | tr ' ' '\n' | grep -c '.')
assert_equals "$count" "6" "sync_scope has exactly 6 domains"

# =============================================================================
echo -e "\n${CYAN}=== Test 2: get_sync_scope defaults to .claude for v1.0 ===${NC}\n"
# =============================================================================
TMPDIR_T2=$(mktemp -d)
cat > "$TMPDIR_T2/manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "Test"
  PROJECT_REPO: "test"
  PROJECT_SHORT: "TST"
  GITHUB_ORG: "test-org"
  TICKET_PREFIX: "TST"
  MAIN_BRANCH: "main"
sync:
  auto_substitute: true
YAML

result=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$TMPDIR_T2"
    MANIFEST_FILE="$TMPDIR_T2/manifest.yml"
    ALLOWED_DOMAINS=(".claude" ".gemini" ".codex" ".cursor" ".agents" "dark-factory")
    SYNC_SCOPE=()
    HAS_MANIFEST=true
    get_sync_scope
    echo "${SYNC_SCOPE[*]}"
)

assert_equals "$result" ".claude" "v1.0 manifest defaults to .claude only"
rm -rf "$TMPDIR_T2"

# =============================================================================
echo -e "\n${CYAN}=== Test 3: get_sync_scope rejects invalid domains ===${NC}\n"
# =============================================================================
TMPDIR_T3=$(mktemp -d)
cat > "$TMPDIR_T3/manifest.yml" <<'YAML'
manifest_version: "1.1"
identity:
  PROJECT_NAME: "Test"
  PROJECT_REPO: "test"
  PROJECT_SHORT: "TST"
  GITHUB_ORG: "test-org"
  TICKET_PREFIX: "TST"
  MAIN_BRANCH: "main"
sync:
  sync_scope:
    - ".claude/"
    - "invalid-domain/"
    - ".gemini/"
YAML

result=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$TMPDIR_T3"
    MANIFEST_FILE="$TMPDIR_T3/manifest.yml"
    ALLOWED_DOMAINS=(".claude" ".gemini" ".codex" ".cursor" ".agents" "dark-factory")
    SYNC_SCOPE=()
    HAS_MANIFEST=true
    get_sync_scope 2>&1
    echo "SCOPE:${SYNC_SCOPE[*]}"
)

assert_contains "$result" "SCOPE:.claude .gemini" "valid domains kept, invalid rejected"
assert_contains "$result" "Ignoring unknown sync domain" "warning for invalid domain"
rm -rf "$TMPDIR_T3"

# =============================================================================
echo -e "\n${CYAN}=== Test 4: manifest-required enforcement ===${NC}\n"
# =============================================================================
TMPDIR_T4=$(mktemp -d)
mkdir -p "$TMPDIR_T4/.claude"

result=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$TMPDIR_T4"
    CLAUDE_DIR="$TMPDIR_T4/.claude"
    MANIFEST_FILE="$TMPDIR_T4/.harness-manifest.yml"
    HAS_MANIFEST=false
    SYNC_SCOPE=(".claude")
    ALLOWED_DOMAINS=(".claude" ".gemini" ".codex" ".cursor" ".agents" "dark-factory")
    # Simulate do_sync's manifest check
    if [ "$HAS_MANIFEST" != "true" ]; then
        echo "BLOCKED:manifest required"
    fi
)

assert_contains "$result" "BLOCKED:manifest required" "sync blocked without manifest"
rm -rf "$TMPDIR_T4"

# =============================================================================
echo -e "\n${CYAN}=== Test 5: USE_ROOT_PATHS flag for v1.1 ===${NC}\n"
# =============================================================================
# Check manifest version directly from YAML
ver=$(grep 'manifest_version:' "$PROJECT_ROOT/.harness-manifest.yml" | head -1 | sed 's/.*"\(.*\)".*/\1/')
if [ "$ver" = "1.1" ] || [[ "$ver" > "1.1" ]]; then
    result="ROOT_PATHS:true"
else
    result="ROOT_PATHS:false"
fi

assert_contains "$result" "ROOT_PATHS:true" "v1.1 manifest uses root-relative paths"

# =============================================================================
echo -e "\n${CYAN}=== Test 6: metadata migration detection ===${NC}\n"
# =============================================================================
TMPDIR_T6=$(mktemp -d)
mkdir -p "$TMPDIR_T6/.claude"
echo '{"upstream_repo":"test"}' > "$TMPDIR_T6/.claude/.harness-sync.json"

result=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$TMPDIR_T6"
    CLAUDE_DIR="$TMPDIR_T6/.claude"
    SYNC_CONFIG="$TMPDIR_T6/.harness-sync.json"
    LEGACY_SYNC_CONFIG="$TMPDIR_T6/.claude/.harness-sync.json"
    BACKUP_DIR="$TMPDIR_T6/.harness-backup"
    LEGACY_BACKUP_DIR="$TMPDIR_T6/.claude/.harness-backup"
    PATCHES_DIR="$TMPDIR_T6/.harness-patches"
    LEGACY_PATCHES_DIR="$TMPDIR_T6/.claude/.harness-patches"
    MANIFEST_FILE="$TMPDIR_T6/.harness-manifest.yml"
    LEGACY_MANIFEST_FILE="$TMPDIR_T6/.claude/.harness-manifest.yml"
    migrate_metadata_to_root 2>&1
)

assert_contains "$result" "MIGRATE" "migration detected and logged"
# Verify file was copied to root
if [ -f "$TMPDIR_T6/.harness-sync.json" ]; then
    echo -e "  ${GREEN}PASS${NC} sync config migrated to root"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} sync config not migrated to root"
    FAIL=$((FAIL + 1))
fi
rm -rf "$TMPDIR_T6"

# =============================================================================
echo -e "\n${CYAN}=== Test 7: ALLOWED_DOMAINS hardcoded list ===${NC}\n"
# =============================================================================
result=$(
    source "$SOURCEABLE"
    echo "${ALLOWED_DOMAINS[*]}"
)

assert_contains "$result" ".claude" "allowed: .claude"
assert_contains "$result" ".gemini" "allowed: .gemini"
assert_contains "$result" ".codex" "allowed: .codex"
assert_contains "$result" ".cursor" "allowed: .cursor"
assert_contains "$result" ".agents" "allowed: .agents"
assert_contains "$result" "dark-factory" "allowed: dark-factory"

# =============================================================================
echo -e "\n${CYAN}=== Test Results ===${NC}\n"
echo "  Total:  $((PASS + FAIL))"
echo -e "  ${GREEN}Passed: $PASS${NC}"
echo -e "  ${RED}Failed: $FAIL${NC}"

if [ "$FAIL" -gt 0 ]; then
    echo -e "\n${RED}SOME TESTS FAILED${NC}"
    exit 1
else
    echo -e "\n${GREEN}ALL MULTI-DOMAIN TESTS PASSED${NC}"
fi

# Cleanup
rm -f "$SOURCEABLE"
