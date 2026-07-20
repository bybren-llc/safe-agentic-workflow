---
type: process
title: "SAFe x AI-DLC Program Cadence"
description: "SAFe keeps hierarchy and gates; inside a program that adopts the AWS AI-DLC fusion the sprint gives way to the Bolt, an hours-to-days swarm exiting on evidence."
tags: [methodology, process, workflow, orchestration, gates]
timestamp: 2026-07-20
status: active
domain: methodology
sources:
  - "docs/guides/SAFE-AI-DLC-METHODOLOGY.md"
  - "README.md"
  - ".claude/skills/safe-ai-dlc/SKILL.md"
  - ".cursor/rules/03-safe-ai-dlc.mdc"
  - "specs_templates/program_template.md"
  - ".claude/skills/linear-sop/SKILL.md"
verified_against: "0c26121"
---

# SAFe x AI-DLC Program Cadence

The thesis is one line: *SAFe with its clock swapped out, for the programs where you choose to swap
it.* SAFe supplies hierarchy, WSJF, roles, and DoD; AWS AI-DLC supplies cadence and the human
checkpoint. In a program that adopts the fusion, the sprint gives way to the Bolt.

## Overview

A **Bolt** is a labelled swarm (`bolt:0`, `bolt:1`) rather than a tracker cycle, since cycles floor
at a week and are team-wide. A **Unit of Work** maps to the SAFe Feature and a tracker Project, a
granularity this fusion chose since AWS frames it as replacing the Epic. **Mob Elaboration** stands
in for sprint planning (decompose, list unknowns, ask *before* code), then **Mob Construction**.
The loop: AI plans, AI asks, human validates, AI executes.

It suits work spanning many issues, not one ticket, and is opt-in per program: the standard sprint
path stays valid. AWS frames AI-DLC as replacing existing practice; this harness offers it as a
cadence you select.

## Flow

- **Map the hierarchy.** Initiative down to Sub-issue; PI increment becomes a `bolt:N` label plus
  target date, each phase gate a Project Milestone. Run an ambiguous epic as a spike, not a Bolt.
- **Wire the dependency DAG.** Gate before the fix it verifies, rotate before scrub, capture before
  alert, upgrades before re-baseline; chains root at CI hardening.
- **Swarm, then exit on evidence.** A Bolt closes only when issues are merged, gates are real and
  green, and evidence posted per [Evidence-Based Delivery](evidence-based-delivery.md).

Six decisions always route to the human, enumerated in the guide: secrets, security policy, required
CI checks and branch protection, severity and fix-vs-suppress budget, SOP exceptions, signing the
DoD. The method ships as a skill for Claude, Gemini and the portable surface; Cursor carries it as a
manual rule, `03-safe-ai-dlc.mdc`.

## Roles Involved

- **[TDM](../roles/tdm.md)** — reactive coordination of blockers across a running Bolt.
- **ARCHitect-in-CLI** — orchestrator; sequences the DAG and calls the Bolt exit.
- **Human (POPM/HITL)** — owns the six routed decisions and signs the DoD.

## Citations

- [SAFE-AI-DLC-METHODOLOGY.md](../../guides/SAFE-AI-DLC-METHODOLOGY.md) — the full 144-line method.
