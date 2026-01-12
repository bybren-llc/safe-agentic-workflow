---
name: testing-patterns
description: Testing patterns using Vitest for unit tests, Docker Playwright for E2E, Chrome DevTools MCP for debugging, and convex-test for backend testing.
---

# Testing Patterns

## Purpose
Ensure comprehensive testing using the ConTStack testing stack: Vitest, Docker Playwright, Chrome DevTools MCP, and convex-test.

## Testing Stack

| Layer | Tool | Purpose |
|-------|------|---------|
| Unit Tests | Vitest | Component and utility testing |
| Backend Tests | convex-test | Convex function testing |
| E2E Tests | Docker Playwright | Full user flow testing |
| Debug/Inspect | Chrome DevTools MCP | Browser debugging and inspection |

## When to Use Each

### Vitest (Unit Tests)
- Testing React components in isolation
- Testing utility functions
- Testing hooks
- Testing data transformations

### convex-test (Backend Tests)
- Testing Convex queries and mutations
- Testing authorization logic
- Testing business logic

### Docker Playwright (E2E)
- Full user authentication flows
- Complete feature workflows
- Cross-browser testing
- Visual regression testing

### Chrome DevTools MCP (Debugging)
- **PREFERRED** for investigating runtime issues
- Inspecting network requests
- Debugging authentication flows
- Examining DOM state
- Console error investigation

## Chrome DevTools MCP Usage

The Chrome DevTools MCP is a powerful debugging tool available to agents:

### When to Use
- E2E test failures that need investigation
- Authentication flow debugging
- Network request inspection
- Console error analysis
- DOM state verification

### Capabilities
- Navigate to pages
- Execute JavaScript in browser context
- Capture screenshots
- Inspect network requests
- Read console logs
- Examine cookies and localStorage

### Example Investigation Flow
1. Launch browser via MCP
2. Navigate to failing page
3. Check console for errors
4. Inspect network requests
5. Verify DOM state
6. Capture screenshots for evidence

## Unit Testing (Vitest)

### Component Test Pattern

```typescript
import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MyComponent } from "./MyComponent";

describe("MyComponent", () => {
  it("renders correctly", () => {
    render(<MyComponent title="Test" />);
    expect(screen.getByText("Test")).toBeInTheDocument();
  });
  
  it("handles click events", async () => {
    const onClick = vi.fn();
    render(<MyComponent onClick={onClick} />);
    
    await userEvent.click(screen.getByRole("button"));
    expect(onClick).toHaveBeenCalledTimes(1);
  });
});
```

### Hook Test Pattern

```typescript
import { renderHook, act } from "@testing-library/react";
import { useCounter } from "./useCounter";

describe("useCounter", () => {
  it("increments count", () => {
    const { result } = renderHook(() => useCounter());
    
    act(() => {
      result.current.increment();
    });
    
    expect(result.current.count).toBe(1);
  });
});
```

## Backend Testing (convex-test)

### Query Test Pattern

```typescript
import { convexTest } from "convex-test";
import { expect, test } from "vitest";
import { api } from "./_generated/api";
import schema from "./schema";

test("getRecords returns organization-scoped data", async () => {
  const t = convexTest(schema);
  
  // Setup auth context
  const userId = await t.run(async (ctx) => {
    return await ctx.db.insert("users", { 
      email: "test@example.com",
      organizationId: "org_123"
    });
  });
  
  // Create test data
  await t.run(async (ctx) => {
    await ctx.db.insert("records", {
      organizationId: "org_123",
      title: "Test Record"
    });
    await ctx.db.insert("records", {
      organizationId: "org_other", // Different org
      title: "Other Record"
    });
  });
  
  // Test query returns only org_123 records
  const records = await t.query(api.records.getRecords, {});
  expect(records).toHaveLength(1);
  expect(records[0].title).toBe("Test Record");
});
```

### Mutation Test Pattern

```typescript
test("createRecord adds organizationId", async () => {
  const t = convexTest(schema);
  
  const recordId = await t.mutation(api.records.create, {
    title: "New Record",
    content: "Test content"
  });
  
  const record = await t.run(async (ctx) => {
    return await ctx.db.get(recordId);
  });
  
  expect(record.organizationId).toBe("org_123");
  expect(record.createdAt).toBeDefined();
});
```

## E2E Testing (Docker Playwright)

### Setup

```bash
# Run E2E tests in Docker
bun run test:e2e:docker:comprehensive

# Validate Docker setup
bun run test:e2e:docker:validate
```

### Test Pattern

```typescript
import { test, expect } from "@playwright/test";

test.describe("Authentication Flow", () => {
  test("user can sign in and access dashboard", async ({ page }) => {
    await page.goto("/");
    
    // Click sign in
    await page.click('text="Sign In"');
    
    // Complete auth flow
    await page.fill('[name="email"]', "test@example.com");
    await page.click('button[type="submit"]');
    
    // Verify redirect to dashboard
    await expect(page).toHaveURL(/.*dashboard/);
    await expect(page.locator("h1")).toContainText("Dashboard");
  });
});
```

### Docker Configuration

```yaml
# docker-compose.e2e.yml
services:
  app:
    ports:
      - "3005:3005"
    environment:
      - E2E_BASE_URL=http://localhost:3005
      - WORKOS_REDIRECT_URI=http://localhost:3005/callback
```

## Test Commands

```bash
# Unit tests
bun run test

# Watch mode
bun run test:watch

# Coverage
bun run test:coverage

# E2E tests (Docker)
bun run test:e2e:docker:comprehensive

# E2E validation
bun run test:e2e:docker:validate
```

## Test File Locations

| Type | Location | Naming |
|------|----------|--------|
| Unit tests | `*.test.ts` adjacent to source | `Component.test.tsx` |
| Backend tests | `packages/backend/convex/**/*.test.ts` | `feature.test.ts` |
| E2E tests | `tests/e2e/*.spec.ts` | `feature.spec.ts` |

## Mocking Patterns

### Mock External APIs

```typescript
import { vi } from "vitest";

vi.mock("../lib/external-api", () => ({
  fetchData: vi.fn().mockResolvedValue({ data: "mocked" }),
}));
```

### Mock Convex Hooks

```typescript
vi.mock("convex/react", () => ({
  useConvexAuth: () => ({ isAuthenticated: true, isLoading: false }),
  useQuery: vi.fn(),
  useMutation: vi.fn(),
}));
```

## Evidence Checklist

Before completing any feature:

- [ ] Unit tests for new components
- [ ] Backend tests for new Convex functions
- [ ] E2E test for critical user flows
- [ ] All tests passing
- [ ] Coverage not decreased
- [ ] Chrome DevTools used to verify any complex interactions
