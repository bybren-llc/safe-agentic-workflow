#!/bin/bash
# =============================================================================
# Test: Fork Compatibility (SAW-9)
# =============================================================================
# Validates that the sync script works correctly against known fork manifests
# (rendertrust + keryk-ai). Ensures upstream changes never silently break
# downstream forks.
#
# Uses fixture data in tests/fixtures/sync/ with mock fork state + manifests.
# Runs sync --dry-run and other commands against mock upstream directories.
#
# Run from repo root: bash tests/test-fork-sync.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SYNC_SCRIPT="$REPO_ROOT/scripts/sync-claude-harness.sh"
FIXTURES_DIR="$SCRIPT_DIR/fixtures/sync"

# Create a temporary working area for tests
TEST_DIR=$(mktemp -d /tmp/fork-sync-test-XXXXXX)
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

# ---------------------------------------------------------------------------
# Assertion helpers
# ---------------------------------------------------------------------------

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
        echo -e "  ${YELLOW}  Output (first 20 lines):${NC}"
        echo "$output" | head -20 | sed 's/^/    /'
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
    local file="$1"
    local label="$2"
    TOTAL=$((TOTAL + 1))
    if [ -f "$file" ]; then
        echo -e "  ${GREEN}PASS${NC} $label"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $label (file not found: $file)"
        FAIL=$((FAIL + 1))
    fi
}

assert_file_contains() {
    local file="$1"
    local expected="$2"
    local label="$3"
    TOTAL=$((TOTAL + 1))
    if [ -f "$file" ] && grep -qF "$expected" "$file"; then
        echo -e "  ${GREEN}PASS${NC} $label"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $label (file missing or does not contain: $expected)"
        FAIL=$((FAIL + 1))
    fi
}

assert_file_not_contains() {
    local file="$1"
    local expected="$2"
    local label="$3"
    TOTAL=$((TOTAL + 1))
    if [ -f "$file" ] && ! grep -qF "$expected" "$file"; then
        echo -e "  ${GREEN}PASS${NC} $label"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $label (file contains unexpected: $expected)"
        FAIL=$((FAIL + 1))
    fi
}

# ---------------------------------------------------------------------------
# Setup helpers
# ---------------------------------------------------------------------------

# Create a mock project directory for a given fixture.
# Sets up both the fork's .claude/ directory (from fixture) and a mock
# "upstream" .claude/ that the sync script will compare against.
#
# Usage: setup_fork_project "rendertrust" "test-label"
# Returns: the project directory path
setup_fork_project() {
    local fixture_name="$1"
    local test_label="$2"
    local proj_dir="$TEST_DIR/$test_label"
    local fixture_dir="$FIXTURES_DIR/$fixture_name"

    mkdir -p "$proj_dir/.claude"
    mkdir -p "$proj_dir/scripts"

    # Copy sync script
    cp "$SYNC_SCRIPT" "$proj_dir/scripts/sync-claude-harness.sh"
    chmod +x "$proj_dir/scripts/sync-claude-harness.sh"

    # Copy fixture .claude/ files (the fork's local state)
    if [ -d "$fixture_dir/.claude" ]; then
        cp -r "$fixture_dir/.claude/"* "$proj_dir/.claude/" 2>/dev/null || true
        cp -r "$fixture_dir/.claude/".* "$proj_dir/.claude/" 2>/dev/null || true
    fi

    # Copy fixture manifest into .claude/.harness-manifest.yml
    if [ -f "$fixture_dir/.harness-manifest.yml" ]; then
        cp "$fixture_dir/.harness-manifest.yml" "$proj_dir/.claude/.harness-manifest.yml"
    fi

    # Initialize sync config
    cat > "$proj_dir/.claude/.harness-sync.json" <<EOF
{
  "upstream_repo": "ByBren-LLC/safe-agentic-workflow",
  "upstream_branch": "template",
  "last_synced_commit": "abc1234",
  "last_synced_version": "v2.6.0",
  "last_synced_at": "2026-03-01T00:00:00Z",
  "sync_history": []
}
EOF

    echo "$proj_dir"
}

