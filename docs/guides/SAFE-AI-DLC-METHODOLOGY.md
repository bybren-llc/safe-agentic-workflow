# SAFe x AI-DLC Methodology

**Purpose**: Define the fusion of SAFe structure with the AI-Driven Development Life Cycle, and explain how to plan and run programs at agent speed.

**Audience**: Anyone contributing to a project using this harness -- human or agent. Read this if you have only ever worked the sprint model.

**Core Belief**: SAFe keeps the structure and the guardrails. AI-DLC supplies the speed and the human checkpoint. Inside a program that adopts this fusion, the sprint gives way to the **Bolt**.

**This cadence is opt-in.** Adopting the fusion is a per-program choice, not a repo-wide switch. The standard sprint path stays valid, and single-issue work should run the ordinary `safe-workflow` rather than being dressed up as a program. Note that AWS frames AI-DLC as a replacement for existing practice; this harness offers it as a cadence you select. That softer framing is ours, not theirs.

---

## Why Fuse Them

SAFe is the base. It gives us the hierarchy (initiative to project to issue), WSJF prioritization, clear role boundaries, a Definition of Done, and disciplined dependencies. That machinery works, and this harness already ships it.

But SAFe's *cadence* assumes human squads on week-long sprints. Agent teams do not move at that speed. A team of specialized agents can elaborate, build, and verify a unit of work in hours. Planning that work into two-week increments wastes most of the capability and hides progress behind ceremony.

AWS's [AI-Driven Development Life Cycle](https://aws.amazon.com/blogs/devops/ai-driven-development-life-cycle/) (AI-DLC) is built for exactly this: a tight plan, clarify, validate, execute loop with a human in the middle. So we fuse the two. SAFe supplies structure and guardrails; AI-DLC supplies cadence and the human checkpoint.

The result is not "SAFe but faster." It is SAFe with its clock swapped out, for the programs where you choose to swap it.

---

## The Vocabulary

**Bolt** -- the unit of cadence, standing in for the sprint wherever the fusion is adopted. A short swarm (hours to a few days) with an entry gate, a handful of issues, and a hard exit. Named and numbered (`bolt:0`, `bolt:1`, and so on). A Bolt exits on **evidence**, not on a date.

**Unit of Work** -- an AI-DLC Feature. In the tracker it is a Project. It is one coherent outcome, not a grab-bag of related tickets.

**Mob Elaboration** -- the Inception activity. The AI reads the issue, breaks it into sub-issues (mob tasks), lists unknowns, and asks clarifying questions **before writing any code**.

**Mob Construction** -- the Construction activity. The AI implements against the elaborated plan.

**The three AI-DLC phases** -- every project moves through **Inception** (understand and decompose), **Construction** (build), and **Operations** (deploy and run). Model them as three milestones per project.

**The loop** -- AI plans, AI asks clarifying questions, the **human validates business context**, then AI executes. This is the heartbeat of the method. The human validation step is not optional.

---

## The Fusion Mapping

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

Two notes on the mapping:

- **Bolts are labels, not sprint cycles.** Bolts run hours to days and cut across projects; tracker cycles floor at a week and are team-wide. A `bolt:N` label plus a target date models the cadence correctly.
- **Program streams** map to sub-initiatives where your tracker plan supports them. Where it does not, encode the stream as **project priority** instead -- the highest-risk stream gets Urgent/High.

---

## How to Run a Bolt

1. **Open and elaborate.** The lead role opens each issue in the Bolt and runs Mob Elaboration: decompose into sub-issues, list unknowns, draft clarifying questions.
2. **Validate with the human.** Bring the questions and any business, security, or policy decision to the human. Do not guess. Construction does not start until the context is validated.
3. **Construct.** Mob Construction: build against the elaborated plan, on a ticket branch, with SAFe commits, rebase-first.
4. **Verify the gates are real.** Run the actual checks and confirm they enforce. A green check that still masks a failure does not count.
5. **Demo and post evidence.** Show the outcome; post dev/staging/done evidence to the issue.
6. **Merge.** The RTE prepares the PR; the human (HITL) merges.

