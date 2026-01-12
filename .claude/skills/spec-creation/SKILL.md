---
name: spec-creation
description: Unified RSI (Research-Spec-Implement) workflow for creating implementation specifications. Combines ConTStack research depth with WTFB spec rigor. Use when starting new features, planning implementations, or creating technical specifications with traceable acceptance criteria.
---

# Spec Creation Skill (RSI Workflow)

## Purpose

Guide the creation of implementation specifications using a unified RSI (Research-Spec-Implement) workflow that combines:

- **ConTStack**: Deep research, sub-agent architecture, Beads tracking, session continuity
- **WTFB**: User stories, testable acceptance criteria, demo scripts, pattern references

## When This Skill Applies

Invoke this skill when:

- Starting a new feature or enhancement
- Converting user requirements to implementation specs
- Creating technical specifications with acceptance criteria
- Need a structured approach to feature planning
- Want traceable specs with validation commands

---

## RSI Workflow Overview

```
Research (Objective) -> Spec (Detailed) -> Implement (Phased)
```

| Phase | Primary Focus | Output | Issue Tracking |
|-------|---------------|--------|----------------|
| **Research** | Understand what exists | Research document | Beads spike issue |
| **Spec** | Define what to build | Spec document | Linear PRD + Beads epic |
| **Implement** | Execute phase by phase | Working code | Beads phase issues |

---

## Phase 1: Research Protocol

### Critical Rules

1. **DO NOT** critique the implementation or identify problems
2. **DO NOT** recommend refactoring or architectural changes
3. **ONLY** describe what exists, where it exists, how it works
4. You are creating a technical map of the existing system

### Step 1.1: Check for Existing Research

```bash
# Check Beads for related work
bd list --label spike,research --json
bd ready --json

# Check existing research docs
ls thoughts/shared/research/
```

### Step 1.2: Create Research Issue in Beads

```bash
bd create "ConTS-Spike: [Topic Name]" -t spike -p 2 -l spike,research,rsi --json
```

Save the returned issue ID as `$RESEARCH_ID`.

### Step 1.3: Spawn Parallel Research Agents

Use the Task tool to spawn these agents concurrently:

| Agent | Purpose | Focus |
|-------|---------|-------|
| **codebase-locator** | Find all relevant files | File paths, imports, exports |
| **codebase-analyzer** | Understand patterns | Conventions, existing implementations |
| **beads-context** | Historical context | Previous decisions, closed issues |

### Step 1.4: Create Research Document

Create file: `thoughts/shared/research/YYYY-MM-DD-{topic-slug}.md`

```markdown
---
date: [ISO timestamp]
researcher: Claude
beads_issue: $RESEARCH_ID
git_commit: [current commit hash]
branch: [current branch]
topic: "[Topic Name]"
tags: [spike, research, component-names]
status: complete
---

# Spike: [Topic Name]

**ConTS Issue:** $RESEARCH_ID
**Type**: Technical Spike
**Time-box**: [X hours]

## Research Question
[What are we trying to understand?]

## Summary
[High-level documentation of what was found]

## Detailed Findings

### [Component/Area 1]
- Description of what exists (`file.ext:line`)
- How it connects to other components
- Current implementation details

### [Component/Area 2]
[Same structure]

## Code References
- `path/to/file.ts:123` - Description
- `another/file.ts:45-67` - Description

## Discovered Patterns
Patterns identified for use in implementation:
- **UI Pattern**: [description + file reference]
- **API Pattern**: [description + file reference]
- **Security Pattern**: [description + file reference]

## Discovered Issues

| ConTS ID | Type | Description | Priority |
|----------|------|-------------|----------|
| ConTS-xxxx | bug | Description | 2 |
| ConTS-yyyy | enabler | Description | 3 |

## Open Questions
[Areas needing clarification before spec creation]

## Spike Outcome
Research complete. Ready for spec creation: `/spec [topic]`
```

### Step 1.5: Create Discovered Issues

For each discovery during research:

```bash
bd create "ConTS-Discovered: [description]" -t [bug|task|enabler] -p [priority] \
  -l discovered,spike --json
bd dep add [new-id] $RESEARCH_ID --type discovered-from
```

