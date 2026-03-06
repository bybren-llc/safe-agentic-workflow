# Agent Teams Guide

**Role**: Any agent role (TDM recommended as team lead)
**Purpose**: Real-time multi-agent coordination using Claude Code Agent Teams for SAFe workflows.

**Prerequisites**:

- Claude Code 2.1.0+ installed
- Agent Teams experimental feature enabled
- Familiarity with the 11-agent team structure (see [AGENTS.md](../../AGENTS.md))
- Repository cloned with agent system verified (see [AGENT-SETUP-GUIDE.md](./AGENT-SETUP-GUIDE.md))

---

## What Are Agent Teams?

Agent Teams is a Claude Code capability that allows multiple Claude Code sessions to coordinate as a real-time team. A single **team lead** session spawns **teammate** sessions, and all participants share a structured TaskList and communicate through direct inter-agent messages. The team lead orchestrates the work, creates tasks with dependencies, monitors progress, and synthesizes results when the work is done.

In the SAFe Agentic Workflow, Agent Teams map naturally to the 11-agent structure defined in [AGENTS.md](../../AGENTS.md). The TDM (or ARCHitect-in-CLI) acts as the team lead, spawning specialist teammates such as BE Developer, FE Developer, QAS, and others. Each teammate operates in its own Claude Code session with full tool access, working on assigned tasks in parallel or sequence based on dependency relationships.

Agent Teams differ from the two other multi-agent approaches available in Claude Code: subagents (via the Task tool) and background agents (headless sessions). Understanding when to use each approach is critical for efficient token usage and effective coordination.

### Agent Teams vs Subagents vs Background Agents

| Aspect | Agent Teams | Subagents (Task tool) | Background Agents |
| --- | --- | --- | --- |
| **Communication** | Bi-directional messaging between all teammates and lead | One-way: subagent reports result back to caller | None during execution; results available after completion |
| **Coordination** | Shared TaskList with dependencies, real-time status | Caller waits for subagent to finish, then proceeds | Fire-and-forget; poll for completion |
| **Visibility** | All teammates visible in split panes or in-process view | Subagent runs inline within the caller's session | Runs headless in the background |
| **Shared state** | Shared filesystem; teammates can read each other's output | Shared filesystem within the session | Shared filesystem (same repo clone) |
| **Best for** | Feature implementation requiring 3-8 coordinated specialists | Focused single-step delegation (review, test, generate) | Long-running tasks that do not need real-time feedback |
| **Token cost** | Approximately 7x a single session (per teammate) | 1-2x per subagent invocation | 1x per background session |
| **Session model** | Single team per session; no resumption after exit | Ephemeral within the parent session | Persistent; can be listed and retrieved later |

**Rule of thumb**: Use Agent Teams when you need multiple specialists working simultaneously with awareness of each other's progress. Use subagents when you need a focused specialist to complete a task and return the result. Use background agents when the work is independent and you do not need the result immediately.

---

## Enabling Agent Teams

### Step 1: Enable the Experimental Flag

Agent Teams is an experimental feature that must be explicitly enabled. Add the following to your Claude Code settings file or set the environment variable before launching Claude Code.

**Option A: Settings file** (`~/.claude/settings.json`):

```json
{
  "experiments": {
    "agentTeams": true
  }
}
```

**Option B: Environment variable**:

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=true
```

Add the environment variable to your shell profile (`~/.bashrc`, `~/.zshrc`) for persistence across sessions.

### Step 2: Choose a Display Mode

Agent Teams supports two display modes for teammate sessions.

**In-process mode** (default): All teammate output is displayed within the lead's terminal. This is the simplest option and works in any terminal emulator.

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "teammateMode": "in-process"
}
```

