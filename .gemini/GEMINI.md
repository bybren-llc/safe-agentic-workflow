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

Skills auto-load when context matches. All 17 skills:

| Skill | Trigger When |
|-------|--------------|
| `safe-workflow` | Starting work, commits, branches, PRs |
| `pattern-discovery` | Before implementing features |
| `rls-patterns` | Database operations, RLS policies |
| `api-patterns` | Creating API endpoints |
| `frontend-patterns` | UI components, pages |
| `testing-patterns` | Writing tests |
| `security-audit` | Security validation |
| `linear-sop` | Ticket management |
| `deployment-sop` | Deploying code |
| `orchestration-patterns` | Multi-step workflows, pipelines |
| `agent-coordination` | Multi-agent collaboration |
| `spec-creation` | Writing SAFe specs (Epic/Feature/Story) |
| `release-patterns` | Release management, versioning |
| `git-advanced` | Rebasing, cherry-pick, conflict resolution |
| `stripe-patterns` | Payment integration, webhooks |
| `confluence-docs` | Confluence documentation, templates |
| `migration-patterns` | Database migrations, schema changes |

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

### Media Commands
- `/media:analyze-images <dir>` - Analyze images using vision
- `/media:extract-pdf <file>` - Extract structured data from PDFs
- `/media:sketch-to-code <image>` - Generate code from UI sketches
- `/media:organize-files <dir>` - Organize files based on content
- `/media:transcribe-audio <file>` - Transcribe audio to text/SRT/VTT
- `/media:analyze-audio <file>` - Analyze audio content and mood
- `/media:extract-dialogue <file>` - Extract dialogue with speaker diarization
- `/media:analyze-video <file>` - Analyze video scene by scene
- `/media:extract-frames <file>` - Extract key frames with descriptions
- `/media:video-to-script <file>` - Generate screenplay from video
- `/media:scene-detect <file>` - Detect scene transitions with timestamps

### Built-in Commands (Gemini CLI v0.32+)
- `/plan` - Enter plan mode for complex tasks
- `/rewind` - Navigate to a previous point in the session
- `/introspect` - Debug session state and context
- `/prompt-suggest` - Generate prompt suggestions
- `/hooks` - Manage lifecycle hooks (panel, enable, disable)
- `/skills` - Manage agent skills (list, link, enable, disable)
- `/settings` - View and edit settings interactively
- `/restore` - Restore from a checkpoint

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

> **Tip**: If your team uses GitHub-Linear auto-sync, tickets referenced in commit messages (e.g., `[WOR-123]`) auto-move to Done when the PR merges. Manually close child stories not referenced in commits.

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

## Plan Mode (v0.29.0+)

Use `/plan` to enter plan mode before implementing complex changes. Gemini CLI will:
1. Analyze the task and break it into steps
2. Present the plan for your approval
3. Execute the plan with tracking

Settings in `settings.json`:
```json
{
  "general": {
    "plan": { "directory": ".gemini/plans", "modelRouting": true }
  }
}
```

## Policy Engine (v0.30.0+)

The policy engine provides fine-grained control over tool execution. Configure policies via:
- `settings.json` → `policyPaths: ["path/to/policy.yaml"]`
- CLI flag: `gemini --policy strict.yaml`

Policies can restrict tools, MCP servers (with wildcards), and match tool annotations.
Replaces the deprecated `--allowed-tools` flag.

## Browser Agent (Experimental, v0.31.0+)

An experimental subagent that interacts with web pages via accessibility tree.
- Navigate, fill forms, click elements, extract content
- Configure in `settings.json` under `agents.browser`
- Requires explicit opt-in via experimental flags

## Hooks System (v0.26.0+)

Hooks intercept Gemini CLI lifecycle events. Configure in `settings.json`:

| Event | When | Use Case |
|-------|------|----------|
| `SessionStart` | Session begins | Load context |
| `BeforeAgent` | Before planning | Validate input |
| `AfterAgent` | Loop completes | Review output |
| `BeforeTool` | Before tool exec | Block operations |
| `AfterTool` | After tool exec | Run tests |
| `PreCompress` | Context compression | Save state |

Manage via `/hooks panel`, `/hooks enable-all`, `/hooks disable-all`.

## Extensions (v0.26.0+)

Extensions bundle skills, MCP servers, commands, and tool restrictions into shareable packages.
- Install: `gemini extensions install <source>`
- Skills are individual capabilities; extensions are the distribution format
- Extension skills load at the Extension tier (lowest precedence after workspace and user)

## Checkpointing (v0.30.0+)

Session recovery via automatic checkpoints before file modifications.
- Enable: `settings.json` → `general.checkpointing.enabled: true`
- Restore: `/restore` command
- Stored in `~/.gemini/tmp/<project_hash>/checkpoints`

## Model Configuration

| Model | Default Since | Notes |
|-------|--------------|-------|
| Gemini 3 Flash | v0.29.0 | Default for all users |
| Gemini 3.1 Pro Preview | v0.31.0 | Higher capability |

Configure in `settings.json` → `model.name` or use `{{GEMINI_MODEL}}` placeholder.
Plan mode can auto-switch between Flash (planning) and Pro (execution) via `plan.modelRouting`.

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
