# SAFe ART Agent Team Guide

## Overview

The {{PROJECT_SHORT}} project uses a SAFe Agile Release Train (ART) agent team powered by Claude Code.
This guide explains how to work with the 11 specialized AI agents that support development workflows.

## Quick Start

### For Human Developers

1. **Understanding the Team**: We have 11 specialized agents, each with specific expertise
2. **Workflow Integration**: Agents follow the same git workflow and standards as human developers
3. **Evidence-Based Delivery**: All agent work is tracked in Linear with session evidence
4. **HITL Model**: {{AUTHOR_NAME}} (POPM) has final approval on all deliverables

### For AI Agents

1. **Read CONTRIBUTING.md** - MANDATORY before starting any work
2. **Follow your agent file** - `.claude/agents/{your-role}.md` contains your specific workflow
3. **Pattern discovery first** - Search codebase and session history before creating new code
4. **Evidence attachment** - Attach session ID and validation results to Linear tickets

## Agent Team Structure

### 11 Specialized Roles

| Agent                 | Primary Responsibility            | Key Output                            |
| --------------------- | --------------------------------- | ------------------------------------- |
| **TDM**               | Coordination, blocker resolution  | Linear updates, blocker tracking      |
| **BSA**               | Requirements, acceptance criteria | User stories, testing strategy        |
| **System Architect**  | Pattern validation, decisions     | ADRs, architectural approval          |
| **FE Developer**      | UI components, client logic       | React components, pages               |
| **BE Developer**      | API routes, server logic, RLS     | API endpoints with RLS                |
| **Data Engineer**     | Schema changes, migrations        | Prisma migrations, RLS policies       |
| **DPE**               | Test data, database access        | Seed scripts, test data               |
| **Technical Writer**  | Documentation, guides             | Markdown docs, API docs               |
| **QAS**               | Testing, quality validation       | Test suites, quality reports          |
| **Security Engineer** | Security audit, RLS validation    | Security reports, vulnerability scans |
| **RTE**               | PR creation, CI/CD, releases      | PRs, deployment coordination          |

## SAFe + Simon Willison Integration

### How SAFe Specs Feed Agentic Loops

**SAFe Methodology** provides structure:

- Epic → Features → Stories → Enablers (planning phase)
- Detailed specs with acceptance criteria
- Testing strategies and demo scripts

**Simon Willison's Loops** provide execution:

- Clear goals from specs
- Right tools for implementation
- Iterate until validation passes
- Escalate when blocked

**Integration Flow**:

````text
1. BSA: Confluence → planning_template.md → Epic/Features/Stories in Linear
2. BSA: Linear story → spec_template.md → Detailed implementation spec
3. Execution Agent: Read spec → Extract goal → Implement → Validate
4. Validation: Run demo script from spec → SUCCESS or iterate
```text

### Specs Directory Structure

```bash
specs/
├── planning_template.md          # SAFe planning template
├── spec_template.md              # Implementation spec template
├── {{TICKET_PREFIX_LOWER}}-228-planning.md           # Planning doc example
├── spec-{{TICKET_PREFIX_LOWER}}-135-posthog-analytics-safe.md  # Implementation spec example
└── README.md                     # Specs usage guide
```text

**Key Files**:

- `docs/team/PLANNING-AGENT-META-PROMPT.md` - Complete SAFe planning guide
- `specs/planning_template.md` - Epic → Features → Stories template
- `specs/spec_template.md` - User story → Low-level tasks template

## Agent Philosophy

### Simon Willison's Agentic Loop Principles

> "An LLM agent is something that runs tools in a loop to achieve a goal"

1. **Clear Goal** - BSA defines specific, measurable objectives
2. **Success Criteria** - Validation via test commands (e.g., `yarn lint:md && echo "SUCCESS"`)
3. **Right Tools** - Read, Write, Edit, Bash - only what's needed
4. **Iterate Until Success** - No arbitrary limits, agents decide when blocked
5. **Escalate When Needed** - Agent determines when to escalate to TDM or ARCHitect

### Pattern Discovery Protocol (MANDATORY)

**Every agent MUST search before creating:**

```bash
# 1. Search codebase
grep -r "feature_name|functionality" app/ lib/

# 2. Search session history
grep -r "similar_pattern" ~/.claude/todos/ 2>/dev/null

# 3. Review documentation
cat CONTRIBUTING.md
cat docs/database/DATA_DICTIONARY.md

