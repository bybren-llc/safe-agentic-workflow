# Adoption Playbook

**Purpose**: Take a team from "we merged the knowledge-vault subsystem" to "we have a vault our
agents and our humans both trust, and CI fails when it drifts."

**Audience**: The person running the first build. Assume one owner, a handful of agents, and a
week of elapsed time.

**Prerequisite**: Read [GUIDE.md](GUIDE.md) first. It explains *why* each rule exists. This
document does not repeat the reasoning — it gives the order of operations and the decisions you
have to make. Where the two disagree, GUIDE.md wins.

Placeholders below use the repo's `{{TOKEN}}` convention. Replace them before running anything.

---

## Step 1 — Verify the tooling before you trust it

The first thing you do after the PR merges is prove the validator works on a vault that is known
to be clean. The starter bundle is that vault.

```bash
node knowledge-vault/scripts/validate-vault.mjs --vault knowledge-vault/templates/starter-bundle
```

Expected: a summary line, zero errors, exit code 0.

```bash
echo $?   # 0
```

If this does not exit 0, stop. Something about the merge is wrong, and every later step assumes a
working validator. Check the CLI surface while you are here:

```bash
node knowledge-vault/scripts/validate-vault.mjs --help
```

| Flag | Use it when |
| --- | --- |
| `--vault <dir>` | Always. Auto-discovery only works when exactly one vault exists. |
| `--allow-broken-links` | Mid-build, while concepts reference each other before all exist. Never in CI. |
| `--strict-orphans` | Once navigation is built, to prove every concept is reachable. |
| `--quiet` | In scripts, when you only want the summary line. |

---

## Step 2 — Copy the starter bundle

Copy, do not symlink, and do not build directly inside `knowledge-vault/templates/`. The template
stays pristine so you can diff against it later.

```bash
cp -r knowledge-vault/templates/starter-bundle {{VAULT_ROOT}}
```

`{{VAULT_ROOT}}` is repo-root-relative, for example `docs/vault` or `knowledge/bundle`.

Then edit `{{VAULT_ROOT}}/_meta/vault-config.json`:

| Field | Set it to | Why it matters |
| --- | --- | --- |
| `bundle_root` | `{{VAULT_ROOT}}` | The validator warns when this disagrees with where the vault actually is. |
| `obsidian_vault_root` | the **parent** of `{{VAULT_ROOT}}` | Makes source-of-truth citations outside the bundle clickable in the GUI. |
| `domains` | your business domains | Empty array disables the check; prefer real values. |
| `tags` | your controlled vocabulary | Empty array disables the check; prefer real values. |

Re-run the validator against the copy. It should still exit 0 — you now have a working vault of
two concepts, which is the smallest thing that can drift.

If you use Obsidian, apply the three settings from GUIDE.md's *GUI/validator treaty* now, before
anyone creates a link by hand. Retrofitting wikilinks into markdown links is tedious.

---

## Step 3 — Choose your taxonomy

Directories are three orthogonal axes, not one hierarchy. GUIDE.md's *three-axis taxonomy* section
has the principle; this is the decision procedure.

Ask three separate questions, and let each one produce its own directories:

1. **Structural** — what artifacts does this repo actually contain? Mirror them.
2. **Semantic** — what does the business call the parts of this product? Cross-cut them.
3. **Conceptual** — what do we know that is not in any one file? Name those.

### Worked example

Take a hypothetical booking platform: a web front end, a job runner, a payments provider
integration, a notifications provider integration, and an on-call rota.

**Structural axis** — one directory per artifact class, mirroring the repo:

| Directory | Holds |
| --- | --- |
| `services/` | Each deployable service, one concept per service |
| `integrations/` | Each third-party provider the system talks to |
| `operations/` | Environments, runbooks, deployment topology |
| `interfaces/` | Public entry points — routes, endpoints, queues |

**Semantic axis** — one directory, `domains/`, re-grouping the same artifacts by purpose:

| Concept | Pulls together |
| --- | --- |
| `domains/booking.md` | The reservation service, the availability store, the booking routes |
| `domains/billing.md` | The payments integration, the invoice job, the refund runbook |
| `domains/messaging.md` | The notifications integration, the template store, the send job |

Note what happened: `integrations/payments-provider.md` is a member of `domains/billing.md`, and it
is written once and linked from both. The domain concept does not restate it.

**Conceptual axis** — the knowledge that has no file:

| Directory | Holds |
| --- | --- |
| `architecture/` | The service boundary decision, the data-flow model, the auth model |
| `knowledge/` | Institutional facts: why the legacy queue is still there, what broke in the last incident |
| `process/` | How work moves — including `process/vault-maintenance.md`, which ships in the bundle |

