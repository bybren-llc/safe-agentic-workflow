---
type: agent-role
title: "{{Title}}"
description: "{{ONE_SENTENCE ≤160 chars: what this agent role is accountable for}}"
resource: "{{PATH}}"
tags: [agents, {{TAGS}}, ssot-stub]
timestamp: {{YYYY-MM-DD}}
status: active
domain: {{DOMAIN}}
docs:
  - "{{PATH}}"
---

# {{Title}}

**This is a map-card. The role's full instructions live in the agent definition cited below — do
not restate its prompt here.** The card places the role in the workflow graph; the definition
tells the agent what to do.

## Overview

{{3-5 sentences: the role's purpose, where it sits in the delivery flow, and the single boundary
that matters most (what it must never do). Refer to roles by function, never by personal name.}}

## Responsibilities

{{3-6 bullets: what this role owns, phrased as accountabilities rather than activities. Include at
least one explicit non-responsibility — boundaries prevent role bleed more effectively than duty
lists do.}}

- {{Owns: ...}}
- {{Does not: ...}}

## Skills & SOPs

{{2-6 bullets: the skills this role invokes and the SOPs it operates under. Link only to concept
IDs listed in manifest.json; name missing ones in prose without a link. Never invent links.}}

- {{[Skill Title](../path/to/skill.md) — when this role reaches for it}}

## Handoffs

{{2-5 bullets: the exit state this role produces, who receives it, and what evidence must
accompany the handoff. Name the upstream role that feeds this one.}}

- **{{Receives from}}** {{role}} — {{what arrives, and the precondition that must hold}}
- **{{Hands off to}}** {{role}} — {{the exit state and the evidence required}}

## Citations

{{1-4 bullets. A stub type MUST carry an out-of-bundle citation to its source of truth — the
validator enforces this. Out-of-bundle links appear ONLY in this section.}}

- [{{Agent Definition}}]({{PATH}}) — the authoritative role specification
