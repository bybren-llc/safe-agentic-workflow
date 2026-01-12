# Agent Coordination: WTFB vs ConTStack Comparison

**Document Type**: Comparative Analysis
**Version**: 1.0
**Created**: 2025-01-12
**Purpose**: Guide unified agent coordination strategy for ConTStack

---

## 1. Executive Summary

This document compares two approaches to AI agent coordination:

| Aspect | WTFB Approach | ConTStack Approach |
|--------|---------------|-------------------|
| **Framework** | SAFe ART (Agile Release Train) | RPI (Research-Plan-Implement) |
| **Issue Tracking** | Linear (evidence + specs + PRDs) | Beads (issues) + Linear (specs/PRDs) |
| **Agent Model** | Role-based (7+ SAFe roles) | Specialist-based (3 core agents) |
| **Handoff Protocol** | Explicit exit states | Implicit context delegation |
| **Gate Enforcement** | Mandatory pre-implementation | Quality gates at merge |
| **Evidence** | Linear comments with templates | Beads notes + handoff docs |

**Recommendation**: Merge WTFB's role clarity and exit states with ConTStack's Beads integration and RPI workflow to create a unified "SAFe-lite + RPI" approach.

---

## 2. WTFB Agent Coordination

### 2.1 SAFe Role Hierarchy

WTFB uses SAFe (Scaled Agile Framework) roles adapted for AI agents:

```
                    +---------------------+
                    |   HITL (Human)      |  <- Final merge authority
                    +----------+----------+
                               |
                    +----------v----------+
                    |  ARCHitect-in-CLI   |  <- Primary orchestrator
                    +----------+----------+
                               |
         +---------------------+---------------------+
         |                     |                     |
+--------v--------+  +---------v---------+  +-------v-------+
|   TDM           |  |  System Architect |  |    POPM       |
| (Delivery Mgr)  |  |  (Code Review)    |  | (Product)     |
+--------+--------+  +-------------------+  +---------------+
         |
         +--- BSA (Business Systems Analyst) -> Requirements/Specs
         +--- BE Developer -> API/Backend
         +--- FE Developer -> UI/Components
         +--- Data Engineer -> Database/Migrations
         +--- QAS (Quality Assurance) -> Testing [GATE]
         +--- SecEng (Security Engineer) -> Security [GATE]
         +--- RTE (Release Train Engineer) -> PR/CI-CD
```

### 2.2 Role Responsibilities

| Role | Primary Responsibility | Tools | Exit State |
|------|----------------------|-------|------------|
| **TDM** | Blocker resolution, Linear updates | Linear MCP, GitHub | N/A (reactive) |
| **ARCHitect** | Orchestration, architectural decisions | All tools | Approves PRs |
| **POPM** | Feature prioritization, requirements | Linear | Business decisions |
| **BSA** | Specs, acceptance criteria, DoD | Read, Write, Linear | Spec approved |
| **BE Developer** | API, server logic, backend code | Read, Write, Edit, Bash | "Ready for QAS" |
| **FE Developer** | UI components, client logic | Read, Write, Edit, Bash | "Ready for QAS" |
| **Data Engineer** | Database, migrations, RLS | Prisma, migrations | "Ready for QAS" |
| **QAS** | Testing, acceptance validation | Playwright, Jest | "Approved for RTE" |
| **SecEng** | Security review, RLS validation | RLS scripts | Security clearance |
| **RTE** | PR creation, CI/CD shepherding | Git, GitHub CLI | "Ready for HITL" |

### 2.3 Key WTFB Patterns

#### Pre-Implementation Gate (MANDATORY)

```markdown
BEFORE any implementation:
1. BSA creates spec with acceptance criteria
2. System Architect reviews patterns
3. THEN implementation begins

NO SPEC = NO CODE (Stop-the-Line)
```

#### Exit State Protocol

```
BE-Developer -> "Ready for QAS"
      |
QAS (verifies) -> "Approved for RTE"
      |
RTE (creates PR) -> "Ready for HITL Review"
      |
HITL -> MERGED
```

#### Blocker Escalation

| Condition | Escalate To | Deadline |
|-----------|-------------|----------|
| Blocker > 1 hour | TDM | Immediately |
| Blocker > 4 hours | ARCHitect | Urgent |
| Architecture ambiguity | ARCHitect | Before work |
| Cross-team dependency | TDM + POPM | Same day |
| Security concern | SecEng | Immediately |

