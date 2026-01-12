---
name: orchestration-patterns
description: Unified workflow orchestration combining RPI phases, WTFB agent loop, QAS gate enforcement, Beads tracking, and sub-agent coordination. Use when running /rpi-full, managing multi-step implementations, or coordinating specialized agents.
---

# Orchestration Patterns Skill

> Unified workflow combining ConTStack RPI phases with WTFB agent loop and quality gates

## When This Skill Applies

Invoke this skill when:

- Starting multi-step implementation tasks (trigger: `/rpi-full`)
- Managing work across specialized agents (research, planning, implementation)
- Running long-running sessions (context > 30%)
- Preparing for merge (mandatory QAS gate)
- Session handoffs (trigger: `/handoff`)
- Coordinating parallel agent work
- Complex features requiring multiple phases

## Unified Workflow Overview

```
START: /rpi-full [task]
    |
    v
=== PHASE 1: RESEARCH (ConTStack) ===
    +-- Spawn codebase-locator (parallel)
    +-- Spawn codebase-analyzer (parallel)
    +-- Create research document
    +-- Create Beads issue (research label)
    |
    v
[HUMAN CHECKPOINT: "Continue to planning?"]
    |
    v
=== PHASE 2: PLAN (ConTStack) ===
    +-- Create implementation plan
    +-- Create Beads epic + phase issues
    +-- Set up dependency tree (bd dep add)
    +-- PRD approval required before implementation
    |
    v
[HUMAN CHECKPOINT: "Approve for implementation?"]
    |
    v
=== PHASE 3: IMPLEMENT (Hybrid WTFB Loop) ===
    |
    +-- For each phase:
    |     |
    |     [WTFB Agent Loop]
    |        +-- BSA: Create spec with acceptance criteria
    |        +-- BE/FE: Implement changes
    |        +-- Validate (bun lint && bun typecheck)
    |        +-- Test (bun test)
    |        +-- If FAIL --> Analyze --> Adjust --> Repeat
    |        +-- If PASS --> Evidence attachment
    |        +-- Exit State: "Ready for Review"
    |     |
    |     [HUMAN CHECKPOINT: "Phase complete, continue?"]
    |     |
    |     +-- Update Beads (bd close [phase-id])
    |
    v
=== QAS GATE (WTFB - MANDATORY) ===
    +-- Security Reviewer: RBAC + multi-tenant validation
    +-- Testing Specialist: E2E + coverage verification
    +-- Commit message validation
    +-- Evidence: QAS report in thoughts/shared/qa-validations/
    +-- Exit State: "Security Approved" + "QA Approved"
    |
    v
[HUMAN FINAL APPROVAL]
    |
    v
=== MERGE ===
    +-- PR creation via RTE role
    +-- Exit State: "Ready for Merge"
    +-- Beads epic closed
```

## RPI Phase Structure

### Phase 1: Research

```bash
# Spawn parallel research agents
# codebase-locator: Find relevant files
# codebase-analyzer: Analyze patterns

# Create research document
thoughts/shared/research/YYYY-MM-DD-{topic-slug}.md

# Create Beads issue
bd create "Research: [topic]" -t task -p 2 -l rpi,research --json
```

**Research Document Template:**

```markdown
# Research: [Topic]

## Task Description
[What we're investigating]

## Findings

### Relevant Files
- `/path/to/file.ts` - [description]

### Patterns Identified
1. [Pattern name]: [description]

### Risks/Concerns
- [Risk 1]
- [Risk 2]

## Recommendations
1. [Recommendation]

## Next Steps
- [ ] Create implementation plan
- [ ] Define acceptance criteria
```

### Phase 2: Plan

```bash
# Create implementation plan
thoughts/shared/plans/YYYY-MM-DD-{beads-id}-{feature-slug}.md

# Create Beads epic with phases
bd create "Epic: [Feature Name]" -t epic -p 2 -l rpi --json

# Create phase issues under epic
bd create "Phase 1: Foundation" -t task -l rpi,phase --json
bd dep add [phase1-id] [epic-id] --type child

bd create "Phase 2: Core Implementation" -t task -l rpi,phase --json
bd dep add [phase2-id] [epic-id] --type child

# Link dependencies between phases
bd dep add [phase2-id] [phase1-id] --type blocked-by
```

**Plan Document Template:**

