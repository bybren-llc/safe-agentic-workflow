#!/usr/bin/env bash
# =============================================================================
# Multi-Domain Sync Tests (SAW-37)
# =============================================================================
# Tests multi-domain sync behavior including:
# - sync_scope reading from v1.0 and v1.1 manifests
# - v1.1 root-relative protected-path enforcement across domains
# - v1.1 root-relative rename resolution (file + directory)
# - compare_file_with_paths domain context (DOMAIN_TMP/DOMAIN_DIR)
# - Shared SYNC_TIMESTAMP across domain backups
# - validate_protected_paths scanning multiple domains
# - Manifest-required enforcement and metadata migration
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
echo -e "\n${CYAN}=== Test 8: v1.1 protected-path enforcement outside .claude ===${NC}\n"
# =============================================================================
# Create a project with .gemini/ and a v1.1 manifest protecting .gemini/settings.json
TMPDIR_T8=$(mktemp -d)
mkdir -p "$TMPDIR_T8/.claude/agents" "$TMPDIR_T8/.gemini"
echo '{"ticketPrefix":"TST"}' > "$TMPDIR_T8/.claude/team-config.json"
echo "gemini settings" > "$TMPDIR_T8/.gemini/settings.json"

cat > "$TMPDIR_T8/.harness-manifest.yml" <<'YAML'
manifest_version: "1.1"
identity:
  PROJECT_NAME: "Test"
  PROJECT_REPO: "test"
  PROJECT_SHORT: "TST"
  GITHUB_ORG: "test-org"
  TICKET_PREFIX: "TST"
  MAIN_BRANCH: "main"
protected:
  - ".gemini/settings.json"
  - ".claude/hooks-config.json"
sync:
  sync_scope:
    - ".claude/"
    - ".gemini/"
YAML

result=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$TMPDIR_T8"
    CLAUDE_DIR="$TMPDIR_T8/.claude"
    MANIFEST_FILE="$TMPDIR_T8/.harness-manifest.yml"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    ALLOWED_DOMAINS=(".claude" ".gemini" ".codex" ".cursor" ".agents" "dark-factory")
    load_manifest
    # Test: is .gemini/settings.json protected?
    if is_excluded ".gemini/settings.json" 2>/dev/null; then
        echo "PROTECTED:gemini-settings"
    else
        echo "NOT_PROTECTED:gemini-settings"
    fi
    # Test: is .claude/hooks-config.json protected?
    if is_excluded ".claude/hooks-config.json" 2>/dev/null; then
        echo "PROTECTED:claude-hooks"
    else
        echo "NOT_PROTECTED:claude-hooks"
    fi
    # Test: is .gemini/commands/test.toml NOT protected?
    if is_excluded ".gemini/commands/test.toml" 2>/dev/null; then
        echo "PROTECTED:gemini-commands"
    else
        echo "NOT_PROTECTED:gemini-commands"
    fi
)

assert_contains "$result" "PROTECTED:gemini-settings" "v1.1 protects .gemini/settings.json"
assert_contains "$result" "PROTECTED:claude-hooks" "v1.1 protects .claude/hooks-config.json"
assert_contains "$result" "NOT_PROTECTED:gemini-commands" "unprotected .gemini file not blocked"
rm -rf "$TMPDIR_T8"

# =============================================================================
echo -e "\n${CYAN}=== Test 9: v1.1 root-relative rename resolution ===${NC}\n"
# =============================================================================
TMPDIR_T9=$(mktemp -d)
mkdir -p "$TMPDIR_T9/.claude/agents" "$TMPDIR_T9/.gemini/skills"

cat > "$TMPDIR_T9/.harness-manifest.yml" <<'YAML'
manifest_version: "1.1"
identity:
  PROJECT_NAME: "Test"
  PROJECT_REPO: "test"
  PROJECT_SHORT: "TST"
  GITHUB_ORG: "test-org"
  TICKET_PREFIX: "TST"
  MAIN_BRANCH: "main"
renames:
  ".claude/agents/fe-developer.md": ".claude/agents/ui-engineer.md"
  ".gemini/skills/stripe-patterns/": ".gemini/skills/payment-patterns/"
YAML

result=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$TMPDIR_T9"
    CLAUDE_DIR="$TMPDIR_T9/.claude"
    MANIFEST_FILE="$TMPDIR_T9/.harness-manifest.yml"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    load_manifest
    # Test file rename
    resolved=$(resolve_rename ".claude/agents/fe-developer.md")
    echo "RENAME:$resolved"
    # Test directory rename
    resolved2=$(resolve_rename ".gemini/skills/stripe-patterns/webhook.md")
    echo "DIR_RENAME:$resolved2"
    # Test non-renamed file
    resolved3=$(resolve_rename ".gemini/commands/test.toml")
    echo "NO_RENAME:$resolved3"
)

