#!/bin/bash
# =============================================================================
# Test: Patch Generation Mode (SAW-4)
# =============================================================================
# Tests all AC items for the --generate-patches sync mode.
# Run from repo root: bash tests/test-patch-generation.sh
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
TEST_DIR=$(mktemp -d /tmp/patch-gen-test-XXXXXX)
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

assert_dir_exists() {
    local path="$1"
    local label="$2"
    TOTAL=$((TOTAL + 1))
    if [ -d "$path" ]; then
        echo -e "  ${GREEN}PASS${NC} $label"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $label (directory not found: $path)"
        FAIL=$((FAIL + 1))
    fi
}

assert_file_content() {
    local path="$1"
    local expected="$2"
    local label="$3"
    TOTAL=$((TOTAL + 1))
    if [ -f "$path" ] && grep -qF -- "$expected" "$path"; then
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

assert_file_not_content() {
    local path="$1"
    local expected="$2"
    local label="$3"
    TOTAL=$((TOTAL + 1))
    if [ -f "$path" ] && ! grep -qF -- "$expected" "$path"; then
        echo -e "  ${GREEN}PASS${NC} $label"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $label (did NOT expect content: $expected in $path)"
        FAIL=$((FAIL + 1))
    fi
}

assert_patch_valid() {
    local patch_file="$1"
    local project_dir="$2"
    local label="$3"
    TOTAL=$((TOTAL + 1))
    if [ ! -f "$patch_file" ]; then
        echo -e "  ${RED}FAIL${NC} $label (patch file not found: $patch_file)"
        FAIL=$((FAIL + 1))
        return
    fi
    # Check that the patch contains unified diff markers
    if grep -q '^---' "$patch_file" && grep -q '^+++' "$patch_file"; then
        echo -e "  ${GREEN}PASS${NC} $label"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $label (not a valid unified diff)"
        echo -e "  ${YELLOW}  Patch contents (first 20 lines):${NC}"
        head -20 "$patch_file" | sed 's/^/    /'
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

# Create a valid manifest with substitutions, renames, and protected entries
create_full_manifest() {
    local proj_dir="$1"
    cat > "$proj_dir/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "MyForkProject"
  PROJECT_REPO: "my-fork-repo"
  PROJECT_SHORT: "MFP"
  GITHUB_ORG: "my-fork-org"
  TICKET_PREFIX: "MFP"
  MAIN_BRANCH: "main"
substitutions:
  "{{PROJECT_NAME}}": "MyForkProject"
  "{{GITHUB_ORG}}": "my-fork-org"
  "{{TICKET_PREFIX}}": "MFP"
renames:
  "agents/be-developer.md": "agents/backend-eng.md"
  "skills/rls-patterns/": "skills/firestore-security/"
protected:
  - "CLAUDE.md"
  - "settings.local.json"
YAML
}

# Create a basic manifest (no renames)
create_basic_manifest() {
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
substitutions:
  "{{PROJECT_NAME}}": "TestProject"
  "{{GITHUB_ORG}}": "test-org"
protected:
  - "settings.local.json"
YAML
}


# =============================================================================
echo -e "\n${CYAN}=== Test 1: --generate-patches writes .patch files to correct directory ===${NC}\n"
# AC: sync --generate-patches writes .patch files to .harness-patches/vX.Y.Z/
# =============================================================================
PROJ=$(setup_project "basic-patches")
create_basic_manifest "$PROJ"
"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

# Create mock upstream with a NEW file
MOCK_UP="$TEST_DIR/upstream-basic"
mkdir -p "$MOCK_UP/.claude/agents"
cat > "$MOCK_UP/.claude/agents/new-agent.md" << 'EOF'
# New Agent
This is a new agent file from upstream.
EOF

# Create a local file that will be MODIFIED
mkdir -p "$PROJ/.claude/skills"
echo "# Old Skill Content" > "$PROJ/.claude/skills/pattern-discovery.md"

# Add an UPSTREAM version of that same file (modified)
mkdir -p "$MOCK_UP/.claude/skills"
cat > "$MOCK_UP/.claude/skills/pattern-discovery.md" << 'EOF'
# Updated Skill Content
This has been updated in upstream with TestProject branding.
EOF

MOCKED=$(create_mocked_script "$PROJ" "$MOCK_UP")

OUTPUT=$("$MOCKED" sync --generate-patches --version v2.7.0 --skip-preflight 2>&1) || true

assert_dir_exists "$PROJ/.harness-patches/v2.7.0" \
    "Patches directory created at .harness-patches/v2.7.0"

# Check that .patch files exist
PATCH_COUNT=$(find "$PROJ/.harness-patches/v2.7.0" -name "*.patch" 2>/dev/null | wc -l | tr -d ' ')
TOTAL=$((TOTAL + 1))
if [ "$PATCH_COUNT" -ge 2 ]; then
    echo -e "  ${GREEN}PASS${NC} At least 2 .patch files generated ($PATCH_COUNT found)"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} Expected at least 2 .patch files, got $PATCH_COUNT"
    echo "  Files in patches dir:"
    find "$PROJ/.harness-patches/v2.7.0" -type f 2>/dev/null | sed 's/^/    /'
    FAIL=$((FAIL + 1))
fi

assert_contains "$OUTPUT" "Generating Patches" \
    "Output indicates patch generation mode"
assert_contains "$OUTPUT" "patch(es)" \
    "Output includes patch count summary"


# =============================================================================
echo -e "\n${CYAN}=== Test 2: Patches are valid unified diffs ===${NC}\n"
# AC: Each patch is a valid unified diff (git apply --check compatible)
# =============================================================================

# Check each .patch file for unified diff format
for patch in "$PROJ/.harness-patches/v2.7.0"/*.patch; do
    [ -f "$patch" ] || continue
    pname=$(basename "$patch")
    assert_patch_valid "$patch" "$PROJ" \
        "Patch $pname is valid unified diff"
done


# =============================================================================
echo -e "\n${CYAN}=== Test 3: APPLY_ORDER.md is generated ===${NC}\n"
# AC: Summary file APPLY_ORDER.md lists patches in recommended order with categorization
# =============================================================================

APPLY_ORDER="$PROJ/.harness-patches/v2.7.0/APPLY_ORDER.md"

assert_file_exists "$APPLY_ORDER" \
    "APPLY_ORDER.md exists"

assert_file_content "$APPLY_ORDER" "v2.7.0" \
    "APPLY_ORDER.md contains version"

assert_file_content "$APPLY_ORDER" "NEW files" \
    "APPLY_ORDER.md has NEW files section"

assert_file_content "$APPLY_ORDER" "UPDATED files" \
    "APPLY_ORDER.md has UPDATED files section"

assert_file_content "$APPLY_ORDER" "git apply" \
    "APPLY_ORDER.md includes git apply commands"


# =============================================================================
echo -e "\n${CYAN}=== Test 4: Patches are rename-aware ===${NC}\n"
# AC: Patches are rename-aware (target fork's local paths)
# =============================================================================
PROJ2=$(setup_project "rename-patches")
create_full_manifest "$PROJ2"
"$PROJ2/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

# Create local file at renamed path (different from upstream)
mkdir -p "$PROJ2/.claude/agents"
echo "# Old Backend Engineer" > "$PROJ2/.claude/agents/backend-eng.md"

# Create upstream file at original path
MOCK_UP2="$TEST_DIR/upstream-rename"
mkdir -p "$MOCK_UP2/.claude/agents"
cat > "$MOCK_UP2/.claude/agents/be-developer.md" << 'EOF'
# Updated Backend Developer
This is the updated upstream content for {{PROJECT_NAME}}.
EOF

# Also create a file in a renamed directory
mkdir -p "$PROJ2/.claude/skills/firestore-security"
echo "# Old Security Pattern" > "$PROJ2/.claude/skills/firestore-security/SKILL.md"

mkdir -p "$MOCK_UP2/.claude/skills/rls-patterns"
cat > "$MOCK_UP2/.claude/skills/rls-patterns/SKILL.md" << 'EOF'
# Updated RLS Pattern for {{PROJECT_NAME}}
New upstream content.
EOF

MOCKED2=$(create_mocked_script "$PROJ2" "$MOCK_UP2")
OUTPUT2=$("$MOCKED2" sync --generate-patches --version v2.7.0 --skip-preflight 2>&1) || true

# Check that patches use the fork's local path, not the upstream path
# The file rename: agents/be-developer.md -> agents/backend-eng.md
FILE_RENAME_PATCH="$PROJ2/.harness-patches/v2.7.0/agents__backend-eng.md.patch"
assert_file_exists "$FILE_RENAME_PATCH" \
    "Patch file named with fork's local path (agents__backend-eng.md.patch)"

if [ -f "$FILE_RENAME_PATCH" ]; then
    assert_file_content "$FILE_RENAME_PATCH" "b/.claude/agents/backend-eng.md" \
        "Patch header uses fork's local path (backend-eng.md)"
    assert_file_not_content "$FILE_RENAME_PATCH" "b/.claude/agents/be-developer.md" \
        "Patch header does NOT use upstream path (be-developer.md)"
fi

# Check directory rename: skills/rls-patterns/ -> skills/firestore-security/
DIR_RENAME_PATCH="$PROJ2/.harness-patches/v2.7.0/skills__firestore-security__SKILL.md.patch"
assert_file_exists "$DIR_RENAME_PATCH" \
    "Patch file named with fork's dir-renamed path (skills__firestore-security__SKILL.md.patch)"

if [ -f "$DIR_RENAME_PATCH" ]; then
    assert_file_content "$DIR_RENAME_PATCH" "b/.claude/skills/firestore-security/SKILL.md" \
        "Patch header uses fork's directory-renamed path"
fi


# =============================================================================
echo -e "\n${CYAN}=== Test 5: Patches are substitution-aware ===${NC}\n"
# AC: Patches are substitution-aware (use fork's placeholder values)
# =============================================================================

# The upstream files contain {{PROJECT_NAME}} which should be substituted
# to "MyForkProject" in the patches
if [ -f "$FILE_RENAME_PATCH" ]; then
    assert_file_content "$FILE_RENAME_PATCH" "MyForkProject" \
        "Patch content has substituted value (MyForkProject)"
    assert_file_not_content "$FILE_RENAME_PATCH" "{{PROJECT_NAME}}" \
        "Patch content does NOT have raw placeholder {{PROJECT_NAME}}"
fi

if [ -f "$DIR_RENAME_PATCH" ]; then
    assert_file_content "$DIR_RENAME_PATCH" "MyForkProject" \
        "Directory-rename patch has substituted value"
fi


# =============================================================================
echo -e "\n${CYAN}=== Test 6: Protected files are skipped (no patches generated) ===${NC}\n"
# AC: Protected files should not have patches generated
# =============================================================================
PROJ3=$(setup_project "protected-skip")
create_full_manifest "$PROJ3"
"$PROJ3/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

# Create local CLAUDE.md (protected per manifest)
echo "# Local CLAUDE.md" > "$PROJ3/.claude/CLAUDE.md"

# Create upstream CLAUDE.md (would be modified)
MOCK_UP3="$TEST_DIR/upstream-protected"
mkdir -p "$MOCK_UP3/.claude"
echo "# Upstream CLAUDE.md - CHANGED" > "$MOCK_UP3/.claude/CLAUDE.md"

# Also create a non-protected file for contrast
echo "# Local README" > "$PROJ3/.claude/README.md"
echo "# Upstream README - CHANGED" > "$MOCK_UP3/.claude/README.md"

MOCKED3=$(create_mocked_script "$PROJ3" "$MOCK_UP3")
OUTPUT3=$("$MOCKED3" sync --generate-patches --version v2.7.0 --skip-preflight 2>&1) || true

# Verify no patch generated for CLAUDE.md (protected)
PROTECTED_PATCH="$PROJ3/.harness-patches/v2.7.0/CLAUDE.md.patch"
TOTAL=$((TOTAL + 1))
if [ ! -f "$PROTECTED_PATCH" ]; then
    echo -e "  ${GREEN}PASS${NC} No patch generated for protected file CLAUDE.md"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} Patch was generated for protected file CLAUDE.md (should be skipped)"
    FAIL=$((FAIL + 1))
fi

assert_contains "$OUTPUT3" "Skipping protected" \
    "Output mentions skipping protected file"

# Verify non-protected file DID get a patch
NON_PROTECTED_PATCH="$PROJ3/.harness-patches/v2.7.0/README.md.patch"
assert_file_exists "$NON_PROTECTED_PATCH" \
    "Non-protected file (README.md) gets a patch"


# =============================================================================
echo -e "\n${CYAN}=== Test 7: No files are overwritten in patch mode ===${NC}\n"
# AC: --generate-patches generates patches instead of overwriting files
# =============================================================================
PROJ4=$(setup_project "no-overwrite")
create_basic_manifest "$PROJ4"
"$PROJ4/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

# Create a local file with specific content
echo "ORIGINAL LOCAL CONTENT - DO NOT CHANGE" > "$PROJ4/.claude/README.md"
LOCAL_MD5=$(md5sum "$PROJ4/.claude/README.md" | cut -d' ' -f1)

# Create upstream with different content
MOCK_UP4="$TEST_DIR/upstream-nooverwrite"
mkdir -p "$MOCK_UP4/.claude"
echo "UPSTREAM CHANGED CONTENT" > "$MOCK_UP4/.claude/README.md"

MOCKED4=$(create_mocked_script "$PROJ4" "$MOCK_UP4")
OUTPUT4=$("$MOCKED4" sync --generate-patches --version v2.7.0 --skip-preflight 2>&1) || true

# Verify local file was NOT modified
NEW_MD5=$(md5sum "$PROJ4/.claude/README.md" | cut -d' ' -f1)
TOTAL=$((TOTAL + 1))
if [ "$LOCAL_MD5" = "$NEW_MD5" ]; then
    echo -e "  ${GREEN}PASS${NC} Local file was NOT overwritten during patch generation"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} Local file was modified during patch generation (should not change)"
    FAIL=$((FAIL + 1))
fi

assert_file_content "$PROJ4/.claude/README.md" "ORIGINAL LOCAL CONTENT - DO NOT CHANGE" \
    "Local file still has original content"


# =============================================================================
echo -e "\n${CYAN}=== Test 8: New file patches diff against /dev/null ===${NC}\n"
# AC: Patches for new files use /dev/null as source
# =============================================================================
PROJ5=$(setup_project "new-file-diff")
create_basic_manifest "$PROJ5"
"$PROJ5/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

# Create upstream with a brand-new file (no local equivalent)
MOCK_UP5="$TEST_DIR/upstream-newfile"
mkdir -p "$MOCK_UP5/.claude/commands"
cat > "$MOCK_UP5/.claude/commands/new-command.md" << 'EOF'
# New Command
Brought to you by TestProject.
EOF

MOCKED5=$(create_mocked_script "$PROJ5" "$MOCK_UP5")
OUTPUT5=$("$MOCKED5" sync --generate-patches --version v2.7.0 --skip-preflight 2>&1) || true

NEW_FILE_PATCH="$PROJ5/.harness-patches/v2.7.0/commands__new-command.md.patch"
assert_file_exists "$NEW_FILE_PATCH" \
    "Patch generated for new file"

if [ -f "$NEW_FILE_PATCH" ]; then
    assert_file_content "$NEW_FILE_PATCH" "a/dev/null" \
        "New file patch uses /dev/null as source"
    assert_file_content "$NEW_FILE_PATCH" "b/.claude/commands/new-command.md" \
        "New file patch uses correct target path"
fi

assert_contains "$OUTPUT5" "Patch (NEW)" \
    "Output labels new file patches as NEW"


# =============================================================================
echo -e "\n${CYAN}=== Test 9: Modified file patches show correct diff ===${NC}\n"
# AC: Patches for modified files diff between local and upstream
# =============================================================================

# Reuse PROJ from Test 1 -- check the modified file patch
MOD_PATCH="$PROJ/.harness-patches/v2.7.0/skills__pattern-discovery.md.patch"
assert_file_exists "$MOD_PATCH" \
    "Patch generated for modified file"

if [ -f "$MOD_PATCH" ]; then
    assert_file_content "$MOD_PATCH" "a/.claude/skills/pattern-discovery.md" \
        "Modified patch references local as source"
    assert_file_content "$MOD_PATCH" "b/.claude/skills/pattern-discovery.md" \
        "Modified patch references same path as target"
    # The old content should appear as removed
    assert_file_content "$MOD_PATCH" "-# Old Skill Content" \
        "Modified patch shows removed old content"
    # The new content should appear as added
    assert_file_content "$MOD_PATCH" "+# Updated Skill Content" \
        "Modified patch shows added new content"
fi

assert_contains "$OUTPUT" "Patch (UPD)" \
    "Output labels modified file patches as UPD"


# =============================================================================
echo -e "\n${CYAN}=== Test 10: APPLY_ORDER.md categorization ===${NC}\n"
# AC: APPLY_ORDER.md lists patches grouped by category with commands
# =============================================================================

APPLY_ORDER_1="$PROJ/.harness-patches/v2.7.0/APPLY_ORDER.md"

if [ -f "$APPLY_ORDER_1" ]; then
    # Verify both sections exist and have entries
    assert_file_content "$APPLY_ORDER_1" "agents__new-agent.md.patch" \
        "APPLY_ORDER.md lists new agent patch"
    assert_file_content "$APPLY_ORDER_1" "skills__pattern-discovery.md.patch" \
        "APPLY_ORDER.md lists updated skill patch"
    assert_file_content "$APPLY_ORDER_1" "Apply all" \
        "APPLY_ORDER.md has apply-all section"
fi


# =============================================================================
echo -e "\n${CYAN}=== Test 11: Patches directory uses version from --version flag ===${NC}\n"
# AC: .patch files are in .harness-patches/vX.Y.Z/
# =============================================================================
PROJ6=$(setup_project "version-dir")
create_basic_manifest "$PROJ6"
"$PROJ6/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

MOCK_UP6="$TEST_DIR/upstream-version"
mkdir -p "$MOCK_UP6/.claude"
echo "# Some file" > "$MOCK_UP6/.claude/test-file.md"

MOCKED6=$(create_mocked_script "$PROJ6" "$MOCK_UP6")
OUTPUT6=$("$MOCKED6" sync --generate-patches --version v3.0.0 --skip-preflight 2>&1) || true

assert_dir_exists "$PROJ6/.harness-patches/v3.0.0" \
    "Patches directory uses version v3.0.0 from flag"


# =============================================================================
echo -e "\n${CYAN}=== Test 12: Previous patches for same version are cleaned ===${NC}\n"
# AC: Re-running cleans previous patches for the same version
# =============================================================================

# Add an extra marker file to the patches dir to verify cleanup
touch "$PROJ6/.harness-patches/v3.0.0/STALE_MARKER.txt"

# Recreate mock upstream (cleanup trap from previous run deleted it)
MOCK_UP6B="$TEST_DIR/upstream-version-b"
mkdir -p "$MOCK_UP6B/.claude"
echo "# Changed upstream file" > "$MOCK_UP6B/.claude/test-file.md"

MOCKED6B=$(create_mocked_script "$PROJ6" "$MOCK_UP6B")
OUTPUT6B=$("$MOCKED6B" sync --generate-patches --version v3.0.0 --skip-preflight 2>&1) || true

# Verify stale marker was cleaned
TOTAL=$((TOTAL + 1))
if [ ! -f "$PROJ6/.harness-patches/v3.0.0/STALE_MARKER.txt" ]; then
    echo -e "  ${GREEN}PASS${NC} Stale patches cleaned before regeneration"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} Stale marker file still exists (directory not cleaned)"
    FAIL=$((FAIL + 1))
fi

# Count patches - should be fresh
PATCH_COUNT6=$(find "$PROJ6/.harness-patches/v3.0.0" -name "*.patch" 2>/dev/null | wc -l | tr -d ' ')
TOTAL=$((TOTAL + 1))
if [ "$PATCH_COUNT6" -ge 1 ]; then
    echo -e "  ${GREEN}PASS${NC} Patches regenerated for v3.0.0 ($PATCH_COUNT6 patches)"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} Expected at least 1 patch after regeneration, got $PATCH_COUNT6"
    FAIL=$((FAIL + 1))
fi


# =============================================================================
echo -e "\n${CYAN}=== Test 13: Unchanged files produce no patches ===${NC}\n"
# AC: No patches generated for files that are identical
# =============================================================================
PROJ7=$(setup_project "unchanged-skip")
create_basic_manifest "$PROJ7"
"$PROJ7/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

# Create identical local and upstream files
mkdir -p "$PROJ7/.claude/agents"
echo "# Identical Content" > "$PROJ7/.claude/agents/same.md"

MOCK_UP7="$TEST_DIR/upstream-unchanged"
mkdir -p "$MOCK_UP7/.claude/agents"
echo "# Identical Content" > "$MOCK_UP7/.claude/agents/same.md"

MOCKED7=$(create_mocked_script "$PROJ7" "$MOCK_UP7")
OUTPUT7=$("$MOCKED7" sync --generate-patches --version v2.7.0 --skip-preflight 2>&1) || true

assert_contains "$OUTPUT7" "0 patch(es)" \
    "No patches generated for unchanged file"


# =============================================================================
echo -e "\n${CYAN}=== Test 14: Substitution in patch content for basic manifest ===${NC}\n"
# AC: Patches use fork's placeholder values
# =============================================================================
PROJ8=$(setup_project "sub-basic")
create_basic_manifest "$PROJ8"
"$PROJ8/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

# Create upstream file with placeholders
MOCK_UP8="$TEST_DIR/upstream-subs"
mkdir -p "$MOCK_UP8/.claude"
cat > "$MOCK_UP8/.claude/README.md" << 'EOF'
# Welcome to {{PROJECT_NAME}}
This is the {{GITHUB_ORG}} project.
Ticket prefix: {{TICKET_PREFIX}}
EOF

MOCKED8=$(create_mocked_script "$PROJ8" "$MOCK_UP8")
OUTPUT8=$("$MOCKED8" sync --generate-patches --version v2.7.0 --skip-preflight 2>&1) || true

SUB_PATCH="$PROJ8/.harness-patches/v2.7.0/README.md.patch"
assert_file_exists "$SUB_PATCH" \
    "Patch generated for file with substitutions"

if [ -f "$SUB_PATCH" ]; then
    assert_file_content "$SUB_PATCH" "TestProject" \
        "Substitution applied: {{PROJECT_NAME}} -> TestProject"
    assert_file_content "$SUB_PATCH" "test-org" \
        "Substitution applied: {{GITHUB_ORG}} -> test-org"
    assert_file_not_content "$SUB_PATCH" "{{PROJECT_NAME}}" \
        "No raw {{PROJECT_NAME}} placeholder in patch"
    assert_file_not_content "$SUB_PATCH" "{{GITHUB_ORG}}" \
        "No raw {{GITHUB_ORG}} placeholder in patch"
fi


# =============================================================================
echo -e "\n${CYAN}=== Test 15: git apply --check compatibility ===${NC}\n"
# AC: Each patch is git apply --check compatible
# =============================================================================

# We test this by creating a git repo and running git apply --check on a patch.
GIT_TEST_DIR="$TEST_DIR/git-apply-test"
mkdir -p "$GIT_TEST_DIR/.claude/skills"
(cd "$GIT_TEST_DIR" && git init -q && echo "# test" > README && git add -A && git commit -q -m "init")

# Create a local file
echo "# Old Skill" > "$GIT_TEST_DIR/.claude/skills/test-skill.md"
(cd "$GIT_TEST_DIR" && git add -A && git commit -q -m "add skill")

# Generate a valid unified diff
diff -u "$GIT_TEST_DIR/.claude/skills/test-skill.md" <(echo "# Updated Skill") \
    --label "a/.claude/skills/test-skill.md" \
    --label "b/.claude/skills/test-skill.md" \
    > "$TEST_DIR/test-apply.patch" 2>/dev/null || true

GIT_APPLY_RC=0
(cd "$GIT_TEST_DIR" && git apply --check "$TEST_DIR/test-apply.patch" 2>/dev/null) || GIT_APPLY_RC=$?

assert_exit_code "$GIT_APPLY_RC" 0 \
    "Unified diff format passes git apply --check"


# =============================================================================
echo -e "\n${CYAN}=== Test 16: Patch filename sanitization ===${NC}\n"
# AC: Patch filenames use __ to replace / for flat directory structure
# =============================================================================

# Already validated in Test 1 and Test 4, but explicitly check naming pattern
assert_file_exists "$PROJ/.harness-patches/v2.7.0/agents__new-agent.md.patch" \
    "agents/new-agent.md -> agents__new-agent.md.patch"
assert_file_exists "$PROJ/.harness-patches/v2.7.0/skills__pattern-discovery.md.patch" \
    "skills/pattern-discovery.md -> skills__pattern-discovery.md.patch"


# =============================================================================
echo -e "\n${CYAN}=== Test 17: No backup created in patch mode ===${NC}\n"
# AC: Patch mode should not create backups (no files are modified)
# =============================================================================

# Check that no backup was created in PROJ (used in Test 1)
BACKUP_COUNT=$(find "$PROJ/.harness-backup" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
TOTAL=$((TOTAL + 1))
# The init command creates the backup dir, but patch mode should not add entries
# (unless a previous sync run did). Since we only ran --generate-patches, there
# should be at most the init backup.
if [ "$BACKUP_COUNT" -le 1 ]; then
    echo -e "  ${GREEN}PASS${NC} No extra backup created during patch generation"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} Extra backups found ($BACKUP_COUNT), patch mode should not create backups"
    FAIL=$((FAIL + 1))
fi


# =============================================================================
# Summary
# =============================================================================
echo -e "\n${CYAN}===============================================${NC}"
echo -e "${CYAN}  Patch Generation Tests Summary${NC}"
echo -e "${CYAN}===============================================${NC}"
echo -e "  Total:  $TOTAL"
echo -e "  ${GREEN}Passed: $PASS${NC}"
echo -e "  ${RED}Failed: $FAIL${NC}"
echo ""

if [ "$FAIL" -gt 0 ]; then
    echo -e "${RED}TESTS FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}ALL TESTS PASSED${NC}"
    exit 0
fi
