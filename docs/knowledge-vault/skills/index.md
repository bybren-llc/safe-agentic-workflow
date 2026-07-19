# Skills

Twenty model-invoked skills. Nobody types these — the model loads one when the work in front of it
matches the skill's trigger, which makes the trigger description the most important line in each
file. Skills carry procedure and standards; [commands](../commands/index.md) carry executable
workflows you invoke by name.

Grouped by the moment in the work where the model would reach for them.

## Before you write code

The gate skills. Two of these are mandatory pre-implementation steps, not suggestions.

- [pattern-discovery](pattern-discovery.md) — the mandatory search of `patterns_library` before any
  new feature code is written
- [spec-creation](spec-creation.md) — builds specs with pattern references, acceptance criteria,
  success-validation commands and a demo script

## Writing application code

Layer-specific implementation standards. Reach for the one matching the file you are in.

- [api-patterns](api-patterns.md) — API routes with RLS context wrappers, Zod validation, standard
  response shapes and error handling
- [frontend-patterns](frontend-patterns.md) — App Router server/client split, auth flows, component
  library and analytics events
- [rls-patterns](rls-patterns.md) — enforces `withUserContext` / `withAdminContext` /
  `withSystemContext`; forbids direct ORM calls
- [migration-patterns](migration-patterns.md) — migrations with mandatory RLS policies and GRANTs,
  gated on architect approval before production
- [stripe-patterns](stripe-patterns.md) — checkout, webhook and subscription flows with test-mode
  safety rules and evidence templates
- [testing-patterns](testing-patterns.md) — unit, integration and E2E conventions, fixtures,
  RLS-aware testing and evidence templates

## Shipping it

Everything between "code is written" and "it is running in production".

- [safe-workflow](safe-workflow.md) — branch naming, SAFe commit format, rebase-first workflow and
  the pre-PR checklist
- [git-advanced](git-advanced.md) — rebase, bisect, cherry-pick, conflict resolution and recovery,
  with force-push safety rules
- [release-patterns](release-patterns.md) — PR creation, pre-PR validation, CI status checks, merge
  strategy and the QAS pre-merge gate
- [deployment-sop](deployment-sop.md) — pre-deploy validation, smoke test, evidence template,
  rollback, and the branch-to-environment map
- [security-audit](security-audit.md) — RLS validation, OWASP Top 10 checklist, credential scanning
  and pre-deployment review

## Coordinating a team

For work that spans agents, tickets, or days.

- [agent-coordination](agent-coordination.md) — the assignment matrix, blocker escalation, the
  pre-implementation gate and TDM role boundaries
- [team-coordination](team-coordination.md) — Agent Teams orchestration: team creation, messaging,
  shared task lists, gate enforcement via dependencies
- [orchestration-patterns](orchestration-patterns.md) — the agent loop for long-running work:
  evidence-based delivery, QAS pre-merge gate, escalation
- [safe-ai-dlc](safe-ai-dlc.md) — program planning in Units of Work and Bolts, a dependency DAG, and
  a human-in-the-loop gate

## Recording it

Where work becomes durable — tickets, docs, and this vault.

- [linear-sop](linear-sop.md) — MCP tool usage, program structure, status workflow, and evidence
  templates for dev, staging and done
- [confluence-docs](confluence-docs.md) — templates for ADRs, runbooks, architecture and
  knowledge-transfer docs, plus where each output belongs
- [vault-sync](vault-sync.md) — detects and repairs drift between this vault and the code it
  describes, gated by the validator

## Related

- [Commands](../commands/index.md) — the invoked counterpart: you type those, the model picks these
- [Roles](../roles/index.md) — which role reaches for which skill
- [Providers](../providers/index.md) — how skills are surfaced per tool, including the portable
  `.agents/skills` convention
- [Vault root](../index.md)
