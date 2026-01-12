---
name: migration-patterns
description: Convex schema evolution patterns for safe database changes. Use when adding tables, modifying fields, updating indexes, or planning data migrations in ConTStack.
---

# Convex Schema Evolution Skill

## Purpose

Guide safe schema evolution in Convex for ConTStack, following the declarative schema-as-code approach with proper field validators, indexes, and multi-tenant patterns.

## When This Skill Applies

Invoke this skill when:

- Adding new tables (`defineTable`)
- Adding or modifying fields in existing tables
- Adding, modifying, or removing indexes
- Planning data backfill migrations
- Converting optional fields to required
- Schema impact analysis
- Multi-tenant data isolation verification

## Stop-the-Line Conditions

### FORBIDDEN Patterns

```typescript
// FORBIDDEN: Required field on existing table with data
// This will fail deployment if existing documents lack the field
defineTable({
  name: v.string(),
  newRequiredField: v.string(), // WRONG: Add as optional first
})

// FORBIDDEN: Missing organizationId for multi-tenant table
defineTable({
  name: v.string(),
  createdAt: v.number(),
  // Missing: organizationId: v.id("organizations")
})

// FORBIDDEN: Removing index that queries depend on
// Always verify no queries use the index before removal
.index("by_old_field", ["oldField"]) // Removing this breaks queries

// FORBIDDEN: Direct schema deploy without testing
bunx convex deploy // WRONG: Always test with --once first

// FORBIDDEN: Changing field type on existing data
// v.string() -> v.number() will fail on existing documents
userId: v.number(), // Was v.string()
```

### CORRECT Patterns

```typescript
// CORRECT: New field starts as optional
defineTable({
  name: v.string(),
  organizationId: v.id("organizations"), // Multi-tenant isolation
  createdAt: v.number(),
  // Phase 1: Add as optional
  newField: v.optional(v.string()),
})
  .index("by_organization", ["organizationId"]) // Always index organizationId

// CORRECT: With proper audit fields and indexes
defineTable({
  organizationId: v.id("organizations"),
  name: v.string(),
  description: v.optional(v.string()),
  status: v.union(
    v.literal("active"),
    v.literal("inactive"),
  ),
  // Audit fields
  createdBy: v.id("users"),
  createdAt: v.number(),
  updatedAt: v.number(),
})
  .index("by_organization", ["organizationId"])
  .index("by_organization_status", ["organizationId", "status"])
  .index("by_created_at", ["createdAt"])
```

## Schema Evolution Workflow (MANDATORY)

### Phase 1: Add Optional Field

**ALWAYS start with optional fields for non-empty tables.**

```typescript
// Step 1: Add field as optional in schema.ts
myTable: defineTable({
  existingField: v.string(),
  newField: v.optional(v.string()), // Start optional
})

// Step 2: Validate locally
bunx convex dev --once

// Step 3: Deploy schema change
bunx convex deploy
```

### Phase 2: Backfill Data

**Create and run backfill mutation for existing documents.**

```typescript
// convex/migrations/backfillNewField.ts
import { internalMutation } from "../_generated/server"
import { v } from "convex/values"

// Internal mutation for backfill (not exposed to clients)
export const backfillNewField = internalMutation({
  args: {
    batchSize: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const batchSize = args.batchSize ?? 100

    // Find documents missing the field
    const docs = await ctx.db
      .query("myTable")
      .filter((q) => q.eq(q.field("newField"), undefined))
      .take(batchSize)

    if (docs.length === 0) {
      console.log("Backfill complete: no more documents to process")
      return { complete: true, processed: 0 }
    }

    // Backfill each document
    for (const doc of docs) {
      await ctx.db.patch(doc._id, {
        newField: calculateDefaultValue(doc), // Your logic here
      })
    }

    console.log(`Backfilled ${docs.length} documents`)
    return { complete: false, processed: docs.length }
  },
})

// Helper to calculate default value
function calculateDefaultValue(doc: any): string {
  // Return appropriate default based on existing data
  return doc.existingField ? `derived-${doc.existingField}` : "default"
}
```

