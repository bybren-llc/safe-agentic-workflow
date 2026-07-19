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
Test 1.1 of `tests/test-fork-sync.sh`. `keryk-ai` (11 files) is the rename-heavy case with four
mappings: three file renames (`agents/fe-developer.md` to `agents/ui-engineer.md`,
`agents/be-developer.md` to `agents/api-engineer.md`, `agents/data-engineer.md` to
`agents/ml-engineer.md`) plus a trailing-slash directory rename of `skills/stripe-patterns/` to
`skills/payment-patterns/`. It also carries a fork-only agent, `agents/ml-ops-engineer.md`, listed as
protected, and `agents/system-architect.md` under `replaced` — locally rewritten, upstream copy
discarded. Together they cover both branches of `resolve_rename` and both of `is_protected`.

## The fixture trees agree with their manifests

The `keryk-ai` `.claude/` tree ships only renamed names (`ui-engineer.md`, `api-engineer.md`,
`ml-engineer.md`, `payment-patterns/SKILL.md`), so a rename regression shows as a stray file, not a no-op.

## Examples and fixtures are near-identical copies

`examples/manifests/` holds exactly two files, one per fork. Beyond the 12-line banner and comments
the fixtures strip, one value diverges in both pairs: the examples list ten `substitution_extensions`
where the fixtures list five (`.md`, `.json`, `.yml`, `.yaml`, `.sh`); neither is read, the engine
hardcodes its own. The keryk-ai banner is stale too, calling `agents/ml-engineer.md` the protected
agent against its own list. The examples are documentation-facing, the fixtures executable.

## Two gaps to know before you trust a run

`tests/test-fork-sync.sh` `cat`s `tests/fixtures/sync/keryk-ai/.claude/settings.local.json` twice in
Test 2.5 and that file does not exist, which aborts the suite. And no fixture exists for any domain
but `.claude`, so multi-domain scope is exercised only by synthetic trees inside
`tests/test-multi-domain-sync.sh`. Mock upstream content lives inline in `setup_mock_upstream` heredocs.

## Next

- [Test Suite: Fork Sync Scenarios](tests/fork-sync.md) — the suite that consumes these fixtures.
- [Harness Manifest and Schema](manifest-schema.md) — what the fixture manifests are instances of.
- [Harness Sync Guide](../../HARNESS_SYNC_GUIDE.md) — the operator view of renames and protection.
