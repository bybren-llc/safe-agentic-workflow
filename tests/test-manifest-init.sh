#!/bin/bash
# =============================================================================
# Test: Manifest Init Wizard (SAW-12)
# =============================================================================
# Tests all AC items for the manifest init command.
# Run from repo root: bash tests/test-manifest-init.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SYNC_SCRIPT="$REPO_ROOT/scripts/sync-claude-harness.sh"

# Create a temporary project structure for testing
TEST_DIR=$(mktemp -d /tmp/manifest-init-test-XXXXXX)
trap "rm -rf $TEST_DIR" EXIT

PASS=0
FAIL=0
TOTAL=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

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
        echo -e "  ${RED}FAIL${NC} $label (file should NOT exist: $path)"
        FAIL=$((FAIL + 1))
    fi
}

# Setup: create a fake project dir with team-config.json
setup_project() {
    local proj_dir="$TEST_DIR/project-$1"
    mkdir -p "$proj_dir/.claude"
    mkdir -p "$proj_dir/scripts"
    cp "$SYNC_SCRIPT" "$proj_dir/scripts/sync-claude-harness.sh"
    chmod +x "$proj_dir/scripts/sync-claude-harness.sh"
    echo "$proj_dir"
}

# Create a team-config.json with replaced values (simulating a downstream fork)
create_team_config_replaced() {
    local proj_dir="$1"
    cat > "$proj_dir/.claude/team-config.json" <<'JSON'
{
  "project": {
    "name": "RenderTrust",
    "short_name": "REN",
    "repo": "rendertrust",
    "domain": "rendertrust.com",
    "github_org": "ByBren-LLC",
    "company": "ByBren, LLC"
  },
  "workflow": {
    "ticket_prefix": "REN",
    "ticket_prefix_lower": "ren",
    "main_branch": "dev",
    "linear_workspace": "cheddarfox",
    "branch_format": "REN-{number}-{description}",
    "commit_format": "type(scope): description [REN-XXX]",
    "merge_strategy": "rebase-and-merge"
  },
  "mcp_servers": {
    "linear": "claude_ai_Linear",
    "confluence": "claude_ai_Atlassian"
  },
  "review_stages": {
    "stage_1": { "reviewer": "system-architect" },
    "stage_2": { "reviewer": "cheddarfox" },
    "stage_3": { "reviewer": "cheddarfox" }
  }
}
JSON
}

# Create a team-config.json with unreplaced placeholders (template state)
create_team_config_template() {
    local proj_dir="$1"
    cat > "$proj_dir/.claude/team-config.json" <<'JSON'
{
  "project": {
    "name": "{{PROJECT_NAME}}",
    "short_name": "{{PROJECT_SHORT}}",
    "repo": "{{PROJECT_REPO}}",
    "domain": "{{PROJECT_DOMAIN}}",
    "github_org": "{{GITHUB_ORG}}",
    "company": "{{COMPANY_NAME}}"
  },
  "workflow": {
    "ticket_prefix": "{{TICKET_PREFIX}}",
    "ticket_prefix_lower": "{{TICKET_PREFIX_LOWER}}",
    "main_branch": "{{MAIN_BRANCH}}",
    "linear_workspace": "{{LINEAR_WORKSPACE}}"
  },
  "mcp_servers": {
    "linear": "{{MCP_LINEAR_SERVER}}",
    "confluence": "{{MCP_CONFLUENCE_SERVER}}"
  },
  "review_stages": {
    "stage_2": { "reviewer": "{{ARCHITECT_GITHUB_HANDLE}}" },
    "stage_3": { "reviewer": "{{AUTHOR_HANDLE}}" }
  }
}
JSON
}

# Create a .sync-exclude file
create_sync_exclude() {
    local proj_dir="$1"
    cat > "$proj_dir/.claude/.sync-exclude" <<'EXCLUDE'
# Claude Harness Sync Exclusions
settings.local.json
hooks-config.json
agents/custom-*.md
EXCLUDE
}

# =============================================================================
echo -e "\n${CYAN}=== Test 1: manifest init --dry-run with replaced team-config ===${NC}\n"
# AC: --dry-run prints manifest to stdout without writing
# AC: Reads team-config.json to extract identity values
# =============================================================================
PROJ=$(setup_project "dry-run-replaced")
create_team_config_replaced "$PROJ"

output=$("$PROJ/scripts/sync-claude-harness.sh" manifest init --dry-run 2>&1)
ec=$?
assert_exit_code "$ec" 0 "manifest init --dry-run exits 0"
assert_contains "$output" "dry-run" "dry-run message present"
assert_contains "$output" "manifest_version" "output contains manifest_version"
assert_contains "$output" "RenderTrust" "output contains PROJECT_NAME from team-config"
assert_contains "$output" "rendertrust" "output contains PROJECT_REPO from team-config"
assert_contains "$output" "ByBren-LLC" "output contains GITHUB_ORG from team-config"
assert_contains "$output" 'TICKET_PREFIX: "REN"' "output contains TICKET_PREFIX from team-config"
assert_contains "$output" 'MAIN_BRANCH: "dev"' "output contains MAIN_BRANCH from team-config"
assert_file_not_exists "$PROJ/.harness-manifest.yml" "manifest NOT written in dry-run mode"

