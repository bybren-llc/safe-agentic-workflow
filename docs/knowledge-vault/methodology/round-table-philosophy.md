---
type: guide
title: "Round Table Philosophy"
description: "Collaboration model treating human and AI contributors as peers with equal voice, defined roles, and authority in their domains."
tags: [methodology, process, agents, workflow]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - "docs/guides/ROUND-TABLE-PHILOSOPHY.md"
  - "AGENTS.md"
  - "docs/guides/AGENT_TEAM_GUIDE.md"
verified_against: "fd0fc6a"
---

# Round Table Philosophy

The harness's stated collaboration model: human and AI contributors sit as peers, each with a
defined role and real authority inside it. It is the reason agents here are expected to disagree.

## The Claim

> We work as a round table team that has 4 pillars of SAFe inscribed on that round table.
> It means something.

The four pillars named are alignment, built-in quality, transparency, and program execution. Seven
principles hang off them — equal voice, mutual respect, shared responsibility, transparent
decision-making, expertise recognition, constructive disagreement, and collaborative
problem-solving — each stated with an "in practice" clause so it is more than a slogan.

## What It Is Defined Against

The explicit foil is the *order-taker model*: an assistant with no agency, ephemeral context, and
no defined role. Round Table inverts all three. An agent carries a role, retains context through
the workflow contract, and is expected to push back — which is what makes
[Stop-the-Line](stop-the-line-gate.md) authority coherent rather than insubordinate.

Four worked scenarios are given: an agent disagreeing with a spec, a human overriding an agent
recommendation, several agents collaborating on one feature, and a developer-versus-architect
conflict. Decisions get recorded with the `#PATH_DECISION` metacognitive tag, one of three the
harness defines alongside `#PLAN_UNCERTAINTY` and `#EXPORT_CRITICAL`.

## Honest Limits

Nothing mechanically enforces any of this. The philosophy is normative prose; no hook, lint rule,
or CI check verifies that equal voice was honoured or that a disagreement was recorded. It works
to the extent people and agents choose to follow it, which is worth knowing before treating it as
a guarantee.

Its source document is also load-bearing beyond this concept: it carries the canonical
stop-the-line authority definition and the evidence-requirements table, making it the origin for
[Evidence-Based Delivery](evidence-based-delivery.md) and
[Stop-the-Line Gate](stop-the-line-gate.md) as well.

## Citations

- [ROUND-TABLE-PHILOSOPHY.md](../../guides/ROUND-TABLE-PHILOSOPHY.md) — the full statement.
- [AGENTS.md](../../../AGENTS.md) — the role roster the model assumes.
- [Agent Team Guide](../../guides/AGENT_TEAM_GUIDE.md) — how the roles work together in practice.