#### Evidence Template

```markdown
**Implementation Evidence**
**Session ID**: [Claude session ID]
**Agent**: [which specialist]
**Ticket**: {PREFIX}-XXX

**Work Completed**:
- [x] Task 1
- [x] Task 2

**Validation**:
yarn ci:validate
# All checks passed

**Next Steps**: [if any]
```

### 2.4 WTFB Workflow Methods

| Method | Use Case | Agents Involved |
|--------|----------|-----------------|
| **Method 1** | Simple task | ARCHitect -> Specialist |
| **Method 2** | Standard feature | TDM -> BSA -> Specialist -> QAS -> RTE |
| **Method 3** | Complex investigation | ARCHitect -> Multiple specialists (parallel/sequential) |
| **Method 4** | Complex code review | Specialist -> System Architect (MANDATORY) |

---

## 3. ConTStack Agent Coordination

### 3.1 Specialist Agent Model

ConTStack uses 3 core specialists with optional domain-specific agents:

```
                    +---------------------+
                    |    Main Agent       |  <- Primary orchestrator
                    +----------+----------+
                               |
         +---------------------+---------------------+
         |                     |                     |
+--------v--------+  +---------v---------+  +-------v-------+
| Testing         |  | Security          |  | Convex        |
| Specialist      |  | Reviewer          |  | Specialist    |
+-----------------+  +-------------------+  +---------------+

         |                     |                     |
    E2E/Unit Tests        RBAC/Auth            Schema/Backend
    Test Coverage         Multi-tenant          Queries/Mutations
    Debugging             Vulnerabilities       Performance
```

### 3.2 Agent Definitions (JSON-based)

| Agent | Primary Role | Knowledge Context | Success Metrics |
|-------|-------------|-------------------|-----------------|
| **Testing Specialist** | E2E + unit testing, debugging | `/tests/CLAUDE.md` | >80% coverage, 100% E2E pass |
| **Security Reviewer** | RBAC, auth guards, multi-tenant | `/packages/backend/CLAUDE.md` | 0 auth bypass, 100% guards |
| **Convex Specialist** | Schema, queries, mutations | `/packages/backend/CLAUDE.md` | All queries indexed, Zod validation |

### 3.3 ConTStack Domain Agents (Extended)

ConTStack also has domain-specific agents for Sales Intelligence:

| Agent | Domain | Responsibilities |
|-------|--------|-----------------|
| **Schema Designer** | Data modeling | Schema design, relationships, indexes |
| **Backend Alpha** | Core CRUD | Companies, contacts, products, timeline |
| **Backend Beta** | Scoring | Lead scoring, engagement algorithms |
| **Backend Gamma** | Enrichment | Data enrichment, external integrations |
| **Frontend** | UI | React components, state management |
| **Fullstack Polish** | Integration | End-to-end feature completion |

### 3.4 RPI Workflow Integration

ConTStack uses Research-Plan-Implement (RPI) workflow:

```
+-------------------------------------------------------------+
|                     RPI WORKFLOW                             |
+-------------------------------------------------------------+
|                                                              |
|  /research [topic]     ->  Research document created         |
|         |                                                    |
|  /plan [task]          ->  Implementation plan + Beads       |
|         |                                                    |
|  /implement [plan]     ->  Execute phase by phase            |
|         |                                                    |
|  /handoff              ->  Session handoff document          |
|                                                              |
+-------------------------------------------------------------+
```

### 3.5 Orchestration Patterns

| Pattern | Description | Example |
|---------|-------------|---------|
| **Sequential** | Chain of specialists | Convex -> Main -> Security -> Testing |
| **Parallel** | Independent work | All 3 specialists run simultaneously |
| **Hierarchical** | Nested delegation | Convex -> Security (sub-task) -> Convex |
| **Review and Approve** | Quality gate | Security audit -> PASS/FAIL -> iterate |

### 3.6 Sub-Agent Spawning

```typescript
// ConTStack spawns sub-agents for context isolation:
- codebase-locator: Find relevant files
- codebase-analyzer: Analyze code patterns
- research-compiler: Synthesize findings
- plan-validator: Validate plans
- beads-sync: Beads operations
```

---

## 4. Side-by-Side Comparison Table

