# Claude Code Harness Setup Guide (ConTStack)

## Quick Start (15 Minutes)

This guide helps you install the SAFe Claude Code harness in the ConTStack project.

---

## Prerequisites

- Claude Code CLI installed (`claude --version`)
- Git repository initialized
- Node.js project with `package.json`
- Bun package manager installed (`bun --version`)

---

## ConTStack Technology Stack

| Layer | Technology | Notes |
|-------|------------|-------|
| **Database** | Convex | Real-time sync, serverless |
| **Authentication** | WorkOS AuthKit | Enterprise SSO ready |
| **Payments** | Polar | Subscription management |
| **Issue Tracking** | Linear | Sprint/ticket management |
| **Agent Tasks** | Beads | Agent task management CLI |
| **Frontend** | Next.js 14 | App Router, React 18 |
| **Styling** | TailwindCSS + Shadcn UI | Component library |

---

## Port Mappings

ConTStack uses the following port assignments for local development:

| Port | App | Description |
|------|-----|-------------|
| 3000 | web | Marketing site |
| 3003 | app | Main SaaS application |
| 3005 | e2e-test | E2E test runner |
| 3006 | crm | CRM application |
| 3007 | bubble-api | BubbleLab API service |

---

## Step 1: Copy the Harness Structure

```bash
# From the source repository root, copy to your project:

# Copy slash commands (24 commands)
cp -r .claude/commands/ /path/to/your-project/.claude/commands/

# Copy skills (17 model-invoked skills)
cp -r .claude/skills/ /path/to/your-project/.claude/skills/

# Copy agent profiles (11 SAFe agents)
cp -r .claude/agents/ /path/to/your-project/.claude/agents/
```

---

## Step 2: Configure Hooks

Create or update your project's `.claude/settings.local.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "git branch --show-current 2>/dev/null | grep -q '^ConTS-[0-9]' || echo '  REMINDER: Branch should follow ConTS-{number}-{description} format.'",
            "description": "Remind about branch naming convention"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash.*git\\s+commit",
        "hooks": [
          {
            "type": "command",
            "command": "echo '  REMINDER: Commit message must follow SAFe format: type(scope): description [ConTS-XXX]'",
            "description": "Remind about commit message format"
          }
        ]
      },
      {
        "matcher": "Bash.*git\\s+push",
        "hooks": [
          {
            "type": "command",
            "command": "BRANCH=$(git branch --show-current); if [ \"$BRANCH\" = 'main' ] || [ \"$BRANCH\" = 'master' ]; then echo '  BLOCKER: Cannot push directly to '$BRANCH'. Create a feature branch first.'; exit 1; fi",
            "description": "Block direct push to main or master"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "echo '  Session Started\\n  Key commands: /start-work, /pre-pr, /end-work\\n  Full list: see .claude/README.md'",
            "description": "Session start reminder"
          }
        ]
      }
    ]
  }
}
```

**Note**: ConTStack uses `ConTS-` as the ticket prefix and protects `main`/`master` branches.

---

## Step 3: Customize for Your Project

### Ticket Prefix (ConTStack Standard)

ConTStack uses `ConTS-` as the ticket prefix for all branches and commits:

| Pattern | Example |
|---------|---------|
| Branch | `ConTS-123-add-user-dashboard` |
| Commit | `feat(auth): add SSO login [ConTS-123]` |
| PR Title | `[ConTS-123] Add user dashboard` |

### Update Linear Workspace

If using Linear MCP tools, update workspace references in:

- `.claude/skills/linear-sop/SKILL.md`
- `.claude/commands/start-work.md`
- `.claude/commands/sync-linear.md`

---

## Step 4: Validate Installation

### Run Validation Commands

ConTStack uses Bun for all package management:

```bash
# Lint the codebase
bun run lint

# Type check
bun run typecheck

# Run tests
bun run test

# Run E2E tests (Docker Playwright)
bun test:e2e:docker:comprehensive
```

### Check Skills Load

Ask Claude:

```
What skills are available?
```

Expected: List of 17 skills with descriptions.

**Known Issue (v2.0.73)**: The `/skills` command has a display bug. Skills work correctly but won't appear in `/skills` output. Ask Claude directly instead.

### Check Commands Work

Run:

```
/start-work ConTS-123
```

Expected: Claude should guide you through starting work on a ticket.

### Check Hooks Fire

Create a test commit:

```bash
git checkout -b ConTS-123-test-branch
echo "test" > test.txt
git add test.txt
git commit -m "test: validate hooks [ConTS-123]"
```

Expected: See reminder about SAFe commit format before commit executes.

---

## Step 5: Copy Documentation (Recommended)

For full harness understanding, copy these docs:

```bash
# Core documentation
cp AGENTS.md /path/to/your-project/
cp CONTRIBUTING.md /path/to/your-project/

