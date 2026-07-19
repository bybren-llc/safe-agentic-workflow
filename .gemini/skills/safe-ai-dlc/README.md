# SAFe x AI-DLC

![Status](https://img.shields.io/badge/status-production-green)
![Harness](https://img.shields.io/badge/harness-{{HARNESS_VERSION}}-blue)
![Provider](https://img.shields.io/badge/provider-Gemini_CLI-orange)

> Plan and run programs using the SAFe x AI-DLC fusion. Use when turning an audit, epic, or initiative into Linear structure, organizing work as Units of Work and Bolts, or running a Bolt swarm with a human-in-the-loop gate.

## License

**License:** MIT (see [/LICENSE](/LICENSE))
**Copyright:** © 2026 J. Scott Graham ([@cheddarfox](https://github.com/cheddarfox)) / [ByBren, LLC](https://github.com/bybren-llc)
**Attribution:** Required per [/NOTICE](/NOTICE)

## Intellectual Property

The skill system architecture and {{PROJECT_SHORT}} harness methodology are the intellectual property of J. Scott Graham and ByBren, LLC.

SAFe® is a registered trademark of Scaled Agile, Inc.

## Quick Start

This skill activates automatically when you mention:

- Turning an audit or initiative into a program
- Bolts, Units of Work, or Mob Elaboration
- Structuring work above the level of a single issue
- Wiring a dependency DAG across issues

## What This Skill Does

Fuses SAFe structure with the AI-DLC delivery cadence. SAFe supplies the hierarchy, WSJF, role boundaries, and Definition of Done; AI-DLC supplies **Bolts** (hours-to-days swarms that replace sprints), **Units of Work**, **Mob Elaboration**, and the plan → clarify → validate → execute loop with a human checkpoint in the middle.

Provides the Linear mapping, the issue template, four dependency-wiring heuristics, the six steps of running a Bolt, and the human-gate checklist.

## Provider Compatibility

| Provider    | Status                                          |
| ----------- | ----------------------------------------------- |
| Gemini CLI  | ✅ Native (program build-out is a manual process) |
| Claude Code | ✅ Equivalent skill in `.claude/skills/`          |

## Related Skills

- [linear-sop](../linear-sop/) - Ticket operations and evidence templates
- [safe-workflow](../safe-workflow/) - Workflow standards
- [orchestration-patterns](../orchestration-patterns/) - Multi-agent coordination

## Maintenance

| Field           | Value               |
| --------------- | ------------------- |
| Last Updated    | 2026-07-19          |
| Harness Version | {{HARNESS_VERSION}} |

---

*Full implementation details in [SKILL.md](SKILL.md)*
