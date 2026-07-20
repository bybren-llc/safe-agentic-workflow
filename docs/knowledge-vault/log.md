# Log

## 2026-07-20 (SAW-66)

**Public-accuracy pass before the v2.11.1 release.** Three read-only audits over the merged work,
the two published guides, and the adopter path found errors more severe than the open tickets: a
shell-injection PoC output file (`2..HEAD`) committed at the repo root, an unreplaced
`{{HARNESS_VERSION}}` in the README footer, a "all four providers" claim that is false (skills ship
for three; Cursor is a rule), `install-prompts.sh` aborting on a clean clone, and a stale
`SECURITY.md` version table. All fixed in `0c26121` and the following commit.

Re-derived every concept whose source `0c26121` changed. 30 concepts re-stamped to `0c26121` this
pass; most verified unchanged. Corrections that mattered: `install-prompts` (described a bug this
pass fixed), `safe-ai-dlc` and the manifest note (the "all four providers" discrepancy is resolved),
`root-docs/security` (SECURITY.md version drift resolved), `setup-template` (a pre-existing 28→26
prompt-count error), and the README line count (1476→1477 across concept and two manifest notes).

**`baseline_sha` still `fd0fc6a`.** Measured from that baseline the vault now shows 57 stale (the 49
prior plus source touched this pass). 36 are re-derived; **21 remain truly untouched** — down from 23
because `setup-template` and `install-prompts` were reconciled here. The remaining 21 are the
`sync/*`, `providers/*` and onboarding concepts tracked in SAW-67. The watermark moves when they are
reconciled, not before.

## 2026-07-20

**Docs-accuracy pass (SAW-63, SAW-64, SAW-65).** 27 concepts re-derived from source and re-stamped
to `a79c2bd` / `c4f9d6d`: everything citing the files reworded for OKF attribution, opt-in Bolt
cadence, and the Obsidian reading layer. Several came back verified-unchanged and were stamped
without edits.

Corrected in the vault's own claims: `providers/rules/methodology.md` described
`max_concept_lines` as "machine-enforced" when `validate-vault.mjs:320-323` only warns and exits 0;
`subsystems/knowledge-vault.md` said the validator ran in no CI workflow, contradicted by
`.github/workflows/validate-vault.yml` since `dc016c3`. Three stale line counts in manifest `notes`
fixed (81→82, 146→148, 1463→1476).

**`baseline_sha` deliberately NOT moved.** It stays at `fd0fc6a`. Measured from that baseline the
vault has 49 stale concepts; this pass re-stamped 27 (26 of them among the 49), leaving **23 untouched** — mostly `sync/*`,
`providers/*` and `operations/scripts/*` concepts that drifted during the v2.11.0 release work.
Advancing the watermark would have dropped the default `check-drift` report from 49 to 0 and made
that debt invisible, since `check-drift.mjs:53` defaults `--since` to `baseline_sha` and never reads
`verified_against`. The remaining 23 are tracked separately; the baseline moves when they are
reconciled, not before.

## 2026-07-19

**Initial build of the SAW knowledge vault.** Baseline `fd0fc6a` on `dev`, after GH#53 (SAFe x
AI-DLC methodology layer) and GH#55 (OKF knowledge-vault subsystem) merged.

Built per `knowledge-vault/docs/SAW-VAULT-BUILD.md` as epic SAW-53, stories SAW-54 through SAW-59.

- **Extract (SAW-55)** — 8 agents produced fact digests for 215 concepts. Folding held: 11 agent
  roles rather than 33 across three provider formats, 20 skills rather than 40 across two surfaces,
  4 cursor-rule families rather than 18 files. Zero `adr` concepts were written, because no
  `docs/adr/` exists and the type requires a source — the build doc's predicted failure mode did not
  occur.
- **Generate (SAW-56)** — 23 lane agents wrote 210 concepts against 5 hand-accepted golden examples.
  Zero invented links across the run; every link target was a manifest ID.
- **Navigate (SAW-57)** — 5 domain concepts, the index cascade, `start-here.md`, 2 canvases and 4
  Bases views including the drift dashboard. Total 220 concepts.

### Corrections made during the build

- `script` and `test-suite` were configured `stub: true`, requiring an out-of-bundle source-of-truth
  citation. Their sources are `.sh` and `.py` files, which the constitution forbids linking, so for
  concepts with no companion prose doc the contract was unsatisfiable and would have forced invented
  citations. Both are now non-stub with `resource_required` retained; traceability is unchanged.
  This defect originates in `SAW-VAULT-BUILD.md`'s proposed config and should be fixed upstream.
- The build doc has 8 extraction agents writing one `manifest.json` concurrently, which is a write
  race. Agents wrote disjoint `_meta/manifest-parts/<lane>.json` fragments, merged deterministically.
- One extraction claim — that `pre-release-check.sh` invokes none of the test suites — was false and
  was corrected before it reached a concept. The script runs every suite and exits 1 with
  `RELEASE BLOCKED`. Its real defect is that `timeout` and `grep -oP` are absent on stock macOS, so
  it over-blocks rather than under-blocks.

### Findings raised against the harness

Of 221 concepts in the extraction manifest, 86 carry a `DOC DRIFT` clause and 54 carry an
`UNKNOWN` clause — 150 and 56 occurrences respectively. Two independently rediscovered known
open issues from source: the squash-versus-rebase contradiction (GH#33) and `replaced` not being
enforced by the sync engine (GH#39).

It also surfaced five BSD/macOS portability defects in the sync engine, fixed under SAW-60 and
SAW-61. **Those fixes are not in this baseline.** At `fd0fc6a` the measured local sweep is **4 of 9
suites passing**, and the sync concepts record that state, because that is what
`verified_against: fd0fc6a` asserts. On the SAW-61 branch the same sweep reaches 8 of 9. When those
tickets merge, the baseline moves and every sync concept should be re-derived and re-stamped — a
citation is not re-verification.
