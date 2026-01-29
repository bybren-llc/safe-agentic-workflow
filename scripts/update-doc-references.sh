#!/bin/bash
# update-doc-references.sh
# Updates all references to moved documentation files after reorganization
# Part of repository reorganization plan (docs/REPOSITORY-REORGANIZATION-PLAN.md)

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Documentation Reference Update Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to update references in a file
update_file_references() {
    local file=$1
    local backup="${file}.bak"
    
    echo -e "${YELLOW}Updating: ${file}${NC}"
    
    # Create backup
    cp "$file" "$backup"
    
    # Update references (using sed for cross-platform compatibility)
    # Note: AGENTS.md and CLAUDE.md stay in root (AI assistant convention)
    sed -i.tmp \
        -e 's|](DATA_DICTIONARY\.md)|](docs/database/DATA_DICTIONARY.md)|g' \
        -e 's|](RLS_IMPLEMENTATION_GUIDE\.md)|](docs/database/RLS_IMPLEMENTATION_GUIDE.md)|g' \
        -e 's|](RLS_POLICY_CATALOG\.md)|](docs/database/RLS_POLICY_CATALOG.md)|g' \
        -e 's|](RLS_DATABASE_MIGRATION_SOP\.md)|](docs/database/RLS_DATABASE_MIGRATION_SOP.md)|g' \
        -e 's|](SECURITY_FIRST_ARCHITECTURE\.md)|](docs/security/SECURITY_FIRST_ARCHITECTURE.md)|g' \
        -e 's|](CI-CD-Pipeline-Guide\.md)|](docs/ci-cd/CI-CD-Pipeline-Guide.md)|g' \
        "$file"
    
    # Remove temporary file created by sed
    rm -f "${file}.tmp"
    
    # Check if file changed
    if diff -q "$file" "$backup" > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} No changes needed"
        rm "$backup"
    else
        echo -e "  ${GREEN}✓${NC} Updated successfully"
        echo -e "  ${BLUE}ℹ${NC}  Backup saved: ${backup}"
    fi
}

# Function to update references in agent prompts (different path depth)
update_agent_prompt_references() {
    local file=$1
    local backup="${file}.bak"
    
    echo -e "${YELLOW}Updating agent prompt: ${file}${NC}"
    
    # Create backup
    cp "$file" "$backup"
    
    # Update references (agent prompts are in subdirectories, need ../../ prefix)
    # Note: AGENTS.md and CLAUDE.md stay in root, so they keep ../../ prefix
    sed -i.tmp \
        -e 's|`DATA_DICTIONARY\.md`|`../../docs/database/DATA_DICTIONARY.md`|g' \
        -e 's|`RLS_IMPLEMENTATION_GUIDE\.md`|`../../docs/database/RLS_IMPLEMENTATION_GUIDE.md`|g' \
        -e 's|`RLS_POLICY_CATALOG\.md`|`../../docs/database/RLS_POLICY_CATALOG.md`|g' \
        -e 's|`RLS_DATABASE_MIGRATION_SOP\.md`|`../../docs/database/RLS_DATABASE_MIGRATION_SOP.md`|g' \
        -e 's|`SECURITY_FIRST_ARCHITECTURE\.md`|`../../docs/security/SECURITY_FIRST_ARCHITECTURE.md`|g' \
        -e 's|`CI-CD-Pipeline-Guide\.md`|`../../docs/ci-cd/CI-CD-Pipeline-Guide.md`|g' \
        -e 's|- `CONTRIBUTING\.md`|- `../../CONTRIBUTING.md`|g' \
        "$file"
    
    # Remove temporary file created by sed
    rm -f "${file}.tmp"
    
    # Check if file changed
    if diff -q "$file" "$backup" > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} No changes needed"
        rm "$backup"
    else
        echo -e "  ${GREEN}✓${NC} Updated successfully"
        echo -e "  ${BLUE}ℹ${NC}  Backup saved: ${backup}"
    fi
}

echo -e "${BLUE}Phase 1: Update README.md${NC}"
echo ""
update_file_references "README.md"
echo ""

echo -e "${BLUE}Phase 2: Update Onboarding Documentation${NC}"
echo ""
for file in docs/onboarding/*.md; do
    if [ -f "$file" ]; then
        update_file_references "$file"
    fi
done
echo ""

echo -e "${BLUE}Phase 3: Update Agent Prompts (.claude/agents/)${NC}"
echo ""
for file in .claude/agents/*.md; do
    if [ -f "$file" ]; then
        update_agent_prompt_references "$file"
    fi
done
echo ""

echo -e "${BLUE}Phase 4: Update Agent Prompts (agent_providers/claude_code/prompts/)${NC}"
echo ""
for file in agent_providers/claude_code/prompts/*.md; do
    if [ -f "$file" ]; then
        update_agent_prompt_references "$file"
    fi
done
echo ""

echo -e "${BLUE}Phase 5: Update Agent Prompts (agent_providers/augment/prompts/)${NC}"
echo ""
if [ -d "agent_providers/augment/prompts" ]; then
    for file in agent_providers/augment/prompts/*.md; do
        if [ -f "$file" ]; then
            update_agent_prompt_references "$file"
        fi
    done
fi
echo ""

echo -e "${BLUE}Phase 6: Update Whitepaper Documentation${NC}"
echo ""
echo ""

echo -e "${BLUE}Phase 7: Update Other Documentation${NC}"
echo ""
if [ -f "agent_providers/augment/AUGMENT_WORKFLOW_GUIDE.md" ]; then
    update_file_references "agent_providers/augment/AUGMENT_WORKFLOW_GUIDE.md"
fi
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Reference Update Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Review changes: git diff"
echo "2. Test agent invocations: @bsa What is your role?"
echo "3. Verify links in README.md"
echo "4. Run verification checklist from REPOSITORY-REORGANIZATION-PLAN.md"
echo "5. Commit changes: git add -A && git commit -m 'docs: update references after reorganization'"
echo ""
echo -e "${BLUE}ℹ${NC}  Backup files saved with .bak extension"
echo -e "${BLUE}ℹ${NC}  To restore a file: mv file.bak file"
echo ""

# Summary statistics
echo -e "${BLUE}Summary:${NC}"
total_backups=$(find . -name "*.bak" 2>/dev/null | wc -l)
echo "  Files updated: ${total_backups}"
echo "  Backup files created: ${total_backups}"
echo ""

# Offer to clean up backups
read -p "Remove all backup files? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    find . -name "*.bak" -delete
    echo -e "${GREEN}✓${NC} Backup files removed"
else
    echo -e "${YELLOW}ℹ${NC}  Backup files preserved"
fi

echo ""
echo -e "${GREEN}✅ Done!${NC}"