```markdown
# Implementation Plan: [Feature Name]

## Overview
**Beads Epic:** ConTS-XXXX
**Research:** [link to research doc]

## Acceptance Criteria (PRD)
- [ ] AC1: [specific, testable criterion]
- [ ] AC2: [specific, testable criterion]

## Phase Breakdown

### Phase 1: Foundation (ConTS-XXX1)
**Objective:** [what this phase accomplishes]
**Dependencies:** None
**Files to Modify:**
- `path/to/file.ts` - [change description]

**Verification:**
- bun lint passes
- bun typecheck passes
- Manual: [verification step]

### Phase 2: Core Implementation (ConTS-XXX2)
**Objective:** [what this phase accomplishes]
**Dependencies:** Phase 1 complete
**Files to Modify:**
- `path/to/file.ts` - [change description]

**Verification:**
- bun test passes
- E2E: [test scenario]

### Phase 3: Integration (ConTS-XXX3)
**Objective:** [what this phase accomplishes]
**Dependencies:** Phase 2 complete
**Files to Modify:**
- `path/to/file.ts` - [change description]

**Verification:**
- Full E2E pass
- Security review required

## Risk Assessment
- [Risk]: [mitigation]

## Rollback Plan
[Steps to revert if needed]
```

### Phase 3: Implement

Each implementation phase follows the WTFB Agent Loop:

```
Phase Start
    |
    v
[BSA Role: Spec Creation]
    +-- Define acceptance criteria
    +-- Document DoD (Definition of Done)
    |
    v
[Developer Role: Implementation]
    |
    +-- Read target files
    +-- Apply changes
    +-- Run incremental validation
    |
    v
[Validation Loop]
    |
    +-- bun lint && bun typecheck
    +-- If FAIL:
    |     +-- Analyze error
    |     +-- Fix issue
    |     +-- Repeat validation
    +-- If PASS:
    |     +-- Continue
    |
    v
[Test Loop]
    |
    +-- bun test
    +-- If FAIL:
    |     +-- Analyze failure
    |     +-- Fix test or code
    |     +-- Repeat test
    +-- If PASS:
    |     +-- Continue
    |
    v
[Exit State: "Ready for Review"]
    |
    v
[HUMAN CHECKPOINT]
    |
    v
[Update Beads]
    +-- bd close [phase-id] --reason "Complete. Evidence: [link]"
```

## WTFB Agent Loop Integration

The WTFB agent loop provides efficient implementation cycles within RPI phases:

### Loop Flow

```
BSA --> BE/FE --> Validate --> QAS --> SecEng --> RTE
  |        |          |          |        |        |
  v        v          v          v        v        v
Spec    Code      Tests      QA Gate  Security   PR
                  Lint       Review   Review   Create
                  Types
```

### Exit States at Each Transition

| From | To | Exit State | Evidence Required |
|------|----|-----------|--------------------|
| BSA | BE/FE | "Spec Approved" | Acceptance criteria documented |
| BE/FE | QAS | "Ready for QAS" | Tests pass, lint clean |
| QAS | SecEng | "QA Approved" | E2E pass, coverage maintained |
| SecEng | RTE | "Security Approved" | RBAC validated, multi-tenant verified |
| RTE | HITL | "Ready for Merge" | PR created, CI green |

### Evidence Requirements

Each phase completion requires:

```markdown
## Phase [N] Evidence

**Beads Issue:** ConTS-XXXX
**Session ID:** [Claude session ID]

### Automated Verification
| Check | Status | Output |
|-------|--------|--------|
| Lint | PASS | `bun lint` clean |
| Types | PASS | `bun typecheck` clean |
| Tests | PASS | `bun test` all pass |

### Manual Verification
- [ ] [Acceptance criterion 1]
- [ ] [Acceptance criterion 2]

### Files Changed
- `path/to/file.ts` - [summary of changes]
```

## Mandatory QAS Gate

**CRITICAL: No merge without QAS validation**

### QAS Gate Requirements

1. **Independence Requirement**: QAS cannot be the same agent that wrote the code
2. **Security Reviewer**: Mandatory for auth/RBAC changes
3. **Testing Specialist**: Mandatory for UI/feature changes

### QAS Validation Checklist

```markdown
## QAS Validation Report - ConTS-XXXX

### Pre-Merge Checklist
- [ ] Commit message format: `type(scope): description [ConTS-XXX]`
- [ ] All acceptance criteria verified
- [ ] E2E tests passing: `bun test:e2e:docker:comprehensive`
- [ ] No security regressions
- [ ] No coverage decrease

### Security Review (SecEng)
- [ ] Auth guards present on new routes
- [ ] RBAC permissions checked: `requirePermission(ctx, "resource:action")`
- [ ] Multi-tenant isolation: `requireOrganization(ctx)` + organizationId filter
- [ ] No hardcoded secrets
- [ ] Webhook signatures verified (if applicable)

### Code Quality
- [ ] TypeScript strict mode compliance
- [ ] No `any` types without justification
- [ ] No `@ts-ignore` without documentation

### Approval
- Security Reviewer: [ ] APPROVED / [ ] NEEDS FIXES
- Testing Specialist: [ ] APPROVED / [ ] NEEDS FIXES
- QAS Exit State: [ ] Ready for Merge
```

**QAS Report Location:** `thoughts/shared/qa-validations/ConTS-XXXX-qa.md`

