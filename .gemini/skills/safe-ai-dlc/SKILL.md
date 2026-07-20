---
name: safe-ai-dlc
description: Plan and run programs using the SAFe x AI-DLC fusion. Use when turning an audit, epic, or initiative into Linear structure (initiative, projects, milestones, issues, sub-issues), organizing work as Units of Work and Bolts, wiring a dependency DAG, or running a Bolt swarm with a human-in-the-loop gate.
---

# SAFe x AI-DLC Skill

> **📋 TEMPLATE**: This skill uses `{{TICKET_PREFIX}}` and `{{MAIN_BRANCH}}` as placeholders.
> Replace with your project's ticket prefix (e.g., `WOR`, `PROJ`) and base branch (e.g., `dev`, `main`).

## Purpose

Encode the SAFe x AI-DLC fusion so agents structure multi-issue programs consistently: SAFe supplies
the hierarchy and guardrails, AI-DLC supplies the cadence and the human checkpoint. Inside a program
that adopts this fusion, sprints give way to **Bolts**, because agent teams elaborate, build, and
verify in hours rather than weeks. Adopting the fusion is a per-program choice; the standard sprint
path stays valid, and single isolated tickets route to `safe-workflow` instead.

## When This Skill Applies

- Turning an audit, epic, or initiative into an executable program
- Structuring work in Linear as initiative, projects, milestones, issues, and sub-issues
- Breaking an initiative into Units of Work and sequencing them into Bolts
- Wiring dependencies so gates land before the fixes they verify
- Running a Bolt: elaborate, validate with the human, construct, verify gates are real, evidence, merge

Do NOT use it for a single isolated ticket with no program context — use `safe-workflow` for that.

## The Fusion Model

SAFe gives hierarchy, WSJF, roles, DoD, and dependencies. AI-DLC gives cadence (Bolts) and the
human-in-the-loop. See `docs/guides/SAFE-AI-DLC-METHODOLOGY.md` for the full rationale.

| SAFe              | AI-DLC                                | Linear                                  |
| ----------------- | ------------------------------------- | --------------------------------------- |
| Portfolio Epic    | The Program                           | Initiative                              |
| Epic/value stream | Program stream                        | Sub-initiative, or project priority     |
| Feature           | Unit of Work                          | Project                                 |
| PI increment      | Bolt                                  | `bolt:N` label + target date            |
| Phase gate        | Inception / Construction / Operations | Project Milestone (3 per project)       |
| Story/Enabler     | Story                                 | Issue                                   |
| Task              | Mob task                              | Sub-issue                               |
| WSJF/Role/DoD     | prioritization / mob role / gate      | description + `agent:*` labels + AC/DoD |

**The loop:** AI plans → AI asks clarifying questions → **HUMAN validates business context** → AI
executes. Never skip the human validation step.

## Building the Program (Manual Process)

Since Gemini CLI does not have native Linear integration, build the program through the Linear web UI
(or the Linear CLI if installed). Build top-down:

1. **Initiative** = the program. One per program.
   `Linear web UI → Initiatives → New initiative`
2. **Projects** = Units of Work. One coherent outcome each.
   `Initiative → Add project`
3. **Milestones** = the three AI-DLC phases (Inception, Construction, Operations). Create all three
   per project.
   `Project → Milestones → New milestone`
4. **Issues** = Stories. Each carries the issue template below. Label with `bolt:N` and `agent:*`
   (lead role). Labels must already exist in the workspace.
5. **Sub-issues** = Mob Elaboration tasks. Create during Inception, not before.
   `Issue → Add sub-issue`
6. **Dependencies** = `blocks` / `blockedBy` edges forming the dependency DAG.
   `Issue → Add relation → Blocks / Blocked by`

Program streams map to **sub-initiatives** where the Linear plan supports them; where it does not,
encode the stream as **project priority** instead (highest-risk stream = Urgent/High).

Use `linear-sop` for ticket operations and evidence templates.

## Issue Template

Every issue description block contains:

```text
Header:      <ID> — <title>  [{{TICKET_PREFIX}}-XXX]
WSJF:        <score>   MoSCoW: <Must|Should|Could|Won't>
Finding:     <source refs, e.g. audit finding IDs>
Phase:       <Inception | Construction | Operations>
Bolt:        <bolt:N>
Role:        <agent:* lead>
AC:          - acceptance criterion (testable)
DoD:         - merged to {{MAIN_BRANCH}}; relevant gate REAL and green; evidence in Linear;
               no silent suppression
Deps:        blocks: [...]   blockedBy: [...]
Sub-issues:  (Mob Elaboration tasks, added during Inception)
```

## Dependency-Wiring Rules

Wire `blocks` / `blockedBy` so the enforcement lands **before** the thing it enforces:

- **Fix the gate before the fix it verifies.** Harden CI or un-mask a check before landing the fix
  that check is supposed to catch.
- **Rotate before scrub.** Rotate a leaked credential before scrubbing it from history.
- **Capture before alert.** Error capture or health check blocks the alerter and the poller built on
  top of it.
- **Upgrades before re-baseline.** Framework and SDK upgrades block audit re-baselining, which blocks
  the scheduled recurring audit.

Dependency chains are usually rooted at CI hardening — one keystone issue tends to unblock a whole
stream. Identify it and sequence its Bolt first.

## Running a Bolt

1. **Open and elaborate** every issue in the Bolt (Mob Elaboration: sub-issues, unknowns, questions).
2. **Validate with the human** on all business, security, and policy decisions before Construction.
3. **Construct** in dependency order on `{{TICKET_PREFIX}}-` branches with SAFe commits, rebase-first.
4. **Verify gates are real** — a green check that still masks a failure is not an exit.
5. **Post evidence** to Linear (dev/staging/done) per `linear-sop`.
6. **Merge** — RTE prepares the PR; the human (HITL) merges. Exit = merged + real gates green +
   evidence posted.

## Human-Gate Checklist

Route to the human, with options and a recommendation, whenever a decision is:

- A **secret or credential** action (what to rotate, when, blast radius)
- A **security policy**: CSP allow-list, auth behavior, headers
- A **CI or branch-protection** decision: which checks become required
- A **severity or risk policy**: dependency-audit thresholds, fix-vs-suppress budget
- An **SOP exception** (e.g. a migration deviating from the documented process)
- **Signing the Definition of Done**

If a decision changes business, security, or risk posture, it is the human's — surface, recommend,
stop.

## Anti-Patterns (Do NOT use)

```text
Forcing an ambiguous epic into one Bolt    (run a spike instead — elaboration is the hard part)
Creating sub-issues before Inception       (Mob Elaboration produces them, not the other way round)
Bolts as calendar sprints                  (a Bolt exits on evidence, not on a date)
Skipping human validation to move faster   (the loop is the method; without it this is just SAFe)
Treating a green check as an exit          (verify the gate enforces, not that it merely passed)
```

## Reference

- `docs/guides/SAFE-AI-DLC-METHODOLOGY.md` -- Methodology guide (rationale, worked example)
- `specs_templates/program_template.md` -- Program document scaffolding
- **AI-DLC source**: <https://aws.amazon.com/blogs/devops/ai-driven-development-life-cycle/>
- **Linear Documentation**: <https://linear.app/docs>

## Routes To

- `linear-sop` — Linear operations, program structure, evidence templates
- `safe-workflow` — branch, commit, and PR conventions; HITL merge
- `orchestration-patterns` — multi-agent swarm coordination for a Bolt
- `pattern-discovery` — find existing code and doc patterns before constructing
