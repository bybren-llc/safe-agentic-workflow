#!/usr/bin/env node
/**
 * validate-vault.mjs — structural validator for an OKF knowledge vault.
 *
 * Zero dependencies: node: builtins only. No package.json required.
 *
 * The vault's `_meta/vault-config.json` is the machine-readable constitution; this script
 * enforces it. Checks:
 *   1. Frontmatter — parseable YAML subset, required fields, enum membership, description length
 *   2. Sections    — H2 set must exactly match the type's template sections
 *   3. Links       — relative markdown only; no wikilinks; no repo-host URLs for repo files;
 *                    concept links resolve inside the bundle; out-of-bundle links only under
 *                    the citations section and must exist on disk
 *   4. Paths       — resource / sources / docs must exist on disk
 *   5. Reserved    — index.md has no frontmatter (root excepted), log.md format
 *   6. Stubs       — types flagged `stub` must actually cite an out-of-bundle source
 *   7. Canvas      — .canvas file nodes must reference files that exist
 *   8. Manifest    — _meta/manifest.json entries <-> files on disk (when a manifest exists)
 *   9. Orphans     — concepts with zero inbound links (warning; --strict-orphans to fail)
 *
 * Exit: 0 clean (warnings allowed), 1 on errors.
 */
import { readFileSync, readdirSync, statSync, existsSync } from "node:fs";
import { join, dirname, resolve, relative, sep } from "node:path";

// ---------------------------------------------------------------- args
const argv = process.argv.slice(2);
const args = new Set(argv);

if (args.has("--help") || args.has("-h")) {
  console.log(`
validate-vault.mjs — structural validator for an OKF knowledge vault

Usage:
  node validate-vault.mjs [--vault <dir>] [options]

Options:
  --vault <dir>          Path to the vault bundle (the dir containing _meta/).
                         If omitted: uses $VAULT_DIR, else auto-discovers a single
                         directory containing _meta/vault-config.json.
  --allow-broken-links   Downgrade broken bundle links and missing manifest files
                         to warnings. For early build phases only.
  --strict-orphans       Promote orphan warnings (no inbound links) to errors.
  --quiet                Print only the summary line.
  --help, -h             Show this help.

Exit codes:
  0  no errors (warnings are allowed)
  1  one or more errors
`);
  process.exit(0);
}

const flagValue = name => {
  const i = argv.indexOf(name);
  return i !== -1 && argv[i + 1] && !argv[i + 1].startsWith("--")
    ? argv[i + 1]
    : null;
};

const ALLOW_BROKEN = args.has("--allow-broken-links");
const STRICT_ORPHANS = args.has("--strict-orphans");
const QUIET = args.has("--quiet");

// ---------------------------------------------------------------- locate vault
const CWD = process.cwd();
const CONFIG_REL = join("_meta", "vault-config.json");

function findVaults(dir, depth, out = []) {
  if (depth < 0) return out;
  let entries;
  try {
    entries = readdirSync(dir, { withFileTypes: true });
  } catch {
    return out;
  }
  if (existsSync(join(dir, CONFIG_REL))) out.push(dir);
  for (const e of entries) {
    if (!e.isDirectory()) continue;
    if (["node_modules", ".git", ".next", "dist", "build"].includes(e.name))
      continue;
    findVaults(join(dir, e.name), depth - 1, out);
  }
  return out;
}

function resolveVault() {
  const explicit = flagValue("--vault") ?? process.env.VAULT_DIR;
  if (explicit) {
    const abs = resolve(CWD, explicit);
    if (!existsSync(join(abs, CONFIG_REL))) {
      console.error(`ERROR no ${CONFIG_REL} under "${explicit}"`);
      process.exit(1);
    }
    return abs;
  }
  const found = findVaults(CWD, 4);
  if (found.length === 1) return found[0];
  if (found.length === 0) {
    console.error(
      `ERROR no vault found (looked for ${CONFIG_REL} up to 4 levels below ${CWD}).\n` +
        `      Pass --vault <dir> or set VAULT_DIR.`
    );
    process.exit(1);
  }
  console.error(
    `ERROR multiple vaults found; pass --vault <dir> to choose:\n` +
      found.map(f => `      ${relative(CWD, f) || "."}`).join("\n")
  );
  process.exit(1);
}

const VAULT = resolveVault();
const CONFIG = JSON.parse(readFileSync(join(VAULT, CONFIG_REL), "utf8"));

// Repo root: nearest ancestor with a .git, else the cwd.
function findRepoRoot(from) {
  let d = from;
  for (;;) {
    if (existsSync(join(d, ".git"))) return d;
    const up = dirname(d);
    if (up === d) return CWD;
    d = up;
  }
}
const REPO_ROOT = findRepoRoot(VAULT);