# Create a mock upstream .claude/ directory that simulates what
# fetch_upstream would produce. Placed at the TMP_DIR location that
# the sync script expects.
#
# Usage: setup_mock_upstream "$proj_dir"
# Populates TMP_DIR/.claude/ with upstream-like content
setup_mock_upstream() {
    local proj_dir="$1"
    local upstream_dir="$proj_dir/_mock_upstream/.claude"
    mkdir -p "$upstream_dir"
    mkdir -p "$upstream_dir/agents"
    mkdir -p "$upstream_dir/skills/stripe-patterns"
    mkdir -p "$upstream_dir/commands"

    # Create upstream files that use {{PLACEHOLDER}} tokens
    # (simulating the raw upstream template state)
    cat > "$upstream_dir/README.md" <<'UPSTREAM'
# Claude Harness - {{PROJECT_NAME}}

This is the {{PROJECT_NAME}} harness directory.
Project: {{PROJECT_NAME}} | Prefix: {{TICKET_PREFIX}} | Branch: {{MAIN_BRANCH}}
UPSTREAM

    cat > "$upstream_dir/AGENT_OUTPUT_GUIDE.md" <<'UPSTREAM'
# {{PROJECT_NAME}} Agent Output Guide

Standard upstream output guide template.
UPSTREAM

    cat > "$upstream_dir/agents/be-developer.md" <<'UPSTREAM'
# Backend Developer

Project: {{PROJECT_NAME}}
Ticket prefix: {{TICKET_PREFIX}}
Main branch: {{MAIN_BRANCH}}

Standard upstream BE developer agent.
UPSTREAM

    cat > "$upstream_dir/agents/fe-developer.md" <<'UPSTREAM'
# Frontend Developer

Project: {{PROJECT_NAME}}
Ticket prefix: {{TICKET_PREFIX}}
Main branch: {{MAIN_BRANCH}}

Standard upstream FE developer agent.
UPSTREAM

    cat > "$upstream_dir/agents/data-engineer.md" <<'UPSTREAM'
# Data Engineer

Project: {{PROJECT_NAME}}
Ticket prefix: {{TICKET_PREFIX}}

Standard upstream data engineer agent.
UPSTREAM

    cat > "$upstream_dir/agents/system-architect.md" <<'UPSTREAM'
# System Architect

Project: {{PROJECT_NAME}}

Standard upstream system architect agent.
UPSTREAM

    cat > "$upstream_dir/agents/qas.md" <<'UPSTREAM'
# QA Specialist

Project: {{PROJECT_NAME}}

Standard upstream QAS agent.
UPSTREAM

    cat > "$upstream_dir/hooks-config.json" <<'UPSTREAM'
{
  "description": "Upstream hooks config template",
  "hooks": {
    "pre-commit": {
      "command": "echo 'run lint'",
      "description": "Generic lint command"
    }
  }
}
UPSTREAM

    cat > "$upstream_dir/team-config.json" <<'UPSTREAM'
{
  "description": "Upstream team config template",
  "team_name": "{{PROJECT_NAME}} Team",
  "ticket_prefix": "{{TICKET_PREFIX}}",
  "main_branch": "{{MAIN_BRANCH}}"
}
UPSTREAM

    cat > "$upstream_dir/skills/stripe-patterns/SKILL.md" <<'UPSTREAM'
# Stripe Patterns Skill

Project: {{PROJECT_NAME}}

Standard upstream stripe patterns skill.
UPSTREAM

    cat > "$upstream_dir/commands/start-work.md" <<'UPSTREAM'
# Start Work

Begin a new {{TICKET_PREFIX}} ticket.
UPSTREAM

    echo "$upstream_dir"
}

