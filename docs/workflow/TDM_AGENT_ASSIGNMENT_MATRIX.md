# TDM Agent Assignment Matrix

**Purpose**: Guide for assigning work to specialized agents in the SAFe ART team

**Version**: 1.4 (vNext Workflow Contract - {{TICKET_PREFIX}}-497/499)
**Last Updated**: 2025-12-23

---

## Agent Roster & Specializations

### Planning Agents (Opus Model)

#### Business Systems Analyst (BSA)

- **Primary Responsibilities**: Requirements decomposition, acceptance criteria, testing strategy
- **Tools**: Read, Write, Edit, Bash, Grep, Glob, Linear MCP
- **When to Assign**: User story creation, spec writing, requirements clarification
- **Success Validation**: `yarn lint:md`

#### System Architect

- **Primary Responsibilities**: Pattern validation, architectural review, code quality enforcement
- **Tools**: Read, Grep, Glob (read-only for review)
- **When to Assign**:
  - Pattern approval requests
  - Architectural decision reviews
  - **MANDATORY: Complex code review (see triggers below)**
- **Success Validation**: Approval documented in Linear

### Execution Agents (Sonnet Model)

#### Backend Developer

- **Primary Responsibilities**: API routes, server logic, database operations
- **Tools**: Read, Write, Edit, Bash, Grep, Glob
- **When to Assign**: API endpoints, server-side logic, business logic
- **Success Validation**: `yarn test:integration && yarn lint`

#### Frontend Developer

- **Primary Responsibilities**: UI components, client-side logic, user interactions
- **Tools**: Read, Write, Edit, Bash, Grep, Glob
- **When to Assign**: React components, UI/UX, client-side state
- **Success Validation**: `yarn test:unit && yarn lint && yarn build`

#### Data Engineer

- **Primary Responsibilities**: Schema changes, migrations, database architecture
- **Tools**: Read, Write, Edit, Bash, Grep, Glob, Prisma
- **When to Assign**: Database migrations, schema changes, RLS policies
- **Success Validation**: Migration applied successfully, RLS maintained

### Quality & Coordination Agents (Sonnet Model)

#### Quality Assurance Specialist (QAS) - GATE OWNER

- **Primary Responsibilities**: Execute testing strategy, validate acceptance criteria, **GATE authority**
- **Role Type**: **Independence Gate** - NOT collapsible ({{TICKET_PREFIX}}-499)
- **Tools**: Read, Bash, Playwright, Jest, **Linear MCP** (`mcp__linear-mcp__create_comment`, `mcp__linear-mcp__update_issue`)
- **When to Assign**: Test execution, acceptance criteria validation, **blocking quality gate**
- **Exit State**: `"Approved for RTE"`
- **Iteration Authority**: Can bounce work back repeatedly until satisfied
- **Success Validation**: All tests passing, evidence posted to Linear

#### Security Engineer - INDEPENDENCE GATE

- **Primary Responsibilities**: Security validation, RLS enforcement, vulnerability assessment
- **Role Type**: **Independence Gate** - NOT collapsible ({{TICKET_PREFIX}}-499)
- **Tools**: Read, Bash, RLS validation scripts
- **When to Assign**: Security reviews, RLS validation, vulnerability scans
- **Success Validation**: Security audit passed, RLS enforced

#### Technical Delivery Manager (TDM)

- **Primary Responsibilities**: Coordination, blocker escalation, Linear ticket management
- **Tools**: Linear MCP, GitHub, Confluence
- **When to Assign**: Cross-team coordination, blocker resolution
- **Success Validation**: Linear updated, blockers resolved

#### Release Train Engineer (RTE) - PR SHEPHERD

- **Primary Responsibilities**: PR creation, CI/CD validation, release coordination
- **Role Type**: **Collapsible** - can be collapsed into implementer ({{TICKET_PREFIX}}-499)
- **Prerequisite**: QAS approval (`"Approved for RTE"`)
- **Tools**: Git, GitHub CLI, CI tools
- **When to Assign**: PR creation, release coordination, CI/CD setup
- **Exit State**: `"Ready for HITL Review"`
- **Must NOT**: Merge PRs (HITL is final authority), implement product code
- **Success Validation**: `yarn ci:validate` passes, PR created

---

## System Architect Review Triggers (MANDATORY)

**Critical Update (v1.1)**: Based on {{TICKET_PREFIX}}-321 gap discovery, System Architect review is **MANDATORY** before PR creation for the following:

