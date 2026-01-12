---
name: agent-coordination
description: SAFe-lite + RPI unified agent coordination with clear role boundaries, exit states, dual issue tracking (Beads + Linear), independence gates, and blocker escalation. Use when orchestrating multi-agent work, managing handoffs, enforcing quality gates, or coordinating complex feature development.
---

# Agent Coordination Skill (Unified SAFe-lite + RPI)

> **ConTStack Configuration**: Ticket prefix `ConTS-`, bun commands, Convex backend

## Purpose

Guide unified agent coordination that combines:
- **SAFe-lite roles** with explicit exit states and handoff protocols
- **RPI workflow** (Research-Plan-Implement) for structured development
- **Dual issue tracking** (Beads for agents, Linear for evidence/specs)
- **Independence gates** (QAS and SecEng cannot be collapsed)
- **Context isolation** via sub-agent spawning

## When This Skill Applies

Invoke this skill when:

- Starting multi-agent work on a feature
- Orchestrating specialist handoffs
- Enforcing quality gates (QAS, SecEng)
- Managing blocker escalation
- Coordinating complex feature development
- Creating implementation evidence
- Pre-deployment validation

---

## Agent Role Hierarchy

```
                     +---------------------+
                     |    HITL (Human)     |  <- Final merge authority
                     +----------+----------+
                                |
                     +----------v----------+
                     |    Main Agent       |  <- Primary orchestrator
                     +----------+----------+
                                |
          +---------------------+---------------------+
          |                     |                     |
+---------v---------+ +---------v---------+ +---------v---------+
|  BSA Role         | | System Architect  | | Domain Specialists|
| (Main Agent)      | | (Complex Review)  | | (Feature Work)    |
+-------------------+ +-------------------+ +-------------------+
          |
          +---> BE Developer (Convex Specialist) -> API/Backend
          +---> FE Developer (Frontend)          -> UI/Components
          +---> QAS (Testing Specialist)         -> Testing [GATE]
          +---> SecEng (Security Reviewer)       -> Security [GATE]
          +---> RTE Role (Main Agent)            -> PR/Release
```

---

## SAFe-lite Roles with Exit States

### Role Definitions

| Role | Agent | Responsibility | Exit State | Exit Criteria |
|------|-------|----------------|------------|---------------|
| **BSA** | Main Agent | Specs with AC/DoD | Spec Approved | AC documented in Linear |
| **BE Developer** | Convex Specialist | Convex implementation | Ready for QAS | Tests pass, lint clean |
| **FE Developer** | Frontend Specialist | UI implementation | Ready for QAS | Tests pass, lint clean |
| **QAS** | Testing Specialist | Testing/validation | QA Approved | Coverage met, E2E pass |
| **SecEng** | Security Reviewer | Security audit | Security Approved | Audit passes |
| **RTE** | Main Agent | Release coordination | Ready for HITL | PR created, CI green |

### Exit State Flow

```
BSA (Spec) -> "Spec Approved"
     |
BE/FE Developer -> "Ready for QAS"
     |
QAS (Testing) -> "QA Approved"
     |
SecEng (Security) -> "Security Approved"
     |
RTE (Release) -> "Ready for HITL Review"
     |
HITL -> MERGED
```

### Exit State Requirements

#### 1. BSA Exit: "Spec Approved"

```markdown
**Exit Criteria**:
- [ ] Acceptance criteria defined
- [ ] Definition of Done specified
- [ ] Technical approach documented
- [ ] Dependencies identified
- [ ] Linear spec created (ConTS-XXX)

**Evidence Location**: Linear issue description
```

#### 2. Developer Exit: "Ready for QAS"

```markdown
**Exit Criteria**:
- [ ] Implementation complete
- [ ] Unit tests written and passing
- [ ] Lint and typecheck passing
- [ ] Code committed to feature branch
- [ ] Beads status updated

**Validation Command**:
bun lint && bun typecheck && bun test

**Evidence Location**: Linear comment + Beads notes
```

