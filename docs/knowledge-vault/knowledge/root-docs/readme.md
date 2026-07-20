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
verified_against: "a79c2bd"
---

# README

At 1476 lines this is the largest document in the repository, and emphatically not an index.
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
`CONTRIBUTING.md`, and `docs/sop/AGENT_WORKFLOW_SOP.md`, each mirrored by hand. Two divergences are
already visible inside this single file at `a79c2bd`:

- Its "Includes" bullet says 18 skills, where its own badge, its own tables, and the contents of
  `.claude/skills/` on disk all say 20. The disk count is correct.
- Its Appendix A exit-state table has eight rows where its own top-level table has seven. Neither
  is marked authoritative; [Exit States](../../methodology/exit-states.md) records the real set.

Both are self-inconsistencies within one document — the clearest possible signal that the
duplication is not being maintained. Prefer the owning document whenever the two disagree.

## Citations

- [README.md](../../../../README.md) — the full front door and the contract diagrams.
