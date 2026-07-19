---
type: agent-role
title: "Tech Writer - Documentation and Data Governance Docs"
description: "Writes documentation from patterns and owns the data dictionary, RLS catalog, and ERD diagrams."
resource: ".claude/agents/tech-writer.md"
tags: [methodology, agents, patterns, workflow, onboarding]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".codex/agents/tech-writer.toml"
  - "agent_providers/claude_code/prompts/tech-writer.md"
verified_against: "fd0fc6a"
---

# Tech Writer - Documentation and Data Governance Docs

Documentation as an execution role: find the template, fill it, lint it, hand it back.

## Overview

The role produces documentation from templates in the documentation pattern category and validates
markdown quality, in the same four-step loop the other execution roles use — read spec, find
pattern, copy template, validate. Beyond prose it owns governance artefacts other roles consume,
most notably the production migration checklist template the Data Engineer builds its migration
plans on. It is one of two roles on a smaller, medium-reasoning Codex model, alongside the Data
Provisioning Engineer.

## Responsibilities

- Owns the data dictionary, the RLS policy catalog, and ERD diagrams generated from the schema.
- Owns integration architecture maps as Mermaid diagrams, schema change history, and data lineage.
- Owns the production migration checklist template and the data governance policy documents.
- Does not create new documentation patterns; the definition assigns that to BSA or the ARCHitect.
- Does not verify code behaviour itself — technical claims needing verification go back to BSA.

## Skills & SOPs

- [confluence-docs](../skills/confluence-docs.md) — ADR, runbook, and architecture templates.
- [pattern-discovery](../skills/pattern-discovery.md) — the pre-authoring template search.
- [Data Dictionary](../knowledge/database/data-dictionary.md) — the artefact it maintains.
- [RLS Policy Catalog](../knowledge/database/rls-policy-catalog.md) — the catalog it maintains.

## Handoffs

- **Receives from** [BSA](bsa.md) — a spec naming the document type and its content. It also
  receives documentation gaps routed directly from [QAS](qas.md) during verification.
- **Hands off** validated markdown, with the markdown linter and type-check green. The definition
  declares no exit state, so unlike the developer roles this handoff rests on convention.
- **Escalates** to BSA when the pattern is unclear or missing, or the spec is thin on content.

The provider mirror differs from the authoritative definition only in the declared model, which is
downgraded; the rest of the file is byte-identical.

## Citations

- [DATA_DICTIONARY.md](../../database/DATA_DICTIONARY.md) — the schema source of truth it owns.
- [AGENTS.md](../../../AGENTS.md) — role roster and invocation patterns.
