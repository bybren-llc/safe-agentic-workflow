---
type: skill
title: "Skill: spec-creation"
description: "Builds specs with pattern references, acceptance criteria, success validation commands and demo scripts."
resource: ".claude/skills/spec-creation/SKILL.md"
tags: [skills, process, patterns, methodology]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".agents/skills/spec-creation/SKILL.md"
  - "docs/team/PLANNING-AGENT-META-PROMPT.md"
verified_against: "fd0fc6a"
---

# Skill: spec-creation

Turns a ticket into a spec another agent can execute without asking questions: pattern references,
acceptance criteria, the command that proves it works, and a demo script.

## Overview

It forks its context (`context: fork`) but names no agent — the two other forking skills,
pattern-discovery and security-audit, both pair the fork with `agent: Explore`. Its `argument-hint`
is `[ticket-id]` and its `allowed-tools` are `Read`, `Write`, `Grep`, `Glob`: `Write` without
`Edit`, which fits a skill that creates new documents rather than revising them.

It declares neither `user-invocable` nor `disable-model-invocation`, yet appears in the runtime
available-skills listing, so both invocation paths are open. Output lands in `specs/` as
`specs/SPEC-*`, with requirements written to `docs/agent-outputs/requirements/`. The `.agents` copy
is shorter (187 lines against 224) and renames "Evidence for Linear" to "Evidence for Ticket System".

## Routes To

- `specs/SPEC-*` and `docs/agent-outputs/requirements/` — the artifacts this skill writes.
- `patterns_library/README.md` plus its `api/`, `database/`, and `ui/` subtrees.

Four routed paths do not exist on disk: `docs/archive/specs/spec_template.md`,
`patterns_library/api/crud-endpoint.md`, `patterns_library/ui/modal-form.md`, and
`patterns_library/security/rls-user-data.md`. The route list is byte-identical across both surfaces,
broken paths included, so neither fold is the corrected one.

Related: [Pattern Discovery Protocol](../methodology/pattern-discovery-protocol.md),
[Pattern Library](../subsystems/pattern-library.md),
[Spec Template](../subsystems/spec-templates/spec-template.md).

## Used By Roles

No role definition under `.claude/agents/` names this skill, which is notable given that spec
authorship belongs to [BSA](../roles/bsa.md) in the delivery chain. The binding exists in the
methodology but not in the harness configuration, leaving model invocation or a direct user call
with a ticket ID as the only ways in.

## Citations

- [PLANNING-AGENT-META-PROMPT.md](../../team/PLANNING-AGENT-META-PROMPT.md) — the planning contract.
- [patterns_library/README.md](../../../patterns_library/README.md) — the pattern index specs must cite.
