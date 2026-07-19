# Commands

Thirty-five commands you invoke by name: 24 on the Claude surface and 11 Gemini-only media commands
that have no counterpart anywhere else. Commands are explicit workflows with steps and side effects
— unlike [skills](../skills/index.md), which the model chooses for you.

Six commands are deprecated aliases kept alive for muscle memory; they are listed last, and each one
names its replacement.

## The work session

The bookends of a ticket. `/start-work` holds a stop-the-line gate — it refuses a ticket with no
acceptance criteria, which is the single most load-bearing behavior in this group.

- [`/start-work`](start-work.md) — opens a Linear ticket behind the mandatory AC/DoD gate, then
  branches from the latest dev
- [`/check-workflow`](check-workflow.md) — traffic-light health check on branch naming, ticket
  linkage, commit format, rebase status and docs
- [`/sync-linear`](sync-linear.md) — derives status from branch commits and writes status, labels
  and a progress comment back to the ticket
- [`/end-work`](end-work.md) — session-close checklist: commit outstanding work, update the ticket,
  preserve context before a switch
- [`/retro`](retro.md) — seven-section retrospective of the session, from what worked well through
  metrics to wins

## Getting a change merged

The validation gate and the routes through it. `/pre-pr` is mandatory; `/quick-fix` is the
deliberately reduced path for small bugs and says so explicitly.

- [`/pre-pr`](pre-pr.md) — the mandatory gate: CI suite, markdown lint, clean tree, rebase onto dev,
  commit-message format check
- [`/quick-fix`](quick-fix.md) — fast-track bug fixes with reduced validation, a minimal PR
  template, and explicit scope limits
- [`/update-docs`](update-docs.md) — scans the branch diff for every doc the change touches,
  enforcing the docs-in-the-same-PR rule
- [`/test-pr-docker`](test-pr-docker.md) — labels a PR to trigger a CI image build, then guides
  pulling and verifying the `pr-N` image
- [`/release`](release.md) — the six-phase release: validate, merge PRs, bump version, tag and
  publish, sync branches, clean up

## Running an environment

Deploy, inspect, and recover. The `remote-*` family is canonical; the local pair is the same shape
against your own Docker daemon.

- [`/remote-deploy`](remote-deploy.md) — one SSH call runs the remote deploy script, then health and
  container revision are verified
- [`/remote-status`](remote-status.md) — compares the SHA baked into the running container against
  the latest branch commit and CI state
- [`/remote-health`](remote-health.md) — eight-step dashboard: containers, resources, HTTP health,
  Postgres, Redis, errors, version
- [`/remote-logs`](remote-logs.md) — fetch, filter and analyse container logs over SSH with tail,
  follow and search modes
- [`/remote-rollback`](remote-rollback.md) — backs up compose, pins the previous image tag,
  restarts, and verifies health
- [`/local-deploy`](local-deploy.md) — deploys the latest registry image to the local daemon in dev
  or staging mode, optionally triggering a CI build
- [`/local-sync`](local-sync.md) — post-pull sync: branch cleanup, pull, change-gated install and
  Prisma generate, optional CI validation

## Investigating the codebase

- [`/search-pattern`](search-pattern.md) — pattern search with an optional file-type filter,
  categorising matches and surfacing refactoring opportunities
- [`/audit-deps`](audit-deps.md) — yarn audit, bundle analyzer, depcheck and outdated, then writes a
  report and files Linear tickets

## Media commands (Gemini only)

Eleven commands in the `media:` namespace, available on no other provider. They are the clearest
example of a surface expressing something its tool has natively — multimodal input — and are the
largest single parity gap in the harness.

Video and scenes:

- [`/media:analyze-video`](media-analyze-video.md) — per-scene setting, subjects, actions, dialogue
  and visual style
- [`/media:scene-detect`](media-scene-detect.md) — scene boundaries as a table or a CMX 3600 EDL
- [`/media:extract-frames`](media-extract-frames.md) — visually significant frames, each described
  as a storyboard entry
- [`/media:video-to-script`](media-video-to-script.md) — fuses transcription and visual analysis
  into a screenplay, narrative or shot list

Audio and speech:

- [`/media:transcribe-audio`](media-transcribe-audio.md) — timestamped text, SRT, WebVTT or JSON
  with automatic language detection
- [`/media:extract-dialogue`](media-extract-dialogue.md) — transcription with speaker diarization as
  screenplay, JSON or labeled transcript
- [`/media:analyze-audio`](media-analyze-audio.md) — classifies speech, music, ambient or mixed and
  reports mood, segments and technical quality

Images, documents and files:

- [`/media:analyze-images`](media-analyze-images.md) — describes visual content in a directory and
  suggests content-based filenames
- [`/media:sketch-to-code`](media-sketch-to-code.md) — turns sketches, wireframes and mockups into
  component code or Mermaid diagrams
- [`/media:extract-pdf`](media-extract-pdf.md) — structured extraction from invoices, tables and
  forms as JSON, CSV, markdown or text
- [`/media:organize-files`](media-organize-files.md) — renames and refiles by content rather than
  extension, behind a dry-run plan

## Deprecated aliases

Still executable, but each one redirects. Use the canonical command named alongside it.

| Alias | Use instead | Note |
| --- | --- | --- |
| [`/deploy-dev`](deploy-dev.md) | [`/remote-deploy`](remote-deploy.md) | pure redirect |
| [`/check-docker-status`](check-docker-status.md) | [`/remote-status`](remote-status.md) | pure redirect |
| [`/dev-health`](dev-health.md) | [`/remote-health`](remote-health.md) | pure redirect |
| [`/dev-logs`](dev-logs.md) | [`/remote-logs`](remote-logs.md) | pure redirect |
| [`/rollback-dev`](rollback-dev.md) | [`/remote-rollback`](remote-rollback.md) | still fully executable |

## Related

- [Skills](../skills/index.md) — the model-invoked counterpart
- [Operations domain](../domains/operations.md) — how commands, CI workflows and the release gate
  fit together day to day
- [Providers](../providers/index.md) — which surface carries which commands, and where they diverge
- [Vault root](../index.md)
