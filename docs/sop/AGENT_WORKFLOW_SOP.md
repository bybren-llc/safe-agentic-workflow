# Agent Workflow Standard Operating Procedure (SOP)

**Purpose**: Define standard workflows for agent invocation and coordination

**Version**: 1.4 (vNext Workflow Contract - {{TICKET_PREFIX}}-497/499)
**Last Updated**: 2025-12-23

---

## Overview

This SOP defines four standard methods for agent workflow coordination:

1. **Method 1**: Direct Specialist Invocation (simple tasks)
2. **Method 2**: TDM Orchestration (standard features)
3. **Method 3**: ARCHitect-in-CLI Orchestration (complex investigations)
4. **Method 4**: System Architect Review for Complex Code (NEW - v1.1)

---

## Method 1: Direct Specialist Invocation

**When to Use**: Simple, focused tasks requiring single specialist

**Examples**:

- Documentation updates
- Simple bug fixes
- Configuration changes
- Single-file modifications

### Workflow

```
ARCHitect-in-CLI
└─ Specialist (Complete work)
```

### Steps

1. **Identify Specialist**: Determine correct specialist for task
2. **Invoke Specialist**: Provide clear requirements and context
3. **Validate Deliverable**: Ensure work meets requirements
4. **Create PR**: If all quality gates pass

### Quality Gates

- [ ] Specialist completed all requested work
- [ ] Output matches requirements
- [ ] Tests passing (if applicable)
- [ ] Documentation updated (if applicable)

---

## Method 2: TDM Orchestration

**When to Use**: Standard feature development with multiple specialists

**Examples**:

- New feature implementation
- Multi-component changes
- Cross-team coordination
- Standard user stories

### Workflow

```
ARCHitect-in-CLI
└─ TDM (Orchestrator)
    ├─ BSA (Requirements/Spec)
    ├─ Specialist (Implementation)
    ├─ QAS (Testing)
    └─ RTE (PR Creation)
```

### Steps

1. **Invoke TDM**: Provide feature requirements and context
2. **TDM Coordinates**: TDM invokes appropriate specialists
3. **Validate Deliverables**: TDM ensures all work complete
4. **Create PR**: RTE creates PR after all validations

### Quality Gates

- [ ] All specialists completed tasks
- [ ] Handoffs documented
- [ ] Tests passing
- [ ] Evidence attached to Linear

---

## Method 3: ARCHitect-in-CLI Orchestration

**When to Use**: Complex investigations requiring multiple specialists with dependencies

**Examples**:

- Root cause analysis
- Complex automation creation
- Multi-specialist coordination
- Investigation-driven work

### Workflow

```
ARCHitect-in-CLI (Orchestrator)
├─ Specialist 1 (Parallel if independent)
├─ Specialist 2 (Parallel if independent)
├─ Specialist 3 (Sequential if dependent)
└─ System Architect (Review if complex code) ← See Method 4
```

### Steps

1. **Define Investigation Scope**: Clear objectives and success criteria
2. **Identify Specialists**: Determine all required specialists
3. **Coordinate Invocations**: Parallel for independent work, sequential for dependencies
4. **Validate Deliverables**: Ensure all outputs meet requirements
5. **System Architect Review**: MANDATORY if complex code created (see Method 4)
6. **Create PR**: Only after all validations and reviews

### Quality Gates

- [ ] All specialists invoked correctly
- [ ] Parallel/sequential coordination optimal
- [ ] All deliverables validated
- [ ] **System Architect review (if complex code)** ← CRITICAL
- [ ] Tests passing
- [ ] Documentation updated
- [ ] Evidence attached to Linear

---

## Method 4: System Architect Review for Complex Code

**When to Use**: Complex automation/infrastructure code created during investigation

**MANDATORY Triggers**:

- Bash scripts >100 lines
- CI/CD workflow changes
- Infrastructure automation
- Database migration scripts
- Security-critical code
- TypeScript/JavaScript >200 lines

### Step 1: Complete Specialist Work

Invoke specialist (Data Engineer, RTE, etc.) to create deliverable:

```typescript
Task({
  subagent_type: "data-engineer",
  description: "Create production deployment script",
  prompt: `Create automated deployment script for production migrations.

