# Engineer Daily Workflow Guide

**Role**: Frontend Developer (FE) or Backend Developer (BE)
**Purpose**: Day-to-day workflow for implementing features, fixing bugs, and delivering code within the SAFe multi-agent harness.

**Prerequisites**:

- Claude Code or Augment Code installed and configured
- Access to Linear workspace with assigned tickets
- Repository cloned with agent system verified (see [AGENT-SETUP-GUIDE.md](./AGENT-SETUP-GUIDE.md))
- Familiarity with the 11-agent team structure (see [AGENTS.md](../../AGENTS.md))

**Key Skills**: `safe-workflow`, `pattern-discovery`, `api-patterns` (BE), `frontend-patterns` (FE)

---

## Start of Day: Sync and Review

### Step 1: Pull Latest Changes

Always start from the latest state of the primary development branch. The SAFe workflow uses a rebase-first strategy, so staying current prevents conflicts.

```bash
# Fetch and pull the latest
git checkout {{MAIN_BRANCH}}
git pull origin {{MAIN_BRANCH}}

# If you have a feature branch in progress, rebase it
git checkout {{TICKET_PREFIX}}-XXX-your-feature
git rebase origin/{{MAIN_BRANCH}}
```

### Step 2: Check Linear for Assigned Tickets

Review your ticket queue in Linear. Focus on tickets in the **Ready** or **In Progress** swimlanes assigned to your role.

```bash
# Use Linear MCP tools to check your queue
mcp__{{MCP_LINEAR_SERVER}}__search_issues "assignee:me state:Ready"
mcp__{{MCP_LINEAR_SERVER}}__search_issues "assignee:me state:In Progress"
```

### Step 3: Read the Spec for Your Ticket

Every ticket should have an associated spec created by the BSA. Read it before writing any code.

```bash
# Find and read the spec
cat specs/{{TICKET_PREFIX}}-XXX-{feature}-spec.md

# Extract your implementation tasks
grep -A 30 "Low-Level Tasks" specs/{{TICKET_PREFIX}}-XXX-{feature}-spec.md

# Check for security-critical requirements
grep "#EXPORT_CRITICAL" specs/{{TICKET_PREFIX}}-XXX-{feature}-spec.md

# Check for architectural decisions that affect your work
grep "#PATH_DECISION" specs/{{TICKET_PREFIX}}-XXX-{feature}-spec.md
```

---

## `/start-work [ticket]` Command Walkthrough

Use the `/start-work` command to begin working on a ticket. This initializes your session with the right context.

```
/start-work {{TICKET_PREFIX}}-XXX
```

### What Happens When You Start Work

1. **Ticket context loads** - The ticket details, acceptance criteria, and testing strategy are pulled from Linear
2. **Spec is located** - The associated spec file in `specs/` is identified and read
3. **Branch is created** (if one does not exist):

   ```bash
   git checkout -b {{TICKET_PREFIX}}-XXX-short-description
   ```

4. **Session tracking begins** - Your Claude Code session ID is recorded for evidence gathering
5. **Skills are loaded** - Relevant skills (`safe-workflow`, `pattern-discovery`, and role-specific skills) activate automatically

### After Starting Work

Verify you are on the correct branch and understand the scope:

```bash
# Confirm branch
git branch --show-current
# Should show: {{TICKET_PREFIX}}-XXX-short-description

# Confirm spec is available
ls specs/{{TICKET_PREFIX}}-XXX-*-spec.md
```

---

## Pattern Discovery Protocol (MANDATORY)

**"Search First, Reuse Always, Create Only When Necessary"**

Before writing any code, you must search for existing patterns. This is not optional. Pattern discovery prevents duplicate implementations and maintains architectural consistency.

### Step 1: Search the Specs Directory

```bash
# Find similar implementations in specs
ls specs/*-spec.md | grep "similar_feature"

# Review SAFe user stories for related work
grep -r "As a.*I want to" specs/
```

### Step 2: Search the Codebase

**For Backend Developers**:

```bash
# Search for similar API routes
grep -r "route_name\|endpoint_name" {{SOURCE_DIR}}/
grep -r "similar_functionality" {{SOURCE_DIR}}/api/

# Find existing helpers and utilities
ls lib/ && grep -r "helper_pattern" lib/

# Check for RLS context usage patterns
grep -r "withUserContext\|withAdminContext\|withSystemContext" {{SOURCE_DIR}}/
```

