---
name: api-patterns
description: Convex API patterns for queries, mutations, actions, external API integration, webhooks, and multi-tenant data access. Use when implementing API endpoints, external service integrations, or webhook handlers.
---

# API Patterns Skill (ConTStack/Convex)

## Purpose

Route to existing Convex API patterns and provide checklists for safe, validated API implementation. All Convex functions MUST use auth helpers--see `rls-patterns` skill for multi-tenant patterns.

## When This Skill Applies

Invoke this skill when:

- Creating new Convex queries/mutations/actions
- Implementing external API integrations (Google Calendar, LinkedIn, YouTube, etc.)
- Adding request/response validation with Zod
- Handling webhooks (Polar, WorkOS, internal)
- Building multi-tenant API endpoints
- Integrating with bubble-api (port 3007)

## Authoritative References (MUST READ)

| Pattern               | Location                                           | Purpose                        |
| --------------------- | -------------------------------------------------- | ------------------------------ |
| Auth Helpers          | `packages/backend/convex/lib/authHelpers.ts`       | Auth and permission validation |
| Service Clients       | `packages/backend/convex/bubbles/serviceClients.ts`| External OAuth API patterns    |
| HTTP Routes           | `packages/backend/convex/http.ts`                  | Webhook routing patterns       |
| Polar Subscriptions   | `packages/backend/convex/subscriptions.ts`         | Payment integration            |
| Backend CLAUDE.md     | `packages/backend/CLAUDE.md`                       | Complete backend reference     |

## Port Mapping Reference

| Port | Service      | Purpose                              |
| ---- | ------------ | ------------------------------------ |
| 3003 | app          | Main SaaS application                |
| 3006 | crm          | CRM application                      |
| 3007 | bubble-api   | BubbleLab workflow API               |

## Stop-the-Line Conditions

### FORBIDDEN Patterns

```typescript
// FORBIDDEN: Direct database access without auth check
export const listData = query({
  handler: async (ctx) => {
    return await ctx.db.query("companies").collect();
    // Exposes ALL companies across ALL organizations!
  }
});

// FORBIDDEN: Using ctx.auth in internal mutations (doesn't exist)
export const internalProcess = internalMutation({
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity(); // undefined!
    // Internal mutations don't have auth context
  }
});

// FORBIDDEN: Direct fetch in queries/mutations (use actions)
export const fetchData = mutation({
  handler: async (ctx) => {
    const response = await fetch("https://api.example.com/..."); // Error!
    // fetch() only works in actions, not queries/mutations
  }
});

// FORBIDDEN: Missing organization scoping
export const list = query({
  handler: async (ctx) => {
    const { user } = await requireOrganization(ctx);
    return await ctx.db.query("deals").collect(); // No org filter!
  }
});

// FORBIDDEN: Unvalidated user input
export const createCompany = mutation({
  args: {
    data: v.any(), // Never use v.any() for user input!
  },
  handler: async (ctx, { data }) => {
    await ctx.db.insert("companies", data); // Security risk!
  }
});
```

### CORRECT Patterns

```typescript
// CORRECT: Multi-tenant query with auth + organization scoping
export const listCompanies = query({
  handler: async (ctx) => {
    const { organization } = await requireOrganization(ctx);

    return await ctx.db
      .query("companies")
      .withIndex("by_organization", (q) =>
        q.eq("organizationId", organization._id)
      )
      .collect();
  }
});

// CORRECT: Validated mutation with permission check
export const createDeal = mutation({
  args: {
    name: v.string(),
    value: v.number(),
    companyId: v.id("companies"),
  },
  handler: async (ctx, args) => {
    await requirePermission(ctx, "deals:write");
    const { organization, user } = await requireOrganization(ctx);

    // Verify company belongs to same organization
    const company = await ctx.db.get(args.companyId);
    if (!company || company.organizationId !== organization._id) {
      throw new ConvexError("Company not found");
    }

    return await ctx.db.insert("deals", {
      ...args,
      organizationId: organization._id,
      createdBy: user._id,
      createdAt: Date.now(),
    });
  }
});

// CORRECT: External API call via action
export const syncCalendar = action({
  args: {
    calendarId: v.string(),
    timeMin: v.number(),
    timeMax: v.number(),
  },
  handler: async (ctx, args) => {
    const { organization } = await requireOrganization(ctx);

    // Get OAuth client (see BubbleLab patterns below)
    const calendar = await getGoogleCalendarClient(ctx, organization._id);

    const events = await calendar.listEvents(args.calendarId, {
      timeMin: new Date(args.timeMin),
      timeMax: new Date(args.timeMax),
    });

    return events;
  }
});
```

