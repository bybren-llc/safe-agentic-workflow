---
name: agent-coordination
description: Agent assignment matrix, blocker escalation, and TDM coordination patterns. Use when assigning work to specialists, managing blockers, or coordinating multi-agent workflows.
---

# Agent Coordination Skill

## Purpose

Guide correct agent assignment, blocker escalation, and delivery coordination following team role boundaries.

## When This Skill Applies

- Assigning work to specialist agents
- Managing blockers across agents
- Coordinating multi-agent workflows
- Escalating issues

## Agent Assignment Matrix (MANDATORY)

| Work Type           | Correct Agent     | Never Use           |
| ------------------- | ----------------- | ------------------- |
| Database/Migrations | Data Engineer     | BE Developer        |
| Security/RLS        | Security Engineer | QAS                 |
| Documentation       | Tech Writer       | BE/FE Developer     |
| Specs/Planning      | BSA               | Any implementation  |
| Architecture        | System Architect  | Direct to developer |
| API Routes          | BE Developer      | FE Developer        |
| UI Components       | FE Developer      | BE Developer        |
| Testing/QA          | QAS               | Implementation team |
| PR/Releases         | RTE               | Developers          |

## Pre-Implementation Gate

**MANDATORY** before any implementation:

1. BSA creates spec with acceptance criteria
2. System Architect reviews patterns
3. THEN implementation can begin

## Blocker Escalation Protocol

| Condition              | Escalate To | Deadline    |
| ---------------------- | ----------- | ----------- |
| Blocker > 1 hour       | TDM         | Immediately |
| Blocker > 4 hours      | ARCHitect   | Urgent      |
| Architecture ambiguity | ARCHitect   | Before work |
| Cross-team dependency  | TDM + POPM  | Same day    |

## Reference

- **Agent Assignment Matrix**: `docs/workflow/TDM_AGENT_ASSIGNMENT_MATRIX.md`
- **Agent Workflow SOP**: `docs/sop/AGENT_WORKFLOW_SOP.md`