**`domains/` is the axis teams forget.** It is also the one that decides whether the vault is
usable. A newcomer does not ask "what is in `services/`" — they ask "how does billing work". If
the only answer is a directory listing of artifacts, you have built a file browser with
frontmatter. Budget real curation time for `domains/`: each domain concept is a hand-written
`Members` list and a `Key Flows` narrative, and it is the highest-leverage writing in the vault.

A useful sizing check: if you cannot name three to seven domains, you either have not talked to
the people who sell the product, or your system is small enough that `domains/` can wait.

---

## Step 4 — Define your types

Keep all 12 stack-agnostic types that ship in `vault-config.json`: `domain`, `architecture`,
`integration`, `environment`, `runbook`, `process`, `pattern`, `adr`, `sop`, `agent-role`, `skill`,
`guide`. They cost nothing if unused, and removing one is a config edit you can make later.

Add a type when an artifact class has **a repeating shape** — the same questions get asked of every
instance. If you cannot name the fixed sections, you do not have a type yet; you have a directory.

Rules for every type you add:

- Sections are **fixed and ordered**, and the last one is `Citations`.
- Set `resource_required: true` when every instance maps to one primary file.
- Set `stub: true` when the knowledge already lives in a source-of-truth document. The validator
  then requires an out-of-bundle citation, which is what stops the concept quietly becoming a
  second copy.
- Add a matching template under `_meta/templates/` carrying per-section length budgets.

### Worked example: adding a `job` type

The booking platform runs scheduled jobs. Every job raises the same four questions: what does it
do, when does it fire, what does it touch, what happens when it fails.

Add to `types` in `{{VAULT_ROOT}}/_meta/vault-config.json`:

```json
"job": {
  "sections": ["Overview", "Schedule & Trigger", "Data Touched", "Failure Modes", "Citations"],
  "resource_required": true
}
```

Then create `{{VAULT_ROOT}}/_meta/templates/job.md` with the length budgets inline:

```markdown
---
type: job
title: "{{JOB_NAME}}"
description: "One sentence, under 160 chars, saying what this job does."
resource: "{{PATH_TO_JOB_ENTRY_FILE}}"
tags: [{{TAG}}]
timestamp: {{YYYY-MM-DD}}
status: active
domain: {{DOMAIN}}
verified_against: "{{SHORT_SHA}}"
---

# {{JOB_NAME}}

## Overview

2-4 sentences. What it does and why it exists. No implementation detail.

## Schedule & Trigger

2-4 bullets. Cadence, trigger mechanism, concurrency limits. Name config keys, never values.

## Data Touched

3-6 bullets. Stores read and written. Link to concepts by title; never link code files.

## Failure Modes

3-6 bullets. What fails, how it surfaces, which runbook responds. Link the runbook concept.

## Citations

Links to source-of-truth docs and external references only.
```

The budgets are not decoration. They are the mechanism that keeps a concept a map-card instead of a
second copy of the code.

Validate after every type you add — a typo in `sections` fails loudly and immediately:

```bash
node knowledge-vault/scripts/validate-vault.mjs --vault {{VAULT_ROOT}}
```

---

## Step 5 — Run the build

Open [BUILD-PROMPT.md](BUILD-PROMPT.md), fill in its placeholders, and run it. Four phases:

| Phase | What you are doing | Done when |
| --- | --- | --- |
| **1 Extract** | Agents read source by artifact class and write fact digests into the manifest's `notes` | Every planned concept has a manifest entry with `notes` and a `batch` |
| **2 Generate** | Fan out by batch; each agent gets the four-part prompt | Every manifest entry has a file on disk |
| **3 Navigate** | Index cascade, `start-here.md`, canvases, Bases views | `--strict-orphans` passes |
| **4 Verify** | Independent agents try to **refute** the claims | Every finding corrected, nothing outstanding |

Two things to plan for rather than discover:

- **Extraction before generation is not optional sequencing.** Generation agents work from the
  digests, not from source. If `notes` is thin, the concepts will be thin, and you will not notice
  until Phase 4.
- **Run the validator with `--allow-broken-links` during Phases 1-3, and without it from Phase 4
  on.** Mid-build, concepts legitimately reference siblings that do not exist yet. Once generation
  is complete, a broken link is a defect.

Phase 4 is where adopters are tempted to save time. Do not. On the reference build, 14 adversarial
verifiers produced 25 evidence-backed findings, all corrected before the vault shipped. A vault
nobody tried to falsify is a rumour with good formatting.

---

## Step 6 — Gate it

A vault that is not gated decays silently. Two gates, both required before merge.