# Create a patched version of the sync script that stubs network calls
# and uses a local mock upstream directory instead of fetching from GitHub.
#
# Usage: create_stubbed_script "$proj_dir" "$upstream_dir"
create_stubbed_script() {
    local proj_dir="$1"
    local upstream_base="$2"  # Path to _mock_upstream (parent of .claude/)
    local script="$proj_dir/scripts/sync-claude-harness.sh"

    # Patch fetch_upstream to copy from mock upstream instead of downloading
    # Patch get_upstream_sha to return a fixed hash
    # Patch get_latest_release to return a fixed version
    # Patch check_dependencies to skip curl requirement
    local patched="$proj_dir/scripts/sync-patched.sh"
    cp "$script" "$patched"

    # Use Python to replace function bodies. The regex matches from the
    # function declaration to the next line that starts with exactly '}' at
    # column 0 (end of top-level function).
    python3 << PYEOF
import re, sys

with open('$patched', 'r') as f:
    content = f.read()

def replace_func(content, func_name, new_body):
    """Replace a top-level bash function body.
    Matches 'func_name() {' through the next line that is exactly '}'.
    """
    pattern = r'^(' + re.escape(func_name) + r'\(\) \{)\n.*?\n(\})\s*$'
    replacement = func_name + '() {\n' + new_body + '\n}'
    result = re.sub(pattern, replacement, content, count=1, flags=re.DOTALL | re.MULTILINE)
    return result

upstream_base = '$upstream_base'

content = replace_func(content, 'fetch_upstream',
    '    local ref="\${1:-\$UPSTREAM_BRANCH}"\n'
    '    print_info "Fetching upstream from mock directory..."\n'
    '    mkdir -p "\$TMP_DIR"\n'
    '    cp -r "' + upstream_base + '/.claude" "\$TMP_DIR/.claude"\n'
    '    print_success "Fetched upstream (mock)"')

content = replace_func(content, 'get_upstream_sha',
    '    echo "deadbeef1234567890abcdef1234567890abcdef"')

content = replace_func(content, 'get_latest_release',
    '    echo "v2.7.0"')

content = replace_func(content, 'check_dependencies',
    '    if ! command -v node &> /dev/null; then\n'
    '        echo -e "\${RED}[ERROR]\${NC} node is required but not installed."\n'
    '        exit 1\n'
    '    fi')

with open('$patched', 'w') as f:
    f.write(content)
PYEOF

    chmod +x "$patched"
    echo "$patched"
}

# ---------------------------------------------------------------------------
# Prerequisite checks
# ---------------------------------------------------------------------------

echo -e "\n${CYAN}=== Fork Sync Compatibility Tests (SAW-9) ===${NC}\n"

# Verify prerequisites
if ! command -v node &> /dev/null; then
    echo -e "${RED}SKIP: node not found (required for sync script)${NC}"
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}SKIP: python3 not found (required for YAML parsing)${NC}"
    exit 1
fi

# Check PyYAML availability
if ! python3 -c "import yaml" 2>/dev/null; then
    echo -e "${RED}SKIP: PyYAML not installed (pip install pyyaml)${NC}"
    exit 1
fi

# Verify fixture directories exist
if [ ! -d "$FIXTURES_DIR/rendertrust" ] || [ ! -d "$FIXTURES_DIR/keryk-ai" ]; then
    echo -e "${RED}SKIP: Fixture directories not found at $FIXTURES_DIR${NC}"
    exit 1
fi

echo -e "Prerequisites satisfied: node, python3, PyYAML\n"

# =============================================================================
# SECTION 1: RenderTrust fork (no renames, protected files, substitutions)
# =============================================================================

echo -e "${CYAN}=== Section 1: RenderTrust Fork ===${NC}\n"

# --- Test 1.1: Manifest loads and validates ---
echo -e "${CYAN}--- Test 1.1: Manifest loading and validation ---${NC}"

PROJ=$(setup_fork_project "rendertrust" "rt-manifest")
UPSTREAM=$(setup_mock_upstream "$PROJ")
STUBBED=$(create_stubbed_script "$PROJ" "$PROJ/_mock_upstream")

# Run init - should detect manifest
output=$("$STUBBED" init 2>&1) || true
assert_contains "$output" "Created" "init creates sync config"
assert_contains "$output" "Manifest found" "manifest detected during init"

# Run status - should show manifest info
output=$("$STUBBED" status 2>&1) || true
assert_contains "$output" "Manifest:" "status shows manifest info"
assert_contains "$output" "Renames:       0" "no renames detected for rendertrust"
assert_contains "$output" "Protected:     2" "2 protected patterns detected"

# --- Test 1.2: Protected files respected during diff ---
echo -e "\n${CYAN}--- Test 1.2: Protected files in diff ---${NC}"