#### 3. QAS Exit: "QA Approved"

```markdown
**Exit Criteria**:
- [ ] E2E tests passing
- [ ] Test coverage acceptable (>80%)
- [ ] No regressions detected
- [ ] All acceptance criteria verified
- [ ] Test evidence documented

**Validation Command**:
bun test:e2e:docker:comprehensive

**Evidence Location**: Linear comment with test report
```

#### 4. SecEng Exit: "Security Approved"

```markdown
**Exit Criteria**:
- [ ] Auth helpers validated
- [ ] Multi-tenant isolation verified
- [ ] RBAC permissions correct
- [ ] No vulnerabilities found
- [ ] Security checklist complete

**Evidence Location**: Linear comment with audit report

**Audit Report Template**:
## Security Audit - ConTS-XXX
- **Date**: [date]
- **Status**: APPROVED / NEEDS_FIXES
- **Findings**: [summary]
- **Checklist**: [link to completed checklist]
```

#### 5. RTE Exit: "Ready for HITL Review"

```markdown
**Exit Criteria**:
- [ ] PR created with proper template
- [ ] All CI checks passing
- [ ] QAS and SecEng gates passed
- [ ] Evidence links in PR description
- [ ] Beads issues closed

**Evidence Location**: GitHub PR
```

---

## Independence Gates (MANDATORY)

### Gate Rules

QAS and SecEng gates **cannot be collapsed** into developer roles:

| Gate | Requirement | Rationale |
|------|-------------|-----------|
| **QAS Gate** | Testing Specialist or explicit "Self-QA (non-independent)" label | Prevents self-review bias |
| **SecEng Gate** | Security Reviewer or explicit "Self-Security (non-independent)" label | Security requires fresh eyes |

### Gate Triggers

| Change Type | QAS Gate | SecEng Gate |
|-------------|----------|-------------|
| UI changes | REQUIRED | Optional |
| Auth/RBAC changes | Optional | REQUIRED |
| Schema changes | REQUIRED | REQUIRED |
| API endpoints | REQUIRED | REQUIRED |
| Infrastructure | Optional | REQUIRED |
| Documentation only | Skip | Skip |

### Self-Review Exception

When resources are limited, self-review is allowed ONLY with explicit labeling:

```markdown
## Self-QA Declaration (Non-Independent)

I am performing QA on my own work due to [reason].

**Additional verification performed**:
- [ ] Reviewed code after 24-hour delay
- [ ] Used automated testing extensively
- [ ] Documented test scenarios

**Risk acknowledgment**: This is non-independent review.
```

---

## Dual Issue Tracking

### System Responsibilities

| System | Use Case | Agent Role |
|--------|----------|------------|
| **Beads** | Task management, dependencies, status | Agent work tracking |
| **Linear** | Evidence, specs, PRDs, audits | Human-visible documentation |

### Beads Commands

```bash
# Session Start Protocol
bd sync                              # Get latest from Linear
bd ready --json                      # See unblocked work
# Check thoughts/shared/handoffs/    # Review previous context

# During Session
bd create "Description" -t [bug|task|feature|epic] -p [0-4] -l [labels]
bd dep add [child-id] [parent-id] --type discovered-from
bd update [issue-id] --status in_progress

# Session End
bd close [issue-id] --reason "Completion summary"
```

### Linear Usage

```text
# Read issue
mcp__linear-mcp__get_issue({ id: "ConTS-XXX" })

# Create spec (BSA role)
mcp__linear-mcp__create_issue({
  title: "spec: Feature description",
  team: "ConTStack",
  description: "## Acceptance Criteria\n- [ ] AC1\n- [ ] AC2\n\n## Definition of Done\n- [ ] Tests passing\n- [ ] Lint clean\n- [ ] Security approved",
  labels: ["spec", "sprint-X"],
})

# Post evidence (Developer/QAS/SecEng)
mcp__linear-mcp__create_comment({
  issueId: "ConTS-XXX",
  body: "**Exit State: Ready for QAS**\n\n[evidence template]",
})
```

