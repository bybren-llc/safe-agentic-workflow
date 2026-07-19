---
type: pattern
title: "Structured Logging Pattern"
description: "JSON structured logging with correlation IDs, level filtering, and request context propagation."
resource: "patterns_library/config/structured-logging.md"
tags: [patterns, subsystems]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "patterns_library/README.md"
  - "scripts/apply-workflow.sh"
verified_against: "fd0fc6a"
---

# Structured Logging Pattern

Logs written as JSON objects rather than sentences, carrying a correlation ID through the whole
request, so a production incident is a query instead of an exercise in grep.

## Overview

Levels are a `LogLevel` union of `debug | info | warn | error`, filtered through a
`LOG_LEVEL_PRIORITY` map so a single threshold silences everything below it. Request context is
propagated rather than re-passed at each call site, which is what makes the correlation ID useful.
The output shape targets the common aggregators — Datadog, ELK, CloudWatch, and Loki — so the
choice of vendor is a downstream concern. Reach for it in any service whose logs are shipped
somewhere. It buys little in a short-lived CLI. Like the security patterns it is written
language-agnostically with placeholders, so adopters substitute before use.

Its 459-line file follows the library's fixed order: what it does, when to use it, the code
pattern, then per-file supporting sections.

**This pattern is not executed by this repository.** Nothing imports or runs it, and no test,
fixture, or CI job references it. That is by design — the harness *distributes* patterns, and for
a reference implementation the exemplar is the artifact. It reaches adopters wholesale, via
`scripts/apply-workflow.sh` recursively copying `patterns_library/` into the target project.

## Exemplars

- `patterns_library/config/structured-logging.md` — the reference implementation itself, carried in
  `resource`; no second in-repo instance exists to compare it against.

Discovery is the intended route in: `CLAUDE.md` and the
[pattern-discovery](../skills/pattern-discovery.md) skill point at `patterns_library/`, and the
library README indexes this file under `config` alongside the
[environment config](environment-config.md) pattern, which supplies the level threshold.

**Open question:** whether this code has ever been compiled or executed anywhere. Nothing in this
repo exercises it, and the placeholders mean it cannot run as written — correctness rests on review.

## Citations

- [patterns_library README](../../../patterns_library/README.md) — the category index.
- [CLAUDE.md](../../../CLAUDE.md) — the Pattern Discovery Protocol that routes agents here.
