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
verified_against: "a79c2bd"
---

# SAFe x AI-DLC Program Cadence

The thesis is one line: *SAFe with its clock swapped out, for the programs where you choose to swap
it.* SAFe supplies hierarchy, WSJF, roles, and DoD; AWS AI-DLC supplies cadence and the human
checkpoint. In a program that adopts the fusion, the sprint gives way to the Bolt.

## Overview

The cadence is opt-in — a per-program choice, not a repo-wide switch — and the standard sprint path
stays valid; AWS frames AI-DLC as replacing existing practice, this harness as a cadence you select.
It applies when work spans many issues, not one ticket. A **Bolt** is a labelled swarm (`bolt:0`,
`bolt:1`) rather than a tracker cycle, since cycles floor at a week and are team-wide. A **Unit of
Work** is an AI-DLC Feature mapping to a tracker Project; **Mob Elaboration** replaces sprint
planning (decompose, list unknowns, ask *before* code), then **Mob Construction**. The loop: AI
plans, AI asks, human validates, AI executes.

## Flow

- **Map the hierarchy.** Portfolio Epic to Initiative, Epic or value stream to sub-initiative,
  Feature to Project, PI increment to a `bolt:N` label plus target date, phase gate to Project
  Milestone, Story or Enabler to Issue, Task to Sub-issue. WSJF, role, and DoD ride in the
  description as `agent:*` labels and AC/DoD text. Run an ambiguous epic as a spike, not a Bolt.
- **Wire the dependency DAG.** Fix the gate before the fix it verifies, rotate before scrub, capture
  before alert, upgrades before re-baseline; chains root at CI hardening.
- **Swarm, then exit on evidence.** A Bolt closes only when issues are merged, gates are real and
  green, and evidence is posted per [Evidence-Based Delivery](evidence-based-delivery.md).

Six decisions always route to the human: secret rotation and blast radius, security policy (CSP,
auth, headers), required CI checks and branch protection, dependency severity and the
fix-vs-suppress budget, any SOP exception, signing the DoD. One discrepancy: README calls it a skill
on all four providers; Cursor carries it as the manual rule `03-safe-ai-dlc.mdc`.

## Roles Involved

- **[TDM](../roles/tdm.md)** — reactive coordination of blockers across a running Bolt.
- **ARCHitect-in-CLI** — primary orchestrator; sequences the DAG and calls the Bolt exit.
- **Human (POPM/HITL)** — owns the six routed decisions and signs the DoD.

## Citations

- [SAFE-AI-DLC-METHODOLOGY.md](../../guides/SAFE-AI-DLC-METHODOLOGY.md) — the full 144-line method.
