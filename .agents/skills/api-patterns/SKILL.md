---
name: api-patterns
description: >
  API route implementation patterns with RLS, validation, and error handling.
  Use when creating API routes, implementing CRUD endpoints, adding server-side
  validation, handling webhooks, or implementing error handling patterns. Do NOT
  use for frontend-only changes or database migrations without API involvement.
---

# API Patterns Skill

> **TEMPLATE**: This skill uses `{{PLACEHOLDER}}` tokens. Replace with your project values before use.

## Purpose

Route to existing API patterns and provide checklists for safe, validated API route implementation. All API routes MUST use RLS context helpers -- see `rls-patterns` skill.

## When This Skill Applies

- Creating new API routes
- Implementing CRUD endpoints
- Adding request/response validation
- Handling webhooks
- Implementing error handling patterns

## Authoritative References (MUST READ)

| Pattern           | Location                                         | Purpose                     |
| ----------------- | ------------------------------------------------ | --------------------------- |
| User Context API  | `patterns_library/api/user-context-api.md`       | User-scoped operations      |
| Admin Context API | `patterns_library/api/admin-context-api.md`      | Admin-scoped operations     |
| Zod Validation    | `patterns_library/api/zod-validation-api.md`     | Request/response validation |
| Webhook Handler   | `patterns_library/api/webhook-handler.md`        | Webhook processing          |
| Bonus Content     | `patterns_library/api/bonus-content-delivery.md` | Protected content delivery  |

## Stop-the-Line Conditions

### FORBIDDEN Patterns

```typescript
// FORBIDDEN: Direct ORM/DB calls (bypass RLS)
const users = await db.user.findMany();
// Must use: withUserContext, withAdminContext, or withSystemContext

// FORBIDDEN: Missing authentication check
export async function GET(req: Request) {
  return getUserData(); // No auth check!
}

// FORBIDDEN: Unvalidated user input
const { userId } = await req.json();
// Must validate with schema validation (Zod, Pydantic, etc.)

// FORBIDDEN: Generic error responses
return new Response("Error", { status: 500 });
// Must use structured error response
```

### CORRECT Patterns

```typescript
// CORRECT: RLS context + auth check
export async function GET(req: Request) {
  const { userId } = await auth();
  if (!userId) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const data = await withUserContext(db, userId, async (client) => {
    return client.user.findUnique({ where: { user_id: userId } });
  });

  return NextResponse.json(data);
}

// CORRECT: Schema validation
const schema = z.object({
  email: z.string().email(),
  name: z.string().min(1),
});

const result = schema.safeParse(body);
if (!result.success) {
  return NextResponse.json(
    { error: "Validation failed", details: result.error.flatten() },
    { status: 400 },
  );
}
```

## API Route Checklist

Before ANY API route:

- [ ] Authentication check
- [ ] Proper 401 response for unauthenticated
- [ ] Request validation with schema (Zod, Pydantic, etc.)
- [ ] RLS context wrapper (`withUserContext`/`withAdminContext`/`withSystemContext`)
- [ ] Structured error responses with appropriate status codes
- [ ] Type-safe request/response definitions

## Standard Response Patterns

### Success Response

```json
{ "data": { ... }, "success": true }
```

### Error Response

```json
{
  "error": "Human-readable error message",
  "code": "ERROR_CODE",
  "details": "optional_details"
}
```

### Status Codes

| Code | When to Use                                  |
| ---- | -------------------------------------------- |
| 200  | Success                                      |
| 201  | Created (POST)                               |
| 400  | Bad request / validation error               |
| 401  | Not authenticated                            |
| 403  | Forbidden (authenticated but not authorized) |
| 404  | Resource not found                           |
| 500  | Server error                                 |

## API Route Template

```typescript
import { auth } from "{{AUTH_IMPORT}}";
import { NextResponse } from "next/server";
import { z } from "zod";
import { withUserContext } from "{{RLS_IMPORT}}";
import { db } from "{{DB_IMPORT}}";

// Request validation schema
const RequestSchema = z.object({
  // Define expected fields
});

export async function POST(req: Request) {
  try {
    // 1. Authenticate
    const { userId } = await auth();
    if (!userId) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    // 2. Parse and validate request
    const body = await req.json();
    const result = RequestSchema.safeParse(body);
    if (!result.success) {
      return NextResponse.json(
        { error: "Validation failed", details: result.error.flatten() },
        { status: 400 },
      );
    }

    // 3. Execute with RLS context
    const data = await withUserContext(db, userId, async (client) => {
      return client.resource.create({ data: result.data });
    });

    // 4. Return success response
    return NextResponse.json({ data, success: true }, { status: 201 });
  } catch (error) {
    console.error("API error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 },
    );
  }
}
```

## API Documentation Template

For documenting new endpoints:

```markdown
## Endpoint: POST /api/resource

### Description
Creates a new resource for the authenticated user.

### Authentication
Required: {{AUTH_PROVIDER}} session

### Request Body
| Field | Type   | Required | Description   |
| ----- | ------ | -------- | ------------- |
| name  | string | Yes      | Resource name |
| type  | string | No       | Resource type |

### Response
**Success (201)**:
{ "data": { "id": 1, "name": "..." }, "success": true }

**Error (400)**:
{ "error": "Validation failed", "details": {...} }

### RLS Context
Uses `withUserContext` - user can only access own resources.
```

## Related Skills

- **rls-patterns**: RLS context helper usage (REQUIRED for all DB operations)
- **security-audit**: API security validation
- **testing-patterns**: API endpoint testing
