---
name: rls-patterns
description: >
  Row Level Security patterns for database operations. Use when writing any
  database query, creating API routes that access data, implementing webhooks
  that write to the database, or working with user data. Enforces
  withUserContext, withAdminContext, or withSystemContext helpers. NEVER use
  direct ORM/DB calls without RLS context wrappers.
---

# RLS Patterns Skill

> **TEMPLATE**: This skill uses `{{PLACEHOLDER}}` tokens. Replace with your project values before use.

## Purpose

Enforce Row Level Security (RLS) patterns for all database operations. This skill ensures data isolation and prevents cross-user data access at the database level.

## When This Skill Applies

- Writing any database query (ORM or raw SQL)
- Creating or modifying API routes that access the database
- Implementing webhook handlers that write to the database
- Working with user data, payments, subscriptions, or enrollments
- Accessing admin-only tables

## Critical Rules

### NEVER Do This

```typescript
// FORBIDDEN - Direct DB calls bypass RLS
const user = await db.user.findUnique({ where: { user_id } });

// FORBIDDEN - No context set
const payments = await db.payments.findMany();
```

**Linting will block direct DB calls.** See linting configuration for enforcement rules.

### ALWAYS Do This

```typescript
import {
  withUserContext,
  withAdminContext,
  withSystemContext,
} from "{{RLS_IMPORT}}";

// CORRECT - User context for user operations
const user = await withUserContext(db, userId, async (client) => {
  return client.user.findUnique({ where: { user_id: userId } });
});

// CORRECT - Admin context for admin operations
const webhooks = await withAdminContext(db, userId, async (client) => {
  return client.webhook_events.findMany();
});

// CORRECT - System context for webhooks/background tasks
const event = await withSystemContext(db, "webhook", async (client) => {
  return client.webhook_events.create({ data: eventData });
});
```

## Context Helper Reference

### `withUserContext(db, userId, callback)`

**Use for**: All user-facing operations

- User profile access
- Payment history
- Subscription management
- Enrollments and personal data

```typescript
const payments = await withUserContext(db, userId, async (client) => {
  return client.payments.findMany({ where: { user_id: userId } });
});
```

### `withAdminContext(db, userId, callback)`

**Use for**: Admin-only operations (requires admin role)

- Viewing all webhook events
- Managing disputes
- Accessing payment failures

```typescript
const disputes = await withAdminContext(db, adminUserId, async (client) => {
  return client.disputes.findMany();
});
```

### `withSystemContext(db, contextType, callback)`

**Use for**: Webhooks and background jobs

- Webhook handlers (Stripe, auth provider, etc.)
- Background job processing
- System-initiated operations

```typescript
await withSystemContext(db, "webhook", async (client) => {
  await client.payments.create({ data: paymentData });
});
```

## Admin Pages: Force Dynamic Rendering

**CRITICAL**: Admin pages using RLS queries MUST force runtime rendering (in Next.js):

```typescript
// REQUIRED - RLS context unavailable at build time
export const dynamic = "force-dynamic";

async function getAdminData() {
  return await withAdminContext(db, userId, async (client) => {
    return client.someTable.findMany();
  });
}
```

Without forced dynamic rendering, frameworks may try to pre-render at build time, causing "permission denied" errors.

## Protected Tables

### User Data Tables (User Isolation)

| Table               | Policy Type    | Access                 |
| ------------------- | -------------- | ---------------------- |
| `user`              | User isolation | Own data only          |
| `payments`          | User isolation | Own payments only      |
| `subscriptions`     | User isolation | Own subscriptions only |
| `invoices`          | User isolation | Own invoices only      |

### Admin/System Tables (Role-Based)

| Table                 | Policy Type  | Access                   |
| --------------------- | ------------ | ------------------------ |
| `webhook_events`      | Admin+System | Admins and webhooks only |
| `disputes`            | Admin only   | Admins only              |
| `payment_failures`    | Admin only   | Admins only              |

## Testing Requirements

Always test with the application-level DB user role (not a superuser):

```bash
# Basic RLS functionality test
{{RLS_TEST_COMMAND}}

# Comprehensive security validation
{{RLS_VALIDATION_COMMAND}}
```

## Common Patterns

### API Route with User Context

```typescript
import { NextResponse } from "next/server";
import { requireAuth } from "{{AUTH_IMPORT}}";
import { withUserContext } from "{{RLS_IMPORT}}";
import { db } from "{{DB_IMPORT}}";

export async function GET() {
  const { userId } = await requireAuth();

  const payments = await withUserContext(db, userId, async (client) => {
    return client.payments.findMany({
      where: { user_id: userId },
      orderBy: { created_at: "desc" },
    });
  });

  return NextResponse.json(payments);
}
```

### Webhook Handler with System Context

```typescript
import { withSystemContext } from "{{RLS_IMPORT}}";
import { db } from "{{DB_IMPORT}}";

export async function POST(req: Request) {
  // Verify webhook signature first...

  await withSystemContext(db, "webhook", async (client) => {
    await client.webhook_events.create({
      data: {
        event_type: event.type,
        payload: event.data,
        processed_at: new Date(),
      },
    });
  });

  return new Response("OK", { status: 200 });
}
```

## Authoritative References

- **RLS Implementation Guide**: `docs/database/RLS_IMPLEMENTATION_GUIDE.md`
- **RLS Policy Catalog**: `docs/database/RLS_POLICY_CATALOG.md`
- **Migration SOP**: `docs/database/RLS_DATABASE_MIGRATION_SOP.md`
- **Linting Rules**: Check linting config for direct DB call enforcement
- **RLS Context Helpers**: `{{RLS_CONTEXT_FILE}}`
