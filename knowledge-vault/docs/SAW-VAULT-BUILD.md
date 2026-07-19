# SAW Vault Build

**Purpose**: The runnable, pre-scoped prompt for building this repository's own knowledge vault.

**Audience**: Maintainers of this repo. Not a template — every path, count, and batch below was
enumerated against this working tree and is meant to be executed as written.

**Method**: [GUIDE.md](GUIDE.md) explains *why* each rule exists. [BUILD-PROMPT.md](BUILD-PROMPT.md)
is the stack-neutral version. This document does not repeat either; it supplies the parameters they
leave blank.

**Enumerated against**: commit `f03e213`, branch `SAW-45-okf-knowledge-vault-subsystem`.

---

## Why This Repo Is The Ideal Dogfood

This harness is not a web application. It has no HTTP routes, no ORM, no database tables, no
payment provider. That is exactly what makes it the right first external build.

The starter config ships twelve **stack-agnostic** types — `domain`, `architecture`, `integration`,
`environment`, `runbook`, `process`, `pattern`, `adr`, `sop`, `agent-role`, `skill`, `guide` — and
deliberately omits the web-app-shaped types (`api-endpoint`, `database-table`, `page-route`) that
the reference build needed. The claim embedded in that decision is that the twelve are genuinely
portable and the omitted ones were correctly identified as local.

Building this vault tests that claim under adversarial conditions:

- If the twelve types cover this repo's artifacts with only a handful of additions, the
  genericization holds.
- If concepts here come out shaped like they are describing something they are not, the starter
  config over-fitted to its source and the fix is upstream, not local.

Two specific stresses worth naming before starting:

1. **`adr` has no source.** There is no `docs/adr/` directory in this repo. The type is
   `resource_required: true` and `stub: true`, so it cannot be used without inventing a source.
   Either the harness grows an ADR practice or the type sits unused here. Do not fabricate ADRs to
   fill the slot.
2. **`pattern` describes shipped templates, not live code.** The eighteen files under
   `patterns_library/` are reference implementations the harness distributes; they are not called by
   anything in this repo. The "code wins over docs" rule has to be read carefully — the exemplar
   *is* the artifact.

---

## Scope: What Gets Mapped

