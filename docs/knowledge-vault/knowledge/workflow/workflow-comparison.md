---
type: process
title: "Workflow Comparison v1.0-v1.2 (SSoT stub)"
description: "Pointer to the side-by-side comparison of workflow versions v1.0, v1.1 and v1.2."
tags: [methodology, workflow, process, ssot-stub]
timestamp: 2026-07-19
status: active
sources:
  - "docs/workflow/WORKFLOW_COMPARISON.md"
verified_against: "fd0fc6a"
---

# Workflow Comparison v1.0-v1.2 (SSoT stub)

A 370-line side-by-side of three workflow versions, written to make the cost and benefit of each
increment visible rather than asserted. It trails the current workflow: a sibling document
describes v1.3, so the comparison is one version behind what the repository documents.

## Overview

Titled *Workflow Comparison: v1.0 vs v1.1 vs v1.2*, its second heading is a Version Status warning
block — the document flags its own currency before any comparison begins, and that block is the
first thing to read. It then covers the original v1.0-versus-v1.1 comparison, a quick summary, a
detailed stage-by-stage comparison, TDM role evolution, feedback loop comparison, timeline
comparison, risk assessment, success criteria, and a recommendation. It is a decision aid, not a
procedure; nothing enforces it.

## Flow

- **Read the Version Status block first.** It states how current the comparison is. Skipping it is
  how a reader adopts a recommendation that has since been superseded.
- **Locate your current version.** The stage-by-stage comparison is only useful relative to where
  the team stands today.
- **Compare the deltas that matter.** TDM role evolution, feedback loops, and timeline are treated
  separately because a version can improve one and worsen another.
- **Weigh the risk assessment.** Each increment carries stated risk, not only benefit.
- **Take the recommendation as of v1.2.** The closing recommendation does not account for v1.3;
  reconcile it against [Workflow Changes v1.3](workflow-changes-v1-3.md) before acting.

## Roles Involved

- **[RTE](../../roles/rte.md)** — accountable for the version adoption decision this comparison
  informs.
- **[TDM](../../roles/tdm.md)** — accountable for the role-evolution consequences the comparison
  spells out, since the TDM's scope changes across versions.

## Citations

- [Workflow Comparison](../../../workflow/WORKFLOW_COMPARISON.md) — the authoritative
  stage-by-stage comparison, risk assessment, and recommendation.
- [Workflow Changes v1.3](workflow-changes-v1-3.md) — the newer version this document predates.
