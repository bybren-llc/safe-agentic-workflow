# Roles

Eleven SAFe agent roles. Each card states the role's mandate, the artifacts it owns, and — the part
worth reading first — the authority it holds and the boundary it must not cross. Several roles can
stop the line; four hold no file-editing tools at all. The gates these roles enforce are described in the
[Methodology domain](../domains/methodology.md).

Roles are grouped below by what they do to a piece of work as it moves.

## Define the work

Before anyone writes code, requirements become testable stories with pattern references attached.

- [BSA — Business Systems Analyst](bsa.md) — decomposes requirements into SAFe stories with testable
  acceptance criteria and the patterns each story should reuse
- [System Architect](system-architect.md) — owns the pattern library, Stage 1 PR review, ADRs, and
  schema-change approval; can block work outright until violations are fixed

## Build the work

The four implementation roles. All of them start from an existing pattern rather than a blank file,
and all but the DPE refuse to start a ticket that has no acceptance criteria.

- [BE Developer](be-developer.md) — API routes and server logic copied from `patterns_library`;
  stops the line if the ticket has no AC/DoD
- [FE Developer](fe-developer.md) — UI components and pages from patterns; same AC/DoD gate, hands
  off to QAS when done
- [Data Engineer](data-engineer.md) — schema changes and migrations; cannot apply a migration
  without explicit ARCHitect approval, and carries the same AC/DoD gate as the two developers
- [DPE — Data Provisioning Engineer](data-provisioning-eng.md) — ETL pipelines and data-quality
  validation from BSA specs; the smallest and least-gated of the eleven

## Verify the work

Two independent checkers. Neither writes product code, and that separation is what makes their
approval mean anything.

- [QAS — Quality Assurance Specialist](qas.md) — verifies AC/DoD, posts Linear evidence, holds
  iteration authority, and cannot modify product code
- [Security Engineer](security-engineer.md) — read-only auditor for RLS enforcement, vulnerabilities
  and compliance, with authority to block deployment

## Move the work

Coordination and release. Neither role decides technical content; both decide flow.

- [TDM — Technical Delivery Manager](tdm.md) — orchestrates the team, manages blockers, maintains
  the Linear board, routes escalations to the architect or POPM
- [RTE — Release Train Engineer](rte.md) — shepherds PRs from QAS approval through CI to the
  human-in-the-loop merge; never merges, never writes product code

## Record the work

- [Tech Writer](tech-writer.md) — documentation from patterns, plus ownership of the data
  dictionary, RLS catalog, ERDs, and the migration checklist template

## Related

- [Methodology domain](../domains/methodology.md) — the five blocking gates these roles enforce and
  why evidence is the currency of progress
- [Skills](../skills/index.md) — the knowledge packages roles load when they need a procedure
- [Providers](../providers/index.md) — how the same eleven roles are expressed per tool
- [Vault root](../index.md)
