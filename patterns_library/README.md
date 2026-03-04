# {{PROJECT_SHORT}} Pattern Library

> **Copy-Paste Ready Code Patterns for Agent-Driven Development**

## Overview

This pattern library provides battle-tested, production-ready code patterns extracted from the {{PROJECT_SHORT}} codebase. Each pattern is:

- ✅ **Copy-Paste Ready** - Minimal customization needed
- ✅ **Security Validated** - RLS enforced, auth required, input validated
- ✅ **SOLID Compliant** - Follows architectural principles
- ✅ **Test Covered** - Includes testing patterns

## Pattern Index

### API Routes

| Pattern                                           | File                                     | Use Case                          |
| ------------------------------------------------- | ---------------------------------------- | --------------------------------- |
| [User Context API](./api/user-context-api.md)     | Basic authenticated API with RLS         | User-specific CRUD operations     |
| [Admin Context API](./api/admin-context-api.md)   | Admin-only API with elevated permissions | Admin dashboards, management      |
| [Webhook Handler](./api/webhook-handler.md)       | External webhook processing              | Stripe, Clerk, third-party events |
| [Zod Validation API](./api/zod-validation-api.md) | Input validation with Zod schemas        | Form submissions, API inputs      |

### UI Components

| Pattern                                              | File                           | Use Case                 |
| ---------------------------------------------------- | ------------------------------ | ------------------------ |
| [Authenticated Page](./ui/authenticated-page.md)     | Protected page with auth check | User dashboard, profile  |
| [Form with Validation](./ui/form-with-validation.md) | React Hook Form + Zod          | Data entry, settings     |
| [Data Table](./ui/data-table.md)                     | Server-side paginated table    | List views, admin panels |

### Database Operations

| Pattern                                                | File                           | Use Case             |
| ------------------------------------------------------ | ------------------------------ | -------------------- |
| [RLS Migration](./database/rls-migration.md)           | Add table with RLS policies    | New user data tables |
| [Prisma Transaction](./database/prisma-transaction.md) | Multi-step database operations | Complex workflows    |

### Testing

| Pattern                                                   | File                       | Use Case             |
| --------------------------------------------------------- | -------------------------- | -------------------- |
| [API Integration Test](./testing/api-integration-test.md) | Test API routes with RLS   | Endpoint validation  |
| [E2E User Flow](./testing/e2e-user-flow.md)               | Playwright end-to-end test | User journey testing |

### Security

| Pattern                                                       | File                              | Use Case                 |
| ------------------------------------------------------------- | --------------------------------- | ------------------------ |
| [Input Sanitization](./security/input-sanitization.md)        | XSS/injection prevention          | User input handling      |
| [Rate Limiting](./security/rate-limiting.md)                  | API rate limiting                  | Abuse prevention         |
| [Secrets Management](./security/secrets-management.md)        | Environment variable management   | Config security          |

### CI/CD

| Pattern                                                       | File                             | Use Case                 |
| ------------------------------------------------------------- | -------------------------------- | ------------------------ |
| [GitHub Actions Workflow](./ci/github-actions-workflow.md)     | Standard CI pipeline             | Automated quality gates  |
| [Deployment Pipeline](./ci/deployment-pipeline.md)             | Staging → production deployment  | Release management       |

### Configuration

| Pattern                                                       | File                             | Use Case                 |
| ------------------------------------------------------------- | -------------------------------- | ------------------------ |
| [Environment Config](./config/environment-config.md)           | Typed environment loading        | App configuration        |
| [Structured Logging](./config/structured-logging.md)           | JSON logging with correlation    | Observability            |

## How to Use Patterns

### 1. Find the Right Pattern

Use the index above to find a pattern matching your use case.

### 2. Copy the Pattern

Each pattern file contains:

- **What It Does** - Purpose and use case
- **Code Pattern** - Copy-paste ready code
- **Customization Guide** - What to change
- **Security Checklist** - Validation points

### 3. Customize for Your Use Case

Follow the customization guide in each pattern:

- Replace placeholders (marked with `{...}`)
- Update type definitions
- Adjust business logic
- Run validation commands

### 4. Validate

Each pattern includes validation commands:

```bash
yarn lint && yarn type-check  # For all patterns
yarn test:integration          # For API patterns
yarn test:e2e                  # For UI patterns
```

## Pattern Discovery Protocol

**Before creating new patterns**, check:

1. **This library first** - Use existing patterns when possible
2. **Codebase search** - Look for similar implementations
3. **BSA/ARCHitect** - Propose new patterns for validation

## Pattern Creation Guidelines

When creating new patterns (BSA/ARCHitect only):

### Required Elements

- [ ] Clear use case description
- [ ] Complete, working code example
- [ ] Customization instructions with placeholders
- [ ] Security validation checklist
- [ ] Success validation commands

### Quality Standards

- [ ] RLS enforced (if database operations)
- [ ] Authentication required (if protected)
- [ ] Input validation with Zod
- [ ] Error handling comprehensive
- [ ] TypeScript strict mode compliant

### Documentation Format

```markdown
# Pattern Name

## What It Does

[Clear description of purpose and use case]

## When to Use

- Use case 1
- Use case 2

## Code Pattern

[Complete, copy-paste ready code]

## Customization Guide

1. Replace `{placeholder}` with your value
2. Update type definitions
3. Adjust business logic

## Security Checklist

- [ ] RLS context enforced
- [ ] Auth required
- [ ] Input validated

## Validation

[Commands to verify implementation]
```

## Contributing Patterns

**BSA/System Architect Only**:

1. Discover gap in pattern library
2. Extract pattern from proven implementation
3. Validate with System Architect
4. Document per template above
5. Add to this index

**Execution Agents**:

- Use existing patterns
- Report missing patterns to BSA
- Do NOT create new patterns

## Maintenance

- **Owner**: System Architect
- **Contributors**: BSA (pattern discovery and extraction)
- **Consumers**: All execution agents (FE, BE, QAS, etc.)
- **Update Frequency**: As new patterns emerge from production code

## Pattern Library Evolution

As patterns prove useful:

1. BSA identifies frequently implemented features
2. System Architect validates pattern
3. BSA extracts and documents pattern
4. Pattern added to library
5. Execution agents use pattern for future implementations

---

**Last Updated**: 2026-03
**Pattern Count**: 18
**Maintained by**: {{PROJECT_NAME}} Development Team + System Architect
