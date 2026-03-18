# CODEX.md

## AI Assistant Context for SAFe Multi-Agent Development

**Repository**: {{PROJECT_NAME}}
**Methodology**: SAFe (Scaled Agile Framework) Agentic Workflow
**Philosophy**: "Round Table" - Equal voice, mutual respect, shared responsibility

---

## Quick Start

This is a **SAFe multi-agent development project** with 11 specialized AI agents working collaboratively. You are part of a team where your input has equal weight with human contributors.

**Core Principles**:
- Search for existing patterns before creating new ones ("Search First, Reuse Always")
- Attach evidence to Linear tickets for all work
- You have "stop-the-line" authority for architectural/security concerns
- Follow SAFe methodology: Epic > Feature > Story > Enabler

**Key Resources**:
- [AGENTS.md](AGENTS.md) - All 11 agent roles, invocation patterns, capabilities
- [CONTRIBUTING.md](CONTRIBUTING.md) - Git workflow, commit standards, PR process
- [docs/onboarding/](docs/onboarding/) - Setup guides and daily workflows
- [docs/guides/ROUND-TABLE-PHILOSOPHY.md](docs/guides/ROUND-TABLE-PHILOSOPHY.md) - Collaboration principles
- [patterns_library/](patterns_library/) - Reusable code patterns (18+ patterns, 7 categories)

---

## Development Commands

```bash
# Development server
{{DEV_COMMAND}}              # Start development server

# Build and production
{{BUILD_COMMAND}}            # Build for production
{{START_COMMAND}}            # Start production server

# Code quality
{{LINT_COMMAND}}             # Run linting
{{LINT_FIX_COMMAND}}         # Auto-fix linting issues
{{TYPE_CHECK_COMMAND}}       # TypeScript validation
{{FORMAT_CHECK_COMMAND}}     # Prettier formatting check

# Testing
{{TEST_UNIT_COMMAND}}        # Run unit tests
{{TEST_INTEGRATION_COMMAND}} # Run integration tests
{{TEST_E2E_COMMAND}}         # Run end-to-end tests

# Database (if applicable)
{{DB_MIGRATE_COMMAND}}       # Run migrations

# CI/CD validation (REQUIRED before PR)
{{CI_VALIDATE_COMMAND}}      # Run all quality checks
```

**Important**: Always run `{{CI_VALIDATE_COMMAND}}` before creating a pull request.

---

## Architecture Overview

### Technology Stack

- **Frontend**: {{FRONTEND_FRAMEWORK}}
- **Backend**: {{BACKEND_FRAMEWORK}}
- **Database**: {{DATABASE_SYSTEM}}
- **ORM**: {{ORM_TOOL}}
- **Authentication**: {{AUTH_PROVIDER}}
- **Payments**: {{PAYMENT_PROVIDER}}
- **Analytics**: {{ANALYTICS_PROVIDER}}
- **UI Components**: {{UI_LIBRARY}}

### Repository Structure

```
{{PROJECT_NAME}}/
├── CODEX.md                     # This file - AI assistant context (Codex CLI)
├── CLAUDE.md                    # AI assistant context (Claude Code)
├── AGENTS.md                    # Agent team quick reference
├── CONTRIBUTING.md              # Git workflow and commit standards
├── docs/                        # Documentation (onboarding, database, security, sop, workflow)
├── specs/                       # SAFe specifications (Epic/Feature/Story)
├── patterns_library/            # Reusable code patterns (7 categories)
├── .codex/                      # Codex CLI harness (commands, skills, settings)
├── .claude/                     # Claude Code harness (hooks, commands, skills, agents)
├── .gemini/                     # Gemini CLI harness (commands, skills, settings)
├── agent_providers/             # Agent configurations
└── scripts/                     # Utility scripts
```

---

## SAFe Workflow

All work follows the SAFe hierarchy and specs-driven development:

