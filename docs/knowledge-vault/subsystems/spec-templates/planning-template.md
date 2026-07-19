---
type: guide
title: "Planning Template"
description: "BSA scaffold for decomposing an initiative into a SAFe Epic/Feature/Story/Enabler breakdown."
tags: [subsystems, process, methodology, workflow]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "specs_templates/planning_template.md"
  - "specs_templates/README.md"
verified_against: "fd0fc6a"
---

# Planning Template

135 lines that take one initiative and break it into the SAFe hierarchy. `README.md` assigns it to
the [Business Systems Analyst](../../roles/bsa.md) and calls it the first step in translating a
business need into technical requirements — so this is the template that runs before any other.

## What It Asks For

It opens with a Linear Issue Reference block: the Epic ticket, plus the Confluence URL of the
upstream initiative. Confluence is named as the source of initiatives, which makes this file the
seam between the business record and the delivery record.

The body is a nested work breakdown — Epic, then Feature, then User Story, then Enabler. As-a /
I-want / So-that blocks appear on the User Stories only; Enablers carry Description and
Justification instead, and the Feature rows carry only Description and Business Value. The Linear
ticket slot sits on the Epic and on every leaf, Story or Enabler, and that is the point: the
breakdown is not finished until each leaf has somewhere to live in Linear.

## Practical Notes

- Placeholders are `__TICKET_PREFIX__` double-underscore tokens, the same dialect as
  `spec_template.md` and not the brace dialect used by the program and PI templates. See
  [Spec Templates](../spec-templates.md).
- No script reads this file. It is filled in by hand and its output is the set of tickets, not the
  document — nothing downstream parses it.
- Each Story that survives the breakdown becomes an input to the
  [Spec Template](spec-template.md).

## Next Steps

- [specs_templates/planning_template.md](../../../../specs_templates/planning_template.md) — the
  scaffold itself.
- [specs_templates/README.md](../../../../specs_templates/README.md) — ownership and sequencing.
