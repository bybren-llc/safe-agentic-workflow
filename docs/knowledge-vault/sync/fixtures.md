---
type: guide
title: "Sync Test Fixtures and Example Manifests"
description: "The two simulated fork trees and example manifests exercising renames, protection, and substitution."
tags: [sync, testing, patterns]
timestamp: 2026-07-19
status: active
domain: sync
sources:
  - "tests/fixtures/sync/rendertrust/.harness-manifest.yml"
  - "tests/fixtures/sync/keryk-ai/.harness-manifest.yml"
  - "examples/manifests/rendertrust.harness-manifest.yml"
  - "examples/manifests/keryk-ai.harness-manifest.yml"
  - "tests/test-fork-sync.sh"
verified_against: "fd0fc6a"
---

# Sync Test Fixtures and Example Manifests

If you are changing rename resolution, protected-file handling, or substitution, these 19 files tell
you whether you broke it. The two fork trees are not sample data: each encodes half of a contrast.

## The two forks are complementary, not redundant

`rendertrust` (8 files) is the unrenamed baseline: zero renames, two protected patterns, asserted by
Test 1.1 of `tests/test-fork-sync.sh`. `keryk-ai` (11 files) is the rename-heavy case, declaring two
file renames (`agents/fe-developer.md` to `agents/ui-engineer.md`, `agents/be-developer.md` to
`agents/api-engineer.md`) plus a trailing-slash directory rename of `skills/stripe-patterns/` to
`skills/payment-patterns/`. It also carries a fork-only agent, `agents/ml-engineer.md`, listed as
protected, and `agents/system-architect.md` under `replaced` — locally rewritten, upstream copy
discarded. Together they cover both branches of `resolve_rename` and both of `is_protected`.

## The fixture trees agree with their manifests

The `keryk-ai` `.claude/` tree ships `ui-engineer.md`, `api-engineer.md` and
`payment-patterns/SKILL.md` and never the upstream names, so a rename regression appears as a file
where none should be rather than as a silent no-op.

## Examples and fixtures are near-identical copies

`examples/manifests/` holds exactly two files, one per fork. `diff` against the fixture copies shows
the only differences are comments: the examples carry a 12-line banner and inline explanations the
fixtures strip. Every key and value is identical. The examples are documentation-facing and read by
no script, while `tests/fixtures/sync/` is the executable copy loaded via `FIXTURES_DIR`.

## Two gaps to know before you trust a run

`tests/test-fork-sync.sh` `cat`s `tests/fixtures/sync/keryk-ai/.claude/settings.local.json` twice in
Test 2.5 and that file does not exist, which aborts the suite. And no fixture exists for any domain
other than `.claude`, so multi-domain scope is exercised only by synthetic trees built inside
`tests/test-multi-domain-sync.sh`. Mock upstream content is not stored here either —
`setup_mock_upstream` emits it inline as heredocs seeded with `{{PROJECT_NAME}}` and friends.

## Next

- [Test Suite: Fork Sync Scenarios](tests/fork-sync.md) — the suite that consumes these fixtures.
- [Harness Manifest and Schema](manifest-schema.md) — what the fixture manifests are instances of.
- [Harness Sync Guide](../../HARNESS_SYNC_GUIDE.md) — the operator view of renames and protection.
