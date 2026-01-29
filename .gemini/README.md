# Gemini CLI Configuration

This directory contains the configuration for [Gemini CLI](https://geminicli.com/), Google's AI-powered command-line tool.

## Quick Start

1. **Install Gemini CLI**
   ```bash
   # See https://geminicli.com/docs/get-started/installation/
   npm install -g @google/gemini-cli
   ```

2. **Authenticate**
   ```bash
   # Option 1: API Key (recommended for quick start)
   export GEMINI_API_KEY="your-api-key"

   # Option 2: Google Cloud ADC (for GCP users)
   gcloud auth application-default login
   ```
   See https://geminicli.com/docs/get-started/authentication/ for details.

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

**Media** (`/media:*`) - Multimodal Commands:
- `analyze-images <dir>` - Analyze and describe images using vision
- `extract-pdf <file>` - Extract structured data from PDFs
- `sketch-to-code <image>` - Generate code from UI sketches/wireframes
- `organize-files <dir>` - Organize files based on content analysis

## Multimodal Capabilities

Gemini CLI supports multimodal input for images, audio, and documents.

### Supported Formats

| Category | Formats | Max Size |
|----------|---------|----------|
| **Images** | PNG, JPG, GIF, WEBP, SVG, BMP | 100MB (Gemini 3) |
| **Audio** | MP3, WAV, AIFF, AAC, OGG, FLAC | 100MB (Gemini 3) |
| **Documents** | PDF | 100MB (Gemini 3) |

### Using Multimodal in Commands

Inject files into prompts with `@{path}`:

```toml
prompt = """
Analyze this image:
@{./screenshot.png}

Describe what you see.
"""
```

### Example Use Cases

```bash
# Analyze images in a folder
/media:analyze-images ./screenshots

# Extract invoice data to CSV
/media:extract-pdf ./invoice.pdf

# Generate React component from sketch
/media:sketch-to-code ./wireframe.png

# Organize messy downloads folder
/media:organize-files ~/Downloads
```

See [Gemini CLI Authoring Guide](../docs/guides/GEMINI_CLI_AUTHORING_GUIDE.md) for creating custom multimodal commands.

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

## Built-in Tools

Gemini CLI includes built-in tools (no configuration required):

| Tool Category | Capabilities |
|---------------|--------------|
| **File operations** | Read, write, search, edit, list directories |
| **Shell execution** | Run arbitrary commands |
| **Web interaction** | Fetch URLs, web search |
| **Memory** | AI memory system for context persistence |

These are accessed automatically through commands using `!{command}` and `@{file}` syntax.

See [Gemini CLI Tools API](https://geminicli.com/docs/core/tools-api/) for architecture details.

## Hooks

Gemini CLI supports hooks for intercepting and customizing behavior at key lifecycle points.

### Enabling Hooks

Add to your `settings.json`:

```json
{
  "tools": { "enableHooks": true },
  "hooks": { "enabled": true }
}
```

### Hook Events

| Event | Trigger Point | Use Cases |
|-------|---------------|-----------|
| `SessionStart` | Session begins | Initialize resources, load context |
| `SessionEnd` | Session ends | Clean up, save state |
| `BeforeAgent` | After prompt, before planning | Add context, validate input |
| `AfterAgent` | Agent loop completes | Review output, force continuation |
| `BeforeModel` | Before LLM request | Modify prompts, add instructions |
| `AfterModel` | After LLM response | Filter responses, log interactions |
| `BeforeToolSelection` | Before tool filtering | Restrict available tools |
| `BeforeTool` | Before tool execution | Validate arguments, block operations |
| `AfterTool` | After tool execution | Process results, run tests |
| `PreCompress` | Before context compression | Save state, notify user |
| `Notification` | Permission events occur | Auto-approve decisions |

### Migrating from Claude Code

Gemini CLI can migrate Claude Code hooks:

```bash
gemini hooks migrate --from-claude
```

### Hook Management

```bash
/hooks panel           # View all registered hooks
/hooks enable-all      # Enable all hooks
/hooks disable-all     # Disable all hooks
```

See [Gemini CLI Hooks Documentation](https://geminicli.com/docs/hooks/) for complete details.

## MCP Servers

Gemini CLI supports Model Context Protocol (MCP) servers for external integrations.

### Configuration

Add MCP servers to `settings.json`:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "python",
      "args": ["mcp_server.py", "--port", "8080"],
      "env": {
        "API_KEY": "$MY_API_KEY"
      },
      "cwd": "./servers",
      "timeout": 30000,
      "trust": false
    }
  }
}
```

Supports stdio, SSE, and HTTP transports. See docs for transport options.

### MCP Server Commands

```bash
gemini mcp add <name> <command>   # Add server
gemini mcp list                   # View servers
gemini mcp remove <name>          # Remove server
```

See [Gemini CLI MCP Documentation](https://geminicli.com/docs/tools/mcp-server/) for details.

## Google Services Integration

Gemini CLI provides native integration with Google services through OAuth authentication.

### Available Services

| Service | Capabilities |
|---------|-------------|
| **Google Drive** | List files, read/write documents, search, share |
| **Google Docs** | Create, edit, format documents |
| **Google Sheets** | Read/write spreadsheets, formulas, charts |
| **Google Calendar** | Create events, check availability, manage invites |
| **Gmail** | Read, search, compose, send emails |
| **Google Tasks** | Create, list, complete tasks |
| **YouTube** | Search videos, get transcripts, analyze content |
| **Google Maps** | Geocoding, directions, place information |

### Enabling Google Services

1. **Authenticate with Google Cloud**
   ```bash
   gcloud auth application-default login
   ```

2. **Enable required APIs** in Google Cloud Console
   - Drive API
   - Docs API
   - Sheets API
   - Calendar API
   - Gmail API

3. **Configure in settings.json** (optional scopes)
   ```json
   {
     "google": {
       "scopes": [
         "https://www.googleapis.com/auth/drive.readonly",
         "https://www.googleapis.com/auth/calendar.events"
       ]
     }
   }
   ```

### Example Use Cases

```bash
# Summarize recent Drive files
"Summarize the last 5 documents in my Drive"

# Create calendar event
"Schedule a meeting with the team for Friday at 2pm"

# Search Gmail
"Find emails from last week about the API deployment"

# Read spreadsheet data
"Show me the Q4 revenue data from the Finance spreadsheet"
```

### Security Considerations

- Google services require explicit user consent
- Credentials are stored securely using Google Cloud's credential management
- Scope permissions follow principle of least privilege
- No data is stored by Gemini CLI beyond the session

See [Google Cloud Authentication](https://cloud.google.com/docs/authentication) for setup details.

## Relationship to Claude Code

This `.gemini/` directory works alongside `.claude/` for teams using both tools:

| Feature | Claude Code | Gemini CLI |
|---------|-------------|------------|
| Skills | `.claude/skills/SKILL.md` | `.gemini/skills/SKILL.md` |
| Commands | `.claude/commands/*.md` (YAML) | `.gemini/commands/*.toml` (TOML) |
| Agents | `.claude/agents/` | Skills (no discrete agents) |
| Hooks | `.claude/hooks-config.json` | `settings.json` hooks section |
| MCP Servers | `settings.local.json` | `settings.json` mcpServers |
| System Instructions | `CLAUDE.md` | `GEMINI.md` |

Both tools can coexist in the same repository.

## License

MIT License - See [LICENSE](../LICENSE) for details.

Copyright (c) 2024-2025 {{AUTHOR_NAME}} / {{COMPANY_NAME}}
