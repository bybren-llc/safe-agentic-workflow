---
name: testing-patterns
description: Testing patterns for Jest and Playwright. Use when writing tests, setting up test fixtures, or validating RLS enforcement. Routes to existing test conventions and provides evidence templates.
---

# Testing Patterns Skill

## Purpose

Guide consistent and effective testing. Routes to existing test patterns and provides evidence templates for Linear.

## When This Skill Applies

Invoke this skill when:

- Writing new unit tests
- Creating integration tests
- Setting up test fixtures with RLS
- Running test suites
- Packaging test evidence for Linear

## Critical Rules

### ❌ FORBIDDEN Patterns

```typescript
// FORBIDDEN: Direct Prisma calls in tests (bypass RLS)
const user = await prisma.user.findUnique({ where: { user_id } });

// FORBIDDEN: Shared test state (causes flaky tests)
let sharedUser: User;
beforeAll(() => { sharedUser = createUser(); });

// FORBIDDEN: Hard-coded IDs (test pollution)
const userId = "user-123";

// FORBIDDEN: Missing cleanup (leaky tests)
it("creates user", async () => {
  await prisma.user.create({ data: userData });
  // No cleanup!
});
```

### ✅ CORRECT Patterns

```typescript
// CORRECT: Use RLS context helpers
const user = await withSystemContext(prisma, "test", async (client) => {
  return client.user.findUnique({ where: { user_id } });
});

// CORRECT: Isolated test state per test
beforeEach(() => {
  const testUser = createTestUser();
});

// CORRECT: Unique identifiers
const userId = `user-${crypto.randomUUID()}`;
const email = `test-${Date.now()}@example.com`;

// CORRECT: Proper cleanup
afterEach(async () => {
  await withSystemContext(prisma, "test", async (client) => {
    await client.user.deleteMany({ where: { email: { contains: "test-" } } });
  });
});
```

## Test Directory Structure

```
__tests__/
├── unit/              # Fast, isolated tests
│   ├── components/    # React component tests
│   ├── lib/           # Library function tests
│   ├── services/      # Service layer tests
│   └── user/          # User helper tests
├── integration/       # API and database tests
├── database/          # Database helper tests
├── e2e/               # End-to-end tests (Playwright)
├── payments/          # Payment flow tests
└── setup.ts           # Global test setup
```

## Configuration Files

- **Jest Config**: `jest.config.js`
- **Test Setup**: `__tests__/setup.ts`
- **Playwright Config**: `playwright.config.ts`

## RLS-Aware Testing

### Setting Up Test Context

Always use RLS context helpers in tests:

```typescript
import { withUserContext, withSystemContext } from "@/lib/rls-context";
import { prisma } from "@/lib/prisma";

describe("User payments", () => {
  const testUserId = "test-user-123";

  beforeEach(async () => {
    // Create test user with RLS context
    await withSystemContext(prisma, "test", async (client) => {
      await client.user.create({
        data: {
          user_id: testUserId,
          email: `test-${Date.now()}@example.com`,
          first_name: "Test",
          last_name: "User",
        },
      });
    });
  });

  it("should only see own payments", async () => {
    const payments = await withUserContext(
      prisma,
      testUserId,
      async (client) => {
        return client.payments.findMany();
      },
    );
    // RLS ensures only this user's payments returned
    expect(payments.every((p) => p.user_id === testUserId)).toBe(true);
  });
});
```

### Test Isolation

Use unique identifiers to prevent test pollution:

```typescript
const uniqueEmail = `test-${Date.now()}@example.com`;
const uniqueUserId = `user-${crypto.randomUUID()}`;
```

## Test Commands

```bash
# Run all unit tests
yarn test:unit

# Run integration tests
yarn test:integration

# Run specific test file
yarn jest __tests__/unit/components/my-component.test.tsx

# Run tests matching pattern
yarn jest --testNamePattern="should handle"

# Run with coverage
yarn test:unit --coverage

# Run E2E tests
yarn test:e2e
```

## Common Patterns

### Component Testing

```typescript
import { render, screen, fireEvent } from "@testing-library/react";
import { MyComponent } from "@/components/my-component";

describe("MyComponent", () => {
  it("renders correctly", () => {
    render(<MyComponent />);
    expect(screen.getByRole("button")).toBeInTheDocument();
  });

  it("handles click events", async () => {
    const onClickMock = jest.fn();
    render(<MyComponent onClick={onClickMock} />);

    fireEvent.click(screen.getByRole("button"));
    expect(onClickMock).toHaveBeenCalledTimes(1);
  });
});
```

### API Route Testing

```typescript
import { GET } from "@/app/api/my-route/route";
import { NextRequest } from "next/server";

describe("GET /api/my-route", () => {
  it("returns 200 with data", async () => {
    const request = new NextRequest("http://localhost:3000/api/my-route");
    const response = await GET(request);

    expect(response.status).toBe(200);
    const data = await response.json();
    expect(data).toHaveProperty("success", true);
  });
});
```

### Mocking Prisma

```typescript
jest.mock("@/lib/prisma", () => ({
  prisma: {
    user: {
      findUnique: jest.fn(),
      create: jest.fn(),
    },
  },
}));
```

## Evidence Template for Linear

When completing test work, attach this evidence block:

```markdown
**Test Execution Evidence**

**Test Suite**: [unit/integration/e2e]
**Files Changed**: [list files]

**Test Results:**

- Total Tests: [X]
- Passed: [X]
- Failed: [0]
- Skipped: [X]

**Coverage** (if applicable):

- Statements: X%
- Branches: X%
- Functions: X%
- Lines: X%

**Commands Run:**

\`\`\`bash
yarn test:unit --coverage
\`\`\`

**Output:**
[Paste relevant test output]
```

## Pre-Push Validation

Always run before pushing:

```bash
yarn ci:validate
```

This runs:

- Type checking
- ESLint
- Unit tests
- Format check

## Authoritative References

- **Jest Config**: `jest.config.js`
- **Test Setup**: `__tests__/setup.ts`
- **RLS Context**: `lib/rls-context.ts`
- **CI Validation**: `package.json` scripts