PROJ=$(setup_fork_project "rendertrust" "rt-protected-diff")
UPSTREAM=$(setup_mock_upstream "$PROJ")
STUBBED=$(create_stubbed_script "$PROJ" "$PROJ/_mock_upstream")

output=$("$STUBBED" diff 2>&1) || true
assert_contains "$output" "PROTECTED" "diff shows PROTECTED label for manifest-protected files"
assert_contains "$output" "hooks-config.json" "hooks-config.json identified in diff"
assert_contains "$output" "team-config.json" "team-config.json identified in diff"

# --- Test 1.3: Sync dry-run completes without errors ---
echo -e "\n${CYAN}--- Test 1.3: Sync --dry-run (RenderTrust) ---${NC}"

PROJ=$(setup_fork_project "rendertrust" "rt-dryrun")
UPSTREAM=$(setup_mock_upstream "$PROJ")
STUBBED=$(create_stubbed_script "$PROJ" "$PROJ/_mock_upstream")

output=$("$STUBBED" sync --dry-run --skip-preflight 2>&1)
rc=$?
assert_exit_code "$rc" 0 "sync --dry-run exits 0 for rendertrust"
assert_contains "$output" "Dry Run" "dry-run header shown"
assert_contains "$output" "Summary:" "summary line present"
assert_not_contains "$output" "ERROR" "no errors during dry-run"

# --- Test 1.4: Protected files not overwritten during sync ---
echo -e "\n${CYAN}--- Test 1.4: Protected file enforcement during sync ---${NC}"

PROJ=$(setup_fork_project "rendertrust" "rt-protected-sync")
UPSTREAM=$(setup_mock_upstream "$PROJ")
STUBBED=$(create_stubbed_script "$PROJ" "$PROJ/_mock_upstream")

# Record original content of protected files
original_hooks=$(cat "$PROJ/.claude/hooks-config.json")
original_team=$(cat "$PROJ/.claude/team-config.json")

# Run actual sync (not dry-run) -- skip preflight to avoid token check
# since we are testing protection, not substitution
output=$("$STUBBED" sync --skip-preflight 2>&1) || true

# Verify protected files were NOT overwritten
current_hooks=$(cat "$PROJ/.claude/hooks-config.json")
current_team=$(cat "$PROJ/.claude/team-config.json")

TOTAL=$((TOTAL + 1))
if [ "$original_hooks" = "$current_hooks" ]; then
    echo -e "  ${GREEN}PASS${NC} hooks-config.json preserved during sync"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} hooks-config.json was modified during sync"
    FAIL=$((FAIL + 1))
fi

TOTAL=$((TOTAL + 1))
if [ "$original_team" = "$current_team" ]; then
    echo -e "  ${GREEN}PASS${NC} team-config.json preserved during sync"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} team-config.json was modified during sync"
    FAIL=$((FAIL + 1))
fi

assert_contains "$output" "Skipping protected" "sync reports skipping protected files"

# --- Test 1.5: Substitutions applied to synced files ---
echo -e "\n${CYAN}--- Test 1.5: Identity substitutions (RenderTrust) ---${NC}"

PROJ=$(setup_fork_project "rendertrust" "rt-substitutions")
UPSTREAM=$(setup_mock_upstream "$PROJ")
STUBBED=$(create_stubbed_script "$PROJ" "$PROJ/_mock_upstream")

# Remove existing files that will be synced so they show as "new"
rm -f "$PROJ/.claude/agents/qas.md"
rm -f "$PROJ/.claude/commands/start-work.md"

# Run sync (with substitutions, skip preflight for token check since
# we want to verify substitutions actually get applied)
output=$("$STUBBED" sync --skip-preflight 2>&1) || true

# Verify substitutions were applied to newly synced files
assert_file_contains "$PROJ/.claude/agents/qas.md" "RenderTrust" \
    "{{PROJECT_NAME}} replaced with RenderTrust in qas.md"
assert_file_not_contains "$PROJ/.claude/agents/qas.md" "{{PROJECT_NAME}}" \
    "no unreplaced {{PROJECT_NAME}} tokens in qas.md"

if [ -f "$PROJ/.claude/commands/start-work.md" ]; then
    assert_file_contains "$PROJ/.claude/commands/start-work.md" "REN" \
        "{{TICKET_PREFIX}} replaced with REN in start-work.md"