### Infrastructure & Automation

- [ ] **Bash scripts >100 lines**
  - Example: Deployment scripts, automation tools, setup scripts
  - {{TICKET_PREFIX}}-321 Gap: 710-line `deploy-migration-prod.sh` delivered without review

- [ ] **CI/CD workflow creation or modification**
  - Example: GitHub Actions workflows, pipeline changes
  - {{TICKET_PREFIX}}-321 Gap: 641-line `migration-validation.yml` delivered without review

- [ ] **Infrastructure-as-code**
  - Example: Terraform, CloudFormation, Docker Compose
  - Impact: Production infrastructure changes

- [ ] **Deployment automation scripts**
  - Example: Production deployment, rollback scripts
  - Impact: Security-critical operations (SSH, Docker, credentials)

- [ ] **Container orchestration changes**
  - Example: Kubernetes manifests, Docker configurations
  - Impact: Production environment changes

### Security-Critical Code

- [ ] **Database migration automation**
  - Example: Migration deployment scripts, RLS automation
  - Impact: Data integrity, security policies

- [ ] **Authentication/authorization logic**
  - Example: Auth middleware, permission checks
  - Impact: Security boundaries

- [ ] **SSH/remote execution scripts**
  - Example: Remote deployment, server management
  - Impact: Production access, credential handling

- [ ] **Secret management code**
  - Example: Credential rotation, secret injection
  - Impact: Security posture

- [ ] **RLS policy automation**
  - Example: Automated policy generation, validation
  - Impact: Data security enforcement

### Complex TypeScript/JavaScript

- [ ] **Validation/verification scripts >200 lines**
  - Example: Pre-commit hooks, data validation
  - {{TICKET_PREFIX}}-321 Gap: 3 TypeScript scripts delivered without review

- [ ] **Custom build tools**
  - Example: Build scripts, code generation
  - Impact: Development workflow

- [ ] **Database query builders**
  - Example: Dynamic query construction
  - Impact: SQL injection risk, performance

- [ ] **Pre-commit hooks**
  - Example: Linting automation, validation
  - Impact: Developer workflow

### When in Doubt

**Rule of Thumb**: If deliverable includes ANY executable code that could impact production, invoke System Architect.

**Example Gap ({{TICKET_PREFIX}}-321)**:

- Created: 710-line deployment script + 641-line CI/CD workflow + 3 TypeScript scripts
- System Architect Review: ❌ NOT invoked
- Result: Unreviewed security-critical code in production path

**Lesson**: Always invoke System Architect for complex automation BEFORE PR creation

---

## Assignment Decision Tree

### Step 1: Identify Work Type

```
What type of work is this?
├─ Requirements/Planning → BSA
├─ Database/Schema → Data Engineer
├─ API/Backend → Backend Developer
├─ UI/Frontend → Frontend Developer
├─ Testing → QAS
├─ Security → Security Engineer
├─ CI/CD → RTE
├─ Coordination → TDM
└─ Architectural Review → System Architect
```

### Step 2: Check Complexity

```
Does work include complex code/automation?
├─ YES → Check System Architect review triggers
│   ├─ Bash script >100 lines? → MANDATORY System Architect review
│   ├─ CI/CD workflow? → MANDATORY System Architect review
│   ├─ Infrastructure automation? → MANDATORY System Architect review
│   ├─ TypeScript/JavaScript >200 lines? → MANDATORY System Architect review
│   └─ Security-critical code? → MANDATORY System Architect review
└─ NO (documentation only) → Proceed with specialist assignment
```

### Step 3: Assign Specialist

Based on work type, assign to appropriate specialist agent.

### Step 4: System Architect Review (if triggered)

If any complexity trigger matched:

1. Specialist completes work
2. **MANDATORY**: Invoke System Architect for review
3. System Architect approves OR requires fixes
4. Only after approval: Proceed to PR

---

## Exit States (vNext Contract)

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

---

## Common Assignment Patterns

### Pattern 1: Simple Feature Implementation (with Exit States)

```
BSA (Spec)
    │
    ▼
BE Developer → Exit: "Ready for QAS"
    │
    ▼
QAS (Gate) → Exit: "Approved for RTE"
    │
    ▼
RTE → Exit: "Ready for HITL Review"
    │
    ▼
HITL → MERGED
```