## Orchestration Patterns

### Sequential Pattern

Use for feature development with dependencies:

```
Convex Specialist --> Main Agent --> Security Reviewer --> Testing Specialist
    |                    |                  |                    |
    v                    v                  v                    v
 Schema              Frontend           Security             E2E Tests
 Backend             Integration        Audit                Coverage
```

### Parallel Pattern

Use for independent work streams:

```
                    +-- Testing Specialist (write tests)
                    |
Main Agent ---------+-- Security Reviewer (audit existing)
                    |
                    +-- Convex Specialist (schema work)

All 3 run simultaneously, then aggregate results
```

### Hierarchical Pattern

Use for complex delegations:

```
Main Agent
    |
    +-- Delegates to Convex Specialist
            |
            +-- Sub-delegates to Security Reviewer (auth helper validation)
                    |
                    +-- Returns: Security findings
            |
            +-- Returns: Schema + backend complete with security validated
    |
    +-- Returns: Feature complete
```

### Review and Approve Pattern

Use for quality gates:

```
Implementation --> Security Reviewer --> PASS/FAIL
                       |
                       +-- If FAIL: Return with findings
                       +-- If PASS: Continue to QAS

                           QAS --> PASS/FAIL
                            |
                            +-- If FAIL: Return with findings
                            +-- If PASS: Ready for merge
```

## Sub-Agent Spawning

### When to Spawn Sub-Agents

- Context window > 30%
- Parallel research needed
- Specialist domain knowledge required
- Long-running tasks (>30 minutes expected)

### Available Sub-Agents

| Agent | Purpose | Spawn Trigger |
|-------|---------|---------------|
| `codebase-locator` | Find relevant files | Research phase start |
| `codebase-analyzer` | Analyze code patterns | Research phase |
| `research-compiler` | Synthesize findings | Research phase end |
| `plan-validator` | Validate plans | Plan phase end |
| `beads-sync` | Beads operations | Beads bulk updates |

### Spawning Pattern

```markdown
## Sub-Agent Task: [Agent Name]

**Objective:** [What to accomplish]

**Context:**
- Research doc: [path]
- Relevant files: [list]

**Deliverables:**
1. [Deliverable 1]
2. [Deliverable 2]

**Return Format:**
[Expected output structure]
```

### Context Isolation Benefits

- Prevents token bloat in main context
- Enables parallel execution
- Maintains coherent main context
- Allows specialist depth without breadth penalty

## Validation Commands

### Pre-Phase Validation

```bash
# Run before starting any phase
bun lint && bun typecheck
```

### Post-Phase Validation

```bash
# Run after completing any phase
bun test
```

### Pre-Merge Validation (Full QAS)

```bash
# Complete validation suite
bun lint && bun typecheck && bun test

# E2E validation
bun test:e2e:docker:comprehensive

# Coverage check
bun test:coverage
```

### Validation Command Reference

| Command | When to Run | Must Pass |
|---------|------------|-----------|
| `bun lint` | Before commit | Yes |
| `bun typecheck` | Before commit | Yes |
| `bun test` | After phase complete | Yes |
| `bun test:e2e:docker:comprehensive` | Before QAS gate | Yes |
| `bun test:coverage` | Before merge | Coverage not decreased |

## Human Checkpoints

### Checkpoint 1: Post-Research

```markdown
## Research Complete - Ready for Planning?

**Research Document:** thoughts/shared/research/YYYY-MM-DD-{slug}.md
**Beads Issue:** ConTS-XXXX

### Key Findings
1. [Finding 1]
2. [Finding 2]

### Recommended Approach
[Recommendation]

### Questions for Human
- [Question 1]
- [Question 2]

**Continue to planning phase?** [Y/N]
```

### Checkpoint 2: Post-Plan (PRD Approval)

```markdown
## Plan Complete - Approve for Implementation?

**Plan Document:** thoughts/shared/plans/YYYY-MM-DD-{beads-id}-{slug}.md
**Beads Epic:** ConTS-XXXX

### Phase Summary
| Phase | Description | Estimated Effort |
|-------|-------------|------------------|
| 1 | [description] | [time] |
| 2 | [description] | [time] |

### Acceptance Criteria
- [ ] AC1: [criterion]
- [ ] AC2: [criterion]

### Risk Assessment
- [Risk]: [mitigation]

**Approve for implementation?** [Y/N]
```

### Checkpoint 3: Post-Phase (Verification)

```markdown
## Phase [N] Complete - Verify and Continue?

**Phase:** [description]
**Beads Issue:** ConTS-XXX[N]

### Automated Verification
- [x] Lint: PASS
- [x] Types: PASS
- [x] Tests: PASS

### Manual Verification Required
- [ ] [Manual check 1]
- [ ] [Manual check 2]

**Verify and continue to Phase [N+1]?** [Y/N]
```

