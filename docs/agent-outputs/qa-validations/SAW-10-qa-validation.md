# QA Validation Report: SAW-10 — Placeholder Substitution Engine

**Ticket**: SAW-10 (B4)
**Branch**: `SAW-10-substitution-engine`
**Commit**: `144602d feat(sync): add placeholder substitution engine for fork identity preservation [SAW-10]`
**Reviewer**: QAS (Claude Opus 4.6)
**Date**: 2026-03-17

---

## Test Suite Results

### Substitution Tests (`tests/test-substitutions.sh`)
- **Result**: 50/50 PASS
- 15 test groups covering all AC items
- Tests cover: basic tokens, longest-match ordering, code example preservation, literal strings, --no-placeholders flag, backup integrity, sync integration, no-manifest backward compat, empty substitutions, special characters, non-existent file handling, binary file skip, syntax validation, regression, and help text

### Regression: Manifest Loader (`tests/test-manifest-loader.sh`)
- **Result**: 24/24 PASS

### Regression: Rename-Diff (`tests/test-rename-diff.sh`)
- **Result**: 50/50 PASS

### Syntax Check (`bash -n scripts/sync-claude-harness.sh`)
- **Result**: PASS

---

## Acceptance Criteria Verification

### AC-1: After fetching upstream files, re-apply fork-specific values from manifest substitutions
- **PASS**
- `apply_all_substitutions()` is called at line 1480 of `do_sync()`, AFTER the file copy loop (lines 1410-1474)
- Identity values from `manifest.identity` and explicit `manifest.substitutions` are both applied
- Evidence: Test 1 (basic tokens), Test 7 (sync integration), Test 9 (empty substitutions with identity)

### AC-2: Substitutions applied in longest-match-first order (prevents partial matches)
- **PASS**
- Line 643-644: `const sortedKeys = Object.keys(combined).sort((a, b) => b.length - a.length);`
- This sorts by key length descending, ensuring `{{GITHUB_REPO_URL}}` is matched before `{{GITHUB_ORG}}`
- Evidence: Test 2 explicitly verifies longest-match-first ordering

### AC-3: Both `{{PLACEHOLDER}}` tokens and literal string substitutions supported
- **PASS**
- Identity keys are mapped as `{{KEY}} -> value` (lines 622-626)
- Explicit substitutions support both `{{PLACEHOLDER}}` tokens and bare literal strings (lines 632-639)
- Evidence: Test 1 (tokens), Test 4 (literal strings like `safe-agentic-workflow`, `SAW`, `ByBren-LLC`)

### AC-4: `--no-placeholders` flag skips substitution step
- **PASS**
- Flag parsed at line 1364-1366 in `do_sync()` argument parsing
- Conditional at line 1479-1482: skips `apply_all_substitutions` and prints info message
- Flag documented in help text at line 1733 and example at line 1752
- Evidence: Test 5 verifies flag behavior, Test 15 verifies help text inclusion

### AC-5: Backup retains upstream originals (substitution happens after backup)
- **PASS**
- Operation ordering in `do_sync()`:
  1. Line 1404: `create_backup` (saves pre-sync local state)
  2. Lines 1456/1466: `cp "$file" "$local_file"` (copy upstream originals)
  3. Line 1480: `apply_all_substitutions "$CLAUDE_DIR"` (substitute on local copies)
- Backup captures the state BEFORE sync; upstream files are copied, THEN substituted
- Evidence: Test 6 verifies backup content differs from post-substitution local content

### AC-6: Code examples with `{{...}}` in markdown not accidentally substituted — only manifest-declared keys
- **PASS**
- The engine does NOT regex-scan for arbitrary `{{...}}` patterns
- It builds explicit sed commands ONLY from keys declared in `manifest.identity` and `manifest.substitutions`
- Non-manifest patterns like `{{CHECKOUT_SESSION_ID}}`, `{{UNKNOWN_PLACEHOLDER}}`, `{{#items}}`, `{{/items}}` are preserved
- Evidence: Test 3 verifies Stripe `{{CHECKOUT_SESSION_ID}}`, unknown placeholders, and Mustache templates are all preserved

---

## Code Quality Assessment

### Implementation Quality
- Clean separation: `apply_substitutions()` (single file) and `apply_all_substitutions()` (directory walk)
- Proper sed BRE escaping for special characters in keys and values
- Cross-platform sed handling (GNU vs BSD)
- Binary file exclusion by extension (only processes `.md`, `.json`, `.yml`, `.yaml`, `.sh`, `.py`, `.txt`, `.toml`, `.ts`, `.mjs`, `.bib`, `.cff`)
- Graceful handling of missing files, empty manifests, and no-manifest scenarios
- Node.js used for JSON/sorting (consistent with existing manifest loader pattern)

### Backward Compatibility
- No-manifest mode continues to work unchanged (Test 8)
- Empty substitutions section produces no errors (Test 9)
- All prior SAW-5 and SAW-6 tests pass without modification

### Changeset Scope
- 2 files changed: `scripts/sync-claude-harness.sh` (+472 lines), `tests/test-substitutions.sh` (+797 lines, new file)
- No unrelated changes

---

## Final Verdict

**APPROVED** — All 6 acceptance criteria verified. All 124 test assertions pass (50 + 24 + 50). No regressions. Code quality is high with proper edge case handling, backward compatibility, and comprehensive test coverage.

---

**QAS validation complete for SAW-10. All criteria PASSED. Approved for merge.**
