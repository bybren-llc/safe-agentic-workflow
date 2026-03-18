#!/bin/bash
# =============================================================================
# Test: Protected File Enforcement (SAW-3)
# =============================================================================
# Tests all AC items for the protected file enforcement feature.
# Run from repo root: bash tests/test-protected-files.sh
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
TEST_DIR=$(mktemp -d /tmp/protected-files-test-XXXXXX)
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
    if echo "$output" | strip_ansi | grep -qF "$expected"; then
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
    if ! echo "$output" | strip_ansi | grep -qF "$expected"; then
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

# Create a valid manifest with protected entries
create_manifest_with_protected() {
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
protected:
  - "CLAUDE.md"
  - "settings.local.json"
  - "hooks-config.json"
  - "agents/custom-*.md"
YAML
}

# =============================================================================
echo -e "\n${CYAN}=== Test 1: is_protected -- manifest protected patterns ===${NC}\n"
# AC: Manifest protected section prevents listed files from being modified
# =============================================================================
PROJ=$(setup_project "is-protected")
create_manifest_with_protected "$PROJ"
"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1
SOURCEABLE=$(create_sourceable_script "$PROJ")

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

    if is_protected "CLAUDE.md"; then echo "PROTECTED_CLAUDE: yes"; else echo "PROTECTED_CLAUDE: no"; fi
    if is_protected "settings.local.json"; then echo "PROTECTED_SETTINGS: yes"; else echo "PROTECTED_SETTINGS: no"; fi
    if is_protected "hooks-config.json"; then echo "PROTECTED_HOOKS: yes"; else echo "PROTECTED_HOOKS: no"; fi
    if is_protected "agents/system-architect.md"; then echo "PROTECTED_SYSARCH: yes"; else echo "PROTECTED_SYSARCH: no"; fi
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "PROTECTED_CLAUDE: yes" "CLAUDE.md is protected by manifest"
assert_contains "$output" "PROTECTED_SETTINGS: yes" "settings.local.json is protected by manifest"
assert_contains "$output" "PROTECTED_HOOKS: yes" "hooks-config.json is protected by manifest"
assert_contains "$output" "PROTECTED_SYSARCH: no" "agents/system-architect.md is NOT protected"

# =============================================================================
echo -e "\n${CYAN}=== Test 2: is_protected -- glob patterns ===${NC}\n"
# AC: Glob patterns supported in protected section
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

    if is_protected "agents/custom-agent.md"; then echo "GLOB_MATCH: yes"; else echo "GLOB_MATCH: no"; fi
    if is_protected "agents/custom-devops.md"; then echo "GLOB_MATCH2: yes"; else echo "GLOB_MATCH2: no"; fi
    if is_protected "agents/fe-developer.md"; then echo "GLOB_NOMATCH: yes"; else echo "GLOB_NOMATCH: no"; fi
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "GLOB_MATCH: yes" "glob agents/custom-*.md matches agents/custom-agent.md"
assert_contains "$output" "GLOB_MATCH2: yes" "glob agents/custom-*.md matches agents/custom-devops.md"
assert_contains "$output" "GLOB_NOMATCH: no" "glob agents/custom-*.md does NOT match agents/fe-developer.md"

# =============================================================================
echo -e "\n${CYAN}=== Test 3: is_excluded delegates to is_protected with manifest ===${NC}\n"
# AC: Manifest protected section prevents listed files from being modified
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

    if is_excluded "CLAUDE.md"; then echo "EXCLUDED_CLAUDE: yes"; else echo "EXCLUDED_CLAUDE: no"; fi
    if is_excluded "agents/system-architect.md"; then echo "EXCLUDED_SYSARCH: yes"; else echo "EXCLUDED_SYSARCH: no"; fi
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "EXCLUDED_CLAUDE: yes" "is_excluded returns true for manifest-protected CLAUDE.md"
assert_contains "$output" "EXCLUDED_SYSARCH: no" "is_excluded returns false for non-protected file"

