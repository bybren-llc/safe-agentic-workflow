---
description: Execute an approved implementation plan phase by phase
arguments:
  - name: plan
    description: Path to plan document OR Beads epic ID
    required: true
---

# Implementation Protocol

You are implementing an approved plan. Follow it precisely while adapting to what you find.

## Plan Reference

$ARGUMENTS

## Critical Rules

1. **Follow the plan intent** while adapting to reality
2. **Implement each phase fully** before moving to the next
3. **Verify your work** makes sense in the broader codebase
4. **Update Beads** as you complete each phase
5. **Pause for human verification** between phases

## Process

### Step 1: Load Plan Context

1. **If $ARGUMENTS is a file path:** Read the plan document
2. **If $ARGUMENTS is a ConTS Beads ID:**
   ```bash
   bd show $ARGUMENTS --json
   bd dep tree $ARGUMENTS
   ```
   Then find the associated plan in `thoughts/shared/plans/`

### Step 2: Check What is Ready

```bash
bd ready --json
```

Identify the first unblocked phase in the plan dependency tree.

### Step 3: Start Phase Implementation

For the current phase:

```bash
bd update [phase-id] --status in_progress --json
```

### Step 4: Execute Phase Changes

For each change in the phase:

1. Read the file at the specified location
2. Verify the "before" code matches (adapt if slightly different)
3. Apply the change
4. Run incremental verification if possible

**If reality does not match the plan:**

```markdown
## Issue in Phase [N]

**Expected:** [what the plan says]
**Found:** [actual situation]
**Why this matters:** [explanation]

Options:
1. [Adaptation that preserves intent]
2. [Alternative approach]
3. Pause and consult human

How should I proceed?
```

### Step 5: Run Phase Verification

Execute all automated verification steps from the plan:

```bash
# Example
npm test
npm run lint
npm run typecheck
```

### Step 6: Phase Completion

After automated verification passes:

```markdown
## Phase [N] Complete - Ready for Manual Verification

**ConTS Issue:** [phase-id]

### Automated Verification Passed:
- [x] Tests pass: `npm test`
- [x] Lint clean: `npm run lint`
- [x] Types valid: `npm run typecheck`

### Acceptance Criteria (Manual Verification Required):
- [ ] [Item from plan]
- [ ] [Another item from plan]

**Please perform manual verification and confirm to proceed to Phase [N+1].**
```

Update Beads:
```bash
bd close [phase-id] --reason "Phase complete. Automated verification passed. Awaiting manual verification."
```

### Step 7: Continue or Complete

**If more phases remain:**
- Wait for human confirmation
- Then proceed to next unblocked phase: `bd ready --json`

**If all phases complete:**
```bash
bd close $EPIC_ID --reason "Implementation complete. All phases verified."
```

Create completion summary linking to:
- The plan document
- All ConTS issues closed
- Any discovered issues created during implementation

### Step 8: Handle Discoveries

If you discover issues during implementation:

```bash
bd create "ConTS-Discovered: [description]" -t [type] -p [priority] \
  -l discovered,implementation \
  --json
bd dep add [new-id] [current-phase-id] --type discovered-from
```

Do NOT fix discovered issues unless they block the current phase. File them and continue.

## Context Management

**Monitor context usage.** If approaching 40% context window:

1. Complete current atomic change
2. Run `/compact` to create handoff
3. Recommend starting new session with handoff context

## Output

During implementation, provide:
1. Current phase progress
2. Any adaptations made to the plan
3. Verification results
4. Discovered issues filed (ConTS- prefixed)
5. Clear indication of what is next
