---
description: Create a detailed implementation plan with Beads epic and phase tracking
arguments:
  - name: task
    description: The feature/task to plan (or path to research doc)
    required: true
---

# Planning Protocol

You are creating a detailed implementation plan. Plans must include specific file paths, line numbers, and code snippets. In SAFe terms, this is story breakdown and acceptance criteria definition.

## Task/Feature

$ARGUMENTS

## Process

### Step 1: Gather Context

1. **Check for research document:**
   - If $ARGUMENTS is a file path, read it
   - Otherwise, search `thoughts/shared/research/` for related docs

2. **Check Beads for context:**
   ```bash
   bd list --label spike,research --status closed --json
   bd ready --json
   ```

3. **Review existing plans:**
   ```bash
   bd list -t epic --status open --json
   ```

### Step 2: Spawn Research Agents (if needed)

If no research exists, spawn agents to gather context:

1. **codebase-locator**: Find relevant files
2. **codebase-analyzer**: Understand current patterns
3. **plan-validator**: Check for conflicts with existing plans

### Step 3: Create Epic in Beads

```bash
bd create "ConTS-[Feature Name]" -t epic -p [priority] -l rpi,plan --json
```

Save the returned issue ID as `$EPIC_ID`.

### Step 4: Define Phases (Stories)

For each phase of implementation:

```bash
bd create "ConTS-Phase N: [Phase Name]" -t story -p [priority] -l phase,story --json
```

Set up blocking dependencies:
```bash
bd dep add [phase-2-id] [phase-1-id] --type blocks
bd dep add [phase-3-id] [phase-2-id] --type blocks
# etc.
```

### Step 5: Create Plan Document

Create file: `thoughts/shared/plans/YYYY-MM-DD-{epic-id}-{slug}.md`

Use this template:

```markdown
---
date: [ISO timestamp]
planner: Claude
beads_epic: $EPIC_ID
git_commit: [current commit hash]
branch: [current branch]
feature: "[Feature Name]"
phases: [phase-1-id, phase-2-id, phase-3-id]
status: draft
sprint: [target sprint]
story_points: [estimated total]
---

# Implementation Plan: [Feature Name]

**ConTS Epic:** $EPIC_ID
**Research:** [link to research doc if exists]
**Target Sprint**: [PI-XX.X Sprint Y]
**Total Story Points**: [estimate]

## Overview
[Brief description of what we are implementing and why]

## Current State Analysis
[What exists now, what is missing, key constraints]

## Desired End State
[Specification of the end state and how to verify it]

## Dependency Tree

```
bd dep tree $EPIC_ID
```

## Implementation Phases

### Phase 1: [Phase Name] (X story points)
**ConTS Issue:** [phase-1-id]
**Goal:** [What this phase accomplishes]

#### Changes

1. **File:** `/src/path/to/file.ts` (line 45)

   **Before:**
   ```typescript
   const oldCode = something();
   ```

   **After:**
   ```typescript
   const newCode = somethingBetter();
   ```

2. **File:** `/src/another/file.ts` (lines 12-34)
   [Description of change with code snippet]

#### Acceptance Criteria

**Automated Verification:**
- [ ] Tests pass: `npm test`
- [ ] Lint clean: `npm run lint`
- [ ] Type check: `npm run typecheck`

**Manual Verification:**
- [ ] [Specific manual check]
- [ ] [Another manual check]

---

### Phase 2: [Phase Name] (X story points)
**ConTS Issue:** [phase-2-id]
**Blocked By:** Phase 1 ([phase-1-id])

[Same structure as Phase 1]

---

### Phase 3: [Phase Name] (X story points)
**ConTS Issue:** [phase-3-id]
**Blocked By:** Phase 2 ([phase-2-id])

[Same structure as Phase 1]

---

## Risk Assessment
- [Potential issue and mitigation]

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Code reviewed and approved
- [ ] Tests passing in CI
- [ ] Documentation updated
- [ ] No new security vulnerabilities

## Open Questions
- [Decision needed from human/PO]
```

### Step 6: Request Review

Present the plan summary and ask for human review:

1. Are the phases properly scoped for sprint capacity?
2. Are acceptance criteria specific enough?
3. Any missing edge cases?
4. Is the Beads dependency tree correct?
5. Story point estimates reasonable?

## Output

After creating plan:
1. Summary of the plan structure
2. ConTS epic ID and phase IDs
3. Link to plan document
4. `bd dep tree $EPIC_ID` visualization
5. Request for human approval before implementation