# =============================================================================
echo -e "\n${CYAN}=== Test 2: manifest init --yes writes file ===${NC}\n"
# AC: sync manifest init generates .harness-manifest.yml
# AC: --yes skips confirmation prompts
# =============================================================================
PROJ=$(setup_project "write-yes")
create_team_config_replaced "$PROJ"

output=$("$PROJ/scripts/sync-claude-harness.sh" manifest init --yes 2>&1)
ec=$?
assert_exit_code "$ec" 0 "manifest init --yes exits 0"
assert_file_exists "$PROJ/.harness-manifest.yml" "manifest file created"
assert_contains "$output" "Manifest written" "success message present"

# Verify the content is valid YAML
content=$(cat "$PROJ/.harness-manifest.yml")
assert_contains "$content" 'manifest_version: "1.0"' "written file has manifest_version"
assert_contains "$content" 'PROJECT_NAME: "RenderTrust"' "written file has PROJECT_NAME"

# =============================================================================
echo -e "\n${CYAN}=== Test 3: Reads .sync-exclude for protected patterns ===${NC}\n"
# AC: Reads .sync-exclude and converts entries to protected section
# =============================================================================
PROJ=$(setup_project "sync-exclude")
create_team_config_replaced "$PROJ"
create_sync_exclude "$PROJ"

output=$("$PROJ/scripts/sync-claude-harness.sh" manifest init --dry-run 2>&1)
assert_contains "$output" "settings.local.json" "protected includes settings.local.json from .sync-exclude"
assert_contains "$output" "hooks-config.json" "protected includes hooks-config.json from .sync-exclude"
assert_contains "$output" "agents/custom-\*.md" "protected includes glob pattern from .sync-exclude"
assert_contains "$output" "protected pattern" "reports protected pattern count"

# =============================================================================
echo -e "\n${CYAN}=== Test 4: Template (unreplaced) team-config ===${NC}\n"
# AC: Detects which placeholders have been replaced and with what values
# =============================================================================
PROJ=$(setup_project "template-config")
create_team_config_template "$PROJ"

output=$("$PROJ/scripts/sync-claude-harness.sh" manifest init --dry-run 2>&1)
# With unreplaced placeholders, identity values should still be {{...}} placeholders
assert_contains "$output" '{{PROJECT_NAME}}' "unreplaced PROJECT_NAME kept as placeholder"
assert_contains "$output" '{{TICKET_PREFIX}}' "unreplaced TICKET_PREFIX kept as placeholder"
assert_contains "$output" "incomplete fields" "warns about incomplete fields"

# =============================================================================
echo -e "\n${CYAN}=== Test 5: No team-config.json ===${NC}\n"
# AC: Handles missing team-config.json gracefully
# =============================================================================
PROJ=$(setup_project "no-config")

output=$("$PROJ/scripts/sync-claude-harness.sh" manifest init --dry-run 2>&1)
ec=$?
assert_exit_code "$ec" 0 "exits 0 even without team-config"
assert_contains "$output" "No team-config.json" "warns about missing team-config"
assert_contains "$output" "manifest_version" "still generates valid manifest structure"

# =============================================================================
echo -e "\n${CYAN}=== Test 6: Substitutions section populated ===${NC}\n"
# AC: Populates substitutions section with detected replacements
# =============================================================================
PROJ=$(setup_project "substitutions")
create_team_config_replaced "$PROJ"

output=$("$PROJ/scripts/sync-claude-harness.sh" manifest init --dry-run 2>&1)
assert_contains "$output" "substitutions:" "substitutions section present"
# Should contain the actual values as substitutions
assert_contains "$output" 'GITHUB_ORG: "ByBren-LLC"' "substitutions includes GITHUB_ORG value"

# =============================================================================
echo -e "\n${CYAN}=== Test 7: Generated manifest validates against schema ===${NC}\n"
# AC: Generated manifest validates against the JSON Schema
# =============================================================================
PROJ=$(setup_project "validates")
create_team_config_replaced "$PROJ"

output=$("$PROJ/scripts/sync-claude-harness.sh" manifest init --yes 2>&1)
assert_contains "$output" "passes schema validation" "reports schema validation pass"

# Now run manifest validate on the written file
output=$("$PROJ/scripts/sync-claude-harness.sh" manifest validate 2>&1)
ec=$?
assert_exit_code "$ec" 0 "manifest validate exits 0 on valid manifest"
assert_contains "$output" "Manifest found" "validate reports manifest found"

# =============================================================================
echo -e "\n${CYAN}=== Test 8: Overwrite protection ===${NC}\n"
# AC: Does not silently overwrite existing manifest
# =============================================================================
PROJ=$(setup_project "overwrite")
create_team_config_replaced "$PROJ"

# Create an existing manifest
cat > "$PROJ/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "ExistingProject"
  PROJECT_REPO: "existing"
  PROJECT_SHORT: "EXI"
  GITHUB_ORG: "existing-org"
  TICKET_PREFIX: "EXI"
  MAIN_BRANCH: "main"
