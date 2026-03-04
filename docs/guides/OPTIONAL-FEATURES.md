# Optional Features Removal Guide

This repository ships with several optional integrations that not every project
needs. Use the checklists below to cleanly remove integrations that do not apply
to your project.

> **When to use this guide**: After running `scripts/setup-template.sh` (or
> completing manual placeholder replacement), review each section. If an
> integration does not apply, follow its removal checklist before your first
> real commit.

---

## Table of Contents

- [1. Stripe / Payment Patterns](#1-stripe--payment-patterns)
- [2. Confluence Integration](#2-confluence-integration)
- [3. RLS / PostgreSQL Patterns](#3-rls--postgresql-patterns)
- [4. Clerk / Auth Patterns](#4-clerk--auth-patterns)
- [Verification After Removal](#verification-after-removal)

---

## 1. Stripe / Payment Patterns

### When to Remove

Remove these files if your project does **not** process payments, handle
subscriptions, or integrate with Stripe (or any payment provider).

### Removal Checklist

#### 1.1 Remove Stripe skill directories

- [ ] Delete `.claude/skills/stripe-patterns/` (contains `README.md` and `SKILL.md`)
- [ ] Delete `.gemini/skills/stripe-patterns/` (contains `README.md` and `SKILL.md`)

#### 1.2 Remove payment-related pattern library files

- [ ] Delete `patterns_library/api/webhook-handler.md` -- or keep it if you use
      non-payment webhooks (Clerk, GitHub, etc.) and strip the Stripe-specific
      example at the bottom of the file
- [ ] Review `patterns_library/testing/api-integration-test.md` and remove any
      Stripe-specific test examples
- [ ] Review `patterns_library/testing/e2e-user-flow.md` and remove payment
      flow examples

#### 1.3 Remove payment references from agent prompts

- [ ] Edit `agent_providers/claude_code/prompts/bsa.md` -- remove payment
      acceptance-criteria examples
- [ ] Edit `agent_providers/claude_code/prompts/be-developer.md` -- remove
      Stripe webhook implementation references
- [ ] Edit `agent_providers/claude_code/prompts/qas.md` -- remove payment
      testing references

#### 1.4 Remove payment references from agent definitions (`.claude/agents/`)

- [ ] Edit `.claude/agents/bsa.md` -- remove payment-related examples
- [ ] Edit `.claude/agents/be-developer.md` -- remove Stripe references
- [ ] Edit `.claude/agents/qas.md` -- remove payment testing references

#### 1.5 Clean up template placeholders

- [ ] In `CLAUDE.md`, remove the entire **Payments** subsection under
      "Project-Specific Implementation Notes"
- [ ] In `.env.template`, remove or comment out any `STRIPE_*` variables you
      may have added
- [ ] Remove `{{PAYMENT_PROVIDER}}` and `{{WEBHOOK_ROUTES}}` placeholders from
      `CLAUDE.md` (or replace the Payments section with a note that payments are
      not used)

#### 1.6 Clean up CODEOWNERS

- [ ] In `project_workflow/.github/CODEOWNERS`, remove the payment-features
      ownership line referencing `@{{PAYMENT_TEAM}}`

#### 1.7 Update skill README indexes

- [ ] Edit `.claude/skills/README.md` -- remove the `stripe-patterns` entry
- [ ] Edit `.gemini/skills/README.md` -- remove the `stripe-patterns` entry

### What to Replace It With

Nothing. If your project later adds payment processing, re-copy the
`stripe-patterns` skill from the template repository.

### Verification

```bash
# Confirm no Stripe skill directories remain
ls .claude/skills/stripe-patterns 2>/dev/null && echo "REMOVE ME" || echo "OK"
ls .gemini/skills/stripe-patterns 2>/dev/null && echo "REMOVE ME" || echo "OK"

# Search for lingering Stripe / payment references
grep -ri "stripe\|PAYMENT_PROVIDER\|payment_team" \
  CLAUDE.md .env.template project_workflow/.github/CODEOWNERS \
  .claude/skills/README.md .gemini/skills/README.md
# Expect: no output
```

---

## 2. Confluence Integration

### When to Remove

Remove these files if your team does **not** use Atlassian Confluence for
documentation. Common alternatives include Notion, GitHub Wiki, GitBook, or
in-repo markdown.

### Removal Checklist

#### 2.1 Remove Confluence skill directories

- [ ] Delete `.claude/skills/confluence-docs/` (contains `README.md` and `SKILL.md`)
- [ ] Delete `.gemini/skills/confluence-docs/` (contains `README.md` and `SKILL.md`)

> **Note**: The templates inside `SKILL.md` (ADR template, runbook template,
> architecture doc template, KT template) are useful regardless of platform.
> Before deleting, consider copying the templates into a general-purpose file
> such as `docs/templates/DOCUMENTATION-TEMPLATES.md`.

#### 2.2 Remove Confluence references from agent prompts

- [ ] Edit `agent_providers/claude_code/prompts/tech-writer.md` -- remove
      references to Confluence and `{{MCP_CONFLUENCE_SERVER}}`
- [ ] Edit `agent_providers/claude_code/prompts/bsa.md` -- remove Confluence
      MCP tool references
- [ ] Edit `agent_providers/claude_code/prompts/tdm.md` -- remove Confluence
      references

#### 2.3 Remove Confluence references from agent definitions

- [ ] Edit `.claude/agents/tech-writer.md` -- remove Confluence references
- [ ] Edit `.claude/agents/bsa.md` -- remove Confluence MCP references
- [ ] Edit `.claude/agents/tdm.md` -- remove Confluence references

#### 2.4 Remove Confluence references from Augment rules

- [ ] Delete `agent_providers/augment/rules/confluence-standards.md`
- [ ] Edit `agent_providers/augment/rules/project-guidelines.md` -- remove
      Confluence references
- [ ] Edit `agent_providers/augment/rules/review-checklist.md` -- remove
      Confluence review items

#### 2.5 Clean up template placeholders and environment

- [ ] In `TEMPLATE_SETUP.md`, the `{{MCP_CONFLUENCE_SERVER}}` placeholder row
      can be removed (already done if you used the setup wizard)
- [ ] In `.env.template`, remove or comment out the `CONFLUENCE_URL` and
      `CONFLUENCE_API_TOKEN` variables
- [ ] In `agent_providers/claude_code/permissions/settings.template.json`,
      remove any MCP server entry for Confluence

#### 2.6 Remove Confluence from onboarding and SOP docs

- [ ] Edit `docs/onboarding/AGENT-SETUP-GUIDE.md` -- remove Confluence setup
      steps
- [ ] Edit `docs/onboarding/DAY-1-CHECKLIST.md` -- remove Confluence
      verification steps
- [ ] Edit `docs/sop/AGENT_CONFIGURATION_SOP.md` -- remove Confluence MCP
      configuration section

#### 2.7 Remove from workflow docs

- [ ] Edit `docs/workflow/TDM_AGENT_ASSIGNMENT_MATRIX.md` -- remove Confluence
      update tasks
- [ ] Edit `specs_templates/planning_template.md` -- remove Confluence
      references
- [ ] Edit `specs_templates/README.md` -- remove Confluence references

#### 2.8 Update skill README indexes

- [ ] Edit `.claude/skills/README.md` -- remove the `confluence-docs` entry
- [ ] Edit `.gemini/skills/README.md` -- remove the `confluence-docs` entry

### What to Replace It With

If you use a different documentation platform, update agent prompts to reference
your platform instead. For example:

| Original Reference | Replacement (Notion) | Replacement (GitHub Wiki) |
|---|---|---|
| `{{MCP_CONFLUENCE_SERVER}}` | Your Notion MCP or API integration | `github-wiki` or in-repo `docs/` |
| Confluence page links | Notion page links | Wiki page links or file paths |
| "Publish to Confluence" | "Update Notion page" | "Commit to `docs/`" |

If you keep documentation entirely in-repo (recommended for smaller teams),
no MCP server replacement is needed -- agents will simply read and write
markdown files in `docs/`.

### Verification

```bash
# Confirm no Confluence skill directories remain
ls .claude/skills/confluence-docs 2>/dev/null && echo "REMOVE ME" || echo "OK"
ls .gemini/skills/confluence-docs 2>/dev/null && echo "REMOVE ME" || echo "OK"

# Search for lingering Confluence references
grep -ri "confluence\|MCP_CONFLUENCE" \
  agent_providers/ .claude/ .gemini/ .env.template \
  docs/onboarding/ docs/sop/ TEMPLATE_SETUP.md
# Expect: no output (or only this file)
```

---

## 3. RLS / PostgreSQL Patterns

### When to Remove

Remove these files if your project uses a database **other than PostgreSQL** or
does not need Row Level Security. Common alternatives include:

- **MongoDB** -- uses document-level access control
- **MySQL** -- uses application-level authorization
- **SQLite** -- typically used with application-level checks
- **Serverless databases** (PlanetScale, Turso) -- use application-layer auth
- **Firebase / Supabase** -- have their own security rule systems

> **Warning**: RLS is deeply integrated into this template. Removing it is the
> largest change in this guide. Take extra care with verification.

### Removal Checklist

#### 3.1 Remove RLS skill directories

- [ ] Delete `.claude/skills/rls-patterns/` (contains `README.md` and `SKILL.md`)
- [ ] Delete `.gemini/skills/rls-patterns/` (contains `README.md` and `SKILL.md`)

#### 3.2 Remove RLS-specific pattern library files

- [ ] Delete `patterns_library/database/rls-migration.md`
- [ ] Edit `patterns_library/database/prisma-transaction.md` -- remove RLS
      context references (or delete if not using Prisma)
- [ ] Edit `patterns_library/api/user-context-api.md` -- replace
      `withUserContext` pattern with your authorization approach
- [ ] Edit `patterns_library/api/admin-context-api.md` -- replace
      `withAdminContext` pattern with your authorization approach
- [ ] Edit `patterns_library/api/webhook-handler.md` -- replace
      `withSystemContext` pattern with your approach

#### 3.3 Remove RLS database documentation

- [ ] Delete `docs/database/RLS_IMPLEMENTATION_GUIDE.md`
- [ ] Delete `docs/database/RLS_POLICY_CATALOG.md`
- [ ] Delete `docs/database/RLS_DATABASE_MIGRATION_SOP.md`
- [ ] Edit `docs/database/DATA_DICTIONARY.md` -- remove RLS policy columns
      and RLS-specific sections
- [ ] Edit `docs/database/README.md` -- remove RLS references

#### 3.4 Remove RLS validation hooks

- [ ] Delete `agent_providers/claude_code/hooks/pre-bash-rls-validation.sh`
- [ ] Delete `.claude/hooks/pre-bash-rls-validation.sh`
- [ ] Edit `agent_providers/claude_code/permissions/settings.template.json` --
      remove the pre-bash hook entry for RLS validation

#### 3.5 Remove RLS references from agent prompts

The following agent prompts contain significant RLS references. Edit each to
replace RLS patterns with your chosen authorization approach:

- [ ] `agent_providers/claude_code/prompts/data-engineer.md`
- [ ] `agent_providers/claude_code/prompts/be-developer.md`
- [ ] `agent_providers/claude_code/prompts/security-engineer.md`
- [ ] `agent_providers/claude_code/prompts/system-architect.md`
- [ ] `agent_providers/claude_code/prompts/bsa.md`
- [ ] `agent_providers/claude_code/prompts/qas.md`
- [ ] `agent_providers/claude_code/prompts/data-provisioning-eng.md`
- [ ] `agent_providers/claude_code/prompts/rte.md`
- [ ] `agent_providers/claude_code/prompts/tech-writer.md`

#### 3.6 Remove RLS references from agent definitions

- [ ] Edit `.claude/agents/data-engineer.md`
- [ ] Edit `.claude/agents/be-developer.md`
- [ ] Edit `.claude/agents/security-engineer.md`
- [ ] Edit `.claude/agents/system-architect.md`
- [ ] Edit `.claude/agents/bsa.md`
- [ ] Edit `.claude/agents/qas.md`
- [ ] Edit `.claude/agents/data-provisioning-eng.md`
- [ ] Edit `.claude/agents/rte.md`
- [ ] Edit `.claude/agents/tech-writer.md`

#### 3.7 Remove RLS references from skills that mention it

- [ ] Edit `.claude/skills/security-audit/SKILL.md` -- remove RLS audit checks
- [ ] Edit `.claude/skills/migration-patterns/SKILL.md` -- remove RLS migration
      steps
- [ ] Edit `.claude/skills/testing-patterns/SKILL.md` -- remove RLS test
      patterns
- [ ] Edit `.claude/skills/api-patterns/SKILL.md` -- remove `withUserContext` /
      `withAdminContext` / `withSystemContext` references
- [ ] Edit `.claude/skills/safe-workflow/SKILL.md` -- remove RLS workflow steps
- [ ] Repeat for corresponding `.gemini/skills/` files:
  - `.gemini/skills/security-audit/SKILL.md`
  - `.gemini/skills/migration-patterns/SKILL.md`
  - `.gemini/skills/testing-patterns/SKILL.md`
  - `.gemini/skills/api-patterns/SKILL.md`
  - `.gemini/skills/rls-patterns/SKILL.md`

#### 3.8 Remove RLS from Augment provider rules

- [ ] Edit `agent_providers/augment/rules/project-guidelines.md` -- remove RLS
      enforcement rules
- [ ] Edit `agent_providers/augment/rules/review-checklist.md` -- remove RLS
      review items
- [ ] Edit `agent_providers/augment/instructions.md` -- remove RLS references

#### 3.9 Remove RLS from top-level docs

- [ ] Edit `CLAUDE.md` -- remove all `withUserContext` / `withAdminContext` /
      `withSystemContext` references, the Database "Development Guidelines"
      RLS bullet points, and RLS references in the Pattern Discovery section
- [ ] Edit `CONTRIBUTING.md` -- remove RLS validation steps
- [ ] Edit `docs/security/SECURITY_FIRST_ARCHITECTURE.md` -- remove or replace
      the RLS architecture section
- [ ] Edit `docs/security/README.md` -- remove RLS references
- [ ] Edit `AGENTS.md` -- remove RLS mentions from agent descriptions

#### 3.10 Remove RLS linting rule example

- [ ] Edit `CLAUDE.md` -- remove the custom ESLint rule example that blocks
      direct `{{ORM_CLIENT_NAME}}` calls
- [ ] Edit `linting_configs/eslint.config.mjs` -- remove the RLS enforcement
      rule (if present)

#### 3.11 Remove database-specific environment variables

- [ ] In `.env.template`, remove `DB_APP_USER_ROLE` and
      `DB_SUPERUSER_ROLE` (keep `DATABASE_URL` and `DIRECT_URL` if you still
      use a relational database)

#### 3.12 Update skill README indexes

- [ ] Edit `.claude/skills/README.md` -- remove the `rls-patterns` entry
- [ ] Edit `.gemini/skills/README.md` -- remove the `rls-patterns` entry

### What to Replace It With

Your project still needs an authorization layer. Choose one that fits your
database:

| Database | Recommended Authorization Approach |
|---|---|
| PostgreSQL (without RLS) | Application-level middleware + ORM query filters |
| MongoDB | Document-level access control with Mongoose middleware |
| MySQL / MariaDB | Application-level authorization middleware |
| Firebase | Firebase Security Rules |
| Supabase | Supabase RLS (similar to this template -- keep most patterns) |
| PlanetScale / Turso | Application-level authorization with edge middleware |

After removing RLS patterns, create a replacement `docs/security/AUTHORIZATION_GUIDE.md`
that documents your chosen approach. Update agent prompts to reference the new
guide instead.

### Verification

```bash
# Confirm no RLS skill directories remain
ls .claude/skills/rls-patterns 2>/dev/null && echo "REMOVE ME" || echo "OK"
ls .gemini/skills/rls-patterns 2>/dev/null && echo "REMOVE ME" || echo "OK"

# Confirm RLS docs are removed
ls docs/database/RLS_*.md 2>/dev/null && echo "REMOVE ME" || echo "OK"

# Confirm RLS hooks are removed
ls agent_providers/claude_code/hooks/pre-bash-rls-validation.sh 2>/dev/null \
  && echo "REMOVE ME" || echo "OK"
ls .claude/hooks/pre-bash-rls-validation.sh 2>/dev/null \
  && echo "REMOVE ME" || echo "OK"

# Search for lingering RLS references (expect minimal / only this file)
grep -ri "withUserContext\|withAdminContext\|withSystemContext\|rls.context\|row.level.security" \
  CLAUDE.md CONTRIBUTING.md AGENTS.md \
  agent_providers/ .claude/skills/ .gemini/skills/ \
  patterns_library/ docs/
```

---

## 4. Clerk / Auth Patterns

### When to Remove

Remove these references if your project uses an authentication provider
**other than Clerk**. Common alternatives include Auth0, NextAuth.js / Auth.js,
Supabase Auth, Firebase Auth, Lucia, or custom JWT-based auth.

> **Note**: Unlike the other sections, auth references are mostly in template
> placeholders (`{{AUTH_PROVIDER}}`) rather than hard-coded to Clerk. The main
> work is replacing Clerk-specific code examples in patterns and skills.

### Removal Checklist

#### 4.1 Replace Clerk-specific code in pattern library

- [ ] Edit `patterns_library/ui/authenticated-page.md` -- replace the
      `import { auth } from '@clerk/nextjs/server'` example with your auth
      provider's import
- [ ] Edit `patterns_library/api/user-context-api.md` -- replace Clerk auth
      helpers with your provider
- [ ] Edit `patterns_library/api/webhook-handler.md` -- replace or remove the
      "Clerk authentication webhooks" reference and Clerk webhook example
- [ ] Edit `patterns_library/api/zod-validation-api.md` -- replace Clerk auth
      references
- [ ] Edit `patterns_library/testing/api-integration-test.md` -- replace Clerk
      test mocking patterns

#### 4.2 Replace Clerk references in skills

- [ ] Edit `.claude/skills/frontend-patterns/SKILL.md` -- replace Clerk
      component references (e.g., `<SignIn />`, `<UserButton />`)
- [ ] Edit `.claude/skills/api-patterns/SKILL.md` -- replace Clerk auth
      middleware references
- [ ] Edit `.claude/skills/security-audit/SKILL.md` -- replace Clerk-specific
      security checks
- [ ] Repeat for corresponding `.gemini/skills/` files:
  - `.gemini/skills/frontend-patterns/SKILL.md`
  - `.gemini/skills/api-patterns/SKILL.md`
  - `.gemini/skills/security-audit/SKILL.md`

#### 4.3 Replace Clerk references in agent prompts

- [ ] Edit `agent_providers/claude_code/prompts/be-developer.md` -- replace
      Clerk middleware and auth helper references
- [ ] Edit `agent_providers/claude_code/prompts/fe-developer.md` -- replace
      Clerk component references
- [ ] Edit `agent_providers/claude_code/prompts/system-architect.md` -- replace
      Clerk architecture references
- [ ] Edit `agent_providers/claude_code/prompts/bsa.md` -- replace Clerk
      acceptance-criteria examples
- [ ] Edit `agent_providers/claude_code/prompts/qas.md` -- replace Clerk
      testing references

#### 4.4 Replace Clerk references in agent definitions

- [ ] Edit `.claude/agents/be-developer.md` -- replace Clerk references
- [ ] Edit `.claude/agents/fe-developer.md` -- replace Clerk references
- [ ] Edit `.claude/agents/system-architect.md` -- replace Clerk references
- [ ] Edit `.claude/agents/bsa.md` -- replace Clerk references
- [ ] Edit `.claude/agents/qas.md` -- replace Clerk references

#### 4.5 Update template placeholders

- [ ] In `CLAUDE.md`, update the **Authentication** subsection under
      "Project-Specific Implementation Notes" to reflect your auth provider
- [ ] Replace `{{AUTH_PROVIDER}}` with your provider name across the repository
      (the setup wizard handles this, but verify)
- [ ] Replace `{{AUTH_ROUTES}}` with your auth routes (e.g., `/login`,
      `/register` instead of `/sign-in`, `/sign-up`)
- [ ] Replace `{{PROTECTED_ROUTES}}` with your protected route patterns

#### 4.6 Update Augment provider rules

- [ ] Edit `agent_providers/augment/rules/project-guidelines.md` -- replace
      Clerk references with your auth provider
- [ ] Edit `agent_providers/augment/rules/review-checklist.md` -- replace
      Clerk-specific review items

#### 4.7 Update CODEOWNERS

- [ ] In `project_workflow/.github/CODEOWNERS`, update the authentication
      ownership line to reference your auth team or remove `@{{AUTH_TEAM}}`

#### 4.8 Update security documentation

- [ ] Edit `docs/security/SECURITY_FIRST_ARCHITECTURE.md` -- replace Clerk
      architecture with your provider's architecture

### What to Replace It With

Replace Clerk-specific patterns with equivalent patterns for your auth
provider. Here is a quick mapping:

| Clerk Pattern | Auth0 Equivalent | NextAuth.js Equivalent |
|---|---|---|
| `import { auth } from '@clerk/nextjs/server'` | `import { getSession } from '@auth0/nextjs-auth0'` | `import { getServerSession } from 'next-auth'` |
| `const { userId } = await auth()` | `const session = await getSession()` | `const session = await getServerSession(authOptions)` |
| `<SignIn />` component | Auth0 Universal Login redirect | `<signIn />` or custom form |
| `<UserButton />` component | Custom user menu | Custom user menu with `useSession()` |
| Clerk webhook (`svix` signatures) | Auth0 Actions / Hooks | NextAuth.js callbacks |
| `clerkMiddleware()` | `withMiddlewareAuthRequired()` | NextAuth.js `middleware.ts` |

Create or update `docs/security/AUTHENTICATION_GUIDE.md` with your provider's
patterns and link to it from `CLAUDE.md`.

### Verification

```bash
# Search for lingering Clerk-specific references
grep -ri "clerk\|@clerk" \
  patterns_library/ .claude/skills/ .gemini/skills/ \
  agent_providers/ CLAUDE.md docs/security/
# Expect: no output (or only this file)

# Verify AUTH_PROVIDER placeholder was replaced
grep -r "{{AUTH_PROVIDER}}" CLAUDE.md
# Expect: no output (should be replaced with your provider name)
```

---

## Verification After Removal

After completing any of the removal checklists above, run a final sweep to
confirm the repository is clean and consistent.

```bash
# 1. Full-text search for removed integration references
#    Adjust the pattern based on which integrations you removed.
grep -ri \
  "stripe\|PAYMENT_PROVIDER\|confluence\|MCP_CONFLUENCE\|withUserContext\|withAdminContext\|withSystemContext\|@clerk" \
  --include="*.md" --include="*.sh" --include="*.json" --include="*.toml" \
  . \
  | grep -v "OPTIONAL-FEATURES.md" \
  | grep -v "node_modules"
# Expect: no output (or only intentional references you chose to keep)

# 2. Verify no broken internal links in key docs
#    Manually spot-check links in these files:
#    - CLAUDE.md
#    - AGENTS.md
#    - CONTRIBUTING.md
#    - docs/onboarding/AGENT-SETUP-GUIDE.md
#    - docs/onboarding/DAY-1-CHECKLIST.md

# 3. Run available linting (if configured for your project)
{{LINT_COMMAND}} 2>/dev/null || echo "Linting not yet configured -- skip"

# 4. Verify skill indexes are consistent with remaining skill directories
diff <(ls .claude/skills/ | grep -v README.md | sort) \
     <(grep -oP '(?<=\[)[\w-]+(?=\])' .claude/skills/README.md | sort) \
  && echo "Claude skills index OK" || echo "Claude skills index MISMATCH -- update README.md"
```

---

## Summary

| Integration | Difficulty | Key Directories to Remove |
|---|---|---|
| Stripe / Payments | Low | `.claude/skills/stripe-patterns/`, `.gemini/skills/stripe-patterns/` |
| Confluence | Low | `.claude/skills/confluence-docs/`, `.gemini/skills/confluence-docs/`, `agent_providers/augment/rules/confluence-standards.md` |
| RLS / PostgreSQL | High | `.claude/skills/rls-patterns/`, `.gemini/skills/rls-patterns/`, `docs/database/RLS_*.md`, `patterns_library/database/rls-migration.md`, RLS hooks |
| Clerk / Auth | Medium | Pattern library auth examples, skill auth references, agent prompt auth patterns |

When in doubt, keep a file and customize it rather than deleting it. The
patterns in this template encode hard-won conventions -- even if you swap out
the specific technology, the structural patterns (webhook handling, auth
middleware, data isolation) usually still apply.
