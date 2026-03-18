# QA Validation Report: SAW-3 (B5) -- Protected File Enforcement

**Ticket**: SAW-3
**Branch**: SAW-3-protected-files
**Reviewer**: QAS (Claude Opus 4.6)
**Date**: 2026-03-17
**Verdict**: APPROVED

---

## Test Suite Results

| Suite | Result | Count |
|-------|--------|-------|
| test-protected-files.sh | PASS | 54/54 |
| test-manifest-loader.sh (regression) | PASS | 24/24 |
| test-rename-diff.sh (regression) | PASS | 50/50 |
| bash -n syntax check | PASS | exit 0 |

**Total assertions validated**: 128/128 (0 failures)

---

## Acceptance Criteria Verification

### AC-1: Manifest `protected` section prevents listed files from being modified during sync
**PASS**

- `is_protected()` checks merged patterns from manifest `protected` array and `.sync-exclude`.
- `do_sync()` calls `is_excluded()` which delegates to `is_protected()` when manifest is present; protected files are skipped with `print_warning "Skipping protected: ..."` (line 1418).
- Test 9 confirms: `CLAUDE.md` retains `LOCAL CLAUDE CONTENT` after sync; `settings.local.json` retains local content; non-protected `system-architect.md` is updated to upstream content.
- Test 18 confirms dry-run also reports protected files without modifying them.
- Test 19 confirms empty `protected: []` does not interfere with normal sync.

### AC-2: `sync diff` shows `PROTECTED  CLAUDE.md (upstream has changes, skipping per manifest)`
**PASS**

- `do_diff()` distinguishes `PROTECTED` (manifest) from `EXCLUDED` (.sync-exclude) via `is_manifest_protected()` (line 1201-1207).
- Test 7 asserts exact string: `PROTECTED  CLAUDE.md (upstream has changes, skipping per manifest)`.
- Test 8 confirms summary line includes protected count.

### AC-3: `.sync-exclude` still works as fallback (backward compatible)
**PASS**

- `is_excluded()` has two code paths: when `HAS_MANIFEST=true` it delegates to `is_protected()` (merged); when `HAS_MANIFEST=false` it falls back to legacy `.sync-exclude` file reading (lines 1054-1073).
- Test 4 confirms `.sync-exclude` patterns work without a manifest.
- Test 12 confirms no `PROTECTED` label appears without manifest; `.sync-exclude` entries show `EXCLUDED` label.

### AC-4: If both `.sync-exclude` and manifest `protected` exist, manifest takes precedence + entries merged
**PASS**

- `get_protected_patterns()` reads manifest `protected` array first, then appends `.sync-exclude` entries with de-duplication (lines 748-794).
- Test 5 confirms: manifest-only pattern works, `.sync-exclude`-only pattern works, pattern in both works, pattern in neither returns false.
- Test 6 confirms de-duplication: `settings.local.json` (present in both sources) appears exactly once in merged output.

### AC-5: Warning emitted if a protected path does not exist locally (possible typo)
**PASS**

- `validate_protected_paths()` (lines 880-945) collects local file paths, converts each manifest pattern to regex (via Node.js), and emits `WARN:` for patterns that match no local file.
- Warning message format: `Protected pattern does not match any local file: <pattern> (possible typo in manifest)`.
- Test 11 asserts warnings for two non-existent paths and the `possible typo in manifest` substring.

### AC-6: Glob patterns supported in protected section
**PASS**

- `is_protected()` uses bash `[[ "$file" == $pattern ]]` (unquoted RHS enables glob matching) for `*` and `?` patterns (line 813).
- `is_manifest_protected()` uses Node.js regex conversion: `**` -> `.*`, `*` -> `[^/]*`, `?` -> `.` (lines 849-852).
- Test 2 confirms: `agents/custom-*.md` matches `agents/custom-agent.md` and `agents/custom-devops.md`, but not `agents/fe-developer.md`.
- Test 14 confirms: `skills/custom-*/**` matches `skills/custom-auth/SKILL.md` and `skills/custom-auth/nested/deep.md`; `*.local.json` matches both `settings.local.json` and `other.local.json`.

---

## Code Review Findings

### Implementation Quality

1. **Function separation is clean**: `get_protected_patterns()`, `is_protected()`, `is_manifest_protected()`, and `validate_protected_paths()` are well-separated and documented with section headers.

2. **Glob-to-regex conversion is correct**: The `is_manifest_protected()` and `validate_protected_paths()` functions both use the same pattern: escape regex special chars, replace `**` with `.*`, replace `*` with `[^/]*`, replace `?` with `.`, then anchor with `^...$`. This correctly distinguishes single-level (`*`) from recursive (`**`) globs.

3. **De-duplication logic is O(n*m) but acceptable**: The `get_protected_patterns()` de-dup loop is quadratic in the number of patterns, but since protected patterns are typically a small set (single digits), this is not a performance concern.

4. **Hardcoded exclusions are consistent**: Both `is_protected()` and `is_excluded()` have identical hardcoded checks for `.harness-sync.json`, `.harness-manifest.yml`, `.sync-exclude`, `.sync-exclude.default`, and `.harness-backup*`. This ensures metadata files are always protected regardless of manifest content.

5. **No product code was modified**: Implementation is confined to `scripts/sync-claude-harness.sh` and `tests/test-protected-files.sh`.

### Minor Observation (non-blocking)

- The `is_protected()` function's substring match (`[[ "$file" == *"$pattern"* ]]` on line 817) is more permissive than strict glob matching. This is intentional for backward compatibility with `.sync-exclude` behavior where entries like `settings.local.json` should match regardless of path prefix. This is documented in the code comment.

---

## Regression Impact

- **manifest-loader tests**: 24/24 PASS (no regression)
- **rename-diff tests**: 50/50 PASS (no regression)
- **Syntax check**: Clean (exit 0)

---

## Final Verdict

**APPROVED** -- All 6 acceptance criteria are met with full test coverage. 128/128 total assertions pass across primary and regression suites. Implementation is clean, well-documented, and backward compatible. No regressions detected.

Ready for SecEng review (SAW-8 / C1-SEC) and then merge.
