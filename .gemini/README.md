# Gemini CLI Configuration

This directory contains the configuration for [Gemini CLI](https://geminicli.com/), Google's AI-powered command-line tool.

## Quick Start

1. **Install Gemini CLI**
   ```bash
   # See https://geminicli.com/docs/cli/installation/
   npm install -g @anthropic-ai/gemini-cli
   # or
   brew install gemini-cli
   ```

2. **Authenticate**
   ```bash
   gemini auth login
   ```

3. **Run Gemini in your project**
   ```bash
   cd your-project
   gemini
   ```

The CLI will automatically detect and load skills from `.gemini/skills/` and commands from `.gemini/commands/`.

## Directory Structure

```
.gemini/
├── GEMINI.md           # System instructions (auto-loaded)
├── README.md           # This file
├── settings.json       # Configuration template
├── skills/             # Auto-loaded skills (17 total)
│   ├── safe-workflow/
│   │   └── SKILL.md
│   ├── pattern-discovery/
│   │   └── SKILL.md
│   ├── rls-patterns/
│   │   └── SKILL.md
│   └── ... (14 more)
└── commands/           # Custom commands (18 total)
    ├── workflow/
    │   ├── start-work.toml
    │   ├── pre-pr.toml
    │   └── ...
    ├── local/
    │   ├── sync.toml
    │   └── deploy.toml
    ├── remote/
    │   ├── status.toml
    │   └── ...
    └── *.toml
```

## Skills

Skills provide contextual knowledge that auto-loads when relevant. View available skills:

```bash
gemini /skills
```

### Included Skills (17)

| Skill | Description |
|-------|-------------|
| `safe-workflow` | SAFe development workflow, branch naming, commits |
| `pattern-discovery` | Pattern library discovery |
| `rls-patterns` | Row Level Security patterns |
| `api-patterns` | API route implementation |
| `frontend-patterns` | Next.js, shadcn/ui patterns |
| `testing-patterns` | Jest and Playwright testing |
| `security-audit` | Security validation, OWASP |
| `linear-sop` | Linear ticket management |
| `migration-patterns` | Database migrations with RLS |
| `deployment-sop` | Deployment workflows |
| `orchestration-patterns` | Multi-step task orchestration |
| `agent-coordination` | Agent assignment matrix |
| `spec-creation` | Spec creation templates |
| `release-patterns` | PR and release coordination |
| `git-advanced` | Rebase, bisect, cherry-pick |
| `stripe-patterns` | Payment integration |
| `confluence-docs` | ADRs, runbooks, architecture docs |

## Commands

Commands are invoked with `/namespace:command` or `/command`. View available commands:

```bash
gemini /help
```

### Command Namespaces

**Workflow** (`/workflow:*`):
- `start-work [ticket]` - Start work on Linear ticket
- `pre-pr` - Pre-PR validation checklist
- `end-work` - Complete work session
- `check-workflow` - Quick workflow health check
- `sync-linear` - Sync work with Linear ticket
- `quick-fix [ticket]` - Fast-track bug fix
- `update-docs` - Update documentation
- `retro` - Conduct retrospective

**Local** (`/local:*`):
- `sync` - Sync local dev environment
- `deploy` - Deploy Docker image locally

**Remote** (`/remote:*`):
- `status` - Check if update needed
- `deploy` - Deploy to remote staging
- `health` - Health dashboard
- `logs` - View container logs
- `rollback [sha]` - Rollback to previous version

**Root** (`/*`):
- `test-pr-docker [PR]` - Test PR Docker workflow
- `audit-deps` - Dependency audit
- `search-pattern <pattern>` - Search codebase

## Configuration

### settings.json

Copy and customize `settings.json` for your project:

```json
{
  "context": {
    "includePatterns": ["**/*.md", "**/*.ts", "**/*.tsx"],
    "excludePatterns": ["node_modules/**", ".git/**", "dist/**"]
  }
}
```

### Environment Variables

Set these in your environment or `.env` file:

```bash
# Linear ticket prefix
TICKET_PREFIX=WOR

# Project name
PROJECT_NAME=myproject

# Main branch
MAIN_BRANCH=main
```

## Customization

### Adding New Skills

Create a new directory under `skills/` with a `SKILL.md` file:

```markdown
---
name: my-skill
description: Description of when this skill should activate
---

# My Skill

Content here...
```

### Adding New Commands

Create a `.toml` file under `commands/`:

```toml
description = "What this command does"

prompt = """
Your prompt here.

Use {{args}} for user input.
Use !{command} for shell execution.
Use @{file} for file injection.
"""
```

## Relationship to Claude Code

This `.gemini/` directory works alongside `.claude/` for teams using both tools:

| Feature | Claude Code | Gemini CLI |
|---------|-------------|------------|
| Skills | `.claude/skills/SKILL.md` | `.gemini/skills/SKILL.md` |
| Commands | `.claude/commands/*.md` (YAML) | `.gemini/commands/*.toml` (TOML) |
| Agents | `.claude/agents/` | Skills (no discrete agents) |
| Hooks | `hooks-config.json` | Not supported |
| System Instructions | `CLAUDE.md` | `GEMINI.md` |

Both tools can coexist in the same repository.

## License

MIT License - See [LICENSE](../LICENSE) for details.

Copyright (c) 2024-2025 J. Scott Graham / Bybren LLC
