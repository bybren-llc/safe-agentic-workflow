# QA Validation Report: SAW-5 -- Rename-Aware Diff and Status

**Ticket**: SAW-5
**Branch**: SAW-5-rename-aware-diff
**Reviewer**: QAS (Claude Opus 4.6)
**Date**: 2026-03-17
**Verdict**: APPROVED

---

## Test Suite Results

### Primary Test Suite: test-rename-diff.sh

```
Total:  50
Passed: 50
Failed: 0
ALL TESTS PASSED
```

18 test groups covering: resolve_rename (file, directory, passthrough, no-manifest, precedence),
rename_type, do_diff (renamed/unrenamed/count/backward-compat), do_status (renames/no-renames),
compare_file_with_paths, local-only detection with renames, do_sync file placement, syntax check,
and regression pass-through of SAW-6 manifest loader tests.

### Regression Test Suite: test-manifest-loader.sh

```
Total:  24
Passed: 24
Failed: 0
ALL TESTS PASSED
```

12 test groups covering: legacy fallback, manifest parsing, validation (required fields, invalid
version, missing identity), summary format, empty sections, backward compatibility, status output,
exclusion list, and invalid YAML fallback.

### Syntax Check: bash -n scripts/sync-claude-harness.sh

```
Exit code: 0 (no syntax errors)
```

---

## Acceptance Criteria Verification

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | `sync diff` uses manifest renames when comparing upstream `.claude/` to local `.claude/` | **PASS** | Test 7 (do_diff -- shows renamed files with correct local path): all 7 assertions pass. `do_diff` calls `resolve_rename()` at line 817 and `compare_file_with_paths()` at line 828 using the resolved local path. |
| 2 | File rename: upstream `skills/rls-patterns/SKILL.md` compared to local `skills/firestore-security/SKILL.md` | **PASS** | Test 2 assertion `DIR_SKILL: skills/firestore-security/SKILL.md` passes. Test 7 assertion `skills/firestore-security/SKILL.md (upstream: skills/rls-patterns/SKILL.md)` passes. |
| 3 | Directory rename: all files under renamed directory correctly mapped | **PASS** | Test 2: SKILL.md, README.md, sub/nested.md all resolve under `skills/firestore-security/`. Test 9: file counts verified (3 files for rls-patterns, 1 for stripe-patterns). |
| 4 | Status output labels renamed files: `RENAMED rls-patterns/ -> firestore-security/ (N files)` | **PASS** | Test 9 assertions verify `skills/rls-patterns/ -> skills/firestore-security/ (3 files)` and `skills/stripe-patterns/ -> skills/payment-patterns/ (1 files)`. Test 12 verifies `do_status` shows rename mappings with type annotations (file/dir). |
| 5 | Diff shows correct local path (not upstream path) for renamed files | **PASS** | Test 7 verifies `agents/ui-engineer.md (upstream: agents/fe-developer.md)` format for file renames, and `skills/firestore-security/SKILL.md (upstream: skills/rls-patterns/SKILL.md)` for directory renames. Test 8 verifies unrenamed files do NOT get the annotation. |
| 6 | No manifest = no rename resolution (backward compatible) | **PASS** | Test 4: `resolve_rename` returns original path when HAS_MANIFEST=false. Test 11: `do_diff` with no manifest shows original paths, no `(upstream:)` annotation, no `RENAMED` lines. Test 13: `do_status` without manifest shows "No manifest found" message and no rename mappings. |

---

## Code Quality Assessment

### DRY/SOLID Compliance

- **PASS**: Rename resolution is centralized in `resolve_rename()` (line 449), defined once and called in exactly 3 places (do_diff line 817, do_diff line 873 for local-path tracking, do_sync line 1010).
- **PASS**: `rename_type()` and `get_directory_renames()` are complementary helpers in the same section (lines 437-548), clearly delimited with section comments.
- **PASS**: All four rename-related functions share a consistent guard clause pattern: `if [ "$HAS_MANIFEST" != "true" ] || [ -z "$MANIFEST_JSON" ] || [ ! -f "$MANIFEST_JSON" ]`.

### File Rename Precedence over Directory Rename

- **PASS**: `resolve_rename()` checks exact file matches first (line 465), then falls through to directory prefix matches (line 471). Verified by Test 5 where `skills/rls-patterns/SKILL.md` resolves to `skills/custom-skill.md` (file rename) while `skills/rls-patterns/README.md` resolves to `skills/firestore-security/README.md` (directory rename).

### Backward Compatibility

- **PASS**: `HAS_MANIFEST` defaults to `false` (line 33). Every rename function returns a safe default (original path or "none") when manifest is absent. `load_manifest()` gracefully falls back on missing file, missing python3, missing PyYAML, or invalid YAML.

### Additional Observations

- `validate_renames_against_upstream()` emits warnings for stale rename entries (sources not found in upstream). Good defensive behavior.
- `do_diff` correctly excludes rename targets from "LOCAL ONLY" reporting by building a resolved-paths lookup file (lines 870-874, 891).
- `do_sync` writes files to the renamed local path, not the upstream path (Test 16 verifies both file existence at renamed path and absence at upstream path).

---

## Summary

All 50 primary assertions and 24 regression assertions pass. All 6 acceptance criteria verified as PASS. Syntax check clean. Code follows DRY/SOLID principles with centralized rename resolution. Backward compatibility confirmed through guard clauses and dedicated no-manifest test cases.

**Final Verdict: APPROVED**