1. BSA creates spec in `specs/{{TICKET_PREFIX}}-XXX-feature-spec.md`
2. System Architect validates architectural approach
3. Implementation agents execute with pattern discovery
4. QAS validates against acceptance criteria
5. Evidence attached to Linear ticket before POPM review

### Metacognitive Tags

Use in specs to highlight critical decisions:
- `#PATH_DECISION` - Architectural path chosen (document alternatives)
- `#PLAN_UNCERTAINTY` - Areas requiring validation
- `#EXPORT_CRITICAL` - Security/compliance requirements

### Pattern Discovery Protocol (MANDATORY)

**Before implementing ANY feature:**

1. Search `patterns_library/` for existing patterns
2. Search `specs/` for similar specifications
3. Search codebase for similar implementations
4. Consult documentation: [CONTRIBUTING.md](CONTRIBUTING.md), [docs/database/](docs/database/), [docs/security/](docs/security/)
5. Propose to System Architect before implementation

---

## Project-Specific Implementation Notes

*Customize this section for your technology stack.*

### Authentication

**Provider**: {{AUTH_PROVIDER}}

- Environment variables: See `.env.template`
- Routes: {{AUTH_ROUTES}} / {{PROTECTED_ROUTES}}
- Patterns: `patterns_library/` + [docs/security/SECURITY_FIRST_ARCHITECTURE.md](docs/security/SECURITY_FIRST_ARCHITECTURE.md)

### Payments

**Provider**: {{PAYMENT_PROVIDER}}

- Webhook endpoints: {{WEBHOOK_ROUTES}}
- Patterns: `patterns_library/api/webhook-handler.md`
- Idempotency required for all payment operations

### Analytics

**Provider**: {{ANALYTICS_PROVIDER}}

- Privacy-first: No tracking without explicit consent (GDPR/CCPA)
- Error boundaries: Analytics failures must not crash the app

### Database

**System**: {{DATABASE_SYSTEM}} | **ORM**: {{ORM_TOOL}}

**Guidelines**:
- Always use ORM (type safety) with RLS context helpers (`withUserContext`, `withAdminContext`, `withSystemContext`)
- Always create proper migrations (never `db push` in production)
- Never use direct SQL or bypass RLS policies

**Schema Docs**: [docs/database/DATA_DICTIONARY.md](docs/database/DATA_DICTIONARY.md) (single source of truth)

**Migration Workflow**:
```bash
{{MIGRATION_CREATE_COMMAND}}     # Create migration
{{MIGRATION_TEST_COMMAND}}       # Test locally
git add {{MIGRATIONS_DIR}}/ && git commit -m "feat(db): add feature migration"
{{MIGRATION_DEPLOY_COMMAND}}     # Deploy to production
```

---

## RLS (Row Level Security) Requirements

**CRITICAL**: All database operations MUST use RLS context helpers:

```typescript
// CORRECT - Always use context helpers
const user = await withUserContext(prisma, userId, async (client) => {
  return client.user.findUnique({ where: { user_id: userId } });
});

// FORBIDDEN - Direct Prisma calls bypass RLS
const user = await prisma.user.findUnique({ where: { user_id } }); // NEVER DO THIS
```

Context helpers:
- `withUserContext` - User-facing operations
- `withAdminContext` - Admin operations
- `withSystemContext` - Webhooks and background jobs

---

## Agent Roles (Reference)

Codex CLI does not have discrete agent personas, but embody these roles as needed:

| Role | Responsibility |
|------|----------------|
| **BSA** | Requirements, specs, acceptance criteria |
| **System Architect** | Pattern validation, architectural decisions |
| **FE Developer** | Frontend components, UI |
| **BE Developer** | Backend APIs, server logic |
| **Data Engineer** | Database, migrations, RLS |
| **QAS** | Testing, validation |
| **Security Engineer** | Security audits, RLS validation |
| **Tech Writer** | Documentation |
| **RTE** | PR creation, releases |
| **TDM** | Coordination, blockers |

