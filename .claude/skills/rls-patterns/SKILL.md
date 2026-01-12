---
name: rls-patterns
description: Enforce authorization for all Convex database operations using auth helpers. Prevents unauthorized data access through three context helpers.
---

# Convex Authorization Patterns

## Purpose
Enforce authorization for ALL database operations. No query or mutation should access data without proper authentication and authorization checks.

## When to Use
- Writing any Convex query or mutation
- Accessing user data
- Performing CRUD operations
- Creating new database functions

## The Three Auth Helpers

### 1. requireAuth(ctx)
For basic authenticated operations. Returns the current user.

```typescript
import { requireAuth } from "./lib/authorization";

export const getCurrentUser = query({
  handler: async (ctx) => {
    const user = await requireAuth(ctx);
    return user;
  },
});
```

### 2. requireOrganization(ctx)
**MOST COMMON** - For multi-tenant operations. Returns user with organization context.

```typescript
import { requireOrganization } from "./lib/authorization";

export const getOrgRecords = query({
  handler: async (ctx) => {
    const { userId, organizationId } = await requireOrganization(ctx);
    
    // ALWAYS scope by organizationId
    return await ctx.db
      .query("records")
      .withIndex("by_organization", q => q.eq("organizationId", organizationId))
      .collect();
  },
});
```

### 3. requirePermission(ctx, permission)
For RBAC-protected operations. Checks specific permissions.

```typescript
import { requirePermission } from "./lib/authorization";

export const deleteRecord = mutation({
  args: { id: v.id("records") },
  handler: async (ctx, args) => {
    // Check admin permission
    await requirePermission(ctx, "records:delete");
    
    await ctx.db.delete(args.id);
  },
});
```

## FORBIDDEN: Direct Database Access

**NEVER** access the database without auth helpers:

```typescript
// WRONG - No auth check
export const getRecords = query({
  handler: async (ctx) => {
    return await ctx.db.query("records").collect(); // FORBIDDEN!
  },
});

// WRONG - Missing organization scoping
export const getRecords = query({
  handler: async (ctx) => {
    const user = await requireAuth(ctx);
    return await ctx.db.query("records").collect(); // Still wrong!
  },
});

// CORRECT - Auth + organization scoping
export const getRecords = query({
  handler: async (ctx) => {
    const { organizationId } = await requireOrganization(ctx);
    return await ctx.db
      .query("records")
      .withIndex("by_organization", q => q.eq("organizationId", organizationId))
      .collect();
  },
});
```

## Multi-Tenant Isolation (CRITICAL)

Every query involving user data MUST scope by organization:

```typescript
// Table schema MUST include organizationId
records: defineTable({
  organizationId: v.id("organizations"),  // REQUIRED
  createdBy: v.id("users"),
  title: v.string(),
  // ...
})
  .index("by_organization", ["organizationId"])  // REQUIRED
  .index("by_creator", ["organizationId", "createdBy"]),

// Query MUST use organization index
const records = await ctx.db
  .query("records")
  .withIndex("by_organization", q => q.eq("organizationId", orgId))
  .collect();
```

## Internal Mutations (System Operations)

For scheduled jobs, webhooks, and internal operations:

```typescript
import { internalMutation } from "./_generated/server";

export const processWebhook = internalMutation({
  args: { eventId: v.string(), data: v.any() },
  handler: async (ctx, args) => {
    // No user context - this is a system operation
    // Still scope by organization from webhook data
    const { organizationId } = args.data.metadata;
    
    await ctx.db.insert("events", {
      organizationId,
      eventId: args.eventId,
      processedAt: Date.now(),
    });
  },
});
```

## Client-Side Query Gating

**CRITICAL**: Gate authenticated queries on the client:

```typescript
// WRONG - Query runs before auth is ready
const records = useQuery(api.records.getRecords);

// CORRECT - Query waits for auth
const { isAuthenticated } = useConvexAuth();
const records = useQuery(
  api.records.getRecords,
  isAuthenticated ? {} : "skip"
);
```

## Permission Levels

Standard RBAC permissions:

| Permission | Description |
|------------|-------------|
| `resource:read` | View resource |
| `resource:write` | Create/update resource |
| `resource:delete` | Delete resource |
| `admin:*` | Full admin access |

## Validation Checklist

Before completing any backend work:

- [ ] All queries use appropriate auth helper
- [ ] All multi-tenant queries scope by organizationId
- [ ] Organization index exists on table
- [ ] RBAC permissions checked where needed
- [ ] Client-side queries gated with isAuthenticated
- [ ] Internal mutations properly scoped

## Error Handling

```typescript
import { ConvexError } from "convex/values";

export const secureOperation = mutation({
  handler: async (ctx, args) => {
    const user = await requireOrganization(ctx);
    
    const record = await ctx.db.get(args.id);
    if (!record) {
      throw new ConvexError({ code: "NOT_FOUND", message: "Record not found" });
    }
    
    // Verify ownership
    if (record.organizationId !== user.organizationId) {
      throw new ConvexError({ code: "FORBIDDEN", message: "Access denied" });
    }
    
    // Proceed with operation
  },
});
```

## Canonical Locations

| Component | Path |
|-----------|------|
| Auth helpers | `packages/backend/convex/lib/authorization.ts` |
| Schema | `packages/backend/convex/schema.ts` |
| Auth types | `packages/backend/convex/lib/authTypes.ts` |