fi


# =============================================================================
# SECTION 2: Keryk AI fork (renames, directory renames, protected, replaced)
# =============================================================================

echo -e "\n${CYAN}=== Section 2: Keryk AI Fork ===${NC}\n"

# --- Test 2.1: Manifest loads with renames ---
echo -e "${CYAN}--- Test 2.1: Manifest loading with renames ---${NC}"

PROJ=$(setup_fork_project "keryk-ai" "ka-manifest")
UPSTREAM=$(setup_mock_upstream "$PROJ")
STUBBED=$(create_stubbed_script "$PROJ" "$PROJ/_mock_upstream")

output=$("$STUBBED" init 2>&1) || true
assert_contains "$output" "Manifest found" "manifest detected for keryk-ai"

output=$("$STUBBED" status 2>&1) || true
assert_contains "$output" "Renames:       4" "4 renames detected (3 files + 1 dir)"
assert_contains "$output" "Protected:     4" "4 protected patterns detected"
assert_contains "$output" "agents/fe-developer.md -> agents/ui-engineer.md" \
    "FE developer rename shown in status"
assert_contains "$output" "skills/stripe-patterns/ -> skills/payment-patterns/" \
    "skill directory rename shown in status"

# --- Test 2.2: Renames resolved in diff ---
echo -e "\n${CYAN}--- Test 2.2: Rename-aware diff ---${NC}"

PROJ=$(setup_fork_project "keryk-ai" "ka-rename-diff")
UPSTREAM=$(setup_mock_upstream "$PROJ")
STUBBED=$(create_stubbed_script "$PROJ" "$PROJ/_mock_upstream")

output=$("$STUBBED" diff 2>&1) || true

# The diff should reference the renamed local paths
assert_contains "$output" "ui-engineer" "diff references renamed ui-engineer (not fe-developer)"
assert_contains "$output" "api-engineer" "diff references renamed api-engineer (not be-developer)"
assert_contains "$output" "payment-patterns" "diff references renamed payment-patterns directory"

# Protected files should be labeled
assert_contains "$output" "PROTECTED" "diff shows PROTECTED for protected files"

# --- Test 2.3: Sync dry-run with renames ---
echo -e "\n${CYAN}--- Test 2.3: Sync --dry-run (Keryk AI) ---${NC}"

PROJ=$(setup_fork_project "keryk-ai" "ka-dryrun")
UPSTREAM=$(setup_mock_upstream "$PROJ")
STUBBED=$(create_stubbed_script "$PROJ" "$PROJ/_mock_upstream")

output=$("$STUBBED" sync --dry-run --skip-preflight 2>&1)
rc=$?
assert_exit_code "$rc" 0 "sync --dry-run exits 0 for keryk-ai"
assert_contains "$output" "Dry Run" "dry-run header shown"
assert_not_contains "$output" "ERROR" "no errors during keryk-ai dry-run"

# --- Test 2.4: Renames resolve correctly during sync ---
echo -e "\n${CYAN}--- Test 2.4: Rename resolution during sync ---${NC}"

PROJ=$(setup_fork_project "keryk-ai" "ka-rename-sync")
UPSTREAM=$(setup_mock_upstream "$PROJ")
STUBBED=$(create_stubbed_script "$PROJ" "$PROJ/_mock_upstream")

# Remove the renamed files so they show up as "new" for sync
rm -f "$PROJ/.claude/agents/ui-engineer.md"
rm -f "$PROJ/.claude/agents/api-engineer.md"
rm -f "$PROJ/.claude/agents/ml-engineer.md"
rm -rf "$PROJ/.claude/skills/payment-patterns"

output=$("$STUBBED" sync --skip-preflight 2>&1) || true

# After sync, files should appear at renamed locations (not upstream names)
assert_file_exists "$PROJ/.claude/agents/ui-engineer.md" \
    "fe-developer.md synced to ui-engineer.md via rename"
assert_file_exists "$PROJ/.claude/agents/api-engineer.md" \
    "be-developer.md synced to api-engineer.md via rename"
assert_file_exists "$PROJ/.claude/agents/ml-engineer.md" \
    "data-engineer.md synced to ml-engineer.md via rename"

