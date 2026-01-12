---
description: Execute complete Research -> Plan -> Implement workflow with human checkpoints
arguments:
  - name: task
    description: The feature or task to implement
    required: true
---

# RPI Full Workflow Command

You are initiating the complete Research -> Plan -> Implement workflow for WTFB development.

## Task Description

$ARGUMENTS

## SAFe Alignment

Before starting, identify:
- **Feature/Story**: Which epic or story does this support?
- **Sprint Fit**: Does this fit in current sprint capacity?
- **Dependencies**: Any team or external dependencies?

## Your Process

### Step 1: Load RPI Coordinator
Read and activate the RPI Coordinator agent:
`.claude/agents/rpi-coordinator.md`

### Step 2: Follow RPI Coordinator Instructions
The coordinator will:
1. Execute research phase (spike)
2. Wait for human checkpoint
3. Execute planning phase (story breakdown)
4. Wait for human checkpoint
5. Execute implementation phase (development)
6. Checkpoint after each implementation phase

### Step 3: Context Management
The coordinator manages:
- Spawning specialized agents
- State persistence in thoughts/
- Beads issue tracking with ConTS- prefix
- Human checkpoints aligned with SAFe ceremonies

## Skills Available
These skills will auto-load based on the task:
- `codebase-overview` - Architecture patterns
- `rls-patterns` - Supabase RLS security
- `payment-patterns` - Stripe integration
- `testing-patterns` - E2E and unit testing
- `frontend-patterns` - Next.js/React patterns

## Expected Output

You will create:
1. Research document in `thoughts/shared/research/` (spike outcome)
2. Implementation plan in `thoughts/shared/plans/` (story breakdown)
3. Beads epic with phase issues (ConTS- prefixed)
4. Implemented code changes
5. Validation reports

## Human Interaction

You will pause for human input:
- After research: "Continue to planning?" (spike complete)
- After planning: "Approve for implementation?" (story acceptance)
- After each implementation phase: "Verify and continue?" (demo/review)

## ConTS Ticket Structure

```
ConTS-XXXX (Epic: Feature Name)
+-- ConTS-XXX1 (Story: Phase 1 - Foundation)
|   +-- ConTS-XXX1a (Task: Schema changes)
|   +-- ConTS-XXX1b (Task: API endpoints)
+-- ConTS-XXX2 (Story: Phase 2 - Core Logic)
+-- ConTS-XXX3 (Story: Phase 3 - UI/Integration)
```

## Now Begin

Load the RPI Coordinator agent and start the workflow for:
**$ARGUMENTS**
