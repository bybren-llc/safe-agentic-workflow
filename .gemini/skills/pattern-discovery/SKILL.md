---
name: pattern-discovery
description: Pattern library discovery for pattern-first development. Use BEFORE implementing any new feature, creating components, writing API routes, or adding database operations. Ensures existing patterns are checked first.
---

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
ls docs/patterns/api/      # API route patterns
ls docs/patterns/ui/       # UI component patterns
ls docs/patterns/database/ # Database patterns
ls docs/patterns/testing/  # Testing patterns
```

### Step 2: Review Pattern Index

See `docs/patterns/README.md` for the complete index.

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

- **Pattern Index**: `docs/patterns/README.md`
- **RLS Patterns**: See `rls-patterns` skill
- **Frontend Patterns**: See `frontend-patterns` skill