**Split-pane mode**: Each teammate gets its own terminal pane using tmux or iTerm2 split panes. This provides better visibility when running 3 or more teammates.

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "teammateMode": "tmux"
}
```

Split-pane mode requirements:

- **tmux**: Install via `brew install tmux` (macOS) or `sudo apt install tmux` (Linux). Claude Code will automatically create a tmux session with panes for each teammate.
- **iTerm2** (macOS only): If detected, Claude Code uses iTerm2's native split-pane API instead of tmux.

### Step 3: Verify Setup

Launch Claude Code in your repository and confirm that Agent Teams is available.

```bash
cd {{PROJECT_NAME}}
claude
```

Once inside the Claude Code session, verify that the team lead can spawn teammates by checking for the `TeamCreate`, `SendMessage`, and `TaskCreate` tools in the available tool list. You can test by asking Claude directly:

```
Can you confirm that Agent Teams tools are available? List the team-related tools you have access to.
```

Expected tools include:

- `TeamCreate` — Create a new team with shared task list
- `Task` — Spawn teammates as specialized agents
- `SendMessage` — Send direct messages, broadcasts, or shutdown requests
- `TaskCreate` / `TaskUpdate` / `TaskList` — Manage the shared task board
- `TeamDelete` — Clean up team resources when done

If these tools are not listed, verify that the experimental flag is correctly set and that your Claude Code version is 2.1.0 or later (`claude --version`).

---

## Quick Start: Your First Agent Team

### Example: Implement a Feature with a Team

This walkthrough demonstrates spawning a 3-teammate team to implement a feature defined in a spec. The team lead (TDM) coordinates a BE Developer, FE Developer, and QAS.

**Step 1: Start a Claude Code session as the team lead.**

```bash
cd {{PROJECT_NAME}}
claude
```

**Step 2: Instruct the lead to read the spec and form a team.**

```
I need to implement {{TICKET_PREFIX}}-42 (User Profile Management).
The spec is at specs/{{TICKET_PREFIX}}-42-user-profile-spec.md.

Please read the spec, then form an Agent Team with:
1. A BE Developer teammate to implement the API endpoints
2. A FE Developer teammate to build the profile UI
3. A QAS teammate to write and run tests after implementation

Create tasks with proper dependencies so QAS waits for both BE and FE to finish.
```

**What happens behind the scenes:**

1. The lead reads the spec and identifies the work breakdown.
2. The lead uses `TeamCreate` to set up the team, then spawns teammates via the `Task` tool with `team_name` parameter, providing each with role-specific prompts from `.claude/agents/`.
3. The lead calls `TaskCreate` to add tasks to the shared TaskList:
   - Task A: "Implement profile API endpoints" (assigned to BE Developer)
   - Task B: "Build profile UI components" (assigned to FE Developer)
   - Task C: "Write and run tests for profile feature" (assigned to QAS, blocked by Task A and Task B)
4. BE Developer and FE Developer work in parallel.
5. When both finish, QAS picks up Task C automatically.
6. The lead monitors progress and synthesizes results.

**Step 3: Monitor and finalize.**

The lead will periodically check task statuses. Once QAS reports that all tests pass and acceptance criteria are met, the lead summarizes the outcome and can either shut down the team or hand off to the RTE for PR creation.

### Example: Parallel Code Review

Use Agent Teams to run multiple independent reviews simultaneously.

```
I need a thorough review of the changes on branch {{TICKET_PREFIX}}-99-payment-flow.

Please form an Agent Team with 3 reviewers:
1. Security Engineer -- review for RLS enforcement, credential handling, injection risks
2. System Architect -- review for pattern consistency, architectural alignment, code quality
3. QAS -- review test coverage, edge cases, acceptance criteria validation