## Convex Function Types

### Query (Read Operations)

```typescript
import { query } from "./_generated/server";
import { v } from "convex/values";
import { requireOrganization } from "./lib/authHelpers";

export const getById = query({
  args: {
    id: v.id("companies"),
  },
  handler: async (ctx, { id }) => {
    const { organization } = await requireOrganization(ctx);

    const company = await ctx.db.get(id);

    // Multi-tenant isolation check
    if (!company || company.organizationId !== organization._id) {
      return null;
    }

    return company;
  }
});

export const list = query({
  args: {
    limit: v.optional(v.number()),
    cursor: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const { organization } = await requireOrganization(ctx);
    const limit = args.limit ?? 50;

    const results = await ctx.db
      .query("companies")
      .withIndex("by_organization", (q) =>
        q.eq("organizationId", organization._id)
      )
      .order("desc")
      .take(limit + 1);

    const hasMore = results.length > limit;
    const items = hasMore ? results.slice(0, -1) : results;

    return {
      items,
      hasMore,
      cursor: hasMore ? items[items.length - 1]?._id : null,
    };
  }
});
```

### Mutation (Write Operations)

```typescript
import { mutation } from "./_generated/server";
import { v } from "convex/values";
import { ConvexError } from "convex/values";
import { requireOrganization, requirePermission } from "./lib/authHelpers";

export const create = mutation({
  args: {
    name: v.string(),
    industry: v.optional(v.string()),
    website: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    await requirePermission(ctx, "companies:write");
    const { organization, user } = await requireOrganization(ctx);

    // Input validation beyond Convex validators
    if (args.name.length > 200) {
      throw new ConvexError("Company name too long (max 200 chars)");
    }

    const id = await ctx.db.insert("companies", {
      ...args,
      organizationId: organization._id,
      createdBy: user._id,
      createdAt: Date.now(),
      updatedAt: Date.now(),
    });

    return { id, success: true };
  }
});

export const update = mutation({
  args: {
    id: v.id("companies"),
    name: v.optional(v.string()),
    industry: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    await requirePermission(ctx, "companies:write");
    const { organization, user } = await requireOrganization(ctx);

    const existing = await ctx.db.get(args.id);
    if (!existing || existing.organizationId !== organization._id) {
      throw new ConvexError("Company not found");
    }

    const { id, ...updates } = args;
    await ctx.db.patch(id, {
      ...updates,
      updatedBy: user._id,
      updatedAt: Date.now(),
    });

    return { success: true };
  }
});

export const remove = mutation({
  args: {
    id: v.id("companies"),
  },
  handler: async (ctx, { id }) => {
    await requirePermission(ctx, "companies:delete");
    const { organization } = await requireOrganization(ctx);

    const existing = await ctx.db.get(id);
    if (!existing || existing.organizationId !== organization._id) {
      throw new ConvexError("Company not found");
    }

    await ctx.db.delete(id);
    return { success: true };
  }
});
```

### Action (External API Calls)

Actions are required for:
- HTTP requests to external APIs
- File system operations
- Any non-deterministic operations