// Config-declared bundle_root is advisory; warn if it disagrees with reality.
const declaredRoot = CONFIG.bundle_root;
const actualRoot = relative(REPO_ROOT, VAULT).split(sep).join("/");

// ---------------------------------------------------------------- rules from config
const LINK_RULES = CONFIG.link_rules ?? {};
const FORBIDDEN = new Set(LINK_RULES.forbidden ?? []);
const CITATIONS_SECTION = LINK_RULES.external_repo_links_only_under ?? "Citations";
const MAX_DESCRIPTION = CONFIG.frontmatter?.max_description_length ?? 160;
const MAX_CONCEPT_LINES = CONFIG.max_concept_lines ?? null;
const PATH_FIELDS = CONFIG.frontmatter?.path_fields ?? [
  "resource",
  "sources",
  "docs",
];

const errors = [];
const warnings = [];
const rel = f => relative(REPO_ROOT, f).split(sep).join("/");
const err = (file, msg) => errors.push(`${rel(file)}: ${msg}`);
const warn = (file, msg) => warnings.push(`${rel(file)}: ${msg}`);

if (declaredRoot && declaredRoot !== actualRoot) {
  warnings.push(
    `${rel(join(VAULT, CONFIG_REL))}: bundle_root is "${declaredRoot}" but the vault is at "${actualRoot}"`
  );
}

// ---------------------------------------------------------------- collect files
function walk(dir) {
  const out = [];
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) out.push(...walk(p));
    else out.push(p);
  }
  return out;
}
const allFiles = walk(VAULT);
const mdFiles = allFiles.filter(f => f.endsWith(".md"));
const canvasFiles = allFiles.filter(f => f.endsWith(".canvas"));
const inMeta = f => relative(VAULT, f).split(sep)[0] === "_meta";
const isIndex = f =>
  f.endsWith(`${sep}index.md`) || f === join(VAULT, "index.md");
const isLog = f => f === join(VAULT, "log.md");
const conceptFiles = mdFiles.filter(f => !inMeta(f) && !isIndex(f) && !isLog(f));

// ---------------------------------------------------------------- YAML subset parser
const unquote = s => (s.startsWith('"') && s.endsWith('"') ? s.slice(1, -1) : s);

function parseFrontmatter(raw, file) {
  if (!raw.startsWith("---\n")) return null;
  const end = raw.indexOf("\n---", 4);
  if (end === -1) {
    err(file, "unterminated frontmatter block");
    return null;
  }
  const fm = {};
  let listKey = null;
  for (const line of raw.slice(4, end).split("\n")) {
    if (!line.trim() || line.trim().startsWith("#")) continue;
    const listItem = line.match(/^\s+-\s+(.+)$/);
    if (listItem && listKey) {
      fm[listKey].push(unquote(listItem[1].trim()));
      continue;
    }
    const kv = line.match(/^([A-Za-z_][A-Za-z0-9_]*):\s*(.*)$/);
    if (!kv) {
      err(file, `frontmatter line not in allowed YAML subset: "${line}"`);
      continue;
    }
    const [, key, valRaw] = kv;
    const val = valRaw.trim();
    if (val === "") {
      fm[key] = [];
      listKey = key;
    } else if (val.startsWith("[") && val.endsWith("]")) {
      fm[key] = val
        .slice(1, -1)
        .split(",")
        .map(s => unquote(s.trim()))
        .filter(Boolean);
      listKey = null;
    } else {
      fm[key] = unquote(val);
      listKey = null;
    }
  }
  return fm;
}

const parseTypeQuick = raw => {
  const m = raw.match(/^---\n[\s\S]*?^type:\s*(.+)$/m);
  return m ? unquote(m[1].trim()) : null;
};

// ---------------------------------------------------------------- per-file checks
const idOf = f => relative(VAULT, f).replace(/\.md$/, "").split(sep).join("/");
const inbound = new Map(conceptFiles.map(f => [idOf(f), 0]));
const LINK_RE = /\[([^\]]*)\]\(([^)\s]+)\)/g;
const WIKILINK_RE = /(^|[^!\[])\[\[([^\]]+)\]\]/g;
const REPO_HOSTS = /^https?:\/\/(www\.)?(github|gitlab|bitbucket)\.com\//i;

