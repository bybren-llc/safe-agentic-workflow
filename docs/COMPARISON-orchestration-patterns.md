# Orchestration Patterns Comparison: WTFB vs ConTStack RPI

> A detailed comparison of workflow orchestration approaches for AI-assisted development

---

## 1. Executive Summary

Both WTFB's orchestration-patterns skill and ConTStack's RPI (Research-Plan-Implement) workflow provide structured approaches to managing complex, multi-step development tasks with AI agents. While they share the goal of ensuring verifiable, high-quality work, they differ significantly in philosophy, structure, and tracking mechanisms.

| Aspect | WTFB | ConTStack RPI |
|--------|------|---------------|
| **Philosophy** | Evidence-based delivery with QAS gate | Phased workflow with human checkpoints |
| **Progress Tracking** | Linear (external ticket system) | Beads (local-first git-based) |
| **Workflow Model** | Loop-based (iterate until success) | Phase-based (sequential stages) |
| **Agent Coordination** | QAS subagent for review | Multiple specialized agents |
| **Validation Point** | Pre-merge QAS gate | Post-phase human verification |

**Key Insight**: WTFB emphasizes automated validation loops with a single mandatory QAS gate, while ConTStack prioritizes human checkpoints at each phase transition with specialized agent coordination.

---

## 2. WTFB Orchestration Model

### 2.1 Core Philosophy

WTFB follows Simon Willison's Agent Loop: **"Iterate until success or blocked, then escalate."**

The model is built on two pillars:
1. **Evidence-Based Delivery**: All work requires verifiable proof
2. **QAS Pre-Merge Gate**: Independent review before any merge

### 2.2 Workflow Structure

```
START: /start-work WOR-XXX
   |
   v
[Pattern Discovery]
   |
   v
[AGENT LOOP]  <---------+
   |                    |
   +-- Implement        |
   +-- Validate (CI)    |
   +-- If PASS --> Exit |
   +-- If FAIL --> Retry -----+
   +-- If BLOCKED --> Escalate
   |
   v
[Pre-PR Checklist] --> /pre-pr
   |
   v
[QAS GATE - MANDATORY]
   |
   v
[Merge] --> /end-work
```

### 2.3 Key Commands

| Command | Purpose | Stage |
|---------|---------|-------|
| `/start-work WOR-XXX` | Branch creation, context setup | Start |
| `/search-pattern` | Find relevant code patterns | Discovery |
| `yarn ci:validate` | Run full validation suite | Validation |
| `/pre-pr` | Pre-merge checklist | Pre-merge |
| QAS subagent | Independent review | Gate |
| `/end-work` | Linear update, cleanup | End |

### 2.4 Evidence Types

WTFB categorizes evidence into specific types:

| Type | Purpose | Example |
|------|---------|---------|
| **Test Results** | Prove code works | `yarn ci:validate` output |
| **Screenshots** | UI verification | Before/after comparison |
| **Command Output** | Operation proof | Build logs, migration logs |
| **QAS Report** | Independent verification | QA validation markdown |
| **Session ID** | Audit trail | Claude Code session reference |

### 2.5 Phase Evidence Requirements

Each development phase requires specific evidence:

| Phase | Required Evidence | Linear Template |
|-------|-------------------|-----------------|
| Dev | Test results + command output | Dev Evidence Template |
| Staging | UAT validation or N/A + reason | Staging Template |
| Done | QAS report + merge confirmation | Done Evidence Template |

### 2.6 Escalation Protocol

WTFB has explicit escalation rules:

| Condition | Escalate To | Include |
|-----------|-------------|---------|
| Blocked > 4 hours | TDM | Full context, attempts made |
| Architecture ambiguity | ARCHitect | Options, trade-offs |
| Cross-team dependency | TDM | Which teams, what's blocked |
| Security concern | SecEng | Specific risk, evidence |

### 2.7 QAS Gate Details

The QAS (Quality Assurance Specialist) subagent is **mandatory** before merge:

**Responsibilities:**
- Validate commit message format (ticket in subject line)
- Check code patterns (RLS, naming, structure)
- Verify CI status (all checks passing)
- Confirm evidence attachments in Linear