A Bolt exits only when its issues are **merged**, its **gates are real and green**, and **evidence is posted**. Nothing else is an exit.

---

## The Human-Gate Principle

Humans own business context; agents own the build.

An agent must **never guess** a business, security, or policy decision. It surfaces options with a recommendation and routes the choice to the human. Decisions that always go to the human:

- Which secrets to rotate, when, and the blast radius
- Security policy: CSP allow-list, auth behavior, headers
- Which CI checks become required, and branch-protection changes
- Dependency severity policy and the fix-versus-suppress budget
- Any exception to a documented SOP
- Signing the Definition of Done

When in doubt, ask. A two-minute question beats an hour of wrong construction.

---

## Worked Example: A Gate-Integrity Bolt

The clearest illustration is a Bolt whose whole job is to make the project's quality gates mean something. Suppose an audit found three defects: the lint rule skips the directory that most needs it, CI swallows failures behind `|| echo`, and the type check runs against a weakened config so it never blocks.

1. **Elaborate.** The architect opens all three issues. Mob Elaboration surfaces one real unknown: clearing the backlog of type errors could take many small fixes or a few blanket suppressions.
2. **Validate with the human.** That is a budget decision, not a code decision, so it routes to the human -- how many suppressions are acceptable versus real fixes? Construction on that issue waits for the answer.
3. **Construct in dependency order.** Shrink the lint ignores first, so the rule watches the right files. Then remove the CI masking, so failures actually surface. Only then make the type check block -- it can only meaningfully block once CI has stopped swallowing its result.
4. **Verify real.** Seed a type error and a lint violation into a scratch branch and confirm CI **fails**. That is proof the gate enforces rather than decorates.
5. **Evidence and merge.** Post the failing-then-passing CI runs to each issue; the RTE prepares the PRs; the human merges.

Only now is the Bolt complete -- and only now can later Bolts trust CI to verify their own work. This ordering is the whole point: **fix the gate before the fix it verifies.**

---

## Dependency-Wiring Rules

Wire `blocks` and `blockedBy` so the enforcement lands **before** the thing it enforces:

- **Fix the gate before the fix it verifies.** Harden CI or un-mask a check before landing the fix that check is supposed to catch.
- **Rotate before scrub.** Rotate a leaked credential before scrubbing it from history.
- **Capture before alert.** Error capture or a health check blocks the alerter built on top of it.
- **Upgrades before re-baseline.** Framework upgrades block audit re-baselining, which blocks the scheduled recurring scan.

Dependency chains are usually rooted at CI hardening. One keystone issue tends to unblock a whole stream -- identify it and sequence its Bolt first.

---

## When NOT to Use a Bolt

A Bolt is for work that can be elaborated and built inside a few days. It is the wrong tool when the work is genuinely large or uncertain -- an unclear problem space, a cross-cutting redesign, or a decision that needs research before it can even be decomposed.

For that, run a **spike**: a time-boxed investigation that produces a plan, not shippable code. Or plan a full increment across several Bolts.

Forcing an ambiguous epic into a single Bolt just relocates the ambiguity into the code. Elaborate first; **if elaboration itself is the hard part, that is a spike.**

---

## Related Reading

- [Program Template](../../specs_templates/program_template.md) - Scaffolding for a new program document
- [Round Table Philosophy](./ROUND-TABLE-PHILOSOPHY.md) - The collaboration model underneath the method
- [Agent Workflow SOP](../sop/AGENT_WORKFLOW_SOP.md) - Workflow methods and exit states
- [Agent Team Guide](./AGENT_TEAM_GUIDE.md) - Agent team structure and SAFe integration
- [CONTRIBUTING.md](../../CONTRIBUTING.md) - Git workflow and commit standards
- Skills: `safe-ai-dlc` (this method, encoded for agents), `linear-sop`, `safe-workflow`, `orchestration-patterns`

**External source**: [AI-Driven Development Life Cycle](https://aws.amazon.com/blogs/devops/ai-driven-development-life-cycle/) (AWS DevOps Blog)

---

**Questions?**

- GitHub Discussions: {{GITHUB_REPO_URL}}/discussions
- Email: {{AUTHOR_EMAIL}}
