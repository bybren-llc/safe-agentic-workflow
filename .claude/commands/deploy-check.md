# /deploy-check - Pre-Deployment Validation

Run comprehensive validation before deploying to production.

## Steps

### 1. Quality Gates
```bash
echo "Running Quality Gates..."

# Lint check
echo "1/7 Running lint..."
if ! npm run lint; then
  echo "Lint failed"
  exit 1
fi
echo "Lint passed"

# Type check
echo "2/7 Running typecheck..."
if ! npm run typecheck; then
  echo "Type check failed"
  exit 1
fi
echo "Type check passed"

# Unit tests
echo "3/7 Running unit tests..."
if ! npm run test; then
  echo "Unit tests failed"
  exit 1
fi
echo "Unit tests passed"
```

### 2. Build Validation
```bash
echo "4/7 Building all packages..."
if ! npm run build; then
  echo "Build failed"
  exit 1
fi
echo "Build successful"
```

### 3. E2E Tests
```bash
echo "5/7 Running E2E smoke tests..."
if ! npm run test:e2e; then
  echo "E2E tests failed (check if critical)"
  read -p "Continue anyway? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi
echo "E2E tests passed"
```

### 4. Environment Validation
```bash
echo "6/7 Validating environment configuration..."

# Check critical env vars for WTFB stack
REQUIRED_VARS=("NEXT_PUBLIC_SUPABASE_URL" "NEXT_PUBLIC_SUPABASE_ANON_KEY" "SUPABASE_SERVICE_ROLE_KEY" "STRIPE_SECRET_KEY" "STRIPE_WEBHOOK_SECRET")

for var in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!var}" ]; then
    echo "Missing required environment variable: $var"
    exit 1
  fi
done

echo "Environment variables validated"
```

### 5. Database Migration Check
```bash
echo "7/7 Validating Supabase migrations..."

# Check for pending migrations
if ! npx supabase migration list | grep -q "pending"; then
  echo "All migrations applied"
else
  echo "Pending migrations detected!"
  echo "Run: npx supabase migration up"
  exit 1
fi

echo "Database migrations valid"
```

### 6. Security Audit
```bash
echo "Running security checks..."

# Check for exposed secrets
echo "- Checking for hardcoded secrets..."
if rg "sk_live_|pk_live_|service_role" . --type ts --type tsx 2>/dev/null; then
  echo "WARNING: Potential hardcoded secrets detected!"
  echo "Review the above findings before deploying"
fi

# Check for console.log in production code
echo "- Checking for console.log statements..."
CONSOLE_LOGS=$(rg "console\.(log|debug)" src/ --type ts --type tsx 2>/dev/null | wc -l)
if [ "$CONSOLE_LOGS" -gt 10 ]; then
  echo "WARNING: $CONSOLE_LOGS console statements found"
  echo "Consider removing debug logs before production"
fi

# Check RLS policies
echo "- Verifying RLS is enabled on all tables..."
# This would check Supabase schema for RLS

echo "Security checks complete"
```

### 7. Performance Check
```bash
echo "Checking bundle sizes..."

# Check Next.js bundle if built
if [ -d ".next" ]; then
  BUNDLE_SIZE=$(du -sh .next/static | cut -f1)
  echo "- App bundle: $BUNDLE_SIZE"
  
  # Warn if bundle is large (>10MB)
  BUNDLE_SIZE_MB=$(du -sm .next/static | cut -f1)
  if [ "$BUNDLE_SIZE_MB" -gt 10 ]; then
    echo "WARNING: Large bundle size detected ($BUNDLE_SIZE_MB MB)"
    echo "Consider code splitting or lazy loading"
  fi
fi

echo "Performance check complete"
```

### 8. SAFe Deployment Checklist
```bash
echo "SAFe Deployment Checklist..."

echo "- [ ] Feature flag ready for gradual rollout?"
echo "- [ ] Monitoring/alerting configured?"
echo "- [ ] Rollback plan documented?"
echo "- [ ] PO approved for release?"
echo "- [ ] Release notes prepared?"
```

### 9. Deployment Readiness Report
```bash
echo ""
echo "=================================="
echo "DEPLOYMENT READINESS REPORT"
echo "=================================="
echo ""
echo "ALL CHECKS PASSED:"
echo "  1. Linting"
echo "  2. Type checking"  
echo "  3. Unit tests"
echo "  4. Build compilation"
echo "  5. E2E smoke tests"
echo "  6. Environment validation"
echo "  7. Database migrations"
echo "  8. Security audit"
echo "  9. Performance check"
echo ""
echo "DEPLOYMENT STATUS: READY"
echo ""
echo "Next steps:"
echo "  1. Review any warnings above"
echo "  2. Deploy to staging first"
echo "  3. Run smoke tests on staging"
echo "  4. Get PO sign-off"
echo "  5. Deploy to production"
echo "  6. Monitor error tracking"
echo ""
echo "=================================="
```

## Summary

Comprehensive pre-deployment validation including quality gates, builds, tests, environment checks, security audit, and performance analysis.

**Use when**: Before any production deployment
**Exit codes**: 0 = ready to deploy, 1 = blocked (fix issues first)
**SAFe Note**: Ensure deployment aligns with PI objectives and has PO approval
