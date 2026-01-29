# Pre-PR Validation Checklist

**Purpose**: Quality gate before PR creation

**Required By**: ARCHitect-in-CLI before creating PR for any investigation/implementation

**Version**: 1.0
**Last Updated**: 2025-10-06

---

## How to Use This Checklist

1. **Complete ALL sections** before creating PR
2. **If ANY item fails**: DO NOT CREATE PR until resolved
3. **System Architect review triggers**: BLOCK PR until approval obtained
4. **Document completion**: Attach checklist to Linear ticket

---

## Documentation Completeness

- [ ] All new files have headers with purpose/context
- [ ] README.md updated if new features added
- [ ] CONTRIBUTING.md updated if workflow changes
- [ ] Linear ticket updated with progress
- [ ] All TODOs completed or documented
- [ ] Inline comments explain complex logic
- [ ] API documentation updated (if applicable)

---

## Code Review Requirements

### System Architect Review Triggers (Check ALL that apply)

**CRITICAL**: If ANY box checked below, **MANDATORY System Architect review required**

#### Infrastructure & Automation

- [ ] **Bash scripts >100 lines** → MANDATORY System Architect review
  - Example: Deployment scripts, automation tools, setup scripts
  - {{TICKET_PREFIX}}-XXX Gap: 710-line `deploy-migration-prod.sh` delivered without review

- [ ] **CI/CD workflow created/modified** → MANDATORY System Architect review
  - Example: GitHub Actions workflows, pipeline changes
  - {{TICKET_PREFIX}}-XXX Gap: 641-line `migration-validation.yml` delivered without review

- [ ] **Infrastructure-as-code** → MANDATORY System Architect review
  - Example: Terraform, CloudFormation, Docker Compose
  - Impact: Production infrastructure changes

- [ ] **Deployment automation scripts** → MANDATORY System Architect review
  - Example: Production deployment, rollback scripts
  - Impact: Security-critical operations (SSH, Docker, credentials)

- [ ] **Container orchestration changes** → MANDATORY System Architect review
  - Example: Kubernetes manifests, Docker configurations
  - Impact: Production environment changes

#### Security-Critical Code

- [ ] **Database migration automation** → MANDATORY System Architect review
  - Example: Migration deployment scripts, RLS automation
  - Impact: Data integrity, security policies

- [ ] **Authentication/authorization logic** → MANDATORY System Architect review
  - Example: Auth middleware, permission checks
  - Impact: Security boundaries

- [ ] **SSH/remote execution scripts** → MANDATORY System Architect review
  - Example: Remote deployment, server management
  - Impact: Production access, credential handling

- [ ] **Secret management code** → MANDATORY System Architect review
  - Example: Credential rotation, secret injection
  - Impact: Security posture

- [ ] **RLS policy automation** → MANDATORY System Architect review
  - Example: Automated policy generation, validation
  - Impact: Data security enforcement

#### Complex TypeScript/JavaScript

- [ ] **Validation/verification scripts >200 lines** → MANDATORY System Architect review
  - Example: Pre-commit hooks, data validation
  - {{TICKET_PREFIX}}-XXX Gap: 3 TypeScript scripts delivered without review

- [ ] **Custom build tools** → MANDATORY System Architect review
  - Example: Build scripts, code generation
  - Impact: Development workflow

- [ ] **Database query builders** → MANDATORY System Architect review
  - Example: Dynamic query construction
  - Impact: SQL injection risk, performance

- [ ] **Pre-commit hooks** → MANDATORY System Architect review
  - Example: Linting automation, validation
  - Impact: Developer workflow

### System Architect Review Status

**If ANY boxes checked above**:

- [ ] **System Architect review requested**
- [ ] **System Architect feedback received**
- [ ] **All feedback addressed**
- [ ] **System Architect approval obtained**
- [ ] **Approval documented in Linear ticket**
- [ ] **Architectural decisions recorded (ADR if needed)**

**⚠️ BLOCK PR CREATION**: If ANY trigger matched but approval NOT obtained

### Standard Code Review

- [ ] Data Engineer reviewed database changes
- [ ] Security Engineer reviewed RLS policies
- [ ] Tech Writer reviewed documentation
- [ ] RTE reviewed CI/CD changes
- [ ] QAS reviewed testing strategy

---

## Security Validation

- [ ] No credentials committed (check .env files, config files)
- [ ] RLS policies present for all user data tables
- [ ] Authentication required for sensitive operations
- [ ] Input validation for all user inputs (Zod schemas)
- [ ] SQL injection prevention verified (use Prisma, no raw SQL)
- [ ] Secret management patterns followed (environment variables)
- [ ] HTTPS enforced for all external communications
- [ ] CORS configured correctly (if applicable)
- [ ] Rate limiting implemented (if applicable)
- [ ] Security headers configured (if applicable)

