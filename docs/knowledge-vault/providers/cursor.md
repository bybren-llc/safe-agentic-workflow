---
type: provider
title: "Cursor IDE Provider Surface"
description: "The .cursor/ surface: 18 .mdc rule files across four numbering families plus a placeholder mcp.json."
tags: [providers, patterns, workflow]
timestamp: 2026-07-20
status: active
domain: providers
resource: ".cursor"
sources:
  - ".cursor/rules/README.md"
  - ".cursor/mcp.json"
  - ".cursor/rules"
  - ".harness-manifest.yml"
verified_against: "c4f9d6d"
---

# Cursor IDE Provider Surface

Cursor reads `.cursor/` for everything. It carries no skills, no commands, and no agents directory,
so its 18 `.mdc` rule files serve all three roles. The rules summarize and point at the Claude
surface for canonical definitions, making this a mirrored surface rather than a primary one.

## Overview

The dialect is `.mdc` — markdown plus YAML frontmatter selecting one of three activation modes.
`alwaysApply: true` loads into every conversation; a `globs` key auto-attaches on matching open or
edited files; `alwaysApply: false` with no globs means manual `@rule-name` invocation. Counted from
frontmatter: 3 always-apply, 15 set false, 7 of those with globs. Without it, Cursor has no context.

## Surface Layout

- `.cursor/rules/` — 18 `.mdc` files plus a README indexing them and stating design principles.
- Four families — [Core](rules/core.md) 00-02 always-on, [Methodology](rules/methodology.md) 03-04
  manual, [Stack](rules/stack.md) 10-16 glob-attached, [Agent & Background](rules/agent-and-background.md) 20-31.
- `.cursor/mcp.json` — two MCP servers keyed by `{{MCP_LINEAR_SERVER}}` and
  `{{MCP_CONFLUENCE_SERVER}}`, run via `npx`, naming `LINEAR_API_KEY` and three Atlassian keys.

## Capabilities Exposed

- Background agents in isolated Ubuntu VMs — Cursor-only across the four provider surfaces.
- Glob-based auto-attach — rules that load themselves from the file being edited.
- `@rule-name` manual invocation; deliberately absent are skills, commands, and agent files.

## Sync & Parity

- `.cursor/` is listed in the `sync_scope` of `.harness-manifest.yml`, so it travels with forks.
- Rules 20-23 restate four SAFe roles held as discrete files in `.claude/agents/` and
  `.codex/agents/`; 03 and 04 restate the `safe-ai-dlc` and `vault-sync` skills.
- Secret handling diverges from Codex: `mcp.json` inlines dummy secret values in `env` while
  `.codex/config.toml` names variables only, so Cursor needs a tracked file edited to work.
- DOC DRIFT: the README calls Cursor "one of four supported AI providers", then lists Augment as a
  fifth. UNKNOWN: whether Cursor accepts unresolved `{{...}}` server-name keys or errors — no
  substitution step is wired inside this surface.

## Citations

- [.cursor rules README](../../../.cursor/rules/README.md) — the rule index and design principles.
