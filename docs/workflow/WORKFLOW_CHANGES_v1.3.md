# Workflow Changes v1.3

**Purpose**: Document evolution of SAFe Agentic Workflow patterns

**Current Version**: v1.3.1 (System Architect Review Gate)
**Last Updated**: 2025-10-06

---

## Version History

### v1.3.1 - System Architect Review Gate (2025-10-06)

#### What Changed

**Added**: MANDATORY System Architect review for complex automation/infrastructure code

**Rationale**: {{TICKET_PREFIX}}-321 gap discovery - 710-line bash script + 641-line CI/CD workflow deployed WITHOUT architectural review

#### The Gap ({{TICKET_PREFIX}}-321)

**What Happened**:

- ARCHitect-in-CLI orchestrated 10 subagent invocations
- Data Engineer delivered 710-line bash deployment script (`deploy-migration-prod.sh`)
- Data Engineer delivered 3 TypeScript validation scripts
- RTE delivered 641-line CI/CD workflow (`migration-validation.yml`)
- System Architect was **NEVER invoked**
- Complex automation merged without architectural oversight

**Impact**:

- Potential security/quality issues in unreviewed code
- Violated architectural governance process
- No quality gate before PR
- Security-critical code (SSH, Docker, database access) unreviewed

#### The Fix (v1.3.1)

**New Requirement**: ARCHitect-in-CLI MUST invoke System Architect for:

**Infrastructure & Automation**:

- Bash scripts >100 lines
- CI/CD workflows
- Infrastructure-as-code
- Deployment automation
- Container orchestration

**Security-Critical Code**:

- Database migration automation
- Auth/authorization logic
- SSH/remote execution
- Secret management
- RLS policy automation

**Complex Code**:

- TypeScript/JavaScript >200 lines
- Custom build tools
- Database query builders
- Pre-commit hooks

**Process**:

1. Specialist delivers complex code
2. ARCHitect-in-CLI invokes System Architect for review
3. System Architect approves OR requires fixes
4. Only after approval: Create PR

#### Workflow Comparison

**Before v1.3.1 ({{TICKET_PREFIX}}-321 Gap)**:

```
ARCHitect-in-CLI
├─ Data Engineer (710-line script)
├─ Data Engineer (3 TypeScript scripts)
├─ RTE (641-line CI/CD workflow)
└─ [CREATE PR] ← Missing System Architect review ❌
```

**After v1.3.1 (Correct)**:

```
ARCHitect-in-CLI
├─ Data Engineer (710-line script)
├─ System Architect (Review script) ← ADDED ✅
├─ Data Engineer (Address feedback)
├─ Data Engineer (3 TypeScript scripts)
├─ System Architect (Review scripts) ← ADDED ✅
├─ RTE (641-line CI/CD workflow)
├─ System Architect (Final review) ← ADDED ✅
└─ [CREATE PR] ← Only after approval ✅
```

#### Success Metrics

v1.3.1 prevents gaps when:

- 100% of complex automation reviewed before PR
- Architectural decisions documented
- Security patterns validated
- Code quality standards enforced

**Measurable Outcomes**:

- 0% unreviewed scripts >100 lines in production
- 100% System Architect approval for complex code
- Reduced production incidents from bad automation
- Higher team confidence in deliverables

---

### v1.3 - ARCHitect-in-CLI Direct Orchestration (2025-10-05)

#### What Changed

**Pattern**: ARCHitect-in-CLI orchestrates specialists directly (not through TDM)

**Rationale**:

- Faster coordination (no TDM intermediary)
- Direct communication with specialists
- Parallel invocation when no dependencies
- ARCHitect-in-CLI maintains context

#### Workflow Pattern

```
ARCHitect-in-CLI (Main Instance)
├─ Invokes specialists directly
├─ Coordinates parallel work
├─ Validates deliverables
└─ Creates PR (after all work complete)
```

**vs v1.2 (TDM Orchestration)**:

```
ARCHitect-in-CLI
└─ TDM (Orchestrator)
    ├─ Invokes specialists
    └─ Coordinates work
```

#### Benefits

- **Efficiency**: No intermediary overhead
- **Context**: ARCHitect-in-CLI maintains full investigation context
- **Flexibility**: Can invoke specialists in parallel or sequence as needed
- **Quality**: Direct validation of deliverables

#### When to Use

- Complex investigations requiring multiple specialists
- Work with clear dependencies (sequential) or independence (parallel)
- ARCHitect-in-CLI has full context of requirements

---

### v1.2 - TDM Orchestration (2025-09-15)

#### What Changed

**Pattern**: TDM coordinates specialist invocations

**Rationale**:

- Clear separation of concerns
- TDM expertise in coordination
- Standardized handoffs

#### Workflow Pattern

```
ARCHitect-in-CLI
└─ TDM
    ├─ BSA (Requirements)
    ├─ Specialist (Implementation)
    ├─ QAS (Testing)
    └─ RTE (PR)
```

#### When to Use