Each reviewer should work independently and report findings. Synthesize their reports when all are done.
```

The lead spawns three teammates, creates three independent review tasks (no dependencies between them), and waits for all to complete. Each reviewer reads the diff, applies their specialist lens, and reports findings. The lead then produces a consolidated review summary.

---

## SAFe Workflow with Teams

### The TDM as Team Lead

In the SAFe Agentic Workflow, the TDM is the natural team lead for Agent Teams sessions. The TDM's responsibilities as team lead are:

1. **Analyze the task**: Read the spec and Linear ticket to understand the full scope of work.
2. **Create the team**: Determine which specialists are needed based on the feature scope.
3. **Spawn teammates**: Launch each specialist with role-appropriate prompts and context.
4. **Create tasks with dependencies**: Define the work breakdown and sequencing using the shared TaskList. Use `blockedBy` and `addBlocks` to enforce SAFe quality gates.
5. **Monitor progress**: Periodically check task statuses and teammate activity. Intervene if a teammate is blocked or idle.
6. **Resolve blockers**: If a teammate encounters an issue, the lead can send messages with guidance, reassign work, or escalate.
7. **Synthesize results**: When all tasks are complete, the lead gathers evidence, posts to Linear, and coordinates the handoff to the next gate.
8. **Shut down the team**: Gracefully shut down all teammates when the work session is complete.

For complex investigations or architectural work, the ARCHitect-in-CLI may serve as team lead instead, following Method 3 from the [Agent Workflow SOP](../sop/AGENT_WORKFLOW_SOP.md).

### Quality Gates as Task Dependencies

The SAFe quality gates map directly to the TaskList's dependency system. Use `blockedBy` to prevent downstream tasks from starting until their prerequisites are complete.

```
TaskList dependency chain for a typical feature:

Task 1: "Implement backend endpoints"
  assignee: be-developer
  blockedBy: []

Task 2: "Implement frontend components"
  assignee: fe-developer
  blockedBy: []

Task 3: "Validate all acceptance criteria"
  assignee: qas
  blockedBy: [Task 1, Task 2]

Task 4: "Create PR and validate CI"
  assignee: rte (or lead handles if RTE role collapsed)
  blockedBy: [Task 3]
```

This maps to the SAFe exit state flow:

```
Implementation (BE/FE)     "Ready for QAS"
       |
       v
QAS Validation             "Approved for RTE"
       |
       v
RTE PR Creation            "Ready for HITL Review"
       |
       v
Stage 1 Review             "Stage 1 Approved - Ready for ARCHitect"
       |
       v
Stage 2 Review             ARCHitect approval
       |
       v