```typescript
import { action } from "./_generated/server";
import { v } from "convex/values";
import { internal } from "./_generated/api";

export const fetchExternalData = action({
  args: {
    url: v.string(),
    method: v.optional(v.union(v.literal("GET"), v.literal("POST"))),
    body: v.optional(v.any()),
  },
  handler: async (ctx, args) => {
    // Auth check works in actions
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Not authenticated");
    }

    const response = await fetch(args.url, {
      method: args.method ?? "GET",
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer " + process.env.API_KEY,
      },
      body: args.body ? JSON.stringify(args.body) : undefined,
    });

    if (!response.ok) {
      throw new Error("API error: " + response.status + " " + response.statusText);
    }

    const data = await response.json();

    // Store results via internal mutation
    await ctx.runMutation(internal.storage.saveExternalData, {
      userId: identity.subject,
      data,
    });

    return data;
  }
});
```

### Internal Functions (Server-to-Server)

**CRITICAL**: Internal functions do NOT have `ctx.auth` - pass user info as parameters.

```typescript
import { internalMutation, internalQuery } from "./_generated/server";
import { v } from "convex/values";

// Internal query - no auth context
export const getByIdInternal = internalQuery({
  args: {
    id: v.id("companies"),
    organizationId: v.id("organizations"),
  },
  handler: async (ctx, { id, organizationId }) => {
    const company = await ctx.db.get(id);

    // Manual org check since no auth context
    if (!company || company.organizationId !== organizationId) {
      return null;
    }

    return company;
  }
});

// Internal mutation - receives auth info as parameters
export const createFromWebhook = internalMutation({
  args: {
    organizationId: v.id("organizations"),
    userId: v.id("users"),
    data: v.object({
      name: v.string(),
      externalId: v.string(),
    }),
  },
  handler: async (ctx, { organizationId, userId, data }) => {
    // No ctx.auth available - use passed parameters
    return await ctx.db.insert("companies", {
      ...data,
      organizationId,
      createdBy: userId,
      createdAt: Date.now(),
    });
  }
});
```

## BubbleLab External API Patterns

### OAuth Service Client Pattern

ConTStack uses REST wrappers for OAuth-authenticated external APIs. Reference: `packages/backend/convex/bubbles/serviceClients.ts`