- Standard feature development
- Clear requirements with defined scope
- Multiple teams coordinating

---

### v1.1 - Specialist Direct Invocation (2025-09-01)

#### What Changed

**Pattern**: ARCHitect-in-CLI invokes single specialist for focused work

**Rationale**:

- Simple tasks don't need orchestration
- Direct communication for clarity
- Faster turnaround

#### Workflow Pattern

```
ARCHitect-in-CLI
└─ Specialist (Complete work)
```

#### When to Use

- Single-specialist tasks
- Documentation updates
- Simple bug fixes
- Configuration changes

---

### v1.0 - Baseline Workflow (2025-08-15)

#### Initial Pattern

**Simulated Subagent Work**: ARCHitect-in-CLI performed all work, simulating specialist roles

**Rationale**:

- Proof of concept
- No actual subagent invocation capability
- Single-agent workflow

#### Limitations

- No true specialization
- No parallel work
- Limited scalability
- No architectural governance

---

## Pattern Selection Guide

### Decision Tree

```
What type of work?
├─ Documentation only → v1.1 (Direct specialist)
├─ Simple feature → v1.2 (TDM orchestration)
├─ Complex investigation → v1.3 (ARCHitect-in-CLI orchestration)
└─ Complex automation → v1.3.1 (+ System Architect review)
```

### Complexity Indicators

**Use v1.3.1 (System Architect Review) when**:

- Creating bash scripts >100 lines
- Modifying CI/CD workflows
- Building infrastructure automation
- Implementing security-critical code
- Writing complex TypeScript/JavaScript >200 lines

**Use v1.3 (Direct Orchestration) when**:

- Multiple specialists needed
- Clear dependencies between work
- ARCHitect-in-CLI has full context
- Parallel work possible

**Use v1.2 (TDM Orchestration) when**:

- Standard feature development
- Multiple teams involved
- Clear requirements defined
- TDM coordination valuable

**Use v1.1 (Direct Specialist) when**:

- Single specialist sufficient
- Simple, focused task
- Quick turnaround needed
- No dependencies

---

## Quality Gates by Version

### v1.3.1 Quality Gates

- [ ] All specialists invoked correctly
- [ ] **System Architect review (if complex code)** ← NEW
- [ ] Security validation (if security-sensitive)
- [ ] Tests passing
- [ ] Documentation updated
- [ ] Evidence attached to Linear

### v1.3 Quality Gates

- [ ] All specialists invoked correctly
- [ ] Parallel/sequential coordination optimal
- [ ] All deliverables validated
- [ ] Tests passing
- [ ] Documentation updated

### v1.2 Quality Gates

- [ ] TDM coordinated all work
- [ ] All specialists completed tasks
- [ ] Handoffs documented
- [ ] Tests passing

### v1.1 Quality Gates

- [ ] Specialist completed work
- [ ] Quality standards met
- [ ] Tests passing

---

## Migration Path

### From v1.3 to v1.3.1

**Action Required**: Add System Architect review gates

**Steps**:

1. Review all existing complex automation
2. Invoke System Architect for retroactive review (if needed)
3. Update workflow documentation
4. Train team on new review triggers
5. Enforce gates in future work

**Timeline**: Immediate (prevent future gaps)

### From v1.2 to v1.3

**Action Required**: Enable ARCHitect-in-CLI direct orchestration

**Steps**:

1. Identify complex investigations
2. Use v1.3 pattern for multi-specialist work
3. Maintain v1.2 for standard features
4. Document pattern selection

**Timeline**: Gradual adoption

---

## Success Metrics

### v1.3.1 Metrics

- **Architectural Governance**: 100% complex automation reviewed
- **Security**: 0% unreviewed security-critical code
- **Quality**: Reduced production incidents from automation
- **Confidence**: Higher team confidence in deliverables

### v1.3 Metrics

- **Efficiency**: Faster multi-specialist coordination
- **Quality**: Direct validation of deliverables
- **Flexibility**: Optimal parallel/sequential work

### v1.2 Metrics

- **Coordination**: Clear handoffs between specialists
- **Standardization**: Consistent workflow patterns

### v1.1 Metrics

- **Speed**: Fast turnaround for simple tasks
- **Clarity**: Direct specialist communication

---

## Related Documentation

- `TDM_AGENT_ASSIGNMENT_MATRIX.md` - Specialist assignment guide
- `ARCHITECT_IN_CLI_ROLE.md` - ARCHitect-in-CLI responsibilities
- `AGENT_WORKFLOW_SOP.md` - Detailed workflow processes
- `PRE_PR_VALIDATION_CHECKLIST.md` - Quality gates before PR

---

## References

- **{{TICKET_PREFIX}}-321**: Migration Automation Workflow Report (v1.3.1 gap discovery)
- **Confluence**: SAFe Agentic Workflow Blueprint
- **{{PROJECT_SHORT}}-app**: Reference implementation

---

**Current Recommendation**: Use v1.3.1 for all complex automation to ensure architectural governance
