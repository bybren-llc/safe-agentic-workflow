---
type: provider
title: "Claude Code Provider Surface"
description: "The .claude/ surface: 11 agent prompts, 24 slash commands, 20 skills, inline hooks-config.json, settings template."
tags: [providers, agents, skills, commands, hooks]
timestamp: 2026-07-19
status: active
domain: providers
resource: ".claude"
sources:
  - ".claude/README.md"
  - ".claude/hooks-config.json"
  - ".claude/team-config.json"
  - ".harness-manifest.yml"
verified_against: "fd0fc6a"
---

# Claude Code Provider Surface

The primary provider surface, and the one every other surface is mirrored from. Editing here is
the only edit that changes agent behaviour without a sync step first.

## Overview

Agents, commands, and skills are markdown with YAML frontmatter; three JSON files carry config.
`hooks-config.json` wires `UserPromptSubmit`, `PreToolUse` (git commit, git push, `gh pr create`),
`PostToolUse` (`Write|Edit`), `SessionStart`, and `SessionEnd` — all inline shell one-liners that
reference none of the three scripts in `.claude/hooks/`. Installation is a manual paste into the
settings UI, so this wiring awaits a step nobody has performed.

## Surface Layout

- `agents/` — 11 SAFe role prompts plus a README; source of truth for role behaviour.
- `commands/` — 24 slash commands; `skills/` — 20 packages, each with a README companion.
- `hooks/` — 3 scripts, none wired; the three JSON files hold wiring, settings, and team model.
- `SETUP.md`, `TROUBLESHOOTING.md`, `AGENT_OUTPUT_GUIDE.md` — operator documentation.

## Capabilities Exposed

- Unique here — slash commands, per-role subagent files, and the `team-coordination` skill.
- Git guardrails — the push hook exits 1 on branch `main` and on a dirty worktree; behind-main is
  warn-only, ending in `|| true`.
- Format-on-write — `PostToolUse` shells `npx prettier --write` then `npx markdownlint-cli`, parsing
  the path with `grep -oP`: a GNU-only lookbehind that fails on BSD and macOS grep.

## Sync & Parity

- Skills — mirrored to [Portable .agents Skills Surface](agents-portable.md) and `.gemini/skills/`;
  this surface is the first entry in [Sync Scope](../sync/sync-scope.md).
- Prompts — mirrored to [Codex CLI Provider Surface](codex.md) and to the stale
  [agent_providers Legacy Mirror](agent-providers.md).
- Drift, all of it in `.claude/README.md` — two hook scripts claimed as wired (neither is, one is
  absent), a missing `.cursor/rules/06-team-culture.mdc` cited as canonical, 23 commands tabled
  against 24, skills called "coming soon" at line 3 but indexed at line 246. Trust disk.

## Citations

- [.claude/README.md](../../../.claude/README.md) — the surface's own guide, drift included.
