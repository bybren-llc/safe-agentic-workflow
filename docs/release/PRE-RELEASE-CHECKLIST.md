# Pre-Release Checklist

> **MANDATORY**: This checklist must be completed before creating any release tag.
> No exceptions. If any item fails, the release is blocked until resolved.

## Release Information

- **Version**: _____________
- **Release branch**: `template`
- **Previous version**: _____________
- **Linear Epic/Stories**: _____________
- **Release owner**: _____________
- **Date**: _____________

---

## 1. Code Quality Gates

- [ ] All feature branches merged to `template`
- [ ] `bash -n scripts/sync-claude-harness.sh` — syntax check passes
- [ ] All test suites pass (list each with count):
  - [ ] `test-manifest-loader.sh`: ___/___
  - [ ] `test-rename-diff.sh`: ___/___
  - [ ] `test-substitutions.sh`: ___/___
  - [ ] `test-protected-files.sh`: ___/___
  - [ ] `test-preflight.sh`: ___/___
  - [ ] `test-fork-sync.sh`: ___/___
  - [ ] `test-patch-generation.sh`: ___/___
  - [ ] `test-manifest-init.sh`: ___/___
  - [ ] Total: ___/___ (zero failures)
- [ ] No merge conflict markers in any file: `grep -r '<<<<<<' . --include='*.sh' --include='*.md' --include='*.json' --include='*.toml' --include='*.yml'`
- [ ] `shellcheck scripts/*.sh` — no new warnings (document pre-existing)

## 2. Documentation Completeness

- [ ] `README.md` — accurate provider list, feature descriptions, version references
- [ ] `docs/HARNESS_SYNC_GUIDE.md` — reflects all sync features in this release
- [ ] `docs/HARNESS_MANIFEST_SCHEMA.md` — schema matches implementation
- [ ] `docs/guides/GETTING-STARTED.md` — setup instructions current
- [ ] `docs/guides/WORKSPACE-ADOPTION-GUIDE.md` — provider list current
- [ ] `docs/guides/OPTIONAL-FEATURES.md` — optional features list current
- [ ] `.claude/README.md` — Claude Code harness docs current
- [ ] `.codex/README.md` — Codex CLI setup guide current (if applicable)
- [ ] `.cursor/rules/README.md` — Cursor rules index current (if applicable)
- [ ] `.gemini/README.md` — Gemini CLI docs current (if applicable)
- [ ] No stale references to removed files: `grep -r 'CODEX.md\|\.codex/settings\.json\|\.codex/commands' docs/ README.md .claude/ .codex/ .cursor/ .gemini/ 2>/dev/null`
- [ ] `HARNESS_CHANGELOG.yml` updated for this release (or generated via `generate-changelog.sh`)

## 3. Third-Party Integration Verification

> **CRITICAL**: For any new or updated third-party tool integration, verify against real vendor documentation. Never ship based on extrapolation alone.

- [ ] **Vendor doc verification**: Each third-party integration checked against official docs
  - [ ] Claude Code: Anthropic docs — https://docs.anthropic.com/claude-code
  - [ ] Codex CLI: OpenAI docs — https://developers.openai.com/codex
  - [ ] Cursor IDE: Cursor docs — https://docs.cursor.com
  - [ ] Gemini CLI: Google docs — https://ai.google.dev/gemini-api
- [ ] Source URLs documented in Linear tickets for QAS verification
- [ ] No fabricated configuration formats (verify every file format, directory path, config key)

## 4. SAFe Workflow Gates

- [ ] All stories QAS-approved (non-collapsible gate)
- [ ] Security Engineer review complete (where applicable, non-collapsible)
- [ ] System Architect Stage 1 approved
- [ ] All Linear tickets marked Done with evidence
- [ ] No stories in "In Progress" or "In Review" state for this release

## 5. Template Compatibility

- [ ] All new files use `{{PLACEHOLDER}}` tokens (not hardcoded project values)
- [ ] `scripts/setup-template.sh` can process all new files: `find . -name '*.md' -o -name '*.json' -o -name '*.toml' -o -name '*.yml' -o -name '*.mdc' | head -20`
- [ ] Example manifests updated (if manifest schema changed):
  - [ ] `examples/manifests/rendertrust.harness-manifest.yml`
  - [ ] `examples/manifests/keryk-ai.harness-manifest.yml`
- [ ] `.harness-manifest.schema.json` updated (if manifest schema changed)

## 6. Backward Compatibility

- [ ] Existing forks NOT broken by this release (no manifest = legacy behavior)
- [ ] Fork-sync CI tests pass against known fork configurations
- [ ] No breaking changes without `BREAKING CHANGES` section in release notes
- [ ] If breaking: migration guide included in docs

## 7. Release Artifacts

- [ ] Git tag created: `git tag -a vX.Y.Z -m "..."`
- [ ] Tag pushed: `git push origin template --tags`
- [ ] GitHub Release created with:
  - [ ] Accurate feature list
  - [ ] Breaking changes section (if any)
  - [ ] Errata section (if fixing previous release issues)
  - [ ] Test coverage summary
  - [ ] Source attribution (Co-Authored-By)
- [ ] Previous release issues noted (if this is a fix release)

## 8. Post-Release Verification

- [ ] Release page accessible: `gh release view vX.Y.Z`
- [ ] Tag matches template HEAD: `git log --oneline -1 vX.Y.Z`
- [ ] Linear epic/stories closed
- [ ] Feature branches cleaned up: `git branch --list 'SAW-*'` returns empty

---

## Sign-Off

| Role | Name | Date | Approved |
|------|------|------|----------|
| Release Owner | | | [ ] |
| QAS Gate | | | [ ] |
| HITL (POPM) | | | [ ] |

---

## Notes / Errata

_Document any known issues, deferred fixes, or caveats for this release._
