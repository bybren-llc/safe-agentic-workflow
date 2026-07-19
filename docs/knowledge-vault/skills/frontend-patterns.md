---
type: skill
title: "Skill: frontend-patterns"
description: "UI patterns for App Router server/client components, auth flows, component library and analytics events."
resource: ".claude/skills/frontend-patterns/SKILL.md"
tags: [skills, methodology, patterns]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".claude/skills/frontend-patterns/SKILL.md"
  - ".agents/skills/frontend-patterns/SKILL.md"
  - ".claude/skills/frontend-patterns/README.md"
  - ".claude/agents/fe-developer.md"
verified_against: "fd0fc6a"
---

# Skill: frontend-patterns

The UI card: where the server/client boundary falls, how a protected page is assembled, which component
library to draw from, and what an analytics event must carry.

## Overview

Model-invoked only — the Claude copy sets `user-invocable: false` with `allowed-tools` of `Read`,
`Grep`, and `Glob`. It is the one skill in this lane wired into a role definition, so it fires as part
of front-end work rather than on demand. Both surfaces keep an accessibility checklist, responsive
design patterns, and a "Common Mistakes to Avoid" section; the routing target is `patterns_library/ui/`.

## Routes To

- `patterns_library/ui/` — the reference implementations this skill sends a reader to.
- `patterns_library/ui/authenticated-page.md`, `data-table.md`, and `form-with-validation.md` are the
  files present in that subtree.

Related concepts: [authenticated-page](../patterns/authenticated-page.md),
[data-table](../patterns/data-table.md), and
[form-with-validation](../patterns/form-with-validation.md) are the vault cards for those patterns.

## Used By Roles

- [FE Developer](../roles/fe-developer.md) — named directly at line 48 of the agent definition; the only
  declared consumer of any skill in this lane apart from migration-patterns and pattern-discovery.

This pair shows the widest textual gap in the lane: 491 lines on the Claude surface against 315 on the
portable one, a 442-line diff. The divergence is deliberate de-vendoring. Claude headings name the
stack — "Next.js App Router Patterns", "Clerk Authentication Patterns", "shadcn/ui Component Patterns",
"PostHog Analytics Patterns" — while `.agents` renames them to "Server vs Client Components",
"Protected Pages", "Route Organization", "Authentication Patterns", "Component Library Patterns", and
"Analytics Patterns". The Claude copy carries no placeholders; `.agents` introduces
`{{AUTH_CLIENT_IMPORT}}`, `{{AUTH_SERVER_IMPORT}}`, `{{UI_COMPONENTS_PATH}}`, `{{ANALYTICS_IMPORT}}`,
`{{ANALYTICS_CONFIG_PATH}}`, `{{FEATURE_FLAGS_CONFIG}}`, and `{{ADMIN_ORG_ENV_VAR}}` — env key names
only, never values. A reader on the portable copy was told materially less.

## Citations

- [frontend-patterns SKILL.md](../../../.claude/skills/frontend-patterns/SKILL.md) — the authoritative procedure.
- [Pattern Library README](../../../patterns_library/README.md) — the index of the `ui/` subtree it routes to.
