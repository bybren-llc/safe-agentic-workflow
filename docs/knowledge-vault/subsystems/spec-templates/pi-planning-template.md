---
type: guide
title: "PI Planning Template"
description: "Full Program Increment planning scaffold covering program board, dependencies, ROAM risks, and gates."
tags: [subsystems, methodology, process, gates]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "specs_templates/pi_planning_template.md"
  - "specs_templates/pi_planning_template.xlsx"
  - "specs_templates/README.md"
verified_against: "fd0fc6a"
---

# PI Planning Template

299 lines, the largest template in the set: a whole Program Increment, from the program board down
to the POPM decision log. Use it when you are planning several sprints across multiple streams at
once; anything smaller is better served by the [Program Template](program-template.md).

## The Ten Sections

Program Summary, Program Board, Sprint Plans, Delivery Teams, Phase Enablers, Dependencies, ROAM
Risk Register, Gate Criteria, POPM Decisions, and a PI Planning Update Log. `README.md` enumerates
ten sections and the file matches — an agreement worth noting, because it does not hold everywhere
in this directory.

The Program Board is a stream-by-sprint matrix. Delivery Teams maps humans *and* agents to streams,
which is where this template departs from stock SAFe. Program Summary carries PI Duration, Sprint
Cadence, Sprint Count and a Decision Readiness percentage, alongside a Program Totals table
tracking committed, backlog and total points plus issue and stream counts.

## Read The Provenance Claim Carefully

The file states it is "Production-validated at scale with 11 AI agents across 5 services." That is
the template's own claim about its origin, not a property of your program, and nothing in this
repository substantiates it. Treat it as heritage, not evidence.

## Practical Notes

- A companion spreadsheet, `specs_templates/pi_planning_template.xlsx`, ships alongside the
  markdown with no automated sync between them. `README.md` tells teams to keep one authoritative
  source; that is discipline, not tooling.
- Placeholders are brace tokens — `{{PROJECT_NAME}}`, `{{TICKET_PREFIX}}`, `{{STREAM_n}}`,
  `{{SPRINT_LENGTH}}` and similar. See [Spec Templates](../spec-templates.md) on the two dialects.
- No script reads either file.

## Next Steps

- [pi_planning_template.md](../../../../specs_templates/pi_planning_template.md) — the scaffold.
- [specs_templates/README.md](../../../../specs_templates/README.md) — section list and the
  one-authoritative-source warning.