for (const file of mdFiles) {
  const raw = readFileSync(file, "utf8");
  const hasFM = raw.startsWith("---\n");
  const isRoot = file === join(VAULT, "index.md");

  // --- reserved files
  if (isLog(file)) {
    if (hasFM) err(file, "log.md must not have frontmatter");
    if (!/^# /m.test(raw)) err(file, "log.md needs an H1");
    if (!/^## \d{4}-\d{2}-\d{2}/m.test(raw))
      warn(file, "log.md has no dated (## YYYY-MM-DD) entries");
    continue;
  }
  if (isIndex(file) && !isRoot && hasFM)
    err(file, "index.md files must not have frontmatter (reserved-file rule)");

  let fm = null;
  if (!inMeta(file) && (!isIndex(file) || isRoot)) {
    fm = parseFrontmatter(raw, file);
    if (!fm) {
      err(file, "missing frontmatter");
      continue;
    }
  } else if (inMeta(file)) {
    fm = parseFrontmatter(raw, file);
    if (!fm || !fm.type) err(file, "_meta markdown needs frontmatter with a type");
  }

  const typeCfg = fm ? CONFIG.types[fm.type] : null;

  // --- frontmatter contract (concepts + root index)
  if (fm && !inMeta(file)) {
    if (!fm.type) err(file, "missing required field: type");
    else if (!typeCfg) err(file, `unknown type "${fm.type}"`);

    for (const req of CONFIG.frontmatter.required) {
      if (isRoot && req === "status") continue;
      if (fm[req] === undefined || (Array.isArray(fm[req]) && fm[req].length === 0))
        err(file, `missing required field: ${req}`);
    }
    if (isRoot && fm.okf_version !== CONFIG.okf_version)
      err(file, `root index.md must declare okf_version: "${CONFIG.okf_version}"`);
    if (!isRoot && fm.okf_version)
      err(file, "okf_version allowed only in root index.md");
    if (fm.description && fm.description.length > MAX_DESCRIPTION)
      err(file, `description is ${fm.description.length} chars (max ${MAX_DESCRIPTION})`);
    if (fm.timestamp && !/^\d{4}-\d{2}-\d{2}$/.test(fm.timestamp))
      err(file, `timestamp "${fm.timestamp}" not YYYY-MM-DD`);
    if (fm.status && !CONFIG.statuses.includes(fm.status))
      err(file, `invalid status "${fm.status}"`);
    if (fm.domain && CONFIG.domains?.length && !CONFIG.domains.includes(fm.domain))
      err(file, `invalid domain "${fm.domain}"`);
    for (const t of fm.tags ?? [])
      if (CONFIG.tags?.length && !CONFIG.tags.includes(t))
        err(file, `tag "${t}" not in controlled vocabulary`);
    if (typeCfg?.resource_required && !fm.resource)
      err(file, `type "${fm.type}" requires resource`);

    const known = new Set([
      ...CONFIG.frontmatter.required,
      ...CONFIG.frontmatter.optional,
    ]);
    for (const k of Object.keys(fm))
      if (!known.has(k)) warn(file, `unrecognized frontmatter key "${k}"`);

    // --- path fields must exist on disk
    for (const field of PATH_FIELDS) {
      const v = fm[field];
      if (v === undefined) continue;
      for (const p of Array.isArray(v) ? v : [v]) {
        if (!p || /^https?:\/\//.test(p)) continue;
        if (!existsSync(resolve(REPO_ROOT, p)))
          err(file, `${field} path does not exist: "${p}"`);
      }
    }

    // --- section structure
    if (typeCfg && !typeCfg.internal && typeCfg.sections.length > 0 && !isRoot) {
      const h2s = [...raw.matchAll(/^## (.+)$/gm)].map(m => m[1].trim());
      const want = typeCfg.sections;
      if (JSON.stringify(h2s) !== JSON.stringify(want))
        err(file, `H2 sections [${h2s.join(" | ")}] != template [${want.join(" | ")}]`);
      const h1s = [...raw.matchAll(/^# (.+)$/gm)];
      if (h1s.length !== 1) err(file, `expected exactly 1 H1, found ${h1s.length}`);
    }

    // --- map-card length budget (advisory).
    // Free-form types (zero declared sections, e.g. `guide`) are navigation, not map-cards.
    const freeForm = !typeCfg || typeCfg.sections.length === 0;
    if (MAX_CONCEPT_LINES && !isRoot && !isIndex(file) && !freeForm) {
      const lines = raw.split("\n").length;
      if (lines > MAX_CONCEPT_LINES)
        warn(file, `${lines} lines (map-card budget is ${MAX_CONCEPT_LINES}) — summarize and link instead`);
    }
  }

  if (inMeta(file)) continue;

  // --- links
  const bodyStart = hasFM ? raw.indexOf("\n---", 4) + 4 : 0;
  const body = raw.slice(bodyStart);
  const fmType = fm?.type ?? parseTypeQuick(raw);
  const exempt = isIndex(file) || fmType === "guide";
  let currentH2 = "";
  let citesOutOfBundle = false;

  for (const line of body.split("\n")) {
    const h2 = line.match(/^## (.+)$/);
    if (h2) currentH2 = h2[1].trim();

    if (FORBIDDEN.has("wikilinks"))
      for (const m of line.matchAll(WIKILINK_RE))
        err(file, `wikilink "[[${m[2]}]]" — use relative markdown links`);

    for (const m of line.matchAll(LINK_RE)) {
      const target = m[2];

      if (/^(https?:)?\/\//.test(target) || target.startsWith("mailto:")) {
        if (FORBIDDEN.has("github-urls-for-repo-files") && REPO_HOSTS.test(target)) {
          const looksLikeThisRepo = /\/(blob|tree|raw)\//.test(target);
          if (looksLikeThisRepo)
            err(file, `repo-host URL "${target}" — reference repo files by path, not URL`);
        }
        if (currentH2 === CITATIONS_SECTION) citesOutOfBundle = true;
        continue;
      }
      if (target.startsWith("#")) continue;
      if (target.startsWith("/")) {
        err(file, `leading-slash link "${target}" (use relative paths)`);
        continue;
      }

      const clean = target.split("#")[0];
      if (![".md", ".canvas", ".base", ".json"].some(e => clean.endsWith(e))) {
        warn(file, `link to non-md target "${target}"`);
        continue;
      }

      const abs = resolve(dirname(file), clean);
      const insideBundle = !relative(VAULT, abs).startsWith("..");
      if (insideBundle) {
        if (!existsSync(abs)) {
          (ALLOW_BROKEN ? warn : err)(file, `broken bundle link "${target}"`);
        } else if (abs.endsWith(".md") && inbound.has(idOf(abs))) {
          inbound.set(idOf(abs), inbound.get(idOf(abs)) + 1);
        }
      } else {
        if (relative(REPO_ROOT, abs).startsWith("..")) {
          err(file, `link escapes repository: "${target}"`);
          continue;
        }
        if (!existsSync(abs)) err(file, `broken citation link "${target}"`);
        if (currentH2 === CITATIONS_SECTION) citesOutOfBundle = true;
        if (!exempt && currentH2 !== CITATIONS_SECTION)
          err(
            file,
            `out-of-bundle link "${target}" outside "## ${CITATIONS_SECTION}" (found under "${currentH2 || "preamble"}")`
          );
      }
    }
  }

  // --- stub types must actually cite their source of truth
  if (typeCfg?.stub && !citesOutOfBundle)
    err(
      file,
      `type "${fmType}" is a stub: it must cite its source-of-truth doc under "## ${CITATIONS_SECTION}"`
    );
}

// ---------------------------------------------------------------- canvas nodes
for (const file of canvasFiles) {
  let canvas;
  try {
    canvas = JSON.parse(readFileSync(file, "utf8"));
  } catch (e) {
    err(file, `canvas is not valid JSON: ${e.message}`);
    continue;
  }
  for (const node of canvas.nodes ?? []) {
    if (node.type !== "file" || !node.file) continue;
    // Canvas file paths are Obsidian-vault-relative; try vault, then bundle, then repo.
    const candidates = [
      resolve(dirname(VAULT), node.file),
      resolve(VAULT, node.file),
      resolve(REPO_ROOT, node.file),
    ];
    if (!candidates.some(existsSync))
      err(file, `canvas node references missing file "${node.file}"`);
  }
}

// ---------------------------------------------------------------- manifest sync
const manifestPath = join(VAULT, "_meta", "manifest.json");
if (existsSync(manifestPath)) {
  const manifest = JSON.parse(readFileSync(manifestPath, "utf8"));
  const entries = manifest.concepts ?? manifest;
  const diskIds = new Set(conceptFiles.map(idOf));
  const manIds = new Set(entries.map(e => e.id));
  for (const e of entries)
    if (!diskIds.has(e.id))
      (ALLOW_BROKEN ? warn : err)(
        manifestPath,
        `manifest concept "${e.id}" missing on disk`
      );
  // Always an error: the manifest is the ID registry that prevents invented links,
  // so a file it does not know about is a hole in the allowlist.
  for (const id of diskIds)
    if (!manIds.has(id)) err(manifestPath, `file "${id}.md" not in manifest`);
}

// ---------------------------------------------------------------- orphans
for (const [id, count] of inbound)
  if (count === 0)
    (STRICT_ORPHANS ? err : warn)(
      join(VAULT, `${id}.md`),
      "orphan: no inbound links"
    );

// ---------------------------------------------------------------- report
if (!QUIET) {
  for (const w of warnings) console.log(`WARN  ${w}`);
  for (const e of errors) console.log(`ERROR ${e}`);
}
console.log(
  `vault(${actualRoot || "."}): ${conceptFiles.length} concepts / ${mdFiles.length} md files` +
    `${canvasFiles.length ? ` / ${canvasFiles.length} canvases` : ""}` +
    ` — ${errors.length} errors, ${warnings.length} warnings` +
    (ALLOW_BROKEN ? " (broken links allowed)" : "")
);
process.exit(errors.length ? 1 : 0);
