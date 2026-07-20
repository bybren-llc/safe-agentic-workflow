# Knowledge Vault

![Status](https://img.shields.io/badge/status-production-green)
![Harness](https://img.shields.io/badge/harness-{{HARNESS_VERSION}}-blue)
![Format](https://img.shields.io/badge/format-OKF%20v0.1-blue)

> An evidence-verified knowledge base for agent teams. Every concept records the commit its claims
> were checked against, so staleness is something you **compute**, not something you feel.

## License

**License:** MIT (see [/LICENSE](/LICENSE))
**Copyright:** © 2026 J. Scott Graham ([@cheddarfox](https://github.com/cheddarfox)) / [ByBren, LLC](https://github.com/bybren-llc)
**Attribution:** Required per [/NOTICE](/NOTICE)

## Intellectual Property

The skill system architecture and {{PROJECT_SHORT}} harness methodology are the intellectual property of J. Scott Graham and ByBren, LLC.

SAFe® is a registered trademark of Scaled Agile, Inc.

---

## Run It

Two prompts. One is a template you fill in; the other is already filled in for this repo.

| Prompt | Who it is for |
| --- | --- |
| **[BUILD-PROMPT.md](docs/BUILD-PROMPT.md)** | **Every adopter.** The generic multi-agent build prompt — fill in your project, taxonomy, and watch-list, then run it. |
| **[SAW-VAULT-BUILD.md](docs/SAW-VAULT-BUILD.md)** | **This repo's maintainers.** Pre-scoped to {{PROJECT_SHORT}} and runnable as-is, with a ready-to-file ticket breakdown. |

Start with the [Adoption Playbook](docs/ADOPTION-PLAYBOOK.md) if you want the steps around the
prompt — what to run first, how to choose a taxonomy, and how to gate it in CI.

## What This Is

A **vault** is a bundle of small markdown concepts — one per real artifact or idea — each with
structured frontmatter, each linking to its neighbours, each stamped with the commit its claims
were verified at.

Built on [Open Knowledge Format v0.1](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
(Google, Apache-2.0), which gives portability. This subsystem adds the rigor layer that gives
trust: a strict frontmatter contract, a zero-dependency validator, an anti-hallucination link
discipline, and a drift mechanism.

**Why bother:** in the project this method came from, an independent architecture audit scored the
vault *"the single strongest KT asset in the repo"* and told new developers to **trust it over the
project's own canonical context file** — because the vault's claims were verified against a SHA
and the canonical file's had silently drifted. Not that a vault is tidy. That it is checkable.

## 30-Second Start

```bash
# 1. Prove the tooling works, against the bundle shipped here
node knowledge-vault/scripts/validate-vault.mjs --vault knowledge-vault/templates/starter-bundle

# 2. Copy the starter bundle to where your vault will live
cp -r knowledge-vault/templates/starter-bundle docs/knowledge-vault

# 3. Repoint canvas nodes at the new folder name.
#    Canvas paths are Obsidian-vault-root-relative, so they move with the bundle.
#    (-i.bak keeps this portable: BSD/macOS sed requires a backup suffix.)
sed -i.bak 's|"starter-bundle/|"knowledge-vault/|g' docs/knowledge-vault/maps/*.canvas \
  && rm -f docs/knowledge-vault/maps/*.bak

# 4. Update bundle_root and obsidian_vault_root in _meta/vault-config.json, then re-validate
node knowledge-vault/scripts/validate-vault.mjs --vault docs/knowledge-vault
```

The validator uses `node:` builtins only — no install step, no `package.json` required. It will
tell you if you miss step 3 or 4: canvas nodes are checked, and a `bundle_root` that disagrees
with where the vault actually sits raises a warning.

## Contents

```text
knowledge-vault/
├── docs/
│   ├── GUIDE.md              # The method, and why each rule exists
│   ├── ADOPTION-PLAYBOOK.md  # Steps, taxonomy choice, CI gating, ticket breakdown
│   ├── BUILD-PROMPT.md       # (A) generic multi-agent build prompt
│   ├── SAW-VAULT-BUILD.md    # (B) exact prompt for this repo's own vault
│   └── OBSIDIAN-GUIDE.md     # Graph, canvases, Bases, and the config treaty
├── templates/
│   ├── starter-bundle/       # A working vault that validates clean as shipped
│   ├── obsidian/             # app.json, graph.json, core-plugins.json
│   └── github/               # Opt-in CI workflow
└── scripts/
    └── validate-vault.mjs    # Zero-dependency structural validator
```

## The Validator

```bash
node knowledge-vault/scripts/validate-vault.mjs --help
```

Enforces the frontmatter contract, exact section structure per type, link legality, that
`resource`/`sources`/`docs` paths exist, that stub types cite their source, that canvas nodes
point at real files, manifest/disk agreement, and orphan detection.

**Wire it into CI.** `templates/github/validate-vault.yml` is ready to copy. In the reference
project the validator existed, passed locally, and ran in **no** workflow — so drift was invisible
until an audit caught it. That gap is documented here so you do not inherit it.

## Maintenance

The `vault-sync` skill ships with this harness as a skill for Claude, Gemini and the portable
agent surface, and as a manual rule for Cursor. It detects drift from
`baseline_sha`, regenerates only what changed, validates, and records the sync.

## Obsidian: the reading layer

A bundle is a directory of markdown, so **Obsidian opens it with no conversion step**. That is not
incidental; it follows from OKF choosing plain files over a database or an API. Opening the vault
in Obsidian is what turns a folder of concepts into something you can navigate:

| Feature | What it gives you |
| --- | --- |
| **Graph view** | The concept graph, colour-grouped by directory. The shipped `graph.json` sets `showOrphans: true` deliberately: an orphan is a concept nothing links to, which is a defect you want visible rather than hidden. |
| **Canvases** | Spatial maps for relationships a linear document cannot show, such as a request lifecycle or how a domain's pieces connect. |
| **Bases** | Saved queries over frontmatter. The one that earns its keep is the **drift dashboard**: every concept whose `verified_against` has fallen behind the baseline, in one view. |

See the [Obsidian Guide](docs/OBSIDIAN-GUIDE.md) for the full setup, and
`templates/obsidian/` for the `app.json`, `graph.json` and `core-plugins.json` this harness ships.

Obsidian is not a dependency: no community plugins are required, and the vault degrades gracefully
to plain markdown in any editor. Bases views need Obsidian 1.9+.

Three settings are non-negotiable if you use it:

```json
{ "useMarkdownLinks": true, "newLinkFormat": "relative", "alwaysUpdateLinks": true }
```

Without them every link the GUI creates is a wikilink, and wikilinks fail validation.
