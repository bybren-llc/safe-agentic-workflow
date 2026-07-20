---
type: provider
title: "Codex CLI Provider Surface"
description: "The .codex/ surface: config.toml with profiles and MCP servers, 11 role TOMLs, skills delegated to .agents/skills."
tags: [providers, agents, skills, security]
timestamp: 2026-07-20
status: active
domain: providers
resource: ".codex"
sources:
  - ".codex/README.md"
  - ".codex/config.toml"
  - ".codex/agents"
  - "AGENTS.md"
  - ".harness-manifest.yml"
verified_against: "0c26121"
---

# Codex CLI Provider Surface

Codex CLI configures from `.codex/`, but the surface is deliberately thin: TOML only. System
instructions come from repo-root `AGENTS.md`, and skills are not here at all.

## Overview

`config.toml` points `project_doc_fallback_filenames` at `AGENTS.md`, `CLAUDE.md`, and
`CONTRIBUTING.md`, so the repo's root docs are the system prompt. The README is blunt about
absences: no slash commands, no `CODEX.md`, no `settings.json`, and no `.codex/skills/` directory.

## Surface Layout

- `config.toml` root — `model`, `approval_policy`, `sandbox_mode`, `web_search`, `personality`.
- `[features]` — `shell_snapshot`, `multi_agent`, `web_search`, `shell_tool`, `unified_exec`.
- `[agents]` — `max_threads`, `max_depth`, `job_max_runtime_seconds`.
- `[profiles.architect|developer|reviewer]` — per-profile `model`, `sandbox_mode`, `approval_policy`.
- `agents/` — 11 role TOMLs, `be-developer` through `tech-writer`. No skills directory exists.

## Capabilities Exposed

- Per-role security posture — `[profiles.*]` override sandbox and approval per role, so the
  reviewer runs under different permissions than the developer. The real differentiator.
- Shell allowlisting — `[shell_environment_policy]` uses `include_only`; `notify` is commented out.
- Native MCP — `[mcp_servers.{{MCP_LINEAR_SERVER}}]` and `[mcp_servers.{{MCP_CONFLUENCE_SERVER}}]`
  carry `command`, `args`, `env_vars`, and timeouts, naming `LINEAR_API_KEY` and `ATLASSIAN_*`.
- Skills by delegation — see [Portable .agents Skills Surface](agents-portable.md).

## Sync & Parity

- Role prompts — mirrored from [Claude Code Provider Surface](claude-code.md).
- Domains — `.codex/` and `.agents/` are separate [Sync Scope](../sync/sync-scope.md) entries.
- Model drift — `config.toml` pins `o4-mini` everywhere, but 9 role TOMLs set `gpt-5.4` and 2 set
  `gpt-5.4-mini`; the README documents only `o4-mini`.
- README drift — 18 shared skills claimed against 20 on disk; 3 `include_only` entries vs 19.
- Open question — whether `agents/*.toml` are auto-discovered or need `--profile` is unstated.

## Citations

- [.codex/README.md](../../../.codex/README.md) — the surface's own documentation.