**Output Location:** `docs/agent-outputs/qa-validations/WOR-{number}-qa-validation.md`

---

## 3. ConTStack RPI Model

### 3.1 Core Philosophy

ConTStack uses a three-phase structured workflow with explicit human checkpoints. The model emphasizes:
1. **Phased Execution**: Distinct research, planning, and implementation stages
2. **Human Oversight**: Explicit approval gates between phases
3. **Beads Integration**: Git-native issue tracking throughout

### 3.2 Workflow Structure

```
START: /rpi-full "task description"
   |
   v
=== PHASE 1: RESEARCH ===
   |
   +-- Spawn research-agent
   +-- codebase-locator (parallel)
   +-- codebase-analyzer (parallel)
   +-- Create research document
   +-- Create Beads issue (research label)
   |
   v
[HUMAN CHECKPOINT: "Continue to planning?"]
   |
   v
=== PHASE 2: PLAN ===
   |
   +-- Spawn planning-agent
   +-- Create implementation plan
   +-- Create Beads epic + phase issues
   +-- Set up dependency tree
   |
   v
[HUMAN CHECKPOINT: "Approve for implementation?"]
   |
   v
=== PHASE 3: IMPLEMENT ===
   |
   +-- For each phase:
   |     +-- Update Beads (in_progress)
   |     +-- Execute changes
   |     +-- Run verification
   |     +-- [HUMAN CHECKPOINT]
   |     +-- Close phase issue
   |
   v
[Epic Complete]
   |
   v
/handoff --> Session end protocol
```

### 3.3 Key Commands

| Command | Purpose | Workflow Stage |
|---------|---------|----------------|
| `/rpi-full [task]` | Execute complete workflow | Full workflow |
| `/research [topic]` | Investigate codebase | Research only |
| `/plan [task]` | Create implementation plan | Planning only |
| `/implement [plan]` | Execute approved plan | Implementation only |
| `/status` | Show current workflow status | Monitoring |
| `/compact` | Create session handoff | Session management |
| `/handoff` | End-of-session protocol | Session end |

### 3.4 Beads Issue Tracking

ConTStack uses Beads for all issue tracking:

```bash
# Create issue
bd create "Description" -t [bug|task|feature|epic] -p [0-4] -l [labels]

# Link dependencies
bd dep add [new-id] [parent-id] --type discovered-from

# Check ready work
bd ready --json

# View dependency tree
bd dep tree [epic-id]

# Close issue
bd close [issue-id] --reason "Completion summary"
```

**Label System:**

| Label | Purpose |
|-------|---------|
| `rpi` | RPI workflow related |
| `research` | Research phase |
| `plan` | Planning phase |
| `phase` | Implementation phase |
| `discovered` | Found during other work |
| `blocked` | Waiting on something |

### 3.5 Specialized Agents

ConTStack coordinates multiple specialized agents:

| Agent | Role | When Used |
|-------|------|-----------|
| `research-agent` | Coordinate parallel research | Research phase |
| `planning-agent` | Create implementation plans | Planning phase |
| `implementation-agent` | Execute plans | Implementation phase |
| `codebase-locator` | Find relevant files | Research/Planning |
| `codebase-analyzer` | Analyze code patterns | Research/Planning |
| `validation-agent` | Verify implementations | Post-implementation |

### 3.6 State Persistence

RPI maintains session state in JSON:

```json
{
  "sessionId": "feature-name-timestamp",
  "currentPhase": "research|plan|implement",
  "taskDescription": "...",
  "researchFile": "path/to/research.md",
  "planFile": "path/to/plan.md",
  "beadsEpicId": "bd-xxxx",
  "completedPhases": ["research"],
  "nextSteps": "..."
}
```

**File Locations:**
- Research: `thoughts/shared/research/YYYY-MM-DD-{topic-slug}.md`
- Plans: `thoughts/shared/plans/YYYY-MM-DD-{beads-id}-{feature-slug}.md`
- Handoffs: `thoughts/shared/handoffs/YYYY-MM-DD-HHmm-handoff.md`

### 3.7 Context Management

ConTStack has explicit context window management:

| Context Level | Action |
|---------------|--------|
| < 30% | Continue working |
| 30-40% | Consider compaction soon |
| > 40% | Compact now |

---

## 4. Side-by-Side Comparison Table

| Aspect | WTFB | ConTStack RPI |
|--------|------|---------------|
| **Primary Workflow** | Agent Loop (iterate until success) | Three-phase (Research-Plan-Implement) |
| **Entry Point** | `/start-work WOR-XXX` | `/rpi-full [task]` |
| **Issue Tracking** | Linear (external) | Beads (git-native) |
| **Phase Structure** | Continuous loop with checkpoints | Discrete phases with explicit gates |
| **Human Involvement** | Minimal until QAS gate | Explicit checkpoint at each phase |
| **Validation Approach** | `yarn ci:validate` in loop | Post-phase automated + manual |
| **Pre-Merge Review** | QAS subagent (mandatory) | Human verification per phase |
| **Agent Count** | 1 QAS subagent | 6+ specialized agents |
| **Escalation Model** | Structured (4hr block, ARCHitect, SecEng) | Error recovery options |
| **Evidence Storage** | Linear attachments | Markdown files in thoughts/ |
| **Pattern Discovery** | Skill auto-invoked or `/search-pattern` | Research agent + codebase-locator |
| **State Management** | Linear ticket status | JSON session state + Beads |
| **Session Handoff** | State preservation template | `/compact` and `/handoff` commands |
| **Context Awareness** | Checkpoints every 10-15 tool calls | <30%/30-40%/>40% thresholds |
| **File Output** | `docs/agent-outputs/qa-validations/` | `thoughts/shared/` hierarchy |
| **Dependency Tracking** | Implicit via Linear | Explicit via `bd dep` commands |

---

## 5. WTFB Strengths

### 5.1 Evidence-Driven Culture

WTFB's strict evidence requirements ensure **no "trust me, it works"** culture:

- Every phase requires specific evidence types
- Linear templates enforce consistent documentation
- QAS reports provide third-party verification

### 5.2 Automated Validation Loop

The agent loop is highly efficient:

```
Implement --> Validate --> Pass? --> Proceed
                  |
                  +--> Fail? --> Analyze --> Adjust --> Repeat
```

- No manual intervention needed during the loop
- Automatic retry on failures
- Clear escalation criteria (blocked > 4 hours)

### 5.3 Independent QAS Gate

The mandatory QAS subagent provides:

- **Separation of concerns**: QAS doesn't write code, only validates
- **Bias prevention**: Fresh perspective on commit messages, patterns
- **Evidence in Linear**: System of record for compliance

### 5.4 Clear Escalation Matrix

Structured escalation prevents wasted effort:

- Time-based triggers (4-hour threshold)
- Role-specific routing (TDM, ARCHitect, SecEng)
- Required context format for escalations

### 5.5 Linear Integration

External tracking provides:

- Cross-team visibility
- Management dashboards
- Historical audit trail
- Integration with other tools

---

## 6. ConTStack Strengths

### 6.1 Human Oversight at Every Phase

Explicit checkpoints ensure human control:

```
Research --> [Approve?] --> Plan --> [Approve?] --> Implement --> [Verify?]
```

- No phase proceeds without human confirmation
- Prevents runaway automation
- Allows course correction early

### 6.2 Git-Native Issue Tracking (Beads)

Beads provides local-first tracking:

- No external service dependency
- Version-controlled issue history
- Dependency trees via `bd dep`
- Ready work queue via `bd ready`

### 6.3 Specialized Agent Architecture

Multiple focused agents improve quality:

| Agent | Specialization |
|-------|---------------|
| `codebase-locator` | File discovery |
| `codebase-analyzer` | Pattern analysis |
| `planning-agent` | Implementation planning |
| `validation-agent` | Quality verification |

### 6.4 Structured Documentation Output

Clear file organization:

```
thoughts/
  shared/
    research/     # YYYY-MM-DD-{slug}.md
    plans/        # YYYY-MM-DD-{beads-id}-{slug}.md
    handoffs/     # YYYY-MM-DD-HHmm-handoff.md
```

- Consistent naming conventions
- Easy to find related documents
- Version-controlled history

### 6.5 Context Window Management

