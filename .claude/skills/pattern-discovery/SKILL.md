---
name: pattern-discovery
description: Unified pattern discovery using hierarchical CLAUDE.md structure with WTFB-style pre-implementation checks and pattern extraction workflow.
---

# ConTS-PatternDiscovery: Unified Pattern Discovery

> Combines ConTStack's hierarchical CLAUDE.md structure with WTFB's pattern-first methodology

## Purpose

Ensure consistent, high-quality implementations by discovering and applying existing patterns BEFORE writing new code, and extracting reusable patterns AFTER successful implementations.

## When This Skill Triggers

Activate pattern discovery when:
- About to create a new Convex query/mutation/action
- About to create a new React component
- About to add authentication or RBAC logic
- About to write integration or E2E tests
- About to configure Docker or infrastructure
- User asks "how do I implement..." or "how should I build..."
- Starting work on any feature implementation

**Key Principle**: ALWAYS check patterns BEFORE writing new code.

---

## Pattern Discovery Protocol

### Step 1: Identify Pattern Category

| Task Type | Primary CLAUDE.md | Secondary Reference |
|-----------|-------------------|---------------------|
| Convex query/mutation | packages/backend/CLAUDE.md | Root CLAUDE.md |
| Authentication/RBAC | apps/app/CLAUDE.md | packages/backend/CLAUDE.md |
| React component | packages/ui/CLAUDE.md | apps/app/CLAUDE.md |
| E2E testing | tests/CLAUDE.md | Docker CLAUDE.md |
| Email template | packages/email/CLAUDE.md | - |
| LLM integration | packages/llm/CLAUDE.md | - |
| Multi-tenant data | packages/backend/CLAUDE.md | Root CLAUDE.md |

### Step 2: Navigate Hierarchical CLAUDE.md

**Navigation Path** (progressive disclosure):

```
CLAUDE.md (root)
  |-- Quick overview, universal rules, navigation map
  |
  +-> packages/CLAUDE.md (router)
  |     |
  |     +-> packages/backend/CLAUDE.md
  |     |     |-- Convex patterns (query, mutation, action)
  |     |     |-- RBAC patterns (requireAuth, requirePermission)
  |     |     |-- Multi-tenant patterns (requireOrganization)
  |     |     +-- Schema patterns
  |     |
  |     +-> packages/ui/CLAUDE.md
  |     |     |-- Component patterns
  |     |     +-- Design system usage
  |     |
  |     +-> packages/email/CLAUDE.md
  |     +-> packages/llm/CLAUDE.md
  |
  +-> apps/CLAUDE.md (router)
  |     |
  |     +-> apps/app/CLAUDE.md
  |     |     |-- Auth integration patterns
  |     |     |-- Query gating pattern
  |     |     |-- withAuthGuard HOC
  |     |     +-- React hooks rules
  |     |
  |     +-> apps/web/CLAUDE.md
  |     +-> apps/crm/CLAUDE.md
  |     +-> apps/tasks/CLAUDE.md
  |
  +-> tests/CLAUDE.md
        |-- Unit test patterns (Vitest)
        |-- E2E patterns (Docker Playwright)
        +-- Convex test patterns (convex-test)
```

### Step 3: Search for Existing Patterns

**Use Quick Find Commands** to locate patterns in the codebase:

#### Component Discovery
```bash
# Find React component definition
rg -n "^export (function|const) .*Component" apps/*/src packages/ui/src --type tsx

# Find component usage
rg -n "<ComponentName" apps/*/src --type tsx

# Find component props interface
rg -n "interface.*Props" apps/*/src packages/ui/src --type tsx

# Find hooks
rg -n "export const use[A-Z]" apps/*/src --type tsx
```

#### Backend Discovery
```bash
# Find Convex mutation/query
rg -n "export const .* = (mutation|query|action)" packages/backend/convex --type ts

# Find auth helper usage
rg -n "requireAuth|requireOrganization|requirePermission" packages/backend/convex --type ts

# Find schema definition
rg -n "defineTable" packages/backend/convex/schema.ts --type ts

# Find indexes
rg -n "\.index\(" packages/backend/convex/schema.ts --type ts
```

#### Testing Discovery
```bash
# Find E2E tests
find tests/e2e -name "*.spec.ts"

# Find unit tests
find . -name "*.test.ts" -o -name "*.test.tsx"

# Find test utilities
rg -n "export.*helper|export.*mock" tests/ --type ts
```

#### Route Discovery
```bash
# Find Next.js App Router pages
find apps/*/src/app -name "page.tsx"

# Find API routes
find apps/*/src/app/api -name "route.ts"

# Find middleware
find apps/*/src -name "middleware.ts"
```

### Step 4: Apply or Escalate

**If pattern exists**:
1. Read the relevant CLAUDE.md section
2. Copy the pattern template
3. Customize for your specific use case
4. Validate implementation matches pattern

