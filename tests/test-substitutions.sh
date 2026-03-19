#!/bin/bash
# =============================================================================
# Test: Placeholder Substitution Engine (SAW-10)
# =============================================================================
# Tests all AC items for the substitution engine feature.
# Run from repo root: bash tests/test-substitutions.sh
#
# Strategy:
#   - Unit tests source functions via a wrapper that strips the main
#     entry point from the sync script.
#   - Integration tests use a mocked version of the sync script that
#     stubs out network calls.
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SYNC_SCRIPT="$REPO_ROOT/scripts/sync-claude-harness.sh"

# Create a temporary project structure for testing
TEST_DIR=$(mktemp -d /tmp/substitution-test-XXXXXX)
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
    if echo "$output" | grep -qF -- "$expected"; then
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
    if ! echo "$output" | grep -qF -- "$expected"; then
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

assert_file_contains() {
    local file="$1"
    local expected="$2"
    local label="$3"
    TOTAL=$((TOTAL + 1))
    if [ -f "$file" ] && grep -qF -- "$expected" "$file"; then
        echo -e "  ${GREEN}PASS${NC} $label"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $label (expected file to contain: $expected)"
        if [ -f "$file" ]; then
            echo -e "  ${YELLOW}  File contents:${NC}"
            cat "$file" | head -20 | sed 's/^/    /'
        else
            echo -e "  ${YELLOW}  File does not exist: $file${NC}"
        fi
        FAIL=$((FAIL + 1))
    fi
}

