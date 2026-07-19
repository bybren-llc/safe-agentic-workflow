---
type: guide
title: "Spec Templates"
description: "Five SAFe planning and specification templates that drive the spec-first workflow."
tags: [subsystems, process, workflow, methodology]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "specs_templates/README.md"
  - "specs_templates/spec_template.md"
  - "specs_templates/planning_template.md"
  - "specs_templates/program_template.md"
  - "specs_templates/pi_planning_template.md"
  - "scripts/apply-workflow.sh"
  - "CLAUDE.md"
verified_against: "fd0fc6a"
---

# Spec Templates

`specs_templates/` holds five markdown files — a README plus four scaffolds — and one binary
companion, `pi_planning_template.xlsx`. Read this before filling any in: the directory is
copy-and-fill only, and its two placeholder dialects will bite a naive substitution pass.

## What Each One Is For

- [Planning Template](spec-templates/planning-template.md) — BSA-owned decomposition from Epic to
  Feature to Story to Enabler. Start here; the others assume its output.
- [Spec Template](spec-templates/spec-template.md) — the per-story specification that `CLAUDE.md`
  step 1 of the SAFe workflow names directly.
- [Program Template](spec-templates/program-template.md) — a SAFe x AI-DLC program as Units of Work
  and sequenced Bolts.
- [PI Planning Template](spec-templates/pi-planning-template.md) — a whole Program Increment, with
  the program board, dependencies, ROAM risks and gates.

## How They Reach You

`scripts/apply-workflow.sh` lines 93-95 copy the directory wholesale into an adopter repo, next to
`patterns_library/` and `linting_configs/`. Nothing else reads them — no script parses, validates
or substitutes into these files. They are inert until someone fills one in and commits it.

## The Trap Worth Knowing First

Two placeholder dialects coexist. `planning_template.md` and `spec_template.md` use
`__TICKET_PREFIX__` double-underscore tokens; `program_template.md` and `pi_planning_template.md`
use `{{TICKET_PREFIX}}` brace tokens. A single substitution pass over the directory will therefore
silently miss half the files. Check which dialect you are in before writing any tooling against
them.

`README.md` also warns that the `.xlsx` companion to the PI planning template is exactly that, and
tells teams to "keep one authoritative source" — a manual discipline with no check behind it.

## Next Steps

- [specs_templates/README.md](../../../specs_templates/README.md) — ownership and per-file notes.
- [Spec Creation](../skills/spec-creation.md) — the skill that walks an agent through filling one.
- [apply-workflow](../operations/scripts/apply-workflow.md) — how the directory is distributed.