**Run backfill:**
```bash
# Run in batches until complete
bunx convex run migrations/backfillNewField:backfillNewField

# With custom batch size
bunx convex run migrations/backfillNewField:backfillNewField '{"batchSize": 500}'

# Repeat until complete: true is returned
```

### Phase 3: Make Field Required (Optional)

**Only after ALL documents have the field.**

```typescript
// Step 1: Verify no documents missing the field
const missing = await ctx.db
  .query("myTable")
  .filter((q) => q.eq(q.field("newField"), undefined))
  .first()

if (missing) {
  throw new Error("Cannot make required: documents still missing field")
}

// Step 2: Update schema - change optional to required
myTable: defineTable({
  existingField: v.string(),
  newField: v.string(), // Now required (remove v.optional wrapper)
})

// Step 3: Deploy
bunx convex deploy
```

## Index Management

### Adding Indexes

```typescript
// Add new index - safe operation (no data changes)
.index("by_new_field", ["newField"])

// Compound index for common query patterns
.index("by_org_status_date", ["organizationId", "status", "createdAt"])

// Search index for text search
.searchIndex("search_name", {
  searchField: "name",
  filterFields: ["organizationId", "status"],
})

// Vector index for AI/semantic search
.vectorIndex("by_embedding", {
  vectorField: "embedding",
  dimensions: 384,
  filterFields: ["organizationId"],
})
```

### Removing Indexes

**CRITICAL: Verify no queries use the index before removal.**

```bash
# Step 1: Search for index usage in codebase
rg "withIndex.*by_old_field" packages/backend/convex --type ts
rg "\.index.*by_old_field" packages/backend/convex --type ts

# Step 2: If no matches, safe to remove from schema.ts
# Step 3: Deploy
bunx convex deploy
```

## Validator Reference

### Primitive Types
```typescript
v.string()                    // String
v.number()                    // Number (including floats)
v.boolean()                   // Boolean
v.null()                      // Null literal
v.int64()                     // 64-bit integer
v.float64()                   // 64-bit float
```

### Reference Types
```typescript
v.id("tableName")             // Document ID reference
v.array(v.string())           // Array of strings
v.object({...})               // Nested object
v.record(v.string(), v.any()) // Key-value map
```

### Union Types
```typescript
v.optional(v.string())        // Optional string (can be undefined)
v.union(                      // Enum-like union
  v.literal("active"),
  v.literal("inactive"),
  v.literal("archived"),
)
v.any()                       // Any type (use sparingly)
```

### Complex Patterns
```typescript
// Nested object with optional fields
preferences: v.optional(v.object({
  theme: v.union(v.literal("light"), v.literal("dark")),
  notifications: v.boolean(),
  timezone: v.optional(v.string()),
}))

// Array of IDs
tagIds: v.array(v.id("tags"))

// Flexible metadata
metadata: v.optional(v.record(v.string(), v.any()))

// Timestamp (always store as number - milliseconds)
createdAt: v.number()
```

## Multi-Tenant Schema Pattern

**CRITICAL: All user-facing tables MUST include `organizationId`.**

```typescript
// Standard multi-tenant table template
newTable: defineTable({
  // Multi-tenant isolation (REQUIRED)
  organizationId: v.id("organizations"),

  // Business fields
  name: v.string(),
  status: v.union(v.literal("active"), v.literal("inactive")),

  // Common relational fields
  ownerId: v.id("users"),

  // Audit fields (recommended)
  createdBy: v.id("users"),
  createdAt: v.number(),
  updatedAt: v.number(),
})
  // Required index for multi-tenant queries
  .index("by_organization", ["organizationId"])
  // Owner lookup within org
  .index("by_organization_owner", ["organizationId", "ownerId"])
```