```bash
node knowledge-vault/scripts/validate-vault.mjs --vault {{VAULT_ROOT}} --strict-orphans
{{MARKDOWN_LINT_COMMAND}}
```

Then wire the validator into CI:

```bash
cp knowledge-vault/templates/github/validate-vault.yml .github/workflows/
```

Edit the copied workflow so its vault path is `{{VAULT_ROOT}}`, commit it, and open a deliberately
broken pull request — delete a linked concept, or point a `resource` at a path that does not
exist — to confirm the check actually fails. A gate you have never seen go red is not a gate.

**Be explicit with your team about why this step exists.** In the reference project the validator
was written, it passed locally, and it was wired into **no** workflow. Drift was therefore
invisible to CI, and an external architecture audit had to catch it. The tooling was fine; the
wiring was missing. That is the failure mode this step exists to prevent, and it costs one file
copy to avoid.

Do not run CI with `--allow-broken-links`. It exists for mid-build only, and a CI job carrying it
reports green on exactly the problems the validator was written to find.

---

## Step 7 — Maintain it

The maintenance loop lives in `process/vault-maintenance.md` in the bundle and in the `vault-sync`
skill. The loop:

1. Compute drift: `git diff --name-only {{BASELINE_SHA}}..HEAD -- {{WATCH_LIST}}`
2. A concept is stale **if and only if** a changed path matches its `resource` or its `sources`
3. Re-derive the stale concepts **from source** — do not patch prose to match a changed API
   without opening the file
4. Bump `timestamp` and `verified_against` on what you actually re-verified, and only that
5. Validate, prepend a dated entry to `log.md`, update `baseline_sha` in the manifest

Two rules carry the loop:

- **Deleted source becomes `status: deprecated`, never a deleted file.** Clean inbound links
  first, in a follow-up change. Deleting immediately breaks the graph and the manifest.
- **A citation is not re-verification.** Linking a concept from a new place does not make its
  claims fresher. Only re-deriving it from source bumps `timestamp` and `verified_against`. Without
  this rule, timestamps launder themselves and the falsifiability mechanism — the entire reason to
  build a vault instead of a wiki — quietly stops meaning anything.

Run the loop on a cadence that matches your merge rate. Weekly is a reasonable default; after any
large refactor, immediately.

---

## File the work

Copy the block below into your tracker. Replace `{{TICKET_PREFIX}}`, `{{VAULT_ROOT}}`,
`{{PROJECT}}`, and `{{WATCH_LIST}}`. Story numbering assumes the epic is filed first.

```text
EPIC {{TICKET_PREFIX}}-100 — Build the {{PROJECT}} knowledge vault

Goal
Stand up an OKF knowledge vault for {{PROJECT}} at {{VAULT_ROOT}} whose staleness is computable,
whose links are validated in CI, and whose claims have survived adversarial review.

Scope
In:  taxonomy, type catalog, extraction, generation, navigation, verification, CI gate.
Out: rewriting existing source-of-truth docs. The vault links them; it does not replace them.

Acceptance criteria
- validate-vault.mjs --vault {{VAULT_ROOT}} --strict-orphans exits 0.
- Markdown lint passes on {{VAULT_ROOT}}.
- .github/workflows/validate-vault.yml runs the validator on every PR and has been observed to
  fail on a deliberately broken PR.
- manifest.json baseline_sha is a real short SHA; every concept has timestamp + verified_against.
- Every Phase 4 verifier finding is either corrected or closed with a written rationale.

Definition of done
Epic closes only when all six stories are closed and the CI gate is required on the default branch.
```

```text
STORY {{TICKET_PREFIX}}-101 — Scaffold the vault and prove the validator

Description
Copy the starter bundle to {{VAULT_ROOT}} and configure it for this repo. Establish that the
validator runs clean before any content exists, so later failures are attributable to content.

Acceptance criteria
- validate-vault.mjs --vault knowledge-vault/templates/starter-bundle exits 0 (tooling proven).
- {{VAULT_ROOT}} exists, copied from the starter bundle, template left unmodified.
- vault-config.json: bundle_root = {{VAULT_ROOT}}; obsidian_vault_root = its parent directory.
- validate-vault.mjs --vault {{VAULT_ROOT}} exits 0 with no bundle_root warning.
- If Obsidian is used: useMarkdownLinks true, newLinkFormat relative, alwaysUpdateLinks true,
  committed to the repo.

Estimate: 1 point
```