### Evidence Flow (Beads + Linear)

```
BEADS                              LINEAR
-----                              ------
Issue created
  |
Research started
  |
Plan created ----------------------> Spec created (BSA AC)
  |
Implementation started
  |
"Ready for QAS" -------------------> Dev Evidence posted
  |
QAS review
  |
"QA Approved" ---------------------> Test Evidence posted
  |
SecEng review
  |
"Security Approved" ---------------> Audit Record posted
  |
"Ready for HITL" ------------------> PR created with links
  |
Issue closed (bd close)            PR merged, ticket Done
```

---

## RPI Workflow Integration

### Workflow Commands

| Command | Purpose | Agent Role |
|---------|---------|------------|
| `/research [topic]` | Investigate codebase | Any |
| `/plan [task]` | Create implementation plan | BSA |
| `/implement [plan]` | Execute phase by phase | Developer |
| `/status` | Show workflow status | Any |
| `/handoff` | End-of-session protocol | Any |

### RPI + SAFe Integration

```
/research [topic]
     |
     v
Research Document + Beads Issue
     |
     v
/plan [task]
     |
     v
Implementation Plan + Linear Spec (BSA exit: "Spec Approved")
     |
     v
/implement [plan]
     |
     +-- Phase 1: Backend (BE Developer)
     |       |
     |       v
     |   "Ready for QAS" exit
     |
     +-- Phase 2: Frontend (FE Developer)
     |       |
     |       v
     |   "Ready for QAS" exit
     |
     +-- Phase 3: Testing (QAS Gate)
     |       |
     |       v
     |   "QA Approved" exit
     |
     +-- Phase 4: Security (SecEng Gate)
             |
             v
         "Security Approved" exit
     |
     v
/handoff (RTE: "Ready for HITL")
```

### Pre-Implementation Gate

Before `/implement` can proceed:

```markdown
**Gate Check**:
- [ ] BSA spec exists in Linear (ConTS-XXX)
- [ ] Acceptance criteria defined
- [ ] Definition of Done specified
- [ ] Plan approved (for complex tasks)

**Failure Action**: Return to /plan phase
```

---

## Sub-Agent Spawning

### Context Isolation Patterns

Use sub-agents to prevent context bloat:

```
Main Agent
    |
    +-- codebase-locator    -> Find relevant files
    +-- codebase-analyzer   -> Analyze code patterns
    +-- research-compiler   -> Synthesize findings
    +-- plan-validator      -> Validate plans
    +-- beads-sync          -> Beads operations
```

### Specialist Agent Files

| Agent | File | Primary Role |
|-------|------|--------------|
| Testing Specialist | `.claude/agents/tester.json` | QAS Gate |
| Security Reviewer | `.claude/agents/security.json` | SecEng Gate |
| Convex Specialist | `.claude/agents/convex.json` | BE Developer |
| Frontend Specialist | `.claude/agents/contstack-frontend.json` | FE Developer |

### Orchestration Patterns

| Pattern | Use Case | Flow |
|---------|----------|------|
| **Sequential** | Standard feature | BSA -> BE -> FE -> QAS -> SecEng -> RTE |
| **Parallel** | Independent tasks | BE + FE simultaneously, then gates |
| **Hierarchical** | Complex nested work | BE -> delegates to SecEng for auth review -> returns |
| **Review and Approve** | Gate enforcement | QAS/SecEng -> PASS/FAIL -> iterate if FAIL |

---

## Handoff Protocol

### Exit State Handoff Template

```markdown
## Handoff Document - ConTS-XXX

**Session ID**: [Claude session ID]
**Agent**: [role/specialist name]
**Exit State**: [current exit state]

### Work Completed
- [x] Task 1
- [x] Task 2
- [ ] Task 3 (blocked/pending)

### Evidence
- **Linear**: ConTS-XXX (spec/evidence comments)
- **Beads**: [issue-id] - [status]
- **Branch**: ConTS-XXX-description
- **PR**: #XXX (if created)

### Validation
bun lint && bun typecheck && bun test
# Output: All checks passed

### Next Agent
- **Required Role**: [QAS/SecEng/RTE]
- **Action Required**: [what needs to happen next]
- **Blockers**: [any blocking issues]

### Context for Next Agent
[Key information the next agent needs to know]
```

