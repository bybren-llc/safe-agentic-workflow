---
name: linear-sop
description: Linear ticket management with Beads integration for agent dynamic task tracking. Use when creating issues, updating status, attaching evidence, or managing agent-discovered work. Provides evidence templates for dev/staging/done phases and Beads workflow for session task management.
---

# Linear SOP Skill (ConTStack)

## Purpose

Guide consistent Linear ticket management with integrated Beads support for agent-driven task discovery and session tracking. Provides evidence templates for the mandatory dev/staging/UAT evidence policy and workflows for dual-system task management.

## When This Skill Applies

Invoke this skill when:

- Creating new Linear issues (human-planned work)
- Updating ticket status in Linear
- Attaching evidence to tickets
- Parsing acceptance criteria
- Working with UUIDs and issue IDs
- **Agent Session Work**: Using Beads for dynamic task management
- **Syncing**: Bridging Linear issues to Beads for agent tracking

---

## Linear vs Beads: When to Use Each

| System | Use Case | Examples |
|--------|----------|----------|
| **Linear** | Human-created tickets, sprint planning, backlog management | ConTS-459: "Add user dashboard", Sprint 3 backlog |
| **Beads** | Agent-discovered work, dynamic task breakdown, session tracking | "Fix auth guard in ProfilePage", "Refactor duplicate code found during review" |

### Decision Tree

```
Is this work human-planned (sprint/backlog)?
├── YES → Create in Linear with ConTS- prefix
│         Then: bd sync to pull into Beads for agent tracking
└── NO → Is this discovered during agent session?
         ├── YES → Create directly in Beads
         │         If significant, escalate to Linear later
         └── NO → Discuss with team first
```

---

## Linear MCP Tools

### Reading Issues

```text
# Get issue by identifier
mcp__linear-mcp__get_issue({ id: "ConTS-459" })

# List issues with filters
mcp__linear-mcp__list_issues({
  team: "ConTStack",
  state: "In Progress",
  assignee: "me",
})
```

### Creating Issues

```text
mcp__linear-mcp__create_issue({
  title: "feat(scope): description",
  team: "ConTStack",
  description: "## Summary\n\n...",
  labels: ["feature", "sprint-1"],
  parentId: "parent-uuid",  // Optional - for sub-issues
})
```

### Updating Issues

```text
mcp__linear-mcp__update_issue({
  id: "ConTS-459",
  state: "Done",
})
```

### Adding Comments

```text
mcp__linear-mcp__create_comment({
  issueId: "ConTS-459",
  body: "**Dev Evidence**\n\n...",
})
```

---

## Beads CLI Commands

Beads is the agent-native task tracking system for dynamic work management during sessions.

### Core Commands

```bash
# Sync Linear issues to Beads (run at session start)
bd sync

# See unblocked work ready to start
bd ready --json

# Create a new Beads issue (agent-discovered work)
bd create "Description of task" -t [bug|task|feature|epic] -p [0-4] -l [labels]

# Update issue status
bd update [issue-id] --status in_progress

# Close completed work
bd close [issue-id] --reason "Completion summary"

# Link issues (parent-child or dependencies)
bd dep add [child-id] [parent-id] --type discovered-from
```

### Session Workflow

```bash
# 1. Session Start Protocol
bd sync                              # Get latest from Linear
bd ready --json                      # See available work
# Check thoughts/shared/handoffs/    # Review previous context

# 2. During Session - Track discoveries
bd create "Fix missing auth guard" -t bug -p 2 -l "security,discovered"
bd dep add NEW-ID PARENT-ID --type discovered-from

# 3. Update as you work
bd update ISSUE-ID --status in_progress

# 4. Session End Protocol
bd close ISSUE-ID --reason "Fixed auth guard, added tests"
# Create handoff document
```

---

## Syncing Linear to Beads

### Import Linear Issues for Agent Work

When starting work on a Linear issue, sync it to Beads for granular tracking:

```bash
# Pull all active Linear issues to Beads
bd sync

# Or manually create Beads tracking for specific Linear issue
bd create "ConTS-459: Add user dashboard" -t task -p 2 -l "linear,ConTS-459"
```

### Escalate Beads Discoveries to Linear

When agent discovers significant work that should be formally tracked:

```bash
# 1. Create Linear issue
mcp__linear-mcp__create_issue({
  title: "fix(auth): Missing guard on ProfilePage (discovered during ConTS-459)",
  team: "ConTStack",
  description: "## Discovery Context\n\nFound during work on ConTS-459...",
  labels: ["bug", "discovered", "security"],
})

# 2. Link Beads issue to new Linear issue
bd update BEADS-ID --linear-ref ConTS-460
```

---

## Evidence Policy (MUST)

Every issue requires evidence at each phase:

| Phase       | Required? | Content                 | Systems |
|-------------|-----------|-------------------------|---------|
| **Dev**     | MUST      | Implementation proof    | Linear + Beads |
| **Staging** | MUST      | UAT validation (or N/A) | Linear |
| **Done**    | MUST      | Final verification      | Linear + Beads close |

---

## Evidence Templates

### Dev Evidence Template (Linear Comment)

```markdown
**Dev Evidence**

**PR**: https://github.com/contstack/convex-v1/pull/XXX
**Commit**: [short-hash]
**Branch**: ConTS-XXX-description

**Implementation:**

- [x] Feature implemented
- [x] Tests passing
- [x] Lint passing

**Verification:**

\`\`\`bash
bun test && bun lint && bun typecheck

# Output: All checks passed
\`\`\`

**Beads Tracking:** [BEADS-ID] - Session work captured
```

### Staging/UAT Evidence Template

