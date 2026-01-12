---
name: security-audit
description: Convex RBAC validation, security audits, OWASP compliance, and vulnerability scanning. Use when validating auth helpers, auditing API routes, multi-tenant isolation, or scanning for security issues.
---

# Security Audit Skill

## Purpose

Guide security validation with Convex RBAC enforcement, multi-tenant isolation, OWASP compliance, and vulnerability detection following security-first architecture.

## When This Skill Applies

Invoke this skill when:

- Validating Convex auth helper usage (requireAuth, requireOrganization, requirePermission)
- Auditing multi-tenant data isolation (organizationId scoping)
- Reviewing client-side query gating patterns
- Verifying webhook signature validation
- Pre-deployment security review
- Checking for exposed credentials
- Reviewing database access patterns

## Stop-the-Line Conditions

### FORBIDDEN Patterns

```typescript
// FORBIDDEN: Missing auth helper in Convex queries/mutations
export const listCompanies = query({
  handler: async (ctx) => {
    return await ctx.db.query("companies").collect();
    // Missing requireAuth/requireOrganization - returns ALL data!
  }
});

// FORBIDDEN: No organization scoping (multi-tenant leak)
export const list = query({
  handler: async (ctx) => {
    await requireAuth(ctx);
    return await ctx.db.query("deals").collect();
    // Returns deals from ALL organizations!
  }
});

// FORBIDDEN: Client-side query without auth gating
const { isAuthenticated } = useConvexAuth();
const user = useQuery(api.users.getCurrentUser);
// Query executes before auth is established - causes "Not authenticated" errors

// FORBIDDEN: Exposed credentials in code
const API_KEY = "sk_live_abc123"; // Hardcoded secret
const WEBHOOK_SECRET = "whsec_xyz789"; // Hardcoded webhook secret

// FORBIDDEN: No webhook signature verification
export const handleWebhook = httpAction(async (ctx, request) => {
  const payload = await request.json();
  // Process webhook without verifying signature - security risk!
});

// FORBIDDEN: Direct database access in internal mutations without org scoping
export const createItem = internalMutation({
  handler: async (ctx, args) => {
    return await ctx.db.insert("items", args);
    // No organizationId - breaks multi-tenancy!
  }
});
```

### CORRECT Patterns

```typescript
// CORRECT: Auth helper with organization scoping
export const listCompanies = query({
  handler: async (ctx) => {
    const { organization } = await requireOrganization(ctx);

    return await ctx.db
      .query("companies")
      .filter(q => q.eq(q.field("organizationId"), organization._id))
      .collect();
  }
});

// CORRECT: Permission-protected mutation
export const deleteUser = mutation({
  handler: async (ctx, args) => {
    await requirePermission(ctx, "users:delete");
    const { organization } = await requireOrganization(ctx);

    // Verify user belongs to same organization
    const user = await ctx.db.get(args.userId);
    if (!user || user.organizationId !== organization._id) {
      throw new Error("User not found");
    }

    await ctx.db.delete(args.userId);
  }
});

// CORRECT: Client-side query gating
const { isAuthenticated } = useConvexAuth();
const user = useQuery(
  api.users.getCurrentUser,
  isAuthenticated ? {} : "skip"
);

// CORRECT: Environment variables for secrets
const API_KEY = process.env.STRIPE_SECRET_KEY;
const WEBHOOK_SECRET = process.env.WEBHOOK_SECRET;

// CORRECT: Webhook signature verification
export const handleWebhook = httpAction(async (ctx, request) => {
  const signature = request.headers.get("x-webhook-signature");
  const payload = await request.text();

  if (!verifySignature(payload, signature, process.env.WEBHOOK_SECRET)) {
    return new Response("Invalid signature", { status: 401 });
  }

  // Process verified webhook...
});

// CORRECT: Internal mutation with explicit org scoping
export const createItem = internalMutation({
  args: {
    organizationId: v.id("organizations"),
    userId: v.id("users"),
    // ...other args
  },
  handler: async (ctx, args) => {
    return await ctx.db.insert("items", {
      ...args,
      organizationId: args.organizationId,
      createdBy: args.userId,
    });
  }
});
```

## Security Audit Checklist

### 1. Convex Auth Helper Validation

- [ ] All queries/mutations use requireAuth, requireOrganization, or requirePermission
- [ ] No direct database operations without auth context
- [ ] Destructive operations use requirePermission with appropriate permission string
- [ ] Actions verify auth before calling internal mutations