### Session End Protocol

```bash
# 1. Update Beads
bd update [issue-id] --status [status]
# Or if complete:
bd close [issue-id] --reason "Exit state: [state]. Evidence: ConTS-XXX"

# 2. Post evidence to Linear
mcp__linear-mcp__create_comment({
  issueId: "ConTS-XXX",
  body: "[handoff template]"
})

# 3. Create handoff document
# Write to: thoughts/shared/handoffs/YYYY-MM-DD-HHmm-handoff.md

# 4. Git status clean
git status
# Ensure all changes committed or stashed
```

---

## Blocker Escalation

### Time-Boxed Escalation

| Condition | Escalate To | Deadline | Action |
|-----------|-------------|----------|--------|
| Blocker > 30 min | Main Agent | Immediately | Document and escalate |
| Blocker > 2 hours | HITL | Urgent | Request human input |
| Architecture ambiguity | Main Agent | Before work | Stop and clarify |
| Cross-agent dependency | Main Agent | Same session | Coordinate handoff |
| Security concern | Security Reviewer | Immediately | Stop-the-line |

### Blocker Documentation

```markdown
## Blocker Report

**Issue**: ConTS-XXX
**Blocker Type**: [Technical/Dependency/Unclear Requirements/Security]
**Severity**: [Low/Medium/High/Critical]
**Time Blocked**: [duration]

### Description
[What is blocking progress]

### Attempted Resolutions
1. [What was tried]
2. [What was tried]

### Required to Unblock
- [ ] [Specific action needed]
- [ ] [Who needs to take action]

### Impact if Unresolved
[What happens if this isn't resolved]
```

### Escalation Commands

```bash
# Document blocker in Beads
bd create "BLOCKER: [description]" -t bug -p 0 -l "blocker,ConTS-XXX"

# Link to parent issue
bd dep add [blocker-id] [parent-id] --type blocks

# Post to Linear for visibility
mcp__linear-mcp__create_comment({
  issueId: "ConTS-XXX",
  body: "**BLOCKER ESCALATION**\n\n[blocker report]"
})
```

---

## Workflow Methods

### Method 1: Simple Task (Single Agent)

```
Main Agent -> Specialist -> Done
```

- Use for: Bug fixes, small enhancements
- Gates: Optional (based on change type)
- Evidence: Beads close reason only

### Method 2: Standard Feature (Full Flow)

```
BSA (Spec) -> BE/FE Developer -> QAS -> SecEng -> RTE -> HITL
```

- Use for: New features, significant changes
- Gates: QAS + SecEng mandatory
- Evidence: Full Linear trail

### Method 3: Complex Investigation (Parallel)

```
Main Agent
    |
    +-- Convex Specialist (backend research)
    +-- Security Reviewer (security implications)
    +-- Testing Specialist (test impact)
    |
    v
Main Agent aggregates findings
```

- Use for: Architecture decisions, large refactors
- Gates: Depends on findings
- Evidence: Research document + Beads

### Method 4: System Architect Trigger

```
Specialist -> "Complex code detected" -> System Architect Review -> Continue
```

**Complexity Triggers** (trigger mandatory architect review):
- Bash script > 100 lines
- TypeScript file > 200 lines
- CI/CD changes
- Schema migrations
- Security-critical code

---

## Evidence Templates

### Dev Evidence Template

```markdown
**Dev Evidence**
**Session ID**: [session ID]
**Agent**: [BE Developer / FE Developer]
**Ticket**: ConTS-XXX

**Exit State**: Ready for QAS

**Work Completed**:
- [x] Feature implemented
- [x] Unit tests added
- [x] Lint passing

**Branch**: ConTS-XXX-description
**Commits**:
- abc1234: feat(scope): description [ConTS-XXX]

**Validation**:
bun lint && bun typecheck && bun test
# All checks passed

**Beads Tracking**: [beads-id] - in_progress

**Next Steps**: Ready for QAS review
```

