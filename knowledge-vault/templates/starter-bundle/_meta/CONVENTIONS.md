---
type: meta
title: "Conventions"
description: "The constitution for this OKF bundle: frontmatter contract, link rules, section templates, style."
tags: [okf]
timestamp: 2026-07-19
status: active
---

# Conventions

This bundle conforms to the [Open Knowledge Format v0.1](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
and doubles as an Obsidian vault. **Every rule here exists to keep hundreds of files written by
many agents indistinguishable from files written by one mind.** The machine-readable form of this
document is `vault-config.json`.

**What enforces what.** `validate-vault.mjs` enforces the structural rules: the frontmatter
contract, section order, link legality, path existence, the stub contract, and manifest agreement.
Markdown lint enforces the formatting rules (line length, table pipes, fenced-block languages).
A handful of rules below are **conventions only** — kebab-case filenames, no emoji, one-sentence
descriptions, `verified_against` actually being a SHA, and newest-first log ordering. Nothing
checks those; they rely on review. Do not assume a clean validator run means every rule here was
followed.

## Concept files

- One concept per `.md` file. The concept ID is its bundle-relative path minus `.md`.
- Filenames are kebab-case.
- Exactly one H1: the concept title. All sections are H2. (OKF suggests `#` headings for
  sections; we use H2 so markdown linters that forbid multiple H1s stay happy. Heading level is
  soft guidance in OKF.)
- Every sectioned concept ends with `## Citations`. (Free-form types such as `guide` declare no
  fixed sections and are exempt — see Section templates.)

## Frontmatter contract

**Required on every concept:** `type`, `title`, `description` (one sentence, ≤160 chars), `tags`
(at least one, from the controlled vocabulary), `timestamp`, `status`.

`timestamp` is **the date the concept was last verified against its sources** — not the date the
file was edited. That distinction is the whole point.

**Optional:** `resource` (the primary underlying asset, repo-root-relative — required for concrete
types), `domain`, `ticket`, `sources` (additional assets), `docs` (source-of-truth docs),
`verified_against` (the git SHA the claims were checked at). `okf_version` appears only in the
root `index.md`.

**YAML subset only.** The validator parses frontmatter without a YAML library, so: scalar values,
double-quoted strings, inline lists `[a, b]`, and two-space-indented block lists. No nested maps,
no multiline scalars. This restriction is what keeps the validator dependency-free.

```yaml
---
type: integration
title: "Payment Provider"
description: "Handles checkout sessions and settlement webhooks for paid plans."
resource: "src/integrations/payments/client.ts"
tags: [platform, api]
timestamp: 2026-07-19
status: active
domain: platform
ticket: [ABC-123]
sources:
  - "src/integrations/payments/webhook.ts"
docs:
  - "docs/payments-overview.md"
verified_against: "a1b2c3d"
---
```

## Link rules

1. **Relative markdown links only.** Never wikilinks, never leading-slash paths, never
   repository-host URLs for files that live in this repo.
2. **Concept-to-concept links never leave the bundle.** Link text is the target's title, or a
   natural inline phrase.
3. **Links that leave the bundle appear only under `## Citations`** — plus in `index.md` files and
   `guide` concepts, which are navigation. Code files are never linked; they are named as plain
   inline code, or carried in `resource` / `sources`.
4. **Link only to concept IDs listed in `manifest.json`.** If a concept you want does not exist,
   name it in prose without a link and report it as a suggestion. **Never invent links.** This is
   the rule that makes parallel multi-agent authoring produce a coherent graph instead of a
   plausible-looking mess.
5. External web URLs: only under `## Citations`.

## Reserved files

- `index.md` — navigation only, no frontmatter. The root `index.md` is the single exception: it
  carries `okf_version` plus the standard fields. Not a concept.
- `log.md` — one changelog at the bundle root. `# Log`, then `## YYYY-MM-DD` entries, newest
  first. Each entry: what changed, why (ticket), and the source SHA.

## Body style

- **Summarize, never duplicate.** If the knowledge lives in a source-of-truth document, the
  concept is a map-card that cites it. **If you are restating more than a paragraph, stop and
  link.**
- **Facts must be true of the code as it exists.** Name the helper actually called, not the one
  the code *should* call. When code contradicts documentation, **the code wins** and the
  discrepancy is noted.
- Environment variable names may be mentioned; values never.
- Keep lines readable; tables need leading and trailing pipes; fenced blocks declare a language.
- No emoji in concept files.

## Section templates

Each type's required H2 set is defined in `vault-config.json` and mirrored as a skeleton in
`templates/`. **Section order is fixed** — do not add, remove, or rename H2s. H3s inside a section
are free. The `guide` type is free-form.

## Change protocol

Every pull request that touches the vault prepends a dated entry to `log.md` and bumps the
`timestamp` of each concept it re-verified. Deprecation is `status: deprecated` plus a log entry;
deletion happens only in a follow-up change, after inbound links are cleaned.

**A citation is not re-verification.** Linking a concept from somewhere new does not make its
claims fresher. Only re-deriving it from source bumps `timestamp` and `verified_against`.