HITL Merge                 MERGED
```

Note that Stage 1 Review, Stage 2 Review, and HITL Merge happen outside the Agent Teams session, as they involve review by the System Architect, ARCHitect-in-CLI, and the human respectively. The Agent Teams session typically covers the implementation-through-PR-creation span.

### Spawning Teammates by Role

Each of the 11 agent roles can be spawned as a teammate. Use the agent prompt files in `.claude/agents/` as the system prompt for each teammate. Below are the recommended configurations.

**Planning and Coordination**:

| Role | Agent file | Model | Use as teammate when |
| --- | --- | --- | --- |
| TDM | `.claude/agents/tdm.md` | opus | Typically the lead, not a teammate |
| BSA | `.claude/agents/bsa.md` | opus | Spec needs to be created as part of the workflow |
| System Architect | `.claude/agents/system-architect.md` | opus | Architectural review is part of the task |

**Implementation**:

| Role | Agent file | Model | Use as teammate when |
| --- | --- | --- | --- |
| BE Developer | `.claude/agents/be-developer.md` | sonnet | API routes, server logic, RLS enforcement |
| FE Developer | `.claude/agents/fe-developer.md` | sonnet | UI components, client-side logic |
| Data Engineer | `.claude/agents/data-engineer.md` | sonnet | Schema changes, migrations |
| DPE | `.claude/agents/data-provisioning-eng.md` | sonnet | Test data, data pipelines |

**Quality and Documentation**:

| Role | Agent file | Model | Use as teammate when |
| --- | --- | --- | --- |
| QAS | `.claude/agents/qas.md` | sonnet | Testing and validation (non-collapsible gate) |
| Security Engineer | `.claude/agents/security-engineer.md` | sonnet | Security audit (non-collapsible gate) |
| Tech Writer | `.claude/agents/tech-writer.md` | sonnet | Documentation updates needed |
| RTE | `.claude/agents/rte.md` | sonnet | PR creation and CI shepherding |

When spawning a teammate, provide the agent's role prompt as the system context and include the spec or ticket reference so the teammate has full context for its work.

### Communication Patterns

Agent Teams supports two communication mechanisms.

**Direct messages** (`sendMessage`): The primary communication method. Use direct messages to:

- Provide a teammate with additional context or clarification
- Notify a teammate that a dependency is resolved
- Ask a teammate for a status update
- Share the output of one teammate's work with another

Direct messages are targeted to a specific teammate and are the most common communication pattern.

**Broadcasts**: Messages sent to all teammates at once. Use broadcasts sparingly, as they add noise and token cost. Appropriate uses include:

- Announcing a change in plan that affects all teammates
- Sharing a critical discovery (such as a security issue) that all teammates must be aware of
- Coordinating a synchronized shutdown

**Shutdown coordination**: When the team lead determines that all work is complete, it should:

1. Verify all tasks in the TaskList have status "completed"
2. Send a final message to each teammate confirming that no further work is needed
3. Send `shutdown_request` via `SendMessage` for each teammate
4. Summarize the session results

---

## Team Sizing Guidelines

Choose team size based on the scope of work. Larger teams increase token cost and coordination overhead.

| Work scope | Team size | Typical composition | When to use |
| --- | --- | --- | --- |
| **Story** (single user story) | 2-3 teammates | 1 implementer + 1 QAS (+ optional TW) | Focused work on a single feature slice |
| **Feature** (multi-story feature) | 3-5 teammates | 1-2 implementers + QAS + optional SecEng + optional TW | Standard feature implementation |
| **Epic** (large initiative) | 5-8 teammates | BSA + multiple implementers + QAS + SecEng + RTE | Major cross-cutting work requiring full team |

**Rules of thumb:**

- Start small. You can always spawn additional teammates mid-session if needed.
- Non-collapsible roles (QAS, Security Engineer) should always be separate teammates when quality gates apply. Never have the implementer self-verify.
- If work items are truly independent with no shared state, prefer background agents over a team, as the coordination overhead is unnecessary.
- Each teammate consumes a separate context window. Keep teammate prompts focused on their specific task to avoid wasting context on irrelevant information.
- For Stories where the implementer can handle the PR (RTE role collapsed per {{TICKET_PREFIX}}-499), a team of 2 (implementer + QAS) is often sufficient.

---

## Quality Gate Hooks

Agent Teams provides two hook mechanisms for enforcing quality standards on teammate behavior. These hooks run as shell scripts and use exit codes to control whether a teammate's state transition is accepted.

### TeammateIdle Hook

The `teammateIdle` hook fires when a teammate reports that it has finished its current work and is transitioning to an idle state. Use this hook to validate that the teammate actually completed its work before allowing it to go idle.

**Configuration** (`.claude/hooks/teammateIdle.sh`):

```bash
#!/bin/bash
# TeammateIdle hook: validate teammate completed work before going idle
# Exit 0 = allow idle (work is done)
# Exit 2 = reject idle (send teammate back to work with message on stderr)

TEAMMATE_ROLE="$1"
TEAMMATE_ID="$2"

# Example: Verify that QAS teammate ran tests before going idle
if [ "$TEAMMATE_ROLE" = "qas" ]; then
  # Check if test results exist
  if [ ! -f "test-results/{{TICKET_PREFIX}}-latest.json" ]; then
    echo "QAS must run tests before going idle. No test results found." >&2
    exit 2
  fi
fi