```typescript
"use node";  // Required for fetch in Convex actions

import { ActionCtx } from "../_generated/server";
import { Id } from "../_generated/dataModel";

// Fetch OAuth credential from bubble-api
async function fetchOAuthCredential(
  ctx: ActionCtx,
  organizationId: Id<"organizations">,
  credentialType: string,
) {
  const identity = await ctx.auth.getUserIdentity();
  if (!identity) return null;

  const params = new URLSearchParams({
    userId: identity.subject,
    organizationId,
    credentialType,
  });

  const bubbleApiUrl = process.env.BUBBLE_API_URL || "http://localhost:3007";
  const internalToken = process.env.BUBBLE_API_INTERNAL_TOKEN;

  const response = await fetch(
    bubbleApiUrl + "/api/internal/oauth-credentials?" + params,
    {
      headers: { Authorization: "Bearer " + internalToken },
    }
  );

  if (!response.ok) return null;
  return (await response.json()).credential;
}

// Google Calendar client factory
export async function getGoogleCalendarClient(
  ctx: ActionCtx,
  organizationId: Id<"organizations">,
) {
  const credential = await fetchOAuthCredential(
    ctx,
    organizationId,
    "GOOGLE_CALENDAR_CRED",
  );

  if (!credential?.oauthAccessToken) {
    throw new Error("Google Calendar not connected");
  }

  const accessToken = credential.oauthAccessToken;

  return {
    async listEvents(calendarId: string, params: { timeMin: Date; timeMax: Date }) {
      const url = new URL(
        "https://www.googleapis.com/calendar/v3/calendars/" + encodeURIComponent(calendarId) + "/events"
      );
      url.searchParams.set("timeMin", params.timeMin.toISOString());
      url.searchParams.set("timeMax", params.timeMax.toISOString());
      url.searchParams.set("singleEvents", "true");

      const response = await fetch(url.toString(), {
        headers: { Authorization: "Bearer " + accessToken },
      });

      if (!response.ok) {
        throw new Error("Google Calendar API error: " + response.status);
      }

      return (await response.json()).items || [];
    },

    async createEvent(calendarId: string, event: {
      summary: string;
      start: { dateTime: string };
      end: { dateTime: string };
    }) {
      const response = await fetch(
        "https://www.googleapis.com/calendar/v3/calendars/" + encodeURIComponent(calendarId) + "/events",
        {
          method: "POST",
          headers: {
            Authorization: "Bearer " + accessToken,
            "Content-Type": "application/json",
          },
          body: JSON.stringify(event),
        }
      );

      if (!response.ok) {
        throw new Error("Google Calendar API error: " + response.status);
      }

      return response.json();
    },
  };
}

// YouTube Data API client
export async function getYouTubeClient(
  ctx: ActionCtx,
  organizationId: Id<"organizations">,
) {
  const credential = await fetchOAuthCredential(
    ctx,
    organizationId,
    "YOUTUBE_DATA_CRED",
  );

  if (!credential?.oauthAccessToken) {
    throw new Error("YouTube not connected");
  }

  const accessToken = credential.oauthAccessToken;
  const apiKey = process.env.YOUTUBE_API_KEY;

  return {
    async searchVideos(query: string, maxResults = 10) {
      const url = new URL("https://www.googleapis.com/youtube/v3/search");
      url.searchParams.set("part", "snippet");
      url.searchParams.set("q", query);
      url.searchParams.set("maxResults", String(maxResults));
      url.searchParams.set("type", "video");
      url.searchParams.set("key", apiKey!);

      const response = await fetch(url.toString(), {
        headers: { Authorization: "Bearer " + accessToken },
      });

      if (!response.ok) {
        throw new Error("YouTube API error: " + response.status);
      }

      return (await response.json()).items || [];
    },
  };
}

// LinkedIn API client
export async function getLinkedInClient(
  ctx: ActionCtx,
  organizationId: Id<"organizations">,
) {
  const credential = await fetchOAuthCredential(
    ctx,
    organizationId,
    "LINKEDIN_CRED",
  );

  if (!credential?.oauthAccessToken) {
    throw new Error("LinkedIn not connected");
  }

  const accessToken = credential.oauthAccessToken;

  return {
    async getProfile() {
      const response = await fetch(
        "https://api.linkedin.com/v2/me?projection=(id,firstName,lastName)",
        {
          headers: {
            Authorization: "Bearer " + accessToken,
            "X-Restli-Protocol-Version": "2.0.0",
          },
        }
      );

      if (!response.ok) {
        throw new Error("LinkedIn API error: " + response.status);
      }

      return response.json();
    },

    async createPost(text: string) {
      const response = await fetch("https://api.linkedin.com/v2/shares", {
        method: "POST",
        headers: {
          Authorization: "Bearer " + accessToken,
          "Content-Type": "application/json",
          "X-Restli-Protocol-Version": "2.0.0",
        },
        body: JSON.stringify({
          text: { text },
          distribution: { linkedInDistributionTarget: {} },
        }),
      });

      if (!response.ok) {
        throw new Error("LinkedIn API error: " + response.status);
      }

      return response.json();
    },
  };
}
```

## Webhook Handling Patterns

### Polar Payment Webhooks

ConTStack uses Polar (not Stripe) for payments. Webhooks are handled via `@convex-dev/polar`.

