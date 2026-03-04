# QAS Daily Workflow Guide

**Role**: Quality Assurance Specialist (QAS)
**Purpose**: Day-to-day workflow for executing testing strategy, validating acceptance criteria, and gathering evidence within the SAFe multi-agent harness.

**Prerequisites**:

- Claude Code or Augment Code installed and configured
- Access to Linear workspace with `mcp__{{MCP_LINEAR_SERVER}}__*` tools available
- Repository cloned with agent system verified (see [AGENT-SETUP-GUIDE.md](./AGENT-SETUP-GUIDE.md))
- Familiarity with the 11-agent team structure (see [AGENTS.md](../../AGENTS.md))

**Key Skills**: `testing-patterns`, `security-audit`, `linear-sop`

---

## Morning Routine: Check the Testing Swimlane

Start every day by reviewing what is waiting for you. QAS is a **gate owner** in the vNext workflow contract. Nothing moves to RTE without your approval.

### Step 1: Review Linear Tickets in Testing

```bash
# Use Linear MCP tools to find tickets assigned to QAS in the Testing swimlane
mcp__{{MCP_LINEAR_SERVER}}__search_issues "assignee:me state:Testing"

# Alternatively, review tickets moved to Testing since last session
mcp__{{MCP_LINEAR_SERVER}}__search_issues "state:Testing updated:>yesterday"
```

### Step 2: Prioritize Your Queue

Order tickets by:

1. **Blocking other agents** - If an implementer is waiting on QAS approval, that ticket comes first
2. **Sprint commitment** - Tickets in the current iteration take priority
3. **Dependency chains** - Tickets that unblock downstream work (e.g., a feature blocking RTE PR creation)

### Step 3: Read the Spec

For each ticket in your queue:

```bash
# Read the implementation spec
cat specs/{{TICKET_PREFIX}}-XXX-{feature}-spec.md

# Extract acceptance criteria
grep -A 20 "Acceptance Criteria" specs/{{TICKET_PREFIX}}-XXX-{feature}-spec.md

# Check for security-critical requirements
grep "#EXPORT_CRITICAL" specs/{{TICKET_PREFIX}}-XXX-{feature}-spec.md
```

---

## Test Execution Workflow

### Starting Work on a Ticket

Use the `/start-work` command to initialize your session context:

```
/start-work {{TICKET_PREFIX}}-XXX
```

This command:

- Loads the ticket context from Linear
- Reads the associated spec file
- Sets up session tracking for evidence gathering
- Identifies the testing strategy defined by the BSA

### Pattern Discovery Before Testing

**"Search First, Reuse Always, Create Only When Necessary"** applies to tests too.

```bash
# Search for existing test patterns
ls patterns_library/testing/
cat patterns_library/testing/integration-test-pattern.md

# Find similar tests in the codebase
grep -r "describe.*similar_feature" {{TESTS_DIR}}/
grep -r "test.*similar_functionality" {{TESTS_DIR}}/

# Check if test utilities already exist
ls {{TESTS_DIR}}/helpers/ 2>/dev/null
ls {{TESTS_DIR}}/fixtures/ 2>/dev/null
```

### Checking Workflow Status

Use `/check-workflow` to see where things stand:

```
/check-workflow {{TICKET_PREFIX}}-XXX
```

This shows:

- Current ticket state in Linear
- Which agents have completed their work
- Whether implementation is ready for testing
- Any blockers or dependencies

### Execute the Testing Strategy

The BSA defines the testing strategy in the spec. QAS executes it. Follow the three tiers:

**Tier 1: Unit Tests**

```bash
# Run unit tests for the feature
{{TEST_UNIT_COMMAND}} --testPathPattern="feature-name"

# Verify coverage meets thresholds
{{TEST_UNIT_COMMAND}} --coverage --testPathPattern="feature-name"
```

**Tier 2: Integration Tests**

```bash
# Run integration tests
{{TEST_INTEGRATION_COMMAND}} --testPathPattern="feature-name"

# Test RLS isolation if database operations are involved
# Verify user A cannot access user B's data
{{TEST_INTEGRATION_COMMAND}} --testPathPattern="rls.*feature-name"
```

**Tier 3: End-to-End Tests**

```bash
# Run E2E tests for the feature
{{TEST_E2E_COMMAND}} --grep "feature-name"

# Run the demo script from the spec (if provided)
# Demo scripts are the BSA's definition of "done"
```

### Validate Acceptance Criteria

For each acceptance criterion in the spec, verify it is met:

```markdown
## AC Validation Checklist

- [ ] AC-1: [Description] - PASS/FAIL - [Evidence reference]
- [ ] AC-2: [Description] - PASS/FAIL - [Evidence reference]
- [ ] AC-3: [Description] - PASS/FAIL - [Evidence reference]
```