# The upstream-named files should NOT exist
TOTAL=$((TOTAL + 1))
if [ ! -f "$PROJ/.claude/agents/fe-developer.md" ]; then
    echo -e "  ${GREEN}PASS${NC} fe-developer.md NOT created (rename target used instead)"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} fe-developer.md incorrectly created (should use rename target)"
    FAIL=$((FAIL + 1))
fi

# Check directory rename: stripe-patterns/ -> payment-patterns/
if [ -d "$PROJ/.claude/skills/payment-patterns" ]; then
    assert_file_exists "$PROJ/.claude/skills/payment-patterns/SKILL.md" \
        "stripe-patterns/SKILL.md synced to payment-patterns/SKILL.md via dir rename"
fi

# --- Test 2.5: Protected files not modified (Keryk AI) ---
echo -e "\n${CYAN}--- Test 2.5: Protected files during Keryk AI sync ---${NC}"

PROJ=$(setup_fork_project "keryk-ai" "ka-protected")
UPSTREAM=$(setup_mock_upstream "$PROJ")
STUBBED=$(create_stubbed_script "$PROJ" "$PROJ/_mock_upstream")

original_hooks=$(cat "$PROJ/.claude/hooks-config.json")
original_team=$(cat "$PROJ/.claude/team-config.json")
original_settings=$(cat "$PROJ/.claude/settings.local.json")
original_mlops=$(cat "$PROJ/.claude/agents/ml-ops-engineer.md")

output=$("$STUBBED" sync --skip-preflight 2>&1) || true

current_hooks=$(cat "$PROJ/.claude/hooks-config.json")
current_team=$(cat "$PROJ/.claude/team-config.json")
current_settings=$(cat "$PROJ/.claude/settings.local.json")
current_mlops=$(cat "$PROJ/.claude/agents/ml-ops-engineer.md")

TOTAL=$((TOTAL + 1))
if [ "$original_hooks" = "$current_hooks" ]; then
    echo -e "  ${GREEN}PASS${NC} hooks-config.json preserved (keryk-ai)"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} hooks-config.json was modified (keryk-ai)"
    FAIL=$((FAIL + 1))
fi

TOTAL=$((TOTAL + 1))
if [ "$original_team" = "$current_team" ]; then
    echo -e "  ${GREEN}PASS${NC} team-config.json preserved (keryk-ai)"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} team-config.json was modified (keryk-ai)"
    FAIL=$((FAIL + 1))
fi

TOTAL=$((TOTAL + 1))
if [ "$original_settings" = "$current_settings" ]; then
    echo -e "  ${GREEN}PASS${NC} settings.local.json preserved (keryk-ai)"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} settings.local.json was modified (keryk-ai)"
    FAIL=$((FAIL + 1))
fi

TOTAL=$((TOTAL + 1))
if [ "$original_mlops" = "$current_mlops" ]; then
    echo -e "  ${GREEN}PASS${NC} agents/ml-ops-engineer.md preserved (keryk-ai custom agent)"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} agents/ml-ops-engineer.md was modified (keryk-ai)"
    FAIL=$((FAIL + 1))
fi

# --- Test 2.6: Substitutions applied with Keryk AI identity ---
echo -e "\n${CYAN}--- Test 2.6: Identity substitutions (Keryk AI) ---${NC}"

PROJ=$(setup_fork_project "keryk-ai" "ka-substitutions")
UPSTREAM=$(setup_mock_upstream "$PROJ")
STUBBED=$(create_stubbed_script "$PROJ" "$PROJ/_mock_upstream")

# Remove QAS agent so it syncs as "new"
rm -f "$PROJ/.claude/agents/qas.md"

output=$("$STUBBED" sync --skip-preflight 2>&1) || true

# Verify Keryk AI identity values were substituted
if [ -f "$PROJ/.claude/agents/qas.md" ]; then
    assert_file_contains "$PROJ/.claude/agents/qas.md" "ScaleForge" \
        "{{PROJECT_NAME}} replaced with ScaleForge in qas.md"
    assert_file_not_contains "$PROJ/.claude/agents/qas.md" "{{PROJECT_NAME}}" \
        "no unreplaced {{PROJECT_NAME}} tokens in qas.md (keryk-ai)"
fi


