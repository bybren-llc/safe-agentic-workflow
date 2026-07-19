---
type: guide
title: "Augment Rule: Project Guidelines"
description: "The larger of the two populated Augment rules: SAFe Essentials project context and development guidelines."
tags: [providers, methodology, process]
timestamp: 2026-07-19
status: active
domain: providers
sources:
  - "agent_providers/augment/rules/project-guidelines.md"
  - "agent_providers/augment/AUGMENT_WORKFLOW_GUIDE.md"
  - "agent_providers/augment/instructions.md"
verified_against: "fd0fc6a"
---

# Augment Rule: Project Guidelines

The largest file under `agent_providers/augment/rules/` at 229 lines, and one of only two of the
six rules that contain anything. Plain markdown, no frontmatter, two sections: Purpose and Context.

## What It Declares

Its stated purpose is to define project-specific guidelines for development using SAFe Essentials
methodology alongside Augment Code integration. The companion `instructions.md` supplies the
operational half — Core Principles, Agent Roles, Pattern Discovery, Spec-Driven Implementation,
Quality Validation, Security, Communication Protocols, Success Criteria, Tools and Commands, and
Continuous Improvement — so the pair mirror what
[CLAUDE.md](../../knowledge/root-docs/claude-md.md) and
[AGENTS.md](../../knowledge/root-docs/agents.md) do on the Claude path. Its discovery block names
`patterns_library/`, matching
[Pattern Discovery Protocol](../../methodology/pattern-discovery-protocol.md). It prescribes
label-based assignment: an *Auggie* label routes architecture, *Claude Code* routes build.

## Why To Be Careful With It

This file is not project-neutral, and the template treats neutrality as a property. It names a
concrete stack rather than placeholders: Next.js 15 with TypeScript and Shadcn UI, self-hosted
PostgreSQL on Coolify.io with Prisma ORM, self-hosted Redis, Clerk auth, Coolify.io PaaS on a
Hostinger VPS KVM 4, PostHog analytics, Redis rate limiting. Named vendors and a specific VPS tier
survive template instantiation untouched, unlike `.claude/team-config.json` — the failure mode
[Domain Adaptation](../../methodology/domain-adaptation.md) exists to prevent.

That stack agrees with root `CLAUDE.md` and the [RLS Patterns](../../skills/rls-patterns.md) skill
but contradicts Cursor rules 10-16, targeting FastAPI — see [Stack Rules](../rules/stack.md).

**Placeholder mismatch.** It uses `__CONFLUENCE_SPACE_KEY__` at three sites while every other
surface uses `{{PLACEHOLDER}}` braces, so brace substitution leaves the token unresolved.

**Doc drift.** It hard-codes yarn literals (`yarn dev`, `yarn build`, `yarn ci:validate`) where
root `CLAUDE.md` parameterizes them as `{{DEV_COMMAND}}` and friends. This file predates that.

Nothing maintains this automatically: `agent_providers/` is absent from `sync_scope` — see
[agent_providers Legacy Mirror](../agent-providers.md).

## Citations

- [project-guidelines.md](../../../../agent_providers/augment/rules/project-guidelines.md) — it.
- [Augment instructions.md](../../../../agent_providers/augment/instructions.md) — the companion.
