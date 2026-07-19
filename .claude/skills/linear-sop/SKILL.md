---
name: linear-sop
description: Linear ticket management best practices. Use when creating issues, updating status, or attaching evidence. Provides evidence templates for dev/staging/done phases.
allowed-tools: Read, Grep
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
mcp__{{MCP_LINEAR_SERVER}}__get_issue({ id: "{{TICKET_PREFIX}}-459" })

# List issues with filters
mcp__{{MCP_LINEAR_SERVER}}__list_issues({
  team: "{{PROJECT_TEAM_NAME}}",
  state: "In Progress",
  assignee: "me",
})
```

### Creating Issues

```text
mcp__{{MCP_LINEAR_SERVER}}__create_issue({
  title: "feat(scope): description",
  team: "{{PROJECT_TEAM_NAME}}",
  description: "## Summary\n\n...",
  labels: ["feature", "sprint-1"],
  parentId: "parent-uuid",  // Optional - for sub-issues
})
```

### Updating Issues

```text
mcp__{{MCP_LINEAR_SERVER}}__update_issue({
  id: "{{TICKET_PREFIX}}-459",
  state: "Done",
})
```

### Adding Comments

```text
mcp__{{MCP_LINEAR_SERVER}}__create_comment({
  issueId: "{{TICKET_PREFIX}}-459",
  body: "**Dev Evidence**\n\n...",
})
```

## Program Structure

For work that spans many issues, Linear has objects **above** the issue. Use them; do not flatten a
program into a flat list of tickets.

### The Hierarchy

```text
Initiative          the program (one per program)
  └── Project       a Unit of Work — one coherent outcome
       ├── Milestone    an AI-DLC phase: Inception, Construction, Operations
       └── Issue        a Story
            └── Sub-issue   a Mob Elaboration task (created during Inception, not before)
```

### Prerequisite: labels must already exist

Program build-out assumes these label namespaces are **pre-created in the workspace**. Create them
before building the program, not during:

- `bolt:0` … `bolt:N` — which Bolt an issue belongs to
- `agent:*` — the lead role (must match an actual agent name in `.claude/agents/`)

Labels are workspace-scoped in Linear — do not create team-scoped duplicates.

### Streams

Linear **sub-initiatives require an Enterprise plan**. If your workspace has it, model program
streams as sub-initiatives under the initiative. If it does not, encode the stream as **project
priority** instead — highest-risk stream gets Urgent/High, follow-up stream gets Medium. Both are
valid; pick based on your plan tier.

### Dependency Wiring

Build the dependency DAG with issue relations:

```text
mcp__{{MCP_LINEAR_SERVER}}__update_issue({
  id: "{{TICKET_PREFIX}}-XXX",
  blocks: ["{{TICKET_PREFIX}}-YYY"],       // this issue must land first
  blockedBy: ["{{TICKET_PREFIX}}-ZZZ"],    // this issue waits on that one
})
```

Use `relatedTo` for soft links that inform but do not block.

**Wire so the enforcement lands before the thing it enforces** — see the `safe-ai-dlc` skill for the
four dependency-wiring heuristics.

### Re-parenting existing issues

When a program absorbs tickets that already exist, **update them into the project — never recreate
them**. Duplicates break traceability and split the evidence trail.

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

### GitHub-Linear Auto-Sync

Tickets referenced in commit messages (e.g., `[{{TICKET_PREFIX}}-123]`) automatically move to **Done** when the PR merges. Child stories not referenced in any commit message must be manually closed after merge.

**Best practice**: Reference Feature-level tickets in commit messages. After merge, manually close orphaned child stories that weren't referenced.

### Status Update Guidelines

| From             | To               | When                     |
| ---------------- | ---------------- | ------------------------ |
| Backlog          | Ready            | Sprint planning          |
| Ready            | In Progress      | Work starts              |
| In Progress      | Testing          | PR created               |
| Testing          | Ready for Review | Tests pass, UAT complete |
| Ready for Review | Done             | POPM approval or auto-sync via PR merge |

## UUID Handling

Linear uses UUIDs internally. When working with APIs:

```typescript
// Issue identifiers (human-readable)
const issueId = "{{TICKET_PREFIX}}-459";

// UUIDs (API operations)
const uuid = "ef6a5fa0-2b46-417f-8266-dea2d187b10a";

// Get UUID from identifier via MCP tool
// mcp__{{MCP_LINEAR_SERVER}}__get_issue({ id: "{{TICKET_PREFIX}}-459" })
// Returns issue object with .id property containing UUID
```

## Common Operations

### Link PR to Issue

PRs are automatically linked when:

- Branch name contains `{{TICKET_PREFIX}}-XXX`
- PR title contains `[{{TICKET_PREFIX}}-XXX]`

### Create Sub-Issue

```text
mcp__{{MCP_LINEAR_SERVER}}__create_issue({
  title: "Sub-task description",
  team: "{{PROJECT_TEAM_NAME}}",
  parentId: "parent-issue-uuid",
})
```

### Query by Label

```text
mcp__{{MCP_LINEAR_SERVER}}__list_issues({
  label: "sprint-1",
  team: "{{PROJECT_TEAM_NAME}}",
})
```

## Authoritative References

- **Agent Workflow SOP**: `docs/sop/AGENT_WORKFLOW_SOP.md`
- **Linear MCP Docs**: Built into Claude Code
- **CONTRIBUTING.md**: Workflow documentation
