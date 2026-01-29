# Workflow Quality Checklist

**Purpose**: ARCHitect-in-CLI self-validation during investigations/implementations

**When to Use**: Before finalizing work and creating PR

**Version**: 1.0
**Last Updated**: 2025-10-06

---

## How to Use This Checklist

1. **Complete during investigation**: Check items as you progress
2. **Self-validate before PR**: Ensure all items complete
3. **Critical checkpoint**: System Architect review for complex code
4. **Document completion**: Attach to Linear ticket

---

## Subagent Orchestration Quality

### All Necessary Specialists Invoked?

- [ ] **Tech Writer** for documentation
- [ ] **Data Engineer** for database/backend changes
- [ ] **Security Engineer** for RLS/security validation
- [ ] **FE Developer** for UI changes
- [ ] **BE Developer** for API/server logic
- [ ] **RTE** for CI/CD changes
- [ ] **System Architect** for complex code review ← **CRITICAL**
- [ ] **BSA** for requirements clarification (if needed)
- [ ] **QAS** for testing strategy (if needed)

### Correct Specialist for Each Task?

- [ ] Database changes → Data Engineer (NOT BE Developer)
- [ ] Documentation → Tech Writer (NOT Data Engineer)
- [ ] Security → Security Engineer (NOT QAS)
- [ ] Architectural review → System Architect (NOT skipped)
- [ ] CI/CD workflows → RTE (NOT BE Developer)
- [ ] Testing strategy → QAS (NOT FE Developer)

### Parallel vs Sequential Invocation?

- [ ] Independent tasks invoked in parallel (efficiency)
- [ ] Dependent tasks invoked sequentially (correctness)
- [ ] Complex code reviewed BEFORE PR (governance)
- [ ] No unnecessary waiting (optimal coordination)

---

## Deliverable Quality

### Code Quality (if applicable)

- [ ] Scripts >100 lines reviewed by System Architect
- [ ] Error handling comprehensive
- [ ] Edge cases considered
- [ ] Security patterns followed
- [ ] Documentation complete
- [ ] No hardcoded credentials
- [ ] No commented-out code
- [ ] Logging appropriate
- [ ] Performance considered

### Documentation Quality

- [ ] All new concepts explained
- [ ] Examples provided
- [ ] References to related docs
- [ ] No broken links
- [ ] Markdown linting passed
- [ ] API documentation complete (if applicable)
- [ ] Migration guides provided (if breaking changes)
- [ ] Changelog updated (if applicable)

### Testing Quality

- [ ] Unit tests for new functions
- [ ] Integration tests for workflows
- [ ] RLS tests for database changes
- [ ] All tests passing locally
- [ ] CI/CD validation passing
- [ ] Edge cases tested
- [ ] Error handling tested
- [ ] Performance tested (if applicable)

---

## Workflow Pattern Compliance

### v1.3 Pattern Followed?

- [ ] ARCHitect-in-CLI orchestrated (not TDM)
- [ ] Specialists invoked directly
- [ ] No simulated work (actual agent invocations)
- [ ] All outputs verified
- [ ] Context maintained throughout

### System Architect Review? (CRITICAL CHECKPOINT)

**⚠️ MANDATORY CHECKPOINT - DO NOT SKIP**

Check if ANY of the following apply:

#### Infrastructure & Automation

- [ ] Created bash scripts >100 lines?
- [ ] Created/modified CI/CD workflows?
- [ ] Created infrastructure automation?
- [ ] Created deployment scripts?
- [ ] Created container orchestration?

#### Security-Critical Code

- [ ] Created database migration automation?
- [ ] Created auth/authorization logic?
- [ ] Created SSH/remote execution scripts?
- [ ] Created secret management code?
- [ ] Created RLS policy automation?

#### Complex Code

- [ ] Created TypeScript/JavaScript >200 lines?
- [ ] Created custom build tools?
- [ ] Created database query builders?
- [ ] Created pre-commit hooks?

### System Architect Review Status

**If ANY box checked above**:

- [ ] **System Architect review requested**
- [ ] **System Architect feedback received**
- [ ] **All feedback addressed**
- [ ] **System Architect approval obtained**
- [ ] **Approval documented in Linear**

**⚠️ IF ANY "complex code" BOX CHECKED BUT REVIEW NOT OBTAINED:**

**STOP - Invoke System Architect now before proceeding**

---

## Quality Gates Passed?

### Pre-PR Quality Gates

- [ ] All TODOs completed
- [ ] All subagent deliverables received
- [ ] **System Architect approval (if required)** ← CRITICAL
- [ ] Security validation complete
- [ ] Linear ticket updated
- [ ] Evidence collected
- [ ] Ready for PR creation

### Code Quality Gates

- [ ] ESLint passing (`yarn lint`)
- [ ] TypeScript compiling (`yarn type-check`)
- [ ] Prettier formatting (`yarn format:check`)
- [ ] All tests passing (`yarn ci:validate`)
- [ ] No console.log statements
- [ ] No merge conflicts

### Documentation Quality Gates

- [ ] All files have headers
- [ ] README updated (if needed)
- [ ] CONTRIBUTING updated (if workflow changes)
- [ ] Markdown linting passed
- [ ] No broken links

---

## {{TICKET_PREFIX}}-321 Retrospective Check

**Purpose**: Prevent {{TICKET_PREFIX}}-321-type gaps in future work

### Gap Prevention Questions

**Question 1**: Did I create complex automation?

- [ ] **NO** → Skip to next section
- [ ] **YES** → Continue to Question 2

**Question 2**: Did I create bash scripts >100 lines?

- [ ] **NO** → Continue to Question 3
- [ ] **YES** → System Architect review REQUIRED