# Whitepapers
cp docs/whitepapers/CLAUDE-CODE-HARNESS-*.md /path/to/your-project/docs/whitepapers/

# SOPs
cp -r docs/sop/ /path/to/your-project/docs/sop/
cp -r docs/patterns/ /path/to/your-project/docs/patterns/
```

---

## Directory Structure

After setup, your `.claude/` directory should look like:

```text
.claude/
├── commands/           # 24 slash commands
│   ├── start-work.md
│   ├── pre-pr.md
│   ├── end-work.md
│   └── ... (21 more)
├── skills/             # 17 model-invoked skills
│   ├── safe-workflow/SKILL.md
│   ├── pattern-discovery/SKILL.md
│   ├── rls-patterns/SKILL.md      # Covers Convex auth helpers
│   ├── payment-patterns/SKILL.md  # Polar integration (was stripe-patterns)
│   └── ... (13 more)
├── agents/             # 11 SAFe agent profiles
│   ├── bsa.md
│   ├── tdm.md
│   ├── rte.md
│   └── ... (8 more)
├── hooks/              # Hook scripts (if using)
│   ├── post-commit-linear-update.sh
│   └── post-push-docker-check.sh
├── settings.local.json # Hooks configuration
├── README.md           # Harness overview
├── SETUP.md            # This file
└── TROUBLESHOOTING.md  # Common issues
```

---

## ConTStack-Specific Skills Reference

### Adapted Skills

| Original Skill | ConTStack Skill | Purpose |
|----------------|-----------------|---------|
| `stripe-patterns` | `payment-patterns` | Polar subscription integration |
| `rls-patterns` | `rls-patterns` | Convex auth helpers & multi-tenant patterns |
| `clerk-patterns` | (removed) | WorkOS AuthKit - see apps/app/CLAUDE.md |

### Convex-Specific Patterns

The `rls-patterns` skill in ConTStack covers:

- `requireAuth(ctx)` - Ensure user is authenticated
- `requireOrganization(ctx)` - Get org-scoped context
- `requirePermission(ctx, "resource:action")` - RBAC permission check
- Multi-tenant data isolation patterns
- Query gating with `useConvexAuth()`

### Beads Integration

ConTStack uses Beads for agent task management:

```bash
# Find ready work
bd ready --json

# Create issue during work
bd create "Description" -t [bug|task|feature|epic] -p [0-4] -l [labels]

# Update status
bd update [issue-id] --status in_progress

# Complete work
bd close [issue-id] --reason "Completion summary"
```

---

## Next Steps

1. **Read AGENTS.md** - Understand when to use which agent
2. **Read the Whitepaper** - Understand the three-layer architecture
3. **Read CLAUDE.md** - ConTStack-specific patterns and conventions
4. **Try /start-work** - Begin your first ticket with the harness
5. **Check TROUBLESHOOTING.md** - If anything doesn't work

---

## Quick Command Reference

| Command | Purpose |
|---------|---------|
| `/start-work ConTS-123` | Begin work on a ticket |
| `/check-workflow` | Check current workflow status |
| `/pre-pr` | Run validation before PR |
| `/end-work` | Complete work session |
| `/local-sync` | Sync after git pull |
| `/remote-status` | Check remote Docker status |

---

## Validation Commands Quick Reference

```bash
# Full validation suite (run before PR)
bun run lint && bun run typecheck && bun run test

# Individual commands
bun run lint          # ESLint + Prettier
bun run typecheck     # TypeScript strict mode
bun run test          # Vitest unit tests
bun run build         # Turbo build all packages

# E2E testing
bun test:e2e:docker:comprehensive    # Full E2E suite
bun test:e2e:docker:validate         # Validate Docker setup
```

---

## Support

- **Issues**: Check `TROUBLESHOOTING.md` first
- **Documentation**: See `docs/whitepapers/` for architecture details
- **Workflow**: See `CONTRIBUTING.md` for complete workflow guide
- **ConTStack Specifics**: See root `CLAUDE.md` for project patterns

---

**Version**: 1.0-contstack
**Last Updated**: 2025-01-11
**Adapted From**: WTFB Claude Code Harness v1.0
