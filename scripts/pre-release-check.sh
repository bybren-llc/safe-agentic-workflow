#!/bin/bash
# =============================================================================
# Pre-Release Validation Script
# =============================================================================
#
# Automates the verifiable checks from docs/release/PRE-RELEASE-CHECKLIST.md
# Run this BEFORE creating any release tag.
#
# Usage:
#   ./scripts/pre-release-check.sh [version]
#
# Example:
#   ./scripts/pre-release-check.sh v2.8.1
# =============================================================================

set -euo pipefail

VERSION="${1:-UNSET}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

check_pass() { ((PASS++)); echo -e "  ${GREEN}✓${NC} $1"; }
check_fail() { ((FAIL++)); echo -e "  ${RED}✗${NC} $1"; }
check_warn() { ((WARN++)); echo -e "  ${YELLOW}⚠${NC} $1"; }

echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Pre-Release Validation: ${VERSION}${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo ""

# ─── 1. Code Quality ────────────────────────────────────────────────────────

echo -e "${CYAN}1. Code Quality Gates${NC}"

# Syntax check
if bash -n scripts/sync-claude-harness.sh 2>/dev/null; then
    check_pass "sync-claude-harness.sh syntax OK"
else
    check_fail "sync-claude-harness.sh syntax FAILED"
fi

# Merge conflict markers
CONFLICTS=$(grep -rl '<<<<<<' . --include='*.sh' --include='*.md' --include='*.json' --include='*.toml' --include='*.yml' --include='*.mdc' 2>/dev/null | grep -v node_modules | grep -v .git | grep -v pre-release | grep -v PRE-RELEASE || true)
if [ -z "$CONFLICTS" ]; then
    check_pass "No merge conflict markers"
else
    check_fail "Merge conflict markers found in: $CONFLICTS"
fi

# Test suites
TOTAL_TESTS=0
TOTAL_PASS=0
for test_file in tests/test-*.sh; do
    if [ -f "$test_file" ]; then
        test_name=$(basename "$test_file" .sh)
        output=$(timeout 120 bash "$test_file" 2>&1 || true)
        if echo "$output" | grep -q "ALL.*PASS"; then
            # Extract count if available
            count=$(echo "$output" | grep -oP '\d+(?=/\d+ PASS)' | tail -1 || echo "?")
            check_pass "$test_name: ${count} tests"
            TOTAL_TESTS=$((TOTAL_TESTS + ${count:-0}))
            TOTAL_PASS=$((TOTAL_PASS + ${count:-0}))
        else
            check_fail "$test_name: FAILED"
        fi
    fi
done
echo -e "  ${CYAN}Total: ${TOTAL_PASS}/${TOTAL_TESTS:-?} tests${NC}"

echo ""

# ─── 2. Documentation ───────────────────────────────────────────────────────

echo -e "${CYAN}2. Documentation Completeness${NC}"

REQUIRED_DOCS=(
    "README.md"
    "docs/HARNESS_SYNC_GUIDE.md"
    "docs/HARNESS_MANIFEST_SCHEMA.md"
    "docs/guides/GETTING-STARTED.md"
    "docs/guides/WORKSPACE-ADOPTION-GUIDE.md"
)

for doc in "${REQUIRED_DOCS[@]}"; do
    if [ -f "$doc" ]; then
        check_pass "$doc exists"
    else
        check_fail "$doc MISSING"
    fi
done

# Provider-specific docs
for provider_doc in .claude/README.md .codex/README.md .cursor/rules/README.md .gemini/README.md; do
    if [ -f "$provider_doc" ]; then
        check_pass "$provider_doc exists"
    else
        check_warn "$provider_doc not found (optional)"
    fi
done

# Stale references
STALE=$(grep -rl 'CODEX\.md' docs/ README.md .claude/ .codex/ .cursor/ .gemini/ 2>/dev/null | grep -v CHANGELOG | grep -v PRE-RELEASE | grep -v 'qa-validations/' | grep -v '.codex/README.md' || true)
if [ -z "$STALE" ]; then
    check_pass "No stale CODEX.md references"
else
    check_fail "Stale CODEX.md references in: $STALE"
fi

echo ""

# ─── 3. Template Compatibility ──────────────────────────────────────────────

echo -e "${CYAN}3. Template Compatibility${NC}"

# Check for hardcoded project values in template files (excluding examples/)
HARDCODED=$(grep -rl 'ByBren-LLC\|rendertrust\|cheddarfox' .claude/ .codex/ .cursor/ .gemini/ 2>/dev/null | grep -v examples/ | grep -v node_modules || true)
if [ -z "$HARDCODED" ]; then
    check_pass "No hardcoded project values in harness files"
else
    check_warn "Possible hardcoded values in: $HARDCODED"
fi

# Check setup-template.sh exists
if [ -f "scripts/setup-template.sh" ]; then
    check_pass "setup-template.sh exists"
else
    check_fail "setup-template.sh MISSING"
fi

echo ""

# ─── 4. Backward Compatibility ──────────────────────────────────────────────

echo -e "${CYAN}4. Backward Compatibility${NC}"

# Check manifest schema exists
if [ -f ".harness-manifest.schema.json" ]; then
    check_pass ".harness-manifest.schema.json exists"
else
    check_warn ".harness-manifest.schema.json not found"
fi

# Check example manifests
for example in examples/manifests/rendertrust.harness-manifest.yml examples/manifests/keryk-ai.harness-manifest.yml; do
    if [ -f "$example" ]; then
        check_pass "$example exists"
    else
        check_warn "$example not found"
    fi
done

echo ""

# ─── 5. Git State ───────────────────────────────────────────────────────────

echo -e "${CYAN}5. Git State${NC}"

BRANCH=$(git branch --show-current)
if [ "$BRANCH" = "main" ]; then
    check_pass "On main branch"
else
    check_fail "Not on main branch (on: $BRANCH)"
fi

# Check for uncommitted changes
if git diff --quiet && git diff --cached --quiet; then
    check_pass "Working tree clean"
else
    check_warn "Uncommitted changes present"
fi

# Check for leftover feature branches
SAW_BRANCHES=$(git branch --list 'SAW-*' 2>/dev/null | wc -l)
if [ "$SAW_BRANCHES" -eq 0 ]; then
    check_pass "No leftover SAW feature branches"
else
    check_warn "${SAW_BRANCHES} SAW feature branches remain"
fi

echo ""

# ─── Summary ────────────────────────────────────────────────────────────────

echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "  ${GREEN}Passed: ${PASS}${NC}  ${RED}Failed: ${FAIL}${NC}  ${YELLOW}Warnings: ${WARN}${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"

if [ "$FAIL" -gt 0 ]; then
    echo -e "${RED}RELEASE BLOCKED — ${FAIL} check(s) failed${NC}"
    echo "Fix the failures above before creating the release tag."
    exit 1
elif [ "$WARN" -gt 0 ]; then
    echo -e "${YELLOW}RELEASE READY WITH WARNINGS — review ${WARN} warning(s) above${NC}"
    exit 0
else
    echo -e "${GREEN}ALL CHECKS PASSED — ready to release ${VERSION}${NC}"
    exit 0
fi
