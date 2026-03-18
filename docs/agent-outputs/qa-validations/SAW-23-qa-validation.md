# QA Validation Report: SAW-23 — Adoption Docs Update

**Ticket**: SAW-23
**Validator**: QAS (Quality Assurance Specialist)
**Date**: 2026-03-18
**Branch**: template
**Verdict**: APPROVED

---

## Acceptance Criteria Validation

### AC-1: WORKSPACE-ADOPTION-GUIDE.md updated with Codex CLI + Cursor IDE as providers

**Result**: PASS

**Evidence**:
- Line 28: `.codex/` listed with description "Codex CLI harness (config.toml, reads AGENTS.md) -- TOML config, MCP native"
- Line 29: `.cursor/` listed with description "Cursor IDE harness (.mdc rules with glob-based activation, background agents)"
- Line 30: `.agents/` listed with description "Shared agent skills (discovered by Codex CLI and other agents)"
- Line 32: `AGENTS.md` noted as "also read by Codex CLI as system instructions"
- Lines 41, 65-67, 159, 171-173, 352-354, 395-397, 412, 420-422: All adoption commands include `.codex/`, `.cursor/`, and `.agents/` directories
- "What you keep vs. customize" section (line 41) includes all four providers
- Update strategy table (lines 386-402) includes `.codex/`, `.cursor/rules/`, and `.agents/skills/`

### AC-2: GETTING-STARTED.md updated with all 4 providers

**Result**: PASS

**Evidence**:
- Path B adoption (line 49): `git checkout` includes `.codex/ .cursor/ .agents/`
- Verification section (lines 125-136):
  - Codex: `ls .codex/config.toml .codex/README.md` (line 126)
  - Cursor: `ls .cursor/rules/*.mdc | wc -l` (line 130)
  - Shared skills: `ls .agents/skills/ | wc -l` (line 134)
- Deep Dives section (lines 311-312): Links to `.codex/README.md` and `.cursor/rules/README.md`

**Minor finding**: Line 131 says "Expect: 14+ files" for `.cursor/rules/*.mdc` but actual count is 13. This is a cosmetic discrepancy (13 .mdc files + 1 README.md = 14 files total in the directory, but the glob `*.mdc` only matches 13). Severity: LOW. Not blocking.

### AC-3: README.md updated with all 4 providers (badges, quick-start, comparison)

**Result**: PASS

**Evidence**:
- **Badges** (lines 17-30): All 4 provider badges present with correct links:
  - Claude Code -> `.claude/`
  - Gemini CLI -> `.gemini/`
  - Codex CLI -> `.codex/`
  - Cursor IDE -> `.cursor/rules/`
- **Quick-start sections** (lines 63-121): All 4 providers have dedicated quick-start blocks:
  - Claude Code (line 63): `.claude/` copy + /start-work
  - Gemini CLI (line 76): `.gemini/` copy + npm install + /workflow:start-work
  - Codex CLI (line 92): `.codex/` + `.agents/` copy + npm install + natural language
  - Cursor IDE (line 109): `.cursor/` copy + cursor open + auto-activate rules
- **Multi-provider mentions** (line 42, 207, 214, 1216, 1219, 1339): All consistently list 4 providers
- **Repository structure** (lines 1228-1265): All 4 provider directories documented with descriptions
- **Comparison**: Detailed Gemini comparison in section (line 221). Codex CLI comparison table in `.codex/README.md` (line 167-175). Cursor comparison in `.cursor/rules/README.md` (lines 109-119). Cross-referenced appropriately.

### AC-4: OPTIONAL-FEATURES.md updated if it mentions providers

**Result**: PASS

**Evidence**:
- OPTIONAL-FEATURES.md does not require provider-specific updates. The removal checklists reference `.claude/skills/` and `.gemini/skills/` which are the correct locations for those providers' skills.
- Codex CLI uses `.agents/skills/` (shared, not provider-specific) -- no removal checklist needed
- Cursor IDE uses `.cursor/rules/` (.mdc files) -- not referenced in feature removal checklists because rules are not feature-specific integrations
- Dark Factory section (line 609) correctly references "Cursor IDE via SSH"
- No stale or incorrect provider references found

---

## Additional Verification: Codex CLI Accuracy

### Codex CLI references are CORRECT per real OpenAI docs

**Result**: PASS

| Claim | Expected | Actual | Status |
|-------|----------|--------|--------|
| System instructions file | `AGENTS.md` (not CODEX.md) | Correct -- `.codex/README.md` lines 30, 37, 144 explicitly state this | PASS |
| Configuration file | `config.toml` (not settings.json) | Correct -- `.codex/config.toml` exists, README line 145 states no settings.json | PASS |
| Skills location | `.agents/skills/` (not .codex/skills/) | Correct -- `.agents/skills/` exists with 3 skills, README line 146 states no .codex/skills/ | PASS |
| No stale CODEX.md references | No docs point to CODEX.md as a real file | Correct -- only cautionary mentions that it does NOT exist | PASS |

### Cursor IDE references are correct

**Result**: PASS

| Claim | Expected | Actual | Status |
|-------|----------|--------|--------|
| Rules location | `.cursor/rules/*.mdc` | Correct -- 13 .mdc files exist with proper YAML frontmatter | PASS |
| Background agents | Documented for isolated VMs | Correct -- `30-background-agents.mdc` provides guidelines | PASS |
| MCP integration | `.cursor/mcp.json` config | Correct -- `31-mcp-integration.mdc` documents configuration | PASS |
| Rule activation modes | alwaysApply, globs, manual | Correct -- `.cursor/rules/README.md` documents all 3 modes | PASS |

---

## Stale Reference Check

```
grep -r 'CODEX.md' (excluding self-referential docs): NO MATCHES
grep -r '.codex/settings.json' (excluding self-referential): NO MATCHES  
grep -r '.codex/commands' (excluding self-referential): NO MATCHES
grep -r '.codex/skills/' (excluding self-referential): NO MATCHES
```

All clear. No stale references detected.

---

## Summary

| Criterion | Result |
|-----------|--------|
| AC-1: WORKSPACE-ADOPTION-GUIDE.md | PASS |
| AC-2: GETTING-STARTED.md | PASS |
| AC-3: README.md (badges, quick-start, comparison) | PASS |
| AC-4: OPTIONAL-FEATURES.md | PASS |
| Codex CLI reference accuracy | PASS |
| Cursor IDE reference accuracy | PASS |
| Stale reference check | PASS |

**Minor findings (non-blocking)**:
1. GETTING-STARTED.md line 131: "14+ files" should be "13+ files" for `.cursor/rules/*.mdc` glob (actual: 13 .mdc files). The "14" likely counts the README.md, but the `*.mdc` glob would not match it.

---

## Final Verdict: APPROVED

All acceptance criteria are met. Codex CLI and Cursor IDE references are accurate per real provider documentation. No stale or incorrect references found. The one minor cosmetic finding (mdc count) is non-blocking.

**Approved for RTE.**
