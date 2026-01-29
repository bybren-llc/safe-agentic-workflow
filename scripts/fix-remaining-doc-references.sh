#!/bin/bash
# Fix remaining documentation references after reorganization

set -e

echo "========================================="
echo "Fixing Remaining Documentation References"
echo "========================================="
echo ""

# Files to update
FILES=(
  "AGENTS.md"
  "CONTRIBUTING.md"
  "docs/onboarding/DAY-1-CHECKLIST.md"
  "docs/onboarding/META-PROMPTS-FOR-USERS.md"
  "docs/onboarding/USER-JOURNEY-VALIDATION-REPORT.md"
  "docs/onboarding/{{TICKET_PREFIX}}-326-COMPLETION-SUMMARY.md"
  "docs/team/PLANNING-AGENT-META-PROMPT.md"
  "patterns_library/database/rls-migration.md"
)

# Update each file
for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "Updating: $file"
    
    # Create backup
    cp "$file" "$file.bak"
    
    # Update references
    sed -i.tmp \
      -e 's|](DATA_DICTIONARY\.md)|](docs/database/DATA_DICTIONARY.md)|g' \
      -e 's|](RLS_IMPLEMENTATION_GUIDE\.md)|](docs/database/RLS_IMPLEMENTATION_GUIDE.md)|g' \
      -e 's|](RLS_POLICY_CATALOG\.md)|](docs/database/RLS_POLICY_CATALOG.md)|g' \
      -e 's|](RLS_DATABASE_MIGRATION_SOP\.md)|](docs/database/RLS_DATABASE_MIGRATION_SOP.md)|g' \
      -e 's|](SECURITY_FIRST_ARCHITECTURE\.md)|](docs/security/SECURITY_FIRST_ARCHITECTURE.md)|g' \
      -e 's|](CI-CD-Pipeline-Guide\.md)|](docs/ci-cd/CI-CD-Pipeline-Guide.md)|g' \
      -e 's|`DATA_DICTIONARY\.md`|`docs/database/DATA_DICTIONARY.md`|g' \
      -e 's|`RLS_IMPLEMENTATION_GUIDE\.md`|`docs/database/RLS_IMPLEMENTATION_GUIDE.md`|g' \
      -e 's|`RLS_POLICY_CATALOG\.md`|`docs/database/RLS_POLICY_CATALOG.md`|g' \
      -e 's|`RLS_DATABASE_MIGRATION_SOP\.md`|`docs/database/RLS_DATABASE_MIGRATION_SOP.md`|g' \
      -e 's|`SECURITY_FIRST_ARCHITECTURE\.md`|`docs/security/SECURITY_FIRST_ARCHITECTURE.md`|g' \
      -e 's|`CI-CD-Pipeline-Guide\.md`|`docs/ci-cd/CI-CD-Pipeline-Guide.md`|g' \
      -e 's|- DATA_DICTIONARY\.md|- docs/database/DATA_DICTIONARY.md|g' \
      -e 's|- RLS_IMPLEMENTATION_GUIDE\.md|- docs/database/RLS_IMPLEMENTATION_GUIDE.md|g' \
      -e 's|- RLS_POLICY_CATALOG\.md|- docs/database/RLS_POLICY_CATALOG.md|g' \
      -e 's|- RLS_DATABASE_MIGRATION_SOP\.md|- docs/database/RLS_DATABASE_MIGRATION_SOP.md|g' \
      -e 's|- SECURITY_FIRST_ARCHITECTURE\.md|- docs/security/SECURITY_FIRST_ARCHITECTURE.md|g' \
      -e 's|- CI-CD-Pipeline-Guide\.md|- docs/ci-cd/CI-CD-Pipeline-Guide.md|g' \
      "$file"
    
    # Remove temp file
    rm -f "$file.tmp"
    
    echo "  ✓ Updated successfully"
  else
    echo "  ⚠ File not found: $file"
  fi
done

echo ""
echo "========================================="
echo "Cleanup"
echo "========================================="
echo ""

# Remove backup files
echo "Removing backup files..."
find . -name "*.bak" -delete
echo "  ✓ Backup files removed"

echo ""
echo "========================================="
echo "Complete!"
echo "========================================="
echo ""
echo "Files updated: ${#FILES[@]}"
echo ""
echo "Next steps:"
echo "1. Review changes: git diff"
echo "2. Commit changes: git add -A && git commit -m 'docs: fix remaining documentation references [{{TICKET_PREFIX}}-326]'"
echo ""

