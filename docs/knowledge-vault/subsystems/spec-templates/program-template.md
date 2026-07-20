---
type: guide
title: "Program Template"
description: "Scaffold for a SAFe x AI-DLC program decomposed into Units of Work and sequenced Bolts."
tags: [subsystems, methodology, process, orchestration]
timestamp: 2026-07-20
status: active
domain: subsystems
sources:
  - "specs_templates/program_template.md"
  - "specs_templates/README.md"
  - "docs/guides/SAFE-AI-DLC-METHODOLOGY.md"
verified_against: "c4f9d6d"
---

# Program Template

152 lines for framing a program the [SAFe x AI-DLC](../../methodology/safe-ai-dlc.md) way: work
grouped into Units of Work, each executed as a Bolt, each Bolt led by a named agent role. Reach for
it when the work is larger than a feature but you are not yet planning a full PI.

## What It Asks For

A front-matter table comes first: Initiative, Source, Method (SAFe x AI-DLC), Owner (HITL), Date,
and Status drawn from Proposed, Active or Complete. The explicit HITL owner field is the template's
way of insisting a human stays accountable for a program agents will execute.

Then "Why This Exists" — a problem statement plus a one-sentence program outcome — followed by the
Units of Work table mapping Project to Outcome, Issues, Bolt and Lead role, and the sequencing
sections that order those Bolts.

## The Constraint To Notice

Lead role is constrained to an existing `agent:*` Linear label. That couples the template directly
to the agent-label taxonomy: a program cannot name a lead the label set does not already contain.
It is a useful guard against inventing roles mid-program, and a thing to check before adopting the
template into a workspace whose labels differ.

## Practical Notes

- Placeholders are `{{TICKET_PREFIX}}` brace tokens plus bracketed prose placeholders — the brace
  dialect, unlike the planning and spec templates. See [Spec Templates](../spec-templates.md).
- Authors are instructed to delete the guidance blockquotes before committing. Nothing checks that
  they did, so shipped programs sometimes still carry them.
- The method itself lives in `docs/guides/SAFE-AI-DLC-METHODOLOGY.md`, which the template links as
  its reference. That guide now states the Bolt cadence is **opt-in per program**, not a repo-wide
  switch: the ordinary sprint path stays valid, single-issue work should run `safe-workflow`, and
  AWS's framing of AI-DLC as a replacement is deliberately softened to a selectable cadence.
- `specs_templates/README.md` carries the same opt-in scoping, so template and methodology agree
  on when the Bolt cadence applies.

## Next Steps

- [specs_templates/program_template.md](../../../../specs_templates/program_template.md) — the
  scaffold.
- [SAFE-AI-DLC-METHODOLOGY.md](../../../guides/SAFE-AI-DLC-METHODOLOGY.md) — Units of Work, Bolts,
  and the HITL gate explained.