Explicit context monitoring prevents overflow:

- Regular status checks via `/status`
- Proactive compaction via `/compact`
- Seamless session handoffs

### 6.6 Discovery Issue Handling

During research and implementation, discovered issues are:

```bash
bd create "Discovered: [description]" -t [type] -p [priority] \
  -l discovered,implementation \
  --json
bd dep add [new-id] [current-phase-id] --type discovered-from
```

- Captured immediately
- Linked to source work
- Not blocking current task

---

## 7. Recommended Unified Approach

### 7.1 Hybrid Model Overview

Combine the strengths of both systems:

```
START: /rpi-full [task]
   |
   v
=== RESEARCH (ConTStack) ===
   +-- Parallel specialized agents
   +-- Beads issue tracking
   +-- Evidence: Research document
   |
   v
[Human Checkpoint]
   |
   v
=== PLAN (ConTStack) ===
   +-- Planning agent + validator
   +-- Beads epic + dependencies
   +-- Evidence: Plan document
   |
   v
[Human Checkpoint]
   |
   v
=== IMPLEMENT (Hybrid) ===
   |
   +-- For each phase:
   |     |
   |     [WTFB Agent Loop]
   |        +-- Implement
   |        +-- Validate (CI)
   |        +-- Repeat until pass
   |        +-- Evidence attachment
   |     |
   |     [Phase Checkpoint]
   |
   v
=== QAS GATE (WTFB) ===
   +-- QAS subagent review
   +-- Commit message validation
   +-- Pattern verification
   +-- Evidence: QAS report
   |
   v
[Human Final Approval]
   |
   v
MERGE
```

### 7.2 Key Unification Principles

#### 7.2.1 Issue Tracking: Beads + Linear Sync

```bash
# Use Beads for local tracking
bd create "Feature: OAuth refresh" -t epic -p 2 -l rpi

# Sync to Linear for team visibility (if needed)
bd sync --linear
```

**Rationale**: Beads for speed and git-native tracking, Linear sync for cross-team visibility.

#### 7.2.2 Agent Coordination: ConTStack Specialists + WTFB QAS

| Phase | Agents |
|-------|--------|
| Research | codebase-locator, codebase-analyzer |
| Planning | planning-agent, plan-validator |
| Implementation | implementation-agent (WTFB loop) |
| Pre-Merge | QAS subagent (mandatory) |

#### 7.2.3 Validation: WTFB Loop with RPI Checkpoints

```
Phase N Start
    |
    v
[WTFB Agent Loop]
    +-- Implement
    +-- Validate (bun test && bun lint && bun typecheck)
    +-- If FAIL --> Analyze --> Adjust --> Repeat
    +-- If PASS --> Continue
    |
    v
[Automated Verification Evidence]
    |
    v
[Human Checkpoint: "Proceed to Phase N+1?"]
```

#### 7.2.4 Evidence: Unified Storage

```
thoughts/shared/
  research/        # Research documents
  plans/           # Implementation plans
  handoffs/        # Session handoffs
  qa-validations/  # QAS reports (from WTFB)
  evidence/        # Phase evidence (screenshots, logs)
```

### 7.3 Unified Command Set

| Command | Origin | Purpose |
|---------|--------|---------|
| `/rpi-full` | ConTStack | Complete workflow |
| `/research` | ConTStack | Research phase |
| `/plan` | ConTStack | Planning phase |
| `/implement` | Hybrid | Implementation with WTFB loop |
| `/validate` | WTFB | Run CI validation |
| `/qas-review` | WTFB | Pre-merge QAS gate |
| `/status` | ConTStack | Workflow status |
| `/compact` | ConTStack | Session compaction |
| `/handoff` | ConTStack | Session end protocol |

### 7.4 Escalation Protocol (Unified)

| Condition | Action |
|-----------|--------|
| Blocked in loop > 4 hours | Escalate per WTFB matrix |
| Phase blocked by dependency | Check `bd ready`, adjust order |
| Context window > 40% | Run `/compact` |
| Architecture uncertainty | Spawn ARCHitect subagent |
| Security concern | Spawn SecEng subagent |

---

## 8. Implementation Notes

