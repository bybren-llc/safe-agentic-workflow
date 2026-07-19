---
type: skill
title: "Skill: confluence-docs"
description: "Templates for ADRs, runbooks, architecture docs and knowledge-transfer docs, plus output locations."
resource: ".claude/skills/confluence-docs/SKILL.md"
tags: [skills, methodology, process]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".claude/skills/confluence-docs/SKILL.md"
  - ".agents/skills/confluence-docs/SKILL.md"
  - ".claude/skills/confluence-docs/README.md"
verified_against: "fd0fc6a"
---

# Skill: confluence-docs

The documentation-shape card: four embedded templates and the directory each finished document is
meant to land in.

## Overview

Model-invocable, with no `user-invocable` key. It is one of only two skills in this lane granted
`Write` and `Edit` alongside `Read`, `Grep`, and `Glob` — the other being spec-creation — because it
produces files rather than advice. It embeds four templates: ADR, Runbook, Architecture Document, and
Knowledge Transfer. Reach for it when a decision or an operational procedure needs a durable home;
do not reach for it to write a spec, which belongs to spec-creation.

## Routes To

- `docs/adr/` — architectural decision records. This directory does NOT exist in the repository.
- `docs/runbooks/` — operational procedures.
- `docs/architecture/` — architecture documents.
- `docs/agent-outputs/technical-docs/` — knowledge-transfer output.

Related concepts: [Three-Layer Architecture](../methodology/three-layer-architecture.md) is the kind of
subject an architecture document here would cover, and [Tech Writer](../roles/tech-writer.md) is the
role whose output this shapes.

## Used By Roles

- No file under `.claude/agents/` names this skill, so no role loads it automatically.
- [Tech Writer](../roles/tech-writer.md) and [System Architect](../roles/system-architect.md) are its
  intended consumers by subject matter, but neither declares it.

This is the widest structural gap in the lane. The Claude copy (277 lines) carries an "Existing ADRs
(Reference)" section naming six project ADRs — ADR-002 constants-unification, ADR-003
dependency-upgrade-typescript-fixes, ADR-004 server-component-data-access-pattern, ADR-005
ci-infrastructure-services, ADR-006 bonus-pdf-private-bucket-security, and ADR-007
rendertrust-marketing-pages. The `.agents` copy (220 lines) deletes that section and adds a `TEMPLATE`
banner with `{{PLACEHOLDER}}` tokens. Since `docs/adr/` is absent here, that list points at nothing: it
is inherited from the project this harness was extracted from, and a reader will find no files.

## Citations

- [confluence-docs SKILL.md](../../../.claude/skills/confluence-docs/SKILL.md) — the authoritative templates.
- [confluence-docs README](../../../.claude/skills/confluence-docs/README.md) — licence and quick-start context.