If any AC fails:

1. Document the failure with specific details
2. Note which test(s) demonstrate the failure
3. Move the ticket back to **In Progress** with a comment explaining what needs to change
4. Tag the implementer in the Linear comment

---

## Evidence Gathering

Evidence is required for every ticket before it can move to "Ready for Review." This is non-negotiable in the SAFe workflow.

### What to Capture

| Evidence Type          | When Required                 | Format                          |
| ---------------------- | ----------------------------- | ------------------------------- |
| **Test results**       | Always                        | CLI output or test report       |
| **Coverage report**    | When tests are written        | Coverage summary with %         |
| **Screenshots**        | UI changes                    | PNG/JPG of before/after         |
| **Validation output**  | Always                        | Output of validation commands   |
| **RLS audit results**  | Database operations            | RLS test script output          |
| **Performance data**   | When `#EXPORT_CRITICAL` perf  | Benchmark results               |
| **Session ID**         | Always                        | Claude Code session identifier  |

### Format for Evidence

Structure your evidence as a Linear comment:

```markdown
## QAS Validation Report - {{TICKET_PREFIX}}-XXX

**Session ID**: [Claude Code session ID]
**Date**: [YYYY-MM-DD]
**Spec**: specs/{{TICKET_PREFIX}}-XXX-{feature}-spec.md

### Acceptance Criteria Validation

| AC   | Description                | Status | Evidence        |
| ---- | -------------------------- | ------ | --------------- |
| AC-1 | [Description]              | PASS   | Unit test suite |
| AC-2 | [Description]              | PASS   | Integration test |
| AC-3 | [Description]              | PASS   | E2E test         |

### Test Results

**Unit Tests**: X passing, 0 failing
**Integration Tests**: X passing, 0 failing
**E2E Tests**: X passing, 0 failing
**Coverage**: XX% (threshold: {{COVERAGE_THRESHOLD}}%)

### Validation Command Output

\`\`\`
[Paste output of validation commands here]
\`\`\`

### Decision

**QAS Gate**: APPROVED / REJECTED
**Exit State**: "Approved for RTE" / "Returned to Implementer"
```

### Where to Attach Evidence

Use Linear MCP tools to post evidence directly to the ticket:

```bash
# Add QAS validation report as a comment on the Linear ticket
mcp__{{MCP_LINEAR_SERVER}}__create_comment \
  --issue_id "{{TICKET_PREFIX}}-XXX" \
  --body "## QAS Validation Report\n\n[Full evidence report here]"

# Update ticket state based on result
# If APPROVED:
mcp__{{MCP_LINEAR_SERVER}}__update_issue \
  --issue_id "{{TICKET_PREFIX}}-XXX" \
  --state "Ready for Review"

# If REJECTED:
mcp__{{MCP_LINEAR_SERVER}}__update_issue \
  --issue_id "{{TICKET_PREFIX}}-XXX" \
  --state "In Progress"
```

---

## Interaction with Linear MCP Tools

QAS uses `mcp__{{MCP_LINEAR_SERVER}}__*` tools throughout the workflow. Here are the key interactions:

### Reading Ticket Context

```bash
# Get full ticket details
mcp__{{MCP_LINEAR_SERVER}}__get_issue "{{TICKET_PREFIX}}-XXX"

# Read comments from implementers
mcp__{{MCP_LINEAR_SERVER}}__get_issue_comments "{{TICKET_PREFIX}}-XXX"

# Check ticket history for context
mcp__{{MCP_LINEAR_SERVER}}__get_issue_history "{{TICKET_PREFIX}}-XXX"
```

### Posting Updates

```bash
# Post progress update
mcp__{{MCP_LINEAR_SERVER}}__create_comment \
  --issue_id "{{TICKET_PREFIX}}-XXX" \
  --body "QAS testing in progress. Unit tests complete (12/12 passing). Starting integration tests."

# Post final approval
mcp__{{MCP_LINEAR_SERVER}}__create_comment \
  --issue_id "{{TICKET_PREFIX}}-XXX" \
  --body "## QAS Gate: APPROVED\n\nAll ACs validated. Exit State: Approved for RTE.\n\nSession ID: [session-id]"
```

### Moving Tickets Through Swimlanes

```bash
# Testing complete, approved → move to Ready for Review
mcp__{{MCP_LINEAR_SERVER}}__update_issue \
  --issue_id "{{TICKET_PREFIX}}-XXX" \
  --state "Ready for Review"

# Testing failed → return to In Progress with explanation
mcp__{{MCP_LINEAR_SERVER}}__update_issue \
  --issue_id "{{TICKET_PREFIX}}-XXX" \
  --state "In Progress"
```