**Question 3**: Did I create CI/CD workflows?

- [ ] **NO** → Continue to Question 4
- [ ] **YES** → System Architect review REQUIRED

**Question 4**: Did I create TypeScript/JavaScript >200 lines?

- [ ] **NO** → Continue to Question 5
- [ ] **YES** → System Architect review REQUIRED

**Question 5**: Did I create security-critical code?

- [ ] **NO** → Continue to Question 6
- [ ] **YES** → System Architect review REQUIRED

**Question 6**: Did System Architect review all complex code?

- [ ] **YES** → Proceed with confidence ✅
- [ ] **NO** → BLOCK PR - Invoke System Architect now ❌

### Self-Check Question

**"Would {{TICKET_PREFIX}}-321 gap happen with this workflow?"**

- [ ] **NO** → Proceed with confidence
- [ ] **YES** → Fix before PR
- [ ] **UNSURE** → Review {{TICKET_PREFIX}}-321 report, invoke System Architect

### {{TICKET_PREFIX}}-321 Gap Indicators

**⚠️ WARNING SIGNS** (If ANY apply, review workflow):

- [ ] Created 710-line bash script without review
- [ ] Created CI/CD workflow without review
- [ ] Created TypeScript scripts without review
- [ ] Skipped System Architect review for complex code
- [ ] Created PR without architectural approval

**If ANY warning signs present: STOP - Review workflow and invoke System Architect**

---

## Evidence Collection

### Required Evidence

- [ ] Test results (unit, integration, e2e)
- [ ] Validation command outputs (`yarn ci:validate`)
- [ ] Manual testing screenshots/videos (if applicable)
- [ ] Performance metrics (if applicable)
- [ ] Security review results (if applicable)
- [ ] System Architect approval (if complex code)

### Evidence Attachment

- [ ] All evidence collected during development
- [ ] Evidence attached to Linear ticket
- [ ] Evidence referenced in PR description
- [ ] Session ID included (for AI agent work)

---

## Final Validation

### Pre-PR Checklist Complete?

- [ ] All sections of this checklist complete
- [ ] All quality gates passed
- [ ] All reviews obtained
- [ ] All evidence collected
- [ ] Linear ticket updated
- [ ] Ready to create PR

### System Architect Approval (if required)

**CRITICAL**: If ANY complex code created

- [ ] **System Architect reviewed all complex code**
- [ ] **Approval documented in Linear**
- [ ] **Architectural decisions recorded**
- [ ] **All feedback addressed**

### Final Sign-Off

**Completed by**: [ARCHitect-in-CLI]  
**Date**: [YYYY-MM-DD]  
**Linear Ticket**: {{TICKET_PREFIX}}-XXX

**System Architect Approval**: [YES/NO/N/A]  
**Approval Reference**: [Link to Linear comment or ADR]

**⚠️ IF ANY ITEM FAILS: DO NOT CREATE PR UNTIL RESOLVED**

---

## Success Patterns

### Pattern 1: Documentation-Only Work

**Checklist Result**:

- ✅ All documentation complete
- ✅ No complex code created
- ✅ System Architect review: N/A
- ✅ Ready for PR

**Example**: {{TICKET_PREFIX}}-321 documentation files (runbooks, best practices)

### Pattern 2: Simple Code Changes

**Checklist Result**:

- ✅ Code changes <100 lines
- ✅ Tests passing
- ✅ System Architect review: N/A
- ✅ Ready for PR

**Example**: Bug fixes, configuration updates

### Pattern 3: Complex Automation (MANDATORY Review)

**Checklist Result**:

- ✅ Complex code created
- ✅ System Architect review: REQUIRED
- ✅ System Architect approval: OBTAINED
- ✅ All feedback addressed
- ✅ Ready for PR

**Example**: Deployment scripts, CI/CD workflows, validation tools

---

## Failure Patterns (Avoid These)

### Anti-Pattern 1: {{TICKET_PREFIX}}-321 Gap

**What Happened**:

- ❌ Created 710-line bash script
- ❌ Created 641-line CI/CD workflow
- ❌ Created 3 TypeScript scripts
- ❌ System Architect review: NOT OBTAINED
- ❌ PR created anyway

**Result**: Unreviewed security-critical code in production

**Prevention**: This checklist would have blocked PR creation

### Anti-Pattern 2: Skipping Quality Gates

**What Happened**:

- ❌ Tests not run locally
- ❌ CI/CD validation skipped
- ❌ Documentation incomplete
- ❌ PR created anyway

**Result**: Failed CI/CD, PR rejected, rework required

**Prevention**: Complete all quality gates before PR

### Anti-Pattern 3: Wrong Specialist Assignment

**What Happened**:

- ❌ BE Developer for database migration (should be Data Engineer)
- ❌ Data Engineer for documentation (should be Tech Writer)
- ❌ No System Architect review for complex code

**Result**: Suboptimal deliverables, missing expertise

**Prevention**: Use correct specialist for each task

---

## Related Documentation

- `TDM_AGENT_ASSIGNMENT_MATRIX.md` - Specialist assignment guide
- `ARCHITECT_IN_CLI_ROLE.md` - ARCHitect-in-CLI responsibilities
- `AGENT_WORKFLOW_SOP.md` - Detailed workflow processes
- `PRE_PR_VALIDATION_CHECKLIST.md` - Quality gates before PR

---

## Version History

### v1.0 (2025-10-06)

- Initial workflow quality checklist
- {{TICKET_PREFIX}}-321 retrospective check
- System Architect review gates
- Gap prevention questions

---

**This checklist prevents architectural governance gaps like {{TICKET_PREFIX}}-321**

**Remember**: Quality is not negotiable. Take time to do it right the first time.
