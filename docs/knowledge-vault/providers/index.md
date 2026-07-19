# Providers

The harness is one methodology shipped to five AI-tool surfaces. Each surface expresses what its tool
can express natively, which means the same rule can be a hook in one, a rule file in another, and a
paragraph of prose in a third. This section is the *where* — which directory carries what. For the
*why* and where parity breaks, read the [Providers domain](../domains/providers.md).

## The five surfaces

Start here. Each card inventories one provider directory: what it contains, what the tool loads
automatically, and what it silently ignores.

- [Claude Code](claude-code.md) — the richest surface and the reference implementation: 11 agent
  prompts, 24 slash commands, 20 skills, inline hooks config, settings template
- [Gemini CLI](gemini-cli.md) — the widest command surface: 30 TOML commands across four namespaces,
  including the media commands no other provider has
- [Codex CLI](codex.md) — config-driven: profiles and MCP servers in `config.toml`, 11 role TOMLs,
  and skills delegated outward to `.agents/skills`
- [Cursor IDE](cursor.md) — rules-driven: 18 `.mdc` files in four numbering families, loaded by
  always-apply, glob match, or manual invocation
- [Portable `.agents` skills](agents-portable.md) — the vendor-neutral surface, 20 skill packages
  that any tool honoring the convention can discover

Read this one to understand how the surfaces are generated and kept in step at all:

- [`agent_providers` legacy mirror](agent-providers.md) — the pre-dotfile directory: an Augment
  starter kit plus a diverged, unsynced copy of the Claude harness. Useful mostly as a warning.

## Cursor rule families

Cursor rules are not one flat list — the leading number decides *when* the rule loads, and that is
the only thing that matters when you are debugging why a rule did or did not fire.

- [Core family (00-02)](rules/core.md) — always-apply: SAFe principles, git workflow, and the
  mandatory pattern-discovery rule. These load on every request.
- [Stack family (10-16)](rules/stack.md) — glob auto-attached: seven rules that wake up when a
  backend, frontend, database, test, spec, deploy, or payment file is open
- [Methodology family (03-04)](rules/methodology.md) — manual only: SAFe x AI-DLC program cadence
  and the OKF knowledge-vault conventions
- [Agent and background family (20-31)](rules/agent-and-background.md) — manual only: four SAFe
  agent personas plus background-agent and MCP integration guidance

## Hooks

Three shell hooks in the Claude surface. Read these before you assume anything is *enforced* —
each one is advisory, and each card says exactly what it does not do.

- [`session-start-pattern-check.sh`](hooks/session-start-pattern-check.md) — prints the pattern
  inventory and agent banner at session start; points at `docs/patterns`, not `patterns_library`
- [`pre-bash-rls-validation.sh`](hooks/pre-bash-rls-validation.md) — warns when a Prisma or psql
  command carries no RLS context helper; blocks nothing
- [`post-commit-linear-update.sh`](hooks/post-commit-linear-update.md) — extracts a ticket ID from
  the commit message and prints a suggested comment; never calls Linear

## Augment rules

Six rule slots, and the split between them is the point: two carry content, four are empty stubs on
disk. Do not assume a slot's name means the rule exists.

Populated:

- [Project Guidelines](augment/project-guidelines.md) — the largest Augment rule: SAFe Essentials
  project context and development guidelines
- [Review Checklist](augment/review-checklist.md) — seven review gates from pre-implementation
  through post-deployment

Empty 4-byte stubs — the slot is reserved, the guidance is not written:

- [Coding Standards](augment/coding-standards.md) — code quality and style slot
- [CONTRIBUTING](augment/contributing.md) — git workflow and contribution standards slot
- [Confluence Standards](augment/confluence-standards.md) — documentation standards slot
- [Linear API SOP](augment/linear-api-sop.md) — Linear integration guidelines slot

## Related

- [Providers domain](../domains/providers.md) — the semantic view: what each tool can express and
  where parity between surfaces breaks
- [Roles](../roles/index.md), [Skills](../skills/index.md), [Commands](../commands/index.md) — the
  payloads every surface carries, described once instead of five times
- [Vault root](../index.md)
