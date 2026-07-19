---
type: provider
title: "Portable .agents Skills Surface"
description: "The vendor-neutral .agents/skills surface: 20 skill packages discovered by Codex and any tool honoring the convention."
tags: [providers, skills, sync]
timestamp: 2026-07-19
status: active
domain: providers
resource: ".agents"
sources:
  - ".agents/skills"
  - ".codex/README.md"
  - ".harness-manifest.yml"
verified_against: "fd0fc6a"
---

# Portable .agents Skills Surface

The one surface that belongs to no vendor. `.agents/` contains a `skills/` directory and nothing
else: no README, no config, no commands, no agent definitions.

## Overview

The dialect is the portable skill package — a required `SKILL.md` with YAML frontmatter carrying
`name` and `description`, plus optional `scripts/`, `references/`, and `assets/` directories, per
`.codex/README.md`. Activation is model-invoked from the description; there are no tool allowlists
and no slash-command bindings, which is the point. Absent this tree, Codex has no skills at all.

## Surface Layout

- 20 packages, the whole of the tree — `agent-coordination`, `api-patterns`, `confluence-docs`,
  `deployment-sop`,  `frontend-patterns`, `git-advanced`, `linear-sop`, `migration-patterns`, `orchestration-patterns`,
  `pattern-discovery`, `release-patterns`, `rls-patterns`, `safe-ai-dlc`, `safe-workflow`,
  `security-audit`, `spec-creation`, `stripe-patterns`, `team-coordination`, `testing-patterns`,
  `vault-sync`.
- Each package — `SKILL.md` plus `scripts/`, `references/`, `assets/`. All 60 of those directories
  hold only a `.gitkeep`, so `SKILL.md` is the sole content-bearing file: scaffolding, not capacity.

## Capabilities Exposed

- Vendor neutrality — no Claude-only frontmatter (`user-invocable`, `allowed-tools`), no tool
  bindings, so any provider reads it unmodified. One directory, no translation step.
- Reach — one directory any convention-honouring tool can read, with no translation step.
- Deliberately absent — helpers, reference material, assets, README companions. Dirs, no content.

## Sync & Parity

- Domain — a shared, non-provider entry in `sync_scope`; see [Sync Scope](../sync/sync-scope.md).
- Names match, content does not — the name set equals `.claude/skills/` exactly, 20 for 20, but no
  `SKILL.md` is byte-identical. See [Claude Code Provider Surface](claude-code.md).
- Shape of the difference — folded YAML (`description: >`) and much shorter bodies: `safe-workflow`
  is 106 lines here against 229 in `.claude/`. Treat them as summaries of the Claude originals.
- Consumer — [Codex CLI Provider Surface](codex.md), which resolves this path at four scopes.
- Open question — no generator is referenced anywhere, so what regenerates these files is unknown.

## Citations

- [.codex/README.md](../../../.codex/README.md) — defines the package shape and discovery order.
