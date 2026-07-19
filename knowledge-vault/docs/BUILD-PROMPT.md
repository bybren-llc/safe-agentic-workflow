# Build Prompt

**Purpose**: The generic, parameterized multi-agent prompt for building a knowledge vault from an
existing codebase. This is the thing you paste into an orchestrator.

**Audience**: Whoever is running the build. Read [GUIDE.md](GUIDE.md) for why the rules are what
they are, and [ADOPTION-PLAYBOOK.md](ADOPTION-PLAYBOOK.md) for what happens before and after this
document. This file is the runnable middle.

**What this produces**: a bundle of ~50-line concepts under `{{VAULT_ROOT}}`, one per real
artifact or idea, each with structured frontmatter, each linked into a navigable graph, each
stamped with the commit its claims were checked against — plus the two navigation doors and a
green validator run. The reference build produced 227 concepts through these four phases.

---

## Fill these in first

The build will not work with placeholders left in. Resolve every one before Phase 1.

| Token | Meaning | Example |
| --- | --- | --- |
| `{{PROJECT}}` | The system being documented | `booking-platform` |
| `{{VAULT_ROOT}}` | Repo-root-relative path to the bundle | `docs/vault` |
| `{{REPO_ROOT}}` | Absolute path to the repository | `/work/booking-platform` |
| `{{BASELINE_SHA}}` | Short SHA the build is run against | output of `git rev-parse --short HEAD` |
| `{{WATCH_LIST}}` | Paths whose changes can make concepts stale | `src/ config/ docs/ migrations/` |
| `{{TAXONOMY}}` | The directory plan, one line per directory + its axis | see the playbook |
| `{{TYPE_CATALOG}}` | The `types` block from `vault-config.json` | see the playbook |
| `{{MARKDOWN_LINT_COMMAND}}` | This repo's markdown lint invocation | project-specific |

Prerequisites: the vault is scaffolded, `vault-config.json` reflects `{{TAXONOMY}}` and
`{{TYPE_CATALOG}}`, and every type has a template under `_meta/templates/`.

Throughout Phases 1-3, validate with `--allow-broken-links`. Drop that flag from Phase 4 onward.

---

## Phase 1 — Extract

**Goal**: turn source code into pre-digested facts, so generation agents never have to re-read the
repository. Output is manifest entries — `notes` digests plus a `batch` lane — not prose.

**Fan-out**: one agent per artifact class in `{{TAXONOMY}}`. Services, integrations, interfaces,
operations, jobs, and so on. Agents run in parallel and write disjoint sets of manifest entries.

**Why digests come first**: a generation agent handed raw source will summarize what it happens to
read. A generation agent handed a digest writes about what the extraction agent decided mattered.
The second is consistent across hundreds of files; the first is not. Thin digests produce thin
concepts, and you will not find out until Phase 4.

### Extraction agent prompt

````text
You are an extraction agent for the {{PROJECT}} knowledge vault. You are documenting the artifact
class: {{ARTIFACT_CLASS}}.

Your job is to gather FACTS. You are not writing concepts. Do not write any .md file.

INPUTS
- Repository root: {{REPO_ROOT}}
- Source paths in scope: {{SCOPE_PATHS}}
- The vault config: {{VAULT_ROOT}}/_meta/vault-config.json
- The current manifest: {{VAULT_ROOT}}/_meta/manifest.json

TASK
1. Enumerate every real artifact of class {{ARTIFACT_CLASS}} under {{SCOPE_PATHS}}. One artifact =
   one planned concept. Do not invent artifacts. Do not merge two real artifacts into one entry.
2. For each artifact, read the actual implementation. Read the entry file and the files it calls
   into. Do not stop at the module's own documentation.
3. Write one manifest entry per artifact into {{VAULT_ROOT}}/_meta/manifest.json with these fields:
     id           bundle-relative path minus .md, kebab-case
     type         one of the types declared in vault-config.json
     title        human title, matches the H1 the generator will write
     path         id + ".md"
     description  one sentence, under 160 characters
     tags         from the controlled vocabulary in vault-config.json only
     domain       from the domains list in vault-config.json, when one applies
     sources      every source path whose change should make this concept stale
     batch        "{{BATCH_NAME}}"
     notes        the fact digest — see below