# =============================================================================
echo -e "\n${CYAN}=== Test 4: .sync-exclude fallback (no manifest) ===${NC}\n"
# AC: .sync-exclude still works as fallback (backward compatible)
# =============================================================================
PROJ2=$(setup_project "sync-exclude-fallback")
"$PROJ2/scripts/sync-claude-harness.sh" init >/dev/null 2>&1
# No manifest, but .sync-exclude has entries
cat > "$PROJ2/.claude/.sync-exclude" <<'EOF'
# Exclude these
settings.local.json
hooks-config.json
EOF

SOURCEABLE2=$(create_sourceable_script "$PROJ2")

output=$(
    source "$SOURCEABLE2"
    PROJECT_ROOT="$PROJ2"
    CLAUDE_DIR="$PROJ2/.claude"
    MANIFEST_FILE="$PROJ2/.claude/.harness-manifest.yml"
    EXCLUDE_FILE="$PROJ2/.claude/.sync-exclude"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    # Do NOT load manifest -- it doesn't exist

    if is_excluded "settings.local.json"; then echo "LEGACY_EXCL: yes"; else echo "LEGACY_EXCL: no"; fi
    if is_excluded "hooks-config.json"; then echo "LEGACY_EXCL2: yes"; else echo "LEGACY_EXCL2: no"; fi
    if is_excluded "agents/fe-developer.md"; then echo "LEGACY_NOEXCL: yes"; else echo "LEGACY_NOEXCL: no"; fi
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "LEGACY_EXCL: yes" ".sync-exclude still works: settings.local.json excluded"
assert_contains "$output" "LEGACY_EXCL2: yes" ".sync-exclude still works: hooks-config.json excluded"
assert_contains "$output" "LEGACY_NOEXCL: no" ".sync-exclude: non-listed file not excluded"

# =============================================================================
echo -e "\n${CYAN}=== Test 5: Manifest + .sync-exclude merged ===${NC}\n"
# AC: If both exist, manifest takes precedence + entries merged
# =============================================================================
PROJ3=$(setup_project "merged-patterns")
create_manifest_with_protected "$PROJ3"
"$PROJ3/scripts/sync-claude-harness.sh" init >/dev/null 2>&1
# Add extra pattern only in .sync-exclude
cat > "$PROJ3/.claude/.sync-exclude" <<'EOF'
# Extra exclude
settings.local.json
my-custom-file.txt
EOF

SOURCEABLE3=$(create_sourceable_script "$PROJ3")

output=$(
    source "$SOURCEABLE3"
    PROJECT_ROOT="$PROJ3"
    CLAUDE_DIR="$PROJ3/.claude"
    MANIFEST_FILE="$PROJ3/.claude/.harness-manifest.yml"
    EXCLUDE_FILE="$PROJ3/.claude/.sync-exclude"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest

    # CLAUDE.md is only in manifest protected
    if is_protected "CLAUDE.md"; then echo "MERGED_MANIFEST: yes"; else echo "MERGED_MANIFEST: no"; fi
    # my-custom-file.txt is only in .sync-exclude
    if is_protected "my-custom-file.txt"; then echo "MERGED_SYNCEXCL: yes"; else echo "MERGED_SYNCEXCL: no"; fi
    # settings.local.json is in BOTH
    if is_protected "settings.local.json"; then echo "MERGED_BOTH: yes"; else echo "MERGED_BOTH: no"; fi
    # Something not in either
    if is_protected "agents/new-file.md"; then echo "MERGED_NONE: yes"; else echo "MERGED_NONE: no"; fi
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "MERGED_MANIFEST: yes" "manifest-only pattern works in merged set"
assert_contains "$output" "MERGED_SYNCEXCL: yes" ".sync-exclude-only pattern works in merged set"
assert_contains "$output" "MERGED_BOTH: yes" "pattern in both sources works"
assert_contains "$output" "MERGED_NONE: no" "pattern in neither source returns false"

# =============================================================================
echo -e "\n${CYAN}=== Test 6: get_protected_patterns -- de-duplication ===${NC}\n"
# AC: Entries are merged (manifest precedence, no duplicates)
# =============================================================================
output=$(
    source "$SOURCEABLE3"
    PROJECT_ROOT="$PROJ3"
    CLAUDE_DIR="$PROJ3/.claude"
    MANIFEST_FILE="$PROJ3/.claude/.harness-manifest.yml"
    EXCLUDE_FILE="$PROJ3/.claude/.sync-exclude"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest

    # Count how many times settings.local.json appears (should be once)
    count=$(get_protected_patterns | grep -cF "settings.local.json")
    echo "DEDUP_COUNT: $count"
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "DEDUP_COUNT: 1" "settings.local.json appears exactly once in merged patterns (de-duplicated)"

# =============================================================================
echo -e "\n${CYAN}=== Test 7: do_diff -- PROTECTED label for manifest-protected files ===${NC}\n"
# AC: sync diff shows PROTECTED CLAUDE.md (upstream has changes, skipping per manifest)
# =============================================================================
PROJ4=$(setup_project "diff-protected")
create_manifest_with_protected "$PROJ4"
"$PROJ4/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

# Create local files
mkdir -p "$PROJ4/.claude/agents"
echo "# My Custom CLAUDE.md" > "$PROJ4/.claude/CLAUDE.md"
echo "# My Settings" > "$PROJ4/.claude/settings.local.json"
echo "# Agent file" > "$PROJ4/.claude/agents/system-architect.md"
echo "# Custom agent" > "$PROJ4/.claude/agents/custom-agent.md"

# Create mock upstream with changes
MOCK_UP4="$TEST_DIR/mock-upstream-diff-prot"
mkdir -p "$MOCK_UP4/.claude/agents"
echo "# UPSTREAM CLAUDE.md - different content" > "$MOCK_UP4/.claude/CLAUDE.md"
echo "# UPSTREAM Settings - different" > "$MOCK_UP4/.claude/settings.local.json"
echo "# UPSTREAM Agent" > "$MOCK_UP4/.claude/agents/system-architect.md"
echo "# UPSTREAM Custom" > "$MOCK_UP4/.claude/agents/custom-agent.md"
echo "# Brand new file" > "$MOCK_UP4/.claude/agents/new-file.md"

MOCKED4=$(create_mocked_script "$PROJ4" "$MOCK_UP4")
output=$("$MOCKED4" diff 2>&1 || true)

assert_contains "$output" "PROTECTED" "diff output contains PROTECTED label"
assert_contains "$output" "PROTECTED  CLAUDE.md (upstream has changes, skipping per manifest)" "diff shows PROTECTED for CLAUDE.md with correct message"
assert_contains "$output" "PROTECTED  settings.local.json" "diff shows PROTECTED for settings.local.json"
assert_contains "$output" "PROTECTED  agents/custom-agent.md" "diff shows PROTECTED for glob-matched custom agent"
assert_not_contains "$output" "PROTECTED  agents/system-architect.md" "system-architect.md is NOT protected"
assert_contains "$output" "agents/new-file.md" "new upstream file is shown"

# =============================================================================
echo -e "\n${CYAN}=== Test 8: do_diff -- protected count in summary ===${NC}\n"
# =============================================================================
assert_contains "$output" "protected" "diff summary includes protected count"

# =============================================================================
echo -e "\n${CYAN}=== Test 9: do_sync -- protected files not overwritten ===${NC}\n"
# AC: Manifest protected section prevents listed files from being modified during sync
# =============================================================================
PROJ5=$(setup_project "sync-protected")
create_manifest_with_protected "$PROJ5"
"$PROJ5/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

# Create local files with specific content
mkdir -p "$PROJ5/.claude/agents"
echo "LOCAL CLAUDE CONTENT" > "$PROJ5/.claude/CLAUDE.md"
echo "LOCAL SETTINGS" > "$PROJ5/.claude/settings.local.json"
echo "LOCAL ARCHITECT" > "$PROJ5/.claude/agents/system-architect.md"

# Create upstream with different content
MOCK_UP5="$TEST_DIR/mock-upstream-sync-prot"
mkdir -p "$MOCK_UP5/.claude/agents"
echo "UPSTREAM CLAUDE CONTENT" > "$MOCK_UP5/.claude/CLAUDE.md"
echo "UPSTREAM SETTINGS" > "$MOCK_UP5/.claude/settings.local.json"
echo "UPSTREAM ARCHITECT" > "$MOCK_UP5/.claude/agents/system-architect.md"

MOCKED5=$(create_mocked_script "$PROJ5" "$MOCK_UP5")
output=$("$MOCKED5" sync 2>&1 || true)

# Protected files should retain local content
assert_file_content "$PROJ5/.claude/CLAUDE.md" "LOCAL CLAUDE CONTENT" "CLAUDE.md retains local content after sync"
assert_file_content "$PROJ5/.claude/settings.local.json" "LOCAL SETTINGS" "settings.local.json retains local content after sync"

# Non-protected file should be updated
assert_file_content "$PROJ5/.claude/agents/system-architect.md" "UPSTREAM ARCHITECT" "system-architect.md updated to upstream content"

# Sync output should mention protected files
assert_contains "$output" "Skipping protected: CLAUDE.md" "sync reports protected CLAUDE.md"
assert_contains "$output" "Skipping protected: settings.local.json" "sync reports protected settings.local.json"

# =============================================================================
echo -e "\n${CYAN}=== Test 10: do_sync -- protected count in summary ===${NC}\n"
# =============================================================================
assert_contains "$output" "protected" "sync summary includes protected count"

# =============================================================================
echo -e "\n${CYAN}=== Test 11: Warning for non-existent protected path ===${NC}\n"
# AC: Warning emitted if a protected path does not exist locally
# =============================================================================
PROJ6=$(setup_project "warn-nonexistent")
"$PROJ6/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

cat > "$PROJ6/.claude/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "TestProject"
  PROJECT_REPO: "test-project"
  PROJECT_SHORT: "TST"
  GITHUB_ORG: "test-org"
  TICKET_PREFIX: "TST"
  MAIN_BRANCH: "main"
protected:
  - "CLAUDE.md"
  - "nonexistent-file.json"
  - "missing-dir/config.yml"
YAML

# Only create CLAUDE.md locally (the other two don't exist)
echo "# Local CLAUDE" > "$PROJ6/.claude/CLAUDE.md"

MOCK_UP6="$TEST_DIR/mock-upstream-warn"
mkdir -p "$MOCK_UP6/.claude"
echo "# Upstream" > "$MOCK_UP6/.claude/CLAUDE.md"
echo "# Some content" > "$MOCK_UP6/.claude/nonexistent-file.json"

MOCKED6=$(create_mocked_script "$PROJ6" "$MOCK_UP6")
output=$("$MOCKED6" diff 2>&1 || true)

assert_contains "$output" "Protected pattern does not match any local file: nonexistent-file.json" "warns about non-existent protected path"
assert_contains "$output" "Protected pattern does not match any local file: missing-dir/config.yml" "warns about second non-existent protected path"
assert_contains "$output" "possible typo in manifest" "warning includes typo hint"

# =============================================================================
echo -e "\n${CYAN}=== Test 12: No manifest -- no PROTECTED label (backward compat) ===${NC}\n"
# AC: .sync-exclude still works as fallback (backward compatible)
# =============================================================================
PROJ7=$(setup_project "no-manifest-compat")
"$PROJ7/scripts/sync-claude-harness.sh" init >/dev/null 2>&1
# No manifest, just .sync-exclude

mkdir -p "$PROJ7/.claude/agents"
echo "Local content" > "$PROJ7/.claude/settings.local.json"
echo "Local agent" > "$PROJ7/.claude/agents/fe-developer.md"

MOCK_UP7="$TEST_DIR/mock-upstream-nomnfst-prot"
mkdir -p "$MOCK_UP7/.claude/agents"
echo "Upstream content" > "$MOCK_UP7/.claude/settings.local.json"
echo "Upstream agent" > "$MOCK_UP7/.claude/agents/fe-developer.md"

MOCKED7=$(create_mocked_script "$PROJ7" "$MOCK_UP7")
output=$("$MOCKED7" diff 2>&1 || true)

assert_not_contains "$output" "PROTECTED" "no PROTECTED label without manifest"
assert_contains "$output" "EXCLUDED  settings.local.json" ".sync-exclude shows EXCLUDED label"

# =============================================================================
echo -e "\n${CYAN}=== Test 13: is_manifest_protected -- distinguishes manifest vs .sync-exclude ===${NC}\n"
# =============================================================================
output=$(
    source "$SOURCEABLE3"
    PROJECT_ROOT="$PROJ3"
    CLAUDE_DIR="$PROJ3/.claude"
    MANIFEST_FILE="$PROJ3/.claude/.harness-manifest.yml"
    EXCLUDE_FILE="$PROJ3/.claude/.sync-exclude"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest

    # CLAUDE.md is in manifest protected
    if is_manifest_protected "CLAUDE.md"; then echo "MNFST_CLAUDE: yes"; else echo "MNFST_CLAUDE: no"; fi
    # my-custom-file.txt is only in .sync-exclude (not manifest)
    if is_manifest_protected "my-custom-file.txt"; then echo "MNFST_CUSTOM: yes"; else echo "MNFST_CUSTOM: no"; fi
    # Something not in either
    if is_manifest_protected "agents/new.md"; then echo "MNFST_NEW: yes"; else echo "MNFST_NEW: no"; fi
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "MNFST_CLAUDE: yes" "is_manifest_protected true for CLAUDE.md (in manifest)"
assert_contains "$output" "MNFST_CUSTOM: no" "is_manifest_protected false for .sync-exclude-only pattern"
assert_contains "$output" "MNFST_NEW: no" "is_manifest_protected false for unlisted file"

# =============================================================================
echo -e "\n${CYAN}=== Test 14: Glob pattern ** (recursive) ===${NC}\n"
# AC: Glob patterns supported in protected section
# =============================================================================
PROJ8=$(setup_project "glob-recursive")
"$PROJ8/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

cat > "$PROJ8/.claude/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "TestProject"
  PROJECT_REPO: "test-project"
  PROJECT_SHORT: "TST"
  GITHUB_ORG: "test-org"
  TICKET_PREFIX: "TST"
  MAIN_BRANCH: "main"
protected:
  - "skills/custom-*/**"
  - "*.local.json"
YAML

SOURCEABLE8=$(create_sourceable_script "$PROJ8")

output=$(
    source "$SOURCEABLE8"
    PROJECT_ROOT="$PROJ8"
    CLAUDE_DIR="$PROJ8/.claude"
    MANIFEST_FILE="$PROJ8/.claude/.harness-manifest.yml"
    EXCLUDE_FILE="$PROJ8/.claude/.sync-exclude"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest

    if is_protected "skills/custom-auth/SKILL.md"; then echo "GLOB_RECUR: yes"; else echo "GLOB_RECUR: no"; fi
    if is_protected "skills/custom-auth/nested/deep.md"; then echo "GLOB_DEEP: yes"; else echo "GLOB_DEEP: no"; fi
    if is_protected "settings.local.json"; then echo "GLOB_STAR: yes"; else echo "GLOB_STAR: no"; fi
    if is_protected "other.local.json"; then echo "GLOB_STAR2: yes"; else echo "GLOB_STAR2: no"; fi
    if is_protected "skills/standard/SKILL.md"; then echo "GLOB_NO: yes"; else echo "GLOB_NO: no"; fi
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "GLOB_RECUR: yes" "** glob matches recursive path"
assert_contains "$output" "GLOB_DEEP: yes" "** glob matches deeply nested path"
assert_contains "$output" "GLOB_STAR: yes" "*.local.json matches settings.local.json"
assert_contains "$output" "GLOB_STAR2: yes" "*.local.json matches other.local.json"
assert_contains "$output" "GLOB_NO: no" "non-matching path is not protected"

# =============================================================================
echo -e "\n${CYAN}=== Test 15: Hardcoded exclusions always apply ===${NC}\n"
# Metadata files are always protected regardless of manifest content
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

    if is_protected ".harness-sync.json"; then echo "HARD_SYNC: yes"; else echo "HARD_SYNC: no"; fi
    if is_protected ".harness-manifest.yml"; then echo "HARD_MANIFEST: yes"; else echo "HARD_MANIFEST: no"; fi
    if is_protected ".sync-exclude"; then echo "HARD_EXCL: yes"; else echo "HARD_EXCL: no"; fi
    if is_protected ".harness-backup/something"; then echo "HARD_BACKUP: yes"; else echo "HARD_BACKUP: no"; fi
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "HARD_SYNC: yes" ".harness-sync.json always protected"
assert_contains "$output" "HARD_MANIFEST: yes" ".harness-manifest.yml always protected"
assert_contains "$output" "HARD_EXCL: yes" ".sync-exclude always protected"
assert_contains "$output" "HARD_BACKUP: yes" ".harness-backup/* always protected"

# =============================================================================
echo -e "\n${CYAN}=== Test 16: Script syntax validation ===${NC}\n"
# =============================================================================
syntax_output=$(bash -n "$SYNC_SCRIPT" 2>&1)
syntax_ec=$?
assert_exit_code "$syntax_ec" 0 "sync script has valid bash syntax"

# =============================================================================
echo -e "\n${CYAN}=== Test 17: Existing manifest loader tests still pass ===${NC}\n"
# =============================================================================
ml_output=$(bash "$REPO_ROOT/tests/test-manifest-loader.sh" 2>&1)
ml_ec=$?
assert_exit_code "$ml_ec" 0 "manifest loader tests (SAW-6) still pass"

# =============================================================================
echo -e "\n${CYAN}=== Test 18: do_sync with dry-run -- protected files reported ===${NC}\n"
# Dry run should still show protected files without modifying anything
# =============================================================================
PROJ9=$(setup_project "sync-dryrun-prot")
create_manifest_with_protected "$PROJ9"
"$PROJ9/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

mkdir -p "$PROJ9/.claude/agents"
echo "LOCAL CLAUDE" > "$PROJ9/.claude/CLAUDE.md"
echo "LOCAL AGENT" > "$PROJ9/.claude/agents/system-architect.md"

MOCK_UP9="$TEST_DIR/mock-upstream-dryrun"
mkdir -p "$MOCK_UP9/.claude/agents"
echo "UPSTREAM CLAUDE" > "$MOCK_UP9/.claude/CLAUDE.md"
echo "UPSTREAM AGENT" > "$MOCK_UP9/.claude/agents/system-architect.md"

MOCKED9=$(create_mocked_script "$PROJ9" "$MOCK_UP9")
output=$("$MOCKED9" sync --dry-run 2>&1 || true)

assert_contains "$output" "Skipping protected: CLAUDE.md" "dry-run reports protected files"
assert_file_content "$PROJ9/.claude/CLAUDE.md" "LOCAL CLAUDE" "dry-run does not modify protected files"

# =============================================================================
echo -e "\n${CYAN}=== Test 19: Empty protected section -- no interference ===${NC}\n"
# =============================================================================
PROJ10=$(setup_project "empty-protected")
"$PROJ10/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

cat > "$PROJ10/.claude/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "TestProject"
  PROJECT_REPO: "test-project"
  PROJECT_SHORT: "TST"
  GITHUB_ORG: "test-org"
  TICKET_PREFIX: "TST"
  MAIN_BRANCH: "main"
protected: []
YAML

mkdir -p "$PROJ10/.claude/agents"
echo "LOCAL" > "$PROJ10/.claude/agents/test.md"

MOCK_UP10="$TEST_DIR/mock-upstream-empty-prot"
mkdir -p "$MOCK_UP10/.claude/agents"
echo "UPSTREAM" > "$MOCK_UP10/.claude/agents/test.md"

MOCKED10=$(create_mocked_script "$PROJ10" "$MOCK_UP10")
output=$("$MOCKED10" sync 2>&1 || true)

assert_not_contains "$output" "PROTECTED" "empty protected section does not trigger PROTECTED label"
assert_not_contains "$output" "Skipping protected" "empty protected section does not skip files"
assert_file_content "$PROJ10/.claude/agents/test.md" "UPSTREAM" "file updated normally with empty protected section"

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
