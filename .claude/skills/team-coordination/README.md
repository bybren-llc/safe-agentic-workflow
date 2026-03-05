# Team Coordination

![Status](https://img.shields.io/badge/status-beta-yellow)
![Harness](https://img.shields.io/badge/harness-{{HARNESS_VERSION}}-blue)

> Agent Teams orchestration patterns for multi-agent SAFe workflows. Use when spawning agent teams, coordinating teammates, enforcing quality gates, or orchestrating the 11-agent SAFe pipeline.

## Quick Start

This skill is invoked manually with `/team-coordination`:

```
/team-coordination Implement {{TICKET_PREFIX}}-XXX user profile feature
```

## What This Skill Does

Provides patterns for Claude Code Agent Teams -- real-time multi-agent coordination with shared TaskList, inter-agent messaging, and SAFe quality gate enforcement via task dependencies.

## Trigger Keywords

| Primary | Secondary |
|---------|-----------|
| agent team | spawn teammates |
| team coordination | parallel agents |
| multi-agent | SAFe pipeline |
| TeamCreate | quality gates |

## Prerequisites

Agent Teams must be enabled (experimental):

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

## Related Skills

- [agent-coordination](../agent-coordination/) - Agent assignment without teams
- [orchestration-patterns](../orchestration-patterns/) - Single-agent orchestration

## Maintenance

| Field | Value |
|-------|-------|
| Last Updated | 2026-03-05 |
| Harness Version | {{HARNESS_VERSION}} |

---

*Full implementation details in [SKILL.md](SKILL.md)*