# =============================================================================
# SECTION 3: Cross-fork validation (both forks together)
# =============================================================================

echo -e "\n${CYAN}=== Section 3: Cross-Fork Validation ===${NC}\n"

# --- Test 3.1: Manifest validation catches invalid manifests ---
echo -e "${CYAN}--- Test 3.1: Invalid manifest detection ---${NC}"

PROJ=$(setup_fork_project "rendertrust" "invalid-manifest")
UPSTREAM=$(setup_mock_upstream "$PROJ")
STUBBED=$(create_stubbed_script "$PROJ" "$PROJ/_mock_upstream")

# Write an invalid manifest (missing required fields)
cat > "$PROJ/.claude/.harness-manifest.yml" <<'EOF'
manifest_version: "1.0"
# Missing required identity section entirely
renames: {}
EOF

rc=0
output=$("$STUBBED" status 2>&1) || rc=$?
assert_exit_code "$rc" 1 "status exits 1 for invalid manifest"
assert_contains "$output" "identity" "error mentions missing identity"

# --- Test 3.2: Bad manifest_version pattern ---
echo -e "\n${CYAN}--- Test 3.2: Bad manifest_version format ---${NC}"

PROJ=$(setup_fork_project "rendertrust" "bad-version")
UPSTREAM=$(setup_mock_upstream "$PROJ")
STUBBED=$(create_stubbed_script "$PROJ" "$PROJ/_mock_upstream")

cat > "$PROJ/.claude/.harness-manifest.yml" <<'EOF'
manifest_version: "abc"
identity:
  PROJECT_NAME: "Test"
  PROJECT_REPO: "test"
  PROJECT_SHORT: "TST"
  GITHUB_ORG: "test-org"
  TICKET_PREFIX: "TST"
  MAIN_BRANCH: "main"
EOF

rc=0
output=$("$STUBBED" status 2>&1) || rc=$?
assert_exit_code "$rc" 1 "status exits 1 for bad manifest_version"
assert_contains "$output" "manifest_version" "error mentions manifest_version"

# --- Test 3.3: Preflight catches protected file writes ---
echo -e "\n${CYAN}--- Test 3.3: Preflight blocks protected file modification ---${NC}"

PROJ=$(setup_fork_project "rendertrust" "preflight-protected")
UPSTREAM=$(setup_mock_upstream "$PROJ")
STUBBED=$(create_stubbed_script "$PROJ" "$PROJ/_mock_upstream")

# Force hooks-config.json to differ from upstream so sync would want to write it
# But since it is protected, the preflight should block it
# Note: The exclusion check happens BEFORE preflight, so protected files
# are already skipped. Preflight is an extra safety net for edge cases.
# This test verifies the overall protection pipeline works end-to-end.

output=$("$STUBBED" sync --dry-run 2>&1) || true
rc=$?

# Protected files should be skipped (not attempted)
assert_contains "$output" "Skipping protected: hooks-config.json" \
    "protected file hooks-config.json skipped in sync"

# --- Test 3.4: Help command works (basic sanity) ---
echo -e "\n${CYAN}--- Test 3.4: Help command sanity ---${NC}"

output=$("$SYNC_SCRIPT" help 2>&1)
rc=$?
assert_exit_code "$rc" 0 "help exits 0"
assert_contains "$output" "sync" "help mentions sync command"
assert_contains "$output" "diff" "help mentions diff command"
assert_contains "$output" "manifest" "help mentions manifest"


# =============================================================================
# SECTION 4: Schema and fixture integrity
# =============================================================================

echo -e "\n${CYAN}=== Section 4: Schema & Fixture Integrity ===${NC}\n"

# --- Test 4.1: Fixture manifests are valid YAML ---
echo -e "${CYAN}--- Test 4.1: Fixture manifests are valid YAML ---${NC}"

for fixture in rendertrust keryk-ai; do
    manifest="$FIXTURES_DIR/$fixture/.harness-manifest.yml"
    TOTAL=$((TOTAL + 1))
    if python3 -c "
import yaml, sys
with open(sys.argv[1]) as f:
    data = yaml.safe_load(f)
if not isinstance(data, dict):
    sys.exit(1)
if 'manifest_version' not in data:
    sys.exit(1)
