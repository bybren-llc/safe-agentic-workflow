---
type: skill
title: "Skill: deployment-sop"
description: "Deploy workflow: pre-deploy validation, smoke test, evidence, rollback and branch-to-environment map."
resource: ".claude/skills/deployment-sop/SKILL.md"
tags: [skills, operations, release, process]
timestamp: 2026-07-19
status: active
domain: methodology
sources:
  - ".claude/skills/deployment-sop/SKILL.md"
  - ".agents/skills/deployment-sop/SKILL.md"
  - ".claude/skills/deployment-sop/README.md"
verified_against: "fd0fc6a"
---

# Skill: deployment-sop

The deploy card: what must be green before a release moves, what to check after it lands, and how to
get back.

## Overview

User-invocable only — the Claude copy sets `disable-model-invocation: true` with
`argument-hint: "[environment]"` and `allowed-tools` of `Read`, `Bash`, `Grep`, and `Glob`. That is why
it does not appear in the model's runtime skill listing: a human must call it with a target
environment. Ten H2 sections carry a pre-deployment checklist, a post-deployment smoke test, an
evidence template, a rollback procedure, stop-the-line conditions, and a branch-to-environment map.

## Routes To

- DOC DRIFT: all four targets under "Authoritative References (MUST READ)" are missing from this
  repository — `docs/ci-cd/Semantic-Release-Deployment-SOP.md`, `docs/sop/STAGING-UAT-RELEASE-SOP.md`,
  `docs/deployment/LINUX-DEV-MACHINE-ACCESS-SOP.md`, and
  `docs/deployment/PRODUCTION-SERVER-ACCESS-SOP.md`. `docs/deployment/` does not exist at all. The
  drift is on BOTH surfaces, so the skill currently routes nowhere that resolves.
- DOC DRIFT: the Claude copy additionally invokes `scripts/dev-docker.sh`, which is also absent; the
  `.agents` copy omits that reference.
- What does exist nearby: `docs/ci-cd/CI-CD-Pipeline-Guide.md` and `docs/sop/PRE_PR_VALIDATION_CHECKLIST.md`.

Related concepts: [Release Process](../operations/release/release-process.md) and
[Pre-Release Checklist](../operations/release/pre-release-checklist.md) cover the missing SOPs' ground.

## Used By Roles

- No `.claude/agents/*.md` file names this skill, and it is not model-invocable, so it reaches an agent
  only when a human runs it.
- [RTE](../roles/rte.md) is its natural operator at release assembly, but does not declare it.

The `.agents` copy (124 lines against 129) drops `disable-model-invocation`, `argument-hint`, and
`allowed-tools`, tokenizes `{{BUILD_COMMAND}}`, `{{CI_VALIDATE_COMMAND}}`, `{{DOMAIN}}`,
`{{MAIN_BRANCH}}`, `{{PROD_DEPLOY_MODE}}`, and `{{STAGING_DEPLOY_MODE}}`, and renames the arrow
heading to ASCII.

## Citations

- [deployment-sop SKILL.md](../../../.claude/skills/deployment-sop/SKILL.md) — the authoritative procedure.
- [CI/CD Pipeline Guide](../../ci-cd/CI-CD-Pipeline-Guide.md) — the pipeline documentation that does exist.
