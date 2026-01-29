---
name: linear-sop
description: Linear ticket management best practices. Use when creating issues, updating status, or attaching evidence. Provides evidence templates for dev/staging/done phases.
---

# Linear SOP Skill

## Purpose

Guide consistent Linear ticket management. Provides evidence templates for the mandatory dev/staging/UAT evidence policy.

## When This Skill Applies

Invoke this skill when:

- Creating new Linear issues
- Updating ticket status
- Attaching evidence to tickets
- Parsing acceptance criteria
- Working with UUIDs and issue IDs

## Linear MCP Tools

### Reading Issues

```text
# Get issue by identifier
mcp__linear-mcp__get_issue({ id: "{{TICKET_PREFIX}}-459" })

# List issues with filters
mcp__linear-mcp__list_issues({
  team: "{{PROJECT_TEAM_NAME}}",
  state: "In Progress",
  assignee: "me",
})
```

### Creating Issues

```text
mcp__linear-mcp__create_issue({
  title: "feat(scope): description",
  team: "{{PROJECT_TEAM_NAME}}",
  description: "## Summary\n\n...",
  labels: ["feature", "sprint-1"],
  parentId: "parent-uuid",  // Optional - for sub-issues
})
```

### Updating Issues

```text
mcp__linear-mcp__update_issue({
  id: "{{TICKET_PREFIX}}-459",
  state: "Done",
})
```

### Adding Comments

```text
mcp__linear-mcp__create_comment({
  issueId: "{{TICKET_PREFIX}}-459",
  body: "**Dev Evidence**\n\n...",
})
```

## Evidence Policy (MUST)

Every issue requires evidence at each phase:

| Phase       | Required? | Content                 |
| ----------- | --------- | ----------------------- |
| **Dev**     | MUST      | Implementation proof    |
| **Staging** | MUST      | UAT validation (or N/A) |
| **Done**    | MUST      | Final verification      |

## Evidence Templates

### Dev Evidence Template

```markdown
**Dev Evidence**

**PR**: https://github.com/{{ORG_NAME}}/{{REPO_NAME}}/pull/XXX
**Commit**: [short-hash]
**Branch**: {{TICKET_PREFIX}}-XXX-description

**Implementation:**

- [x] Feature implemented
- [x] Tests passing
- [x] Lint passing

**Verification:**

\`\`\`bash
yarn ci:validate

# Output: All checks passed

\`\`\`
```

### Staging/UAT Evidence Template

```markdown
**Staging Evidence**

**Environment**: Pop OS dev server
**URL**: http://pop-os:3000

**Validation Steps:**

1. Deployed to staging: [timestamp]
2. Smoke test passed: [yes/no]
3. Feature verified: [description]

**UAT Status:** [Passed/Pending/N/A]

If N/A, reason: [e.g., "Dev tooling only - no user-facing changes"]
```

### Done Evidence Template

```markdown
**Done Evidence**

**PR Merged**: https://github.com/{{ORG_NAME}}/{{REPO_NAME}}/pull/XXX
**Merge Commit**: [hash]

**Final Checklist:**

- [x] All acceptance criteria met
- [x] Documentation updated (if applicable)
- [x] No regressions detected
```

## Acceptance Criteria Parsing

When reading issue descriptions, extract ACs:

```markdown
## Acceptance Criteria

- [ ] User can perform action X
- [ ] System responds with Y
- [ ] Error handling for Z
```

Convert to testable checklist:

```typescript
const acceptanceCriteria = [
  { criterion: "User can perform action X", verified: false },
  { criterion: "System responds with Y", verified: false },
  { criterion: "Error handling for Z", verified: false },
];
```

## Status Workflow

```text
Backlog -> Ready -> In Progress -> Testing -> Ready for Review -> Done
```

### Status Update Guidelines

| From             | To               | When                     |
| ---------------- | ---------------- | ------------------------ |
| Backlog          | Ready            | Sprint planning          |
| Ready            | In Progress      | Work starts              |
| In Progress      | Testing          | PR created               |
| Testing          | Ready for Review | Tests pass, UAT complete |
| Ready for Review | Done             | POPM approval            |

## UUID Handling

Linear uses UUIDs internally. When working with APIs:

```typescript
// Issue identifiers (human-readable)
const issueId = "{{TICKET_PREFIX}}-459";

// UUIDs (API operations)
const uuid = "ef6a5fa0-2b46-417f-8266-dea2d187b10a";

// Get UUID from identifier via MCP tool
// mcp__linear-mcp__get_issue({ id: "{{TICKET_PREFIX}}-459" })
// Returns issue object with .id property containing UUID
```

## Common Operations

### Link PR to Issue

PRs are automatically linked when:

- Branch name contains `{{TICKET_PREFIX}}-XXX`
- PR title contains `[{{TICKET_PREFIX}}-XXX]`

### Create Sub-Issue

```text
mcp__linear-mcp__create_issue({
  title: "Sub-task description",
  team: "{{PROJECT_TEAM_NAME}}",
  parentId: "parent-issue-uuid",
})
```

### Query by Label

```text
mcp__linear-mcp__list_issues({
  label: "sprint-1",
  team: "{{PROJECT_TEAM_NAME}}",
})
```

## Authoritative References

- **Agent Workflow SOP**: `docs/sop/AGENT_WORKFLOW_SOP.md`
- **Linear MCP Docs**: Built into Claude Code
- **CONTRIBUTING.md**: Workflow documentation