if 'identity' not in data:
    sys.exit(1)
" "$manifest" 2>/dev/null; then
        echo -e "  ${GREEN}PASS${NC} $fixture manifest is valid YAML with required fields"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $fixture manifest has invalid YAML or missing fields"
        FAIL=$((FAIL + 1))
    fi
done

# --- Test 4.2: Fixture manifests match example manifests (key fields) ---
echo -e "\n${CYAN}--- Test 4.2: Fixture manifests match examples ---${NC}"

for fixture in rendertrust keryk-ai; do
    fixture_manifest="$FIXTURES_DIR/$fixture/.harness-manifest.yml"
    example_manifest="$REPO_ROOT/examples/manifests/$fixture.harness-manifest.yml"

    if [ ! -f "$example_manifest" ]; then
        TOTAL=$((TOTAL + 1))
        echo -e "  ${YELLOW}SKIP${NC} $fixture example manifest not found (expected at $example_manifest)"
        continue
    fi

    # Compare key identity fields
    TOTAL=$((TOTAL + 1))
    fixture_name=$(python3 -c "
import yaml, sys
with open(sys.argv[1]) as f:
    data = yaml.safe_load(f)
print(data.get('identity', {}).get('PROJECT_NAME', ''))
" "$fixture_manifest" 2>/dev/null)
    example_name=$(python3 -c "
import yaml, sys
with open(sys.argv[1]) as f:
    data = yaml.safe_load(f)
print(data.get('identity', {}).get('PROJECT_NAME', ''))
" "$example_manifest" 2>/dev/null)

    if [ "$fixture_name" = "$example_name" ] && [ -n "$fixture_name" ]; then
        echo -e "  ${GREEN}PASS${NC} $fixture fixture PROJECT_NAME matches example ($fixture_name)"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $fixture fixture PROJECT_NAME mismatch (fixture=$fixture_name, example=$example_name)"
        FAIL=$((FAIL + 1))
    fi
done

# --- Test 4.3: Fixture .claude/ directories have expected structure ---
echo -e "\n${CYAN}--- Test 4.3: Fixture directory structure ---${NC}"

# RenderTrust should have standard upstream file names (no renames)
assert_file_exists "$FIXTURES_DIR/rendertrust/.claude/agents/be-developer.md" \
    "rendertrust fixture has agents/be-developer.md (no rename)"
assert_file_exists "$FIXTURES_DIR/rendertrust/.claude/hooks-config.json" \
    "rendertrust fixture has hooks-config.json (protected)"

# Keryk AI should have RENAMED file names
assert_file_exists "$FIXTURES_DIR/keryk-ai/.claude/agents/ui-engineer.md" \
    "keryk-ai fixture has agents/ui-engineer.md (renamed from fe-developer)"
assert_file_exists "$FIXTURES_DIR/keryk-ai/.claude/agents/api-engineer.md" \
    "keryk-ai fixture has agents/api-engineer.md (renamed from be-developer)"
assert_file_exists "$FIXTURES_DIR/keryk-ai/.claude/agents/ml-engineer.md" \
    "keryk-ai fixture has agents/ml-engineer.md (renamed from data-engineer)"
assert_file_exists "$FIXTURES_DIR/keryk-ai/.claude/skills/payment-patterns/SKILL.md" \
    "keryk-ai fixture has skills/payment-patterns/ (renamed from stripe-patterns/)"
assert_file_exists "$FIXTURES_DIR/keryk-ai/.claude/agents/ml-ops-engineer.md" \
    "keryk-ai fixture has custom agents/ml-ops-engineer.md (protected)"


# =============================================================================
# Results
# =============================================================================

echo ""
echo -e "${CYAN}=== Results ===${NC}"
echo ""
echo -e "  Total:  $TOTAL"
echo -e "  ${GREEN}Passed: $PASS${NC}"
if [ "$FAIL" -gt 0 ]; then
    echo -e "  ${RED}Failed: $FAIL${NC}"
fi
echo ""

if [ "$FAIL" -gt 0 ]; then
    echo -e "${RED}FORK SYNC COMPATIBILITY TESTS FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}ALL FORK SYNC COMPATIBILITY TESTS PASSED${NC}"
    exit 0
fi