4. Set baseline_sha to {{BASELINE_SHA}} if it is not already set.

THE NOTES DIGEST — this is the deliverable
Pipe-separated facts, dense, no prose, no hedging. Cover: what the artifact does, what it calls,
what calls it, what data it touches, which configuration keys it reads, and how it fails.
Name the helper ACTUALLY called, not the one that should be called.

Example shape:
  notes: "entry at src/x/handler.ts | validates via schema in src/x/schema.ts | writes table
  bookings | reads config KEY_A KEY_B | retries 3x then dead-letters | called by the scheduler,
  never by a route"

HARD RULES
- CODE WINS OVER DOCS. Where implementation contradicts documentation, record the implementation
  and add a "DOC DRIFT:" clause to the digest naming both sides. Do not silently pick one.
- Configuration KEY NAMES may be recorded. Configuration VALUES never may, including defaults that
  look harmless.
- If you cannot determine a fact from source, write "UNKNOWN: <question>" in the digest. Do not
  guess, and do not omit the gap silently.
- Every path you record in sources must exist on disk. The validator checks this.

OUTPUT
The updated manifest, plus a short report: artifacts found, entries written, every UNKNOWN, and
every DOC DRIFT clause.
````

**Phase 1 exit criteria**: every planned concept has a manifest entry with a non-empty `notes`
digest and a `batch`; `baseline_sha` is a real SHA; no `.md` concept files have been written.

---

## Phase 2 — Generate

**Goal**: turn digests into concepts. Fan out by `batch` — each generation agent takes one lane and
writes every concept in it.

**The key detail**: every generation agent prompt carries **exactly four things**, and dropping any
one has a predictable failure mode.

| Input | What it is | What its absence causes |
| --- | --- | --- |
| **Type template** | The frontmatter stencil and fixed section list from `_meta/templates/` | Structurally invalid files; validator fails on H2 sets |
| **Golden example** | One real, already-accepted concept of the same type | Drift — every agent invents its own voice and depth |
| **Hard rules inline** | The constitution, pasted in full, not linked | Hedging, duplication, aspirational claims |
| **Manifest ID registry** | The concept ID list, as a link allowlist | Invented links — confident references to files nobody wrote |

Template alone yields structurally-correct emptiness. Example alone yields drift. Rules alone yield
hedging. All four together yield concepts that read as though one author wrote them.

The golden example is the input teams skip because it feels redundant next to the template. It is
not. Write one concept by hand, accept it, and use it as the example for its whole type.

### Generation agent prompt

````text
You are a generation agent for the {{PROJECT}} knowledge vault. You are writing batch
{{BATCH_NAME}} — the concepts listed at the end of this prompt.

You have four inputs. Use all four. Do not go looking for a fifth.

INPUT 1 — TYPE TEMPLATE
{{PASTE_THE_FULL_TEMPLATE_FROM__meta/templates/<type>.md}}
The H2 sections are FIXED and ORDERED. Do not add, remove, rename, or reorder them. The per-section
length budgets in the template are limits, not suggestions.

INPUT 2 — GOLDEN EXAMPLE
{{PASTE_ONE_REAL_ACCEPTED_CONCEPT_OF_THE_SAME_TYPE}}
Match its voice, its density, and its level of abstraction. When the template and the example
disagree on shape, the template wins on structure and the example wins on tone.

INPUT 3 — HARD RULES
- Exactly one H1 (the title). Every section is an H2. The last H2 is "Citations".
- Frontmatter required: type, title, description (one sentence, <=160 chars), tags, timestamp,
  status. Also stamp: verified_against: "{{BASELINE_SHA}}" and timestamp: {{BUILD_DATE}}.
- YAML subset only: scalars, double-quoted strings, inline lists [a, b], two-space block lists.
  No nested maps. No multiline scalars. The validator parses without a YAML library.