```bash
# Find queries/mutations missing auth helpers
grep -r "export const .* = query" packages/backend/convex/ --include="*.ts" | \
  xargs -I {} grep -L "requireAuth\|requireOrganization\|requirePermission" {}

# Find all auth helper usage
grep -rn "requireAuth\|requireOrganization\|requirePermission" packages/backend/convex/ --include="*.ts"
```

### 2. Multi-Tenant Isolation

- [ ] All entity tables have organizationId field in schema
- [ ] All queries filter by organizationId from requireOrganization
- [ ] User cannot access data from other organizations
- [ ] Internal mutations receive organizationId as explicit parameter

```bash
# Find queries that might miss organization scoping
grep -rn "ctx.db.query" packages/backend/convex/ --include="*.ts" | \
  grep -v "organizationId\|by_organization"

# Verify schema has organizationId on multi-tenant tables
grep -n "organizationId" packages/backend/convex/schema.ts
```

### 3. Client-Side Query Gating

- [ ] All authenticated queries use isAuthenticated ? args : "skip" pattern
- [ ] useConvexAuth hook is called before any query execution
- [ ] Loading states handle the undefined query result properly

```bash
# Find potential ungated queries
grep -rn "useQuery(api\." apps/*/src --include="*.tsx" | \
  grep -v "isAuthenticated\|skip"

# Find correct gating patterns
grep -rn "isAuthenticated.*skip" apps/*/src --include="*.tsx"
```

### 4. Webhook Security

- [ ] All webhook handlers verify signature before processing
- [ ] Webhook secrets stored in environment variables
- [ ] No webhook handlers process unsigned requests in production
- [ ] WorkOS webhooks verify WorkOS-Signature header
- [ ] Polar/Stripe webhooks verify respective signatures

```bash
# Find webhook handlers
grep -rn "httpAction.*request" packages/backend/convex/ --include="*.ts"

# Check for signature verification
grep -rn "signature\|Signature" packages/backend/convex/ --include="*.ts"
```

### 5. Credential Scanning

- [ ] No hardcoded secrets in code
- [ ] No API keys in client-side code (except public keys)
- [ ] Environment variables used correctly
- [ ] Convex env vars set via bunx convex env set

```bash
# Scan for potential secrets
grep -rE "(sk_live|pk_live|password|secret|api_key|apiKey)" --include="*.ts" --include="*.tsx" | \
  grep -v "process.env\|.env"

# Check for Convex env vars
cd packages/backend && bunx convex env list
```

### 6. Input Validation

- [ ] User input validated with Convex v validators or Zod schemas
- [ ] No raw string interpolation in queries
- [ ] File upload restrictions in place
- [ ] Pagination limits enforced (max 100 items typically)

```bash
# Find mutations without args validation
grep -rn "export const .* = mutation" packages/backend/convex/ --include="*.ts" | \
  xargs -I {} grep -L "args:" {}
```

### 7. Dependency Vulnerabilities

```bash
# Run security audit
bun audit
npm audit

# Check for high/critical vulnerabilities
npm audit --audit-level=high
```

## OWASP Top 10 Checklist (Convex-Adapted)

| Risk                 | Check                                          | Status |
| -------------------- | ---------------------------------------------- | ------ |
| A01 Broken Access    | Auth helpers on all routes, org scoping        | [ ]    |
| A02 Crypto Failures  | Secrets in env vars only, no client exposure   | [ ]    |
| A03 Injection        | Convex validators, no raw interpolation        | [ ]    |
| A04 Insecure Design  | Auth-first pattern, query gating               | [ ]    |
| A05 Misconfiguration | Prod env properly secured, debug flags off     | [ ]    |
| A06 Vulnerable Deps  | bun audit clean                                | [ ]    |
| A07 Auth Failures    | WorkOS integration correct, sessions secure    | [ ]    |
| A08 Data Integrity   | Org scoping prevents cross-tenant access       | [ ]    |
| A09 Logging Failures | Security events logged, webhook events tracked | [ ]    |
| A10 SSRF             | External URLs validated, no user-controlled    | [ ]    |

## Security Validation Commands

