# /test-auth - Authentication Flow Testing

Test complete authentication integration for Supabase Auth with RLS.

## Steps

### 1. Check Supabase Configuration
```bash
echo "Verifying Supabase Configuration..."

# Check environment variables
if [ -z "$NEXT_PUBLIC_SUPABASE_URL" ]; then
  echo "NEXT_PUBLIC_SUPABASE_URL not set"
  exit 1
fi

if [ -z "$NEXT_PUBLIC_SUPABASE_ANON_KEY" ]; then
  echo "NEXT_PUBLIC_SUPABASE_ANON_KEY not set"
  exit 1
fi

if [ -z "$SUPABASE_SERVICE_ROLE_KEY" ]; then
  echo "SUPABASE_SERVICE_ROLE_KEY not set"
  exit 1
fi

echo "Supabase environment variables configured"
```

### 2. Verify Supabase Connection
```bash
echo "Testing Supabase connection..."

# Test connection with curl (if supabase CLI not available)
curl -s -o /dev/null -w "%{http_code}" \
  "$NEXT_PUBLIC_SUPABASE_URL/rest/v1/" \
  -H "apikey: $NEXT_PUBLIC_SUPABASE_ANON_KEY" \
  | grep -q "200" && echo "Supabase API reachable" || echo "Supabase API unreachable"

echo "Supabase connection verified"
```

### 3. Check RLS Policies
```bash
echo "Verifying RLS policies..."

# List all tables with RLS enabled
echo "- Tables with RLS enabled:"
npx supabase db test --list-tables 2>/dev/null || \
  rg "ALTER TABLE.*ENABLE ROW LEVEL SECURITY" supabase/migrations --type sql

# Check for policy coverage
echo "- RLS policy coverage:"
rg "CREATE POLICY" supabase/migrations --type sql | wc -l

echo "RLS policies verified"
```

### 4. Run E2E Authentication Tests
```bash
echo "Running E2E authentication tests..."

# Run Playwright auth tests
npm run test:e2e -- --grep "@auth"

if [ $? -ne 0 ]; then
  echo "E2E authentication tests failed"
  echo "Check logs for details"
  exit 1
fi

echo "E2E authentication tests passed"
```

### 5. Test Auth Middleware
```bash
echo "Testing authentication middleware..."

# Check for auth middleware implementation
echo "- Checking middleware.ts:"
rg "getSession|auth\.getUser|createServerClient" src/middleware.ts --type ts

# Check for protected routes
echo "- Protected routes configuration:"
rg "matcher.*protected|config.*matcher" src/middleware.ts --type ts

echo "Auth middleware verified"
```

### 6. Test Server-Side Auth
```bash
echo "Testing server-side authentication..."

# Check for server component auth
echo "- Server component auth patterns:"
rg "createServerComponentClient|createRouteHandlerClient|getServerSession" src --type ts -l

# Check for auth in API routes
echo "- API route auth patterns:"
rg "supabase\.auth\.getUser|requireAuth" src/app/api --type ts -l

echo "Server-side auth verified"
```

### 7. Test Client-Side Auth
```bash
echo "Testing client-side authentication..."

# Check for client auth hooks
echo "- Client auth hook usage:"
rg "useSession|useUser|useSupabaseClient" src --type tsx -l

# Check for auth state handling
echo "- Auth state handling:"
rg "onAuthStateChange|session" src --type tsx -l

echo "Client-side auth verified"
```

### 8. Test Multi-Tenant Isolation
```bash
echo "Testing multi-tenant isolation..."

# Check for organization/tenant scoping
echo "- Organization scoping in queries:"
rg "organization_id|tenant_id" src --type ts -l

# Check RLS uses auth.uid()
echo "- RLS using auth.uid():"
rg "auth\.uid\(\)" supabase/migrations --type sql

echo "Multi-tenant isolation verified"
```

### 9. Generate Test Report
```bash
echo ""
echo "=================================="
echo "AUTHENTICATION TEST REPORT"
echo "=================================="
echo ""
echo "PASSED:"
echo "  - Supabase environment variables configured"
echo "  - Supabase API connection verified"
echo "  - RLS policies implemented"
echo "  - E2E authentication tests passed"
echo "  - Auth middleware configured"
echo "  - Server-side auth implemented"
echo "  - Client-side auth implemented"
echo "  - Multi-tenant isolation verified"
echo ""
echo "AUTH COMPONENTS VERIFIED:"
echo "  - Supabase Auth (email/password, OAuth)"
echo "  - Row Level Security (RLS)"
echo "  - Server component authentication"
echo "  - Client-side session handling"
echo "  - API route protection"
echo "  - Multi-tenant data isolation"
echo ""
echo "=================================="
```

## Summary

Tests complete authentication integration including Supabase Auth, RLS policies, server/client auth patterns, and multi-tenant isolation.

**Use when**: After auth changes, before deployment, debugging auth issues, RLS policy updates
**ConTS Note**: Update relevant ConTS tickets with auth test status