### Checkpoint 4: Pre-Merge (Final Approval)

```markdown
## QAS Gate Complete - Ready for Merge?

**Epic:** ConTS-XXXX
**All Phases:** Complete

### Gate Status
- Security Reviewer: APPROVED
- Testing Specialist: APPROVED
- All validation: PASS

### Evidence Links
- Research: [link]
- Plan: [link]
- QAS Report: [link]

### PR Ready
- Branch: ConTS-XXXX-{description}
- Title: feat(scope): description [ConTS-XXXX]

**Approve merge?** [Y/N]
```

## Beads Integration

### Session Start Protocol

```bash
# Get latest issues
bd sync

# See unblocked work
bd ready --json

# Check in-progress work
bd list --status in_progress --json
```

### During Work

```bash
# Create issue for discovered work
bd create "Discovered: [description]" -t [type] -p [priority] \
  -l discovered,rpi --json

# Link to current work
bd dep add [new-id] [current-phase-id] --type discovered-from

# Update status
bd update [phase-id] --status in_progress --json
```

### Phase Completion

```bash
# Close phase with evidence
bd close [phase-id] --reason "Complete. Evidence posted. Tests passing."

# View dependency tree
bd dep tree [epic-id]

# Check next ready work
bd ready --json
```

### Epic Completion

```bash
# Close epic when all phases done
bd close [epic-id] --reason "Implementation complete. All phases verified. QAS approved."
```

### Labels Reference

| Label | Purpose |
|-------|---------|
| `rpi` | RPI workflow related |
| `research` | Research phase |
| `plan` | Planning phase |
| `phase` | Implementation phase |
| `discovered` | Found during other work |
| `blocked` | Waiting on something |
| `security` | Security-related |
| `urgent` | High priority |

## Context Management

### Context Thresholds

| Threshold | Action |
|-----------|--------|
| < 30% | Continue working freely |
| 30-40% | Consider compaction soon |
| > 40% | Run `/compact` immediately |

### Compaction Trigger

When context > 40%:

1. Complete current atomic change
2. Run validation (bun lint && bun typecheck)
3. Update Beads status
4. Run `/compact` to create handoff
5. Recommend new session with handoff context

### Handoff Document Location

`thoughts/shared/handoffs/YYYY-MM-DD-HHmm-handoff.md`

## Escalation Protocol

### Time-Based Escalation

| Blocked Duration | Action |
|-----------------|--------|
| > 1 hour | Notify in handoff |
| > 4 hours | Create blocker issue (bd create -l blocked) |
| > 8 hours | Escalate to human review |

### Domain-Based Escalation

| Issue Type | Escalate To |
|------------|-------------|
| Architecture ambiguity | Create ADR, request human decision |
| Security concern | Security Reviewer (mandatory gate) |
| Cross-team dependency | Document in handoff, create blocked issue |
| Schema breaking change | Request explicit human approval |

## File Locations

```
thoughts/
  shared/
    research/         # YYYY-MM-DD-{slug}.md
    plans/            # YYYY-MM-DD-{beads-id}-{slug}.md
    handoffs/         # YYYY-MM-DD-HHmm-handoff.md
    qa-validations/   # ConTS-XXXX-qa.md
```

## Quick Reference Commands

| Command | Purpose |
|---------|---------|
| `/rpi-full [task]` | Execute complete workflow |
| `/research [topic]` | Research phase only |
| `/plan [task]` | Planning phase only |
| `/implement [plan]` | Implementation with WTFB loop |
| `/status` | Show workflow status + Beads |
| `/compact` | Create session handoff |
| `/handoff` | End-of-session protocol |

## Anti-Patterns to Avoid

| Anti-Pattern | Why Bad | Solution |
|--------------|---------|----------|
| Skip research | Missing context = bad plans | Always run /research first |
| Skip QAS gate | Self-review bias | QAS is MANDATORY |
| No evidence in Beads | No audit trail | Attach evidence every phase |
| Ignore CI failures | Broken code reaches dev | Fix in WTFB loop |
| Continue when blocked | Waste time | Escalate after 4 hours |
| Skip human checkpoints | Loss of control | Always pause for approval |
| Ignore context window | Context overflow | Monitor via /status |
| Merge without security review | Vulnerabilities | Security gate is mandatory for auth changes |

## Authoritative References

- **RPI Framework**: `.claude/RPI-README.md`
- **RPI Quick Reference**: `.claude/RPI-QUICKREF.md`
- **Agents**: `.claude/agents/*.md`
- **Commands**: `.claude/commands/*.md`
- **Testing Patterns**: `.claude/skills/testing-patterns/SKILL.md`
- **Security Audit**: `.claude/skills/security-audit/SKILL.md`
- **Safe Workflow**: `.claude/skills/safe-workflow/SKILL.md`