---

## Test Coverage

- [ ] Unit tests written for new functions
- [ ] Integration tests for API changes
- [ ] RLS tests for database changes
- [ ] E2E tests for UI changes (if applicable)
- [ ] CI/CD validation passing (`yarn ci:validate`)
- [ ] Local validation successful
- [ ] All tests passing (no skipped tests)
- [ ] Test coverage meets minimum threshold (if defined)
- [ ] Edge cases tested
- [ ] Error handling tested

---

## Linear Ticket Completeness

- [ ] All acceptance criteria met
- [ ] Ticket updated with deliverables
- [ ] Ticket references in commit messages
- [ ] Ticket ready for QAS review
- [ ] Stakeholder approval obtained (if required)
- [ ] Evidence attached (test results, screenshots, etc.)
- [ ] Session ID documented (for AI agent work)
- [ ] Time tracking updated (if applicable)

---

## Workflow Compliance

- [ ] Branch naming: `{{TICKET_PREFIX}}-{number}-{description}` or `__TICKET_PREFIX__-{number}-{description}`
- [ ] Commit messages: SAFe format with ticket reference
  - Format: `type(scope): description [{{TICKET_PREFIX}}-XXX]`
  - Types: feat, fix, docs, style, refactor, test, chore
- [ ] Rebase onto latest `dev` or `__PRIMARY_DEV_BRANCH__` (no merge commits)
- [ ] All automated checks passing
- [ ] PR template used completely
- [ ] No merge conflicts
- [ ] Linear history maintained

---

## Code Quality

- [ ] ESLint validation passing (`yarn lint`)
- [ ] TypeScript compilation successful (`yarn type-check`)
- [ ] Prettier formatting applied (`yarn format:check`)
- [ ] No console.log statements (use proper logging)
- [ ] No commented-out code (remove or document why)
- [ ] No hardcoded values (use constants/config)
- [ ] Error handling comprehensive
- [ ] Edge cases considered
- [ ] Performance implications considered

---

## Documentation Quality

- [ ] All new concepts explained
- [ ] Examples provided for complex features
- [ ] References to related docs
- [ ] No broken links
- [ ] Markdown linting passed (`yarn lint:md`)
- [ ] API documentation complete (if applicable)
- [ ] Migration guides provided (if breaking changes)
- [ ] Changelog updated (if applicable)

---

## Sign-Off

**Completed by**: [ARCHitect-in-CLI / Agent Name]  
**Date**: [YYYY-MM-DD]  
**Linear Ticket**: {{TICKET_PREFIX}}-XXX

### System Architect Approval (if required)

**Required**: If ANY System Architect review trigger matched

- [ ] **System Architect reviewed all complex code**
- [ ] **Approval documented in Linear ticket**
- [ ] **Architectural decisions recorded (ADR if needed)**
- [ ] **All feedback addressed**

**Approval Reference**: [Link to Linear comment or ADR]

### Final Validation

- [ ] **ALL checklist items complete**
- [ ] **ALL quality gates passed**
- [ ] **ALL reviews obtained**
- [ ] **Ready to create PR**

**⚠️ IF ANY ITEM FAILS: DO NOT CREATE PR UNTIL RESOLVED**

---

## Example: {{TICKET_PREFIX}}-321 Failure Analysis

**Gap Identified**: System Architect review NOT obtained before PR

### Items That Should Have Been Checked

- [x] Bash scripts >100 lines → ❌ NOT reviewed (deploy-migration-prod.sh, 710 lines)
- [x] CI/CD workflow created → ❌ NOT reviewed (migration-validation.yml, 641 lines)
- [x] Validation scripts >200 lines → ❌ NOT reviewed (3 TypeScript scripts)
- [ ] System Architect approval obtained → ❌ NOT obtained

### What Went Wrong

1. **Triggers Matched**: 3 different System Architect review triggers
2. **Review NOT Requested**: System Architect never invoked
3. **PR Created Anyway**: Quality gate bypassed
4. **Result**: Unreviewed security-critical code in production path

### Lesson Learned

**This checklist would have caught the gap before PR creation**

If this checklist had been used:

1. ✅ Identified 3 System Architect review triggers
2. ✅ Blocked PR creation until review obtained
3. ✅ Ensured architectural governance
4. ✅ Prevented unreviewed code in production

---

## Related Documentation

- `TDM_AGENT_ASSIGNMENT_MATRIX.md` - System Architect review triggers
- `ARCHITECT_IN_CLI_ROLE.md` - When to invoke System Architect
- `AGENT_WORKFLOW_SOP.md` - Method 4 (System Architect review process)
- `WORKFLOW_QUALITY_CHECKLIST.md` - ARCHitect-in-CLI self-validation

---

**This checklist prevents architectural governance gaps like {{TICKET_PREFIX}}-321**