- tags come from the controlled vocabulary in vault-config.json. domain comes from its domains
  list. Nothing else validates.
- SUMMARIZE, NEVER DUPLICATE. If you are restating more than a paragraph of a source document,
  stop and link to it instead. The concept is a map-card, not a copy.
- CODE WINS OVER DOCS. Name the helper actually called, not the one that should be called. If the
  digest carries a DOC DRIFT clause, state the real behaviour and note the discrepancy in one
  sentence.
- Configuration key NAMES may appear. Configuration VALUES never may.
- Links: relative markdown only. No wikilinks. No leading-slash paths. No repository-host URLs for
  files in this repo. Code files are never linked — name them as inline code, or carry them in
  resource / sources.
- Links that leave the bundle appear ONLY under "## Citations".
- Stay under the max_concept_lines budget in vault-config.json.
- No emoji.
- If the digest says UNKNOWN, write the gap into the concept as an explicit open question. Do not
  fill it with a plausible guess.

INPUT 4 — ID REGISTRY (LINK ALLOWLIST)
{{PASTE_THE_LIST_OF_EVERY_id_IN_manifest.json}}
LINK ONLY TO IDS ON THIS LIST. This is an allowlist, not a suggestion. If you want to link to a
concept that is not listed, name it in prose WITHOUT a link and report it as a suggestion at the
end of your run. NEVER INVENT LINKS. A plausible-looking broken link is worse than no link,
because it survives review.

YOUR ASSIGNMENT
{{PASTE_THE_MANIFEST_ENTRIES_FOR_THIS_BATCH_INCLUDING_THEIR_notes_DIGESTS}}
Write facts from the notes digests. Do not re-read source to add facts the digest omitted; report
the omission instead.

OUTPUT
One file per assigned entry at its manifest path, plus a report listing: files written, every
suggested-but-unlinkable concept, and every digest gap you could not resolve.
````

**Phase 2 exit criteria**: every manifest entry has a file, and every file is in the manifest;
`validate-vault.mjs --vault {{VAULT_ROOT}}` exits 0 **without** `--allow-broken-links`.

---

## Phase 3 — Navigate

**Goal**: build both doors. A vault needs a reference door and a learning door, and they are not
the same document.

### The index cascade

Root `index.md` links section indexes; section indexes link concepts. `index.md` files carry no
frontmatter — the root is the single exception, and it declares `okf_version`.

Every link is annotated. A bare list of titles is a directory listing; the annotation is the
curation, and it is the reason a reader picks one link over another.

### `start-here.md`

An ordered path where **every step states why it comes at that position**. The WHY clause is the
teaching. "Read the security model third" is a table of contents. "Read it third because
everything after this assumes it, and it is the one convention you cannot violate even once" is
onboarding.

End it with **one traced vertical slice**: a single request or job followed from entry point, to
handler, to the store it writes — every hop linked to a real concept. One concrete path through
the system beats any amount of overview, because the reader can check it against the code.

### Canvases and views

- **Canvases** — spatial maps for relationships a linear document cannot show: a domain and its
  members, a request lifecycle, a deployment topology. Canvas node paths are resolved against the
  Obsidian vault root, so they only work if `obsidian_vault_root` is set correctly.
- **Bases views** — saved queries over frontmatter. The ones that earn their keep: concepts by
  `status`, concepts by `domain`, and concepts whose `verified_against` is behind `baseline_sha`.
  The last one is the drift dashboard.

**Phase 3 exit criteria**: `validate-vault.mjs --vault {{VAULT_ROOT}} --strict-orphans` exits 0.
Zero orphans means every concept is reachable from a door.

---

## Phase 4 — Verify (adversarial)

**Goal**: try to break the vault. Verifiers are **independent** — an agent does not verify a batch
it generated — and their job is to **refute** claims, not to confirm them.

Frame the task as refutation because confirmation bias is the whole problem. An agent asked "is
this concept accurate?" will read the concept, find it coherent, and say yes. An agent asked "prove
this claim wrong" opens the file.

