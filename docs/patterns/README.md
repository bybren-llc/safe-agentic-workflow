# Pattern Library

> **📋 TEMPLATE**: This is a placeholder structure for your project's pattern library.

## Purpose

The pattern library contains reusable code patterns that have been proven to work in production. Before implementing any feature, check this library first.

**Philosophy**: "Search First, Reuse Always, Create Only When Necessary"

---

## Recommended Structure

```text
docs/patterns/
├── README.md                 # This file
├── api/                      # Backend API patterns
│   ├── route-handler.md      # Standard route structure
│   ├── error-handling.md     # Error response patterns
│   └── validation.md         # Request validation patterns
├── ui/                       # Frontend UI patterns
│   ├── form-handling.md      # Form state and validation
│   ├── data-fetching.md      # Data fetching patterns
│   └── component-structure.md # Component organization
├── database/                 # Database patterns
│   ├── rls-policies.md       # Row-Level Security patterns
│   ├── migrations.md         # Migration best practices
│   └── queries.md            # Query optimization
├── testing/                  # Test patterns
│   ├── unit-tests.md         # Unit test conventions
│   ├── integration-tests.md  # Integration test patterns
│   └── e2e-tests.md          # End-to-end test patterns
└── ci/                       # CI/CD patterns
    ├── workflows.md          # GitHub Actions patterns
    └── deployment.md         # Deployment patterns
```

---

## Adding Patterns

When adding a new pattern:

1. **Document the problem** it solves
2. **Show the solution** with code examples
3. **Explain when to use** (and when NOT to use)
4. **Include real examples** from the codebase
5. **Reference related patterns**

### Pattern Template

```markdown
# Pattern Name

## Problem

What problem does this pattern solve?

## Solution

How does this pattern solve it?

## Example

\`\`\`typescript
// Code example here
\`\`\`

## When to Use

- Scenario 1
- Scenario 2

## When NOT to Use

- Anti-pattern scenario

## Related Patterns

- [Other Pattern](./other-pattern.md)
```

---

## Integration with Skills

The `pattern-discovery` skill automatically searches this directory when agents are about to implement features. Keep patterns up-to-date to maximize reuse.

---

**Last Updated**: {{DATE}}
**Maintained by**: {{PROJECT_NAME}} Development Team
