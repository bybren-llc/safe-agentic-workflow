# SAFe x AI-DLC

![Status](https://img.shields.io/badge/status-production-green)
![Harness](https://img.shields.io/badge/harness-{{HARNESS_VERSION}}-blue)

> Plan and run programs using the SAFe x AI-DLC fusion. Structures an audit or initiative into Linear as Units of Work and Bolts, with a human-in-the-loop gate.

## License

**License:** MIT (see [/LICENSE](/LICENSE))
**Copyright:** © 2026 J. Scott Graham ([@cheddarfox](https://github.com/cheddarfox)) / [ByBren, LLC](https://github.com/bybren-llc)
**Attribution:** Required per [/NOTICE](/NOTICE)

## Intellectual Property

The skill system architecture and {{PROJECT_SHORT}} harness methodology are the intellectual property of J. Scott Graham and ByBren, LLC.

SAFe® is a registered trademark of Scaled Agile, Inc.

## Quick Start

This skill activates automatically when you:

- Turn an audit, epic, or initiative into an executable program
- Structure work in Linear above the level of a single issue
- Break an initiative into Units of Work and sequence them into Bolts
- Wire a dependency DAG across issues
- Run a Bolt from elaboration through to HITL merge

## What This Skill Does

Encodes the fusion of SAFe structure with the AI-DLC delivery cadence. SAFe supplies the hierarchy, WSJF, role boundaries, and Definition of Done; AI-DLC supplies **Bolts** (hours-to-days swarms that replace sprints), **Units of Work**, **Mob Elaboration**, and the plan → clarify → validate → execute loop with a human checkpoint in the middle.

Provides the Linear mapping (initiative → project → milestone → issue → sub-issue), the issue template, four dependency-wiring heuristics, the six steps of running a Bolt, and the human-gate checklist that keeps agents from guessing business, security, or policy decisions.

## Trigger Keywords

| Primary      | Secondary       |
| ------------ | --------------- |
| bolt         | program         |
| unit of work | initiative      |
| AI-DLC       | mob elaboration |
| remediation  | dependency DAG  |

## Related Skills

- [linear-sop](../linear-sop/) - Program structure, MCP calls, evidence templates
- [safe-workflow](../safe-workflow/) - Branch, commit, and PR conventions
- [orchestration-patterns](../orchestration-patterns/) - Multi-agent coordination during a Bolt
- [pattern-discovery](../pattern-discovery/) - Find patterns before constructing

## Maintenance

| Field           | Value                 |
| --------------- | --------------------- |
| Last Updated    | 2026-07-19            |
| Harness Version | {{HARNESS_VERSION}}   |

---

*Full implementation details in [SKILL.md](SKILL.md)*