exit 0
```

**How it works**: When the hook returns exit code 2, the teammate receives the stderr message as feedback and continues working instead of going idle. This prevents teammates from prematurely stopping before their work is complete.

### TaskCompleted Hook

The `taskCompleted` hook fires when a teammate marks a task as completed in the shared TaskList. Use this hook to validate that the task output meets minimum quality standards before the completion is accepted.

**Configuration** (`.claude/hooks/taskCompleted.sh`):

```bash
#!/bin/bash
# TaskCompleted hook: validate task output before marking complete
# Exit 0 = accept completion
# Exit 2 = reject completion (send back with feedback on stderr)

TASK_ID="$1"
TASK_TITLE="$2"
TEAMMATE_ROLE="$3"

# Example: Verify implementation tasks pass linting
if [ "$TEAMMATE_ROLE" = "be-developer" ] || [ "$TEAMMATE_ROLE" = "fe-developer" ]; then
  if ! {{LINT_COMMAND}} 2>/dev/null; then
    echo "Linting failed. Fix lint errors before marking task complete." >&2
    exit 2
  fi
fi

# Example: Verify QAS tasks include evidence
if [ "$TEAMMATE_ROLE" = "qas" ]; then
  if ! {{TEST_UNIT_COMMAND}} 2>/dev/null; then
    echo "Unit tests failed. All tests must pass before marking QAS task complete." >&2
    exit 2
  fi
fi

exit 0
```

**SAFe integration**: These hooks enforce the same quality gates defined in the [Agent Workflow SOP](../sop/AGENT_WORKFLOW_SOP.md). The `taskCompleted` hook for QAS tasks can verify that all acceptance criteria have been addressed, and the `teammateIdle` hook for implementers can verify that validation commands pass.

---

## Token Cost Considerations

Agent Teams consumes approximately 7 times the tokens of a single Claude Code session because each teammate maintains its own context window. The team lead also consumes tokens for coordination overhead (monitoring, messaging, task management).

**When Agent Teams is worth the cost:**

- Multiple specialists need to work in parallel, and the wall-clock time savings outweigh the token cost
- Real-time coordination is critical (teammates need to react to each other's progress)
- The work breakdown has clear dependencies that benefit from the TaskList model
- The feature is complex enough that sequential subagent calls would be slow and lose context

**When simpler approaches are better:**

- **Single specialist task**: Use a direct agent invocation (`@agent-name`) or a subagent via the Task tool
- **Independent, non-coordinated work**: Use background agents; no communication overhead needed
- **Code review or validation only**: A single subagent call (Task tool) is typically sufficient
- **Simple bug fixes or documentation updates**: Method 1 (Direct Specialist Invocation) from the Agent Workflow SOP is more efficient
- **Budget-constrained work**: If token cost is a concern, prefer sequential subagent calls over a full team

**Cost optimization tips:**

- Shut down teammates as soon as their tasks are complete; do not leave idle teammates running
- Keep teammate system prompts concise; the full agent prompt file plus the spec is usually sufficient context
- Avoid unnecessary broadcasts; prefer targeted direct messages
- For review-only teammates (Security Engineer, System Architect), spawn them only when implementation is done, not at session start

---

## Known Limitations

Agent Teams is an experimental feature with the following limitations as of Claude Code 2.1.x:

- **No session resumption**: If the team lead's session ends (crash, disconnect, manual exit), the entire team shuts down. Work in progress is not recoverable from the team's perspective, though filesystem changes are preserved. Commit frequently.
- **One team per session**: A single Claude Code session can only lead one team. You cannot nest teams or have a teammate spawn its own sub-team.
- **No nested teams**: A teammate cannot itself become a team lead and spawn additional teammates. If a teammate needs delegation, it must use the Task tool (subagent) instead.
- **No cross-session teams**: Teammates must all be spawned from the same lead session. You cannot join an existing team from a separate terminal.
- **Teammate count limits**: While there is no hard limit enforced, performance degrades beyond 8 teammates due to coordination overhead and context window pressure on the lead.
- **No persistent task state**: The shared TaskList exists only for the duration of the team session. If the session ends, the TaskList is lost. Record important outcomes in the filesystem or Linear before shutting down.
- **Tool permissions are session-wide**: Teammates inherit the same permission settings as the lead. You cannot restrict a specific teammate's tool access at the Agent Teams level (tool restrictions in agent frontmatter apply at the agent prompt level, not enforced by Agent Teams).
- **Split-pane mode requires tmux or iTerm2**: In-process mode works everywhere but can be hard to follow with more than 3 teammates.
- **No automatic retry**: If a teammate encounters a fatal error and stops, the lead must manually intervene (send a message, reassign the task, or spawn a replacement teammate).

---

## Troubleshooting

### Teammates Not Appearing

**Symptom**: Teammate spawning is attempted but no teammate session starts.

**Solutions**:

- Verify the experimental flag is enabled: check `~/.claude/settings.json` for `"agentTeams": true` or confirm `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=true` is set in your environment.
- Verify Claude Code version is 2.1.0 or later: run `claude --version`.
- If using split-pane mode, verify tmux is installed: run `which tmux`. If tmux is not found, install it or switch to in-process mode.
- Check that you have not exceeded your API rate limits. Spawning multiple teammates rapidly can trigger rate limiting.

### Too Many Permission Prompts

**Symptom**: Each teammate triggers individual permission prompts for tool usage, making the session unmanageable.

**Solutions**:

- Use the `--dangerously-skip-permissions` flag when launching Claude Code for trusted environments (development only, never production).
- Pre-approve common tool patterns in your Claude Code settings:

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Write",
      "Edit",
      "Bash(git *)",
      "Bash({{LINT_COMMAND}})",
      "Bash({{TEST_UNIT_COMMAND}})",
      "Bash({{BUILD_COMMAND}})"
    ]
  }
}
```

