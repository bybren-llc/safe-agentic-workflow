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

## Finding-Sourced Tickets (Audits, Reviews, Spec-Conformance Checks)

When a ticket originates from a finding against a spec — a build-fidelity audit, a code review against a blueprint, a spec-conformance check — the ticket body must cite the **spec source directly**, not the tool/report that surfaced the finding.

### Rule: Cite the spec, never the diffing artifact

Audit reports, review docs, and other dated/diff artifacts (e.g. `audit-report-YYYY-MM-DD.md`) are disposable — they capture a point-in-time comparison and may be archived or deleted. The Blueprint and DDD (Design Decision Document) are the durable source of truth. A ticket that cites the artifact instead of the spec breaks the moment that artifact is gone.

**MUST**: `Ref: Blueprint §<section> / DDD <number>`
**MUST NOT**: `From audit-report-YYYY-MM-DD.md — <section>`

### Rule: Don't restate spec prose — link instead

If the "Problem" or "expected behavior" is already written in the Blueprint/DDD, do not copy it into the ticket body. Restating it duplicates content that will drift out of sync with the spec and bloats every ticket. Point to the section; let the spec be read once, at the source.

### Finding-Sourced Ticket Template (MANDATORY)

```markdown
Ref: Blueprint §<section> / DDD <number>
Finding type: REGRESSION | GAP | INVENTED | INTENTIONAL DEVIATION
Fix: <1-2 lines, no restated spec prose — pointer only>
Acceptance criteria:
- [ ] ...
```

- `Finding type` classifies the deviation (matches build-fidelity-audit taxonomy: REGRESSION = built correctly then reverted, GAP = spec'd but missing, INVENTED = built but not spec'd, INTENTIONAL DEVIATION = spec'd but deliberately built differently).
- `Fix` is a pointer, not prose — if the fix requires explaining *why*, that explanation belongs in the Blueprint/DDD, not the ticket.
- Acceptance criteria stay testable per the standard [Acceptance Criteria Parsing](#acceptance-criteria-parsing) rules below.

### DECISION NEEDED tickets

When the finding is a spec-vs-code conflict with no clear resolution (the code and the spec disagree and neither is obviously right), the ticket is a **DECISION NEEDED** ticket. These require an *even more explicit* source-of-truth anchor than a normal finding ticket, since the whole point of the ticket is to resolve which side wins:

```markdown
Ref: Blueprint §<section> / DDD <number> — READ BEFORE DECIDING
Finding type: DECISION NEEDED
Conflict: <1-2 lines — what the spec says vs. what the code does>
Fix: Pending decision — see Ref above for full context
Acceptance criteria:
- [ ] Decision made and documented in DDD (update DDD, don't just resolve in the ticket)
- [ ] Code updated to match decision (or spec updated, if code wins)
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
