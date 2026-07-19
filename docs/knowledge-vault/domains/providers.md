---
type: domain
title: "Providers Domain"
description: "The five AI-tool surfaces the harness ships to, what each expresses natively, and where parity breaks."
tags: [providers, agents, skills, commands, hooks]
timestamp: 2026-07-19
status: active
domain: providers
verified_against: "fd0fc6a"
---

# Providers Domain

One methodology, five directories: this domain is the translation layer, and translation is lossy.

## Overview

Owns the per-tool surfaces — `.claude/`, `.gemini/`, `.codex/`, `.cursor/`, `.agents/` — plus the
authoring guides that say how to write into them and the legacy `agent_providers/` mirror. It owns
*shape*: file format, discovery rules, activation modes, hook wiring — not the content those files
encode ([Methodology](methodology.md)) nor the machinery that copies upstream changes into them
([Sync](sync.md)). Parity is the central problem: every surface claims the same eleven roles and
twenty skills, and no two copies are byte-identical.

## Members

- [Claude Code](../providers/claude-code.md) — de facto source of truth: 11 agents, 24 commands,
  20 skills, the only surface with discrete subagent files.
- [Gemini CLI](../providers/gemini-cli.md) — 19 skills, 30 TOML commands, and a `media/` namespace
  of multimodal commands that exists on no other surface.
- [Codex CLI](../providers/codex.md) — 11 agent TOMLs; no skills of its own, it resolves
  [.agents](../providers/agents-portable.md).
- [Cursor](../providers/cursor.md) — 18 `.mdc` rules serving as agents, commands and skills at once.
- [agent_providers mirror](../providers/agent-providers.md) — the pre-dotfile copy, now diverged.
- The [RLS validation hook](../providers/hooks/pre-bash-rls-validation.md) — a script no matcher wires.
- Authoring contracts: [Skill Authoring Guide](../knowledge/guides/skill-authoring-guide.md), its
  [Gemini counterpart](../knowledge/guides/gemini-cli-authoring-guide.md), and
  [CLAUDE.md](../knowledge/root-docs/claude-md.md), loaded unasked into every Claude session.

## Key Flows

**Adding a skill.** Author it under `.claude/skills/<name>/SKILL.md` per the Skill Authoring Guide,
then mirror by hand into `.gemini/skills/` and `.agents/skills/` — the latter is how Codex gets it,
discovering `.agents/skills` at CWD, parent, repo root, `$HOME`. Cursor restates it as a rule.

**A role reaching an agent.** `.claude/agents/<role>.md` is authoritative; the Codex TOML and the
`agent_providers` prompt restate it. All eleven Claude prompts declare `model: opus` though docs
still describe an Opus-plans / Sonnet-executes split; worse, the mirror's `be-developer` sets
`model: sonnet` and drops Stop-the-Line entirely, silently weakening a gate.

**Staying in step.** Five of the six domains in the manifest's `sync_scope` are provider surfaces, so
upstream parity work arrives via [Sync](sync.md); anything outside it moves only by hand.

## Citations

- [AGENTS.md](../../../AGENTS.md) — the role roster every surface restates.
- [SKILL_AUTHORING_GUIDE.md](../../guides/SKILL_AUTHORING_GUIDE.md) — Claude-side authoring contract.
- [GEMINI_CLI_AUTHORING_GUIDE.md](../../guides/GEMINI_CLI_AUTHORING_GUIDE.md) — Gemini counterpart.
