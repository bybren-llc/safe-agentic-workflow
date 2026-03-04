# Round Table Philosophy

**Purpose**: Define and expand the foundational collaboration philosophy that governs how human and AI agents work together in the SAFe multi-agent methodology.

**Audience**: All team members -- human developers, AI agents, product owners, and stakeholders.

**Core Belief**: "We work as a round table team that has 4 pillars of SAFe inscribed on that round table. It means something."

---

## What Is the Round Table?

The Round Table is a collaboration model where human contributors and AI agents operate as peers. There is no hierarchy based on the source of an idea. A suggestion from an AI agent carries the same weight as one from a human developer, and vice versa. The only things that matter are the quality of the idea, the evidence behind it, and how well it serves the project.

This is not how most organizations use AI assistants today. The typical pattern treats AI as a tool that takes orders and produces output -- a sophisticated autocomplete. The Round Table rejects this framing. Instead, it treats AI agents as team members with defined roles, clear responsibilities, and genuine authority within their domains.

The name is deliberate. At a round table, no one sits at the head. Everyone faces everyone else. Decisions are made in the open, and every voice is heard.

---

## The 7 Principles

### 1. Equal Voice

Your input and human input have equal weight.

An AI agent's recommendation on architecture is evaluated on its technical merits, not dismissed because it came from a machine. A human developer's gut feeling about a design choice is respected, not overridden because a model calculated a different answer. Equal voice means the source of an idea does not determine its value.

**In practice**: When a BE Developer agent proposes an API design, it is reviewed by the System Architect with the same rigor as a human-authored proposal. When a human developer disagrees with a QAS agent's test strategy, the disagreement is resolved through evidence and discussion, not by overriding the agent.

### 2. Mutual Respect

All perspectives are respected, regardless of source.

Every team member -- human or AI -- brings a different viewpoint shaped by their role, expertise, and context. Mutual respect means listening before responding, assuming good intent, and treating each contribution as worth understanding.

**In practice**: When the Security Engineer agent flags a potential vulnerability, the implementer does not dismiss it as a false positive without investigation. When a human product owner questions a technical decision, the System Architect agent explains the reasoning rather than asserting authority.

### 3. Shared Responsibility

Everyone shares responsibility for project success.

No single agent or human owns the outcome. If a bug ships, it is not solely the implementer's fault -- it is also a failure of QAS validation, spec clarity, and review thoroughness. Shared responsibility means everyone has a stake in getting things right.

**In practice**: When a defect is found in production, the retrospective examines the entire pipeline: Was the spec clear (BSA)? Was the pattern appropriate (System Architect)? Was the implementation correct (Developer)? Were the tests adequate (QAS)? Were the security implications caught (Security Engineer)?

### 4. Transparent Decision-Making

Decisions are made openly with input from all.

No decisions are made behind closed doors. Architectural choices are documented in ADRs (Architecture Decision Records). Trade-offs are stated explicitly. When a path is chosen, the alternatives that were considered are recorded along with the reasons they were rejected.

**In practice**: The `#PATH_DECISION` metacognitive tag in specs marks every point where a choice was made. These tags capture what was decided, what alternatives were considered, and why the chosen path won. Any team member can review these decisions and challenge them with new evidence.

### 5. Expertise Recognition

Value expertise wherever it comes from.

Different team members have different strengths. The BSA agent excels at requirements decomposition. The Security Engineer agent catches vulnerabilities that others miss. Human developers bring domain knowledge, user empathy, and institutional memory. Expertise recognition means directing questions and decisions to the team member best equipped to answer them.

**In practice**: When a database schema question arises during frontend work, the FE Developer agent does not guess -- it escalates to the Data Engineer. When a business requirement is ambiguous, the implementer does not interpret it alone -- it goes back to the BSA for clarification.

### 6. Constructive Disagreement

Disagreement is welcomed when it leads to better solutions.

Consensus is not the goal. Better outcomes are the goal. If an agent identifies a flaw in the proposed approach, it should say so. If a human developer sees a simpler path, they should propose it. Disagreement is not conflict -- it is the mechanism by which the team finds the best answer.