All counts below were produced by running the enumeration commands in
[Appendix A](#appendix-a--enumeration-commands) against the working tree. Re-run them before
starting; if a number has moved, use the new one.

### Provider surfaces and agent configuration

| Artifact class | Concept type | Count | Batch lane |
| --- | --- | --- | --- |
| Provider surfaces (`.claude`, `.gemini`, `.codex`, `.cursor`, `.agents`) | `provider` | 5 | `providers` |
| Agent role definitions (`.claude/agents/*.md`, excl. README) | `agent-role` | 11 | `roles` |
| Codex role mirrors (`.codex/agents/*.toml`) | folded into `agent-role` | 11 | `roles` |
| Augment role prompts (`agent_providers/claude_code/prompts/*.md`) | folded into `agent-role` | 11 | `roles` |
| Skills (`.claude/skills/*/SKILL.md`) | `skill` | 20 | `skills-a`, `skills-b` |
| Portable skill mirrors (`.agents/skills/*/SKILL.md`) | folded into `skill` | 20 | `skills-a`, `skills-b` |
| Claude slash commands (`.claude/commands/*.md`, excl. README) | `command` | 24 | `commands-a`, `commands-b` |
| Gemini media commands (no Claude counterpart) | `command` | 11 | `commands-c` |
| Cursor rules (`.cursor/rules/*.mdc`), grouped into families | `guide` | 4 | `providers` |
| Claude hooks (`.claude/hooks/*.sh`) | `script` | 3 | `providers` |
| Augment rules (`agent_providers/augment/rules/*.md`) | `guide` | 6 | `providers` |

Notes on folding:

- The eleven Codex TOML agents and eleven Augment prompt files are **the same eleven roles** in
  other providers' formats. One `agent-role` concept per role, carrying all three paths in
  `sources`. Do not write thirty-three role concepts.
- Same for skills: `.claude/skills/<n>/SKILL.md` and `.agents/skills/<n>/SKILL.md` are one skill.
- Gemini has 30 TOML commands. Nineteen mirror Claude commands (fold them in); eleven under
  `.gemini/commands/media/` have no Claude counterpart and get their own concepts.
- Eighteen cursor rules grouped into four `guide` concepts by prefix family:
  core (`00`–`02`), methodology (`03`–`04`), stack (`10`–`16`), agent and background (`20`–`31`).
  Eighteen separate concepts for files this small would be granularity without navigational value.

### The sync engine

| Artifact class | Concept type | Count | Batch lane |
| --- | --- | --- | --- |
| `scripts/sync-claude-harness.sh` | `architecture` | 1 | `sync` |
| `.harness-manifest.schema.json` + `.harness-manifest.yml` | `architecture` | 1 | `sync` |
| `sync_scope` semantics (multi-domain resolution) | `process` | 1 | `sync` |
| Shell test suites (`tests/test-*.sh`) | `test-suite` | 9 | `sync` |
| Sync fixtures (`tests/fixtures/sync/*`) + `examples/manifests/*` | `guide` | 1 | `sync` |
| Remaining `scripts/*` (10 files) | `script` | 10 | `operations` |

`scripts/` holds 11 files total; `sync-claude-harness.sh` is pulled out as `architecture` above, so
the remaining 10 become `script` concepts.

### Subsystems

| Artifact class | Concept type | Count | Batch lane |
| --- | --- | --- | --- |
| Dark factory (overview of the subsystem) | `architecture` | 1 | `subsystems` |
| Dark factory operator scripts (`dark-factory/scripts/*.sh`) | `runbook` | 5 | `subsystems` |
| Dark factory team layouts (`templates/team-layouts/*.sh`) | `runbook` | 3 | `subsystems` |
| Dark factory guides (`dark-factory/docs/*.md`) | `guide` | 4 | `subsystems` |
| Dark factory tmux / env topology | `environment` | 1 | `subsystems` |
| Pattern library (overview) | `architecture` | 1 | `patterns` |
| Patterns (`patterns_library/*/*.md`, excl. README) | `pattern` | 18 | `patterns` |
| Spec templates (`specs_templates/*.md`) | `guide` | 5 | `subsystems` |
| Lint configs (`linting_configs/`) | `guide` | 1 | `subsystems` |
| Provider assets (`agent_providers/`, overview) | `architecture` | 1 | `providers` |
| Project workflow scaffold (`project_workflow/`) | `guide` | 1 | `operations` |
| Knowledge vault subsystem (this one) | `architecture` | 1 | `subsystems` |

### Process and methodology knowledge

These have no single file to point at; they are the institutional knowledge the repo encodes.
Each cites the documents that carry it.

| Concept | Concept type | Count | Batch lane |
| --- | --- | --- | --- |
| Three-Layer Architecture (hooks / commands / skills) | `architecture` | 1 | `methodology` |
| vNext Workflow Contract (v1.4) | `process` | 1 | `methodology` |
| Exit states and chain of custody | `process` | 1 | `methodology` |
| Stop-the-Line gate (AC/DoD) | `process` | 1 | `methodology` |
| Role collapsing authority | `process` | 1 | `methodology` |
| Three-stage PR review | `process` | 1 | `methodology` |
| Round Table philosophy | `guide` | 1 | `methodology` |
| Evidence-based delivery | `guide` | 1 | `methodology` |
| Pattern discovery protocol | `process` | 1 | `methodology` |
| SAFe x AI-DLC methodology layer | `process` | 1 | `methodology` |
| Domain adaptation (non-SWE teams) | `guide` | 1 | `methodology` |
| Harness sync and fork workflow | `process` | 1 | `sync` |

### Operations

| Artifact class | Concept type | Count | Batch lane |
| --- | --- | --- | --- |
| GitHub workflows (`.github/workflows/*.yml`) | `integration` | 4 | `operations` |
| Release process (`scripts/generate-changelog.sh`, `HARNESS_CHANGELOG.yml`) | `process` | 1 | `operations` |
| Pre-release checklist (`docs/release/PRE-RELEASE-CHECKLIST.md`) | `sop` | 1 | `operations` |
| Version upgrade notes (`docs/releases/*.md`) | `guide` | 1 | `operations` |

### Source-of-truth document stubs

The repo holds 68 files under `docs/`. Not all warrant a concept: `docs/archive/` (5 files),
`docs/agent-outputs/qa-validations/` (9 files), and the four `REORGANIZATION-*` reports are
historical records, not live knowledge. Skip them and say so in the log.

| Directory | Files | Concept type | Count | Batch lane |
| --- | --- | --- | --- | --- |
| `docs/guides/` | 8 | `guide` | 8 | `docs-a` |
| `docs/sop/` | 3 | `sop` | 3 | `docs-a` |
| `docs/onboarding/` | 6 | `guide` | 6 | `docs-a` |
| `docs/workflow/` | 6 | `process` | 6 | `docs-b` |
| `docs/whitepapers/` | 6 | `guide` | 6 | `docs-b` |
| `docs/database/` | 4 | `guide` | 4 | `docs-b` |
| `docs/security/` | 2 | `guide` | 2 | `docs-b` |
| `docs/ci-cd/` | 2 | `guide` | 2 | `operations` |
| `docs/team/`, `docs/templates/`, `docs/patterns/` | 3 | `guide` | 3 | `docs-b` |
| `docs/HARNESS_SYNC_GUIDE.md`, `docs/HARNESS_MANIFEST_SCHEMA.md` | 2 | `guide` | 2 | `sync` |
| Root docs (`README`, `AGENTS`, `CONTRIBUTING`, `CLAUDE`, `TEMPLATE_SETUP`, `SECURITY`) | 6 | `guide` | 6 | `docs-a` |

### Domains and navigation

| Item | Concept type | Count | Batch lane |
| --- | --- | --- | --- |
| Domain concepts (see config below) | `domain` | 5 | `navigation` |
| `index.md` cascade (root + one per section directory) | reserved | ~12 | `navigation` |
| `start-here.md` | `guide` | 1 | `navigation` |
| `log.md` | reserved | 1 | `navigation` |
| Canvases (`maps/*.canvas`) | reserved | 2 | `navigation` |
| Bases (`bases/*.base`) | reserved | 4 | `navigation` |

**Estimated concept total: roughly 200.** This is an estimate derived from the counts above, not a
target. Do not pad toward it and do not merge concepts to stay under it.

---

## The SAW `vault-config.json`

Drop this at `docs/knowledge-vault/_meta/vault-config.json`. It is the starter config with
`bundle_root`, `obsidian_vault_root`, `domains`, `tags`, and four added types changed.

```json
{
  "okf_version": "0.1",
  "bundle_root": "docs/knowledge-vault",
  "obsidian_vault_root": ".",

  "domains": ["methodology", "providers", "sync", "subsystems", "operations"],

  "statuses": ["active", "deprecated", "experimental", "planned"],

  "max_concept_lines": 60,

  "frontmatter": {
    "required": ["type", "title", "description", "tags", "timestamp", "status"],
    "optional": [
      "resource",
      "domain",
      "ticket",
      "sources",
      "docs",
      "verified_against",
      "okf_version"
    ],
    "max_description_length": 160,
    "path_fields": ["resource", "sources", "docs"]
  },

  "link_rules": {
    "style": "relative-markdown",
    "concept_links_stay_in_bundle": true,
    "external_repo_links_only_under": "Citations",
    "forbidden": ["wikilinks", "leading-slash-paths", "github-urls-for-repo-files"]
  },

  "tags": [
    "methodology",
    "providers",
    "sync",
    "subsystems",
    "operations",

    "agents",
    "skills",
    "commands",
    "hooks",
    "workflow",
    "gates",
    "process",
    "patterns",
    "testing",
    "ci",
    "release",
    "onboarding",
    "security",
    "orchestration",
    "ssot-stub",
    "okf"
  ],

  "types": {
    "domain": {
      "sections": ["Overview", "Members", "Key Flows", "Citations"],
      "resource_required": false
    },
    "architecture": {
      "sections": ["Overview", "Design", "Related Concepts", "Citations"],
      "resource_required": false
    },
    "integration": {
      "sections": [
        "Overview",
        "Touchpoints",
        "Configuration",
        "Failure Modes & Health",
        "Citations"
      ],
      "resource_required": false
    },
    "environment": {
      "sections": ["Overview", "Topology", "Access & Deployment", "Citations"],
      "resource_required": false
    },
    "runbook": {
      "sections": ["Overview", "When To Use", "Procedure Map", "Citations"],
      "resource_required": false
    },
    "process": {
      "sections": ["Overview", "Flow", "Roles Involved", "Citations"],
      "resource_required": false
    },
    "pattern": {
      "sections": ["Overview", "Exemplars", "Citations"],
      "resource_required": true,
      "stub": true
    },
    "adr": {
      "sections": ["Overview", "Decision", "Affected Concepts", "Citations"],
      "resource_required": true,
      "stub": true
    },
    "sop": {
      "sections": ["Overview", "When It Applies", "Affected Concepts", "Citations"],
      "resource_required": true,
      "stub": true
    },
    "agent-role": {
      "sections": [
        "Overview",
        "Responsibilities",
        "Skills & SOPs",
        "Handoffs",
        "Citations"
      ],
      "resource_required": true,
      "stub": true
    },
    "skill": {
      "sections": ["Overview", "Routes To", "Used By Roles", "Citations"],
      "resource_required": true,
      "stub": true
    },
    "provider": {
      "sections": [
        "Overview",
        "Surface Layout",
        "Capabilities Exposed",
        "Sync & Parity",
        "Citations"
      ],
      "resource_required": true
    },
    "command": {
      "sections": [
        "Overview",
        "Invocation",
        "What It Does",
        "Provider Parity",
        "Citations"
      ],
      "resource_required": true,
      "stub": true
    },
    "script": {
      "sections": ["Overview", "Inputs & Outputs", "Invoked By", "Citations"],
      "resource_required": true,
      "stub": true
    },
    "test-suite": {
      "sections": ["Overview", "What It Proves", "Fixtures", "Citations"],
      "resource_required": true,
      "stub": true
    },
    "guide": {
      "sections": [],
      "resource_required": false
    },
    "meta": {
      "sections": [],
      "resource_required": false,
      "internal": true
    },
    "template": {
      "sections": [],
      "resource_required": false,
      "internal": true
    }
  }
}
```

### Why these four additions

- **`provider`** — a provider surface is a whole configuration dialect, not an integration with a
  third party. It needs a **Sync & Parity** section, because parity across the five surfaces is the
  thing that actually breaks.
- **`command`** — a slash command has a fixed shape: invocation, effect, whether the other providers
  carry it. `runbook` has nowhere to record parity; `skill` implies model invocation rather than
  user invocation.
- **`script`** — shell entry points need **Inputs & Outputs** and **Invoked By**. `runbook`
  describes a human procedure; a script is an artifact with a call graph.
- **`test-suite`** — **What It Proves** is the load-bearing section, and no shipped type has it.
  Without it, a test concept degrades into a restatement of the file listing.

All four end in `Citations`, all four have fixed ordered sections, and the three stub types require
an out-of-bundle citation — matching the constitution in
[CONVENTIONS.md](../templates/starter-bundle/_meta/CONVENTIONS.md).

### Two deviations from the default, deliberate

- **`obsidian_vault_root` is `"."` (repo root), not the bundle's parent `docs`.** The playbook's
  rule of thumb is "the parent of the bundle", which works when sources live under `docs/`. Here
  they do not: concepts cite `.claude/`, `.cursor/`, `tests/`, `scripts/`, `patterns_library/`. Only
  a repo-root Obsidian vault keeps those citations clickable. The field is advisory — the validator
  does not read it — so this costs nothing but must be a conscious choice.
- **Templates and matching skeletons for the four added types must be written** under
  `docs/knowledge-vault/_meta/templates/`, carrying per-section length budgets, before generation
  starts. A type in the config with no template produces structurally-correct emptiness.

---

## Directory Taxonomy

Three orthogonal axes, per [GUIDE.md](GUIDE.md). Structural mirrors the repo, semantic re-groups by
intent, conceptual holds what has no file.

```text
docs/knowledge-vault/
├── _meta/                      # config, manifest, templates (not concepts)
├── index.md                    # root of the cascade
├── start-here.md               # the learning door
├── log.md
│
├── providers/                  # STRUCTURAL — the five surfaces
│   ├── index.md
│   ├── claude-code.md          # provider
│   ├── gemini-cli.md
│   ├── codex.md
│   ├── cursor.md
│   ├── agents-portable.md
│   ├── rules/                  # cursor rule families (guide)
│   └── hooks/                  # .claude/hooks/*.sh (script)
│
├── roles/                      # STRUCTURAL — 11 agent-role concepts
├── skills/                     # STRUCTURAL — 20 skill concepts
├── commands/                   # STRUCTURAL — 34 command concepts
│
├── sync/                       # STRUCTURAL — the sync engine
│   ├── index.md
│   ├── harness-sync-engine.md  # architecture
│   ├── manifest-schema.md      # architecture
│   ├── sync-scope.md           # process
│   └── tests/                  # 9 test-suite concepts
│
├── subsystems/                 # STRUCTURAL — the shipped subsystems
│   ├── index.md
│   ├── dark-factory/
│   ├── pattern-library/
│   ├── spec-templates/
│   ├── linting/
│   └── knowledge-vault/
│
├── patterns/                   # STRUCTURAL — 18 pattern stubs
│
├── operations/                 # STRUCTURAL — CI, release, scripts
│   ├── index.md
│   ├── workflows/              # 4 integration concepts
│   ├── scripts/                # 10 script concepts
│   └── release/
│
├── domains/                    # SEMANTIC — the five curated cross-cuts
│   ├── methodology.md
│   ├── providers.md
│   ├── sync.md
│   ├── subsystems.md
│   └── operations.md
│
├── methodology/                # CONCEPTUAL — knowledge with no single file
│   ├── index.md
│   ├── three-layer-architecture.md
│   ├── vnext-workflow-contract.md
│   ├── exit-states.md
│   ├── stop-the-line-gate.md
│   ├── role-collapsing.md
│   ├── three-stage-pr-review.md
│   ├── round-table-philosophy.md
│   ├── evidence-based-delivery.md
│   ├── pattern-discovery-protocol.md
│   ├── safe-ai-dlc.md
│   └── domain-adaptation.md
│
├── knowledge/                  # CONCEPTUAL — SSoT doc stubs
│   ├── index.md
│   ├── guides/  onboarding/  workflow/  whitepapers/
│   ├── database/  security/  ci-cd/
│   └── root-docs/
│
├── maps/                       # canvases
└── bases/                      # Obsidian Bases views
```

The `domains/` axis is the one that earns its keep. `providers/claude-code.md` is where a file
lives; `domains/providers.md` is where someone asks "how does multi-provider parity actually work"
and gets routed across `sync/`, `providers/`, and `operations/` in one place.

---

## The `vault-sync` Watch List

These globs go into the sync skill's drift check. A concept is stale if and only if a path changed
by `git diff --name-only $BASELINE..HEAD` matches its `resource` or one of its `sources`.

```text
.claude/agents/*.md
.claude/skills/*/SKILL.md
.claude/commands/*.md
.claude/hooks/*.sh
.claude/settings.template.json
.claude/hooks-config.json
.claude/team-config.json
.agents/skills/*/SKILL.md
.gemini/commands/**/*.toml
.codex/agents/*.toml
.codex/config.toml
.cursor/rules/*.mdc
agent_providers/**/*.md
agent_providers/**/*.sh
scripts/*.sh
scripts/*.py
tests/test-*.sh
tests/fixtures/**
.harness-manifest.yml
.harness-manifest.schema.json
HARNESS_CHANGELOG.yml
.github/workflows/*.yml
dark-factory/**/*.sh
dark-factory/**/*.md
patterns_library/**/*.md
specs_templates/*.md
linting_configs/*
project_workflow/**
examples/manifests/*.yml
knowledge-vault/scripts/*.mjs
knowledge-vault/templates/**
docs/**/*.md
README.md
AGENTS.md
CONTRIBUTING.md
CLAUDE.md
TEMPLATE_SETUP.md
```

Two exclusions, both intentional:

- `docs/archive/**` and `docs/agent-outputs/**` are historical; changes there do not invalidate
  anything. They are not in the watch list because no concept cites them.
- `docs/knowledge-vault/**` is the vault itself. Including it would make every vault edit mark the
  whole vault stale.

---

## Agent Fan-Out Plan

Sized to the inventory above. Phase boundaries are hard: no generation agent starts before the
manifest holds every ID, because the manifest is the link allowlist.

### Phase 1 — Extract (8 agents)

Each writes a fact digest into the `notes` field of its concepts' manifest entries. No prose, no
concept files.

- **E1** reads `.claude/agents/*.md`, `.codex/agents/*.toml`,
  `agent_providers/claude_code/prompts/*.md` — produces notes for 11 roles.
- **E2** reads `.claude/skills/*/SKILL.md`, `.agents/skills/*/SKILL.md` — 20 skills.
- **E3** reads `.claude/commands/*.md`, `.gemini/commands/**/*.toml` — 34 commands.
- **E4** reads `.cursor/rules/*.mdc`, `.claude/hooks/*.sh`, `agent_providers/augment/**` —
  5 providers, 4 rule families, 3 hooks, 6 augment rules.
- **E5** reads `scripts/*`, `.harness-manifest*`, `tests/test-*.sh`, `tests/fixtures/**`,
  `examples/manifests/*` — the sync engine, 9 test suites, 10 scripts.
- **E6** reads `dark-factory/**`, `patterns_library/**`, `specs_templates/*`, `linting_configs/*`,
  `knowledge-vault/**` — the subsystems and 18 patterns.
- **E7** reads `README.md`, `AGENTS.md`, `CONTRIBUTING.md`, `CLAUDE.md`, `docs/guides/*`,
  `docs/workflow/*`, `docs/sop/*` — 12 methodology concepts.
- **E8** reads `.github/workflows/*.yml`, `docs/ci-cd/*`, `docs/release*/**`,
  `HARNESS_CHANGELOG.yml`, `project_workflow/**` — operations.

**Gate**: the manifest lists every concept ID with `type`, `title`, `path`, `description`, `tags`,
`batch`, and `notes`, before Phase 2 begins.

### Phase 2 — Generate (24 agents)

One agent per batch lane, each carrying the four-part prompt.

| Lane | Agents | Concepts |
| --- | --- | --- |
| `roles` | 2 | 11 agent-role |
| `skills-a`, `skills-b` | 2 | 20 skill |
| `commands-a`, `commands-b`, `commands-c` | 3 | 34 command |
| `providers` | 2 | 5 provider, 4 rule families, 3 hooks, 6 augment rules, 1 architecture |
| `sync` | 3 | 2 architecture, 1 process, 9 test-suite, 2 guide, 1 process |
| `subsystems` | 3 | dark factory (14), spec templates (5), linting (1), vault (1) |
| `patterns` | 2 | 18 pattern, 1 architecture |
| `methodology` | 3 | 12 concepts |
| `operations` | 2 | 4 integration, 10 script, 3 release |
| `docs-a`, `docs-b` | 2 | ~40 SSoT stubs |

**Gate**: `--allow-broken-links` validation passes before Phase 3.

### Phase 3 — Navigate (5 agents)

| Agent | Produces |
| --- | --- |
| N1 | Root `index.md` plus section indexes for `providers/`, `roles/`, `skills/`, `commands/` |
| N2 | Section indexes for `sync/`, `subsystems/`, `patterns/`, `operations/`, `methodology/`, `knowledge/` |
| N3 | The 5 `domain` concepts under `domains/` |
| N4 | `start-here.md` — every step states why it comes there |
| N5 | `maps/*.canvas` and `bases/*.base` |

The vertical slice for `start-here.md`: a ticket enters at `/start-work`, the BSA role writes AC,
the Stop-the-Line gate admits it, an implementer exits at "Ready for QAS", QAS gates, RTE opens the
PR, and `.github/workflows/pr-validation.yml` runs. Trace that end to end with real paths.

### Phase 4 — Verify (12 adversarial agents)

Verifiers do not fix; they file findings with file-and-line evidence. Assign one verifier per
Phase 2 lane group, plus two cross-cutting:

| Verifier | Target |
| --- | --- |
| V1–V9 | One per generation lane group — re-derive every claim from source |
| V10 | Link legality: no wikilinks, no leading slashes, no repo-host URLs, every link in the manifest |
| V11 | Count integrity: every number stated in a concept re-counted from disk |
| V12 | Stub discipline: does any stub restate more than a paragraph of its source? |

V11 exists specifically because this repo's concepts will state counts ("20 skills", "5 provider
surfaces") and a wrong count is the most embarrassing possible failure in a document about
verifiability. On the reference build, 14 adversarial verifiers produced 25 evidence-backed
findings; all were corrected before merge. Budget for the same and do not treat zero findings as
success — treat it as a sign the verifiers were too gentle.

---

## Runnable Prompt Blocks

Paste these as-is. Replace nothing except the per-agent scope line.

### Phase 1 — extraction agent

```text
You are an extraction agent for this repository's knowledge vault build.

SCOPE: <paste the "Reads" cell for your agent from the Phase 1 table>

Read every file in scope. For each concept assigned to you in
docs/knowledge-vault/_meta/manifest.json, write a fact digest into that entry's "notes" field.

A fact digest is pipe-separated, dense, and factual. No prose, no adjectives, no
recommendations. Example shape:
  "invoked by /start-work | reads .harness-manifest.yml | writes patch to /tmp | 3 exit codes"

Rules:
- Facts must be true of the file as it exists at HEAD. If a doc contradicts a script, the
  script wins; record the discrepancy in the digest.
- Record the exact repo-root-relative paths. They become "resource" and "sources".
- Count things by listing them, never by estimating.
- Do NOT write concept .md files. Do NOT invent concepts not in the manifest.
- If you find an artifact with no manifest entry, report it as a suggestion at the end.

Output: the updated manifest entries, plus a list of suggested missing concepts.
```

### Phase 2 — generation agent

```text
You are a generation agent for this repository's knowledge vault build.
Your lane: <lane name>. Your concepts: <list of manifest IDs>.

You are given four things and must use all four.

1. TYPE TEMPLATE
   docs/knowledge-vault/_meta/templates/<type>.md — the frontmatter stencil and the fixed,
   ordered H2 list with per-section length budgets. Do not add, remove, or reorder H2s.

2. GOLDEN EXAMPLE
   <path to one already-accepted concept of the same type>
   Match its density, its voice, and its level of abstraction.

3. THE HARD RULES (the constitution — knowledge-vault/templates/starter-bundle/_meta/CONVENTIONS.md)
   - One concept per file, kebab-case filename, exactly one H1, all sections H2, ends in
     "## Citations".
   - Required frontmatter: type, title, description (one sentence, <=160 chars), tags (from the
     controlled vocabulary in vault-config.json), timestamp, status.
   - timestamp is the date you verified the claims against source. verified_against is the short
     git SHA you verified at. Set both honestly.
   - Summarize, never duplicate. If you are restating more than a paragraph, stop and link.
   - Facts must be true of the artifact as it exists. Name what the code actually does, not what
     it should do. Where code and docs disagree, the code wins and you note the discrepancy.
   - Relative markdown links only. Never wikilinks, never leading-slash paths, never
     repository-host URLs for files in this repo. Code files are named as inline code, never
     linked; they belong in resource/sources.
   - Links leaving the bundle appear only under "## Citations".
   - No emoji. Max 60 lines per concept. Tables need leading and trailing pipes. Fenced blocks
     declare a language.
   - Environment variable names may be mentioned; values never.

4. THE ID REGISTRY (the link allowlist)
   docs/knowledge-vault/_meta/manifest.json
   Link ONLY to concept IDs listed there. If a concept you want does not exist, name it in prose
   without a link and report it as a suggestion. NEVER invent links.

Your manifest entries carry a "notes" fact digest from the extraction phase. Use it, but open the
actual source file before asserting anything you did not find in the digest.

Output: one .md file per assigned concept at its manifest "path", plus a list of suggested
missing concepts and any code/doc discrepancies you found.
```

### Phase 3 — navigation agent

```text
You are a navigation agent for this repository's knowledge vault build.
Your assignment: <N1..N5 row from the Phase 3 table>

index.md files carry no frontmatter and are not concepts (the root index.md is the sole
exception: it carries okf_version plus the standard fields). They are curated and annotated —
each link gets a clause saying what the reader will find, not just the title.

start-here.md is the learning door, not a table of contents. Every step must state WHY it comes
at that point in the order. It ends in one traced vertical slice through this repo, using real
paths: a ticket enters at /start-work, BSA writes AC, the Stop-the-Line gate admits it, an
implementer exits at "Ready for QAS", QAS gates, RTE opens the PR,
.github/workflows/pr-validation.yml runs.

Link ONLY to concept IDs in docs/knowledge-vault/_meta/manifest.json. Never invent links.
Canvas nodes must reference files that exist on disk.
```

### Phase 4 — verifier agent

```text
You are an adversarial verifier for this repository's knowledge vault build.
Your target: <verifier row from the Phase 4 table>

Your job is to BREAK claims, not to improve prose. You do not edit concepts.

For every factual assertion in your target concepts:
- Open the source file named in resource/sources and confirm the claim against it.
- Re-count every number stated. Run the count; do not eyeball it.
- Check that every link resolves and that its target ID is in the manifest.
- Check that stub-type concepts cite an out-of-bundle source and do not restate it.
- Check that timestamp and verified_against are plausible: a concept claiming verification at a
  SHA whose source has since changed is a finding.

File each finding as: concept ID | claim | evidence (file:line) | severity (wrong | minor).
"Wrong" means a reader acting on it would do the wrong thing. "Minor" means imprecise but not
misleading.

Report zero findings only if you genuinely found none after checking every assertion. State how
many assertions you checked.
```

---

## The Gate

The build is not done until both commands exit 0.

```bash
node knowledge-vault/scripts/validate-vault.mjs --vault docs/knowledge-vault
npx markdownlint-cli2 "docs/knowledge-vault/**/*.md"
```

The `--vault` flag is mandatory here, not optional: this repo will contain two bundles once the
build lands — `knowledge-vault/templates/starter-bundle` and `docs/knowledge-vault` — and the
validator refuses to guess when it finds more than one.

Use `--allow-broken-links` during Phase 2 only. Never in CI.

Wire it in: `knowledge-vault/templates/github/validate-vault.yml` is the opt-in workflow template.
Copy it to `.github/workflows/`, bringing the repo from 4 workflows to 5. In the reference project
the validator existed, passed locally, and ran in no workflow, so drift was invisible to CI until an
audit caught it. That gap is avoidable here and should be closed in the same change that adds the
vault.

---

## Linear Epic and Stories

Ticket prefix `SAW`. File these rather than treating the above as a suggestion.

### Epic: Build the SAW knowledge vault

**Description**: Build this repository's own OKF knowledge vault using the shipped
`knowledge-vault/` subsystem, and use the build as the falsification test for whether the twelve
stack-agnostic types genericized correctly.

**Business outcome**: A newcomer or agent can orient in this repo from a map that is provably
current, and any over-fitting left in the starter config is found and fixed upstream.

**Metrics**:

- `validate-vault.mjs --vault docs/knowledge-vault` exits 0 in CI on every PR.
- Every concept carries `verified_against` set to a real SHA.
- Adversarial verification findings are recorded and every one is corrected before merge.

---

### Story 1: Author the SAW vault config and type templates

**As a** vault maintainer, **I want** a SAW-specific `vault-config.json` plus templates for the
added types, **so that** generation agents have an enforceable contract before any concept exists.

**Acceptance criteria**:

- [ ] `docs/knowledge-vault/_meta/vault-config.json` exists, matching the block in this document.
- [ ] `bundle_root` is `docs/knowledge-vault`; `obsidian_vault_root` is `.`.
- [ ] Domains are `methodology`, `providers`, `sync`, `subsystems`, `operations`.
- [ ] Types `provider`, `command`, `script`, `test-suite` are present with ordered sections ending
      in `Citations`.
- [ ] `_meta/templates/provider.md`, `command.md`, `script.md`, `test-suite.md` exist, each with
      per-section length budgets.
- [ ] `_meta/CONVENTIONS.md` is present and consistent with the config.
- [ ] The validator runs against the empty bundle and reports only "no concepts" style output, not
      config errors.

---

### Story 2: Extraction pass — populate the manifest

**As a** vault maintainer, **I want** a manifest holding every concept ID with a fact digest,
**so that** generation can run in parallel against a fixed link allowlist.

**Acceptance criteria**:

- [ ] `_meta/manifest.json` lists every concept from the scope tables, each with `id`, `type`,
      `title`, `path`, `description`, `tags`, `batch`, `notes`.
- [ ] `baseline_sha` is set to a real short SHA of the commit extraction ran against.
- [ ] Counts in the manifest match a fresh run of the enumeration commands in Appendix A. Any
      divergence from this document's stated counts is recorded in the story comments.
- [ ] The eleven agent roles have one entry each, not one per provider format.
- [ ] Artifacts found with no planned concept are listed as comments on this story.

---

### Story 3: Generation pass — write the concepts

**As a** vault maintainer, **I want** every planned concept written by a lane agent using the
four-part prompt, **so that** ~200 files read as though one author wrote them.

**Acceptance criteria**:

- [ ] Every manifest ID has a file at its `path`.
- [ ] Every concept has the required frontmatter, exactly the H2s its type declares, in order,
      ending in `## Citations`.
- [ ] Every concept is 60 lines or fewer.
- [ ] Every concept sets `verified_against` to a real short SHA and `timestamp` to the date of
      verification.
- [ ] Stub-type concepts each carry at least one out-of-bundle citation and restate no more than a
      paragraph of it.
- [ ] `validate-vault.mjs --vault docs/knowledge-vault --allow-broken-links` exits 0.
- [ ] Code/doc discrepancies found during generation are filed as comments, not silently resolved
      in favour of the doc.

---

### Story 4: Navigation pass — build both doors

**As a** newcomer, **I want** a reference door and a learning door, **so that** I can either look
something up or be taught the system in order.

**Acceptance criteria**:

- [ ] Root `index.md` carries `okf_version` and links every section index.
- [ ] Each section directory has an `index.md` with an annotated link per concept.
- [ ] `start-here.md` orders its steps and states why each step comes where it does.
- [ ] `start-here.md` ends in one traced vertical slice using real repo paths from `/start-work`
      through `.github/workflows/pr-validation.yml`.
- [ ] Five `domain` concepts exist under `domains/`, each re-grouping artifacts by intent rather
      than by directory.
- [ ] Canvases under `maps/` reference only files that exist.
- [ ] `log.md` exists with a dated entry for the build.

---

### Story 5: Adversarial verification pass

**As a** reader trusting this vault, **I want** independent agents to have tried to falsify every
claim, **so that** trusting it is justified rather than habitual.

**Acceptance criteria**:

- [ ] Twelve verifiers run per the Phase 4 assignment table.
- [ ] Every finding is recorded as `concept ID | claim | evidence (file:line) | severity`.
- [ ] Every count asserted anywhere in the vault has been independently re-counted from disk.
- [ ] Every finding is corrected before merge; corrections bump `timestamp` and `verified_against`
      of the concepts they touch.
- [ ] Each verifier reports the number of assertions checked, not only the number of findings.
- [ ] Findings and their resolutions are posted to Linear as the evidence record.

---

### Story 6: Wire vault validation into CI and vault-sync

**As a** maintainer, **I want** drift to be caught by CI rather than by an audit, **so that** the
vault cannot silently go stale.

**Acceptance criteria**:

- [ ] `knowledge-vault/templates/github/validate-vault.yml` is copied to `.github/workflows/`,
      taking the repo from 4 workflows to 5.
- [ ] The workflow runs `validate-vault.mjs --vault docs/knowledge-vault` without
      `--allow-broken-links` and fails the build on a non-zero exit.
- [ ] `yarn`-equivalent markdown linting covers `docs/knowledge-vault/**/*.md` and passes.
- [ ] The `vault-sync` skill's watch list matches the glob list in this document.
- [ ] A deliberate test change to a watched path is shown to mark exactly the expected concepts
      stale, and no others.

---

## Appendix A — Enumeration Commands

Run these before starting. Every count in this document came from them. If a number has moved,
the number in this document is the one that is wrong.

```bash
ls -d .claude/skills/*/ | wc -l                          # 20 skills
ls .claude/agents/*.md | wc -l                           # 12 files = 11 roles + README
ls .claude/commands/*.md | wc -l                         # 25 files = 24 commands + README
ls .claude/hooks/*.sh | wc -l                            # 3 hooks
find .agents -name SKILL.md | wc -l                      # 20 portable skill mirrors
find .gemini -name '*.toml' | wc -l                      # 30 (20 mirrors + 10 media-only)
ls .cursor/rules/*.mdc | wc -l                           # 18 rules
ls .codex/agents/*.toml | wc -l                          # 11 role mirrors
ls agent_providers/claude_code/prompts/*.md | wc -l      # 11 role prompts
ls agent_providers/augment/rules/*.md | wc -l            # 6 augment rules
ls .github/workflows/*.yml | wc -l                       # 4 workflows
ls tests/test-*.sh | wc -l                               # 9 shell test suites
ls scripts/* | wc -l                                     # 11 scripts
find patterns_library -name '*.md' | wc -l               # 19 files = 18 patterns + README
ls dark-factory/scripts/*.sh | wc -l                     # 5 operator scripts
ls dark-factory/docs/*.md | wc -l                        # 4 guides
ls dark-factory/templates/team-layouts/*.sh | wc -l      # 3 team layouts
ls specs_templates/*.md | wc -l                          # 5 templates
find docs -type f | wc -l                                # 68 doc files
git rev-parse --short HEAD                               # baseline_sha
```

---

## Related Reading

- [Knowledge Vault Guide](GUIDE.md) — the method and why each rule exists
- [Build Prompt](BUILD-PROMPT.md) — the stack-neutral build prompt
- [Adoption Playbook](ADOPTION-PLAYBOOK.md) — first-build walkthrough
- [Conventions](../templates/starter-bundle/_meta/CONVENTIONS.md) — the constitution
- [Starter config](../templates/starter-bundle/_meta/vault-config.json) — the 12 shipped types