**If pattern is missing**:
1. Search codebase for similar implementations
2. Document the gap (create issue if significant)
3. After successful implementation, extract as new pattern

---

## Task-to-Pattern Quick Reference

| If you need to... | Look in... | Section |
|-------------------|------------|---------|
| Create authenticated Convex mutation | packages/backend/CLAUDE.md | #auth-helpers |
| Create protected React page | apps/app/CLAUDE.md | #authentication-integration-patterns |
| Gate Convex query on auth state | apps/app/CLAUDE.md | #query-gating |
| Add RBAC permission check | packages/backend/CLAUDE.md | #rbac-security-patterns |
| Scope data by organization | packages/backend/CLAUDE.md | #multi-tenant-data-isolation |
| Add new database table | packages/backend/CLAUDE.md | #schema-development |
| Build UI component | packages/ui/CLAUDE.md | #component-development-pattern |
| Create E2E test | tests/CLAUDE.md | #e2e-test-pattern |
| Create unit test | tests/CLAUDE.md | #unit-test-pattern |
| Test Convex functions | tests/CLAUDE.md | #convex-test-pattern |
| Add email template | packages/email/CLAUDE.md | #email-template-development |
| Configure Docker | docker/CLAUDE.md | #setup |
| Add new app to monorepo | apps/CLAUDE.md | #new-app-integration-template |

---

## Core Patterns (Quick Reference)

### Pattern 1: Authenticated Convex Mutation

**Location**: packages/backend/CLAUDE.md#auth-helpers

```typescript
// packages/backend/convex/yourModule.ts
import { mutation } from "./_generated/server"
import { requireOrganization, requirePermission } from "./lib/authHelpers"
import { v } from "convex/values"

export const create = mutation({
  args: {
    name: v.string(),
    // other fields...
  },
  handler: async (ctx, args) => {
    // 1. Check authentication and get organization
    const { organization, user } = await requireOrganization(ctx)

    // 2. Check specific permission (optional)
    await requirePermission(ctx, "resource:write")

    // 3. Create with organization scope
    return await ctx.db.insert("yourTable", {
      ...args,
      organizationId: organization._id,  // CRITICAL: Multi-tenant isolation
      createdBy: user._id,
      createdAt: Date.now(),
    })
  }
})
```

### Pattern 2: Query Gating (Client-Side)

**Location**: apps/app/CLAUDE.md#query-gating

```typescript
// apps/app/src/app/[locale]/(dashboard)/yourPage/page.tsx
"use client"

import { useConvexAuth, useQuery } from "convex/react"
import { api } from "@v1/backend/convex/_generated/api"

function YourPage() {
  // 1. Get auth state
  const { isAuthenticated } = useConvexAuth()

  // 2. Gate query on auth state (CRITICAL)
  const data = useQuery(
    api.yourModule.list,
    isAuthenticated ? {} : "skip"
  )

  // 3. Handle loading state
  if (!isAuthenticated) return <div>Please sign in</div>
  if (!data) return <div>Loading...</div>

  // 4. Render data
  return <YourComponent data={data} />
}
```

### Pattern 3: Protected Page with HOC

**Location**: apps/app/CLAUDE.md#auth-guards

```typescript
// apps/app/src/app/[locale]/(dashboard)/yourPage/page.tsx
import { withAuthGuard } from "@/lib/auth/withAuthGuard"

function YourPage() {
  // Component is only rendered when authenticated
  return <div>Protected Content</div>
}

export default withAuthGuard(YourPage)
```

### Pattern 4: Organization-Scoped Query

**Location**: packages/backend/CLAUDE.md#multi-tenant-data-isolation

```typescript
export const list = query({
  handler: async (ctx) => {
    const { organization } = await requireOrganization(ctx)

    return await ctx.db
      .query("yourTable")
      .filter(q => q.eq(q.field("organizationId"), organization._id))
      .order("desc")
      .collect()
  }
})
```

### Pattern 5: React Hooks Order (CRITICAL)

**Location**: apps/app/CLAUDE.md#react-hooks-rules

```typescript
function YourComponent() {
  // === PHASE 1: ALL HOOKS FIRST ===
  const { isAuthenticated } = useConvexAuth()
  const router = useRouter()
  const [state, setState] = useState(initial)
  const data = useQuery(api.module.func, isAuthenticated ? {} : "skip")

  // Safe extraction
  const items = data?.items ?? []

  // useMemo BEFORE early returns
  const computed = useMemo(() => {
    if (!items.length) return []
    return items.filter(...)
  }, [items])

  // === PHASE 2: EARLY RETURNS (after hooks) ===
  if (!isAuthenticated) return <NotAuth />
  if (!data) return <Loading />

  // === PHASE 3: MAIN RENDER ===
  return <Content items={computed} />
}
```

---

## Pattern Extraction Workflow

After successfully implementing a feature, extract reusable patterns:

### When to Extract

