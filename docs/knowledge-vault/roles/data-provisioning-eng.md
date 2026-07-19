---
type: agent-role
title: "DPE - Data Provisioning Engineer"
description: "Builds ETL pipelines and data-quality validation from BSA specs; the least-gated of the eleven roles."
resource: ".claude/agents/data-provisioning-eng.md"
tags: [methodology, agents, patterns, workflow]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".codex/agents/data-provisioning-eng.toml"
  - "agent_providers/claude_code/prompts/data-provisioning-eng.md"
verified_against: "fd0fc6a"
---

# DPE - Data Provisioning Engineer

Pure execution: "BSA defined the data strategy. You just execute."

## Overview

The role builds data pipelines and ETL processes from an existing pattern in four steps — read
spec, find pattern, copy and customise, validate. It is the smallest role definition in the team
and one of only two configured on a smaller, medium-reasoning model in the Codex surface; the
other is the Tech Writer. It also carries the least ceremony of any implementation role: no
stop-the-line gate, no ownership model section, and no declared exit state, where the backend,
frontend, and data engineers all declare `Ready for QAS`.

## Responsibilities

- Owns ETL pipelines and transformations implemented from `patterns_library/` patterns.
- Owns data quality rules and the completeness, accuracy, and consistency checks that enforce them.
- Owns data lineage monitoring and transformation documentation.
- Does not create new patterns — the definition assigns that to BSA or the System Architect.
- Does not design the data strategy; it receives one.

## Skills & SOPs

- [pattern-discovery](../skills/pattern-discovery.md) — the pre-implementation search.
- [rls-patterns](../skills/rls-patterns.md) — ETL work goes through the system context helper,
  and operations are wrapped in transactions.
- [testing-patterns](../skills/testing-patterns.md) — the integration checks it runs before handoff.

## Handoffs

- **Receives from** [BSA](bsa.md) — a spec naming the data source, transformation logic, and
  validation rules. Any of the three being unclear is an escalation back to BSA, not a guess.
- **Hands off to** [QAS](qas.md) — with integration tests and type-check green. Note the gap: the
  definition never names an exit state, so the handoff is by convention rather than by contract.

The provider mirror differs from the authoritative definition only in the declared model, which is
downgraded; the rest of the file is byte-identical.

## Citations

- [Agent Workflow SOP](../../sop/AGENT_WORKFLOW_SOP.md) — the exit-state contract this role omits.
- [AGENTS.md](../../../AGENTS.md) — role roster and invocation patterns.
