---
type: guide
title: "Iteration Patterns Comparative Analysis (SSoT stub)"
description: "Pointer to the analysis contrasting self-referential agent loops with SAFe multi-agent orchestration."
tags: [methodology, ssot-stub, orchestration, patterns]
timestamp: 2026-07-19
status: active
sources:
  - "docs/whitepapers/ITERATION-PATTERNS-COMPARATIVE-ANALYSIS.md"
verified_against: "fd0fc6a"
---

# Iteration Patterns Comparative Analysis (SSoT stub)

At 632 lines this is the longest file in `docs/whitepapers/` and the most academic in form — it
opens with an Abstract. It sets two ways of getting work out of agents against each other:
a self-referential loop and this harness's distributed SAFe orchestration. A pointer, not a
summary; the comparison is too dense to compress without losing the argument.

## What the source covers

*Comparative Analysis: Self-Referential Loops vs SAFe Multi-Agent Orchestration* runs in eight
numbered sections plus appendices: introduction, the self-referential model, the distributed
model as built here, a side-by-side comparison, what each could learn from the other, a failure
mode analysis, use-case suitability, and conclusions.

## Read it when

- You are choosing an orchestration shape for a body of work and want the tradeoff argued rather
  than asserted. Section 7 on use-case suitability is the decision aid.
- A multi-agent run failed and you want the failure modes named before you patch around one.
  Section 6 is the reason to keep this document.
- You suspect the harness is heavier than the job needs — the analysis is unusually willing to say
  where the simpler loop wins, which makes it worth reading against your own defaults.

## Where it sits in the vault

It is the theoretical backing for how this repository schedules agents, so it pairs with the
orchestration concepts rather than replacing them: [Role Collapsing](../../methodology/role-collapsing.md)
and [Exit States](../../methodology/exit-states.md) are the mechanisms the analysis argues for,
and the [orchestration-patterns skill](../../skills/orchestration-patterns.md) is where the
argument becomes something an agent actually executes.

## Citations

- [Comparative Analysis](../../../whitepapers/ITERATION-PATTERNS-COMPARATIVE-ANALYSIS.md) — the
  full paper, authoritative for the comparison and the failure mode analysis.
- [Whitepapers Index](whitepapers-readme.md) — the surrounding set of harness whitepapers.
