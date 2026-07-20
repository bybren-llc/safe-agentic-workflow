---
type: skill
title: "Skill: safe-ai-dlc"
description: "SAFe x AI-DLC program planning: Units of Work, Bolts, dependency DAG and a human-in-the-loop gate."
resource: ".claude/skills/safe-ai-dlc/SKILL.md"
tags: [skills, methodology, orchestration, gates, process]
timestamp: 2026-07-20
status: active
domain: methodology
sources:
  - ".agents/skills/safe-ai-dlc/SKILL.md"
  - "docs/guides/SAFE-AI-DLC-METHODOLOGY.md"
verified_against: "a79c2bd"
---

# Skill: safe-ai-dlc

How an epic becomes a tracked program: work decomposed into Units of Work, executed as Bolts,
ordered by a dependency graph, and paused at a human gate.

## Overview

Model-invoked only — `user-invocable: false`, `allowed-tools` limited to `Read`, `Grep`, `Glob`. It
fires when work spans multiple issues and needs cadence rather than a single ticket: turning an
initiative into projects, milestones, issues and sub-issues, wiring the dependency DAG, or running
a Bolt swarm. Its Purpose scopes the claim: in a program that adopts the fusion sprints give way to
Bolts; adopting it is a per-program choice and the standard sprint path stays valid.

Eleven H2s carry it, including The Fusion Model, Issue Template, Dependency-Wiring Rules, Running a
Bolt, Human-Gate Checklist, and Anti-Patterns (Do NOT use) — the last matters as much as the
procedure, being explicit about when the machinery is overkill. Both copies are exactly 148 lines,
the only exact line-count match across the twenty; vault-sync's two copies diverge less, 15 `diff`
lines against 83 here.

## Routes To

- `docs/guides/SAFE-AI-DLC-METHODOLOGY.md` — the full methodology this skill compresses.
- The Bolt run loop and its human-gate checklist, which halts the swarm for review.

This is one of only two skills declaring a literal `Routes To` heading of its own; the other is
vault-sync. The `.agents` copy renames "How to Structure Linear" to "How to Structure the Program"
and swaps "Linear structure" for "tracker structure" in its description.

Related: [SAFe x AI-DLC](../methodology/safe-ai-dlc.md),
[SAFe AI-DLC Methodology](../knowledge/guides/safe-ai-dlc-methodology.md),
[Evidence-Based Delivery](../methodology/evidence-based-delivery.md).

## Used By Roles

No role definition under `.claude/agents/` references this skill by name, so it is reachable only by
model invocation from context — not wired into any role's standing instructions. Planning-facing
roles such as [BSA](../roles/bsa.md) and [TDM](../roles/tdm.md) are its natural callers, but that is
an inference from subject matter rather than a declared binding.

Extraction flagged the methodology guide as unverified; it does exist, at the path cited below.

## Citations

- [SAFE-AI-DLC-METHODOLOGY.md](../../guides/SAFE-AI-DLC-METHODOLOGY.md) — the authoritative methodology.