**Query Pattern:**
```typescript
// CORRECT: Always filter by organizationId
const { organization } = await requireOrganization(ctx)

const items = await ctx.db
  .query("newTable")
  .withIndex("by_organization", (q) =>
    q.eq("organizationId", organization._id)
  )
  .collect()
```

## Rollback Patterns

### Rolling Back Field Addition

```typescript
// If backfill failed or field not needed:

// Step 1: Remove field from schema (if optional)
// Simply remove the field from defineTable - Convex ignores extra fields

// Step 2: Clean up data (optional, for large tables)
export const cleanupField = internalMutation({
  handler: async (ctx) => {
    const docs = await ctx.db.query("myTable").collect()
    for (const doc of docs) {
      // Convex doesn't support unsetting fields, but optional fields
      // can be ignored in queries and will be cleaned on next write
    }
  },
})
```

### Rolling Back Index Changes

```typescript
// Remove index from schema.ts
// Indexes are dropped automatically on deploy

// Re-add old index if needed
.index("by_old_pattern", ["oldField"])
```

### Rolling Back Table Addition

```typescript
// Step 1: Remove all data
export const cleanupTable = internalMutation({
  handler: async (ctx) => {
    const docs = await ctx.db.query("newTable").collect()
    for (const doc of docs) {
      await ctx.db.delete(doc._id)
    }
  },
})

// Step 2: Remove table from schema.ts
// Step 3: Deploy
bunx convex deploy
```

## Schema Change Checklist

Before PR:

- [ ] Schema validates locally (`bunx convex dev --once`)
- [ ] New fields added as `v.optional()` for non-empty tables
- [ ] Backfill mutation created if converting optional to required
- [ ] Multi-tenant tables include `organizationId: v.id("organizations")`
- [ ] Required indexes created (at minimum `by_organization` for multi-tenant)
- [ ] No breaking type changes on existing fields
- [ ] No required fields added to tables with existing data
- [ ] Rollback plan documented for complex changes

For Production Deployments:

- [ ] Schema change tested in dev environment
- [ ] Backfill tested with production-like data volume
- [ ] Backfill performance acceptable (consider batching for large tables)
- [ ] Monitoring plan for post-deploy validation
- [ ] Human approval obtained for schema changes

## Common Migration Scenarios

### Adding a New Feature Table

```typescript
// 1. Add table to schema.ts
features: defineTable({
  organizationId: v.id("organizations"),
  name: v.string(),
  description: v.optional(v.string()),
  isEnabled: v.boolean(),
  createdBy: v.id("users"),
  createdAt: v.number(),
  updatedAt: v.number(),
})
  .index("by_organization", ["organizationId"])
  .index("by_name", ["organizationId", "name"])

// 2. Create CRUD mutations in convex/features.ts
// 3. Deploy: bunx convex deploy
```

### Adding Relationship Field

```typescript
// 1. Add optional reference field
contacts: defineTable({
  ...existing,
  companyId: v.optional(v.id("companies")), // Start optional
})
  .index("by_company", ["companyId"]) // Add index for lookups

// 2. Deploy schema
// 3. Run backfill if needed
// 4. Convert to required after backfill (if applicable)
```

### Adding Computed/Derived Field

```typescript
// 1. Add optional field for computed value
companies: defineTable({
  ...existing,
  totalScore: v.optional(v.number()), // Computed from other scores
})

// 2. Create computation mutation
export const recomputeScores = internalMutation({
  handler: async (ctx) => {
    const companies = await ctx.db.query("companies").collect()
    for (const company of companies) {
      const totalScore = calculateTotalScore(company)
      await ctx.db.patch(company._id, { totalScore })
    }
  },
})

// 3. Add trigger to update on related changes
```

## Authoritative References

- **Schema Source of Truth**: `packages/backend/convex/schema.ts`
- **Auth Helpers**: `packages/backend/convex/lib/authHelpers.ts`
- **Backend Guide**: `packages/backend/CLAUDE.md`
- **Multi-Tenant Patterns**: RBAC section in backend guide
- **Convex Docs**: https://docs.convex.dev/database/schemas