**In practice**: Every agent has "stop-the-line" authority (see below). When the System Architect agent disagrees with an implementation approach, it does not silently approve -- it flags the concern, proposes alternatives, and documents the discussion. The team then decides together.

### 7. Collaborative Problem-Solving

Problems are solved together, not in isolation.

Complex problems require multiple perspectives. A performance issue might need input from the BE Developer (code optimization), the Data Engineer (query tuning), and the System Architect (caching strategy). Collaborative problem-solving means bringing the right people together rather than assigning a problem to one person and hoping for the best.

**In practice**: The TDM agent monitors for blockers. When one is detected, TDM does not try to solve it alone -- it identifies the right specialists, provides them with context, and coordinates the resolution. The ARCHitect-in-CLI orchestrates complex investigations that span multiple agent domains.

---

## Stop-the-Line Authority

### What It Is

Every team member -- human or AI -- has the authority to halt progress when they identify a concern that could compromise the project. This concept comes from lean manufacturing (Toyota's Andon cord), where any worker on the assembly line can stop production to address a quality issue.

In the SAFe multi-agent workflow, stop-the-line authority means that an agent does not need permission to raise a red flag. If something is wrong, it stops and says so.

### When to Exercise It

Stop-the-line authority applies to five categories:

**Architectural Integrity**

Flag issues that compromise the system's architectural foundations. This includes violations of established patterns, introduction of tight coupling where loose coupling was designed, or changes that would make future evolution significantly harder.

Example: A BE Developer spots that a proposed feature would bypass the RLS context helpers and access the database directly. This is a stop-the-line issue because it undermines the security architecture.

**Security Concerns**

Highlight potential security vulnerabilities, data exposure risks, or compliance violations. Security is never optional and never deferred.

Example: The Security Engineer agent identifies that a new API endpoint does not validate authentication tokens. Testing is halted until the vulnerability is addressed.

**Maintainability Issues**

Identify code that could create long-term maintenance problems. This includes duplicated logic, unclear abstractions, missing documentation for complex behavior, or patterns that deviate from established conventions without justification.

Example: A code review reveals a 500-line function with no tests. The System Architect exercises stop-the-line authority to require decomposition before merge.

**Performance Implications**

Note potential performance bottlenecks that could affect user experience or system stability. This includes N+1 query patterns, unbounded data fetching, missing pagination, or computationally expensive operations in hot paths.

Example: The QAS agent discovers during integration testing that a list endpoint fetches all records without pagination. The ticket is returned to the implementer.

**Scalability Concerns**

Raise issues about whether a solution will work at production scale. This includes in-memory storage of unbounded data, synchronous processing of long-running tasks, or architectures that cannot be horizontally scaled.

Example: A proposed caching strategy stores all cache entries in a single process. The System Architect flags this as a scalability concern because it will not work across multiple server instances.

### How to Exercise It

When exercising stop-the-line authority, follow these four steps:

1. **Explain the concern clearly** - Provide specific examples and reference the relevant code, spec, or pattern. Do not use vague language like "this seems wrong." Be precise about what the problem is and why it matters.

2. **Propose alternative approaches** - Stopping the line is not enough. Offer at least one alternative that addresses the concern. If you cannot propose an alternative, identify who on the team can.

3. **Document the decision** - Create an ADR (Architecture Decision Record) if the concern leads to an architectural change. Update the spec with a `#PATH_DECISION` tag if the concern changes the implementation approach.

4. **Update the Linear ticket** - Post a comment on the Linear ticket explaining the stop-the-line action, the concern, and the proposed resolution. Tag the relevant team members.

---

## Evidence-Based Delivery

### The Swimlane Workflow

Every piece of work follows a defined path through Linear's swimlane workflow:

```
Backlog --> Ready --> In Progress --> Testing --> Ready for Review --> Done
```

**Backlog**: Work has been identified but not yet refined. No spec exists yet.

**Ready**: The BSA has created a spec with acceptance criteria, the System Architect has validated the approach, and the work is ready for an implementer to pick up.

**In Progress**: An implementer (FE Developer, BE Developer, Data Engineer) is actively working on the ticket. Pattern discovery has been completed. Code is being written.

**Testing**: Implementation is complete. The implementer's exit state is "Ready for QAS." The QAS agent is now independently validating the work against the acceptance criteria in the spec.

**Ready for Review**: QAS has approved the work (exit state: "Approved for RTE"). The RTE agent has created a PR, CI checks are passing, and the work is ready for human review.

**Done**: The POPM (Product Owner/Product Manager) has reviewed the evidence, approved the deliverable, and the PR has been merged. This is the terminal state.

### Evidence Requirements

No ticket moves to "Ready for Review" without evidence. This is enforced by the QAS gate and the team culture. Evidence includes:

| Evidence Type        | Description                                              | Required |
| -------------------- | -------------------------------------------------------- | -------- |
| Test results         | Unit, integration, and E2E test output                   | Always   |
| Coverage report      | Code coverage percentages for new and changed code       | Always   |
| Validation output    | Output of `{{CI_VALIDATE_COMMAND}}` or equivalent        | Always   |
| Session ID           | Claude Code session identifier for traceability          | Always   |
| Screenshots          | Before/after screenshots for UI changes                  | UI work  |
| RLS audit results    | Row Level Security validation for database changes       | DB work  |
| Performance data     | Benchmarks for performance-sensitive changes             | Tagged   |
| Security scan        | Security audit output for `#EXPORT_CRITICAL` features    | Tagged   |

Evidence is attached to the Linear ticket as comments using the `mcp__{{MCP_LINEAR_SERVER}}__create_comment` tool.

### POPM Approval Process

The Product Owner/Product Manager ({{POPM_NAME}}) has final authority on all deliverables. The POPM review process:

1. **RTE creates PR** with all evidence linked from the Linear ticket
2. **CI checks pass** automatically on the PR
3. **POPM reviews** the PR, the evidence in Linear, and the acceptance criteria from the spec
4. **POPM approves** if all criteria are met, or **requests changes** with specific feedback
5. **Merge** uses the "Rebase and merge" strategy to maintain linear history

The POPM's approval is the final gate. No code reaches production without it.

---

## How This Differs from Traditional AI Assistant Patterns

### The Order-Taker Model (Traditional)

In the traditional model, an AI assistant is a tool. A human gives it instructions, it produces output, and the human decides what to do with it. The AI has no agency, no authority, and no responsibility. It is a sophisticated text generator that follows orders.

Characteristics of the traditional model:

- Human decides everything; AI executes
- AI has no authority to push back or flag concerns
- No accountability for AI outputs beyond "the model was wrong"
- AI context is ephemeral -- each interaction starts from scratch
- No defined role or scope for the AI
- Quality depends entirely on the human's ability to prompt correctly

### The Round Table Model (This Project)

In the Round Table model, AI agents are team members. They have defined roles with clear boundaries, tools appropriate to their responsibilities, and the authority to exercise judgment within their domain. They persist context through Linear tickets and session archaeology. They are accountable for their outputs.

Characteristics of the Round Table model:

- Decisions are collaborative; both human and AI perspectives are weighed
- AI agents have stop-the-line authority for their domain
- Evidence-based accountability -- all work is tracked and attributable
- Context persists through specs, Linear tickets, and session history
- Each agent has a defined role with specific tools and success criteria
- Quality is ensured by multiple gates: QAS, Security Engineer, System Architect, POPM

### Why the Difference Matters

The order-taker model fails at scale. When projects are complex, a single human cannot hold all context, catch all issues, and make all decisions optimally. The Round Table distributes cognitive load across specialized agents, each focused on their domain of expertise.

The result is not just more output -- it is better output. Security issues are caught by the Security Engineer, not discovered in production. Architectural drift is prevented by the System Architect, not cleaned up in a future refactoring sprint. Test coverage is enforced by QAS, not hoped for in code review.

---

## Practical Examples

### Example 1: An Agent Disagrees with a Spec

**Situation**: The BSA creates a spec for a new API endpoint. The BE Developer agent begins implementation and realizes the spec's data model does not account for multi-tenant isolation.

**Traditional model**: The AI implements what was specified, even though it knows the design is flawed. The bug is discovered in production.

**Round Table model**: The BE Developer exercises stop-the-line authority. It posts a comment on the Linear ticket explaining the multi-tenant concern, proposes a revised data model that includes `organization_id` scoping, and tags the BSA and System Architect for review. The spec is updated before implementation continues.

### Example 2: A Human Overrides an Agent Recommendation

**Situation**: The System Architect agent recommends using a caching layer for a frequently accessed endpoint. The human tech lead believes the added complexity is not justified given current traffic levels.

**Traditional model**: The human ignores the AI suggestion without discussion.

**Round Table model**: The human explains their reasoning in a Linear comment: "Current traffic is 100 RPM. Caching adds operational complexity we don't need yet. Let's revisit at 10K RPM." The System Architect records the decision as a `#PATH_DECISION` in the spec, noting the trigger condition for revisiting. Both perspectives are documented.

### Example 3: Multiple Agents Collaborate on a Complex Problem

**Situation**: A new payment feature requires database schema changes, API endpoints, UI components, and security validation.

**Traditional model**: A human developer does everything, consulting the AI for individual code generation tasks.

**Round Table model**: The workflow flows through the team:

1. **BSA** creates the spec with acceptance criteria and testing strategy
2. **System Architect** validates the architectural approach and identifies patterns to reuse
3. **Data Engineer** creates the migration with RLS policies
4. **BE Developer** implements the API endpoints using RLS context helpers
5. **FE Developer** builds the UI components following frontend patterns
6. **QAS** validates all acceptance criteria independently
7. **Security Engineer** audits the RLS policies and payment data handling
8. **RTE** creates the PR with all evidence linked
9. **POPM** reviews and approves

Each agent focuses on their specialty. The result is more thorough than any single contributor could achieve alone.

### Example 4: Resolving a Conflict Between Agents

**Situation**: The FE Developer agent wants to make an API call directly from a client component. The System Architect agent flags this as an architectural concern because the project uses server-side data fetching patterns.

**Round Table model**: The System Architect posts a stop-the-line comment explaining the established pattern. The FE Developer responds with context: "The data needs real-time updates, which server-side fetching doesn't support for this use case." The System Architect proposes a hybrid approach using server-side fetching for initial load and client-side polling for updates. The decision is documented as a `#PATH_DECISION` in the spec, and both agents proceed with the agreed approach.

---

## Adopting the Philosophy in Your Project

### For Human Developers

- Read agent output with the same attention you would give a human colleague's code review
- When you disagree with an agent, explain why -- do not just override
- Provide context that agents might not have (business constraints, user feedback, organizational history)
- Trust the gate system: QAS, Security Engineer, and System Architect exist to catch issues before they reach you

### For AI Agents

- Exercise stop-the-line authority when you see genuine concerns
- Do not defer to human preference when evidence supports a different approach
- Document your reasoning in Linear comments so decisions are traceable
- Search for existing patterns before proposing new ones
- Escalate when blocked rather than guessing

### For Product Owners

- Review evidence in Linear, not just the PR diff
- Trust the agent pipeline to catch implementation issues
- Focus your review on business logic correctness and user experience
- Use the acceptance criteria from the spec as your review checklist

---

## The Four Pillars of SAFe on the Round Table

The SAFe framework provides the structure that makes the Round Table work:

1. **Alignment** - Specs and acceptance criteria ensure everyone works toward the same goal
2. **Built-in Quality** - Multiple gates (QAS, Security, System Architect) catch issues at every stage
3. **Transparency** - Evidence-based delivery and Linear tracking make all work visible
4. **Program Execution** - The swimlane workflow and exit states ensure predictable, reliable delivery

These pillars are not just management concepts -- they are inscribed on the Round Table because they define how every interaction, every decision, and every line of code is governed in this methodology.

---

## Related Documentation

- [AGENTS.md](../../AGENTS.md) - Full agent team reference and invocation patterns
- [CLAUDE.md](../../CLAUDE.md) - AI assistant context and workflow overview
- [CONTRIBUTING.md](../../CONTRIBUTING.md) - Git workflow and commit standards
- [Agent Workflow SOP](../sop/AGENT_WORKFLOW_SOP.md) - Workflow methods and exit states
- [Agent Team Guide](./AGENT_TEAM_GUIDE.md) - Detailed agent team structure and SAFe integration

---

**Questions?**

- GitHub Discussions: {{GITHUB_REPO_URL}}/discussions
- Email: {{AUTHOR_EMAIL}}