Requirements:
- SSH to production server via Tailscale
- Execute migration via Docker
- Comprehensive error handling
- Rollback capability
- Validation checks

Context: [Investigation findings, requirements, constraints]`,
});
```

### Step 2: System Architect Review (MANDATORY)

After specialist delivers complex code, invoke System Architect:

```typescript
Task({
  subagent_type: "system-architect",
  description: "Review deployment automation",
  prompt: `Architectural review required for {{TICKET_PREFIX}}-XXX deliverables.

Files to Review:
- scripts/deploy-migration-prod.sh (710 lines bash)
- scripts/pre-migration-audit.ts (TypeScript with Prisma)
- scripts/validate-migration-rls.ts (TypeScript pre-commit hook)
- .github/workflows/migration-validation.yml (641 lines CI/CD)

Review Criteria:
1. Architectural patterns and consistency
2. Security best practices (SSH, Docker, credentials)
3. Error handling and edge cases
4. Code quality and maintainability
5. Documentation completeness

Decision Required:
- [ ] APPROVED: Ready for PR with recommendations
- [ ] REQUIRES FIXES: Detailed issues list

Context:
[What automation does, why needed, production impact]

Reference: {{TICKET_PREFIX}}-XXX investigation findings`,
});
```

### Step 3: Address Review Feedback

If System Architect requires fixes:

1. **Invoke specialist again** with System Architect feedback
2. **Implement fixes** addressing all issues
3. **Re-submit to System Architect** for re-review
4. **Repeat until approved**

Example:

```typescript
Task({
  subagent_type: "data-engineer",
  description: "Address System Architect feedback on deployment script",
  prompt: `System Architect review identified the following issues:

1. Missing error handling for SSH connection failures
2. Hardcoded credentials (should use environment variables)
3. No rollback mechanism for failed migrations
4. Insufficient logging for debugging

Please update scripts/deploy-migration-prod.sh to address all issues.

Original script: [Attach current version]
System Architect feedback: [Full review comments]`,
});
```

### Step 4: Create PR (Only After Approval)

Once System Architect approves:

1. **Document architectural decisions** (ADR if needed)
2. **Update Linear ticket** with review approval
3. **Create PR** with System Architect approval noted in description
4. **Attach evidence** (review approval, test results)

### Example: {{TICKET_PREFIX}}-321 Gap

**Missing Steps**: System Architect review NOT invoked

**What Should Have Happened**:

1. Data Engineer delivered scripts ✅
2. **System Architect reviewed scripts** ❌ (MISSING)
3. **Fixes applied based on review** ❌ (MISSING)
4. **System Architect approved** ❌ (MISSING)
5. RTE created CI/CD workflow ✅
6. **System Architect reviewed workflow** ❌ (MISSING)
7. **System Architect final approval** ❌ (MISSING)
8. PR created ❌ (Created without approval)

**Lesson**: **Never skip architectural review for complex code**

---

## Workflow Selection Guide

### Decision Tree

```
What type of work?
├─ Simple task, single specialist → Method 1
├─ Standard feature, multiple specialists → Method 2
├─ Complex investigation, multiple specialists → Method 3
└─ Complex code created? → Method 4 (MANDATORY)
```

### Complexity Assessment

**Simple** (Method 1):

- Single file changes
- Documentation updates
- Configuration tweaks
- Bug fixes <50 lines

**Standard** (Method 2):

- Feature implementation
- Multi-component changes
- Standard user stories
- Clear requirements

**Complex** (Method 3):

- Root cause analysis
- Multi-specialist coordination
- Investigation-driven work
- Unclear requirements

**Complex Code** (Method 4 - MANDATORY):

- Bash scripts >100 lines
- CI/CD workflows
- Infrastructure automation
- Security-critical code
- TypeScript/JavaScript >200 lines

---

## Quality Gates by Method

### Method 1 Quality Gates

- [ ] Specialist completed work
- [ ] Output matches requirements
- [ ] Tests passing (if applicable)

### Method 2 Quality Gates

- [ ] All specialists completed tasks
- [ ] Handoffs documented
- [ ] Tests passing
- [ ] Evidence attached

