#!/bin/bash
# reorganize-docs.sh
# Complete implementation of repository reorganization plan
# See: docs/REPOSITORY-REORGANIZATION-PLAN.md

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Repository Documentation Reorganization${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if we're in the repository root
if [ ! -f "README.md" ] || [ ! -d ".git" ]; then
    echo -e "${RED}❌ Error: Must run from repository root${NC}"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  Warning: You have uncommitted changes${NC}"
    echo ""
    git status --short
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Aborted${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✓${NC} Pre-flight checks passed"
echo ""

# Confirm execution
echo -e "${YELLOW}This script will:${NC}"
echo "  1. Create new documentation directories"
echo "  2. Move 8 files from root to organized subdirectories"
echo "  3. Keep AGENTS.md and CLAUDE.md in root (AI assistant convention)"
echo "  4. Create README.md index files for new directories"
echo "  5. Update all references in documentation and agent prompts"
echo ""
read -p "Proceed with reorganization? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Aborted${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Phase 1: Create New Directories${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

mkdir -p docs/database
echo -e "${GREEN}✓${NC} Created docs/database/"

mkdir -p docs/security
echo -e "${GREEN}✓${NC} Created docs/security/"

mkdir -p docs/ci-cd
echo -e "${GREEN}✓${NC} Created docs/ci-cd/"

mkdir -p docs/archive
echo -e "${GREEN}✓${NC} Created docs/archive/"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Phase 2: Move Files (Preserving History)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Note: AGENTS.md and CLAUDE.md stay in root (AI assistant convention)
echo -e "${BLUE}ℹ${NC}  Keeping AGENTS.md and CLAUDE.md in root (AI assistant convention)"
echo ""

# Move database documentation
if [ -f "DATA_DICTIONARY.md" ]; then
    git mv DATA_DICTIONARY.md docs/database/
    echo -e "${GREEN}✓${NC} Moved DATA_DICTIONARY.md → docs/database/"
fi

if [ -f "RLS_IMPLEMENTATION_GUIDE.md" ]; then
    git mv RLS_IMPLEMENTATION_GUIDE.md docs/database/
    echo -e "${GREEN}✓${NC} Moved RLS_IMPLEMENTATION_GUIDE.md → docs/database/"
fi

if [ -f "RLS_POLICY_CATALOG.md" ]; then
    git mv RLS_POLICY_CATALOG.md docs/database/
    echo -e "${GREEN}✓${NC} Moved RLS_POLICY_CATALOG.md → docs/database/"
fi

if [ -f "RLS_DATABASE_MIGRATION_SOP.md" ]; then
    git mv RLS_DATABASE_MIGRATION_SOP.md docs/database/
    echo -e "${GREEN}✓${NC} Moved RLS_DATABASE_MIGRATION_SOP.md → docs/database/"
fi

# Move security documentation
if [ -f "SECURITY_FIRST_ARCHITECTURE.md" ]; then
    git mv SECURITY_FIRST_ARCHITECTURE.md docs/security/
    echo -e "${GREEN}✓${NC} Moved SECURITY_FIRST_ARCHITECTURE.md → docs/security/"
fi

# Move CI/CD documentation
if [ -f "CI-CD-Pipeline-Guide.md" ]; then
    git mv CI-CD-Pipeline-Guide.md docs/ci-cd/
    echo -e "${GREEN}✓${NC} Moved CI-CD-Pipeline-Guide.md → docs/ci-cd/"
fi

# Move archived files
if [ -f "README-TEMPLATE.md" ]; then
    git mv README-TEMPLATE.md docs/archive/
    echo -e "${GREEN}✓${NC} Moved README-TEMPLATE.md → docs/archive/"
fi

# Move scripts
if [ -f "apply-workflow.sh" ]; then
    git mv apply-workflow.sh scripts/
    echo -e "${GREEN}✓${NC} Moved apply-workflow.sh → scripts/"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Phase 3: Create README.md Index Files${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Create docs/database/README.md
cat > docs/database/README.md << 'EOF'
# Database Documentation

This directory contains all database-related documentation including schema, security, and migration procedures.

## 📚 Documentation Files

### [DATA_DICTIONARY.md](./DATA_DICTIONARY.md)
**Single source of truth** for database schema:
- Table definitions and relationships
- Column specifications and constraints
- Enum types and their values
- Indexes and performance considerations

**Use this when**: You need to understand the database schema or add new tables/columns.

### [RLS_IMPLEMENTATION_GUIDE.md](./RLS_IMPLEMENTATION_GUIDE.md)
Row-Level Security (RLS) implementation patterns:
- RLS context helpers (`withUserContext`, `withAdminContext`, `withSystemContext`)
- Security patterns and best practices
- Common RLS policy patterns
- Testing RLS policies

**Use this when**: Implementing new features that require database access with proper security.

### [RLS_POLICY_CATALOG.md](./RLS_POLICY_CATALOG.md)
Comprehensive catalog of all RLS policies:
- Policy definitions by table
- Access control rules
- Policy testing procedures
- Security audit checklist

**Use this when**: You need to understand existing RLS policies or create new ones.

### [RLS_DATABASE_MIGRATION_SOP.md](./RLS_DATABASE_MIGRATION_SOP.md)
Standard Operating Procedure for database migrations:
- Migration workflow (dev → staging → production)
- Schema change procedures
- RLS policy updates
- Rollback procedures
- Validation checklist

**Use this when**: You need to create or apply database migrations.

## 🔗 Related Documentation

- [Security Architecture](../security/SECURITY_FIRST_ARCHITECTURE.md) - Overall security patterns
- [Contributing Guide](../../CONTRIBUTING.md) - Git workflow for schema changes

## ⚠️ Important Notes

1. **Always use RLS context helpers** - Never make direct Prisma calls
2. **Test RLS policies** - Verify isolation between users
3. **Follow migration SOP** - Schema changes require ARCHitect approval
4. **Update DATA_DICTIONARY.md** - Keep schema documentation current
EOF

echo -e "${GREEN}✓${NC} Created docs/database/README.md"

# Create docs/security/README.md
cat > docs/security/README.md << 'EOF'
# Security Documentation

This directory contains security architecture and implementation guidelines.

## 📚 Documentation Files

### [SECURITY_FIRST_ARCHITECTURE.md](./SECURITY_FIRST_ARCHITECTURE.md)
Comprehensive security architecture guide:
- Security-first design principles
- Authentication and authorization patterns
- Data protection strategies
- Security testing procedures
- Threat modeling

**Use this when**: Designing new features or reviewing security implications.

## 🔗 Related Documentation

- [RLS Implementation Guide](../database/RLS_IMPLEMENTATION_GUIDE.md) - Database security
- [RLS Policy Catalog](../database/RLS_POLICY_CATALOG.md) - Access control policies
- [CI/CD Pipeline](../ci-cd/CI-CD-Pipeline-Guide.md) - Security in deployment

## 🎯 Security Agents

- **Security Engineer** (`.claude/agents/security-engineer.md`) - Security audits and validation
- **System Architect** (`.claude/agents/system-architect.md`) - Architectural security review

## ⚠️ Security Principles

1. **Defense in Depth** - Multiple layers of security
2. **Least Privilege** - Minimal access by default
3. **Fail Secure** - Errors should deny access
4. **Security by Design** - Not an afterthought
EOF

echo -e "${GREEN}✓${NC} Created docs/security/README.md"

# Create docs/ci-cd/README.md
cat > docs/ci-cd/README.md << 'EOF'
# CI/CD Documentation

This directory contains CI/CD pipeline and DevOps documentation.

## 📚 Documentation Files

### [CI-CD-Pipeline-Guide.md](./CI-CD-Pipeline-Guide.md)
Complete CI/CD pipeline documentation:
- Multi-team git workflow
- Branch protection rules
- CI validation commands
- Code ownership (CODEOWNERS)
- Rebase-first workflow
- Pull request process

**Use this when**: Setting up CI/CD or understanding the deployment workflow.

## 🔗 Related Documentation

- [Contributing Guide](../../CONTRIBUTING.md) - Git workflow and commit standards
- [Security Architecture](../security/SECURITY_FIRST_ARCHITECTURE.md) - Security in CI/CD

## 🎯 CI/CD Agents

- **RTE** (Release Train Engineer) - PR creation and CI validation
- **TDM** (Technical Delivery Manager) - Coordination and blocker resolution

## ⚠️ Important Notes

1. **Always rebase before PR** - `git rebase origin/dev`
2. **Run ci:validate locally** - `yarn ci:validate` before pushing
3. **Use force-with-lease** - `git push --force-with-lease`
4. **Follow PR template** - `.github/pull_request_template.md`
EOF

echo -e "${GREEN}✓${NC} Created docs/ci-cd/README.md"

# Create docs/archive/README.md
cat > docs/archive/README.md << 'EOF'
# Archived Documentation

This directory contains archived or deprecated documentation files.

## 📁 Files

### [README-TEMPLATE.md](./README-TEMPLATE.md)
Original README template used during repository setup.

**Status**: Archived - No longer needed as README.md is complete.

## ℹ️ About This Directory

Files in this directory are:
- No longer actively used
- Kept for historical reference
- May contain outdated information
- Not linked from active documentation

**Do not use these files for current development.**
EOF

echo -e "${GREEN}✓${NC} Created docs/archive/README.md"

echo ""
echo -e "${GREEN}✓${NC} All README.md index files created"
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Phase 4: Update References${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Run the reference update script
if [ -f "scripts/update-doc-references.sh" ]; then
    echo -e "${YELLOW}Running reference update script...${NC}"
    echo ""
    bash scripts/update-doc-references.sh
else
    echo -e "${YELLOW}⚠️  Warning: scripts/update-doc-references.sh not found${NC}"
    echo -e "${YELLOW}   You'll need to update references manually${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Reorganization Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Summary
echo -e "${BLUE}Summary:${NC}"
echo "  Files moved: 8"
echo "  Files kept in root: 2 (AGENTS.md, CLAUDE.md - AI assistant convention)"
echo "  Directories created: 4"
echo "  README.md files created: 4"
echo "  Root directory files: $(ls -1 *.md 2>/dev/null | wc -l) (was 14)"
echo ""

echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Review changes: git status"
echo "  2. Test agent invocations: @bsa What is your role?"
echo "  3. Verify README.md links work"
echo "  4. Run verification checklist (docs/REPOSITORY-REORGANIZATION-PLAN.md)"
echo "  5. Commit: git commit -m 'docs: reorganize root directory documentation [{{TICKET_PREFIX}}-XXX]'"
echo ""

echo -e "${GREEN}✅ Done!${NC}"

