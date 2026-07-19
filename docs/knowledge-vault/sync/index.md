# Sync

A fork of this harness is not a snapshot — it is a long-running relationship with an upstream that
keeps moving. The sync subsystem exists to answer one question: **how does a fork take upstream
improvements without losing the edits that made it a fork?** Renamed files, substituted project
tokens, and locally-owned files all have to survive a pull that neither side coordinated.

Read the engine first if you want to know what happens; read the manifest if you want to know what
a fork is allowed to declare about itself.

## The mechanism

- [Harness Sync Engine](harness-sync-engine.md) — the 3366-line bash script that does the work:
  fetches upstream domains as a GitHub tarball, then replays each fork's renames, substitutions and
  protected paths over the incoming tree. Start here.
- [Harness Manifest Schema](manifest-schema.md) — the contract a fork writes about itself: identity,
  substitutions, renames, protected and replaced files, and sync preferences. Everything the engine
  does is driven by this file, so the schema is the real API.
- [Multi-Domain Sync Scope Resolution](sync-scope.md) — how the engine decides *which* directories
  to pull: manifest `sync_scope`, a `--scope` override, or the `.claude` default. Read when a sync
  moved more or less than you expected.
- [Sync Test Fixtures and Example Manifests](fixtures.md) — two synthetic fork snapshots
  (`rendertrust`, `keryk-ai`) and their published manifests. These are the fork-compatibility
  contract in concrete form, and they are what the end-to-end suite runs against.

## Test suites

The nine suites under `tests/` have no index of their own; they are listed here. They are the only
evidence that the engine's guarantees are real, so their pass/fail state is worth stating plainly
rather than assuming.

**Measured state on macOS at this baseline: four of nine suites pass.** The failures split into two
distinct causes, and the distinction matters — neither is a defect in the sync logic itself:

- **A missing fixture (data gap).** The fork-compatibility suite aborts because
  `tests/fixtures/sync/keryk-ai/.claude/settings.local.json` does not exist in the repo. Nothing is
  wrong with the code; the test data is incomplete.
- **macOS portability (bash 3.2 / BSD tooling).** `declare -A` in the engine's diff path is rejected
  by the bash 3.2 that ships with macOS, so every `do_diff` assertion fails. A GNU/Linux runner with
  bash 4+ may well pass these; that is untested here and should not be assumed.

| Suite | State here | Note |
| --- | --- | --- |
| [Manifest Init Wizard](tests/manifest-init.md) | Passes | 14 tests, 52 assertions on generation from team-config |
| [Manifest Loader and Validator](tests/manifest-loader.md) | Passes | Asserts every required-field error and the bad-YAML fallback |
| [Patch Generation Mode](tests/patch-generation.md) | Passes | 17 tests; verifies output is `git apply` compatible |
| [Preflight and Provenance](tests/preflight.md) | Passes | 18 tests; exercises real failure paths, not just happy ones |
| [Fork Compatibility](tests/fork-sync.md) | Aborts | Missing fixture file, not a code defect |
| [Protected File Enforcement](tests/protected-files.md) | 48 pass, 6 fail | All six are `do_diff` under bash 3.2 |
| [Rename Resolution and Diff](tests/rename-diff.md) | 38 pass, 12 fail | Same `do_diff` cause; the root of the portability issue |
| [Placeholder Substitution](tests/substitutions.md) | Aborts | Inherits the rename-diff failure under `set -e` |
| [Multi-Domain Sync](tests/multi-domain-sync.md) | Aborts in Test 1 | BSD tooling; zero of its 14 tests execute on macOS |

A useful reading order for the suites: start with **Protected File Enforcement** and **Rename
Resolution**, because between them they encode the two promises a fork actually cares about — *my
local files are not overwritten* and *my renames are understood, not duplicated*.

## Related

- [Harness Sync and Fork Workflow](../methodology/harness-sync-and-fork-workflow.md) — the human
  procedure around the tooling: when to sync, and how to roll back
- [Fork Sync Compatibility Workflow](../operations/workflows/test-fork-sync.md) — the CI workflow
  that runs these suites on a path filter
- [Sync domain](../domains/sync.md) — the cross-cutting view of how sync works
- [Operations](../operations/index.md) — the scripts and workflows that run alongside sync
