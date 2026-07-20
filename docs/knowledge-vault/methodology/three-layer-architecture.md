---
type: architecture
title: "Three-Layer Architecture (Hooks, Commands, Skills)"
description: "Layered harness model: hooks are automatic guardrails, commands are user-invoked workflows, skills are model-invoked expertise."
tags: [methodology, hooks, commands, skills, workflow]
timestamp: 2026-07-20
status: active
domain: methodology
sources:
  - "README.md"
  - "AGENTS.md"
  - "CLAUDE.md"
  - ".claude/hooks-config.json"
  - ".claude/README.md"
  - "docs/guides/SKILL_AUTHORING_GUIDE.md"
  - "docs/guides/GEMINI_CLI_AUTHORING_GUIDE.md"
  - "docs/whitepapers/CLAUDE-CODE-HARNESS-AGENT-PERSPECTIVE.md"
verified_against: "a79c2bd"
---

# Three-Layer Architecture (Hooks, Commands, Skills)

The harness sorts everything it ships by *who invokes it*: hooks fire automatically, commands are
typed by a person, skills are chosen by the model. The harness's own whitepapers call this "process
as service, not control"; README separately credits the layering to Anthropic's harnesses paper.

## Overview

The layering exists so guardrails cannot be forgotten, workflows stay discoverable, and expertise
loads only when relevant. On disk it is uneven — layer 1 is thin and advisory. Two discrepancies
matter. README's Includes bullet says 18 model-invoked skills while its badge, research table,
structure block, and the directory all say 20 — 20 is correct. And `.claude/hooks-config.json` blocks
pushes to `main` while the workflow rebases onto `{{PRIMARY_DEV_BRANCH}}`; the hook wins.

## Design

| Layer | Invoked by | On disk |
| --- | --- | --- |
| 1 — Hooks | The harness, automatically | `.claude/hooks-config.json`, 5 wired events |
| 2 — Commands | The user, explicitly | 24 command files |
| 3 — Skills | The model, when relevant | 20 skill directories |

- **Layer 1 is thin.** The five wired events (`UserPromptSubmit`, `PreToolUse`, `PostToolUse`,
  `SessionStart`, `SessionEnd`) are inline shell one-liners. Only the `PreToolUse` git-push hooks
  exit non-zero, blocking pushes on `main` and on a dirty worktree; the rest are advisory echoes,
  and the three scripts under `.claude/hooks/` match no event.
- **Roles sit beside the layers.** 11 roles in `.claude/agents/`; 18 Cursor rules, 30 Gemini cmds.
- **Open question.** `hooks-config.json` is not `settings.json` and no in-repo file merges them;
  which file Claude Code reads hooks from in an adopting project is stated nowhere.

## Related Concepts

- [Claude Code Provider](../providers/claude-code.md) — the reference implementation of all layers.
- [Agent Providers](../providers/agent-providers.md) — how the layering ports across tools.

## Citations

- [SKILL_AUTHORING_GUIDE.md](../../guides/SKILL_AUTHORING_GUIDE.md) — authoring rules for layer 3.
