---
type: pattern
title: "Secrets Management Pattern"
description: "Startup-validated environment configuration with .env.template as living documentation of required keys."
resource: "patterns_library/security/secrets-management.md"
tags: [patterns, subsystems, security]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "patterns_library/README.md"
  - "scripts/apply-workflow.sh"
verified_against: "fd0fc6a"
---

# Secrets Management Pattern

Fail at startup, not at the first request. A missing key should stop the process with a named
variable, rather than surfacing hours later as an unexplained 500.

## Overview

The pattern prescribes a `.env.template` that lists every variable and marks it REQUIRED or
OPTIONAL, and a startup check that refuses to boot when a required value is absent. The template is
the documentation — it carries key names only, never values, and stays in version control while the
real environment file does not. Reach for it when introducing any new credential or provider key.
It deliberately overlaps with the [environment config](environment-config.md) pattern; that one is
the general shape of typed configuration, this one is the security-side emphasis on secrets, and
adopting both means writing the validation once.

Its 350-line file follows the library's fixed order: what it does, when to use it, the code
pattern, then per-file supporting sections.

**This pattern is not executed by this repository.** Nothing imports or runs it, and no test,
fixture, or CI job references it. That is by design — the harness *distributes* patterns, and for
a reference implementation the exemplar is the artifact. It reaches adopters wholesale, via
`scripts/apply-workflow.sh` recursively copying `patterns_library/` into the target project.

## Exemplars

- `patterns_library/security/secrets-management.md` — the reference implementation itself, carried
  in `resource`; no second in-repo instance exists to compare it against.

Agents are meant to arrive by discovery: `CLAUDE.md` and the
[pattern-discovery](../skills/pattern-discovery.md) skill point at `patterns_library/`, the
[security-audit](../skills/security-audit.md) skill reaches the same material when scanning for
exposed credentials, and the library README indexes the file under `security`.

**Open question:** whether this code has ever been compiled or executed anywhere. Nothing in this
repo exercises it, so correctness rests on review alone.

## Citations

- [patterns_library README](../../../patterns_library/README.md) — the category index.
- [CLAUDE.md](../../../CLAUDE.md) — the Pattern Discovery Protocol that routes agents here.