```bash
# Complete security check
cd packages/backend && \
  bunx convex dev --once && \
  bun lint && \
  bun audit && \
  echo "Security checks passed"

# Auth helper coverage check
echo "=== Queries/Mutations ===" && \
grep -c "export const .* = query\|mutation" packages/backend/convex/*.ts && \
echo "=== With Auth Helpers ===" && \
grep -c "requireAuth\|requireOrganization\|requirePermission" packages/backend/convex/*.ts

# Multi-tenant isolation check
echo "=== Tables with organizationId ===" && \
grep -c "organizationId" packages/backend/convex/schema.ts

# Secret detection
git secrets --scan 2>/dev/null || \
  grep -rE "sk_|pk_|password=|secret=" . --include="*.ts" | grep -v node_modules
```

## Auth Helper Reference

### 1. requireAuth(ctx)

**Use for**: Any authenticated operation

```typescript
import { requireAuth } from "@v1/backend/convex/lib/authHelpers";

export const myQuery = query({
  handler: async (ctx) => {
    const identity = await requireAuth(ctx);
    // identity.subject = WorkOS user ID
    // identity.email = User email
  }
});
```

### 2. requireOrganization(ctx)

**Use for**: Multi-tenant operations (most common)

```typescript
import { requireOrganization } from "@v1/backend/convex/lib/authHelpers";

export const list = query({
  handler: async (ctx) => {
    const { identity, user, membership, organization } = await requireOrganization(ctx);

    return await ctx.db
      .query("items")
      .filter(q => q.eq(q.field("organizationId"), organization._id))
      .collect();
  }
});
```

### 3. requirePermission(ctx, permission)

**Use for**: RBAC-protected operations

```typescript
import { requirePermission } from "@v1/backend/convex/lib/authHelpers";

// Permission format: "resource:action"
// Examples: "users:read", "users:write", "users:delete", "billing:manage"

export const deleteUser = mutation({
  handler: async (ctx, args) => {
    await requirePermission(ctx, "users:delete");
    // User has permission - proceed
  }
});
```

### Role Hierarchy

```
owner: All permissions (wildcard *)
  |
admin: users:*, org:*, billing:*
  |
member: tasks:rw, projects:rw, labels:rw, users:read
  |
viewer: Read-only access
```

## Pre-Deployment Security Review

Before ANY production deployment:

- [ ] All queries use appropriate auth helpers
- [ ] Multi-tenant isolation verified (test with 2+ orgs)
- [ ] Client-side query gating in place
- [ ] No hardcoded secrets in codebase
- [ ] Webhook signatures verified in production mode
- [ ] Environment variables documented
- [ ] bun audit shows no high/critical issues
- [ ] CORS properly configured for production domains
- [ ] Debug flags disabled in production

## Security Audit Report Template

```markdown
## Security Audit Report - [TICKET-XXX]

### Summary

- **Date**: [date]
- **Auditor**: Security Engineer
- **Scope**: [what was audited]

### Findings

| Severity | Issue | Location | Status |
| -------- | ----- | -------- | ------ |
| HIGH     | ...   | ...      | FIXED  |
| MEDIUM   | ...   | ...      | OPEN   |

### Auth Helper Coverage

- [x] All public queries use requireAuth/requireOrganization
- [x] Permission-protected mutations use requirePermission
- [x] Internal mutations receive org context as parameters

### Multi-Tenant Isolation

- [x] All multi-tenant tables have organizationId
- [x] All queries filter by organization
- [x] Cross-tenant access tested and blocked

### Client-Side Security

- [x] All queries use isAuthenticated gating
- [x] No sensitive data in client-side code
- [x] Public env vars properly prefixed (NEXT_PUBLIC_)

### Webhook Security

- [x] WorkOS webhook signature verified
- [x] Polar/Stripe webhook signatures verified
- [x] No unsigned webhook processing in production

### Recommendations

1. [recommendation]
2. [recommendation]

### Approval

- [ ] Security Engineer approves
- [ ] Ready for deployment
```

## Authoritative References

- **Auth Helpers**: packages/backend/convex/lib/authHelpers.ts
- **Backend Guide**: packages/backend/CLAUDE.md
- **App Auth Patterns**: apps/app/CLAUDE.md
- **Webhook Handlers**: packages/backend/convex/webhooks.ts
- **WorkOS Webhooks**: packages/backend/convex/workosWebhooks.ts
- **Schema Definition**: packages/backend/convex/schema.ts
- **OWASP Top 10**: https://owasp.org/Top10/
