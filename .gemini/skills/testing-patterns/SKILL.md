---
name: testing-patterns
description: Testing patterns for Jest and Playwright. Use when writing tests, setting up test fixtures, or validating RLS enforcement. Routes to existing test conventions.
---

# Testing Patterns Skill

## Purpose

Guide consistent and effective testing. Routes to existing test patterns and provides evidence templates.

## When This Skill Applies

- Writing unit or integration tests
- Setting up test fixtures with RLS
- Running test suites
- Packaging test evidence

## Critical Rules

### ❌ FORBIDDEN

```typescript
// Direct Prisma calls bypass RLS
const user = await prisma.user.findUnique({ where: { user_id } });

// Shared test state causes flaky tests
let sharedUser: User;
beforeAll(() => { sharedUser = createUser(); });
```

### ✅ CORRECT

```typescript
// Use RLS context helpers
const user = await withSystemContext(prisma, "test", async (client) => {
  return client.user.findUnique({ where: { user_id } });
});

// Isolated test state
beforeEach(() => {
  const testUser = createTestUser();
});

// Unique identifiers
const userId = `user-${crypto.randomUUID()}`;
```

## Test Commands

```bash
yarn test:unit              # Unit tests
yarn test:integration       # Integration tests
yarn test:e2e               # E2E tests (Playwright)
yarn ci:validate            # Full validation
```

## Test Directory Structure

```
__tests__/
├── unit/              # Fast, isolated tests
├── integration/       # API and database tests
├── e2e/               # End-to-end tests
└── setup.ts           # Global setup
```

## Evidence Template

```markdown
**Test Execution Evidence**

**Test Suite**: [unit/integration/e2e]
**Files Changed**: [list files]

**Test Results:**
- Total Tests: [X]
- Passed: [X]
- Failed: [0]

**Commands Run:**
```bash
yarn test:unit --coverage
```
```

## Reference

- **Jest Config**: `jest.config.js`
- **RLS Context**: `lib/rls-context.ts`