- Alternatively, configure a `.claude/settings.local.json` in the repository root with project-specific permissions.

### Teammates Stopping on Errors

**Symptom**: A teammate encounters a build error, test failure, or linting issue and stops working instead of iterating.

**Solutions**:

- Include explicit iteration instructions in the teammate's system prompt. The standard agent loop ("implement, validate, iterate, escalate if blocked") should be part of the agent prompt. All agent prompts in `.claude/agents/` include this pattern.
- Send a direct message to the stopped teammate with the error context and instructions to continue.
- If the teammate is truly stuck, shut it down and spawn a replacement with additional context about the error.

### Lead Shutting Down Before Teammates Finish

**Symptom**: The team lead session ends (timeout, user exit, crash) while teammates are still working.

**Solutions**:

- Set a longer timeout for the lead session if using `claude --timeout`.
- Avoid leaving the lead session unattended for long periods. The lead should actively monitor teammate progress.
- If the lead session crashes, check the filesystem for any work the teammates completed before they were shut down. Teammates write to the shared filesystem, so their file changes persist even if the session ends.
- Re-launch a new Claude Code session and review the filesystem state. You can start a new team session to continue the work.

### Orphaned tmux Sessions

**Symptom**: After an Agent Teams session in split-pane mode, tmux sessions are left running in the background.

**Solutions**:

```bash
# List all tmux sessions
tmux list-sessions

# Kill orphaned Claude Code team sessions
tmux kill-session -t claude-team

# Kill all tmux sessions (use with caution)
tmux kill-server
```

- Make it a habit to run `tmux list-sessions` after an Agent Teams session to verify cleanup.

### Teammate Not Picking Up Blocked Tasks

**Symptom**: A blocking task is marked complete, but the downstream teammate does not start the now-unblocked task.

**Solutions**:

- Verify the task dependencies are correctly set. Use `TaskList` to inspect the shared task board and confirm `blockedBy` references are correct.
- Send a direct message to the blocked teammate notifying it that the dependency is resolved and it should proceed.
- The lead can also call `TaskCreate` with the same task details to re-trigger the assignment if needed.

---