| Dimension | WTFB | ConTStack |
|-----------|------|-----------|
| **Framework** | SAFe ART | RPI Workflow |
| **Issue Tracking** | Linear (full lifecycle) | Beads (issues) + Linear (specs) |
| **Number of Roles** | 10+ SAFe roles | 3 core + domain specialists |
| **Role Definition** | Markdown SOPs | JSON configs + CLAUDE.md |
| **Handoff Protocol** | Explicit exit states | Contextual delegation |
| **Pre-Implementation** | MANDATORY spec (BSA) | Optional research phase |
| **Quality Gates** | QAS + SecEng (independence gates) | Security Reviewer (advisory) |
| **Evidence Storage** | Linear comments | Beads notes + handoff docs |
| **Escalation** | TDM -> ARCHitect -> POPM | Main agent handles |
| **PR Workflow** | 3-stage review | Standard PR |
| **Tool Access** | Role-restricted | Capability-based |
| **Model Selection** | Role-based (Opus/Sonnet) | Agent-based |
| **Context Management** | Exit states | Sub-agent spawning |
| **Blocker Handling** | Escalation protocol | Ad-hoc resolution |

---

## 5. WTFB Strengths

### 5.1 Role Clarity
- **Clear boundaries**: Each role has explicit responsibilities
- **No overlap**: BE Developer vs FE Developer vs Data Engineer
- **Accountability**: Exit states create audit trail

### 5.2 Handoff Protocols
```
Explicit exit states prevent work falling through cracks
"Ready for QAS" -> "Approved for RTE" -> "Ready for HITL"
Each transition is documented and trackable
```

### 5.3 Evidence Requirements
- **Mandatory templates**: Consistent documentation
- **Linear as system of record**: Centralized evidence
- **Validation commands**: `yarn ci:validate` required

### 5.4 Independence Gates
- **QAS cannot be collapsed**: Prevents self-review bias
- **SecEng independence**: Security requires fresh eyes
- **System Architect review**: Complex code triggers mandatory review

### 5.5 Blocker Escalation
- **Time-boxed**: 1 hour -> TDM, 4 hours -> ARCHitect
- **Clear ownership**: Who to escalate to for what
- **Prevents stalls**: Work does not silently block

### 5.6 Pre-Implementation Gate
- **Stop-the-line**: No spec = no code
- **BSA ownership**: Requirements are someone's responsibility
- **Acceptance criteria first**: Clear success definition

---

## 6. ConTStack Strengths

### 6.1 Beads Integration
```bash
# Beads provides structured issue tracking:
bd ready --json           # See unblocked work
bd create "Description"   # Create issue during work
bd dep add [id] [parent]  # Link discovered work
bd update [id] --status   # Update status
bd close [id] --reason    # Complete work
```

### 6.2 RPI Workflow
- **Research phase**: Understand before implementing
- **Plan phase**: Beads epic with phase tracking
- **Implement phase**: Execute with checkpoints
- **Handoff phase**: Clean session transitions

### 6.3 Sub-Agent Spawning
```
Context isolation prevents token bloat
Parallel research with codebase-locator, codebase-analyzer
Specialized agents for specific tasks
Main agent maintains coherent context
```

### 6.4 Hierarchical CLAUDE.md
```
/CLAUDE.md                    <- Master guide
+-- /apps/CLAUDE.md           <- App development
|   +-- /apps/app/CLAUDE.md   <- Main SaaS app
|   +-- /apps/web/CLAUDE.md   <- Marketing site
+-- /packages/CLAUDE.md       <- Shared packages
|   +-- /packages/backend/CLAUDE.md  <- Convex backend
+-- /tests/CLAUDE.md          <- Testing patterns
```

### 6.5 MCP Tool Integration
- **Serena MCP**: 25+ tools for file ops, code navigation
- **GitHub MCP**: Issues, PRs, repository management
- **Sequential Thinking MCP**: Complex reasoning
- **Chrome DevTools MCP**: Autonomous browser debugging

### 6.6 JSON Agent Configuration
```json
{
  "name": "Testing Specialist",
  "capabilities": [...],
  "knowledgeContext": { "primary": "/tests/CLAUDE.md" },
  "activationTriggers": [...],
  "workflowPatterns": {...},
  "successMetrics": [...]
}
```

### 6.7 Flexible Orchestration
- Not bound to SAFe ceremony
- Parallel execution when possible
- Hierarchical delegation for complex tasks
- Quality gates without mandatory roles

---

## 7. Recommended Unified Approach