# 4. Propose to System Architect
# 5. Get approval before coding
```text

### Session Archaeology

All Claude sessions create `~/.claude/todos/*.json` files:

```bash
# Find concurrent agent work
ls -lt ~/.claude/todos/*.json | head -10

# Search for patterns across all sessions
grep -r "pattern_name" ~/.claude/todos/

# Monitor concurrent work on same files
grep -l "file_path" ~/.claude/todos/*.json
```text

**Evidence Attachment**: Always attach session ID to Linear tickets for traceability.

## Workflows by Role

### Business Systems Analyst (BSA)

**When to Engage**: New feature requirements, user stories needed

**Workflow**:

1. Receive business requirement from POPM
2. Search for similar user stories
3. Create user story with testable acceptance criteria
4. Define testing strategy (unit, integration, E2E)
5. Get System Architect approval
6. Attach to Linear ticket

**Success Criteria**: `yarn lint:md` passes, user story testable

**Reference**: `.claude/agents/bsa.md`

### System Architect

**When to Engage**: Architectural decisions, pattern validation

**Workflow**:

1. Receive proposed pattern from agent
2. Search for existing patterns
3. Evaluate against SOLID principles
4. Check RLS and security implications
5. Approve or reject with rationale
6. Create ADR if significant decision

**Success Criteria**: `yarn lint && yarn type-check && yarn build` passes

**Reference**: `.claude/agents/system-architect.md`

### Technical Delivery Manager (TDM)

**When to Engage**: Coordination, blocker resolution, Linear updates

**Workflow**:

1. Monitor agent sessions via `~/.claude/todos/`
2. Coordinate work to prevent conflicts
3. Resolve blockers (escalate to ARCHitect if needed)
4. Update Linear tickets with evidence
5. Manage PR queue and merges

**Success Criteria**: `yarn ci:validate` passes, Linear current

**Reference**: `.claude/agents/tdm.md`

### Frontend Developer

**When to Engage**: UI components, pages, client-side logic

**Workflow**:

1. Search for similar components
2. Reuse shadcn/ui components
3. Implement with TypeScript, Tailwind
4. Ensure accessibility (WCAG AA)
5. Validate with `yarn lint && yarn build`

**Success Criteria**: Components render, tests pass, build succeeds

**Reference**: `.claude/agents/fe-developer.md`

### Backend Developer

**When to Engage**: API routes, server logic, database operations

**Workflow**:

1. Search for similar API patterns
2. Implement with RLS context helpers (MANDATORY)
3. Add authentication via `await auth()`
4. Input validation with Zod schemas
5. Integration tests for all endpoints

**Success Criteria**: `yarn test:integration` passes, RLS enforced

**Reference**: `.claude/agents/be-developer.md`

**CRITICAL**: NEVER use direct Prisma calls. ALWAYS use `withUserContext`, `withAdminContext`, or `withSystemContext`.

### Data Engineer (DE)

**When to Engage**: Schema changes, migrations, RLS policies

**Workflow**:

1. Request ARCHitect approval (MANDATORY)
2. Create Prisma migration
3. Add/update RLS policies if needed
4. Test with `{{LINEAR_WORKSPACE}}_app_user` (not superuser)
5. Validate RLS enforcement
6. Update DATA_DICTIONARY.md

**Success Criteria**: Migration applied, RLS validated

**Reference**: `.claude/agents/data-engineer.md`

**MANDATORY**: Follow `RLS_DATABASE_MIGRATION_SOP.md` for all schema changes.

### Data Provisioning Engineer (DPE)

**When to Engage**: Test data creation, database access

**Workflow**:

1. Follow `CLAUDE_REMOTE_DATABASE_SOP.md` (MANDATORY for remote DB)
2. Create seed scripts with system RLS context
3. Generate test data for all user types
4. Validate data integrity and RLS enforcement
5. Document test data inventory

**Success Criteria**: Test data available, validation scripts pass

**Reference**: `.claude/agents/data-provisioning-eng.md`

### Technical Writer (TW)

**When to Engage**: Documentation, guides, API docs

**Workflow**:

1. Search for similar documentation
2. Create docs following markdown standards
3. Test all code examples
4. Verify links (internal and external)
5. Validate with `yarn lint:md`

**Success Criteria**: Markdown linting passes, examples work

**Reference**: `.claude/agents/tech-writer.md`

### Quality Assurance Specialist (QAS)

**When to Engage**: Execute BSA testing strategy, validate acceptance criteria

**Workflow**:

1. Review BSA testing strategy
2. Create unit, integration, E2E tests
3. Validate all acceptance criteria
4. Check test coverage meets requirements
5. Report quality status with evidence

**Success Criteria**: `yarn test:unit && yarn test:integration && yarn test:e2e` passes

**Reference**: `.claude/agents/qas.md`

### Security Engineer (SecEng)

**When to Engage**: Security validation, RLS audit, vulnerability scan

**Workflow**:

1. Audit authentication/authorization
2. Validate RLS enforcement
3. Run security scans (`npm audit`)
4. Check for exposed secrets
5. Approve or block based on findings

**Success Criteria**: RLS validated, no vulnerabilities, secrets protected

**Reference**: `.claude/agents/security-engineer.md`

**CRITICAL**: Zero tolerance for security violations. Block deployment if issues found.

### Release Train Engineer (RTE)

**When to Engage**: PR creation, CI/CD validation, deployment

**Workflow**:

1. Validate `yarn ci:validate` passes locally
2. Ensure rebase on latest dev (linear history)
3. Create PR with complete template
4. Monitor CI/CD pipeline
5. Merge using "Rebase and merge" ONLY

**Success Criteria**: CI passes, PR merged, linear history maintained

**Reference**: `.claude/agents/rte.md`

**MANDATORY**: NEVER use "Squash and merge" or "Create merge commit".

## Common Workflows

### Workflow 1: New Feature Implementation

1. **BSA**: Create user story with acceptance criteria
2. **System Architect**: Validate architectural approach
3. **TDM**: Assign to FE/BE developers, create Linear ticket
4. **DE**: Create migration if schema change needed (ARCHitect approval)
5. **DPE**: Provision test data
6. **FE/BE Developers**: Implement feature with RLS
7. **QAS**: Execute testing strategy, validate ACs
8. **SecEng**: Security audit and RLS validation
9. **TW**: Document feature
10. **RTE**: Create PR, monitor CI, merge
11. **TDM**: Update Linear, tag POPM for review

### Workflow 2: Bug Fix

1. **BSA**: Create bug fix user story
2. **System Architect**: Validate fix approach
3. **TDM**: Assign to developer, track in Linear
4. **Developer**: Fix with test coverage
5. **QAS**: Verify bug fixed, regression tests
6. **SecEng**: Security impact assessment
7. **RTE**: Create PR, merge
8. **TDM**: Update Linear, tag POPM

### Workflow 3: Database Migration

1. **DE**: Request ARCHitect approval with migration plan
2. **ARCHitect**: Review and approve (MANDATORY)
3. **DE**: Create Prisma migration, update RLS policies
4. **DE**: Test locally with `{{LINEAR_WORKSPACE}}_app_user`
5. **DPE**: Update test data for new schema
6. **BE Developer**: Update API routes if needed
7. **QAS**: Integration tests for migration
8. **SecEng**: RLS validation post-migration
9. **TW**: Update DATA_DICTIONARY.md
10. **RTE**: Create PR, deploy migration

## Escalation Paths

### To ARCHitect ({{AUTHOR_HANDLE}}) - MANDATORY

- Database schema changes (DE)
- Core architecture modifications (System Architect)
- Security model changes (SecEng)
- CI/CD pipeline issues (RTE)

### To POPM ({{AUTHOR_NAME}}) - HITL Model

- Unclear business requirements (BSA)
- Conflicting priorities (TDM)
- Scope changes (BSA)
- Final approval on all deliverables (All agents)

### To TDM - Blocker Resolution

- Development blockers (All agents)
- Cross-agent coordination needed (All agents)
- CI/CD failures (RTE)
- Resource constraints (All agents)

## Evidence-Based Delivery

### What to Attach to Linear

Every completed ticket must have:

1. **Session ID(s)** - From `~/.claude/todos/` for traceability
2. **Validation Results** - Output from success validation commands
3. **Test Coverage** - Unit, integration, E2E results
4. **Pattern Discovery** - What existing patterns were reused
5. **Quality Report** - From QAS with acceptance criteria validation
6. **Security Audit** - From SecEng with RLS validation

### Example Evidence Attachment

```markdown
## Agent Evidence - {{TICKET_PREFIX}}-123

### Sessions

- BSA: session_abc123
- FE Developer: session_def456
- QAS: session_ghi789

### Validation Results

\`\`\`bash
yarn ci:validate

# All checks passed ✅

\`\`\`

### Test Coverage

- Unit: 95%
- Integration: 100%
- E2E: 3 workflows

### Security Audit

- RLS enforced: ✅
- Auth required: ✅
- No vulnerabilities: ✅

### Quality Gate: PASS ✅
```text

## Agent Coordination via Session Archaeology

### Prevent Conflicts

```bash
# Before starting work, check for concurrent sessions
ls -lt ~/.claude/todos/*.json | head -10

# Check if another agent is working on same file
grep -l "target_file.ts" ~/.claude/todos/*.json

# Coordinate with TDM if conflict detected
```text

### Discover Patterns

```bash
# Find how similar features were implemented
grep -r "withUserContext" ~/.claude/todos/

# Learn from past architectural decisions
grep -r "architectural|ADR|decision" ~/.claude/todos/
```text

### Cross-Agent Learning

```bash
# FE Developer learns from past API integrations
grep -r "fetch.*api" ~/.claude/todos/

# BE Developer learns RLS patterns
grep -r "withAdminContext|withSystemContext" ~/.claude/todos/
```text

## Key Principles

### 1. Search First, Reuse Always

- Grep codebase for similar implementations
- Search `~/.claude/todos/` for past agent work
- Review documentation (DATA_DICTIONARY.md, RLS guides)
- Only create new code when existing patterns don't fit

### 2. Pattern Discovery is MANDATORY

Every agent must:

1. Search codebase
2. Search session history
3. Review documentation
4. Propose to System Architect
5. Get approval before coding

### 3. Security First

- RLS enforcement on ALL database operations
- Authentication on ALL protected API routes
- Input validation with Zod schemas
- No secrets in code

### 4. Evidence-Based Delivery

- All work tracked in Linear
- Session IDs attached
- Validation results documented
- POPM approval required

### 5. No Over-Engineering

Following Simon Willison:

- ❌ No file locks
- ❌ No circuit breakers
- ❌ No arbitrary retry limits
- ✅ Clear goals + right tools
- ✅ Let agents iterate
- ✅ Agent decides when to escalate

## Documentation Reference

### Core Documentation (All Agents)

- `CONTRIBUTING.md` - Workflow and standards (MANDATORY)
- `AGENTS.md` - Quick reference for all agents
- `.claude/agents/{role}.md` - Your specific agent workflow

### Technical Documentation

- `DATA_DICTIONARY.md` - Database schema (SINGLE SOURCE OF TRUTH)
- `RLS_IMPLEMENTATION_GUIDE.md` - RLS patterns (MANDATORY for DB ops)
- `SECURITY_FIRST_ARCHITECTURE.md` - Security principles
- `RLS_DATABASE_MIGRATION_SOP.md` - Schema changes (DE MANDATORY)
- `CLAUDE_REMOTE_DATABASE_SOP.md` - Remote DB access (DPE MANDATORY)

### Process Documentation

- `.github/pull_request_template.md` - PR template (RTE MANDATORY)
- `CODEOWNERS` - Reviewer assignment
- `.github/workflows/` - CI/CD pipeline

## Confluence Documentation

- [SAFe ART Agent Team: Evidence-Based Delivery Model](https://{{AUTHOR_HANDLE}}.atlassian.net/wiki/spaces/WA/pages/365264898) - Complete agent team structure
- [Coding Standards & Pattern Discovery](https://{{AUTHOR_HANDLE}}.atlassian.net/wiki/spaces/WA/pages/365494275) - Standards and discovery protocol

## Getting Started

### For New Agents

1. **Read your agent file**: `.claude/agents/{your-role}.md`
2. **Read CONTRIBUTING.md**: Complete workflow understanding
3. **Practice pattern discovery**: Search codebase and sessions
4. **Understand your success criteria**: Know how to validate your work
5. **Learn escalation paths**: When to escalate and to whom

### For Human Developers

1. **Understand agent capabilities**: Review AGENTS.md
2. **Assign work via TDM**: Let TDM coordinate agent assignments
3. **Review agent evidence**: Check Linear tickets for session IDs
4. **Trust the process**: Agents follow the same standards as humans
5. **Provide feedback**: Help improve agent workflows

## Success Metrics

### Agent Performance

- **Pattern Reuse Rate**: % of code reusing existing patterns
- **First-Time Success Rate**: % of work passing validation first try
- **Escalation Rate**: % of work requiring TDM/ARCHitect escalation
- **Evidence Quality**: Completeness of Linear attachments

### Team Performance

- **Velocity**: Story points completed per sprint
- **Quality**: % of PRs passing all CI checks first time
- **Security**: Zero security vulnerabilities in production
- **POPM Approval Rate**: % of work approved by Scott first time

---

**Remember**: The agent team exists to accelerate delivery while maintaining quality. Follow your agent workflow, discover patterns first, and deliver evidence-based results.

**Last Updated**: 2025-10-03
**Maintained by**: {{PROJECT_SHORT}} Development Team + ARCHitect-in-the-IDE (Auggie)
````