### Method 3 Quality Gates

- [ ] All specialists invoked correctly
- [ ] Deliverables validated
- [ ] **System Architect review (if complex code)**
- [ ] Tests passing
- [ ] Documentation updated

### Method 4 Quality Gates (CRITICAL)

- [ ] Specialist delivered complex code
- [ ] **System Architect reviewed code**
- [ ] **Fixes applied (if required)**
- [ ] **System Architect approved**
- [ ] Architectural decisions documented
- [ ] Linear ticket updated with approval
- [ ] PR created with approval noted

**If ANY Method 4 trigger matched: BLOCK PR until System Architect approval**

---

## Escalation Paths

### Technical Blockers

1. **System Architect**: Architectural guidance
2. **TDM**: Cross-team coordination
3. **Product Owner**: Business decision

### Process Issues

1. **TDM**: Workflow clarification
2. **RTE**: CI/CD issues
3. **Team retrospective**: Process improvement

### Security Concerns

1. **Security Engineer**: Immediate review
2. **System Architect**: Architectural impact
3. **Security team**: Escalation

---

## Success Metrics

### Method 1 Success

- Fast turnaround (<1 hour)
- Single specialist sufficient
- Quality standards met

### Method 2 Success

- Clear handoffs between specialists
- All specialists completed work
- Evidence consistently attached

### Method 3 Success

- Efficient parallel/sequential coordination
- All deliverables validated
- ARCHitect-in-CLI maintained context

### Method 4 Success (CRITICAL)

- **100% of complex automation reviewed**
- **0% unreviewed scripts >100 lines**
- **System Architect approval before all PRs with complex code**
- **Architectural governance enforced**

---

## vNext Workflow Contract ({{TICKET_PREFIX}}-497)

### Exit States

Each agent role has explicit exit states that define handoff points:

```
┌─────────────────┬───────────────────────────────────────────┐
│ Role            │ Exit State                                │
├─────────────────┼───────────────────────────────────────────┤
│ BE-Developer    │ "Ready for QAS"                           │
│ FE-Developer    │ "Ready for QAS"                           │
│ Data-Engineer   │ "Ready for QAS"                           │
│ QAS             │ "Approved for RTE"                        │
│ RTE             │ "Ready for HITL Review"                   │
│ System Architect│ "Stage 1 Approved - Ready for ARCHitect"  │
│ HITL            │ MERGED                                    │
└─────────────────┴───────────────────────────────────────────┘
```

### Stop-the-Line Gate

**MANDATORY**: Before any implementation work begins:

1. **Check for AC/DoD**: Does the Linear ticket have acceptance criteria?
2. **If NO AC/DoD**: STOP immediately - do not proceed
3. **Escalate to BSA**: Request acceptance criteria definition
4. **Wait for AC/DoD**: Only proceed after criteria are defined

```
┌─────────────────────────────────────────────────────────────┐
│                  STOP-THE-LINE GATE                         │
│                                                             │
│  AC/DoD exists?  ──YES──▶  Proceed to implementation        │
│        │                                                    │
│        NO                                                   │
│        │                                                    │
│        ▼                                                    │
│  STOP - Escalate to BSA for acceptance criteria             │
└─────────────────────────────────────────────────────────────┘
```

### QAS Gate Owner Role

QAS is a **GATE**, not just a report producer. Work does not proceed without QAS approval.

**QAS Ownership**:

- Independent verification of ALL implementation work
- Iteration authority (can bounce back repeatedly until satisfied)
- Final evidence posted to Linear (system of record)
- Exit State: `"Approved for RTE"`

**Linear MCP Tools (MANDATORY for QAS)**:

- `mcp__{{MCP_LINEAR_SERVER}}__create_comment` - Post evidence/verdict
- `mcp__{{MCP_LINEAR_SERVER}}__update_issue` - Update ticket status
- `mcp__{{MCP_LINEAR_SERVER}}__list_comments` - Review prior evidence

### RTE PR Shepherd Role

RTE is the **PR shepherd**, not the gatekeeper. RTE does NOT merge.

**RTE Ownership**:

