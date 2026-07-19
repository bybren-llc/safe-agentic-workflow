# Knowledge Vault Guide

**Purpose**: Explain the OKF knowledge-vault method — what it is, why each rule exists, and how a
knowledge base stays true as the code moves under it.

**Audience**: Anyone adopting the harness who wants their agents and their humans working from the
same map.

**Core belief**: A knowledge base that cannot be proven stale will become confidently wrong, and
confidently wrong is worse than absent. Everything below serves making staleness **computable**.

---

## What This Is

A **vault** is a bundle of small markdown concepts — one per real artifact or idea — each carrying
structured frontmatter, each linking to its neighbours, and each recording the commit its claims
were checked against.

It is a **map, not the territory**. Source-of-truth documents stay where they live. Code stays
authoritative over everything, including the vault. A concept is a ~50-line map-card that
summarizes and links; it never restates its source.

Built on [Open Knowledge Format v0.1](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
(Google, Apache-2.0) — an open spec for portable markdown knowledge bundles. OKF requires only a
`type` field and keeps conformance deliberately loose so that consumers never reject a bundle.

**This harness adds the rigor layer on top**: a strict frontmatter contract, a zero-dependency
validator, an anti-hallucination link discipline, and the verification mechanism that makes the
whole thing falsifiable. OKF gives portability. The rules below give trust.

---

## Why Bother

The honest case, from the project this method came from: an independent architecture audit of that
codebase scored twelve dimensions and found documentation to be one of the weak ones — **except**
for the vault, which it recorded as *"the single strongest KT asset in the repo"* and instructed
new developers to **trust over the project's own canonical `CLAUDE.md`**, because the vault's
version claims were verified against a SHA and the canonical file's had silently drifted.

That is the whole argument. Not that a vault is tidy — that it is **checkable**, and therefore
beats hand-maintained prose the moment the two disagree.

---

## The Eight Ideas

### 1. Two-level falsifiability: `verified_against` and `baseline_sha`

Every concept records `verified_against` — the git SHA at which its claims were checked — and
`timestamp`, the date of that check. The manifest records `baseline_sha`: the commit the vault as
a whole was last verified against.

Drift is then a computation, not a feeling:

```bash
git diff --name-only "$BASELINE"..HEAD -- <watch-list>
```

A concept is stale **if and only if** a changed path matches its `resource` or one of its
`sources`. File-level truth. Not "docs older than 90 days", which flags everything and teaches
people to ignore the flag.

**And the discipline that keeps it honest: a citation is not re-verification.** Linking a concept
from somewhere new does not make its claims fresher. Only re-deriving it from source bumps the
pair. Without this rule, timestamps launder themselves and the whole mechanism rots.

### 2. The anti-hallucination link rule

> Link only to concept IDs listed in the manifest. If a concept you want does not exist, name it
> in prose without a link and report it as a suggestion. **Never invent links.**

The manifest is an **allowlist**. This single rule is what makes it possible to generate hundreds
of concepts with dozens of parallel agents and get a coherent graph out, rather than a web of
plausible-looking links to files nobody wrote. An agent asked to "link related concepts" will
otherwise produce beautiful, confident, broken references.

### 3. The four-part generation prompt

Every generation agent gets exactly four things:

1. **The type template** — the frontmatter stencil and the fixed section list
2. **A golden example** — one real, already-accepted concept of the same type
3. **The hard rules** — the constitution, inline
4. **The ID registry** — the manifest, as the link allowlist

Template alone yields structurally-correct emptiness. Example alone yields drift. Rules alone
yield hedging. All four together yield concepts that look like one author wrote them.

### 4. Stub, don't duplicate

If the knowledge already lives in a source-of-truth document, the concept is a map-card that cites
it — an abstract, the links that place it in the system, and nothing more.

> If you are restating more than a paragraph, stop and link.

Types flagged `stub` in the config are validated for this: they must carry an out-of-bundle
citation. A stub that restates its source is now two things to maintain, and they will diverge.

### 5. Code wins over docs

> Name the helper actually called, not the one the code *should* call. When code contradicts
> documentation, the code wins and the discrepancy is noted.

This is what makes a vault worth reading. Aspirational documentation is the default failure mode
of every knowledge base; a concept that records a deliberate deviation — and says it is one — is
more valuable than one describing the intended design.

### 6. The three-axis taxonomy

Directories are not one hierarchy but three orthogonal ones:

| Axis | Organizes by | Example dirs |
| --- | --- | --- |
| **Structural** | real artifacts, mirroring the repo | `lib/`, `integrations/`, `operations/` |
| **Semantic** | business domain — a curated cross-cut | `domains/` |
| **Conceptual** | cross-cutting views and institutional knowledge | `architecture/`, `knowledge/` |

The semantic axis is the one people forget, and the one that makes a vault navigable **by intent**
rather than by file location. A newcomer does not ask "what is in `lib/`" — they ask "how does
billing work". `domains/` answers that by re-grouping artifacts around purpose.

### 7. The GUI/validator treaty

If you use Obsidian, three settings are non-negotiable:

```json
{ "useMarkdownLinks": true, "newLinkFormat": "relative", "alwaysUpdateLinks": true }
```

Without them, every link the GUI creates is a wikilink, and wikilinks fail validation. With them,
the editor and the validator want the same thing, and renaming a note rewrites its inbound links
automatically. Three lines that decide whether the tooling fights you.

### 8. Two-door navigation

A vault needs a **reference** door and a **learning** door, and they are not the same document.

- `index.md` — the cascade. Root index links section indexes link concepts. Curated, annotated,
  browsable. For people who know what they are looking for.
- `start-here.md` — an ordered path where **every step states why it comes there**, ending in one
  traced vertical slice: an entry point, to the handler, to the store it writes.

That WHY clause is the teaching. "Read the security model third" is a table of contents; "read it
third because everything after assumes it, and it is the one convention you cannot violate even
once" is onboarding.

---

## How a Vault Gets Built

Four phases, run as a multi-agent pipeline. The reference build produced 227 concepts this way.

| Phase | What it does | Output |
| --- | --- | --- |
| **Extract** | Read source, gather facts per artifact class | Fact digests into the manifest's `notes` |
| **Generate** | Fan out by batch, four-part prompt each | Concepts |
| **Navigate** | Build the doors | Indexes, `start-here.md`, canvases, views |
| **Verify** | Independent agents try to **break** each claim | Findings — all corrected before merge |

The verify phase is not optional polish. On the reference build, 14 adversarial verifiers produced
25 evidence-backed findings — 9 outright wrong, 16 minor — every one corrected before the vault
shipped. A knowledge base nobody tried to falsify is a rumour with good formatting.

See [BUILD-PROMPT.md](BUILD-PROMPT.md) for the runnable version.

---

## How a Vault Stays True

The `vault-sync` skill encodes the maintenance loop: detect drift from `baseline_sha`, detect
inventory changes, regenerate **only** what drifted, validate, record.

Two rules do the heavy lifting:

- **Deleted source → `status: deprecated`, never file deletion.** Inbound links must be cleaned
  first, in a follow-up change. Deleting immediately breaks the graph.
- **Re-derive from source; never patch prose without re-reading the code it describes.** Editing a
  concept to match a changed API without opening the file is how a vault becomes fiction.

---

## The Validator

`scripts/validate-vault.mjs` — zero dependencies, `node:` builtins only, so it runs anywhere Node
runs with no install step.

It enforces: the frontmatter contract, exact section structure per type, link legality (no
wikilinks, no leading-slash paths, no repository-host URLs for repo files), that `resource` /
`sources` / `docs` paths actually exist, that stub types cite their source, that canvas nodes
reference real files, manifest/disk agreement in both directions, and orphan detection.

```bash
node knowledge-vault/scripts/validate-vault.mjs --vault path/to/your/vault
```

Exit 0 means no errors; warnings are allowed. `--strict-orphans` promotes orphan warnings to
errors. `--allow-broken-links` softens link and manifest errors during an early build — use it
while building, never in CI.

**Wire it into CI.** An opt-in workflow template ships at
`knowledge-vault/templates/github/validate-vault.yml`. This matters: in the reference project the
validator existed, passed locally, and was wired into **no** workflow — so drift was invisible to
CI, and an audit had to catch it. Do not inherit that gap.

---

## Adapting It To Your Project

The 12 types shipped in the starter config are **stack-agnostic**: `domain`, `architecture`,
`integration`, `environment`, `runbook`, `process`, `pattern`, `adr`, `sop`, `agent-role`, `skill`,
`guide`.

Types for *your* artifacts are yours to define. A web application might add:

```json
"api-endpoint": {
  "sections": ["Overview", "Auth & Access", "Request & Response",
               "Data Access", "Patterns Applied", "Citations"],
  "resource_required": true
}
```

A data platform might add `pipeline` or `dataset`. A mobile app, `screen` or `feature-module`.
The rule is the same in every case: **fixed sections, ordered, ending in `Citations`**, with a
matching template that carries per-section length budgets ("2-4 sentences", "3-6 bullets"). Those
budgets are what stop concepts sprawling back into duplication.

---

## Related Reading

- [Adoption Playbook](ADOPTION-PLAYBOOK.md) — run your first build
- [Build Prompt](BUILD-PROMPT.md) — the generic multi-agent build prompt
- [Conventions](../templates/starter-bundle/_meta/CONVENTIONS.md) — the constitution
- [Obsidian Guide](OBSIDIAN-GUIDE.md) — graph, canvases, and Bases
- [OKF Specification](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
