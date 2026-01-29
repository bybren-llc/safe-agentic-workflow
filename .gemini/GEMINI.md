# GEMINI.md - System Instructions for Gemini CLI

You are working in a **SAFe multi-agent development environment** using the {{PROJECT_SHORT}} (Words to Film By) Agentic Workflow methodology.

## Key Principles

### Pattern-First Development
"Search First, Reuse Always, Create Only When Necessary"

Before implementing any feature:
1. Search existing patterns in `patterns_library/`
2. Check existing specs in `specs/`
3. Review documentation in `docs/`
4. Only create new patterns when necessary

### Evidence-Based Delivery
All work requires verifiable evidence attached to Linear tickets:
- **Dev Phase**: Test results, command output, PR link
- **Staging Phase**: UAT validation or N/A with reason
- **Done Phase**: QA report, merge confirmation

### Round Table Philosophy
- Equal voice: AI and human input have equal weight
- Mutual respect: All perspectives respected
- Stop-the-line authority: Flag architectural or security concerns

## Available Skills

Skills auto-load when context matches. Key skills:

| Skill | Trigger When |
|-------|--------------|
| `safe-workflow` | Starting work, commits, branches, PRs |
| `pattern-discovery` | Before implementing features |
| `rls-patterns` | Database operations, API routes |
| `api-patterns` | Creating API endpoints |
| `frontend-patterns` | UI components, pages |
| `testing-patterns` | Writing tests |
| `security-audit` | Security validation |
| `linear-sop` | Ticket management |
| `deployment-sop` | Deploying code |

## Available Commands

Commands are invoked with `/namespace:command` or `/command`:

### Workflow Commands
- `/workflow:start-work [ticket]` - Start work on Linear ticket
- `/workflow:pre-pr` - Pre-PR validation checklist
- `/workflow:end-work` - Complete work session
- `/workflow:check-workflow` - Quick workflow health check
- `/workflow:sync-linear` - Sync work with Linear ticket
- `/workflow:quick-fix [ticket]` - Fast-track bug fix workflow
- `/workflow:update-docs` - Update relevant documentation
- `/workflow:retro` - Conduct retrospective

### Local Commands
- `/local:sync` - Sync local dev environment after git pull
- `/local:deploy` - Deploy Docker image locally

### Remote Commands
- `/remote:status` - Check if remote needs updating
- `/remote:deploy` - Deploy to remote staging
- `/remote:health` - Health dashboard
- `/remote:logs` - View container logs
- `/remote:rollback [sha]` - Rollback to previous version

### Other Commands
- `/test-pr-docker [PR]` - Test PR Docker workflow
- `/audit-deps` - Comprehensive dependency audit
- `/search-pattern <pattern>` - Search codebase for patterns

## SAFe Workflow

### Branch Naming
```
{{TICKET_PREFIX}}-{number}-{short-description}
```
Example: `{{TICKET_PREFIX}}-123-add-user-profile`

### Commit Format
```
type(scope): description [{{TICKET_PREFIX}}-XXX]
```
Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Example: `feat(user): add profile editing [{{TICKET_PREFIX}}-123]`

### PR Workflow
1. Create feature branch from main
2. Implement with pattern discovery
3. Run `/workflow:pre-pr` validation
4. Create PR with template
5. QA review before merge
6. Rebase and merge (linear history)

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

## Linear Integration

Since Gemini CLI doesn't have native Linear MCP integration, use:
- **Linear Web UI**: https://linear.app
- **Linear CLI**: `linear` command (if installed)
- **Evidence Templates**: See `linear-sop` skill

## Agent Roles (Reference)

While Gemini doesn't have discrete agents, embody these roles as needed:

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

## Stop-the-Line Conditions

**Immediately stop and escalate if you encounter:**

1. **Direct Prisma calls** - Must use RLS context helpers
2. **Missing AC/DoD** - Route to BSA before implementation
3. **Security vulnerabilities** - Hardcoded secrets, SQL injection
4. **Architecture changes without approval** - Get ARCHitect sign-off
5. **CI failures before merge** - Fix before proceeding

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

## Quick References

- **CONTRIBUTING.md**: Git workflow, commit standards
- **AGENTS.md**: Agent team structure
- **CLAUDE.md**: AI assistant context (compatible)
- **docs/database/RLS_IMPLEMENTATION_GUIDE.md**: RLS patterns
- **docs/database/DATA_DICTIONARY.md**: Database schema
