# Methodology

This is the institutional knowledge — the twelve ideas that explain *why* the harness behaves the
way it does. They are here because **no single source file states them**. Each one was reconstructed
from agent prompts, hook scripts, README passages and SOPs that each encode a fragment. Delete this
directory and the reasoning is not lost so much as scattered back into the places it was inferred
from.

If an agent has just refused to proceed, blocked a merge, or demanded evidence you thought was
unnecessary, the explanation is almost certainly one of these twelve.

## Start here

- [Round Table Philosophy](round-table-philosophy.md) — human and AI contributors as peers with
  equal voice and real authority in their domains. Every other idea assumes this one.
- [vNext Workflow Contract](vnext-workflow-contract.md) — the v1.4 delivery contract end to end: BSA
  spec, stop-the-line gate, implementers, QAS gate, RTE shepherd, three-stage review, human merge.
  The single most useful concept if you read only one.
- [Three-Layer Architecture](three-layer-architecture.md) — hooks are automatic guardrails, commands
  are user-invoked workflows, skills are model-invoked expertise. The taxonomy the whole harness is
  filed under.

## Gates and authority

Where work stops, and who is allowed to stop it. This is the cluster people most often misread:

- [Stop-the-Line Gate and Authority](stop-the-line-gate.md) — two distinct mechanisms share one
  name: a mandatory AC/DoD precondition gate, and every agent's Andon-cord right to halt work. Read
  this before assuming which one someone meant.
- [Three-Stage PR Review](three-stage-pr-review.md) — System Architect pattern review, then
  ARCHitect-in-CLI architecture review, then human HITL review. **Only the human may merge.**
- [Evidence-Based Delivery](evidence-based-delivery.md) — nothing advances on assertion. Every
  deliverable carries verifiable evidence attached to the tracker before a human looks at it. This
  is the currency the gates are denominated in.
- [Exit States and Handoff Statements](exit-states.md) — each role terminates in a named exit state
  plus a handoff statement, which is what makes the chain of custody between agents auditable

## Cadence and team shape

- [SAFe x AI-DLC Program Cadence](safe-ai-dlc.md) — SAFe keeps the hierarchy and the gates, while
  AWS AI-DLC contributes the **Bolt**: an hours-to-days swarm that exits on evidence. Note carefully
  that the Bolt is offered as an **alternative cadence alongside sprints, not a replacement for
  them** — a program may run either, and the gates are identical in both.
- [Role Collapsing and Independence Gates](role-collapsing.md) — which roles may merge into the
  implementer for small work, and which are independence gates that never collapse no matter how
  small the change
- [Domain Adaptation Beyond Software](domain-adaptation.md) — the same roles, gates and artifacts
  mapped onto marketing, research, legal and operations teams

## Working rules

- [Pattern Discovery Protocol](pattern-discovery-protocol.md) — the mandatory search of the pattern
  library, specs, codebase and session history before writing any new implementation. See
  [patterns/](../patterns/index.md) for what that search covers.
- [Harness Sync and Fork Workflow](harness-sync-and-fork-workflow.md) — the human procedure for
  pulling upstream releases into a fork without losing customizations, including the rollback path.
  The tooling is in [sync/](../sync/index.md).

## Related

- [Methodology domain](../domains/methodology.md) — the cross-cutting view
- [Round Table Philosophy (Doc)](../knowledge/guides/round-table-philosophy.md) — the
  source-of-truth document, including the evidence requirements table
- [SAFe x AI-DLC Methodology](../knowledge/guides/safe-ai-dlc-methodology.md) — the authoritative
  definition of Bolts, Units of Work and the human gate
- [Agent Workflow SOP v1.4](../knowledge/sop/agent-workflow-sop.md) — the procedural form of the
  vNext contract
- [Roles](../roles/index.md) — the eleven agents these rules govern
