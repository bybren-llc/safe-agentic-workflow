# Structured Changelog: v2.9.0

**Date**: 2026-03-18
**Refs**: `v2.8.1`..`v2.9.0`
**Schema Version**: 1.0.0
**Commits**: 16 (since v2.8.1 tag)
**Epic**: SAW-26 — Full SAFe Parity for Codex CLI + Cursor IDE

## Release Summary

v2.9.0 completes the SAW-26 Epic: full SAFe parity across all three IDE providers
(Claude Code, Codex CLI, Cursor IDE). This release adds 11 Codex agent role definitions,
expands the shared skill library to 18 cross-provider skills, enriches Codex configuration
with MCP and agent profiles, adds Cursor MCP integration, and restructures the repository
branch topology from `template` to `main` + `dev` per GitHub template-hosting standards.

## Overview

| Category | Count | Scope |
| --- | --- | --- |
| Codex Agents (new) | 11 files | `.codex/agents/*.toml` |
| Shared Skills (new/expanded) | 15 files | `.agents/skills/` (was 3, now 18) |
| Codex Config (enriched) | 1 file | `.codex/config.toml` |
| Cursor MCP + Rules (new) | 4 files | `.cursor/mcp.json` + 3 new `.mdc` rules |
| Dark Factory Codex (new) | 2 files | `dark-factory/docs/`, `dark-factory/templates/` |
| PI Planning Template (new) | 3 files | `specs_templates/` (PR #30) |
| Branch Restructure | 6 files | CI, scripts, docs (template → main) |
| Release Artifacts | 4 files | Version bump, changelog, upgrade guide, QA report |

---

## PI Planning Template (PR #30)

Comprehensive SAFe Program Increment planning artifacts covering all 10 standard PI Planning sections:

- `specs_templates/pi_planning_template.md` — Markdown format (version control, agent consumption)
- `specs_templates/pi_planning_template.xlsx` — Spreadsheet format (spreadsheet-native teams)
- `specs_templates/README.md` — Template usage guide

Sections: Program Summary, Program Board, Sprint Plans, Delivery Teams, Enablers, Dependencies, ROAM Risks, Gate Criteria, POPM Decisions, mid-PI Update Log. All content uses `{{PLACEHOLDER}}` tokens.

---

## SAW-27: Codex Agent Role Definitions (5 pts)

11 TOML files in `.codex/agents/` mapping all SAFe roles per [OpenAI Codex Multi-Agent docs](https://developers.openai.com/codex/multi-agent/):

- `bsa.toml` — Business Systems Analyst
- `be-developer.toml` — Backend Developer
- `fe-developer.toml` — Frontend Developer
- `system-architect.toml` — System Architect
- `qas.toml` — Quality Assurance Specialist (read-only sandbox)
- `security-engineer.toml` — Security Engineer (read-only sandbox)
- `rte.toml` — Release Train Engineer
- `tdm.toml` — Technical Delivery Manager
- `tech-writer.toml` — Technical Writer
- `data-engineer.toml` — Data Engineer
- `data-provisioning-eng.toml` — Data Provisioning Engineer

## SAW-28: Shared Skills Library (5 pts)

Expanded `.agents/skills/` from 3 to 18 skills. Each skill has a `SKILL.md` with YAML frontmatter (`name`, `description`) and instructions.
These skills are shared across all IDE providers (Claude Code, Codex CLI, Cursor IDE).

New skills added (15):
- `api-patterns`, `agent-coordination`, `confluence-docs`, `deployment-sop`
- `frontend-patterns`, `git-advanced`, `linear-sop`, `migration-patterns`
- `orchestration-patterns`, `release-patterns`, `rls-patterns`, `safe-workflow`
- `security-audit`, `spec-creation`, `stripe-patterns`

## SAW-29: Codex Config Enrichment (3 pts)

Enriched `.codex/config.toml` (242 lines) with:
- `[mcp_servers]` — Linear + Confluence MCP server definitions
- `[agents]` — max_threads=6, multi_agent=true
- `[features]` — shell_snapshot, web_search, shell_tool, unified_exec
- Agent profiles: architect, developer, reviewer
- Notification and reasoning settings

## SAW-30: Dark Factory Codex Integration (3 pts)

- `dark-factory/docs/CODEX-DARK-FACTORY-GUIDE.md` — How to run Codex agents in tmux via codex-yolo
- `dark-factory/templates/codex-factory.sh` — tmux layout template for Codex agent teams

## SAW-31: Cursor MCP + Additional Rules (2 pts)

- `.cursor/mcp.json` — MCP server config for Linear + Confluence
- 3 new Cursor rules (16 total):
  - `14-spec-creation.mdc` — SAFe specification creation
  - `15-deployment.mdc` — Deployment procedures
  - `16-stripe-payments.mdc` — Stripe payment integration

## SAW-32: Branch Restructure + Release (3 pts)

- Renamed default branch from `template` to `main` per GitHub template-hosting standards
- Created `dev` as governed long-running integration branch
- Updated 6 files with hardcoded branch references (CI, scripts, docs, tests)
- Version bump to v2.9.0 (CITATION.cff, CITATION.bib, README.md, setup-template.sh)
- Fixed stale repo URLs in CITATION files

---

## Also Included (pre-SAW team, from proper PRs)

These changes were made via proper GitHub PRs before the SAW Linear team was created:

- **WOR-560** (PR #27): `/release` command for full version release workflow
- **WOR-561** (PR #29): `allowed-tools` frontmatter added to 9 remaining skills
- **WOR-563** (PR #31): Hardcoded harness author attribution in copyright/IP notices (42 files)
- **PR #30**: SAFe PI Planning template (markdown + xlsx formats)
- Conflict marker cleanup from merge resolution

---

## Breaking Changes

### Branch Rename: `template` → `main`

Existing forks using `harness/template` as a remote tracking branch must update:

```bash
git remote set-branches harness main
git fetch harness
# References change: harness/template → harness/main
```

See `docs/releases/v2.9.0-UPGRADE.md` for full migration instructions.