## Running Agent Teams on a Remote Server (Dark Factory)

For persistent, 24/7 agent teams on a headless remote machine, the harness includes the **Dark Factory** module — a self-contained set of tmux scripts that automate team session management.

### Why Remote?

- **Always-on**: Agent teams run overnight or over weekends without keeping your laptop open
- **Resource isolation**: Dedicated CPU/RAM for agent workloads
- **Team visibility**: Multiple developers can observe via SSH or Cursor Remote
- **Worktree isolation**: Each agent pane gets its own git worktree (no cross-agent file collisions)

### Quick Start

On your remote server:

```bash
cd /path/to/{{PROJECT_NAME}}

# One-time setup (checks prerequisites, creates config, validates merge queue)
./dark-factory/scripts/factory-setup.sh

# Configure your project values
nano ~/.dark-factory/env

# Launch a feature team for a ticket
./dark-factory/scripts/factory-start.sh feature {{TICKET_PREFIX}}-42

# Monitor from any terminal
./dark-factory/scripts/factory-status.sh

# Attach to a specific agent's pane
./dark-factory/scripts/factory-attach.sh

# Graceful shutdown when done
./dark-factory/scripts/factory-stop.sh
```

### Team Layouts

Dark Factory provides pre-built tmux layouts that map to the team sizes described in [Team Sizing Guidelines](#team-sizing-guidelines):

| Layout | Panes | Agents | Command |
| --- | --- | --- | --- |
| `story` | 3 | TDM + BE + QAS | `factory-start.sh story` |
| `feature` | 5 | TDM + BE + FE + QAS + RTE | `factory-start.sh feature` |
| `epic` | 9 | TDM + BSA + ARCH + SecEng + BE + FE + Data + QAS + RTE | `factory-start.sh epic` |

### Observing from Cursor IDE

Connect Cursor IDE to your remote server via SSH Remote, then:

1. Open a terminal in Cursor
2. Run `tmux attach -t factory-*` to observe agent panes
3. Use Cursor's file explorer to see worktree changes in real time

See [Cursor SSH Guide](../../dark-factory/docs/CURSOR-SSH-GUIDE.md) for detailed setup.

### Merge Queue Enforcement

Dark Factory enforces merge queue policy as a hard requirement. Agents create PRs via `gh pr create` and enqueue them via `gh pr merge --auto --squash`. No direct merges are permitted. See [Merge Queue Policy](../../dark-factory/docs/MERGE-QUEUE-POLICY.md).

### Full Documentation

- [Dark Factory README](../../dark-factory/README.md) — Architecture overview and quick start
- [Dark Factory Guide](../../dark-factory/docs/DARK-FACTORY-GUIDE.md) — Comprehensive setup, monitoring, recovery, and FAQ
- [Cursor SSH Guide](../../dark-factory/docs/CURSOR-SSH-GUIDE.md) — Observing agents from Cursor IDE
- [Merge Queue Policy](../../dark-factory/docs/MERGE-QUEUE-POLICY.md) — Squash merge enforcement

---

## Related Documentation

- [AGENTS.md](../../AGENTS.md) - Agent team quick reference (all 11 roles)
- [Agent Workflow SOP](../sop/AGENT_WORKFLOW_SOP.md) - Workflow methods, exit states, role collapsing
- [AGENT-SETUP-GUIDE.md](./AGENT-SETUP-GUIDE.md) - Agent installation and provider setup
- [DAY-1-CHECKLIST.md](./DAY-1-CHECKLIST.md) - First day setup and validation
- [ENGINEER-DAILY-WORKFLOW.md](./ENGINEER-DAILY-WORKFLOW.md) - Implementation workflow for FE/BE developers
- [QAS-DAILY-WORKFLOW.md](./QAS-DAILY-WORKFLOW.md) - QAS validation workflow
- [CONTRIBUTING.md](../../CONTRIBUTING.md) - Git workflow, commit standards, PR process