---

## End-of-Day: `/end-work` Checklist

Before ending your session, run through this checklist:

```
/end-work
```

### Mandatory End-of-Day Items

- [ ] **All tested tickets have evidence posted** - Every ticket you tested today has a QAS Validation Report comment in Linear
- [ ] **Ticket states are accurate** - Tickets are in the correct swimlane (Ready for Review, In Progress, or Testing)
- [ ] **Blocked tickets are flagged** - If you found blockers, they are documented in Linear with `@tdm` tagged for resolution
- [ ] **Session IDs are recorded** - Your Claude Code session IDs are attached to relevant Linear tickets
- [ ] **No orphaned work** - If you started testing something but did not finish, the ticket is still in Testing with a progress comment
- [ ] **Security findings reported** - Any `#EXPORT_CRITICAL` findings are documented and escalated to Security Engineer

### End-of-Day Linear Update

Post a summary comment on any ticket still in progress:

```bash
mcp__{{MCP_LINEAR_SERVER}}__create_comment \
  --issue_id "{{TICKET_PREFIX}}-XXX" \
  --body "QAS end-of-day update: Integration tests complete (8/8 passing). E2E tests pending - will resume next session. Session ID: [session-id]"
```

---

## Key Skills Reference

### `testing-patterns`

Loaded automatically when writing tests. Provides:

- Jest configuration patterns for unit and integration tests
- Playwright patterns for E2E tests
- Test data fixture patterns
- RLS isolation test patterns
- Mock and stub patterns for external services

### `security-audit`

Loaded when `#EXPORT_CRITICAL` tags are present in specs. Provides:

- RLS policy validation procedures
- Authentication bypass testing
- Input validation test patterns
- Cross-user data isolation verification

### `linear-sop`

Loaded when interacting with Linear. Provides:

- Correct swimlane transitions
- Evidence format requirements
- Comment formatting standards
- Ticket state management rules

---

## QAS Gate Authority

QAS is a **non-collapsible role** in the vNext workflow contract. This means:

- QAS validation cannot be skipped or performed by the implementer
- The QAS gate is a **blocking gate** - no ticket moves forward without QAS approval
- If QAS rejects, the ticket returns to the implementer with specific feedback
- QAS exit state is "Approved for RTE" - only QAS can set this

### When to Exercise Stop-the-Line Authority

QAS should halt progress when:

- Acceptance criteria are untestable or ambiguous (escalate to BSA)
- Implementation does not match the spec (return to implementer)
- Security-critical requirements are not met (escalate to Security Engineer)
- Test infrastructure is broken or unreliable (escalate to TDM)
- RLS policies are not properly enforced (block until Data Engineer resolves)

---

## Troubleshooting

### Common Issues

**Issue**: Tests pass locally but fail in CI

- **Solution**: Check environment variable differences between local and CI
- **Action**: Run `{{CI_VALIDATE_COMMAND}}` locally to reproduce

**Issue**: Cannot find the spec for a ticket

- **Solution**: Ask BSA to create the spec or check `specs/` directory naming
- **Action**: `ls specs/ | grep "{{TICKET_PREFIX}}-XXX"` or ask `@bsa`

**Issue**: Acceptance criteria are ambiguous

- **Solution**: Do not guess. Escalate to BSA for clarification before testing
- **Action**: Post a Linear comment tagging BSA with your specific question

**Issue**: RLS tests fail unexpectedly

- **Solution**: Verify test database user is `{{LINEAR_WORKSPACE}}_app_user`, not the superuser
- **Action**: See [RLS Implementation Guide](../database/RLS_IMPLEMENTATION_GUIDE.md)

---

## Success Validation

```bash
# QAS session validation
{{TEST_UNIT_COMMAND}} && {{TEST_INTEGRATION_COMMAND}} && echo "QAS SUCCESS" || echo "QAS FAILED"
```

---

## Related Documentation

- [AGENTS.md](../../AGENTS.md) - Full agent team reference
- [CONTRIBUTING.md](../../CONTRIBUTING.md) - Git workflow and commit standards
- [Agent Workflow SOP](../sop/AGENT_WORKFLOW_SOP.md) - Workflow methods and exit states
- [Pre-PR Validation Checklist](../sop/PRE_PR_VALIDATION_CHECKLIST.md) - Validation before PR creation
- [DAY-1-CHECKLIST.md](./DAY-1-CHECKLIST.md) - First day setup and validation

---

**Questions?**

- GitHub Discussions: {{GITHUB_REPO_URL}}/discussions
- Email: {{AUTHOR_EMAIL}}
