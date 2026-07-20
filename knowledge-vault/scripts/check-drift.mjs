// Compute which vault concepts a set of changed paths makes stale.
//
// A concept is stale IFF a changed path matches its `resource` or one of its
// `sources`. That mapping is the manifest's reverse index — the second of the
// three jobs the manifest does.
//
// Usage:
//   node knowledge-vault/scripts/check-drift.mjs --vault <dir> [--since <sha>]
//   node knowledge-vault/scripts/check-drift.mjs --vault <dir> --paths a.md,b.sh
//
// --since diffs baseline..HEAD. --paths takes an explicit list, which is what
// makes the behaviour testable without mutating the working tree.
import { readFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';

const argv = process.argv.slice(2);

// Returns the flag's value, or `d` when the flag is absent.
// Deliberately strict about two cases that used to fail silently:
//   - `--paths ""` and a trailing bare `--paths` previously fell through to the
//     default, turning "check these zero paths" into "diff the entire baseline".
//   - A flag immediately followed by another flag used to swallow it as a value.
// Both now exit with a message rather than quietly doing something else.
const arg = (n, d = null) => {
  const i = argv.indexOf(n);
  if (i < 0) return d;
  const v = argv[i + 1];
  if (v === undefined || v.startsWith('--')) {
    console.error(`error: ${n} requires a value`);
    process.exit(2);
  }
  return v;
};

const vault = arg('--vault', 'docs/knowledge-vault');
const manifest = JSON.parse(readFileSync(`${vault}/_meta/manifest.json`, 'utf8'));
const config = JSON.parse(readFileSync(`${vault}/_meta/vault-config.json`, 'utf8'));

const exclusions = config.watch_list_exclusions ?? [];
const excluded = (p) =>
  exclusions.some((ex) => {
    const base = ex.replace(/\/\*\*$/, '');
    return p === base || p.startsWith(base.endsWith('/') ? base : base + '/');
  });

let changed;
// `--paths` present at all means explicit mode, even if it resolves to an empty list.
// Testing truthiness here is what let an empty value fall through to a full diff.
const explicitMode = argv.includes('--paths');
if (explicitMode) {
  changed = arg('--paths').split(',').map((s) => s.trim()).filter(Boolean);
} else {
  const since = arg('--since', manifest.baseline_sha);
  // execFileSync with an argument array, never a shell string. `since` can come from
  // the manifest JSON, so interpolating it into a shell command was arbitrary code
  // execution: `--since 'x ; touch /tmp/PWNED ; echo y'` ran.
  changed = execFileSync('git', ['diff', '--name-only', `${since}..HEAD`], {
    encoding: 'utf8',
  })
    .split('\n')
    .map((s) => s.trim())
    .filter(Boolean);
}

const inScope = changed.filter((p) => !excluded(p));
const skipped = changed.filter(excluded);

// Reverse index: source path -> concepts that cite it
const stale = new Map();
for (const c of manifest.concepts) {
  const cites = [c.resource, ...(c.sources ?? [])].filter(Boolean);
  for (const p of inScope) {
    if (cites.includes(p)) {
      if (!stale.has(c.id)) stale.set(c.id, []);
      stale.get(c.id).push(p);
    }
  }
}

console.log(`changed paths      : ${changed.length}`);
console.log(`excluded by config : ${skipped.length}${skipped.length ? ' -> ' + skipped.slice(0, 3).join(', ') + (skipped.length > 3 ? ' ...' : '') : ''}`);
console.log(`in scope           : ${inScope.length}`);
console.log(`STALE CONCEPTS     : ${stale.size}`);
for (const [id, paths] of [...stale].sort()) {
  console.log(`  ${id}`);
  for (const p of paths) console.log(`      <- ${p}`);
}
process.exit(0);