YAML

# With --yes, it should overwrite
output=$("$PROJ/scripts/sync-claude-harness.sh" manifest init --yes 2>&1)
assert_contains "$output" "already exists" "warns about existing manifest"
assert_contains "$output" "Manifest written" "overwrites with --yes"

# The content should now be the new generated one, not the old one
content=$(cat "$PROJ/.harness-manifest.yml")
assert_contains "$content" "RenderTrust" "overwritten with new values"
assert_not_contains "$content" "ExistingProject" "old values replaced"

# =============================================================================
echo -e "\n${CYAN}=== Test 9: manifest validate on missing manifest ===${NC}\n"
# =============================================================================
PROJ=$(setup_project "validate-missing")

output=$("$PROJ/scripts/sync-claude-harness.sh" manifest validate 2>&1 || true)
ec=$?
assert_contains "$output" "No manifest found" "reports missing manifest"

# =============================================================================
echo -e "\n${CYAN}=== Test 10: manifest subcommand help ===${NC}\n"
# =============================================================================
PROJ=$(setup_project "manifest-help")

output=$("$PROJ/scripts/sync-claude-harness.sh" manifest 2>&1 || true)
assert_contains "$output" "init" "help shows init subcommand"
assert_contains "$output" "validate" "help shows validate subcommand"
assert_contains "$output" "dry-run" "help shows dry-run option"

# =============================================================================
echo -e "\n${CYAN}=== Test 11: Derived values computed ===${NC}\n"
# AC: Derived values like TICKET_PREFIX_LOWER computed from identity
# =============================================================================
PROJ=$(setup_project "derived")
create_team_config_replaced "$PROJ"

output=$("$PROJ/scripts/sync-claude-harness.sh" manifest init --dry-run 2>&1)
# Should detect derived substitutions
assert_contains "$output" "derived substitution" "reports derived substitutions found"

# =============================================================================
echo -e "\n${CYAN}=== Test 12: Sync preferences section populated ===${NC}\n"
# AC: Generated manifest includes sync preferences with defaults
# =============================================================================
PROJ=$(setup_project "sync-prefs")
create_team_config_replaced "$PROJ"

output=$("$PROJ/scripts/sync-claude-harness.sh" manifest init --dry-run 2>&1)
assert_contains "$output" "auto_substitute: true" "sync auto_substitute default present"
assert_contains "$output" "backup: true" "sync backup default present"
assert_contains "$output" 'conflict_strategy: "prompt"' "sync conflict_strategy default present"
assert_contains "$output" '".md"' "substitution_extensions includes .md"

# =============================================================================
echo -e "\n${CYAN}=== Test 13: Partial team-config (some values replaced, some not) ===${NC}\n"
# =============================================================================
PROJ=$(setup_project "partial-config")
cat > "$PROJ/.claude/team-config.json" <<'JSON'
{
  "project": {
    "name": "MyProject",
    "short_name": "MYP",
    "repo": "my-project",
    "domain": "{{PROJECT_DOMAIN}}",
    "github_org": "my-org",
    "company": "{{COMPANY_NAME}}"
  },
  "workflow": {
    "ticket_prefix": "MYP",
    "main_branch": "main",
    "linear_workspace": "{{LINEAR_WORKSPACE}}"
  },
  "mcp_servers": {
    "linear": "{{MCP_LINEAR_SERVER}}",
    "confluence": "{{MCP_CONFLUENCE_SERVER}}"
  },
  "review_stages": {
    "stage_2": { "reviewer": "{{ARCHITECT_GITHUB_HANDLE}}" },
    "stage_3": { "reviewer": "{{AUTHOR_HANDLE}}" }
  }
}
JSON

output=$("$PROJ/scripts/sync-claude-harness.sh" manifest init --dry-run 2>&1)
# Replaced values should appear
assert_contains "$output" 'PROJECT_NAME: "MyProject"' "detected replaced PROJECT_NAME"
assert_contains "$output" 'TICKET_PREFIX: "MYP"' "detected replaced TICKET_PREFIX"
# Unreplaced values should remain as placeholders
assert_contains "$output" '{{PROJECT_DOMAIN}}' "unreplaced PROJECT_DOMAIN kept as placeholder"
assert_contains "$output" '{{COMPANY_NAME}}' "unreplaced COMPANY_NAME kept as placeholder"

# =============================================================================
echo -e "\n${CYAN}=== Test 14: MCP server names detected ===${NC}\n"
# =============================================================================
PROJ=$(setup_project "mcp-servers")
create_team_config_replaced "$PROJ"

output=$("$PROJ/scripts/sync-claude-harness.sh" manifest init --dry-run 2>&1)
assert_contains "$output" 'MCP_LINEAR_SERVER: "claude_ai_Linear"' "MCP_LINEAR_SERVER detected"
assert_contains "$output" 'MCP_CONFLUENCE_SERVER: "claude_ai_Atlassian"' "MCP_CONFLUENCE_SERVER detected"

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
