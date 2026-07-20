---
type: guide
title: "README"
description: "SSoT stub: the repository front door, and the only place several methodology contracts are written out in full."
tags: [ssot-stub, methodology, workflow, onboarding]
timestamp: 2026-07-20
status: active
domain: methodology
sources:
  - "README.md"
verified_against: "0c26121"
---

# README

At 1477 lines this is the largest document in the repository, and emphatically not an index.
Several contracts exist in full text here and nowhere else, so it is a source of truth.

## What Only Lives Here

- The vNext Workflow Contract v1.4 ASCII flow diagrams — the canonical picture behind
  [vNext Workflow Contract](../../methodology/vnext-workflow-contract.md).
- The role ownership matrix and the per-role contract cards for implementation agents, QAS, RTE,
  and System Architect Stage 1.
- The contract changelog, the Appendix A quick-reference cards, and the Domain Adaptation
  mappings behind [Domain Adaptation](../../methodology/domain-adaptation.md).

## What It Also Carries

The three-layer architecture diagram, quick starts for all four providers, both harness-update
paths, the SAFe x AI-DLC summary, the Knowledge Vault section, the 11-agent table, the mapping to
Anthropic's published research, and the repository structure block. Most is a second copy of
something owned elsewhere — see [Three-Layer Architecture](../../methodology/three-layer-architecture.md)
and [SAFe x AI-DLC](../../methodology/safe-ai-dlc.md).

## When To Open It

When you need the canonical diagram for a workflow contract, or an inventory claim for a harness
surface. For procedure use the owning document: [CONTRIBUTING.md](contributing.md) for git
workflow, [Agent Workflow SOP v1.4](../sop/agent-workflow-sop.md) for invocation.

## Staleness Risk

Unusually high, and structurally so: it duplicates tables that also live in `AGENTS.md`,
`CONTRIBUTING.md`, and `docs/sop/AGENT_WORKFLOW_SOP.md`, each mirrored by hand. An "Includes" bullet
that said 18 skills — against its own badge, its own tables, and the 20 in `.claude/skills/` on disk
— was carried here until `0c26121` corrected it to 20. One divergence still stands at `0c26121`:

- Its Appendix A exit-state table has eight rows where its own top-level table has seven. Neither
  is marked authoritative; [Exit States](../../methodology/exit-states.md) records the real set.

That lone self-inconsistency within one document is a signal that the hand-mirrored duplication is
not reliably maintained. Prefer the owning document whenever two copies disagree.

## Citations

- [README.md](../../../../README.md) — the full front door and the contract diagrams.
