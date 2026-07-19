---
name: vault-sync
description: Detect and repair drift between an OKF knowledge vault and the code it describes. Use after merging significant changes (schema, routes, workflows, agent config), when a staleness review is due, or when the user asks to sync, refresh, or update the knowledge vault or Obsidian vault.
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
---

# Vault Sync Skill

> **📋 TEMPLATE**: This skill uses `{{TICKET_PREFIX}}` and `{{MAIN_BRANCH}}` as placeholders, and
> assumes a vault created from `knowledge-vault/templates/starter-bundle`.

## Purpose

Keep an OKF knowledge vault honest as the code evolves. The vault is a map of the system; this
skill detects drift between map and territory, regenerates **only** the affected concepts, and
records the sync.

## When This Skill Applies

Invoke this skill when:

- A significant change merged — schema, public interfaces, CI workflows, agent or skill config
- A staleness review is due (the `stale-concepts` Base is the queue)
- The user asks to sync, refresh, or update the knowledge vault
- A concept is suspected of being wrong

## Key Files

| Path | Role |
| --- | --- |
| `<vault>/_meta/vault-config.json` | Machine-readable constitution — types, tags, frontmatter contract |
| `<vault>/_meta/CONVENTIONS.md` | The human-readable rules |
| `<vault>/_meta/manifest.json` | ID registry, reverse index, and `baseline_sha` drift watermark |
| `<vault>/_meta/templates/` | Per-type skeletons |
| `<vault>/log.md` | Dated changelog |
| `knowledge-vault/scripts/validate-vault.mjs` | The gate |

## Procedure

### 1. Detect drift

Read the baseline and diff it to HEAD across the watch-list — **the source paths your concepts
claim to describe**. Configure this list for your project; the example below is illustrative.

```bash
BASELINE=$(node -e "console.log(require('./<vault>/_meta/manifest.json').baseline_sha)")
git diff --name-only "$BASELINE"..HEAD -- \
  'src/**' 'lib/**' 'config/**' '.github/workflows/**' 'docs/**'
```

A concept is **stale** if and only if a changed path matches its `resource` or an entry in its
`sources`. Check the manifest first (it is the reverse index); grep concept frontmatter as backup.

This is file-level truth. Do not substitute a time-based heuristic — "older than N days" flags
everything and teaches people to ignore the flag.

### 2. Detect inventory changes

Re-enumerate your source globs and diff against the manifest.

- **New source, no concept** → create one. **Add the manifest entry first**, so the ID exists in
  the registry before anything links to it.
- **Deleted source** → set the concept's `status: deprecated`. **Do not delete the file.** Inbound
  links must be cleaned first, in a follow-up change; the backlinks pane or the validator's orphan
  report shows them.

### 3. Regenerate

For a handful of concepts, update inline. For larger sets, fan out generation agents batched by
area. **Every generation prompt must carry exactly four things:**

1. The type template from `_meta/templates/`
2. A **golden example** — a real, already-accepted concept of the same type
3. The hard rules from `_meta/CONVENTIONS.md`, inline
4. The manifest **ID registry** — links may target only IDs listed there

Every touched concept gets `timestamp:` = today and `verified_against:` = the current short SHA.

**Re-derive facts from the source files. Never patch prose without re-reading the code it
describes.** Editing a concept to match a changed interface without opening the file is how a
vault becomes fiction.

### 4. Validate

```bash
node knowledge-vault/scripts/validate-vault.mjs --vault <vault>
```

Must exit 0. Markdown lint must pass. Neither is optional.

### 5. Record

Prepend a dated entry to `log.md`: what changed, why (ticket), and the source SHA. Then bump
`baseline_sha` and `generated` in the manifest.

Ship on a `{{TICKET_PREFIX}}-XXX-vault-sync-<topic>` branch with a `docs(vault): …` commit to
`{{MAIN_BRANCH}}`. The pull request should name the code changes that triggered the sync.

## Invariants (do not relax)

- Concept-to-concept links never leave the bundle; out-of-bundle links only under `## Citations`
- Relative markdown links only — no wikilinks, no leading-slash paths, no repo-host URLs for repo files
- **Link only to IDs in the manifest.** If a concept does not exist, name it in prose and report it
  as a suggestion — never invent a link
- One concept per file; H2 sections exactly match the type template, in order
- Stub types cite their source-of-truth doc; they never restate it
- **A citation is not re-verification.** Only re-deriving a concept from source bumps its
  `timestamp` and `verified_against`

## Anti-Patterns (Do NOT use)

```text
Bumping timestamps on a docs-only pass   (that is laundering, not verification)
Deleting a concept when its source dies  (deprecate; clean inbound links first)
Regenerating the whole vault on drift    (regenerate only what the diff implicates)
Patching prose without reading the code  (the one habit that makes a vault untrustworthy)
Skipping the validator because "it is just docs"  (drift is invisible without the gate)
```

## Authoritative References

- `knowledge-vault/docs/GUIDE.md` -- the method and why each rule exists
- `knowledge-vault/docs/ADOPTION-PLAYBOOK.md` -- running your first build
- `knowledge-vault/docs/BUILD-PROMPT.md` -- the multi-agent build prompt

## Routes To

- `safe-workflow` — branch, commit, and PR conventions
- `linear-sop` — recording the sync against a ticket
- `pattern-discovery` — find existing concepts before writing new ones
