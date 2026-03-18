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

Codex CLI automatically reads `AGENTS.md` at the project root for system instructions. It walks from the Git root to the current working directory, loading any `AGENTS.md` files it finds. **This harness already includes `AGENTS.md`** -- no additional instructions file is needed.

## How Codex Discovers Context

### System Instructions: AGENTS.md

Codex reads `AGENTS.md` (not a Codex-specific file) at the project root. This is the same `AGENTS.md` used by all agents in the SAFe harness, providing:

- Agent role definitions and responsibilities
- SAFe workflow guidance
- Pattern discovery protocol
- Documentation references

There is **no** `CODEX.md` file. If you see references to one, they are outdated.

### Configuration: .codex/config.toml

The `.codex/config.toml` file controls Codex CLI behavior:

```toml
model = "o4-mini"
approval_policy = "on-request"  # "untrusted", "on-request", "never"
sandbox_mode = "workspace-write"
web_search = "cached"           # "cached", "live", "disabled"
model_reasoning_effort = "high"
personality = "pragmatic"       # "friendly", "pragmatic", "none"

[features]
shell_snapshot = true
multi_agent = true
web_search = true

[shell_environment_policy]
include_only = ["PATH", "HOME", "OPENAI_API_KEY"]
```

#### Approval Policies

| Policy | Behavior |
|--------|----------|
| `untrusted` | Codex cannot execute commands or write files without approval |
| `on-request` | Codex can read files and run safe commands; asks before writes |
| `never` | Full autonomy within sandbox constraints (use with caution) |

### Skills: .agents/skills/

Codex discovers skills from `.agents/skills/` directories at multiple scopes:

```
.agents/skills/         # CWD (project-level)
../.agents/skills/      # Parent directory
$REPO_ROOT/.agents/skills/  # Git repository root
$HOME/.agents/skills/   # User-level (personal skills)
```

Each skill follows this structure:

```
.agents/skills/my-skill/
├── SKILL.md           # Required: YAML frontmatter (name, description) + instructions
├── scripts/           # Optional: executable scripts
├── references/        # Optional: reference documentation
└── assets/            # Optional: templates, resources
```

Skills are **shared across all agents** (not Codex-specific). The same `.agents/skills/` directory is used by any tool that supports the convention.

#### Available Skills

| Skill | Description | When to Use |
|-------|-------------|-------------|
| `safe-workflow` | Branch naming, commits, PR workflow | Starting work, commits, PRs |
| `pattern-discovery` | Pattern library discovery | Before implementing features |
| `testing-patterns` | Unit, integration, E2E patterns | Writing tests |

### MCP Support

Codex CLI supports the [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) natively. MCP servers provide additional tools and context to Codex sessions.

To configure MCP servers, add them to your Codex session:

```bash
# Example: connect to a Linear MCP server
codex --mcp-server linear

# Example: connect to a Confluence MCP server
codex --mcp-server confluence
```

MCP enables Codex to interact with external services like Linear (ticket management), Confluence (documentation), databases, and other APIs without custom scripts.

## Directory Structure

```
.codex/
├── README.md           # This file - setup guide
└── config.toml         # Codex CLI configuration (TOML format)

.agents/
└── skills/             # Shared skills (discovered by Codex and other agents)
    ├── pattern-discovery/
    │   ├── SKILL.md
    │   ├── scripts/
    │   ├── references/
    │   └── assets/
    ├── safe-workflow/
    │   ├── SKILL.md
    │   ├── scripts/
    │   ├── references/
    │   └── assets/
    └── testing-patterns/
        ├── SKILL.md
        ├── scripts/
        ├── references/
        └── assets/
```

## What Codex Does NOT Have

- **No slash commands** -- Codex uses natural language instead of `/command` syntax. If you need structured workflows, describe them in conversation or load a skill.
- **No `CODEX.md`** -- Codex reads `AGENTS.md`, which is already part of this harness.
- **No `settings.json`** -- Configuration uses TOML format at `.codex/config.toml`.
- **No `.codex/skills/`** -- Skills live in `.agents/skills/` and are shared across agents.

## Environment Variables

Set these in your environment or `.env` file:

```bash
# Required
export OPENAI_API_KEY="your-api-key"

# Optional - project-specific (used by skills via {{PLACEHOLDER}} tokens)
export TICKET_PREFIX=WOR
export PROJECT_NAME=myproject
export MAIN_BRANCH=main
```

## Relationship to Other AI Tool Configs

This `.codex/` directory works alongside `.claude/` and `.gemini/` for teams using multiple AI tools:

| Feature | Codex CLI | Claude Code | Gemini CLI |
|---------|-----------|-------------|------------|
| System Instructions | `AGENTS.md` (project root) | `CLAUDE.md` | `GEMINI.md` |
| Configuration | `.codex/config.toml` | `.claude/settings.local.json` | `.gemini/settings.json` |
| Commands | N/A (natural language) | `.claude/commands/*.md` | `.gemini/commands/*.toml` |
| Skills | `.agents/skills/*/SKILL.md` | `.claude/skills/*/SKILL.md` | `.gemini/skills/*/SKILL.md` |
| Agents | N/A | `.claude/agents/` | N/A |
| MCP Servers | Native support | `settings.local.json` | `settings.json` mcpServers |

All tools can coexist in the same repository. `AGENTS.md` is the universal file read by Codex and useful to all agents.

## Troubleshooting

### Codex Not Finding Instructions

1. Verify `AGENTS.md` exists in the project root (or a parent directory)
2. Ensure you are running Codex from within the Git repository
3. Check that `OPENAI_API_KEY` is set in your environment

### Sandbox Permission Errors

If Codex cannot read or write files:
1. Check `sandbox_mode` in `config.toml`
2. Try `sandbox_mode = "workspace-write"` for development
3. For network access, ensure relevant features are enabled in `[features]`

### Model Selection

```bash
# Via command line (overrides config.toml)
codex --model o3

# Or update config.toml
# model = "o3"
```

### Skills Not Loading

1. Verify `.agents/skills/` exists at one of the discovery scopes
2. Check that each skill has a `SKILL.md` with valid YAML frontmatter
3. Ensure the `name` and `description` fields are present in frontmatter

## License

MIT License - See [LICENSE](../LICENSE) for details.

Copyright (c) 2024-2026 J. Scott Graham (@cheddarfox) / ByBren, LLC