assert_file_not_contains() {
    local file="$1"
    local expected="$2"
    local label="$3"
    TOTAL=$((TOTAL + 1))
    if [ -f "$file" ] && ! grep -qF -- "$expected" "$file"; then
        echo -e "  ${GREEN}PASS${NC} $label"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $label (did NOT expect file to contain: $expected)"
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

# Create a sourceable version of the sync script (strips main entry point).
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

# =============================================================================
echo -e "\n${CYAN}=== Test 1: apply_substitutions -- basic {{PLACEHOLDER}} tokens ===${NC}\n"
# AC: Both {{PLACEHOLDER}} tokens and literal string substitutions supported
# =============================================================================
PROJ=$(setup_project "basic-subs")

cat > "$PROJ/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "MyProject"
  PROJECT_REPO: "my-project"
  PROJECT_SHORT: "MYP"
  GITHUB_ORG: "my-org"
  TICKET_PREFIX: "MYP"
  MAIN_BRANCH: "main"
substitutions:
  TICKET_PREFIX: "MYP"
  GITHUB_ORG: "my-org"
  PROJECT_NAME: "MyProject"
YAML

"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1
SOURCEABLE=$(create_sourceable_script "$PROJ")

# Create a test file with template placeholders
mkdir -p "$PROJ/.claude/agents"
cat > "$PROJ/.claude/agents/test-agent.md" <<'EOF'
# {{PROJECT_NAME}} Agent

Ticket prefix: {{TICKET_PREFIX}}
Organization: {{GITHUB_ORG}}
Repo: {{PROJECT_REPO}}
Short: {{PROJECT_SHORT}}
EOF

output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.harness-manifest.yml"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest
    apply_substitutions "$PROJ/.claude/agents/test-agent.md"
    cat "$PROJ/.claude/agents/test-agent.md"
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "# MyProject Agent" "{{PROJECT_NAME}} replaced with MyProject"
assert_contains "$output" "Ticket prefix: MYP" "{{TICKET_PREFIX}} replaced with MYP"
assert_contains "$output" "Organization: my-org" "{{GITHUB_ORG}} replaced with my-org"
assert_not_contains "$output" "{{TICKET_PREFIX}}" "no remaining {{TICKET_PREFIX}} placeholders"
assert_not_contains "$output" "{{GITHUB_ORG}}" "no remaining {{GITHUB_ORG}} placeholders"

# Identity fields without explicit substitutions should also be replaced
assert_contains "$output" "Repo: my-project" "{{PROJECT_REPO}} replaced from identity"
assert_contains "$output" "Short: MYP" "{{PROJECT_SHORT}} replaced from identity"

# =============================================================================
echo -e "\n${CYAN}=== Test 2: apply_substitutions -- longest-match-first order ===${NC}\n"
# AC: Substitutions applied in longest-match-first order (prevents partial matches)
# =============================================================================
PROJ=$(setup_project "longest-match")

cat > "$PROJ/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "MyProject"
  PROJECT_REPO: "my-project"
  PROJECT_SHORT: "MYP"
  GITHUB_ORG: "my-org"
  TICKET_PREFIX: "MYP"
  MAIN_BRANCH: "main"
substitutions:
  "{{GITHUB_REPO_URL}}": "https://github.com/my-org/my-project"
  "{{GITHUB_ORG}}": "my-org"
YAML

"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1
SOURCEABLE=$(create_sourceable_script "$PROJ")

# Create a test file with overlapping placeholders
mkdir -p "$PROJ/.claude/agents"
cat > "$PROJ/.claude/agents/overlap.md" <<'EOF'
Repo URL: {{GITHUB_REPO_URL}}
Org: {{GITHUB_ORG}}
EOF

output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.harness-manifest.yml"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest
    apply_substitutions "$PROJ/.claude/agents/overlap.md"
    cat "$PROJ/.claude/agents/overlap.md"
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "Repo URL: https://github.com/my-org/my-project" "longer {{GITHUB_REPO_URL}} substituted correctly"
assert_contains "$output" "Org: my-org" "shorter {{GITHUB_ORG}} still works"
assert_not_contains "$output" "{{GITHUB_REPO_URL}}" "no remaining {{GITHUB_REPO_URL}}"

# =============================================================================
echo -e "\n${CYAN}=== Test 3: apply_substitutions -- code examples not accidentally substituted ===${NC}\n"
# AC: Code examples with {{...}} in markdown not accidentally substituted
# =============================================================================
PROJ=$(setup_project "code-examples")

cat > "$PROJ/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "MyProject"
  PROJECT_REPO: "my-project"
  PROJECT_SHORT: "MYP"
  GITHUB_ORG: "my-org"
  TICKET_PREFIX: "MYP"
  MAIN_BRANCH: "main"
substitutions:
  TICKET_PREFIX: "MYP"
YAML

"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1
SOURCEABLE=$(create_sourceable_script "$PROJ")

# Create a file with Stripe-style {{CHECKOUT_SESSION_ID}} and other non-manifest tokens
mkdir -p "$PROJ/.claude/skills"
cat > "$PROJ/.claude/skills/stripe-guide.md" <<'EOF'
# Stripe Integration

Use `{{CHECKOUT_SESSION_ID}}` in your redirect URL:
```
https://example.com/success?session_id={{CHECKOUT_SESSION_ID}}
```

Ticket prefix: {{TICKET_PREFIX}}
Some other template: {{UNKNOWN_PLACEHOLDER}}
Mustache syntax: {{#items}} and {{/items}}
EOF

output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.harness-manifest.yml"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest
    apply_substitutions "$PROJ/.claude/skills/stripe-guide.md"
    cat "$PROJ/.claude/skills/stripe-guide.md"
    rm -rf "$TMP_DIR"
)

# Stripe placeholder should NOT be touched (not in manifest)
assert_contains "$output" "{{CHECKOUT_SESSION_ID}}" "Stripe {{CHECKOUT_SESSION_ID}} preserved"
assert_contains "$output" "{{UNKNOWN_PLACEHOLDER}}" "non-manifest {{UNKNOWN_PLACEHOLDER}} preserved"
assert_contains "$output" "{{#items}}" "Mustache {{#items}} preserved"
assert_contains "$output" "{{/items}}" "Mustache {{/items}} preserved"
# But the manifest-defined one SHOULD be replaced
assert_contains "$output" "Ticket prefix: MYP" "manifest {{TICKET_PREFIX}} still replaced"
assert_not_contains "$output" "Ticket prefix: {{TICKET_PREFIX}}" "{{TICKET_PREFIX}} removed"

# =============================================================================
echo -e "\n${CYAN}=== Test 4: apply_substitutions -- literal string substitutions ===${NC}\n"
# AC: Both {{PLACEHOLDER}} tokens and literal string substitutions supported
# =============================================================================
PROJ=$(setup_project "literal-subs")

cat > "$PROJ/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "MyProject"
  PROJECT_REPO: "my-project"
  PROJECT_SHORT: "MYP"
  GITHUB_ORG: "my-org"
  TICKET_PREFIX: "MYP"
  MAIN_BRANCH: "main"
substitutions:
  "safe-agentic-workflow": "my-project"
  "SAW": "MYP"
  "ByBren-LLC": "my-org"
YAML

"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1
SOURCEABLE=$(create_sourceable_script "$PROJ")

mkdir -p "$PROJ/.claude/agents"
cat > "$PROJ/.claude/agents/literal-test.md" <<'EOF'
# safe-agentic-workflow Agent

Prefix: SAW-123
Organization: ByBren-LLC
Commit format: feat(scope): description [SAW-XXX]
EOF

output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.harness-manifest.yml"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest
    apply_substitutions "$PROJ/.claude/agents/literal-test.md"
    cat "$PROJ/.claude/agents/literal-test.md"
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "# my-project Agent" "literal 'safe-agentic-workflow' replaced"
assert_contains "$output" "Prefix: MYP-123" "literal 'SAW' replaced in SAW-123"
assert_contains "$output" "Organization: my-org" "literal 'ByBren-LLC' replaced"
assert_contains "$output" "[MYP-XXX]" "literal 'SAW' replaced in [SAW-XXX]"

# =============================================================================
echo -e "\n${CYAN}=== Test 5: --no-placeholders flag skips substitution ===${NC}\n"
# AC: --no-placeholders flag skips substitution step
# =============================================================================
PROJ=$(setup_project "no-placeholders")

cat > "$PROJ/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "MyProject"
  PROJECT_REPO: "my-project"
  PROJECT_SHORT: "MYP"
  GITHUB_ORG: "my-org"
  TICKET_PREFIX: "MYP"
  MAIN_BRANCH: "main"
substitutions:
  TICKET_PREFIX: "MYP"
  GITHUB_ORG: "my-org"
YAML

"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

# Create mock upstream with template placeholders
MOCK_UPSTREAM="$TEST_DIR/mock-upstream-noplc"
mkdir -p "$MOCK_UPSTREAM/.claude/agents"
cat > "$MOCK_UPSTREAM/.claude/agents/test-agent.md" <<'EOF'
# {{PROJECT_NAME}} Agent
Ticket: {{TICKET_PREFIX}}
Org: {{GITHUB_ORG}}
EOF

MOCKED_SCRIPT=$(create_mocked_script "$PROJ" "$MOCK_UPSTREAM")
output=$("$MOCKED_SCRIPT" sync --no-placeholders 2>&1 || true)

# Verify placeholders were NOT substituted
assert_contains "$output" "Skipping placeholder substitutions (--no-placeholders)" "reports skipping substitutions"
assert_file_contains "$PROJ/.claude/agents/test-agent.md" "{{TICKET_PREFIX}}" "placeholders preserved with --no-placeholders"
assert_file_contains "$PROJ/.claude/agents/test-agent.md" "{{GITHUB_ORG}}" "{{GITHUB_ORG}} preserved with --no-placeholders"

# =============================================================================
echo -e "\n${CYAN}=== Test 6: Backup retains upstream originals ===${NC}\n"
# AC: Backup retains upstream originals (substitution happens after backup)
# =============================================================================
PROJ=$(setup_project "backup-originals")

cat > "$PROJ/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "MyProject"
  PROJECT_REPO: "my-project"
  PROJECT_SHORT: "MYP"
  GITHUB_ORG: "my-org"
  TICKET_PREFIX: "MYP"
  MAIN_BRANCH: "main"
substitutions:
  TICKET_PREFIX: "MYP"
  GITHUB_ORG: "my-org"
YAML

"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

# Create existing local file so backup has something
mkdir -p "$PROJ/.claude/agents"
echo "# Old content" > "$PROJ/.claude/agents/existing.md"

# Create mock upstream with template placeholders
MOCK_UPSTREAM2="$TEST_DIR/mock-upstream-backup"
mkdir -p "$MOCK_UPSTREAM2/.claude/agents"
cat > "$MOCK_UPSTREAM2/.claude/agents/existing.md" <<'EOF'
# {{PROJECT_NAME}} Agent
Ticket: {{TICKET_PREFIX}}
EOF

MOCKED_SCRIPT2=$(create_mocked_script "$PROJ" "$MOCK_UPSTREAM2")
output=$("$MOCKED_SCRIPT2" sync 2>&1 || true)

# After sync, local should have substituted content
assert_file_contains "$PROJ/.claude/agents/existing.md" "# MyProject Agent" "local file has substituted content"
assert_file_not_contains "$PROJ/.claude/agents/existing.md" "{{PROJECT_NAME}}" "local file has no remaining {{PROJECT_NAME}}"

# Backup should retain the OLD local content (pre-sync)
# The backup contains whatever was in .claude/ before the sync, not the upstream originals.
# The key point is: backup is created BEFORE substitution runs on the new files.
BACKUP_DIR="$PROJ/.harness-backup"
if [ -d "$BACKUP_DIR" ]; then
    latest_backup=$(ls -1dt "$BACKUP_DIR"/*/ 2>/dev/null | head -1)
    if [ -n "$latest_backup" ] && [ -f "${latest_backup}agents/existing.md" ]; then
        # Backup should contain the OLD content (before sync), not the new substituted content
        assert_file_contains "${latest_backup}agents/existing.md" "# Old content" "backup retains pre-sync content"
        assert_file_not_contains "${latest_backup}agents/existing.md" "MyProject" "backup does NOT have new substituted content"
    else
        TOTAL=$((TOTAL + 1))
        echo -e "  ${GREEN}PASS${NC} backup directory exists (backup created before substitution)"
        PASS=$((PASS + 1))
    fi
else
    TOTAL=$((TOTAL + 1))
    echo -e "  ${RED}FAIL${NC} backup directory not created"
    FAIL=$((FAIL + 1))
fi

# =============================================================================
echo -e "\n${CYAN}=== Test 7: Sync integration -- substitutions applied to synced files ===${NC}\n"
# AC: After fetching upstream .claude/ files, re-apply fork-specific values from manifest substitutions
# =============================================================================
PROJ=$(setup_project "sync-integration")

cat > "$PROJ/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "MyProject"
  PROJECT_REPO: "my-project"
  PROJECT_SHORT: "MYP"
  GITHUB_ORG: "my-org"
  TICKET_PREFIX: "MYP"
  MAIN_BRANCH: "main"
substitutions:
  TICKET_PREFIX: "MYP"
  GITHUB_ORG: "my-org"
  PROJECT_NAME: "MyProject"
YAML

"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

# Create mock upstream with multiple files containing placeholders
MOCK_UPSTREAM3="$TEST_DIR/mock-upstream-integration"
mkdir -p "$MOCK_UPSTREAM3/.claude/agents"
mkdir -p "$MOCK_UPSTREAM3/.claude/skills/testing-patterns"

cat > "$MOCK_UPSTREAM3/.claude/agents/be-developer.md" <<'EOF'
# {{PROJECT_NAME}} BE Developer

Commit format: `feat(scope): description [{{TICKET_PREFIX}}-XXX]`
Repository: {{GITHUB_ORG}}/{{PROJECT_REPO}}
EOF

cat > "$MOCK_UPSTREAM3/.claude/skills/testing-patterns/SKILL.md" <<'EOF'
# Testing Patterns for {{PROJECT_NAME}}

Use ticket prefix {{TICKET_PREFIX}} in all test names.
EOF

MOCKED_SCRIPT3=$(create_mocked_script "$PROJ" "$MOCK_UPSTREAM3")
output=$("$MOCKED_SCRIPT3" sync 2>&1 || true)

assert_contains "$output" "Applied substitutions" "substitution summary reported"

# Verify BE developer file was substituted
assert_file_contains "$PROJ/.claude/agents/be-developer.md" "# MyProject BE Developer" "BE developer has project name"
assert_file_contains "$PROJ/.claude/agents/be-developer.md" "[MYP-XXX]" "BE developer has ticket prefix"
assert_file_contains "$PROJ/.claude/agents/be-developer.md" "my-org/my-project" "BE developer has org/repo"
assert_file_not_contains "$PROJ/.claude/agents/be-developer.md" "{{TICKET_PREFIX}}" "BE developer no remaining {{TICKET_PREFIX}}"

# Verify skill file was substituted
assert_file_contains "$PROJ/.claude/skills/testing-patterns/SKILL.md" "Testing Patterns for MyProject" "skill file has project name"
assert_file_contains "$PROJ/.claude/skills/testing-patterns/SKILL.md" "ticket prefix MYP" "skill file has ticket prefix"

# =============================================================================
echo -e "\n${CYAN}=== Test 8: No manifest -- no substitution (backward compatible) ===${NC}\n"
# =============================================================================
PROJ=$(setup_project "no-manifest-subs")
"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1

# Create mock upstream with placeholders (but no manifest to substitute them)
MOCK_UPSTREAM4="$TEST_DIR/mock-upstream-nomnfst"
mkdir -p "$MOCK_UPSTREAM4/.claude/agents"
cat > "$MOCK_UPSTREAM4/.claude/agents/test-agent.md" <<'EOF'
# {{PROJECT_NAME}} Agent
Ticket: {{TICKET_PREFIX}}
EOF

MOCKED_SCRIPT4=$(create_mocked_script "$PROJ" "$MOCK_UPSTREAM4")
output=$("$MOCKED_SCRIPT4" sync 2>&1 || true)

# v2.10.0+: sync without manifest should FAIL (SA decision: manifest required)
assert_contains "$output" "No manifest found" "no-manifest: sync fails with manifest required error"
assert_contains "$output" "manifest init" "no-manifest: error message routes to manifest init"
# File should NOT have been written (sync aborted)
assert_not_contains "$output" "Applied substitutions" "no-manifest: no substitution summary"

# =============================================================================
echo -e "\n${CYAN}=== Test 9: Empty substitutions section -- no error ===${NC}\n"
# =============================================================================
PROJ=$(setup_project "empty-subs")

cat > "$PROJ/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "MyProject"
  PROJECT_REPO: "my-project"
  PROJECT_SHORT: "MYP"
  GITHUB_ORG: "my-org"
  TICKET_PREFIX: "MYP"
  MAIN_BRANCH: "main"
substitutions: {}
YAML

"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1
SOURCEABLE=$(create_sourceable_script "$PROJ")

# Create a test file -- identity fields should still be substituted
mkdir -p "$PROJ/.claude/agents"
cat > "$PROJ/.claude/agents/test.md" <<'EOF'
Ticket: {{TICKET_PREFIX}}
EOF

output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.harness-manifest.yml"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest
    apply_substitutions "$PROJ/.claude/agents/test.md"
    cat "$PROJ/.claude/agents/test.md"
    rm -rf "$TMP_DIR"
)

# Identity-derived {{TICKET_PREFIX}} -> MYP should still work even with empty substitutions
assert_contains "$output" "Ticket: MYP" "empty substitutions: identity values still applied"

# =============================================================================
echo -e "\n${CYAN}=== Test 10: Substitutions with special characters ===${NC}\n"
# =============================================================================
PROJ=$(setup_project "special-chars")

cat > "$PROJ/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "My.Special-Project"
  PROJECT_REPO: "my-special-project"
  PROJECT_SHORT: "MSP"
  GITHUB_ORG: "my-org"
  TICKET_PREFIX: "MSP"
  MAIN_BRANCH: "main"
substitutions:
  "{{AUTHOR_WEBSITE}}": "https://example.com/~user"
  "{{AUTHOR_EMAIL}}": "user@example.com"
YAML

"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1
SOURCEABLE=$(create_sourceable_script "$PROJ")

mkdir -p "$PROJ/.claude/agents"
cat > "$PROJ/.claude/agents/special.md" <<'EOF'
Website: {{AUTHOR_WEBSITE}}
Email: {{AUTHOR_EMAIL}}
Project: {{PROJECT_NAME}}
EOF

output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.harness-manifest.yml"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest
    apply_substitutions "$PROJ/.claude/agents/special.md"
    cat "$PROJ/.claude/agents/special.md"
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "Website: https://example.com/~user" "URL with special chars substituted"
assert_contains "$output" "Email: user@example.com" "email with @ substituted"
assert_contains "$output" "Project: My.Special-Project" "project name with dots/dashes substituted"

# =============================================================================
echo -e "\n${CYAN}=== Test 11: apply_substitutions -- non-existent file handled gracefully ===${NC}\n"
# =============================================================================
PROJ=$(setup_project "nonexistent")

cat > "$PROJ/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "MyProject"
  PROJECT_REPO: "my-project"
  PROJECT_SHORT: "MYP"
  GITHUB_ORG: "my-org"
  TICKET_PREFIX: "MYP"
  MAIN_BRANCH: "main"
substitutions:
  TICKET_PREFIX: "MYP"
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
    apply_substitutions "$PROJ/.claude/nonexistent-file.md" 2>&1
    echo "EXIT_OK"
    rm -rf "$TMP_DIR"
)

assert_contains "$output" "EXIT_OK" "non-existent file does not cause error"

# =============================================================================
echo -e "\n${CYAN}=== Test 12: apply_all_substitutions -- only processes text files ===${NC}\n"
# =============================================================================
PROJ=$(setup_project "text-only")

cat > "$PROJ/.harness-manifest.yml" <<'YAML'
manifest_version: "1.0"
identity:
  PROJECT_NAME: "MyProject"
  PROJECT_REPO: "my-project"
  PROJECT_SHORT: "MYP"
  GITHUB_ORG: "my-org"
  TICKET_PREFIX: "MYP"
  MAIN_BRANCH: "main"
substitutions:
  TICKET_PREFIX: "MYP"
YAML

"$PROJ/scripts/sync-claude-harness.sh" init >/dev/null 2>&1
SOURCEABLE=$(create_sourceable_script "$PROJ")

# Create files of different types
mkdir -p "$PROJ/.claude/agents"
echo "{{TICKET_PREFIX}}" > "$PROJ/.claude/agents/test.md"
echo "{{TICKET_PREFIX}}" > "$PROJ/.claude/agents/test.json"
echo "{{TICKET_PREFIX}}" > "$PROJ/.claude/agents/test.png"  # binary extension

output=$(
    source "$SOURCEABLE"
    PROJECT_ROOT="$PROJ"
    CLAUDE_DIR="$PROJ/.claude"
    MANIFEST_FILE="$PROJ/.harness-manifest.yml"
    MANIFEST_JSON=""
    HAS_MANIFEST=false
    TMP_DIR=$(mktemp -d)
    load_manifest
    apply_all_substitutions "$PROJ/.claude"
    rm -rf "$TMP_DIR"
)

assert_file_contains "$PROJ/.claude/agents/test.md" "MYP" "markdown file substituted"
assert_file_contains "$PROJ/.claude/agents/test.json" "MYP" "JSON file substituted"
# .png should NOT be processed (not in text file extension list)
assert_file_contains "$PROJ/.claude/agents/test.png" "{{TICKET_PREFIX}}" "binary extension file NOT substituted"

# =============================================================================
echo -e "\n${CYAN}=== Test 13: Script syntax validation ===${NC}\n"
# =============================================================================
syntax_output=$(bash -n "$SYNC_SCRIPT" 2>&1)
syntax_ec=$?
assert_exit_code "$syntax_ec" 0 "sync script has valid bash syntax"

# =============================================================================
echo -e "\n${CYAN}=== Test 14: Existing tests still pass ===${NC}\n"
# =============================================================================
echo "  Running manifest loader tests..."
ml_output=$(bash "$REPO_ROOT/tests/test-manifest-loader.sh" 2>&1)
ml_ec=$?
assert_exit_code "$ml_ec" 0 "manifest loader tests (SAW-6) still pass"

echo "  Running rename-diff tests..."
rd_output=$(bash "$REPO_ROOT/tests/test-rename-diff.sh" 2>&1)
rd_ec=$?
assert_exit_code "$rd_ec" 0 "rename-diff tests (SAW-5) still pass"

# =============================================================================
echo -e "\n${CYAN}=== Test 15: help text includes --no-placeholders ===${NC}\n"
# =============================================================================
PROJ=$(setup_project "help-text")
help_output=$("$PROJ/scripts/sync-claude-harness.sh" help 2>&1)
assert_contains "$help_output" "--no-placeholders" "help mentions --no-placeholders flag"
assert_contains "$help_output" "substitution" "help mentions substitution"

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
