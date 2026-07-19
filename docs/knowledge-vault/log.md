# Log

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

The build surfaced 86 `DOC DRIFT` and 52 `UNKNOWN` clauses. Two independently rediscovered known
open issues from source: the squash-versus-rebase contradiction (GH#33) and `replaced` not being
enforced by the sync engine (GH#39).

It also surfaced five BSD/macOS portability defects in the sync engine, fixed under SAW-60 and
SAW-61. **Those fixes are not in this baseline.** At `fd0fc6a` the measured local sweep is **4 of 9
suites passing**, and the sync concepts record that state, because that is what
`verified_against: fd0fc6a` asserts. On the SAW-61 branch the same sweep reaches 8 of 9. When those
tickets merge, the baseline moves and every sync concept should be re-derived and re-stamped — a
citation is not re-verification.