### 7.1 Hybrid Model: "SAFe-lite + RPI"

Combine the best of both approaches:

```
+------------------------------------------------------------------+
|                    UNIFIED WORKFLOW                               |
+------------------------------------------------------------------+
|                                                                   |
|  +------------------------------------------------------------+  |
|  | BEADS: Issue Tracking + Task Management                    |  |
|  | - bd ready --json (find work)                              |  |
|  | - bd create (new issues)                                   |  |
|  | - bd update (status tracking)                              |  |
|  | - bd close (completion)                                    |  |
|  +------------------------------------------------------------+  |
|                              |                                    |
|  +------------------------------------------------------------+  |
|  | LINEAR: Evidence + Specs + PRDs                            |  |
|  | - BSA specs with acceptance criteria                       |  |
|  | - Implementation evidence (WTFB template)                  |  |
|  | - PRD storage and tracking                                 |  |
|  | - Security audit records                                   |  |
|  +------------------------------------------------------------+  |
|                              |                                    |
|  +------------------------------------------------------------+  |
|  | RPI WORKFLOW (ConTStack)                                   |  |
|  |                                                            |  |
|  |  /research -> Research document + Beads issue              |  |
|  |      |                                                     |  |
|  |  /plan -> Implementation plan + Linear spec                |  |
|  |      |                                                     |  |
|  |  /implement -> Execute with exit states                    |  |
|  |      |                                                     |  |
|  |  /handoff -> Session handoff + Beads sync                  |  |
|  +------------------------------------------------------------+  |
|                                                                   |
+------------------------------------------------------------------+
```

### 7.2 Adopted from WTFB

| Pattern | Adaptation |
|---------|------------|
| **Exit States** | Implement for key handoffs: "Ready for Review", "Ready for Merge" |
| **Independence Gates** | Security Reviewer as mandatory gate for auth changes |
| **Evidence Templates** | Use WTFB templates in Linear comments |
| **Blocker Escalation** | Time-boxed escalation to main agent |
| **Pre-Implementation Gate** | Require plan approval before /implement |
| **System Architect Triggers** | Apply to complex code (>100 lines bash, >200 lines TS) |

### 7.3 Retained from ConTStack

| Pattern | Rationale |
|---------|-----------|
| **Beads for issues** | Lightweight, CLI-native, works offline |
| **Linear for evidence** | Rich formatting, integrations, searchable |
| **RPI workflow** | Structured without SAFe overhead |
| **Sub-agent spawning** | Context isolation prevents token bloat |
| **JSON agent configs** | Machine-readable, versionable |
| **CLAUDE.md hierarchy** | Context injection at point of need |
| **MCP tool integration** | Rich automation capabilities |

### 7.4 Unified Agent Roster

```
CORE AGENTS (from ConTStack):
+-- Testing Specialist    -> E2E, unit tests, debugging
+-- Security Reviewer     -> RBAC, auth, multi-tenant [GATE]
+-- Convex Specialist     -> Schema, queries, backend

SAFe-INSPIRED ROLES (from WTFB):
+-- BSA Role             -> Main agent creates specs before /implement
+-- System Architect     -> Triggered for complex code reviews
+-- QAS Role             -> Testing Specialist acts as gate
+-- RTE Role             -> Main agent handles PR creation

DOMAIN AGENTS (optional):
+-- Schema Designer      -> Complex schema work
+-- Backend Alpha/Beta   -> Domain-specific implementation
+-- Frontend             -> UI-focused work
```

### 7.5 Exit State Implementation

```markdown
IMPLEMENTATION EXIT STATES:

Developer/Specialist -> "Ready for Review"
  - Code complete
  - Tests passing
  - Evidence posted to Linear

Security Reviewer -> "Security Approved" or "Needs Fixes"
  - RBAC validated
  - Multi-tenant isolation verified
  - Auth guards confirmed

Testing Specialist -> "QA Approved" or "Needs Fixes"
  - E2E tests passing
  - Coverage acceptable
  - No regressions

Main Agent -> "Ready for Merge"
  - All gates passed
  - PR created
  - Awaiting human review
```

### 7.6 Evidence Flow

```
BEADS                          LINEAR
-----                          ------
Issue created
  |
  v
Research started
  |
  v
Plan created -------------------> Spec created (with AC)
  |
  v
Implementation started
  |
  v
Implementation complete --------> Evidence posted (WTFB template)
  |
  v
Security review ----------------> Audit record posted
  |
  v
QA review ----------------------> Test results posted
  |
  v
Issue closed (bd close)        PR created with evidence links
```

