# Security Audit

![Status](https://img.shields.io/badge/status-production-green)
![Harness](https://img.shields.io/badge/harness-v2.2-blue)

> Convex RBAC validation, security audits, OWASP compliance, and vulnerability scanning.

## Quick Start

This skill activates automatically when you:
- Validate Convex auth helper usage
- Audit multi-tenant data isolation
- Run vulnerability scanning
- Check for exposed credentials
- Review database access patterns
- Verify webhook signature security

## What This Skill Does

Guides security validation with Convex RBAC enforcement, multi-tenant organization scoping, OWASP compliance checking, and vulnerability detection. Follows security-first architecture principles to prevent data leaks and unauthorized access.

## Key Security Patterns

### Three Auth Helpers

| Helper | Use Case | Returns |
|--------|----------|---------|
| `requireAuth(ctx)` | Any authenticated operation | `identity` |
| `requireOrganization(ctx)` | Multi-tenant operations | `{ identity, user, membership, organization }` |
| `requirePermission(ctx, "resource:action")` | RBAC-protected operations | void (throws on failure) |

### Client-Side Query Gating

```typescript
const { isAuthenticated } = useConvexAuth();
const data = useQuery(
  api.module.function,
  isAuthenticated ? { orgId } : "skip"
);
```

### Multi-Tenant Isolation

```typescript
const { organization } = await requireOrganization(ctx);
return await ctx.db
  .query("items")
  .filter(q => q.eq(q.field("organizationId"), organization._id))
  .collect();
```

## Trigger Keywords

| Primary | Secondary |
|---------|-----------|
| security | audit |
| auth helper | requireAuth |
| multi-tenant | organizationId |
| OWASP | vulnerability |
| webhook | signature |

## Related Skills

- [convex-patterns](../convex-patterns/) - Convex backend patterns (if exists)
- [frontend-patterns](../frontend-patterns/) - Client-side auth patterns
- [testing-patterns](../testing-patterns/) - Security test patterns

## Maintenance

| Field | Value |
|-------|-------|
| Last Updated | 2026-01-12 |
| Harness Version | v2.2.0 |
| Adapted From | WTFB security-audit |
| Target Stack | ConTStack (Convex + WorkOS) |

---

*Full implementation details in [SKILL.md](SKILL.md)*