- PR creation (from spec/template)
- CI/CD monitoring
- Evidence assembly
- PR metadata edits
- Exit State: `"Ready for HITL Review"`

**RTE Must NOT**:

- Merge PRs (HITL is final merge authority)
- Implement product code
- Approve own work (QAS gate required)

### 3-Stage PR Review

```
┌─────────────────────────────────────────────────────────────┐
│                    3-STAGE PR REVIEW                        │
├─────────────────────────────────────────────────────────────┤
│ Stage 1: System Architect                                   │
│          └─ Pattern validation, technical review            │
│          └─ Exit: "Stage 1 Approved - Ready for ARCHitect"  │
├─────────────────────────────────────────────────────────────┤
│ Stage 2: ARCHitect-in-CLI                                   │
│          └─ Architectural alignment                         │
│          └─ Cross-cutting concerns                          │
├─────────────────────────────────────────────────────────────┤
│ Stage 3: HITL (Human-in-the-Loop)                           │
│          └─ Final merge authority                           │
│          └─ Exit: MERGED                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## Role Collapsing Guidelines ({{TICKET_PREFIX}}-499)

### Collapsible Roles

**RTE (Release Train Engineer)**: COLLAPSIBLE

- PR creation and CI shepherding can be done by implementer
- Use when: Simple PRs, single-agent work, fast iteration needed
- Collapsed into: BE-Developer, FE-Developer, or Data-Engineer

### Non-Collapsible Roles (Independence Gates)

**QAS (Quality Assurance Specialist)**: NOT COLLAPSIBLE

- Independence gate - cannot be collapsed into implementer
- Spawn subagent for verification even in collapsed workflows
- Rationale: Self-review bias, quality enforcement

**Security Engineer**: NOT COLLAPSIBLE

- Security audit requires independence
- Cannot be performed by implementer
- Rationale: Security blindness, conflict of interest

### Collapsed Workflow Example

```
Standard Workflow:
BE-Developer → QAS → RTE → HITL

Collapsed Workflow (RTE collapsed):
BE-Developer → QAS → [BE handles PR] → HITL

Note: QAS gate is ALWAYS present, never collapsed
```

---

## Related Documentation

- `TDM_AGENT_ASSIGNMENT_MATRIX.md` - Specialist assignment guide
- `ARCHITECT_IN_CLI_ROLE.md` - ARCHitect-in-CLI responsibilities
- `AGENT_CONFIGURATION_SOP.md` - Tool restrictions, model selection
- `WORKFLOW_COMPARISON.md` - TDM role clarification
- `WORKFLOW_MIGRATION_GUIDE.md` - vNext transition guide
- `PRE_PR_VALIDATION_CHECKLIST.md` - Quality gates before PR
- `WORKFLOW_QUALITY_CHECKLIST.md` - Self-validation checklist

---

## Version History

### v1.4 (2025-12-23)

- **Added**: vNext Workflow Contract ({{TICKET_PREFIX}}-497)
- **Added**: Role Collapsing Guidelines ({{TICKET_PREFIX}}-499)
- **Added**: Exit States for all agent roles
- **Added**: Stop-the-Line Gate (mandatory AC/DoD check)
- **Added**: QAS Gate Owner role with iteration authority
- **Added**: RTE PR Shepherd role (no code, no merge)
- **Added**: 3-Stage PR Review process
- **Updated**: Related Documentation links
- **Rationale**: Major upgrade establishing clear ownership boundaries and mandatory gates

### v1.3 (2025-12-15)

- **Changed**: TDM role from orchestrator to reactive blocker resolution
- **Added**: ARCHitect-in-CLI as primary orchestrator
- **Impact**: Clearer role boundaries

### v1.1 (2025-10-06)

- **Added**: Method 4 (System Architect Review for Complex Code)
- **Rationale**: {{TICKET_PREFIX}}-321 gap discovery (unreviewed complex automation)
- **Impact**: Prevents future governance gaps

### v1.0 (2025-10-05)

- Initial SOP with Methods 1-3
- Basic workflow patterns
- Quality gates defined

---

**Reference**: {{TICKET_PREFIX}}-497/499 vNext Workflow Contract
