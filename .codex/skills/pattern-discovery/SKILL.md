# Pattern Discovery Skill

## Purpose

Enforce pattern-first development by checking the pattern library before implementing new functionality.

## When to Use

- About to create a new API route
- About to create a new UI component
- About to add database operations
- User asks "how do I implement..." or "how should I build..."

## Pattern Discovery Protocol

**ALWAYS check patterns before writing new code:**

### Step 1: Check Pattern Library

```bash
ls patterns_library/api/      # API route patterns
ls patterns_library/ui/       # UI component patterns
ls patterns_library/database/ # Database patterns
ls patterns_library/testing/  # Testing patterns
```

### Step 2: Review Pattern Index

See `patterns_library/README.md` for the complete index.

### Step 3: Apply or Escalate

**If pattern exists:** Copy, customize, validate.

**If missing:** Search codebase, implement following conventions, report gap.

## Pattern Matching Guide

| If you need to...                  | Use this pattern                  |
| ---------------------------------- | --------------------------------- |
| Create authenticated API endpoint  | `api/user-context-api.md`         |
| Create admin-only API endpoint     | `api/admin-context-api.md`        |
| Handle external webhooks           | `api/webhook-handler.md`          |
| Validate API input with Zod        | `api/zod-validation-api.md`       |
| Create protected page              | `ui/authenticated-page.md`        |
| Build form with validation         | `ui/form-with-validation.md`      |
| Add new table with RLS             | `database/rls-migration.md`       |
| Test API endpoints                 | `testing/api-integration-test.md` |

## Reference

- **Pattern Index**: `patterns_library/README.md`
- **RLS Patterns**: See `safe-workflow` skill
- **Testing Patterns**: See `testing-patterns` skill