**Evidence is the deliverable.** Every finding carries `file:line` or a command that was actually
run with its actual output. A finding without evidence is not a finding and gets re-run.

On the reference build, 14 adversarial verifiers produced 25 evidence-backed findings — 9 outright
wrong, 16 minor — and every one was corrected before the vault shipped.

### Verifier agent prompt

````text
You are an adversarial verifier for the {{PROJECT}} knowledge vault. You did not write these
concepts. Your job is to prove them WRONG.

SCOPE
{{LIST_OF_CONCEPT_FILES_TO_VERIFY}}

STANCE
Assume each concept contains an error and find it. You are not reviewing for style, tone, or
completeness. You are looking for claims that are FALSE about the code as it exists at
{{BASELINE_SHA}}. Do not report that a concept is "good" — that is not an output.

METHOD
For each concept, for each factual claim:
1. Open the file named in resource or sources. Read the implementation. Do not read the concept's
   own citations and stop there.
2. Check specifically for:
   - A named helper, function, module, or table that does not exist, or is not the one called
   - A described control flow that the code does not follow
   - A stated failure or retry behaviour the code does not implement
   - A configuration key that is not read where the concept says it is read
   - A claim that matches the DOCUMENTATION but contradicts the CODE (code wins; this is a finding)
   - A link whose target concept does not describe what the link text implies
   - A stub-typed concept that restates its source instead of citing it
   - resource / sources paths that do not exist on disk
3. Where a claim is testable by running something, run it and record the real output.

EVIDENCE REQUIREMENT
Every finding MUST carry either:
   file:line   e.g. src/x/handler.ts:142 — the concept says it retries; the code throws
   a command   the exact command you ran and its actual output, pasted
Findings without evidence are rejected and re-run. Do not infer, do not reason from naming, and do
not report a suspicion as a finding.

SEVERITY
   wrong  — the claim is false and would mislead a reader into an incorrect action
   minor  — imprecise, incomplete, or stale wording that does not mislead
Report the count of each. Do not inflate severity to look thorough.

OUTPUT
A findings list. Each entry: concept id, claim quoted verbatim, evidence, severity, and the
corrected wording you propose. If you found nothing in a concept after actually opening its
sources, say so explicitly and name the files you opened.
````

### Closing the phase

Every finding is triaged as wrong / minor / not-a-defect with a one-line rationale. Every wrong and
minor finding is **corrected before merge** — findings that ship as a backlog item are findings
that never get fixed. Concepts changed by a correction get `timestamp` and `verified_against`
re-stamped, because they were genuinely re-derived from source.

Record the finding count and triage split. The next build compares against it.

**Phase 4 exit criteria**: zero outstanding findings; validator and markdown lint both pass without
softening flags.

---

## The non-negotiables

The checklist. If a build is going wrong, it is almost always one of these.

- [ ] **Link only to manifest IDs.** The manifest is an allowlist. A concept you want but do not
      have gets named in prose without a link and reported as a suggestion. Never invent links.
- [ ] **Stub, don't duplicate.** If the knowledge lives in a source-of-truth document, the concept
      is a map-card that cites it. Restating more than a paragraph means stop and link.
- [ ] **Code wins over docs.** Name the helper actually called. When code and documentation
      disagree, record the code and note the discrepancy.
- [ ] **Stamp `verified_against` and `timestamp`.** Both, on every concept, on every re-derivation.
      And a citation is not re-verification — only re-reading the source bumps them.
- [ ] **Validator and markdown lint must pass.** `validate-vault.mjs --vault {{VAULT_ROOT}}
      --strict-orphans` and `{{MARKDOWN_LINT_COMMAND}}`, both clean, with no `--allow-broken-links`
      after Phase 3.

---

## Related Reading

- [Knowledge Vault Guide](GUIDE.md) — the method and the reasoning
- [Adoption Playbook](ADOPTION-PLAYBOOK.md) — scaffolding, taxonomy, CI gate, maintenance
- [Conventions](../templates/starter-bundle/_meta/CONVENTIONS.md) — the constitution in full
