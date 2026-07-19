---
type: provider
title: "Gemini CLI Provider Surface"
description: "The .gemini/ surface: GEMINI.md, settings.json, 19 skills, 30 TOML commands in four namespaces plus root."
tags: [providers, skills, commands, sync]
timestamp: 2026-07-19
status: active
domain: providers
resource: ".gemini"
sources:
  - ".gemini/README.md"
  - ".gemini/GEMINI.md"
  - ".gemini/settings.json"
  - ".gemini/commands"
  - ".gemini/skills"
  - ".harness-manifest.yml"
verified_against: "fd0fc6a"
---

# Gemini CLI Provider Surface

Gemini CLI reads `.gemini/` for instructions, settings, skills, and slash commands. It is a mirrored
surface — 19 skills copied by name from Claude's, rewritten not duplicated — and authoritative for
one thing no other surface carries: the media command namespace.

## Overview

Three dialects live here. `GEMINI.md` is plain markdown system instruction. `settings.json` is one
JSON file that also holds hook declarations, where other providers use a separate hook config.
Commands are `.toml` prompts with `{{args}}`, `!{cmd}`, `@{file}`; skills reuse Claude's shape.

## Surface Layout

- `.gemini/GEMINI.md` and `.gemini/settings.json` — session instructions and a configuration
  template whose values are placeholders; key names only appear here.
- `.gemini/skills/` — 19 skill directories plus a README, each a `SKILL.md` and `README.md`.
- `.gemini/commands/` — 30 `.toml` plus README: `workflow/` 9, `media/` 11, `remote/` 5, root 3.

## Capabilities Exposed

- Multimodal media commands — 11 of them, marked N/A for Claude Code in the README comparison.
- Plan mode, policy engine, browser agent, extensions, and checkpointing — all Gemini-only.
- Hooks declared inline in `settings.json`; `team-coordination` is the one unmirrored Claude skill.

## Sync & Parity

- `.gemini/` appears in the `sync_scope` of `.harness-manifest.yml`.
- All 19 skill bodies differ from Claude's: variants strip Claude-only frontmatter keys and emoji
  and run shorter — `safe-workflow` is 82 lines against 229. No hook fires as committed either:
  `settings.json` ships `hooks` as an empty object.
- DOC DRIFT: the README claims 29 commands (disk has 30) and tabulates 18 skills claiming 19. Its
  settings example disagrees with the committed file on `general.plan.modelRouting` (string versus
  boolean) and `general.checkpointing.enabled`, and its "Enabling Hooks" section names
  `hooks.enabled` where the file uses `hooksConfig.enabled`, so following it registers nothing.

## Citations

- [.gemini README](../../../.gemini/README.md) — the surface's inventory and comparison table.
