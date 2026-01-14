---
name: rls-patterns
description: Row Level Security patterns for database operations. Use when writing Prisma/database code, creating API routes that access data, or implementing webhooks. Enforces withUserContext, withAdminContext, or withSystemContext helpers. NEVER use direct prisma calls.
---

# RLS Patterns Skill

## Purpose

Enforce Row Level Security (RLS) patterns for all database operations. Ensures data isolation and prevents cross-user data access.

## When This Skill Applies

- Writing any Prisma database query
- Creating or modifying API routes that access the database
- Implementing webhook handlers
- Working with user data, payments, subscriptions

## Critical Rules

### NEVER Do This

```typescript
// ❌ FORBIDDEN - Direct Prisma calls bypass RLS
const user = await prisma.user.findUnique({ where: { user_id } });
```

### ALWAYS Do This

```typescript
import { withUserContext, withAdminContext, withSystemContext } from "@/lib/rls-context";

// ✅ CORRECT - User context for user operations
const user = await withUserContext(prisma, userId, async (client) => {
  return client.user.findUnique({ where: { user_id: userId } });
});

// ✅ CORRECT - System context for webhooks
await withSystemContext(prisma, "webhook", async (client) => {
  return client.webhook_events.create({ data: eventData });
});
```

## Context Helper Reference

| Helper | Use For |
| ------ | ------- |
| `withUserContext` | User-facing operations (profile, payments, subscriptions) |
| `withAdminContext` | Admin-only operations (disputes, webhook events) |
| `withSystemContext` | Webhooks and background jobs |

## Common Patterns

### API Route with User Context

```typescript
export async function GET() {
  const { userId } = await requireAuth();

  const payments = await withUserContext(prisma, userId, async (client) => {
    return client.payments.findMany({
      where: { user_id: userId },
      orderBy: { created_at: "desc" },
    });
  });

  return NextResponse.json(payments);
}
```

### Admin Pages: Force Dynamic

```typescript
// REQUIRED for admin pages with RLS
export const dynamic = "force-dynamic";
```

## Reference

- **Implementation Guide**: `docs/database/RLS_IMPLEMENTATION_GUIDE.md`
- **Policy Catalog**: `docs/database/RLS_POLICY_CATALOG.md`
