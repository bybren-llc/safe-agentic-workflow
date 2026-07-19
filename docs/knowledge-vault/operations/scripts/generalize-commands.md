---
type: script
title: "generalize_commands.py"
description: "Python utility that adds template notices and placeholder syntax to Claude Code command markdown files."
tags: [operations, commands, process]
timestamp: 2026-07-19
status: active
domain: operations
resource: "scripts/generalize_commands.py"
sources:
  - "scripts/generalize_commands.py"
verified_against: "fd0fc6a"
---

# generalize_commands.py

Rewrites `.claude/commands/*.md` in place to use template placeholders instead of hardcoded project
values, and inserts a template-notice banner into each. It is broken as shipped: its target
directory is an unresolvable literal path, so a run cannot find any files. This is a stub; the
script is the source of truth.

## Overview

A one-time template-preparation utility, written when the command catalogue needed converting from
one project's concrete values to reusable tokens. It is the only non-shell file in `scripts/` and
the only one named in snake_case rather than kebab-case, requires Python 3 (`os`, `re`, `pathlib`
only), and is 6659 bytes. In practice [setup-template.sh](setup-template.md) superseded it by
handling substitution repo-wide.

## Inputs & Outputs

- **In** — no flags, no positional arguments, no environment variables. Nothing is configurable.
- **In** `COMMANDS_DIR` — a hardcoded absolute path built from unresolved template tokens,
  `Path("/home/{{AUTHOR_HANDLE}}/Projects/{{PROJECT_REPO}}/.claude/commands")`. It is not derived
  from `__file__` and cannot resolve in template state.
- **Out** — command markdown files rewritten in place, each gaining a `TEMPLATE_NOTICE` banner
  inserted after its frontmatter.
- **Exit** `0` — no explicit failure exits are defined.

`add_template_notice()` locates the insertion point with `content.split("---", 2)` and returns the
content unchanged when the marker is already present, so that step is idempotent. The split assumes
the file opens with a `---` delimited block; a command file without frontmatter would have its first
two `---` occurrences treated as one.

## Invoked By

- Nothing. No workflow, hook, command, or script references it; it is run by hand, if at all.
- Note that `scripts/setup-template.sh` includes `*.py` in its find list, so the `{{...}}` tokens in
  `COMMANDS_DIR` would be substituted by a template setup run.

Open question: whether this script was ever run against a resolved path, and whether the tokens in
`COMMANDS_DIR` were intended as substitution targets rather than a mistake, is UNKNOWN.

## Citations

- [Commands README](../../../../.claude/commands/README.md) — the catalogue it was written to
  generalize.
