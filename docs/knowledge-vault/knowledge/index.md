# Knowledge

Everything here is a **source-of-truth stub**. The knowledge itself lives in a document under
`docs/` or at the repository root; each concept below is a short map-card that says what that
document is authoritative for and points at it. The vault deliberately does not restate them —
duplicated prose drifts, and a stub that lies is worse than a link.

So the question this index answers is not "what is in `docs/`" but **"which document decides the
thing I am trying to do?"** They are grouped by that, not by directory.

## Adopting the harness for the first time

Roughly in the order you need them:

- [README](root-docs/readme.md) — the front door, and the only place several methodology contracts
  are written out in full
- [Getting Started](guides/getting-started.md) — the end-to-end path from first clone through first
  agent session and first PR
- [TEMPLATE_SETUP.md](root-docs/template-setup.md) — the placeholder inventory and post-setup
  checklist for turning the template into a real project
- [Agent Setup Guide](onboarding/agent-setup-guide.md) — install and verify the 11-agent system, and
  make the first invocation
- [Day 1 Checklist](onboarding/day-1-checklist.md) — the first day, clone through a validated
  workflow run
- [Meta-Prompts for Users](onboarding/meta-prompts-for-users.md) — copy-paste prompts that bootstrap
  setup, role selection, a first ticket, and troubleshooting
- [Workspace Adoption Guide](guides/workspace-adoption-guide.md) — adopting into an *existing*
  single- or multi-repo workspace, and keeping it updated afterwards
- [Optional Features Removal Guide](guides/optional-features.md) — removing shipped integrations you
  do not need, with post-removal verification

## Doing the daily work

- [Engineer Daily Workflow](onboarding/engineer-daily-workflow.md) — the FE/BE loop from morning
  sync to pre-PR validation
- [QAS Daily Workflow](onboarding/qas-daily-workflow.md) — the gate owner's loop: Testing swimlane,
  evidence posting, approval
- [CONTRIBUTING.md](root-docs/contributing.md) — authoritative git workflow, branch and commit
  format, PR process. Binds humans and agents identically.
- [Pre-PR Validation Checklist](sop/pre-pr-validation-checklist.md) — the blocking checklist before
  any PR opens, signed off on the ticket
- [Workflow Quality Checklist](workflow/workflow-quality-checklist.md) — the per-story checklist for
  validating that the workflow was actually followed
- [CI/CD Pipeline Guide](ci-cd/ci-cd-pipeline-guide.md) — branch protection and the rebase-first
  flow for multiple teams
- [CI/CD Documentation Index](ci-cd/ci-cd-readme.md) — the pipeline guide, related docs, and CI/CD
  agent owners

## Understanding the method and the roles

- [Round Table Philosophy (Doc)](guides/round-table-philosophy.md) — the collaboration model,
  stop-the-line authority, and the evidence requirements table
- [SAFe x AI-DLC Methodology](guides/safe-ai-dlc-methodology.md) — Bolts, Units of Work, mob
  elaboration, the human gate, dependency wiring
- [SAFe ART Agent Team Guide](guides/agent-team-guide.md) — the 11-agent structure, per-role
  workflows, escalation paths, session archaeology
- [Agent Workflow SOP v1.4](sop/agent-workflow-sop.md) — the four invocation methods plus the vNext
  contract, gates and role collapsing
- [Agent Configuration SOP](sop/agent-configuration-sop.md) — agent YAML frontmatter, per-role tool
  restrictions, model selection
- [Agent Teams Guide](onboarding/agent-teams-guide.md) — the experimental Agent Teams feature: team
  sizing, gate hooks, and token cost. Read the cost section before enabling it.
- [ARCHitect-in-CLI Role](workflow/architect-in-cli-role.md) — the technical authority in the
  workflow, and what that authority covers
- [TDM Agent Assignment Matrix](workflow/tdm-agent-assignment-matrix.md) — which work type routes to
  which role

## Writing database code

The RLS discipline is the strictest rule in the harness; these four documents define it.

- [Database Data Dictionary](database/data-dictionary.md) — declared single source of truth for
  schema context. Consult before any schema change.
- [RLS Implementation Guide](database/rls-implementation-guide.md) — how to implement Row Level
  Security in data-access code
- [RLS Policy Catalog](database/rls-policy-catalog.md) — the per-table policy enumeration
- [RLS Database Migration SOP](database/rls-database-migration-sop.md) — the procedure for
  RLS-safe migrations
- [Database Documentation Index](database/database-readme.md) — the index over the four above

## Security

- [SECURITY.md](root-docs/security.md) — the security policy, notably reframing risk for a
  prompt-and-config harness rather than an executable application
- [Security-First Architecture](security/security-first-architecture.md) — the architecture
  assessment and development standards
- [Security Documentation Index](security/security-readme.md) — the `docs/security` index

## Extending the harness

For authoring new agent-facing surfaces rather than using existing ones:

- [Skill Authoring Guide](guides/skill-authoring-guide.md) — creating and maintaining Claude Code
  skills, including Skills 2.0 frontmatter
- [Gemini CLI Authoring Guide](guides/gemini-cli-authoring-guide.md) — Gemini skills, TOML commands,
  hooks and multimodal features
- [CLAUDE.md](root-docs/claude-md.md) — the context file Claude Code loads automatically: commands,
  stack, and the pattern-discovery mandate
- [AGENTS.md](root-docs/agents.md) — the agent quick reference, and the file Codex CLI reads
  natively as its instruction surface
- [Planning Agent Meta-Prompt](misc/planning-agent-meta-prompt.md) — the meta-prompt driving the
  planning agent

## Workflow version history

Useful only when reconciling an older fork against current behaviour:

- [Workflow Changes v1.3](workflow/workflow-changes-v1-3.md) — the v1.3 change record and version
  history
- [Workflow Comparison v1.0-v1.2](workflow/workflow-comparison.md) — side-by-side across three
  versions
- [Workflow Migration Guide v1.0 to v1.1](workflow/workflow-migration-guide.md) — moving a team
  between versions

## Whitepapers and rationale

Argument rather than instruction — read when you need to justify the approach, not to follow it:

- [Whitepapers Index](whitepapers/whitepapers-readme.md) — the index of the five harness whitepapers
- [Anthropic Research Alignment](whitepapers/anthropic-research-alignment.md) — published Anthropic
  engineering insights mapped onto harness design
- [Harness Agent Perspective](whitepapers/harness-agent-perspective.md) — why the harness works from
  the agent's point of view
- [Iteration Patterns Comparative Analysis](whitepapers/iteration-patterns-comparative-analysis.md) —
  self-referential agent loops contrasted with SAFe multi-agent orchestration
- [Harness v2.5.0 Knowledge Transfer](whitepapers/harness-v2-5-0-kt.md) — the v2.5.0 note on Skills
  2.0 and Agent Teams
- [Harness Modernization KT Meta-Prompt](whitepapers/harness-kt-meta-prompt.md) — handing harness
  modernization to another ARCHitect

## Pointers and templates

- [Release Changelog Template](misc/release-changelog-template.md) — when and how the release
  changelog is written
- [docs/patterns Redirect](misc/patterns-redirect.md) — a stub redirecting an old path to
  [patterns/](../patterns/index.md)

## Related

- [Methodology](../methodology/index.md) — the reasoning these documents encode, reconstructed
- [Operations](../operations/index.md) — the CI and release machinery the checklists gate