### Step 1.6: Close Research Issue

```bash
bd update $RESEARCH_ID --status in_progress
# After document is complete:
bd close $RESEARCH_ID --reason "Spike complete. See thoughts/shared/research/YYYY-MM-DD-{slug}.md"
```

---

## Phase 2: Spec Creation

**PREREQUISITE**: Research document MUST exist before creating a spec.

### Step 2.1: Pre-Spec Gate

Before proceeding, verify:

- [ ] Research document exists and is complete
- [ ] All open questions from research are resolved
- [ ] Discovered issues are logged in Beads

If research is incomplete, return to Phase 1.

### Step 2.2: Create Linear Issue (PRD Attachment)

```text
mcp__linear-mcp__create_issue({
  title: "feat(scope): [Feature Name]",
  team: "ConTStack",
  description: "## PRD\n\nSee spec: specs/ConTS-XXX-{feature}-spec.md",
  labels: ["feature", "spec", "sprint-X"],
})
```

Note the returned Linear issue ID as `$LINEAR_ID` (e.g., ConTS-123).

### Step 2.3: Create Beads Epic

```bash
bd create "ConTS-$LINEAR_ID: [Feature Name]" -t epic -p [priority] -l rsi,spec,epic --json
```

Save the returned issue ID as `$EPIC_ID`.

### Step 2.4: Create Spec Document

Create file: `specs/ConTS-{LINEAR_ID}-{feature-slug}-spec.md`

Use the complete spec template in the "Spec Document Template" section below.

### Step 2.5: Create Phase Issues in Beads

```bash
# Phase 1
bd create "ConTS-$LINEAR_ID Phase 1: [Name]" -t story -p [priority] \
  -l phase,story,ConTS-$LINEAR_ID --json
# Save as $PHASE1_ID

# Phase 2
bd create "ConTS-$LINEAR_ID Phase 2: [Name]" -t story -p [priority] \
  -l phase,story,ConTS-$LINEAR_ID --json
# Save as $PHASE2_ID

# Phase 3
bd create "ConTS-$LINEAR_ID Phase 3: [Name]" -t story -p [priority] \
  -l phase,story,ConTS-$LINEAR_ID --json
# Save as $PHASE3_ID

# Phase 4
bd create "ConTS-$LINEAR_ID Phase 4: [Name]" -t story -p [priority] \
  -l phase,story,ConTS-$LINEAR_ID --json
# Save as $PHASE4_ID
```

### Step 2.6: Set Up Dependencies

```bash
# Create blocking dependencies
bd dep add $PHASE2_ID $PHASE1_ID --type blocks
bd dep add $PHASE3_ID $PHASE2_ID --type blocks
bd dep add $PHASE4_ID $PHASE3_ID --type blocks

# Link phases to epic
bd dep add $PHASE1_ID $EPIC_ID --type child-of
bd dep add $PHASE2_ID $EPIC_ID --type child-of
bd dep add $PHASE3_ID $EPIC_ID --type child-of
bd dep add $PHASE4_ID $EPIC_ID --type child-of

# View dependency tree
bd dep tree $EPIC_ID
```

### Step 2.7: Spec Approval Gate

**STOP**: Before proceeding to implementation, verify:

- [ ] All acceptance criteria are testable
- [ ] Pattern references point to existing patterns
- [ ] Success validation commands are runnable
- [ ] Demo script is step-by-step reproducible
- [ ] Beads epic and all phase issues created
- [ ] Linear issue linked to spec document
- [ ] Open questions resolved or escalated

**Request human review** for spec approval before implementation.

---

## Phase 3: Implementation Protocol

### Step 3.1: Pre-Implementation Checklist

- [ ] Spec status is "approved"
- [ ] All blocking dependencies clear
- [ ] Development environment ready
- [ ] Feature branch created

```bash
# Create feature branch
git checkout -b ConTS-$LINEAR_ID-{feature-slug}

# Verify clean state
git status
bun install
bun typecheck
```

### Step 3.2: Execute Phases