```markdown
**Staging Evidence**

**Environment**: Development server
**URL**: http://localhost:3001

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

**PR Merged**: https://github.com/contstack/convex-v1/pull/XXX
**Merge Commit**: [hash]

**Final Checklist:**

- [x] All acceptance criteria met
- [x] Documentation updated (if applicable)
- [x] No regressions detected
- [x] Beads issues closed with summaries
```

### Beads Issue Close Template

```bash
bd close BEADS-ID --reason "$(cat <<'EOF'
## Summary
- Implemented [feature/fix description]
- Added tests in [test-file.spec.ts]
- PR: #XXX

## Verification
- bun test: PASSED
- bun lint: PASSED
- Manual verification: PASSED

## Linked Linear: ConTS-XXX
EOF
)"
```

---

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

### Create Beads Sub-Tasks from ACs

```bash
# Break down Linear AC into trackable Beads tasks
bd create "AC1: User can perform action X" -t task -l "ConTS-459,ac"
bd create "AC2: System responds with Y" -t task -l "ConTS-459,ac"
bd create "AC3: Error handling for Z" -t task -l "ConTS-459,ac"
```

---

## Status Workflow

### Linear Status Flow

```text
Backlog -> Ready -> In Progress -> Testing -> Ready for Review -> Done
```

### Beads Status Flow

```text
pending -> in_progress -> completed
```

### Mapping Linear to Beads Status

| Linear Status    | Beads Status   | Trigger |
|------------------|----------------|---------|
| Backlog          | (not synced)   | Not agent work yet |
| Ready            | pending        | bd sync pulls it |
| In Progress      | in_progress    | Agent starts work |
| Testing          | in_progress    | Still being verified |
| Ready for Review | in_progress    | Awaiting approval |
| Done             | completed      | All work finished |

### Status Update Guidelines

| From             | To               | When                     | Beads Action |
|------------------|------------------|--------------------------|--------------|
| Backlog          | Ready            | Sprint planning          | bd sync |
| Ready            | In Progress      | Work starts              | bd update --status in_progress |
| In Progress      | Testing          | PR created               | (continue in_progress) |
| Testing          | Ready for Review | Tests pass, UAT complete | (continue in_progress) |
| Ready for Review | Done             | POPM approval            | bd close |

---

## UUID Handling

Linear uses UUIDs internally. When working with APIs:

```typescript
// Issue identifiers (human-readable)
const issueId = "ConTS-459";

// UUIDs (API operations)
const uuid = "ef6a5fa0-2b46-417f-8266-dea2d187b10a";

// Get UUID from identifier via MCP tool
// mcp__linear-mcp__get_issue({ id: "ConTS-459" })
// Returns issue object with .id property containing UUID
```

---

## Common Operations

### Link PR to Issue

PRs are automatically linked when:

- Branch name contains `ConTS-XXX`
- PR title contains `[ConTS-XXX]`

### Create Sub-Issue (Linear)

```text
mcp__linear-mcp__create_issue({
  title: "Sub-task description",
  team: "ConTStack",
  parentId: "parent-issue-uuid",
})
```

### Create Sub-Task (Beads)

```bash
bd create "Sub-task description" -t task -l "parent:BEADS-PARENT-ID"
bd dep add NEW-ID PARENT-ID --type subtask
```

### Query by Label

```text
# Linear
mcp__linear-mcp__list_issues({
  label: "sprint-1",
  team: "ConTStack",
})

# Beads
bd list --label sprint-1
```

---

## Agent Session Patterns

### Pattern 1: Linear-First (Planned Work)

```bash
# 1. Start with Linear issue
mcp__linear-mcp__update_issue({ id: "ConTS-459", state: "In Progress" })

# 2. Sync to Beads for granular tracking
bd sync
bd update BEADS-ID --status in_progress

# 3. Work and track discoveries in Beads
bd create "Discovered: needs refactor" -t task -l "ConTS-459,discovered"

# 4. Complete in both systems
bd close BEADS-ID --reason "Completed with X changes"
mcp__linear-mcp__update_issue({ id: "ConTS-459", state: "Done" })
mcp__linear-mcp__create_comment({ issueId: "ConTS-459", body: "**Dev Evidence**..." })
```

### Pattern 2: Beads-First (Discovered Work)

```bash
# 1. Discover work during session
bd create "Auth guard missing on /settings" -t bug -p 2 -l "security,discovered"

# 2. Track and complete in Beads
bd update BEADS-ID --status in_progress
# ... do the work ...
bd close BEADS-ID --reason "Added withAuthGuard to settings page"

# 3. If significant, escalate to Linear
mcp__linear-mcp__create_issue({
  title: "fix(auth): Add auth guard to settings (post-fix documentation)",
  team: "ConTStack",
  description: "## Resolved\n\nFixed during agent session. See Beads BEADS-ID.",
  state: "Done",
})
```

### Pattern 3: Mixed (Large Feature)

```bash
# 1. Linear epic for feature
mcp__linear-mcp__create_issue({
  title: "epic: User Dashboard",
  team: "ConTStack",
  labels: ["epic"],
})

# 2. Beads for implementation phases
bd create "Phase 1: Dashboard layout" -t task -l "ConTS-460,phase"
bd create "Phase 2: Data fetching" -t task -l "ConTS-460,phase"
bd create "Phase 3: Real-time updates" -t task -l "ConTS-460,phase"

# 3. Track each phase in Beads, roll up to Linear
```

---

## Authoritative References

- **RPI Workflow**: See CLAUDE.md "RPI Workflow Integration" section
- **Beads Documentation**: Built into Claude Code
- **Agent Workflow SOP**: `docs/sop/AGENT_WORKFLOW_SOP.md`
- **Linear MCP Docs**: Built into Claude Code
- **Handoff Patterns**: `thoughts/shared/handoffs/`
