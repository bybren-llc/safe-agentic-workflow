# QA Validation Report: SAW-32

**Story**: SAW-32 — QAS + Docs + Release: Full parity verification and v2.9.0 release
**Epic**: SAW-26 — Full SAFe Parity for Codex CLI + Cursor IDE
**Date**: 2026-03-18
**Validator**: Claude Opus 4.6 (automated) + Human review (HITL)

## 1. Automated Test Suite Execution

| Test Suite | Passed | Failed | Status |
|-----------|--------|--------|--------|
| test-manifest-loader.sh | 24 | 0 | PASS |
| test-rename-diff.sh | 50 | 0 | PASS |
| test-substitutions.sh | 50 | 0 | PASS |
| test-protected-files.sh | 54 | 0 | PASS |
| test-preflight.sh | 45 | 0 | PASS |
| test-fork-sync.sh | 61 | 0 | PASS |
| test-patch-generation.sh | 50 | 0 | PASS |
| test-manifest-init.sh | 48 | 0 | PASS |
| **TOTAL** | **382** | **0** | **ALL PASS** |

## 2. Static Analysis

| Check | Result | Notes |
|-------|--------|-------|
| `bash -n scripts/sync-claude-harness.sh` | PASS | Syntax valid |
| Merge conflict markers | PASS | Only self-referential docs match (PRE-RELEASE-CHECKLIST.md) |

## 3. Manual Verification

| Check | Result | Notes |
|-------|--------|-------|
| Template compatibility | PASS | Hardcoded values are copyright attribution only (WOR-563, intentional) |
| Stale references (CODEX.md) | PASS | Only self-referential docs and existing QA report |
| Branch references (template→main) | PASS | No stale template branch refs in scripts/configs |

## 4. Smoke Testing

| Artifact | Count | Valid | Status |
|----------|-------|-------|--------|
| Codex agent TOML files | 11 | 11 parse correctly | PASS |
| Shared skills (SKILL.md) | 18 | All present | PASS |
| Cursor rules (.mdc) | 16 | All present | PASS |
| Cursor MCP config | 1 | Valid JSON | PASS |
| Codex config.toml | 1 | Structure valid; strict TOML parse fails on `{{MCP_LINEAR_SERVER}}` table name (expected — placeholder resolved after `setup-template.sh`) | PASS (with caveat) |

## 5. Regression Testing

| Check | Result | Notes |
|-------|--------|-------|
| Sync script functionality | PASS | All fork-sync tests pass (61 assertions) |
| Manifest loader | PASS | 24 assertions |
| Setup-template.sh | PASS | HARNESS_VERSION updated to v2.9.0 |
| Version references consistent | PASS | CITATION.cff, CITATION.bib, README.md all at v2.9.0 |

## 6. Scenario Testing

| Scenario | Result | Notes |
|----------|--------|-------|
| Placeholder substitution | PASS | New .codex/agents/, .agents/skills/ files use `{{PLACEHOLDER}}` tokens where needed |
| Downstream fork sync | PASS | `upstream_branch: main` in test fixture, fork-sync tests pass |
| Branch rename migration | DOCUMENTED | v2.9.0-UPGRADE.md includes migration instructions |

## 7. Version Reference Audit

| File | Version | Status |
|------|---------|--------|
| CITATION.cff | 2.9.0 | PASS |
| CITATION.bib | 2.9.0 | PASS |
| README.md | v2.9 | PASS |
| scripts/setup-template.sh | v2.9.0 | PASS |

## 8. SAW-26 Story Completion Status

| Story | Points | Status | Evidence |
|-------|--------|--------|----------|
| SAW-27 | 5 | Done | 11 .codex/agents/*.toml |
| SAW-28 | 5 | Done | 18 .agents/skills/ |
| SAW-29 | 3 | Done | .codex/config.toml enriched |
| SAW-30 | 3 | Done | Dark Factory guide + tmux template |
| SAW-31 | 2 | Done | .cursor/mcp.json + 3 new rules |
| SAW-32 | 3 | In Progress | This QA report + release |
| **Total** | **21** | **5/6 Done** | |

## 9. Known Acceptable Issues

- `.codex/config.toml` fails strict TOML parse due to `{{MCP_LINEAR_SERVER}}` placeholder — this is by design for template repos, resolved after `setup-template.sh` runs
- 3 of 64 commits (4.7%) lack proper ticket references — preserved for lineage continuity per Architect review
- Historical merge commit messages reference "into template" — harmless artifacts from pre-rename

## Verdict

**QAS PASS** — All automated tests pass (382/382), all manual/smoke/regression/scenario checks pass. Ready for STAGE gate and release promotion.
