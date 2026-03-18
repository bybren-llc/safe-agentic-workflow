# Cursor Rules for SAFe Agentic Workflow

This directory contains `.mdc` rule files that translate the SAFe harness methodology into Cursor IDE's native rule format. Cursor is one of four supported AI providers in this harness, alongside Claude Code, Gemini CLI, and Codex CLI.

## How Cursor Rules Work

Cursor uses `.cursor/rules/*.mdc` files with YAML frontmatter to provide context-aware instructions to the AI assistant. There are three activation modes:

| Mode          | Frontmatter                     | When Active                              |
|---------------|---------------------------------|------------------------------------------|
| Always Apply  | `alwaysApply: true`             | Active in every conversation             |
| Auto-Attached | `globs: "pattern"`              | Active when matching files are open/edited|
| Manual        | `alwaysApply: false`, no globs  | Active when referenced with `@rule-name` |

## Rule Index

### Always-Apply Core (active in every conversation)

| File                        | Purpose                                           |
|-----------------------------|---------------------------------------------------|
| `00-core-principles.mdc`   | SAFe methodology, round-table philosophy, evidence-based delivery |
| `01-git-workflow.mdc`       | Branch naming, commit format, rebase-first, PR process |
| `02-pattern-discovery.mdc`  | MANDATORY pattern discovery before implementing anything |

### Auto-Attached Tech Rules (active when matching files are open)

| File                     | Globs                                      | Purpose                                |
|--------------------------|--------------------------------------------|----------------------------------------|
| `10-backend-python.mdc`  | `core/**/*.py, edgekit/**/*.py`            | FastAPI, SQLAlchemy, async, Alembic    |
| `11-frontend-react.mdc`  | `sdk/**/*.tsx, sdk/**/*.ts`                | React 18, Electron, ShadCN, Tailwind  |
| `12-database-sql.mdc`    | `alembic/**, **/models.py, **/schemas.py`  | PostgreSQL 16, migrations, RLS         |
| `13-testing.mdc`          | `tests/**/*.py, tests/**`                  | pytest, integration, E2E Docker        |
| `14-spec-creation.mdc`   | `specs/**/*.md, specs_templates/**/*.md`    | Spec templates, AC/DoD, pattern refs   |
| `15-deployment.mdc`       | `docker-compose*.yml, Dockerfile*, scripts/deploy*` | Deploy procedures, Coolify, Docker |
| `16-stripe-payments.mdc`  | `core/**/billing/**, core/**/payments/**`   | Stripe webhooks, checkout, idempotency |

### Agent-Role Rules (manual, use `@rule-name` to activate)

| File                       | Purpose                                           |
|----------------------------|---------------------------------------------------|
| `20-agent-architect.mdc`   | System Architect: pattern validation, Stage 1 review, ADRs |
| `21-agent-backend.mdc`     | BE Developer: API implementation, RLS enforcement  |
| `22-agent-qas.mdc`         | QAS: independent gate, acceptance criteria verification |
| `23-agent-security.mdc`    | SecEng: OWASP, RLS validation, vulnerability scanning |

### Advanced Features (manual, use `@rule-name` to activate)

| File                          | Purpose                                           |
|-------------------------------|---------------------------------------------------|
| `30-background-agents.mdc`   | Guidelines for Cursor background agents running in isolated VMs |
| `31-mcp-integration.mdc`     | MCP server configuration guidance for external service integration |

## MCP Server Configuration

Cursor supports project-level MCP server configuration via `.cursor/mcp.json`. This harness includes a pre-configured MCP config with placeholder tokens for Linear and Confluence integration.

**Config file**: `.cursor/mcp.json`

To activate:

1. Open `.cursor/mcp.json`
2. Replace `{{MCP_LINEAR_SERVER}}` with your preferred server name (e.g., `linear`)
3. Replace `{{MCP_CONFLUENCE_SERVER}}` with your preferred server name (e.g., `confluence`)
4. Set environment variable values (API keys, tokens, URLs)
5. Cursor auto-detects the config -- servers appear in Settings > Features > MCP Servers

**Security**: Never commit real API keys. Use environment variables or Cursor's settings UI for secrets. The `.cursor/mcp.json` file uses placeholder values that must be replaced per-project.

See `31-mcp-integration.mdc` for detailed MCP usage guidance across SAFe agent roles.

## Background Agent Support

Cursor Background Agents can run long tasks autonomously in isolated Ubuntu VMs. They clone the repo, work on a branch, and open PRs. This harness includes guidelines for using background agents within the SAFe workflow:

- Activate the rule with `@30-background-agents` for guidance
- Background agents follow the same SAFe gate chain (Stop-the-Line, QAS, 3-stage review)
- Assign one ticket per agent for clear scope
- PRs created by background agents still require QAS validation and HITL merge

See `30-background-agents.mdc` for full details.

## MCP Integration

Cursor supports the Model Context Protocol (MCP) natively. Configure MCP servers in `.cursor/mcp.json` or via Cursor settings to enable agents to interact with Linear, Confluence, GitHub, and other services.

- Activate the rule with `@31-mcp-integration` for configuration guidance
- MCP servers are interchangeable across all four supported providers

See `31-mcp-integration.mdc` for configuration examples.

## Usage

### Always-Apply Rules

These load automatically. No action needed. They ensure every conversation respects SAFe principles, git workflow standards, and the pattern discovery protocol.

### Auto-Attached Rules

These activate when you open or edit files matching their glob pattern. For example, editing `core/gateway/router.py` will automatically load `10-backend-python.mdc`.

### Agent-Role Rules

Reference these manually when you want Cursor to adopt a specific SAFe agent persona:

```
@20-agent-architect Review this PR for pattern compliance
@21-agent-backend Implement the API endpoint from spec REN-123
@22-agent-qas Validate acceptance criteria for this feature
@23-agent-security Audit RLS policies for this new table
```

### Advanced Feature Rules

Reference these when working with background agents or MCP:

```
@30-background-agents Set up a background agent for {{TICKET_PREFIX}}-42
@31-mcp-integration Configure Linear MCP for ticket management
```

## Design Principles

1. **DRY**: Rules reference existing docs (CLAUDE.md, AGENTS.md, patterns_library/) rather than duplicating content
2. **Concise**: Each rule stays under 200 lines to respect Cursor's context limits
3. **Template-Ready**: Uses `{{TICKET_PREFIX}}`, `{{MAIN_BRANCH}}`, and other placeholders for project customization
4. **Hierarchical**: Numbering (00-02, 10-16, 20-23, 30-31) groups rules by activation type

## Relationship to Other Configurations

This harness supports four AI providers. All share the same SAFe methodology and reference the same source docs:

| Tool        | Config Location                    | Purpose                         |
|-------------|------------------------------------|---------------------------------|
| Claude Code | `.claude/` (agents, skills, commands, hooks) | Primary provider -- full harness    |
| Gemini CLI  | `.gemini/` (commands, skills, settings) | Secondary provider -- TOML commands |
| Codex CLI   | `.codex/config.toml` + `.agents/skills/` | TOML config, reads AGENTS.md, MCP native |
| Cursor IDE  | `.cursor/rules/` (this directory)  | .mdc rules, background agents, MCP |
| Augment     | `agent_providers/augment/rules/`   | Augment Code rules              |

All configurations reference the same source docs (CLAUDE.md, AGENTS.md, CONTRIBUTING.md, patterns_library/) to maintain consistency.