### 8.1 Migration Path: WTFB to Unified

1. **Keep existing Linear integration** for team visibility
2. **Add Beads** for local tracking and dependency management
3. **Adopt RPI phases** for research and planning
4. **Maintain QAS gate** as mandatory pre-merge step
5. **Expand agent roster** with ConTStack specialists

### 8.2 Migration Path: ConTStack to Unified

1. **Keep Beads** for git-native tracking
2. **Add QAS subagent** as mandatory pre-merge gate
3. **Add Linear sync** if cross-team visibility needed
4. **Adopt WTFB evidence types** for phase completion
5. **Implement escalation matrix** for blocked work

### 8.3 Skill Adaptation for ConTStack

When adapting WTFB's `orchestration-patterns` skill for ConTStack:

```markdown
# orchestration-patterns/SKILL.md (adapted)

## When This Skill Applies
- Orchestrating multi-step implementation tasks (trigger: /rpi-full)
- Managing work across specialized agents (research, planning, implementation)
- Running long-running sessions (context > 30%)
- Preparing for merge (mandatory QAS gate)
- Session handoffs (trigger: /handoff)

## Workflow
1. RPI phases with human checkpoints
2. WTFB agent loop within implementation
3. Beads for tracking + Linear sync optional
4. QAS gate before merge (mandatory)
```

### 8.4 Evidence Template (Unified)

```markdown
## Phase [N] Evidence

**Beads Issue:** bd-XXXX
**Linear Ticket:** WOR-YYY (if applicable)

### Automated Verification
| Check | Status | Output |
|-------|--------|--------|
| Tests | PASS/FAIL | `bun test` log |
| Lint | PASS/FAIL | `bun lint` log |
| Types | PASS/FAIL | `bun typecheck` log |

### Manual Verification
- [ ] UI renders correctly (screenshot attached)
- [ ] API returns expected response
- [ ] [Other domain-specific checks]

### Evidence Files
- Research: `thoughts/shared/research/YYYY-MM-DD-{slug}.md`
- Plan: `thoughts/shared/plans/YYYY-MM-DD-{bd-id}-{slug}.md`
- QAS Report: `thoughts/shared/qa-validations/bd-XXXX-qa.md`
```

### 8.5 Context Management Best Practices

| Threshold | WTFB Approach | ConTStack Approach | Unified |
|-----------|---------------|-------------------|---------|
| < 30% | Continue | Continue | Continue freely |
| 30-40% | Checkpoint every 10-15 calls | Consider compaction | Checkpoint + prepare /compact |
| > 40% | State preservation | Compact now | Run /compact, create handoff |

### 8.6 Anti-Patterns to Avoid

| Anti-Pattern | Why It's Bad | Solution |
|--------------|--------------|----------|
| Skip research phase | Missing context leads to bad plans | Always run /research first |
| Skip QAS review | Miss commit message issues | Always invoke QAS pre-merge |
| No evidence in Beads/Linear | No audit trail | Attach evidence every phase |
| Ignore CI failures | Broken code reaches dev | Fix in agent loop, don't skip |
| Continue when blocked | Waste time, no progress | Escalate with context after 4hrs |
| Force-push without check | May lose teammate's changes | Use `--force-with-lease` |
| Skip human checkpoints | Loss of control | Always pause for approval |
| Ignore context window | Context overflow, lost state | Monitor via /status |

---

## Conclusion

WTFB's orchestration-patterns skill and ConTStack's RPI workflow represent complementary approaches to AI-assisted development orchestration. WTFB excels at automated validation loops and evidence-driven delivery with external tracking (Linear), while ConTStack provides structured human oversight, git-native tracking (Beads), and specialized agent coordination.

The recommended unified approach combines:
- **RPI phases** for structured workflow progression
- **WTFB agent loop** for efficient implementation cycles
- **Beads** for local-first dependency tracking
- **QAS gate** for independent pre-merge validation
- **Human checkpoints** at critical transitions

This hybrid model provides both the automation efficiency of WTFB and the oversight control of ConTStack, resulting in a robust orchestration system suitable for complex, multi-step development tasks.

---

*Document created: 2026-01-12*
*Comparison version: 1.0*
