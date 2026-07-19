---
type: domain
title: "Subsystems Domain"
description: "The self-contained units the harness ships: dark factory, patterns, spec templates, linting, this vault."
tags: [subsystems, patterns, orchestration, testing, okf]
timestamp: 2026-07-19
status: active
domain: subsystems
verified_against: "fd0fc6a"
---

# Subsystems Domain

Parts of the repo that would still make sense lifted out of it, and are shipped by copy, not run.

## Overview

Owns five shipped units: the Dark Factory tmux runtime, the pattern library, the spec templates, the
linting configs, and the vault tooling. It stops at the artifact — the discipline a pattern encodes
belongs to [Methodology](methodology.md), the CI that would run a config to
[Operations](operations.md), the surfaces routing agents here to [Providers](providers.md).

## Members

- [Pattern Library](../subsystems/pattern-library.md) — 18 exemplars in 7 categories; documentation,
  not code, since nothing in the repo imports them.
- [Spec Templates](../subsystems/spec-templates.md) — five SAFe artifacts including the
  [spec template](../subsystems/spec-templates/spec-template.md); two placeholder dialects coexist.
- [Linting Configs](../subsystems/linting.md) — the only member with teeth: `no-restricted-syntax`
  turns the RLS discipline into an error, though the packages it extends are not installed here.
- [Dark Factory](../subsystems/dark-factory.md) — persistent tmux agent teams, with its
  [topology](../subsystems/dark-factory/tmux-topology.md),
  [merge queue policy](../subsystems/dark-factory/merge-queue-policy.md),
  [setup](../subsystems/dark-factory/factory-setup.md), [start](../subsystems/dark-factory/factory-start.md).
- [Knowledge Vault](../subsystems/knowledge-vault.md) — the OKF validator gating this bundle, and
  [apply-workflow](../operations/scripts/apply-workflow.md), which distributes three of the five.

## Key Flows

**A pattern reaching code.** An agent runs [pattern-discovery](../skills/pattern-discovery.md) or
[/search-pattern](../commands/search-pattern.md), finds an exemplar such as
[user-context-api](../patterns/user-context-api.md), the BSA writes it into a spec from the
[spec template](../subsystems/spec-templates/spec-template.md) — and only ESLint catches deviation.

**Distribution.** `apply-workflow.sh` copies `AGENTS.md`, `project_workflow/`, `patterns_library`,
`specs_templates`, `linting_configs` and the chosen `agent_providers/<provider>/` into an adopter
repo. Dark Factory is not copied; it travels as a `sync_scope` domain, so the halves take two routes.

**A factory session.** [factory-setup](../subsystems/dark-factory/factory-setup.md) refuses to run
without GitHub merge queue enforcement; [factory-start](../subsystems/dark-factory/factory-start.md)
opens a `factory-<ticket>` session, a pane per agent over per-agent worktrees; work leaves only
through [`gh pr merge --auto --squash`](../subsystems/dark-factory/merge-queue-policy.md).

## Citations

- [patterns_library/README.md](../../../patterns_library/README.md) — pattern governance.
- [dark-factory/README.md](../../../dark-factory/README.md) — the factory's own entry point.
- [knowledge-vault/README.md](../../../knowledge-vault/README.md) — OKF tooling overview.