For each phase:

1. **Update Beads status:**
   ```bash
   bd update $PHASE_N_ID --status in_progress
   ```

2. **Implement changes** following the spec

3. **Run validation:**
   ```bash
   bun test && bun lint && bun typecheck
   ```

4. **Commit with prescribed message:**
   ```bash
   git add .
   git commit -m "feat(scope): description [ConTS-{LINEAR_ID}]"
   ```

5. **Close phase:**
   ```bash
   bd close $PHASE_N_ID --reason "Phase complete. Tests passing."
   ```

### Step 3.3: Post-Implementation

After all phases complete:

1. **Run demo script** and verify all steps pass
2. **Update spec status** to "complete"
3. **Close Beads epic:**
   ```bash
   bd close $EPIC_ID --reason "Feature complete. All phases done."
   ```

4. **Update Linear with evidence:**
   ```text
   mcp__linear-mcp__create_comment({
     issueId: "$LINEAR_ID",
     body: "**Implementation Complete**\n\n[Evidence template filled]"
   })
   ```

---

## Stop-the-Line Conditions

**FORBIDDEN** - Do not proceed if:

- Missing research document (return to Phase 1)
- No acceptance criteria defined
- No pattern references provided
- No success validation commands
- No demo script for user-facing features
- Beads epic/phases not created
- Open questions unresolved

**ESCALATE** if any condition cannot be met.

---

## Spec Document Template

Create file: `specs/ConTS-{LINEAR_ID}-{feature-slug}-spec.md`

