# /review - Comprehensive Code Review

Perform systematic code review of recent changes following project standards.

## Review Checklist

### 1. Code Quality and Standards
```bash
echo "Reviewing Code Quality..."

# Check TypeScript strict mode compliance
echo "- TypeScript strict mode:"
grep -r "strict.*false" . --include="*.json" || echo "  No strict mode violations"

# Check for 'any' type usage
echo "- Checking for 'any' type usage:"
rg ": any" --type ts --type tsx || echo "  No 'any' type found"

# Check for @ts-ignore bypasses
echo "- Checking for @ts-ignore:"
rg "@ts-ignore" --type ts --type tsx || echo "  No @ts-ignore found"
```

### 2. Authentication and Security
```bash
echo "Reviewing Authentication and Security..."

# Check for RLS policies in Supabase migrations
echo "- RLS policies defined:"
rg "CREATE POLICY|ALTER TABLE.*ENABLE ROW LEVEL SECURITY" supabase/migrations --type sql

# Check for auth middleware usage
echo "- Auth middleware applied:"
rg "requireAuth|withAuth|getServerSession" src --type ts --type tsx

# Check for exposed secrets
echo "- No hardcoded secrets:"
rg "API_KEY.*=.*[\"']" . --type ts --type tsx && echo "  Potential hardcoded secret!" || echo "  No hardcoded secrets"
```

### 3. RLS and Multi-Tenancy
```bash
echo "Reviewing RLS and Multi-Tenancy..."

# Check for tenant isolation in queries
echo "- Queries scoped by tenant/org:"
rg "organization_id|tenant_id|user_id" src --type ts

# Check RLS policy completeness
echo "- RLS SELECT/INSERT/UPDATE/DELETE coverage:"
rg "CREATE POLICY.*FOR (SELECT|INSERT|UPDATE|DELETE)" supabase/migrations --type sql
```

### 4. Error Handling and Loading States
```bash
echo "Reviewing Error Handling..."

# Check for error boundaries
echo "- Error boundaries implemented:"
rg "ErrorBoundary" src --type tsx

# Check for loading states
echo "- Loading states implemented:"
rg "isLoading|isPending|Suspense" src --type tsx
```

### 5. Accessibility
```bash
echo "Reviewing Accessibility..."

# Check for ARIA labels
echo "- ARIA labels on interactive elements:"
rg "aria-label" src --type tsx

# Check for keyboard navigation
echo "- Keyboard event handlers:"
rg "onKeyDown|onKeyPress" src --type tsx
```

### 6. Performance
```bash
echo "Reviewing Performance..."

# Check bundle size (if built)
if [ -d ".next" ]; then
  echo "- Next.js bundle analysis:"
  du -sh .next/static/* | sort -h
fi

# Check for unnecessary re-renders
echo "- Memoization usage:"
rg "useMemo|useCallback|React.memo" src --type tsx
```

### 7. Testing Coverage
```bash
echo "Reviewing Test Coverage..."

# Check for test files
echo "- Test files for new components:"
find src -name "*.test.tsx" -o -name "*.test.ts"

# Run tests
echo "- Running test suite:"
npm run test
```

### 8. Documentation
```bash
echo "Reviewing Documentation..."

# Check for JSDoc comments on exported functions
echo "- Exported functions have JSDoc:"
rg "^export (function|const).*" src --type ts -A 5 | grep -B 1 "/\*\*" || echo "  Some exports lack JSDoc"

# Check if README updated
echo "- README files updated:"
find . -name "README.md" -mtime -1
```

### 9. Git Hygiene
```bash
echo "Reviewing Git Hygiene..."

# Check commit messages follow conventional commits
echo "- Recent commit messages:"
git log --oneline -5

# Check for ConTS ticket references
echo "- ConTS ticket references in commits:"
git log --oneline -10 | grep -E "ConTS-[0-9]+" || echo "  Some commits missing ConTS reference"

# Check for large files
echo "- No large files committed:"
git diff --stat HEAD~5..HEAD | grep "|\s*[0-9]\{4,\}" && echo "  Large file changes detected"
```

## Final Review Summary

```bash
echo ""
echo "=================================="
echo "CODE REVIEW SUMMARY"
echo "=================================="
echo ""
echo "PASSED:"
echo "  - Code quality checks"
echo "  - Security review (no exposed secrets)"
echo "  - RLS/tenant isolation present"
echo "  - Testing coverage adequate"
echo ""
echo "WARNINGS:"
echo "  [List any warnings from above]"
echo ""
echo "RECOMMENDATIONS:"
echo "  1. [Specific, actionable feedback with file:line references]"
echo "  2. [Areas for improvement]"
echo "  3. [Best practice suggestions]"
echo ""
echo "CONTS COMPLIANCE:"
echo "  - All commits reference ConTS tickets: [yes/no]"
echo "  - Epic/Story linked: ConTS-XXXX"
echo ""
echo "=================================="
```

## Summary

This command performs:
1. TypeScript strict mode compliance check
2. Security audit (auth, secrets, RLS)
3. Multi-tenancy/RLS validation
4. Error handling and loading states validation
5. Accessibility standards review
6. Performance implications check
7. Test coverage verification
8. Documentation completeness check
9. Git commit hygiene and ConTS compliance review

**Use when**:
- Before creating PR
- After completing feature
- During code review process
- Before sprint demo