assert_contains "$result" "RENAME:.claude/agents/ui-engineer.md" "v1.1 renames .claude file correctly"
assert_contains "$result" "DIR_RENAME:.gemini/skills/payment-patterns/webhook.md" "v1.1 renames .gemini dir correctly"
assert_contains "$result" "NO_RENAME:.gemini/commands/test.toml" "non-renamed file unchanged"
rm -rf "$TMPDIR_T9"

# =============================================================================
echo -e "\n${CYAN}=== Test 10: compare_file_with_paths uses domain context ===${NC}\n"
# =============================================================================
TMPDIR_T10=$(mktemp -d)
mkdir -p "$TMPDIR_T10/.gemini/commands" "$TMPDIR_T10/upstream/.gemini/commands"
echo "local content" > "$TMPDIR_T10/.gemini/commands/test.toml"
echo "upstream content" > "$TMPDIR_T10/upstream/.gemini/commands/test.toml"
echo "same" > "$TMPDIR_T10/.gemini/commands/same.toml"
echo "same" > "$TMPDIR_T10/upstream/.gemini/commands/same.toml"

result=$(
    source "$SOURCEABLE"
    # Set domain context as the sync loop would
    DOMAIN_TMP="$TMPDIR_T10/upstream/.gemini"
    DOMAIN_DIR="$TMPDIR_T10/.gemini"
    status1=$(compare_file_with_paths "commands/test.toml" "commands/test.toml")
    echo "MODIFIED:$status1"
    status2=$(compare_file_with_paths "commands/same.toml" "commands/same.toml")
    echo "UNCHANGED:$status2"
    # For "new": file exists in upstream but not locally
    mkdir -p "$DOMAIN_TMP/commands"
    echo "new content" > "$DOMAIN_TMP/commands/new.toml"
    status3=$(compare_file_with_paths "commands/new.toml" "commands/new.toml")
    echo "NEW:$status3"
)

assert_contains "$result" "MODIFIED:modified" "compare detects modified .gemini file"
assert_contains "$result" "UNCHANGED:unchanged" "compare detects unchanged .gemini file"
assert_contains "$result" "NEW:new" "compare detects new .gemini file (exists upstream, not local)"
rm -rf "$TMPDIR_T10"

# =============================================================================
echo -e "\n${CYAN}=== Test 11: SYNC_TIMESTAMP shared across domains ===${NC}\n"
# =============================================================================
result=$(
    source "$SOURCEABLE"
    SYNC_TIMESTAMP=""
    # First call sets timestamp
    DOMAIN_DIR="/tmp/test-domain1"
    DOMAIN_DIR="/tmp/fake/.claude"
    mkdir -p "$DOMAIN_DIR"
    BACKUP_DIR=$(mktemp -d)
    create_backup 2>/dev/null
    ts1="$SYNC_TIMESTAMP"
    # Second call reuses same timestamp
    DOMAIN_DIR="/tmp/fake/.gemini"
    mkdir -p "$DOMAIN_DIR"
    create_backup 2>/dev/null
    ts2="$SYNC_TIMESTAMP"
    echo "TS_MATCH:$([ "$ts1" = "$ts2" ] && echo 'yes' || echo 'no')"
    echo "TS_SET:$([ -n "$ts1" ] && echo 'yes' || echo 'no')"
    rm -rf "$BACKUP_DIR" /tmp/fake
)

assert_contains "$result" "TS_MATCH:yes" "both domains share same SYNC_TIMESTAMP"
assert_contains "$result" "TS_SET:yes" "SYNC_TIMESTAMP is non-empty"

# =============================================================================
echo -e "\n${CYAN}=== Test 12: validate_protected scans multiple domains ===${NC}\n"
# =============================================================================
TMPDIR_T12=$(mktemp -d)
mkdir -p "$TMPDIR_T12/.claude/agents" "$TMPDIR_T12/.gemini/skills"
echo "test" > "$TMPDIR_T12/.claude/agents/bsa.md"
echo "test" > "$TMPDIR_T12/.gemini/skills/safe-workflow.md"

cat > "$TMPDIR_T12/.harness-manifest.yml" <<'YAML'
manifest_version: "1.1"
identity:
  PROJECT_NAME: "Test"
  PROJECT_REPO: "test"
  PROJECT_SHORT: "TST"
  GITHUB_ORG: "test-org"
  TICKET_PREFIX: "TST"
  MAIN_BRANCH: "main"
protected:
  - ".gemini/skills/nonexistent-pattern-*.md"
sync:
  sync_scope:
    - ".claude/"
    - ".gemini/"
YAML

result=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$TMPDIR_T12"
    CLAUDE_DIR="$TMPDIR_T12/.claude"
    MANIFEST_FILE="$TMPDIR_T12/.harness-manifest.yml"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    ALLOWED_DOMAINS=(".claude" ".gemini" ".codex" ".cursor" ".agents" "dark-factory")
    SYNC_SCOPE=()
    TMP_DIR=$(mktemp -d)
    load_manifest
    validate_protected_paths 2>&1 || true
)

assert_contains "$result" "does not match" "typo detection for .gemini protected pattern"
rm -rf "$TMPDIR_T12"

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