### Pattern 2: Database Migration

```
BSA (Spec) → Data Engineer (Migration) → Security Engineer (RLS) → System Architect (Review) → RTE (PR)
```

### Pattern 3: Complex Automation ({{TICKET_PREFIX}}-321 Pattern)

```
Investigation → Data Engineer (Scripts) → System Architect (Review) → RTE (CI/CD) → System Architect (Final Review) → PR
```

**Note**: Pattern 3 is the CORRECT workflow. {{TICKET_PREFIX}}-321 skipped both System Architect reviews.

### Pattern 4: UI Feature

```
BSA (Spec) → FE Developer (Component) → QAS (E2E Tests) → RTE (PR)
```

### Pattern 5: Collapsed RTE Workflow ({{TICKET_PREFIX}}-499)

```
BSA (Spec)
    │
    ▼
BE Developer → Exit: "Ready for QAS"
    │
    ▼
QAS (Gate) → Exit: "Approved for RTE"
    │
    ▼
[BE handles PR creation - RTE collapsed]
    │
    ▼
HITL → MERGED

Note: QAS gate is ALWAYS present, never collapsed
```

---

## Quality Gates

### Before PR Creation

**MANDATORY Checklist**:

- [ ] All acceptance criteria met
- [ ] Tests passing (`yarn ci:validate`)
- [ ] Evidence attached to Linear
- [ ] **System Architect approval (if complex code)**
- [ ] Security review (if security-sensitive)
- [ ] Documentation updated

**If ANY System Architect trigger matched: BLOCK PR until review approved**

---

## Escalation Paths

### Technical Blockers

- **First**: System Architect (architectural guidance)
- **Second**: TDM (cross-team coordination)
- **Third**: Product Owner (business decision)

### Process Issues

- **First**: TDM (workflow clarification)
- **Second**: RTE (CI/CD issues)
- **Third**: Team retrospective

### Security Concerns

- **First**: Security Engineer (immediate review)
- **Second**: System Architect (architectural impact)
- **Third**: Security team escalation

---

## Success Metrics

### Individual Agent Performance

- Deliverables meet acceptance criteria
- Evidence consistently provided
- Pattern reuse over new code
- Quality gates passed

### System Architect Review Effectiveness

- 100% of complex automation reviewed
- 0% unreviewed scripts >100 lines
- Architectural governance enforced
- Quality standards maintained

### Team Velocity

- Velocity maintained with quality gates
- Reduced production incidents
- Faster reviews (clear triggers)
- Higher confidence in deliverables

---

## Version History

### v1.4 (2025-12-23)

- **Added**: vNext Workflow Contract ({{TICKET_PREFIX}}-497)
- **Added**: Role Collapsing Guidelines ({{TICKET_PREFIX}}-499)
- **Added**: Exit States for all agent roles
- **Updated**: QAS to GATE OWNER role with Linear MCP tools
- **Updated**: RTE to PR SHEPHERD role (no merge)
- **Updated**: Security Engineer as INDEPENDENCE GATE
- **Added**: Pattern 5 - Collapsed RTE Workflow
- **Rationale**: Major upgrade establishing clear ownership boundaries and mandatory gates

### v1.3 (2025-12-15)

- **Changed**: TDM role from orchestrator to reactive blocker resolution
- **Added**: ARCHitect-in-CLI as primary orchestrator
- **Impact**: Clearer role boundaries

### v1.1 (2025-10-06)

- **Added**: System Architect Review Triggers (MANDATORY)
- **Rationale**: {{TICKET_PREFIX}}-321 gap discovery (unreviewed complex automation)
- **Impact**: Prevents future governance gaps

### v1.0 (2025-10-05)

- Initial agent assignment matrix
- Basic role definitions
- Assignment patterns

---

**Related Documentation**:

- `ARCHITECT_IN_CLI_ROLE.md` - When to invoke System Architect
- `AGENT_WORKFLOW_SOP.md` - Detailed workflow processes
- `AGENT_CONFIGURATION_SOP.md` - Tool restrictions, model selection
- `WORKFLOW_COMPARISON.md` - TDM role clarification
- `PRE_PR_VALIDATION_CHECKLIST.md` - Quality gates before PR
- `WORKFLOW_QUALITY_CHECKLIST.md` - ARCHitect-in-CLI self-validation

**Reference**: {{TICKET_PREFIX}}-497/499 vNext Workflow Contract