### QAS Evidence Template

```markdown
**QA Evidence**
**Session ID**: [session ID]
**Agent**: Testing Specialist
**Ticket**: ConTS-XXX

**Exit State**: QA Approved

**Testing Completed**:
- [x] E2E tests passing
- [x] Unit test coverage: XX%
- [x] Acceptance criteria verified:
  - [x] AC1: [verified]
  - [x] AC2: [verified]
- [x] No regressions detected

**Test Results**:
bun test:e2e:docker:comprehensive
# 12/12 tests passed

**Beads Tracking**: [beads-id] - completed

**Next Steps**: Ready for Security review
```

### Security Audit Template

```markdown
**Security Audit**
**Session ID**: [session ID]
**Agent**: Security Reviewer
**Ticket**: ConTS-XXX

**Exit State**: Security Approved

**Audit Scope**:
- [x] Auth helper validation
- [x] Multi-tenant isolation
- [x] RBAC permissions
- [x] Input validation

**Findings**:
| Severity | Issue | Status |
|----------|-------|--------|
| - | No issues found | N/A |

**Security Checklist**:
- [x] All queries use requireOrganization
- [x] Mutations use requirePermission
- [x] Client queries gated with isAuthenticated
- [x] No hardcoded secrets
- [x] Webhook signatures verified

**Beads Tracking**: [beads-id] - completed

**Approval**: Security Reviewer approves for deployment
```

---

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Exit state compliance | 100% | All handoffs have explicit exit state |
| Pre-implementation gate | 100% | BSA spec exists before /implement |
| Independence gate pass | 100% for triggers | QAS/SecEng gates enforced |
| Evidence posted | 100% | All exit states have Linear evidence |
| Blocker escalation SLA | <2 hours | Blockers escalated within threshold |
| Session handoff | 100% | All sessions end with handoff doc |

---

## Quick Reference

### Agent Assignment Matrix

| Task Type | Primary Agent | QAS Gate | SecEng Gate |
|-----------|--------------|----------|-------------|
| API endpoint | Convex Specialist | Required | Required |
| UI component | Frontend Specialist | Required | Optional |
| Auth changes | Security Reviewer | Optional | Required |
| Schema changes | Convex Specialist | Required | Required |
| Test creation | Testing Specialist | Self | Optional |
| Bug fix | Domain specialist | Optional | If auth-related |
| Documentation | Main Agent | Skip | Skip |

### Exit State Quick Checks

```bash
# BSA Exit Check
# Does Linear issue ConTS-XXX exist with AC and DoD?

# Developer Exit Check
bun lint && bun typecheck && bun test

# QAS Exit Check
bun test:e2e:docker:comprehensive

# SecEng Exit Check
# Security audit template complete in Linear?

# RTE Exit Check
# PR created with all evidence links?
# CI checks passing?
```

### Session Start Protocol

```bash
# 1. Sync issues
bd sync

# 2. Find ready work
bd ready --json

# 3. Check handoffs
ls thoughts/shared/handoffs/ | tail -5

# 4. Start work
bd update [issue-id] --status in_progress
```

---

## Authoritative References

- **Agent Definitions**: `.claude/agents/*.json`
- **Testing Patterns**: `/tests/CLAUDE.md`
- **Security Patterns**: `/packages/backend/CLAUDE.md`
- **Convex Backend**: `/packages/backend/CLAUDE.md`
- **Frontend Patterns**: `/apps/app/CLAUDE.md`
- **RPI Workflow**: `/CLAUDE.md` (RPI Workflow Integration section)
- **Handoff Location**: `thoughts/shared/handoffs/`
- **Research Location**: `thoughts/shared/research/`
- **Plans Location**: `thoughts/shared/plans/`
