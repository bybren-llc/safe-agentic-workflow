---
type: guide
title: "Merge Queue Policy"
description: "The single-path-to-trunk policy: GitHub merge queue with squash, enforced by ruleset not by client flags."
tags: [subsystems, gates, ci, process]
timestamp: 2026-07-19
status: active
domain: subsystems
sources:
  - "dark-factory/docs/MERGE-QUEUE-POLICY.md"
  - "dark-factory/templates/github/merge-queue-ruleset.json"
  - "dark-factory/scripts/factory-setup.sh"
verified_against: "fd0fc6a"
---

# Merge Queue Policy

Read this before running any [Dark Factory](../dark-factory.md) session, because
[factory-setup.sh](factory-setup.md) will not let you start one until the policy is in place.
Agents opening PRs against one trunk collide unless something serialises them. The queue does.

## One command, and only one

Agents may merge exactly one way: `gh pr merge --auto --squash`. All three team layouts embed that
literal string in the TDM lead prompt. The policy denies that `--merge-queue` is a real `gh`
option, and states that enforcement lives in a GitHub branch ruleset rather than client-side flags,
where an agent cannot route around it. Because the queue squashes, the PR title becomes the trunk
commit message, so titles must satisfy `type(scope): description [<PREFIX>-XXX]`.

## What the ruleset must say

Merge queue required on the main branch, merge method squash, a maximum of five entries, a
30-minute check timeout, the ALLGREEN strategy, `strict_required_status_checks_policy` false, and
no bypass actors — that last is the point, since a bypass actor makes the gate advisory. It ships
`dark-factory/templates/github/merge-queue-ruleset.json` for import through Settings > Rules >
Rulesets, with manual UI steps as a fallback.

## Wiring CI to the queue

A merge queue runs checks against a speculative merge commit, so workflows must subscribe to the
`merge_group` event. Half of the setup readiness gate is a `grep -rl merge_group` over
`.github/workflows/*.yml`; a `pull_request`-only workflow leaves the queue waiting forever.

## When the queue is down

The policy is stop-the-line, not degrade-gracefully. If the queue is unavailable, agents stop
creating PRs, the TDM reports the blocker, and there is no fallback to a direct merge — the same
shape as the harness's [Stop-the-Line Gate](../../methodology/stop-the-line-gate.md).

## Watching it

Monitoring: `gh pr checks`, `gh pr list --json number,title,mergeStateStatus`, and
`gh api repos/{owner}/{repo}/mergequeue`. Next, read [factory-setup.sh](factory-setup.md).

## Citations

- [MERGE-QUEUE-POLICY.md](../../../../dark-factory/docs/MERGE-QUEUE-POLICY.md) — the full policy,
  including the `{{MAIN_BRANCH}}` and `{{TICKET_PREFIX}}` tokens to substitute.