**For Frontend Developers**:

```bash
# Search for similar components
grep -r "ComponentName\|similar_component" {{COMPONENTS_DIR}}/

# Find existing UI patterns
ls {{COMPONENTS_DIR}}/ && grep -r "pattern_name" {{COMPONENTS_DIR}}/

# Check for existing hooks and utilities
grep -r "useHookName\|similar_hook" {{SOURCE_DIR}}/hooks/
```

### Step 3: Search the Pattern Library

```bash
# List available patterns
ls patterns_library/

# For BE: Check API patterns
cat patterns_library/api/user-context-api.md 2>/dev/null

# For FE: Check frontend patterns
cat patterns_library/ui/form-with-validation.md 2>/dev/null

# For database operations: Check RLS patterns
cat patterns_library/database/rls-migration.md 2>/dev/null
```

### Step 4: Search Session History

```bash
# Find related work from past sessions
grep -r "similar_feature\|pattern_name" ~/.claude/todos/ 2>/dev/null
```

### Step 5: Consult Documentation

- [CONTRIBUTING.md](../../CONTRIBUTING.md) - Workflow and git process
- [docs/database/DATA_DICTIONARY.md](../database/DATA_DICTIONARY.md) - Database schema (SINGLE SOURCE OF TRUTH)
- [docs/database/RLS_IMPLEMENTATION_GUIDE.md](../database/RLS_IMPLEMENTATION_GUIDE.md) - Row Level Security patterns
- [docs/security/SECURITY_FIRST_ARCHITECTURE.md](../security/SECURITY_FIRST_ARCHITECTURE.md) - Security architecture

### Step 6: Propose to System Architect (If Needed)

If no existing pattern fits, or if you are creating a new architectural pattern:

```
@system-architect I need to implement [feature] for {{TICKET_PREFIX}}-XXX.
I searched for existing patterns and found [results].
I propose [approach]. Please validate before I proceed.
```

---

## Implementation Workflow

### Writing Code

Follow the spec's low-level tasks as your implementation guide. The BSA has already decomposed the work.

**Backend Developer Checklist**:

- [ ] Use RLS context helpers (`withUserContext`, `withAdminContext`, `withSystemContext`) for all database operations
- [ ] Validate input with the project's validation library (e.g., Zod schemas)
- [ ] Follow error handling patterns from `patterns_library/api/`
- [ ] Write unit tests alongside implementation
- [ ] Reference the Data Dictionary for schema questions

**Frontend Developer Checklist**:

- [ ] Follow component patterns from `patterns_library/ui/`
- [ ] Use the project's UI component library ({{UI_LIBRARY}})
- [ ] Implement proper loading and error states
- [ ] Follow accessibility standards
- [ ] Write component tests alongside implementation

### Commit Format

Every commit must follow the SAFe conventional commit format with a Linear ticket reference:

```
type(scope): description [{{TICKET_PREFIX}}-XXX]
```

**Types**:

| Type       | When to Use                               |
| ---------- | ----------------------------------------- |
| `feat`     | New feature or capability                 |
| `fix`      | Bug fix                                   |
| `refactor` | Code restructuring (no behavior change)   |
| `test`     | Adding or updating tests                  |
| `docs`     | Documentation changes                     |
| `style`    | Code formatting (no logic change)         |
| `chore`    | Maintenance, dependency updates           |
| `ci`       | CI/CD pipeline changes                    |

**Scopes** (use the area you are changing):

| Scope      | Area                    |
| ---------- | ----------------------- |
| `api`      | API routes and backend  |
| `ui`       | User interface          |
| `auth`     | Authentication          |
| `payments` | Payment features        |
| `db`       | Database changes        |

**Examples**:

```bash
# Feature implementation
git commit -m "feat(api): add user profile endpoint with RLS context [{{TICKET_PREFIX}}-123]"

# Bug fix
git commit -m "fix(ui): resolve login redirect loop on expired session [{{TICKET_PREFIX}}-456]"

# Test addition
git commit -m "test(api): add integration tests for profile endpoint [{{TICKET_PREFIX}}-123]"

# Multi-line commit for complex changes
git commit -m "$(cat <<'EOF'
feat(payments): add Stripe checkout flow with webhook handling [{{TICKET_PREFIX}}-789]

- Add POST /api/payments/checkout endpoint
- Add webhook handler for payment events
- Implement idempotency for payment creation
- Add unit and integration tests

EOF
)"
```