```typescript
// packages/backend/convex/subscriptions.ts
import { Polar } from "@convex-dev/polar";
import { api, components } from "./_generated/api";

export const polar = new Polar(components.polar, {
  getUserInfo: async (ctx) => {
    const user = await ctx.runQuery(api.users.getUser);
    if (!user?.email) throw new Error("User not found");
    return { userId: user._id, email: user.email };
  },
});

// Export API functions
export const {
  changeCurrentSubscription,
  cancelCurrentSubscription,
  listAllProducts,
} = polar.api();

export const { generateCheckoutLink, generateCustomerPortalUrl } =
  polar.checkoutApi();

// Register routes in http.ts
// polar.registerRoutes(http);  // Handles /polar/events
```

### Custom Webhook Routes

```typescript
// packages/backend/convex/http.ts
import { httpRouter } from "convex/server";
import { httpAction } from "./_generated/server";

const http = httpRouter();

// Internal webhook with token verification
http.route({
  path: "/webhook/task-update",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    // Verify internal auth token
    const authHeader = request.headers.get("Authorization");
    const expectedAuth = "Bearer " + process.env.WEBHOOK_SECRET;

    if (authHeader !== expectedAuth) {
      return new Response(
        JSON.stringify({ error: "Unauthorized" }),
        { status: 401, headers: { "Content-Type": "application/json" } }
      );
    }

    try {
      const payload = await request.json();

      // Validate payload with Zod
      const result = webhookPayloadSchema.safeParse(payload);
      if (!result.success) {
        return new Response(
          JSON.stringify({ error: "Invalid payload", details: result.error.flatten() }),
          { status: 400, headers: { "Content-Type": "application/json" } }
        );
      }

      // Process webhook
      await ctx.runMutation(internal.tasks.updateFromWebhook, result.data);

      return new Response(
        JSON.stringify({ success: true }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    } catch (error) {
      console.error("Webhook error:", error);
      return new Response(
        JSON.stringify({ error: "Processing failed" }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }
  }),
});
```

### WorkOS Webhook Pattern

```typescript
// packages/backend/convex/workosWebhooks.ts
import { httpAction } from "./_generated/server";
import { internal } from "./_generated/api";
import WorkOS from "@workos-inc/node";

const workos = new WorkOS(process.env.WORKOS_API_KEY);

export const handleWorkOSWebhook = httpAction(async (ctx, request) => {
  const payload = await request.text();
  const sigHeader = request.headers.get("WorkOS-Signature");

  // Verify signature
  try {
    const event = workos.webhooks.constructEvent({
      payload,
      sigHeader: sigHeader!,
      secret: process.env.WORKOS_WEBHOOK_SECRET!,
    });

    switch (event.event) {
      case "user.created":
        await ctx.runMutation(internal.users.createFromWorkOS, {
          workosUserId: event.data.id,
          email: event.data.email,
          firstName: event.data.first_name,
          lastName: event.data.last_name,
        });
        break;

      case "user.updated":
        await ctx.runMutation(internal.users.updateFromWorkOS, {
          workosUserId: event.data.id,
          email: event.data.email,
        });
        break;

      case "organization_membership.created":
        await ctx.runMutation(internal.organizations.addMember, {
          workosUserId: event.data.user_id,
          workosOrgId: event.data.organization_id,
          role: event.data.role?.slug || "member",
        });
        break;
    }

    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("WorkOS webhook error:", error);
    return new Response(
      JSON.stringify({ error: "Webhook verification failed" }),
      { status: 400, headers: { "Content-Type": "application/json" } }
    );
  }
});
```

## Zod Validation Patterns

Zod validation is still valid and recommended for complex input validation.