---

## 8. Implementation Notes

### 8.1 Migration Path

1. **Phase 1: Evidence Templates** (Week 1)
   - Adopt WTFB evidence template in Linear
   - Create `/plan` command that generates Linear spec
   - Update handoff docs to link Linear evidence

2. **Phase 2: Exit States** (Week 2)
   - Add exit state tracking to Beads issues
   - Implement "Ready for Review" -> "Approved" flow
   - Document exit state criteria

3. **Phase 3: Independence Gates** (Week 3)
   - Make Security Reviewer mandatory for auth changes
   - Add pre-implementation gate check to /implement
   - Implement blocker escalation timers

4. **Phase 4: System Architect Triggers** (Week 4)
   - Add complexity detection to /implement
   - Trigger architect review for complex code
   - Document review criteria

### 8.2 Tool Configuration

```yaml
# .claude/skills/agent-coordination/config.yaml
beads:
  use_for: [issues, task_management, dependencies]

linear:
  use_for: [specs, evidence, prds, audits]
  templates:
    - evidence_template
    - spec_template
    - security_audit_template

exit_states:
  developer: "Ready for Review"
  security_reviewer: "Security Approved"
  testing_specialist: "QA Approved"
  main_agent: "Ready for Merge"

independence_gates:
  - security_reviewer  # Cannot be skipped for auth changes
  - testing_specialist # Cannot be skipped for UI changes

complexity_triggers:
  bash_lines: 100
  typescript_lines: 200
  ci_cd_changes: true
  security_critical: true
```

### 8.3 Skill Updates Required

| Skill | Update Needed |
|-------|---------------|
| `/plan` | Generate Linear spec with WTFB AC template |
| `/implement` | Check for pre-implementation gate |
| `/review` | Implement exit state transitions |
| `/handoff` | Link Beads + Linear evidence |
| `/status` | Show exit states in workflow status |

### 8.4 Agent Config Updates

```json
// security.json - Add GATE designation
{
  "name": "Security Reviewer",
  "roleType": "INDEPENDENCE_GATE",
  "exitStates": {
    "approved": "Security Approved",
    "rejected": "Needs Fixes"
  },
  "activationTriggers": [
    "New auth guard implementation",
    "RBAC permission changes",
    "Multi-tenant schema changes"
  ]
}
```

### 8.5 Workflow Command Updates

```bash
# Updated /implement with exit states
/implement [plan-id]
  +-- Check pre-implementation gate (BSA spec exists?)
  +-- Execute phases
  +-- After each phase:
  |   +-- Post evidence to Linear
  |   +-- Update Beads status
  |   +-- Set exit state
  +-- Trigger independence gates:
  |   +-- Security Reviewer (if auth changes)
  |   +-- Testing Specialist (if UI changes)
  +-- Final exit state: "Ready for Merge"
```

### 8.6 Key Success Metrics

| Metric | Target | Source |
|--------|--------|--------|
| Exit state compliance | 100% | Beads status |
| Pre-implementation gate | 100% | Linear spec check |
| Independence gate pass | 100% for auth changes | Security reviews |
| Evidence posted | 100% of implementations | Linear comments |
| Blocker escalation SLA | <4 hours | Beads timestamps |

---

## 9. Appendix: Reference Documentation

### WTFB Sources
- `/home/user/wtfb-fork/.claude/skills/agent-coordination/SKILL.md`
- `/home/user/wtfb-fork/docs/workflow/TDM_AGENT_ASSIGNMENT_MATRIX.md`
- `/home/user/wtfb-fork/docs/sop/AGENT_WORKFLOW_SOP.md`

### ConTStack Sources
- `/home/user/convex-v1/CLAUDE.md` (Specialized Subagents section)
- `/home/user/convex-v1/docs/subagent-usage-guide.md`
- `/home/user/convex-v1/.claude/agents/*.json`

### Related Comparison Documents
- `COMPARISON-linear-sop.md` (if exists) - Linear integration patterns
- `COMPARISON-quality-gates.md` (planned) - Gate enforcement patterns

---

**Document Status**: Complete
**Review Required**: Before implementing unified approach
**Next Steps**: Create `/plan` skill update for Linear spec generation
