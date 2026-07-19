---
type: process
title: "Workflow Quality Checklist (SSoT stub)"
description: "Pointer to the per-story quality checklist used to validate workflow execution."
tags: [methodology, workflow, process, gates, ssot-stub]
timestamp: 2026-07-19
status: active
sources:
  - "docs/workflow/WORKFLOW_QUALITY_CHECKLIST.md"
verified_against: "fd0fc6a"
---

# Workflow Quality Checklist (SSoT stub)

A 391-line manual checkbox gate applied per story, asking whether the workflow was executed well —
not whether the code compiles. It exists to catch the failure where every individual step passed
and the orchestration was still bad.

## Overview

The document opens with How to Use This Checklist, then sections on subagent orchestration
quality, deliverable quality, workflow pattern compliance, quality gates passed, a retrospective
check, evidence collection, final validation, and paired success and failure pattern catalogues.
**No script or hook consumes it** — it is checked by a human or an agent reading the file, and a
green CI run says nothing about it. It is separate from `docs/release/PRE-RELEASE-CHECKLIST.md`,
which gates tags rather than stories. The retrospective heading carries an unsubstituted
`{{TICKET_PREFIX}}` placeholder.

## Flow

- **Open the checklist at story close.** How to Use This Checklist scopes it to a completed unit of
  work, not to a release.
- **Check orchestration quality.** Whether subagents were used well, which is the part no other
  gate looks at.
- **Check deliverables and pattern compliance.** Whether what was produced matches what the chosen
  workflow pattern requires.
- **Confirm the quality gates passed.** The gate: unchecked boxes mean the story is not done.
- **Collect evidence.** The Evidence Collection section feeds the ticket record — see
  [Evidence-Based Delivery](../../methodology/evidence-based-delivery.md).
- **Compare against the pattern catalogues.** Success and failure patterns turn a one-off review
  into something the next story can learn from.

## Roles Involved

- **[QAS](../../roles/qas.md)** — accountable for running the checklist and for the evidence
  attached to the ticket.
- **[TDM](../../roles/tdm.md)** — accountable for the orchestration quality the checklist judges.
- **[RTE](../../roles/rte.md)** — accountable for the failure patterns recurring across stories.

## Citations

- [Workflow Quality Checklist](../../../workflow/WORKFLOW_QUALITY_CHECKLIST.md) — the
  authoritative checklist, gates, and pattern catalogues.
- [Pre-PR Validation Checklist](../sop/pre-pr-validation-checklist.md) — the automated-check
  counterpart run before a pull request.
