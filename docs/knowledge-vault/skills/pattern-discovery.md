---
type: skill
title: "Skill: pattern-discovery"
description: "Mandatory pre-implementation search of patterns_library before writing any new feature code."
resource: ".claude/skills/pattern-discovery/SKILL.md"
tags: [skills, patterns, gates, methodology]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".claude/skills/pattern-discovery/SKILL.md"
  - ".agents/skills/pattern-discovery/SKILL.md"
  - ".claude/skills/pattern-discovery/README.md"
  - ".claude/agents/be-developer.md"
  - ".claude/agents/fe-developer.md"
  - ".claude/agents/data-engineer.md"
  - ".claude/agents/qas.md"
  - ".claude/agents/system-architect.md"
  - "patterns_library/README.md"
verified_against: "fd0fc6a"
---

# Skill: pattern-discovery

The gate that fires before code exists: search the pattern library first, write new code only once
that search comes back empty.

## Overview

Model-invocable, one of three skills declaring `context: fork` and one of only two pairing it with
`agent: Explore`, tools limited to `Read`, `Grep`, `Glob`. The fork is the design: the sweep runs in
its own context so it does not crowd out the work that prompted it. The other `Explore` forker is
security-audit; spec-creation forks without naming an agent. Reach for it before any feature, route,
component, or schema change.

## Routes To

- `patterns_library/README.md` — the library index and entry point.
- `patterns_library/api/`, `database/`, `testing/`, `ui/` — the four subtrees it sweeps.

Related: [Pattern Discovery Protocol](../methodology/pattern-discovery-protocol.md) and
[Pattern Library](../subsystems/pattern-library.md).

## Used By Roles

- [BE Developer](../roles/be-developer.md), [FE Developer](../roles/fe-developer.md) — before coding.
- [Data Engineer](../roles/data-engineer.md) — before a schema or migration change.
- [QAS](../roles/qas.md) — checking work against the pattern it should have reused.
- [System Architect](../roles/system-architect.md) — judging whether a new pattern is warranted.

Five declared roles make this the second-widest adoption in the harness, behind safe-workflow's six.
The surfaces diverge most here proportionally: `.agents` is 62 lines against Claude's 155, dropping the
`context`, `agent` and `allowed-tools` frontmatter — so no fork happens there — plus three sections.

## Citations

- [pattern-discovery SKILL.md](../../../.claude/skills/pattern-discovery/SKILL.md) — the authoritative procedure.
- [Pattern Library README](../../../patterns_library/README.md) — the index this skill searches.