```text
STORY {{TICKET_PREFIX}}-102 — Define taxonomy and type catalog

Description
Decide the three-axis directory structure and the artifact types for this stack. Blocks all
extraction and generation work.

Acceptance criteria
- Directory plan documented in the ticket, with each directory assigned to exactly one axis
  (structural / semantic / conceptual).
- domains/ is populated with 3-7 domains named in the language the business uses, each reviewed by
  someone outside the authoring team.
- vault-config.json: domains and tags set to real project vocabulary (no empty arrays).
- Every added type declares fixed ordered sections ending in Citations; resource_required and stub
  set deliberately, with the reason recorded in the ticket.
- Every added type has a matching template in _meta/templates/ carrying per-section length budgets.
- validate-vault.mjs --vault {{VAULT_ROOT}} exits 0 after config changes.

Blocked by: {{TICKET_PREFIX}}-101
Estimate: 3 points
```

```text
STORY {{TICKET_PREFIX}}-103 — Phase 1: extract facts into the manifest

Description
Run extraction agents by artifact class. Output is fact digests in each manifest entry's notes
field, not prose concepts. Generation reads these digests instead of re-reading source.

Acceptance criteria
- Every planned concept has a manifest entry with: id, type, title, path, description, tags, batch.
- Every entry has a non-empty notes digest sourced from code, not from documentation.
- Where code and docs disagree, the digest records the code behaviour and flags the discrepancy.
- The manifest sources field maps source paths back to the concepts describing them.
- baseline_sha is set to the real short SHA the extraction was run against.
- No concept files written in this story. Extraction produces digests only.

Blocked by: {{TICKET_PREFIX}}-102
Estimate: 5 points
```

```text
STORY {{TICKET_PREFIX}}-104 — Phase 2: generate concepts

Description
Fan out generation agents by batch. Every agent prompt carries exactly four inputs: the type
template, a golden example of the same type, the hard rules inline, and the manifest ID registry
as the link allowlist.

Acceptance criteria
- Every manifest entry has a corresponding file on disk; no file exists outside the manifest.
- Every concept: exactly one H1, H2 set exactly matching its type template, ends in Citations.
- Every concept carries timestamp and verified_against.
- Every link resolves to a manifest ID. Zero invented links.
- Stub-typed concepts each cite an out-of-bundle source-of-truth document.
- No concept exceeds the max_concept_lines budget without a recorded justification.
- validate-vault.mjs --vault {{VAULT_ROOT}} exits 0 without --allow-broken-links.

Blocked by: {{TICKET_PREFIX}}-103
Estimate: 8 points
```

```text
STORY {{TICKET_PREFIX}}-105 — Phase 4: adversarial verification

Description
Independent agents attempt to REFUTE the vault's claims. Verifiers must not have authored the
concepts they review. Confirmation is not the deliverable; evidence is.

Acceptance criteria
- Each verifier covers a defined slice and reports findings with file:line or a reproduced command.
- Findings without evidence are rejected and re-run.
- Every finding is triaged as wrong / minor / not-a-defect, with a one-line rationale.
- Every wrong and minor finding is corrected in the vault before this story closes.
- Concepts changed by a correction have timestamp and verified_against re-stamped.
- Finding count, triage split, and resolution recorded in the ticket for the next build to compare.

Blocked by: {{TICKET_PREFIX}}-104
Estimate: 5 points
```

```text
STORY {{TICKET_PREFIX}}-106 — Phase 3 + CI: navigation and the gate

Description
Build both doors — reference and learning — then wire the validator into CI so drift cannot land
silently.

Acceptance criteria
- Index cascade complete: root index links section indexes, section indexes link concepts, every
  link annotated rather than bare.
- start-here.md is an ordered path where every step states WHY it comes at that position, ending in
  one traced vertical slice: entry point -> handler -> the store it writes.
- At least one canvas and one saved view exist; canvas nodes reference files that exist.
- validate-vault.mjs --vault {{VAULT_ROOT}} --strict-orphans exits 0 (zero orphans).
- knowledge-vault/templates/github/validate-vault.yml copied to .github/workflows/ and pointed at
  {{VAULT_ROOT}}. The workflow does NOT pass --allow-broken-links.
- A deliberately broken PR was opened and the check was observed failing; link to that PR.
- The check is marked required on the default branch.
- process/vault-maintenance.md reflects this project's {{WATCH_LIST}} and sync cadence.

Blocked by: {{TICKET_PREFIX}}-105
Estimate: 5 points
```

---

## Related Reading

- [Knowledge Vault Guide](GUIDE.md) — the method and the reasoning behind each rule
- [Build Prompt](BUILD-PROMPT.md) — the runnable multi-agent build
- [Conventions](../templates/starter-bundle/_meta/CONVENTIONS.md) — the constitution
- [Contributing](../../CONTRIBUTING.md) — branch, commit, and PR requirements for this repo