Extract a pattern when:
- Implementation solves a common problem
- Code can be reused with minimal modification
- Pattern enforces important security/quality constraints
- Multiple team members might need similar functionality

### Extraction Process

1. **Identify the pattern** in your implementation
2. **Generalize the code** (remove specific variable names, add placeholders)
3. **Document the pattern** using the template below
4. **Add to appropriate CLAUDE.md** file
5. **Create PR** with pattern documentation

### Pattern Documentation Template

```markdown
### Pattern: [Pattern Name]

**Purpose**: [What problem this pattern solves]

**When to Use**:
- [Scenario 1]
- [Scenario 2]

**Code Template**:
\`\`\`typescript
// [File path guidance]
[Code template with placeholders]
\`\`\`

**Customization**:
- [placeholder]: [What to replace with]
- [Other customization instructions]

**Validation**:
\`\`\`bash
# Commands to verify correct implementation
[Test commands]
\`\`\`

**Anti-Patterns**:
- [Common mistake 1]
- [Common mistake 2]

**Related Patterns**:
- [Link to related pattern 1]
- [Link to related pattern 2]
```

---

## Anti-Patterns to Avoid

### Backend Anti-Patterns

**No Organization Scoping**:
```typescript
// WRONG - Returns ALL data across ALL organizations
export const list = query({
  handler: async (ctx) => {
    return await ctx.db.query("companies").collect()
  }
})
```

**Missing Auth Check**:
```typescript
// WRONG - No authentication validation
export const create = mutation({
  handler: async (ctx, args) => {
    return await ctx.db.insert("companies", args)
  }
})
```

### Frontend Anti-Patterns

**Query Without Auth Gate**:
```typescript
// WRONG - Query runs before auth is established
const user = useQuery(api.users.getCurrentUser)
```

**Hooks After Early Returns**:
```typescript
// WRONG - Hooks must come before ANY early returns
if (!isAuthenticated) return <Login />
const data = useMemo(() => ..., [])  // Will crash!
```

### Testing Anti-Patterns

**No Multi-Tenant Test Coverage**:
```typescript
// WRONG - Only tests happy path, not isolation
test("list companies", async () => {
  const companies = await t.query(api.companies.list)
  expect(companies.length).toBeGreaterThan(0)
  // Missing: Verify only current org's data returned
})
```

---

## Validation Commands

After implementing, verify with:

```bash
# Type checking
bun typecheck

# Linting
bun lint

# Unit tests
bun test

# E2E tests (for auth/critical flows)
bun run test:e2e:docker:comprehensive

# Convex schema validation
cd packages/backend && bunx convex dev --once

# Full pre-PR check
bun typecheck && bun lint && bun test && turbo build
```

---

## Integration with Existing CLAUDE.md Files

This skill complements (does not replace) the existing documentation:

| CLAUDE.md File | What It Contains | This Skill Adds |
|----------------|------------------|-----------------|
| CLAUDE.md (root) | Navigation map, universal rules | Pattern discovery protocol |
| packages/backend/CLAUDE.md | Convex patterns, RBAC, schema | When/how to find patterns |
| apps/app/CLAUDE.md | Auth integration, React patterns | Pre-implementation checks |
| tests/CLAUDE.md | Testing patterns | Pattern validation steps |
| packages/ui/CLAUDE.md | Component patterns | Pattern extraction workflow |

### Cross-References

When working on:
- **Authentication**: Start at apps/app/CLAUDE.md, then packages/backend/CLAUDE.md
- **New Feature**: Start at root CLAUDE.md navigation map
- **Testing**: Start at tests/CLAUDE.md, reference specific app/package guides
- **Bug Fix**: Find relevant CLAUDE.md via Quick Find Commands

---

## Gap Reporting

If you cannot find a pattern for your task:

1. **Document the gap** in your implementation notes
2. **Search codebase** for similar implementations to use as reference
3. **Implement with care** following existing conventions
4. **Extract pattern** after successful implementation
5. **Report gap** by creating an issue for pattern documentation

### Gap Report Template

```markdown
## Pattern Gap Report

**Task**: [What you were trying to implement]
**Searched In**: [Which CLAUDE.md files you checked]
**Similar Code Found**: [Any similar implementations in codebase]
**Implemented Solution**: [Brief description of your approach]
**Suggested Pattern Location**: [Which CLAUDE.md should contain this]
```

---

## Quick Checklist

Before implementing:
- [ ] Identified pattern category
- [ ] Checked relevant CLAUDE.md file(s)
- [ ] Searched codebase for similar implementations
- [ ] Found applicable pattern OR documented gap

After implementing:
- [ ] Implementation follows existing patterns
- [ ] All validation commands pass
- [ ] Extracted new pattern if applicable
- [ ] Updated CLAUDE.md if new pattern extracted

---

## Related Skills

- **testing-patterns**: For testing implementations
- **security-audit**: For security-critical patterns
- **api-patterns**: For API route patterns
- **safe-workflow**: For git and deployment patterns
