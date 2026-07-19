---
type: guide
title: "Spec Template"
description: "Per-story specification scaffold with acceptance criteria, pattern references, and testing plan."
tags: [subsystems, process, workflow, patterns]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "specs_templates/spec_template.md"
  - "specs_templates/README.md"
  - "CLAUDE.md"
verified_against: "fd0fc6a"
---

# Spec Template

The 202-line scaffold a BSA fills in to turn one story into an implementable specification. It is
step 1 of the SAFe workflow in `CLAUDE.md`, and the file every implementation agent reads before
touching code.

## What It Asks For

In order: Linear Issue Reference; High-Level Objective, carrying the user story and its business
context; Acceptance Criteria as a checkbox list; Pattern References, split into Primary and
Secondary; then implementation and testing sections. The checkbox form of the acceptance criteria
is deliberate — it is what QAS validates against, so each box is meant to be independently
demonstrable.

## The Section That Does The Real Work

Pattern References is the mechanism binding a spec back to the
[Pattern Library](../pattern-library.md). It asks for the pattern file name *and* a justification,
which is what turns the [Pattern Discovery Protocol](../../methodology/pattern-discovery-protocol.md)
from an instruction into a reviewable artifact. A spec with an empty Pattern References section is
a spec that skipped the search.

## Practical Notes

- Placeholders are `__TICKET_PREFIX__` and `__TICKET_URL_PREFIX__` double-underscore tokens, unlike
  `program_template.md` and `pi_planning_template.md`, which use `{{...}}` braces. See
  [Spec Templates](../spec-templates.md) for why that split matters.
- No script parses or validates a filled-in spec. Consumption is by humans and agents reading it,
  which means an incomplete section fails silently.
- The [Spec Creation](../../skills/spec-creation.md) skill is the guided path through this file.

## Next Steps

- [specs_templates/spec_template.md](../../../../specs_templates/spec_template.md) — the scaffold.
- [specs_templates/README.md](../../../../specs_templates/README.md) — ownership and context.
