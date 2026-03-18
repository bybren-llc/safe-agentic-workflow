---
description: "MCP (Model Context Protocol) server configuration guidance for Cursor IDE."
alwaysApply: false
---

# MCP Integration Guidelines

Cursor supports the [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) natively. MCP servers provide additional tools and context to AI sessions, enabling interaction with external services.

## Configuring MCP Servers in Cursor

MCP servers are configured in Cursor's settings. Navigate to:

**Settings > Features > MCP Servers**

Or add them to your project-level `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "linear": {
      "command": "npx",
      "args": ["-y", "@linear/mcp-server"],
      "env": {
        "LINEAR_API_KEY": "your-api-key"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/project"]
    }
  }
}
```

## Common MCP Servers for SAFe Workflow

| MCP Server | Purpose | When to Use |
|------------|---------|-------------|
| Linear | Ticket management, comments, status updates | All workflow (TDM, QAS, RTE agents) |
| Confluence | Documentation publishing | Tech Writer agent, BSA specs |
| GitHub | PR management, issue tracking | RTE agent, code review |
| Filesystem | Extended file access | Background agents needing broad access |
| PostgreSQL | Direct database queries | Data Engineer agent |

## SAFe Agent MCP Usage

Different agent roles use different MCP capabilities:

- **TDM**: Linear MCP for ticket coordination and status updates
- **QAS**: Linear MCP for posting validation evidence as comments
- **RTE**: GitHub MCP for PR creation and CI monitoring
- **Tech Writer**: Confluence MCP for publishing documentation
- **BSA**: Linear MCP for creating tickets, Confluence MCP for specs

## Security Considerations

- Never commit API keys or tokens to the repository
- Use environment variables for MCP server credentials
- Review MCP server permissions before granting access
- Prefer read-only access where write access is not needed
- MCP servers in background agents use the repository-level config only

## Cross-Provider MCP Compatibility

MCP servers configured for Cursor also work with other providers in this harness:

| Provider | MCP Config Location |
|----------|---------------------|
| Claude Code | `.claude/settings.local.json` (mcpServers key) |
| Gemini CLI | `.gemini/settings.json` (mcpServers key) |
| Codex CLI | Native MCP support via `codex --mcp-server` flag |
| Cursor IDE | `.cursor/mcp.json` or Cursor settings UI |

All providers use the same MCP protocol, so servers are interchangeable. Configure once, describe in your project docs, and each provider picks up its own config.
