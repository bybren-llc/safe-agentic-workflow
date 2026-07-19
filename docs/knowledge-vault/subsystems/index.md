# Subsystems

Most of this harness is prompts and configuration spread thinly across provider directories. The
five subsystems are the exception: each is a **self-contained unit that ships and is reasoned about
as a whole**, with its own scripts, its own docs, and its own failure modes. If you are trying to
understand one of them, you want its concept and its sub-tree — not a tour of the whole vault.

## The five

- [Dark Factory](dark-factory.md) — the largest by far: a tmux subsystem that runs persistent SAFe
  agent teams on a headless machine. Detailed below.
- [Pattern Library](pattern-library.md) — eighteen reference implementations in seven categories,
  distributed to adopters rather than executed here. See [patterns/](../patterns/index.md) for the
  implementations themselves.
- [Spec Templates](spec-templates.md) — the four planning scaffolds that make the workflow
  spec-first. Detailed below.
- [Linting Configs](linting.md) — shipped ESLint and Prettier configs whose `no-restricted-syntax`
  rules machine-enforce the RLS discipline. The interesting claim: a convention nobody checks is a
  wish, and this is where several conventions stop being wishes.
- [Knowledge Vault Subsystem](knowledge-vault.md) — OKF v0.1 tooling: a zero-dependency structural
  validator, gate tests, a starter bundle, and the build prompts. This vault is its output.

## Dark Factory

Thirteen concepts, no index of its own. Read them in this order — setup, then layouts, then the
operational scripts, because the scripts make little sense until you know what a team layout is.

**Understand it first.**

- [Dark Factory](dark-factory.md) — what the subsystem is and why persistent agent teams need it
- [Dark Factory Runtime Topology](dark-factory/tmux-topology.md) — the tmux, filesystem and
  environment-key surface a running session actually occupies. The mental model everything else
  assumes.
- [Dark Factory Guide](dark-factory/operations-guide.md) — the comprehensive setup, worktree,
  logging and troubleshooting reference for the Claude Code factory

**Team layouts** — three sizes, differing in how many roles are worth paying for:

- [Story Team Layout](dark-factory/story-team-layout.md) — three panes: TDM lead, BE Developer, QAS
- [Feature Team Layout](dark-factory/feature-team-layout.md) — five panes: TDM plus BE, FE, QAS, RTE
- [Epic Team Layout](dark-factory/epic-team-layout.md) — nine panes, the full SAFe team under a TDM

**The lifecycle scripts** — one per verb, and they run in this order:

- [factory-setup.sh](dark-factory/factory-setup.md) — one-time: checks tools, creates
  `~/.dark-factory`, and gates on the merge queue being configured
- [factory-start.sh](dark-factory/factory-start.md) — creates the session, optional per-agent
  worktrees, applies a layout, pipes pane logs
- [factory-status.sh](dark-factory/factory-status.md) — the dashboard that classifies each pane as
  active, idle or dead. The one you run most.
- [factory-attach.sh](dark-factory/factory-attach.md) — lists sessions and panes, or attaches you to
  one to intervene
- [factory-stop.sh](dark-factory/factory-stop.md) — interrupts panes, kills the session, removes
  worktrees, archives per-agent logs

**Policy and access** — how work leaves the factory, and how a human gets in:

- [Merge Queue Policy](dark-factory/merge-queue-policy.md) — the single-path-to-trunk rule, enforced
  by GitHub ruleset rather than by client-side flags. Read this before wondering why a push was
  rejected.
- [Cursor SSH Guide](dark-factory/cursor-ssh-guide.md) — Remote-SSH into a running factory to
  observe or intervene
- [Codex Dark Factory Guide](dark-factory/codex-guide.md) — the window-based Codex CLI variant, which
  depends on a third-party auto-approval daemon

## Spec templates

Four scaffolds, ordered widest to narrowest by the scope of work they plan:

- [PI Planning Template](spec-templates/pi-planning-template.md) — a full Program Increment: program
  board, dependencies, ROAM risks, gates
- [Program Template](spec-templates/program-template.md) — a SAFe x AI-DLC program decomposed into
  Units of Work and sequenced Bolts
- [Planning Template](spec-templates/planning-template.md) — the BSA scaffold that breaks an
  initiative into Epic, Feature, Story and Enabler
- [Spec Template](spec-templates/spec-template.md) — one story: acceptance criteria, pattern
  references, testing plan. The per-ticket workhorse.

## Related

- [Subsystems domain](../domains/subsystems.md) — the cross-cutting view
- [Patterns](../patterns/index.md) — the pattern library's eighteen implementations
- [Operations](../operations/index.md) — the scripts and CI that run the harness day to day
