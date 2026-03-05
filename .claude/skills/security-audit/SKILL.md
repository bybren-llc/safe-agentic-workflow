---
name: security-audit
description: RLS validation, security audits, OWASP compliance, and vulnerability scanning. Use when validating RLS policies, auditing API routes, or scanning for security issues.
context: fork
agent: Explore
allowed-tools: Read, Bash, Grep, Glob
---

# Security Audit Skill

## Purpose

Guide security validation with RLS enforcement, OWASP compliance, and vulnerability detection following security-first architecture.

## When This Skill Applies

Invoke this skill when:

- Validating RLS policies
- Auditing API routes for auth
- Vulnerability scanning
- Pre-deployment security review
- Checking for exposed credentials
- Reviewing database access patterns

## Stop-the-Line Conditions

### FORBIDDEN Patterns

```typescript
// FORBIDDEN: Direct Prisma calls (bypass RLS)
const users = await prisma.user.findMany();
// Must use: withUserContext, withAdminContext, or withSystemContext

// FORBIDDEN: Missing authentication on protected routes
export async function GET(req: Request) {
  // No auth check before accessing user data
  return getUserData();
}

// FORBIDDEN: Exposed credentials
const API_KEY = "sk_live_abc123"; // Hardcoded secret

// FORBIDDEN: SQL injection vulnerability
const query = `SELECT * FROM users WHERE id = ${userId}`; // Interpolated
```

### CORRECT Patterns

```typescript
// CORRECT: RLS context wrapper
const users = await withUserContext(prisma, userId, async (client) => {
  return client.user.findMany();
});

// CORRECT: Auth check before data access
export async function GET(req: Request) {
  const { userId } = await auth();
  if (!userId) {
    return new Response("Unauthorized", { status: 401 });
  }
  return getUserData(userId);
}

// CORRECT: Environment variables for secrets
const API_KEY = process.env.STRIPE_SECRET_KEY;

// CORRECT: Parameterized queries
const user = await prisma.$queryRaw`SELECT * FROM users WHERE id = ${userId}`;
```

## Security Audit Checklist

### 1. RLS Validation

- [ ] All database operations use context wrappers
- [ ] No direct Prisma calls in route handlers
- [ ] User isolation verified (user A cannot see user B's data)
- [ ] Admin operations properly scoped

```bash
# Find potential RLS bypasses
grep -r "prisma\." --include="*.ts" app/ lib/ | grep -v "withUserContext\|withAdminContext\|withSystemContext"
```

### 2. Authentication Checks

- [ ] All protected routes verify authentication
- [ ] Clerk auth() called before data access
- [ ] Proper 401/403 responses for unauthorized

```bash
# Find routes missing auth checks
grep -r "export async function" --include="route.ts" app/ | head -20
# Manually verify each has auth check
```

### 3. Credential Scanning

- [ ] No hardcoded secrets in code
- [ ] No API keys in client-side code
- [ ] Environment variables used correctly

```bash
# Scan for potential secrets
grep -rE "(sk_live|pk_live|password|secret|key)" --include="*.ts" --include="*.tsx" | grep -v "process.env\|.env"
```

### 4. Dependency Vulnerabilities

```bash
# Run security audit
npm audit
yarn audit

# Check for high/critical vulnerabilities
npm audit --audit-level=high
```

### 5. Input Validation

- [ ] User input validated with Zod schemas
- [ ] No raw query interpolation
- [ ] File upload restrictions in place

## OWASP Top 10 Checklist

| Risk                 | Check                            | Status |
| -------------------- | -------------------------------- | ------ |
| A01 Broken Access    | RLS enforced, auth on all routes | ☐      |
| A02 Crypto Failures  | Secrets in env vars only         | ☐      |
| A03 Injection        | Parameterized queries, Zod       | ☐      |
| A04 Insecure Design  | Auth-first pattern followed      | ☐      |
| A05 Misconfiguration | Prod env properly secured        | ☐      |
| A06 Vulnerable Deps  | npm audit clean                  | ☐      |
| A07 Auth Failures    | Clerk integration correct        | ☐      |
| A08 Data Integrity   | RLS prevents tampering           | ☐      |
| A09 Logging Failures | Security events logged           | ☐      |
| A10 SSRF             | External URLs validated          | ☐      |

## Security Validation Commands

```bash
# Complete security check
npm audit && yarn lint && echo "Security checks passed"

# RLS bypass detection
grep -r "prisma\." --include="*.ts" app/ lib/ | wc -l
# Compare with context wrapper count

# Secret detection
git secrets --scan  # If git-secrets installed
grep -rE "sk_|pk_|password=" . --include="*.ts"
```

## Pre-Deployment Security Review

Before ANY production deployment:

- [ ] npm audit shows no high/critical issues
- [ ] RLS policies validated
- [ ] No new direct Prisma calls
- [ ] Environment variables documented
- [ ] Backup taken before migration
- [ ] Rollback plan documented

## Security Audit Report Template

```markdown
## Security Audit Report - {{TICKET_PREFIX}}-XXX

### Summary

- **Date**: [date]
- **Auditor**: Security Engineer
- **Scope**: [what was audited]

### Findings

| Severity | Issue | Location | Status |
| -------- | ----- | -------- | ------ |
| HIGH     | ...   | ...      | FIXED  |
| MEDIUM   | ...   | ...      | OPEN   |

### RLS Validation

- [x] All tables have RLS enabled
- [x] User isolation verified
- [x] Admin policies scoped correctly

### Recommendations

1. [recommendation]
2. [recommendation]

### Approval

- [ ] Security Engineer approves
- [ ] Ready for deployment
```

## Authoritative References

- **Security Architecture**: `docs/guides/SECURITY_FIRST_ARCHITECTURE.md`
- **RLS Implementation**: `docs/database/RLS_IMPLEMENTATION_GUIDE.md`
- **RLS Policies**: `docs/database/RLS_POLICY_CATALOG.md`
- **OWASP Top 10**: <https://owasp.org/Top10/>
