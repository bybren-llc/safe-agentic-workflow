# Operations

How the harness is actually run: what CI checks on every push, what gates a release, and the
one-off scripts that built the repository into its current shape. If sync is about taking changes
*in*, operations is about getting changes *out* safely.

## CI workflows

Four workflows. Note what they do **not** cover — there is no deployment workflow here, because this
repository ships prompts and configuration, not a running service.

- [CI Workflow (ci.yml)](workflows/ci.md) — lint, type-check and test on push and PR to `main` and
  `dev`. The template baseline an adopting project inherits.
- [PR Validation Workflow (pr-validation.yml)](workflows/pr-validation.md) — process rather than
  code: rebase status, commit message format, PR title, and the presence of a Linear ticket
  reference. This is the workflow that fails you for a missing `[SAW-XX]`.
- [Fork Sync Compatibility Workflow (test-fork-sync.yml)](workflows/test-fork-sync.md) —
  path-filtered; runs the fork-sync and sync unit suites against the fixture manifests. See
  [sync/](../sync/index.md) for what those suites currently prove.
- [Docker Build Workflow (docker-build.yml)](workflows/docker-build.md) — builds and pushes an image
  on push to `main`/`dev` or on a labeled PR

## Release

The gate between "merged" and "tagged". Read the checklist first — the script automates part of it,
not all of it.

- [Pre-Release Checklist](release/pre-release-checklist.md) — the mandatory manual gate before any
  release tag is cut
- [pre-release-check.sh - Release Gate](scripts/pre-release-check.md) — automates the verifiable
  items across five gate categories. **It does run every suite in `tests/`**, and exits 1 with
  `RELEASE BLOCKED` when any check fails — so at present it blocks, because several sync suites fail
  on macOS. Treat a red run as information about the suites, not about the gate being broken.
- [Harness Release Changelog Process](release/release-process.md) — how releases get described:
  `generate-changelog.sh` diffs two refs into the `HARNESS_CHANGELOG.yml` schema
- [Version Upgrade Notes](release/version-upgrade-notes.md) — the index of per-version upgrade
  guides, release notes and structured changelogs

## Scaffolding an adopting project

Scripts you run once, on purpose, when standing up a new project from this template:

- [project_workflow Scaffold](project-workflow.md) — the drop-in CI/CD bundle: CONTRIBUTING,
  CODEOWNERS, PR template, multi-team pipeline, setup script
- [setup-template.sh - Template Setup Wizard](scripts/setup-template.md) — the interactive wizard
  that replaces every `{{PLACEHOLDER}}` across the repo with real project values. The first thing
  you run.
- [apply-workflow.sh - Workflow Integration Installer](scripts/apply-workflow.md) — installs the
  workflow into an existing project. **Caution:** it substitutes a second, incompatible `__TOKEN__`
  placeholder family, so it does not compose cleanly with the wizard above.
- [install-prompts.sh - Agent Prompt Installer](scripts/install-prompts.md) — installs agent prompts
  at user or team scope for Claude Code, or for Augment Code

## Changelog generation

- [generate-changelog.sh - Structured Changelog Generator](scripts/generate-changelog.md) — diffs two
  git refs into a schema-v1.0.0 changelog in YAML or Markdown, classifying `.claude/` changes into
  five categories

## Historical migrations

These ran once and are unlikely to run again. They are documented because they explain why the
repository is laid out the way it is, and because their placeholder conventions still leak into
files they touched.

- [reorganize-docs.sh - One-Shot Docs Reorganization](scripts/reorganize-docs.md) — the migration
  that `git mv`'d eight root docs into `docs/` subdirectories
- [update-doc-references.sh - Doc Link Rewriter](scripts/update-doc-references.md) — rewrote links to
  the six moved docs, leaving a `.bak` beside every file it edited
- [fix-remaining-doc-references.sh - Residual Link Fixer](scripts/fix-remaining-doc-references.md) —
  the second pass, for backtick and bare-list references the rewriter missed
- [generalize_commands.py - Command Template Generalizer](scripts/generalize-commands.md) — injected
  the template notice and placeholder substitutions into slash-command markdown
- [generalize-onboarding-docs.sh - Onboarding Doc Generalizer](scripts/generalize-onboarding-docs.md)
  — replaced hardcoded project references across five onboarding docs; **GNU-only `sed`**, so it does
  not run as written on macOS

## Related

- [Operations domain](../domains/operations.md) — the cross-cutting view
- [Sync](../sync/index.md) — pulling upstream changes in, the other half of the loop
- [Pre-PR Validation Checklist](../knowledge/sop/pre-pr-validation-checklist.md) — what an
  orchestrator completes before opening a PR
- [CI/CD Pipeline Guide](../knowledge/ci-cd/ci-cd-pipeline-guide.md) — the source-of-truth doc for
  branch protection and the rebase-first flow
