# Domains

Everywhere else in this vault, the directory tells you **where something lives**: a command is under
`commands/`, a Cursor rule under `providers/`, a CI workflow under `operations/`. That is a useful
filing system and a poor explanation, because the answer to "how does deployment actually work here"
is spread across four directories and no single file.

Domains are the other axis. Each of the five is a semantic cross-cut that answers **how does X work
here** by pulling together the concepts that participate in it, regardless of which structural
directory they were filed under. Read a domain when you want understanding; read a structural index
when you already know what you are looking for and need to find it.

Every concept in this vault carries exactly one `domain` in its frontmatter, so these five partition
the whole set. The [by-domain view](../bases/by-domain.base) regroups the vault along this axis.

## The five domains

- [Methodology](methodology.md) — how work is decided and approved: the SAFe plus AI-DLC method,
  eleven roles, five blocking gates, and evidence as the currency of progress. Start here if you
  want to know why an agent refused to proceed.
- [Providers](providers.md) — how one methodology reaches five different AI tools: what each surface
  expresses natively and, more usefully, where parity between them breaks.
- [Subsystems](subsystems.md) — the self-contained units the harness ships as units: the dark
  factory, the pattern library, spec templates, linting, and this vault itself.
- [Operations](operations.md) — how the harness is run day to day: four CI workflows, the release
  gate, maintenance scripts and the commands that drive them.
- [Sync](sync.md) — how a fork pulls upstream harness releases without losing its own edits: the
  sync engine, the manifest it reads, and the tests that keep it honest.

## Where to go instead

If you know the shape of the thing you want, the structural indexes are faster:

| You want | Go to |
| --- | --- |
| A specific tool's directory layout | [providers/](../providers/index.md) |
| What an agent role may and may not do | [roles/](../roles/index.md) |
| A procedure the model loads on its own | [skills/](../skills/index.md) |
| A workflow you invoke by name | [commands/](../commands/index.md) |
| Reusable implementation code | [patterns/](../patterns/index.md) |
| CI, environments, runbooks | [operations/](../operations/index.md) |

## Related

- [Vault root](../index.md) — both doors, and what `verified_against` means
- [Conventions](../_meta/CONVENTIONS.md) — the controlled domain vocabulary is defined there