### Iterative Development Loop

Follow the standard agent loop (per Simon Willison):

1. **Clear goal** - From the spec's acceptance criteria
2. **Pattern discovery** - Already completed above
3. **Implement** - Write code following patterns
4. **Validate** - Run tests and validation commands
5. **Iterate** - If validation fails, analyze the error, adjust, and repeat
6. **Escalate** - If blocked for more than two iterations, escalate to TDM

```bash
# Validate after each significant change
# For BE:
{{TEST_UNIT_COMMAND}} --testPathPattern="feature-name" && echo "UNIT PASS" || echo "UNIT FAIL"
{{TEST_INTEGRATION_COMMAND}} --testPathPattern="feature-name" && echo "INT PASS" || echo "INT FAIL"

# For FE:
{{LINT_COMMAND}} && {{TYPE_CHECK_COMMAND}} && {{BUILD_COMMAND}} && echo "FE PASS" || echo "FE FAIL"
```

---

## Pre-PR Workflow: `/pre-pr` Validation

Before creating a pull request, run the `/pre-pr` command to validate everything:

```
/pre-pr
```

### What `/pre-pr` Checks

The `/pre-pr` validation runs through the complete quality gate:

```bash
# 1. Rebase onto latest main branch
git fetch origin
git rebase origin/{{MAIN_BRANCH}}

# 2. Run the full CI validation suite
{{CI_VALIDATE_COMMAND}}

# This typically includes:
# - {{TYPE_CHECK_COMMAND}}       # TypeScript validation
# - {{LINT_COMMAND}}             # Linting
# - {{TEST_UNIT_COMMAND}}        # Unit tests
# - {{FORMAT_CHECK_COMMAND}}     # Code formatting
```

### Manual Pre-PR Checklist

If `/pre-pr` is not available, run these steps manually:

- [ ] **Rebase is clean**: `git rebase origin/{{MAIN_BRANCH}}` completes without conflicts
- [ ] **Type checking passes**: `{{TYPE_CHECK_COMMAND}}`
- [ ] **Linting passes**: `{{LINT_COMMAND}}`
- [ ] **Unit tests pass**: `{{TEST_UNIT_COMMAND}}`
- [ ] **Integration tests pass**: `{{TEST_INTEGRATION_COMMAND}}`
- [ ] **Formatting is correct**: `{{FORMAT_CHECK_COMMAND}}`
- [ ] **Build succeeds**: `{{BUILD_COMMAND}}`
- [ ] **All acceptance criteria are addressed** (review the spec one more time)
- [ ] **Commit messages follow format**: `type(scope): description [{{TICKET_PREFIX}}-XXX]`
- [ ] **No secrets or credentials committed**: Check `.env` is in `.gitignore`

### Push and Set Exit State

After validation passes:

```bash
# Push with force-with-lease (safe after rebase)
git push --force-with-lease origin {{TICKET_PREFIX}}-XXX-your-feature

# Your exit state as an implementer is "Ready for QAS"
# Update the Linear ticket
mcp__{{MCP_LINEAR_SERVER}}__update_issue \
  --issue_id "{{TICKET_PREFIX}}-XXX" \
  --state "Testing"

mcp__{{MCP_LINEAR_SERVER}}__create_comment \
  --issue_id "{{TICKET_PREFIX}}-XXX" \
  --body "Implementation complete. All validation checks passing. Exit State: Ready for QAS.\n\nSession ID: [session-id]"
```

---

## End of Day: Wrap Up

### If Work Is Complete

- [ ] All commits pushed to remote
- [ ] Linear ticket state updated (Testing if ready for QAS, In Progress if continuing)
- [ ] Evidence comment posted on Linear ticket with session ID
- [ ] No uncommitted changes left in working directory

### If Work Is In Progress

- [ ] Current progress committed with a descriptive message
- [ ] Linear ticket has a progress comment:

```bash
mcp__{{MCP_LINEAR_SERVER}}__create_comment \
  --issue_id "{{TICKET_PREFIX}}-XXX" \
  --body "End-of-day update: API endpoint implemented, unit tests written (6/6 passing). Integration tests pending. Will resume next session. Session ID: [session-id]"
```

- [ ] Any blockers are documented and TDM is tagged if needed
- [ ] Branch is pushed to remote (even if work is incomplete)

---

## Key Skills Reference

### `safe-workflow`

Loaded automatically for commits, branches, and PRs. Provides:

- SAFe commit message formatting
- Rebase-first workflow guidance
- Branch naming conventions
- PR creation standards

### `pattern-discovery`

Loaded before writing any code. Provides:

- Codebase search strategies
- Pattern library navigation
- Session history search
- Architectural consultation triggers

### `api-patterns` (Backend)

Loaded when creating API routes. Provides:

- Route structure and organization
- RLS context integration patterns
- Error handling and response formatting
- Input validation with schema libraries
- Middleware patterns

### `frontend-patterns` (Frontend)

Loaded for UI work. Provides:

- Component structure and composition patterns
- Authentication integration ({{AUTH_PROVIDER}})
- UI component library patterns ({{UI_LIBRARY}})
- State management approaches
- Client-side data fetching patterns

---

## Exit States

As an implementer (FE or BE Developer), your exit state is **"Ready for QAS"**. This means:

- All acceptance criteria from the spec are implemented
- Tests are written and passing
- Code follows existing patterns
- Validation commands pass
- Evidence is posted to the Linear ticket

The ticket then moves to the QAS gate for independent validation.

```
Implementer (FE/BE) → "Ready for QAS" → QAS → "Approved for RTE" → RTE → "Ready for HITL Review"
```

---

## Troubleshooting

### Common Issues

**Issue**: Rebase conflicts after `git rebase origin/{{MAIN_BRANCH}}`

- **Solution**: Resolve conflicts file by file, then `git rebase --continue`
- **Prevention**: Rebase frequently (at least once per day) to minimize drift

**Issue**: Pattern discovery returns no results

- **Solution**: Broaden your search terms, check `patterns_library/` directory
- **Action**: If truly no pattern exists, propose a new one to System Architect before implementing

**Issue**: RLS context errors in tests

- **Solution**: Verify you are using the correct context helper and the test database user is `{{LINEAR_WORKSPACE}}_app_user`
- **Reference**: [RLS Implementation Guide](../database/RLS_IMPLEMENTATION_GUIDE.md)

**Issue**: CI validation fails on push

- **Solution**: Run `{{CI_VALIDATE_COMMAND}}` locally to reproduce, fix issues, and push again
- **Action**: Do not force push to bypass CI. Fix the root cause.

**Issue**: Spec is missing or incomplete

- **Solution**: Do not start implementation without a spec. Ask `@bsa` to create or update it
- **Action**: Post a comment on the Linear ticket requesting spec clarification

---

## Success Validation

```bash
# Frontend validation
{{LINT_COMMAND}} && {{TYPE_CHECK_COMMAND}} && {{BUILD_COMMAND}} && echo "FE SUCCESS" || echo "FE FAILED"

# Backend validation
{{TEST_INTEGRATION_COMMAND}} && echo "BE SUCCESS" || echo "BE FAILED"

# Full CI validation (run before PR)
{{CI_VALIDATE_COMMAND}} && echo "CI SUCCESS" || echo "CI FAILED"
```

---

## Related Documentation

- [AGENTS.md](../../AGENTS.md) - Full agent team reference
- [CONTRIBUTING.md](../../CONTRIBUTING.md) - Git workflow and commit standards
- [Agent Workflow SOP](../sop/AGENT_WORKFLOW_SOP.md) - Workflow methods and exit states
- [Pre-PR Validation Checklist](../sop/PRE_PR_VALIDATION_CHECKLIST.md) - Validation before PR creation
- [DAY-1-CHECKLIST.md](./DAY-1-CHECKLIST.md) - First day setup and validation
- [QAS Daily Workflow](./QAS-DAILY-WORKFLOW.md) - How QAS validates your work

---

**Questions?**

- GitHub Discussions: {{GITHUB_REPO_URL}}/discussions
- Email: {{AUTHOR_EMAIL}}
