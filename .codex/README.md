# Codex CLI Configuration

This directory contains the configuration for [OpenAI Codex CLI](https://github.com/openai/codex), OpenAI's AI-powered command-line tool for software development.

## Quick Start

1. **Install Codex CLI**
   ```bash
   npm install -g @openai/codex
   ```

2. **Authenticate**
   ```bash
   # Set your OpenAI API key
   export OPENAI_API_KEY="your-api-key"
   ```

3. **Run Codex in your project**
   ```bash
   cd your-project
   codex
   ```

Codex CLI automatically detects `CODEX.md` in the project root for system instructions.

## Directory Structure

```
.codex/
├── README.md           # This file - setup guide
├── settings.json       # Configuration template
├── commands/           # Instruction files for common workflows
│   ├── start-work.md   # Start work on Linear ticket
│   ├── pre-pr.md       # Pre-PR validation checklist
│   ├── end-work.md     # Complete work session
│   ├── search-pattern.md # Search codebase for patterns
│   └── check-workflow.md # Quick workflow health check
└── skills/             # Contextual knowledge packs
    ├── safe-workflow/
    │   ├── README.md
    │   └── SKILL.md
    ├── pattern-discovery/
    │   ├── README.md
    │   └── SKILL.md
    └── testing-patterns/
        ├── README.md
        └── SKILL.md
```

## Using Commands

Codex CLI commands are markdown instruction files. Pass them via the `--instructions` flag:

```bash
# Start work on a ticket
codex --instructions .codex/commands/start-work.md "Start work on TICKET-123"

# Run pre-PR validation
codex --instructions .codex/commands/pre-pr.md

# End work session
codex --instructions .codex/commands/end-work.md

# Search for patterns
codex --instructions .codex/commands/search-pattern.md "withUserContext"

# Check workflow status
codex --instructions .codex/commands/check-workflow.md
```

You can also reference CODEX.md as the base instructions for any session:

```bash
codex --instructions CODEX.md "Implement the user profile API"
```

### Command Reference

| Command | Purpose | Usage |
|---------|---------|-------|
| `start-work.md` | Begin work on Linear ticket | `codex --instructions .codex/commands/start-work.md` |
| `pre-pr.md` | Run validation before PR | `codex --instructions .codex/commands/pre-pr.md` |
| `end-work.md` | Complete work session | `codex --instructions .codex/commands/end-work.md` |
| `search-pattern.md` | Search code patterns | `codex --instructions .codex/commands/search-pattern.md "pattern"` |
| `check-workflow.md` | Check workflow status | `codex --instructions .codex/commands/check-workflow.md` |

## Using Skills

Skills provide deep contextual knowledge on specific topics. Load them as instructions when working in a specific area:

```bash
# When working on git workflow
codex --instructions .codex/skills/safe-workflow/SKILL.md "Create a feature branch for TICKET-123"

# When implementing a new feature (pattern-first)
codex --instructions .codex/skills/pattern-discovery/SKILL.md "Build a new API endpoint"

# When writing tests
codex --instructions .codex/skills/testing-patterns/SKILL.md "Write tests for the user service"
```

### Skills Reference

| Skill | Description | When to Use |
|-------|-------------|-------------|
| `safe-workflow` | Branch naming, commits, PR workflow | Starting work, commits, PRs |
| `pattern-discovery` | Pattern library discovery | Before implementing features |
| `testing-patterns` | Jest and Playwright patterns | Writing tests |

## Configuration

### settings.json

The `settings.json` file contains project-level configuration:

```json
{
  "model": "o4-mini",
  "approval_mode": "suggest",
  "sandbox": {
    "enable": true,
    "permissions": {
      "read": [".", "~/.gitconfig"],
      "write": ["."],
      "net": false
    }
  },
  "instructions": "CODEX.md"
}
```

#### Key Settings

| Setting | Description | Default |
|---------|-------------|---------|
| `model` | OpenAI model to use | `o4-mini` |
| `approval_mode` | `suggest`, `auto-edit`, or `full-auto` | `suggest` |
| `sandbox.enable` | Enable sandboxed execution | `true` |
| `sandbox.permissions.net` | Allow network access | `false` |
| `instructions` | Path to system instructions file | `CODEX.md` |
| `notify` | Desktop notifications on completion | `true` |

#### Approval Modes

| Mode | Behavior |
|------|----------|
| `suggest` | Codex suggests changes, you approve each one |
| `auto-edit` | Codex auto-applies file edits, asks before commands |
| `full-auto` | Codex runs autonomously within sandbox constraints |

### Environment Variables

Set these in your environment or `.env` file:

```bash
# Required
export OPENAI_API_KEY="your-api-key"

# Optional - project-specific
export TICKET_PREFIX=WOR
export PROJECT_NAME=myproject
export MAIN_BRANCH=main
```

## Combining Instructions

You can combine the base CODEX.md with specific commands:

```bash
# Use CODEX.md as base context, then run a specific command
codex --instructions CODEX.md --instructions .codex/commands/start-work.md "Start TICKET-123"
```

## Relationship to Other AI Tool Configs

This `.codex/` directory works alongside `.claude/` and `.gemini/` for teams using multiple AI tools:

| Feature | Codex CLI | Claude Code | Gemini CLI |
|---------|-----------|-------------|------------|
| System Instructions | `CODEX.md` | `CLAUDE.md` | `GEMINI.md` |
| Settings | `.codex/settings.json` | `.claude/settings.local.json` | `.gemini/settings.json` |
| Commands | `.codex/commands/*.md` | `.claude/commands/*.md` | `.gemini/commands/*.toml` |
| Skills | `.codex/skills/*/SKILL.md` | `.claude/skills/*/SKILL.md` | `.gemini/skills/*/SKILL.md` |
| Agents | N/A | `.claude/agents/` | N/A (skills) |
| Hooks | N/A | `.claude/hooks-config.json` | `settings.json` hooks |
| MCP Servers | N/A | `settings.local.json` | `settings.json` mcpServers |

All three tools can coexist in the same repository.

## Customization

### Adding New Commands

Create a new markdown file in `.codex/commands/`:

```markdown
# My Command Name

Instructions for what this command does.

## Steps

1. Step one
2. Step two

## Success Criteria

- Criteria 1
- Criteria 2
```

### Adding New Skills

Create a new directory under `.codex/skills/` with `README.md` and `SKILL.md`:

```
.codex/skills/my-skill/
├── README.md    # Quick reference and metadata
└── SKILL.md     # Full skill definition
```

## Troubleshooting

### Codex Not Finding Instructions

1. Verify `CODEX.md` exists in the project root
2. Check `settings.json` has correct `instructions` path
3. Ensure `OPENAI_API_KEY` is set in your environment

### Sandbox Permission Errors

If Codex cannot read or write files:
1. Check `sandbox.permissions` in `settings.json`
2. Ensure the project directory is listed in `read` and `write` arrays
3. For network access (API calls, etc.), set `net: true` (use with caution)

### Model Selection

To use a different model:
```bash
# Via command line
codex --model o3

# Or update settings.json
# "model": "o3"
```

## License

MIT License - See [LICENSE](../LICENSE) for details.

Copyright (c) 2024-2026 J. Scott Graham (@cheddarfox) / ByBren, LLC
