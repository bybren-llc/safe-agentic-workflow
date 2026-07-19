# Obsidian Guide

**Purpose**: Set up [Obsidian](https://obsidian.md) as the visual layer over a knowledge vault —
graph, canvases, and Bases — and explain the configuration that makes the editor and the validator
want the same thing.

**Audience**: Anyone maintaining a vault who wants to see it, not just read it.

**Optional**: The vault is plain markdown and works in any editor, in `git`, and on the web.
Obsidian adds a graph, spatial canvases, and live database views. Nothing here is required.

---

## The Config Treaty

Three settings decide whether your tooling helps you or fights you:

```json
{
  "useMarkdownLinks": true,
  "newLinkFormat": "relative",
  "alwaysUpdateLinks": true
}
```

- `useMarkdownLinks: true` — Obsidian creates `[text](path.md)`, not `[[wikilinks]]`. **Wikilinks
  fail validation**, and the default is wikilinks, so without this every link you create by
  clicking is a future CI failure.
- `newLinkFormat: "relative"` — matches the relative-links-only rule.
- `alwaysUpdateLinks: true` — renaming a concept rewrites every inbound link automatically.

Copy `knowledge-vault/templates/obsidian/app.json` into your vault's `.obsidian/` and adjust the
paths. This is the single highest-value configuration in the system.

---

## Vault Root: Point It at the Parent

Open Obsidian on the **parent** of your bundle, not the bundle itself.

If your vault lives at `docs/knowledge-vault/`, open `docs/` as the Obsidian vault.

Why it matters:

1. **Citations stay clickable.** Concepts cite source-of-truth documents that live outside the
   bundle. With the wider root, those are live links with hover previews. With the narrow root,
   every citation is a dead path.
2. **The graph shows map and territory**, with a colour group greying out everything outside the
   bundle — instant visual separation.
3. **Bases filters need it.** Every `.base` file filters with `file.inFolder("<bundle>")`, which
   only makes sense if the vault is a superset of the bundle.
4. **Search spans both**, so "where is this documented" finds the source and the map-card together.

Use `userIgnoreFilters` in `app.json` to hide the noise the wider root pulls in — archives,
generated reports, and the `_meta/templates/` directory, which would otherwise pollute search.

---

## The Graph

`templates/obsidian/graph.json` ships colour groups keyed to directory, plus tuned physics
(`linkDistance: 250`, `repelStrength: 12`, labels always visible).

The important group is the last one:

```json
{ "query": "-path:starter-bundle", "color": { "a": 1, "rgb": 8947848 } }
```

Everything outside the bundle greys out. Map and territory become visually distinct at a glance.

`showOrphans` is deliberately **true**. An orphan — a concept nothing links to — is a defect you
want to see, not hide. The validator reports them too.

---

## Canvases

Canvases use the [JSONCanvas](https://jsoncanvas.org) open spec: a JSON file of `nodes` and
`edges`. Nodes of `type: "file"` embed a real concept, rendered as a live card you can click
straight through.

**They are not separate diagrams.** They are spatial layouts over the same concept files, so they
cannot drift into being a second thing to maintain. The validator checks that every `file` node
points at something real.

Two genres, one example of each in the starter bundle:

| Genre | Shape | Example |
| --- | --- | --- |
| **Architectural** | Labelled columns at a fixed pitch, one card per load-bearing concept, stable over time | `maps/system-overview.canvas` |
| **Flow** | Mostly file nodes, edge-dense, tracing one path end to end | `maps/vault-lifecycle.canvas` |

A third genre is worth knowing: the **report** canvas — a dated, point-in-time artifact such as an
audit heatmap, where node colour encodes a verdict and edges wire each finding to the concepts
that must change. It renders an assessment *into* the knowledge graph rather than beside it.

Keep one canvas per major flow, and link it from the relevant domain hub and from `start-here.md`.

### Canvas paths move with the bundle

Node `file` paths are **Obsidian-vault-root-relative**, not bundle-relative. That is an Obsidian
convention, not a choice this harness makes — so if you copy or rename the bundle, the paths need
rewriting:

```bash
sed -i 's|"starter-bundle/|"your-vault-folder/|g' your-vault-folder/maps/*.canvas
```

The validator checks every `file` node, so a missed rewrite is an error rather than a silently
blank card.

---

## Bases

Bases (Obsidian **1.9+**) are live table views over frontmatter. They are the payoff for the
frontmatter contract: structured metadata becomes queryable.

Four ship in the starter bundle:

| Base | What it answers |
| --- | --- |
| `stale-concepts.base` | **The maintenance queue.** Which concepts have gone longest without verification. |
| `coverage.base` | What is mapped, grouped by type — and which concepts have no verification SHA at all. |
| `by-domain.base` | What belongs to each business domain. |
| `ticket-index.base` | Which concepts a given ticket touched. |

`stale-concepts.base` is the one to pin. Its "Staleness Radar" view sorts by `timestamp` ascending
with `verified_against` alongside, turning the discipline into a worklist. Without it, the
frontmatter contract is bookkeeping nobody reads.

If you are on an older Obsidian, delete the `bases/` directory — nothing else depends on it.

---

## Core Plugins Only

`templates/obsidian/core-plugins.json` enables graph, backlinks, outgoing links, canvas, Bases,
tag pane, properties, bookmarks, and outline. **No community plugins are required.**

That is deliberate. A vault that needs third-party plugins to be readable is a vault that breaks
for the next person.

---

## Bookmarks

Worth curating: `start-here.md`, the root `index.md`, your main canvas, the staleness Base — and
at least one **source-of-truth document from outside the bundle**, as a standing reminder that the
vault is the map and not the thing itself.

---

## Housekeeping

Commit the shared config; ignore the per-user state:

```gitignore
# Obsidian per-user state (the vault config itself is committed)
**/.obsidian/workspace.json
**/.obsidian/workspace-mobile.json
```

And do not leave a stray `.obsidian/` inside the bundle from opening it directly once. An empty
`app.json` there means Obsidian falls back to wikilinks, which fail validation — a trap that is
hard to diagnose because everything looks configured.

---

## Related Reading

- [Knowledge Vault Guide](GUIDE.md) — the method
- [Adoption Playbook](ADOPTION-PLAYBOOK.md) — running your first build
- [JSONCanvas spec](https://jsoncanvas.org)
- [Obsidian Bases documentation](https://help.obsidian.md/bases)