```typescript
import { z } from "zod";
import { mutation } from "./_generated/server";
import { v } from "convex/values";
import { ConvexError } from "convex/values";

// Define Zod schema for complex validation
const CreateCompanySchema = z.object({
  name: z.string()
    .min(1, "Name is required")
    .max(200, "Name too long"),
  website: z.string()
    .url("Invalid URL")
    .optional()
    .nullable(),
  industry: z.enum([
    "technology", "finance", "healthcare", "retail", "other"
  ]).optional(),
  employees: z.number()
    .int()
    .min(1)
    .max(1000000)
    .optional(),
  metadata: z.record(z.unknown()).optional(),
});

export const create = mutation({
  args: {
    // Use v.any() then validate with Zod for complex schemas
    input: v.object({
      name: v.string(),
      website: v.optional(v.string()),
      industry: v.optional(v.string()),
      employees: v.optional(v.number()),
      metadata: v.optional(v.any()),
    }),
  },
  handler: async (ctx, { input }) => {
    // Validate with Zod for detailed error messages
    const result = CreateCompanySchema.safeParse(input);

    if (!result.success) {
      throw new ConvexError({
        code: "VALIDATION_ERROR",
        message: "Invalid input",
        details: result.error.flatten(),
      });
    }

    const { organization, user } = await requireOrganization(ctx);

    return await ctx.db.insert("companies", {
      ...result.data,
      organizationId: organization._id,
      createdBy: user._id,
      createdAt: Date.now(),
    });
  },
});
```

## Error Handling Patterns

### ConvexError Usage

```typescript
import { ConvexError } from "convex/values";

// Simple error
throw new ConvexError("Resource not found");

// Structured error with code
throw new ConvexError({
  code: "NOT_FOUND",
  message: "Company not found",
  resourceId: companyId,
});

// Validation error
throw new ConvexError({
  code: "VALIDATION_ERROR",
  message: "Invalid input",
  details: {
    name: ["Name is required"],
    email: ["Invalid email format"],
  },
});

// Permission error
throw new ConvexError({
  code: "FORBIDDEN",
  message: "Permission denied - 'deals:delete' required",
});
```

### Client-Side Error Handling

```typescript
// In React component
import { useMutation } from "convex/react";
import { api } from "@v1/backend/convex/_generated/api";

function CreateCompanyForm() {
  const createCompany = useMutation(api.companies.create);

  const handleSubmit = async (data: FormData) => {
    try {
      const result = await createCompany({ input: data });
      toast.success("Company created!");
    } catch (error) {
      if (error instanceof ConvexError) {
        const errorData = error.data;

        if (errorData.code === "VALIDATION_ERROR") {
          // Show field-specific errors
          setErrors(errorData.details);
        } else if (errorData.code === "FORBIDDEN") {
          toast.error("You don't have permission to create companies");
        } else {
          toast.error(errorData.message || "An error occurred");
        }
      } else {
        toast.error("An unexpected error occurred");
      }
    }
  };
}
```

## API Route Checklist

Before ANY Convex function:

- [ ] Determine function type: query, mutation, action, or internal
- [ ] Add appropriate auth helper: `requireAuth`, `requireOrganization`, or `requirePermission`
- [ ] Scope all data access by `organizationId` (multi-tenant isolation)
- [ ] Validate input with Convex validators (`v.string()`, etc.)
- [ ] Add Zod validation for complex input schemas
- [ ] Use `ConvexError` for structured error responses
- [ ] For external API calls, use `action` with `"use node"` directive
- [ ] For internal functions, pass auth info as explicit parameters
- [ ] Add indexes for query performance

## Standard Response Patterns

### Query Response

```typescript
// Single item
return company || null;

// List with pagination
return {
  items: companies,
  hasMore: companies.length > limit,
  cursor: lastItem?._id,
};
```

### Mutation Response

```typescript
// Create
return { id: newId, success: true };

// Update
return { success: true };

// Delete
return { success: true };
```

### Action Response

```typescript
// External API result
return {
  success: true,
  data: externalApiResponse,
  syncedAt: Date.now(),
};
```

## Related Skills

- **rls-patterns**: Multi-tenant data isolation patterns (REQUIRED for all DB operations)
- **payment-patterns**: Polar payment integration
- **testing-patterns**: Convex function testing
- **frontend-patterns**: React hooks for Convex queries/mutations