```markdown
---
date: [ISO timestamp]
author: Claude
linear_issue: $LINEAR_ID
beads_epic: $EPIC_ID
research_doc: thoughts/shared/research/YYYY-MM-DD-{topic}.md
git_commit: [current commit hash]
branch: [current branch]
feature: "[Feature Name]"
status: draft | approved | implementing | complete
---

# SPEC-ConTS-{LINEAR_ID}: [Feature Name]

## Research Summary

**Research Doc:** [link to research document]

**Key Findings:**
- [Finding 1]
- [Finding 2]
- [Finding 3]

---

## User Story

As a **[user type]**,
I want **[goal/action]**
so that **[benefit/value]**.

### Persona Context
- **User Type**: [description of user]
- **Primary Goal**: [what they're trying to achieve]
- **Pain Point**: [current friction or limitation]

---

## Acceptance Criteria

### Functional Criteria

- [ ] **AC1**: User can [action] -> [expected result]
- [ ] **AC2**: When user [triggers], system [responds]
- [ ] **AC3**: [field/input] validates [constraint]
- [ ] **AC4**: [action] is blocked when [condition]

### Non-Functional Criteria

- [ ] **Performance**: [action] completes within [X]ms
- [ ] **Accessibility**: [component] meets WCAG 2.1 AA
- [ ] **Security**: [data] is [protected/encrypted/scoped]
- [ ] **Multi-tenant**: Data scoped to organization

---

## Pattern References

Reference existing patterns from the codebase:

| Pattern Type | Reference | Usage |
|--------------|-----------|-------|
| **UI** | `apps/app/src/components/[pattern]` | [how to apply] |
| **API** | `packages/backend/convex/[pattern]` | [how to apply] |
| **Auth** | `packages/backend/convex/auth/*` | [how to apply] |
| **Schema** | `packages/backend/convex/schema.ts` | [table pattern] |

### Pattern Compliance Checklist

- [ ] UI follows existing component patterns
- [ ] API follows Convex query/mutation conventions
- [ ] Auth uses `requireAuth()` / `requireOrganization()`
- [ ] Multi-tenant isolation verified

---

## Success Validation Commands

```bash
# Run all tests
bun test

# Run specific feature tests
bun test --grep "[FeatureName]"

# Type checking
bun typecheck

# Lint check
bun lint

# E2E validation (if applicable)
bun test:e2e:docker:comprehensive
```

### API Validation (if applicable)

```bash
# Test API endpoint
curl -X POST http://localhost:3001/api/[endpoint] \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"test": true}'

# Expected response: 200 OK with [expected data]
```

---

## Demo Script

### Prerequisites
- [ ] Development server running (`bun dev`)
- [ ] Test user account available
- [ ] Test data seeded (if required)

### Steps

1. **Navigate** to [starting page]
   - URL: `http://localhost:3001/[path]`
   - Expected: [page loads, shows X]

2. **Action** [specific user action]
   - Click/Enter: [element/data]
   - Expected: [response/feedback]

3. **Verify** [success indicator]
   - Check: [what to look for]
   - Expected: [specific outcome]

4. **Edge Case** [error/boundary condition]
   - Try: [invalid input or action]
   - Expected: [error handling behavior]

### Demo Success Criteria
- [ ] All steps complete without errors
- [ ] Success indicators visible
- [ ] Edge cases handled gracefully

---

## Implementation Phases

### Phase 1: [Foundation/Schema] (Beads: $PHASE1_ID)

**Goal:** [What this phase accomplishes]
**Blocked By:** None
**Story Points:** [estimate]

#### Changes

1. **File:** `packages/backend/convex/schema.ts` (line XX)

   **Before:**
   ```typescript
   // Current state
   ```

   **After:**
   ```typescript
   // New state
   ```

2. **File:** `packages/backend/convex/[feature].ts` (new file)

   **Create:**
   ```typescript
   // New implementation
   ```

#### Acceptance Criteria

**Automated:**
- [ ] `bun test` - passes
- [ ] `bun typecheck` - passes
- [ ] `bun lint` - passes

**Manual:**
- [ ] Schema deploys successfully to Convex
- [ ] No breaking changes to existing functionality

#### Logical Commits

```text
feat(convex): add [feature] schema [ConTS-{LINEAR_ID}]
feat(convex): implement [feature] queries [ConTS-{LINEAR_ID}]
```

---

### Phase 2: [API/Backend] (Beads: $PHASE2_ID)

**Goal:** [What this phase accomplishes]
**Blocked By:** Phase 1
**Story Points:** [estimate]

#### Changes

[Same structure as Phase 1]

#### Acceptance Criteria

[Same structure as Phase 1]

#### Logical Commits

```text
feat(api): add [feature] mutations [ConTS-{LINEAR_ID}]
test(convex): add [feature] backend tests [ConTS-{LINEAR_ID}]
```

---

### Phase 3: [UI/Frontend] (Beads: $PHASE3_ID)

**Goal:** [What this phase accomplishes]
**Blocked By:** Phase 2
**Story Points:** [estimate]

#### Changes

[Same structure as Phase 1]

#### Acceptance Criteria

[Same structure as Phase 1]

#### Logical Commits

```text
feat(ui): add [feature] component [ConTS-{LINEAR_ID}]
feat(app): integrate [feature] page [ConTS-{LINEAR_ID}]
test(ui): add [feature] component tests [ConTS-{LINEAR_ID}]
```

---

### Phase 4: [Testing/Polish] (Beads: $PHASE4_ID)

**Goal:** Complete testing and documentation
**Blocked By:** Phase 3
**Story Points:** [estimate]

#### Changes

- E2E test coverage
- Documentation updates
- Final polish

#### Acceptance Criteria

- [ ] E2E tests passing
- [ ] Demo script verified
- [ ] Documentation updated

#### Logical Commits

```text
test(e2e): add [feature] E2E tests [ConTS-{LINEAR_ID}]
docs: update [feature] documentation [ConTS-{LINEAR_ID}]
```

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk 1] | Low/Med/High | Low/Med/High | [Strategy] |
| [Risk 2] | Low/Med/High | Low/Med/High | [Strategy] |

---

## Definition of Done

- [ ] All acceptance criteria verified
- [ ] All phases completed and Beads issues closed
- [ ] Code reviewed and approved
- [ ] Tests passing in CI
- [ ] Demo script executed successfully
- [ ] Linear issue updated with evidence
- [ ] No new security vulnerabilities
- [ ] Multi-tenant isolation verified

---

## Open Questions

- [ ] [Decision needed from stakeholder]
- [ ] [Technical decision pending]

---

## Evidence Attachments

### For Linear Comments

```markdown
**Spec Evidence**

**Spec Doc**: specs/ConTS-{LINEAR_ID}-{feature}-spec.md
**Research Doc**: thoughts/shared/research/YYYY-MM-DD-{topic}.md
**Beads Epic**: $EPIC_ID

**Phase Status:**
- [ ] Phase 1: [status]
- [ ] Phase 2: [status]
- [ ] Phase 3: [status]
- [ ] Phase 4: [status]

**Validation:**
- [ ] Demo script verified
- [ ] All tests passing
```
```

---

## File Naming Conventions

| Document Type | Location | Naming Pattern |
|---------------|----------|----------------|
| Research | `thoughts/shared/research/` | `YYYY-MM-DD-{topic-slug}.md` |
| Spec | `specs/` | `ConTS-{LINEAR_ID}-{feature-slug}-spec.md` |
| Plan (deprecated) | `thoughts/shared/plans/` | `YYYY-MM-DD-ConTS-{LINEAR_ID}-{feature-slug}.md` |
| Handoff | `thoughts/shared/handoffs/` | `YYYY-MM-DD-HHmm-handoff.md` |

---

## Quick Reference Commands

```bash
# Start research
bd create "ConTS-Spike: [topic]" -t spike -p 2 -l spike,research,rsi --json

# Create epic after spec
bd create "ConTS-XXX: [feature]" -t epic -p [priority] -l rsi,spec,epic --json

# Create phase issues
bd create "ConTS-XXX Phase N: [name]" -t story -p [priority] -l phase,story --json

# Set up blocking
bd dep add [child-id] [parent-id] --type blocks

# View ready work
bd ready --json

# View dependency tree
bd dep tree [epic-id]

# Update status
bd update [issue-id] --status in_progress

# Close with summary
bd close [issue-id] --reason "Summary of completion"
```

---

## Dual Issue Tracking Summary

| System | Use For | Examples |
|--------|---------|----------|
| **Linear** | PRD storage, sprint planning, stakeholder visibility | ConTS-123 (feature ticket) |
| **Beads** | Agent tracking, phase management, dependencies | Epic, Phase 1-N issues |

### Sync Pattern

```text
Linear (Human PRD) -> Beads Epic -> Beads Phases -> Implementation -> Evidence to Linear
```

---

## Session Handoff

When ending a session mid-spec:

1. **Update all in-progress items:**
   ```bash
   bd update $CURRENT_PHASE --status pending  # If not complete
   ```

2. **Create handoff document:**
   File: `thoughts/shared/handoffs/YYYY-MM-DD-HHmm-handoff.md`

   ```markdown
   # Session Handoff - [Date]

   ## Current State
   - **Spec:** ConTS-{ID} - [status]
   - **Current Phase:** [N] - [status]
   - **Blocking Issues:** [any blockers]

   ## Next Steps
   1. [Immediate next action]
   2. [Following action]

   ## Context for Next Session
   - [Important context]
   - [Decisions made]

   ## Beads State
   - Epic: $EPIC_ID - [status]
   - Phase 1: $PHASE1_ID - [status]
   - Phase 2: $PHASE2_ID - [status]
   ...
   ```

3. **Sync Beads:**
   ```bash
   bd sync
   ```

---

## Beads Label Strategy

| Label | Purpose |
|-------|---------|
| `research` | Research/spike phase work |
| `spec` | Spec creation/review |
| `phase` | Implementation phase |
| `discovered` | Found during research |
| `blocked` | Waiting on dependency |
| `rsi` | RSI workflow item |
| `epic` | Feature epic |
| `story` | Implementation story |

---

## Authoritative References

- **Research Command**: `.claude/commands/research.md`
- **Implement Command**: `.claude/commands/implement.md`
- **Linear SOP**: `.claude/skills/linear-sop/SKILL.md`
- **SAFe Workflow**: `.claude/skills/safe-workflow/SKILL.md`
- **Testing Patterns**: `.claude/skills/testing-patterns/SKILL.md`
- **RPI Documentation**: CLAUDE.md "RPI Workflow Integration" section