---

## Code Quality

**Linter**: {{LINTER_TOOL}} | **Config**: {{LINTER_CONFIG_FORMAT}}

```bash
{{LINT_COMMAND}}          # Run linter
{{LINT_FIX_COMMAND}}      # Auto-fix issues
```

Always run `{{LINT_COMMAND}}` before committing. Consult your linting configuration file for project-specific rules.

---

## CI/CD Pipeline

**MANDATORY**: Read [CONTRIBUTING.md](CONTRIBUTING.md) before any development.

### PR Workflow

1. Create feature branch: `{{TICKET_PREFIX}}-{number}-{description}`
2. Implement with proper commits: `type(scope): description [{{TICKET_PREFIX}}-XXX]`
3. Rebase: `git rebase origin/{{MAIN_BRANCH}}`
4. Validate: `{{CI_VALIDATE_COMMAND}}` (must pass)
5. Push: `git push --force-with-lease`
6. Create PR using `.github/pull_request_template.md`
7. Merge using "Rebase and merge" only

### Branch Protection

- All PRs must be up-to-date with `{{MAIN_BRANCH}}`
- All CI checks must pass
- CODEOWNERS reviewers required
- No direct pushes to `{{MAIN_BRANCH}}`

**Detailed Guides**: [docs/ci-cd/CI-CD-Pipeline-Guide.md](docs/ci-cd/CI-CD-Pipeline-Guide.md) | [docs/workflow/](docs/workflow/)

---

## Stop-the-Line Conditions

**Immediately stop and escalate if you encounter:**

1. **Direct Prisma calls** - Must use RLS context helpers
2. **Missing AC/DoD** - Route to BSA before implementation
3. **Security vulnerabilities** - Hardcoded secrets, SQL injection
4. **Architecture changes without approval** - Get ARCHitect sign-off
5. **CI failures before merge** - Fix before proceeding

---

## Available Skills

Skills provide contextual knowledge. See `.codex/skills/` for all available skills:

| Skill | Trigger When |
|-------|--------------|
| `safe-workflow` | Starting work, commits, branches, PRs |
| `pattern-discovery` | Before implementing features |
| `testing-patterns` | Writing tests |

---

## Available Commands

Commands are markdown instruction files in `.codex/commands/`. Pass them via `codex --instructions .codex/commands/<name>.md`:

| Command | Purpose |
|---------|---------|
| `start-work.md` | Start work on Linear ticket |
| `pre-pr.md` | Pre-PR validation checklist |
| `end-work.md` | Complete work session |
| `search-pattern.md` | Search codebase for patterns |
| `check-workflow.md` | Quick workflow health check |

---

## Linear Integration

Use the Linear web UI or CLI for ticket management:
- **Linear Web UI**: https://linear.app
- **Linear CLI**: `linear` command (if installed)
- **Evidence Templates**: See `safe-workflow` skill

> **Tip**: If your team uses GitHub-Linear auto-sync, tickets referenced in commit messages (e.g., `[{{TICKET_PREFIX}}-123]`) auto-move to Done when the PR merges.

---

## Documentation Structure

```
docs/
├── onboarding/          # New user guides
├── database/            # Schema, RLS, migrations
├── security/            # Security architecture
├── ci-cd/               # CI/CD pipeline
├── sop/                 # Standard Operating Procedures
├── workflow/            # Workflow templates
└── adr/                 # Architecture Decision Records
```

---

## Quick References

- **CONTRIBUTING.md**: Git workflow, commit standards
- **AGENTS.md**: Agent team structure
- **CLAUDE.md**: AI assistant context (Claude Code compatible)
- **GEMINI.md**: AI assistant context (Gemini CLI compatible)
- **docs/database/RLS_IMPLEMENTATION_GUIDE.md**: RLS patterns
- **docs/database/DATA_DICTIONARY.md**: Database schema
