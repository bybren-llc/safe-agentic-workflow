---
type: script
title: "apply-workflow.sh"
description: "Integrates the SAFe agentic workflow template into an existing project, prompting for the AI agent provider."
tags: [operations, onboarding, workflow]
timestamp: 2026-07-19
status: active
domain: operations
resource: "scripts/apply-workflow.sh"
sources:
  - "scripts/apply-workflow.sh"
verified_against: "fd0fc6a"
---

# apply-workflow.sh

Writes harness files into an existing project. `TARGET_DIR` is hardcoded to `.`, so the current
working directory is always the install target — run it from the wrong directory and it installs
into the wrong repository. This is a stub; the script is the source of truth.

## Overview

The harness has two entry points that are easy to confuse.
[setup-template.sh](setup-template.md) bootstraps a new repository from the template; this one
integrates the template into a project that already exists. It is a bash script under `set -e` at
6664 bytes, and its only interactive step asks the operator to choose an AI agent provider,
presenting Claude Code as the recommended fully-automated option. It carries unresolved
`{{PROJECT_SHORT}}` placeholders in its own output strings, which makes it a substitution target of
that script as well as a peer of it.

## Inputs & Outputs

- **In** — no flags or positional arguments; configuration comes from the interactive provider
  prompt.
- **In** `TARGET_DIR` — hardcoded to `.`, not overridable from the command line.
- **In** `TEMPLATE_DIR` — derived as `dirname $0`, which resolves to the `scripts/` directory
  itself rather than the repo root.
- **Out** — files written into the current working directory.
- **Exit** `1` — every error path is fatal: `log_error` echoes and then exits.
- **Exit** `0` — integration completed.

## Invoked By

- Nothing in the repository calls it. It is operator-run only, and because its mode is 644 while
  the other nine shell scripts in `scripts/` are 755, it cannot be executed directly — invoke it as
  `bash scripts/apply-workflow.sh`.
- Not referenced by any workflow, hook, or slash command.

Two open questions remain from the source: the full list of providers the prompt offers and what
each branch copies is UNKNOWN, as is whether the non-executable file mode is deliberate or an
oversight.

## Citations

- [Template Setup](../../knowledge/root-docs/template-setup.md) — the sibling bootstrap path for a
  new repository.
- [README.md](../../../../README.md) — the project entry point that frames both install routes.
