---
type: script
title: "apply-workflow.sh"
description: "Integrates the SAFe agentic workflow template into an existing project, prompting for the AI agent provider."
tags: [operations, onboarding, workflow]
timestamp: 2026-07-20
status: active
domain: operations
resource: "scripts/apply-workflow.sh"
sources:
  - "scripts/apply-workflow.sh"
verified_against: "0c26121"
---

# apply-workflow.sh

Writes harness files into an existing project. `TARGET_DIR` is hardcoded to `.`, so the current
working directory is always the install target — run it from the wrong directory and it installs
into the wrong repository. This is a stub; the script is the source of truth.

## Overview

The harness has two entry points that are easy to confuse.
[setup-template.sh](setup-template.md) bootstraps a new repository from the template; this one
integrates the template into a project that already exists. It is a bash script under `set -e` at
6664 bytes, and it interrogates the operator through six prompts. The first picks the AI agent
provider from exactly two branches — `1` for Claude Code into `.claude`, `2` for Augment into
`.augment`, anything else fatal. It carries unresolved `{{PROJECT_SHORT}}` placeholders in its own
output strings, which makes it a substitution target of that script as well as a peer of it.

## Inputs & Outputs

- **In** — no flags or positional arguments; all configuration arrives through six `read -p`
  prompts: provider, ticket prefix, primary dev branch, project git URL, project name (asked only
  when derivation from the URL yields empty), and ticket URL prefix. A blank ticket prefix or dev
  branch is fatal. The last five feed the matching `__TICKET_PREFIX__`-style token substitutions.
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

One open question remains from the source: whether the non-executable file mode is deliberate or an
oversight.

## Citations

- [Template Setup](../../knowledge/root-docs/template-setup.md) — the sibling bootstrap path for a
  new repository.
- [README.md](../../../../README.md) — the project entry point that frames both install routes.
