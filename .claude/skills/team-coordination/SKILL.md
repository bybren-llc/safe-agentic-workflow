---
name: team-coordination
description: Agent Teams orchestration patterns for multi-agent SAFe workflows. Use when spawning agent teams, coordinating teammates, enforcing quality gates via task dependencies, or orchestrating the 11-agent SAFe pipeline. Covers TeamCreate, SendMessage, shared TaskList, and SAFe gate enforcement.
disable-model-invocation: true
argument-hint: "[task-description]"
allowed-tools: Read, Bash, Grep, Glob, Task
---

# Team Coordination Skill

## Purpose

Orchestrate Claude Code Agent Teams for SAFe multi-agent workflows. This skill provides patterns for spawning teams, assigning work by role, enforcing quality gates via task dependencies, and managing the full delivery pipeline.

## Prerequisites

Agent Teams are **experimental** and must be enabled:

```json
// .claude/settings.json or settings.local.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

## When This Skill Applies

Invoke this skill when:

- Orchestrating work across multiple agent roles (FE, BE, QAS, etc.)
- Spawning a team for a Feature or Epic-level deliverable
- Coordinating parallel implementation with quality gate enforcement
- Running competing hypothesis debugging with multiple agents
- Performing parallel code review across security, performance, and test coverage

## Agent Teams vs Subagents vs Background Agents

| Approach | Communication | Coordination | Best For |
|----------|--------------|--------------|----------|
| **Agent Teams** | DMs, broadcasts | Shared TaskList with dependencies | Complex multi-role SAFe workflows |
| **Subagents** | Report back only | Main agent manages | Focused tasks, results only |
| **Background Agents** | None | None | Fire-and-forget parallel work |

**Use Agent Teams when**: teammates need to share findings, challenge each other, and coordinate via SAFe gates.
**Use Subagents when**: you need quick, focused workers that report back.
**Use Background Agents when**: tasks are independent and don't need coordination.

## SAFe Team Patterns

### Pattern 1: TDM as Team Lead

The TDM (Technical Delivery Manager) is the natural team lead in the 11-agent model:

```
Create an agent team for {{TICKET_PREFIX}}-XXX implementation.

Team lead (TDM) responsibilities:
- Spawn teammates by role (BE, FE, QAS, etc.)
- Create tasks with SAFe gate dependencies
- Monitor progress and steer teammates
- Synthesize results and escalate blockers

Spawn these teammates:
- BE Developer: Implement API endpoints per spec
- FE Developer: Implement UI components per spec
- QAS: Validate acceptance criteria after implementation
```

### Pattern 2: Task Dependencies for Quality Gates

Use `addBlockedBy` / `addBlocks` to enforce the SAFe pipeline:

```
Task structure for {{TICKET_PREFIX}}-XXX:

1. "Implement API endpoint" (owner: be-developer)
2. "Implement UI components" (owner: fe-developer)
3. "QAS validation" (owner: qas, blockedBy: [1, 2])
4. "Create PR" (owner: rte, blockedBy: [3])
5. "Stage 1 review" (owner: system-architect, blockedBy: [4])

This enforces: Implementation → QAS → RTE → Architect Review
```

### Pattern 3: Spawning Teammates by Role

Map harness agent roles to teammate configurations:

```
Spawn teammates with role-specific prompts:

BE Developer teammate:
- Load: api-patterns, rls-patterns skills
- Task: Implement endpoints per spec at specs/{{TICKET_PREFIX}}-XXX-spec.md
- Constraint: All DB operations must use RLS context helpers

FE Developer teammate:
- Load: frontend-patterns skill
- Task: Implement UI per spec
- Constraint: Follow component patterns in patterns_library/ui/

QAS teammate:
- Load: testing-patterns skill
- Task: Execute testing strategy from spec
- Constraint: Must verify all acceptance criteria before approving
- Plan approval required (require plan approval before QAS makes changes)
```

### Pattern 4: Parallel Code Review

```
Create an agent team to review PR #XXX. Spawn three reviewers:
- Security reviewer: Focus on RLS enforcement, input validation, auth checks
- Architecture reviewer: Focus on pattern compliance, separation of concerns
- Test reviewer: Focus on test coverage, edge cases, acceptance criteria

Have them each review independently, then share and challenge findings.
```

### Pattern 5: Competing Hypothesis Debugging

```
Users report [issue description]. Spawn 3-4 teammates to investigate:
- Teammate 1: Investigate [hypothesis A]
- Teammate 2: Investigate [hypothesis B]
- Teammate 3: Investigate [hypothesis C]

Have them talk to each other to challenge and disprove theories.
Update findings as consensus emerges.
```

## Communication Patterns

### Direct Messages (Most Common)

```
Send a message to the BE developer:
"The API endpoint needs to handle pagination. Check patterns_library/api/
for the standard pagination pattern before implementing."
```

### Broadcast (Use Sparingly -- Expensive)

```
Broadcast to all teammates:
"STOP: Architecture decision changed. The auth middleware now uses
{{AUTH_PROVIDER}} session tokens instead of JWT. Check the updated
spec before continuing."
```

Only broadcast for:
- Critical blocking issues
- Architecture changes affecting everyone
- Stop-the-line announcements

### Shutdown Coordination

```
When all tasks are complete:
1. Send shutdown_request to each teammate
2. Wait for approval from each
3. Clean up team resources via TeamDelete
```

## Quality Gate Hooks

### TeammateIdle Hook

Validates teammates completed their work before going idle:

```json
{
  "hooks": {
    "TeammateIdle": [{
      "command": "bash -c 'echo \"Verify all assigned tasks are completed before going idle\"'",
      "description": "Validate teammate completed assigned work"
    }]
  }
}
```

Exit code 2 sends feedback and keeps the teammate working.

### TaskCompleted Hook

Validates task output meets criteria before allowing completion:

```json
{
  "hooks": {
    "TaskCompleted": [{
      "command": "bash -c 'echo \"Verify acceptance criteria met before marking complete\"'",
      "description": "Validate task meets acceptance criteria"
    }]
  }
}
```

Exit code 2 prevents completion and sends feedback.

## Team Sizing Guidelines

| Work Scope | Recommended Size | Tasks per Teammate |
|-----------|-----------------|-------------------|
| Single Story | 2-3 teammates | 3-4 tasks each |
| Feature (multi-story) | 3-5 teammates | 5-6 tasks each |
| Epic (parallel features) | 5-8 teammates | 5-6 tasks each |

**Rules of thumb**:
- Start with fewer teammates; scale up if needed
- Each teammate should own different files (avoid conflicts)
- 5-6 tasks per teammate keeps everyone productive
- More than 8 teammates rarely helps (coordination overhead)

## Known Limitations

- **Experimental**: Enable via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`
- **No session resumption**: `/resume` doesn't restore in-process teammates
- **One team per session**: Clean up before starting a new team
- **No nested teams**: Teammates cannot spawn their own teams
- **Permissions inherit**: All teammates start with lead's permission mode
- **Token cost**: ~7x single session in plan mode

## Authoritative References

- **Official Docs**: [Agent Teams](https://code.claude.com/docs/en/agent-teams)
- **Hooks Reference**: [Hooks](https://code.claude.com/docs/en/hooks)
- **Subagents Comparison**: [Subagents](https://code.claude.com/docs/en/sub-agents)
- **Harness Agents**: `AGENTS.md`
- **Team Config**: `.claude/team-config.json`
