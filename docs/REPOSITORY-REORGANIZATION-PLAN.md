> **📚 EXAMPLE**: This document is preserved as a learning example from the {{PROJECT_SHORT}} project. It demonstrates the pattern for planning a comprehensive repository reorganization with detailed implementation steps. When adopting this workflow, create your own version tailored to your project.

---

# Repository Reorganization Plan

## Cleaning Up Root Directory Clutter

**Date**: 2025-10-08  
**Issue**: Root directory has 14 documentation files (should have ~6)  
**Goal**: Organize documentation into logical subdirectories while maintaining "clone and use" readiness

---

## 📊 Current State Audit

### Root Directory Files (14 total)

| File                             | Size      | Purpose               | Status                                    |
| -------------------------------- | --------- | --------------------- | ----------------------------------------- |
| `README.md`                      | Primary   | Repository overview   | ✅ Keep in root                           |
| `LICENSE`                        | Primary   | MIT License           | ✅ Keep in root                           |
| `CODE_OF_CONDUCT.md`             | Primary   | Community guidelines  | ✅ Keep in root                           |
| `CITATION.bib`                   | Primary   | BibTeX citation       | ✅ Keep in root                           |
| `CITATION.cff`                   | Primary   | Citation File Format  | ✅ Keep in root                           |
| `.env.template`                  | Config    | Environment variables | ✅ Keep in root                           |
| `CONTRIBUTING.md`                | Primary   | Contributor guide     | ✅ Keep in root                           |
| `AGENTS.md`                      | Reference | Agent quick reference | ✅ Keep in root (AI assistant convention) |
| `CLAUDE.md`                      | Reference | Claude Code guidance  | ✅ Keep in root (AI assistant convention) |
| `DATA_DICTIONARY.md`             | Database  | Schema template       | 🔄 Move to /docs/database/                |
| `RLS_IMPLEMENTATION_GUIDE.md`    | Database  | RLS patterns          | 🔄 Move to /docs/database/                |
| `RLS_POLICY_CATALOG.md`          | Database  | RLS policy template   | 🔄 Move to /docs/database/                |
| `RLS_DATABASE_MIGRATION_SOP.md`  | Database  | Migration SOP         | 🔄 Move to /docs/database/                |
| `SECURITY_FIRST_ARCHITECTURE.md` | Security  | Security patterns     | 🔄 Move to /docs/security/                |
| `CI-CD-Pipeline-Guide.md`        | DevOps    | CI/CD standards       | 🔄 Move to /docs/ci-cd/                   |
| `README-TEMPLATE.md`             | Template  | README template       | 🗄️ Archive to /docs/archive/              |
| `apply-workflow.sh`              | Script    | Workflow script       | 🔄 Move to /scripts/                      |

**Summary**:

- **Keep in Root**: 9 files (README, LICENSE, CODE_OF_CONDUCT, CITATION.\*, .env.template, CONTRIBUTING, AGENTS, CLAUDE)
- **Move to /docs**: 6 files (organized by category)
- **Archive**: 1 file (README-TEMPLATE.md)
- **Move to /scripts**: 1 file (apply-workflow.sh)

---

## 🎯 Proposed Directory Structure

```
/
├── README.md                    ✅ Keep (primary entry point)
├── LICENSE                      ✅ Keep (required for OSS)
├── CODE_OF_CONDUCT.md          ✅ Keep (community standard)
├── CONTRIBUTING.md             ✅ Keep (contributor guide)
├── CITATION.bib                ✅ Keep (academic citation)
├── CITATION.cff                ✅ Keep (citation format)
├── .env.template               ✅ Keep (setup requirement)
├── AGENTS.md                   ✅ Keep (AI assistant convention)
├── CLAUDE.md                   ✅ Keep (AI assistant convention)
│
├── docs/
│   │
│   ├── database/               📁 NEW - Database documentation
│   │   ├── README.md           (Index of database docs)
│   │   ├── DATA_DICTIONARY.md  (Moved from root)
│   │   ├── RLS_IMPLEMENTATION_GUIDE.md (Moved from root)
│   │   ├── RLS_POLICY_CATALOG.md (Moved from root)
│   │   └── RLS_DATABASE_MIGRATION_SOP.md (Moved from root)
│   │
│   ├── security/               📁 NEW - Security documentation
│   │   ├── README.md           (Index of security docs)
│   │   └── SECURITY_FIRST_ARCHITECTURE.md (Moved from root)
│   │
│   ├── ci-cd/                  📁 NEW - CI/CD documentation
│   │   ├── README.md           (Index of CI/CD docs)
│   │   └── CI-CD-Pipeline-Guide.md (Moved from root)
│   │
│   ├── onboarding/             ✅ KEEP AS IS (recently created for {{TICKET_PREFIX}}-326)
│   │   ├── AGENT-SETUP-GUIDE.md
│   │   ├── DAY-1-CHECKLIST.md
│   │   ├── META-PROMPTS-FOR-USERS.md
│   │   ├── USER-JOURNEY-VALIDATION-REPORT.md
│   │   └── {{TICKET_PREFIX}}-326-COMPLETION-SUMMARY.md
│   │
│   ├── sop/                    ✅ KEEP AS IS (existing SOPs)
│   ├── team/                   ✅ KEEP AS IS (team docs)
│   ├── workflow/               ✅ KEEP AS IS (workflow docs)
│   │
│   └── archive/                📁 NEW - Archived/deprecated docs
│       └── README-TEMPLATE.md  (Moved from root)
│
└── scripts/
    ├── install-prompts.sh      ✅ KEEP (recently created)
    └── apply-workflow.sh       (Moved from root)
```

---

## 📋 Detailed Move Plan

### Phase 1: Create New Directories

```bash
mkdir -p docs/database
mkdir -p docs/security
mkdir -p docs/ci-cd
mkdir -p docs/archive
```

### Phase 2: Move Files

| Current Location                  | New Location                                    | Rationale                  |
| --------------------------------- | ----------------------------------------------- | -------------------------- |
| `/DATA_DICTIONARY.md`             | `/docs/database/DATA_DICTIONARY.md`             | Database schema reference  |
| `/RLS_IMPLEMENTATION_GUIDE.md`    | `/docs/database/RLS_IMPLEMENTATION_GUIDE.md`    | Database security patterns |
| `/RLS_POLICY_CATALOG.md`          | `/docs/database/RLS_POLICY_CATALOG.md`          | Database security catalog  |
| `/RLS_DATABASE_MIGRATION_SOP.md`  | `/docs/database/RLS_DATABASE_MIGRATION_SOP.md`  | Database operations SOP    |
| `/SECURITY_FIRST_ARCHITECTURE.md` | `/docs/security/SECURITY_FIRST_ARCHITECTURE.md` | Security architecture      |
| `/CI-CD-Pipeline-Guide.md`        | `/docs/ci-cd/CI-CD-Pipeline-Guide.md`           | DevOps documentation       |
| `/README-TEMPLATE.md`             | `/docs/archive/README-TEMPLATE.md`              | Archived template          |
| `/apply-workflow.sh`              | `/scripts/apply-workflow.sh`                    | Script organization        |

### Phase 3: Create README.md Files for New Directories

Each new directory needs a README.md index:

1. **docs/database/README.md** - Index of database documentation
2. **docs/security/README.md** - Index of security documentation
3. **docs/ci-cd/README.md** - Index of CI/CD documentation
4. **docs/archive/README.md** - Explanation of archived files

---

## 🔗 Reference Update Plan

### Files That Reference Moved Documents

#### High Priority (README.md and Onboarding)

**README.md**:

- Line 97: `[AGENTS.md](AGENTS.md)` - No change (stays in root)

**docs/onboarding/AGENT-SETUP-GUIDE.md**:

- References to `AGENTS.md` - No change (stays in root)
- References to `CONTRIBUTING.md` - No change (stays in root)

**docs/onboarding/META-PROMPTS-FOR-USERS.md**:

- References to `AGENTS.md` - No change (stays in root)
- References to `CONTRIBUTING.md` - No change (stays in root)
- References to `CI-CD-Pipeline-Guide.md` → `docs/ci-cd/CI-CD-Pipeline-Guide.md`

**docs/onboarding/DAY-1-CHECKLIST.md**:

- References to `AGENTS.md` - No change (stays in root)

**docs/onboarding/{{TICKET_PREFIX}}-326-COMPLETION-SUMMARY.md**:

- References to `CONTRIBUTING.md` (stays in root - no change)
- References to `DATA_DICTIONARY.md` → `docs/database/DATA_DICTIONARY.md`
- References to `SECURITY_FIRST_ARCHITECTURE.md` → `docs/security/SECURITY_FIRST_ARCHITECTURE.md`
- References to `RLS_IMPLEMENTATION_GUIDE.md` → `docs/database/RLS_IMPLEMENTATION_GUIDE.md`
- References to `CI-CD-Pipeline-Guide.md` → `docs/ci-cd/CI-CD-Pipeline-Guide.md`
- References to `RLS_DATABASE_MIGRATION_SOP.md` → `docs/database/RLS_DATABASE_MIGRATION_SOP.md`
- References to `RLS_POLICY_CATALOG.md` → `docs/database/RLS_POLICY_CATALOG.md`

#### Medium Priority (Agent Prompts)

**Agent prompts in `.claude/agents/` and `agent_providers/claude_code/prompts/`**:

- `bsa.md`: References to `DATA_DICTIONARY.md`, `SECURITY_FIRST_ARCHITECTURE.md`
- `system-architect.md`: References to `SECURITY_FIRST_ARCHITECTURE.md`
- `data-engineer.md`: References to `DATA_DICTIONARY.md`, `RLS_IMPLEMENTATION_GUIDE.md`
- `security-engineer.md`: References to `RLS_POLICY_CATALOG.md`, `SECURITY_FIRST_ARCHITECTURE.md`

**Count**: ~11 agent files × ~2-3 references each = ~25 references to update

#### Low Priority (Whitepaper and Other Docs)

**whitepaper/section-3-background-related-work.md**:

- Lines 427-429: References to `DATA_DICTIONARY.md`, `RLS_IMPLEMENTATION_GUIDE.md`, `SECURITY_FIRST_ARCHITECTURE.md`

**whitepaper/data/REPOSITORY_ARTIFACT_VALIDATION.md**:

- Lines 64-68: References to `DATA_DICTIONARY.md`, `SECURITY_FIRST_ARCHITECTURE.md`, `RLS_IMPLEMENTATION_GUIDE.md`, `CI-CD-Pipeline-Guide.md`

**whitepaper/README.md**:

- Line 241: Reference to `RLS_IMPLEMENTATION_GUIDE.md`

**agent_providers/augment/AUGMENT_WORKFLOW_GUIDE.md**:

- Line 70: Reference to `AGENTS.md` - No change (stays in root)

---

## 📝 .gitignore Additions

Add these patterns to prevent future clutter:

```gitignore
# Working documents and drafts
*.draft.md
working-*.md
temp-*.md
scratch-*.md

# Archive directory (optional - may want to track archived docs)
# docs/archive/*

# Personal notes
notes/
.notes/
personal-*.md

# IDE-specific documentation
.vscode/*.md
.idea/*.md

# Temporary documentation exports
docs-export/
*.docx
*.pdf.tmp
```

---

## ✅ Verification Checklist

After reorganization, verify:

### 1. No Broken Links

- [ ] Run link checker on README.md
- [ ] Run link checker on all docs/onboarding/\*.md files
- [ ] Run link checker on all agent prompts
- [ ] Run link checker on whitepaper/\*.md files

### 2. Agent Prompts Still Work

- [ ] Test BSA agent invocation
- [ ] Test System Architect agent invocation
- [ ] Test Data Engineer agent invocation
- [ ] Test Security Engineer agent invocation
- [ ] Verify all agents can find referenced documentation

### 3. User Journey Still Works

- [ ] Follow README Quick Start for Agents
- [ ] Follow docs/onboarding/AGENT-SETUP-GUIDE.md
- [ ] Follow docs/onboarding/DAY-1-CHECKLIST.md
- [ ] Verify all links in onboarding docs work

### 4. Repository Structure

- [ ] Root directory has ≤ 9 files (excluding hidden files)
- [ ] AGENTS.md and CLAUDE.md remain in root
- [ ] All other docs organized in /docs subdirectories
- [ ] Each new /docs subdirectory has README.md index
- [ ] No orphaned files or broken directory structure

### 5. Git History

- [ ] Use `git mv` for all moves (preserves history)
- [ ] Single commit for reorganization
- [ ] Clear commit message explaining changes

---

## 🚀 Implementation Commands

```bash
# Phase 1: Create directories
mkdir -p docs/database docs/security docs/ci-cd docs/archive

# Phase 2: Move files (use git mv to preserve history)
git mv DATA_DICTIONARY.md docs/database/
git mv RLS_IMPLEMENTATION_GUIDE.md docs/database/
git mv RLS_POLICY_CATALOG.md docs/database/
git mv RLS_DATABASE_MIGRATION_SOP.md docs/database/
git mv SECURITY_FIRST_ARCHITECTURE.md docs/security/
git mv CI-CD-Pipeline-Guide.md docs/ci-cd/
git mv README-TEMPLATE.md docs/archive/
git mv apply-workflow.sh scripts/

# Phase 3: Create README.md files for new directories
# (Create these files with appropriate content)

# Phase 4: Update all references
# (Use find-and-replace or sed commands)

# Phase 5: Commit
git add -A
git commit -m "docs: reorganize root directory documentation [{{TICKET_PREFIX}}-XXX]

Move documentation files from root to organized subdirectories:
- Database docs → docs/database/
- Security docs → docs/security/
- CI/CD docs → docs/ci-cd/
- Archived docs → docs/archive/
- Scripts → scripts/

Keep AGENTS.md and CLAUDE.md in root (AI assistant convention).

Update all references in:
- docs/onboarding/*.md
- Agent prompts (.claude/agents/, agent_providers/)
- Whitepaper sections

Root directory now has 9 essential files (was 17).
All documentation organized by category with README.md indexes."
```

---

## 📊 Impact Analysis

### Before Reorganization

- **Root files**: 17 (14 .md files + 3 other)
- **User confusion**: High (which file do I read first?)
- **Discoverability**: Low (no organization)
- **Maintainability**: Low (hard to find related docs)

### After Reorganization

- **Root files**: 9 (essential files + AI assistant conventions)
- **User confusion**: Low (clear entry points)
- **Discoverability**: High (organized by category)
- **Maintainability**: High (related docs together)

### Benefits

1. **Cleaner Root**: Only essential files visible
2. **Better Organization**: Docs grouped by purpose
3. **Easier Navigation**: README.md indexes in each category
4. **Preserved History**: Using `git mv` maintains file history
5. **No Broken Links**: Systematic reference updates
6. **Better Onboarding**: Clear path from README → category → specific doc

---

## ⚠️ Risks & Mitigation

### Risk 1: Broken Links

**Mitigation**: Comprehensive reference update plan + verification checklist

### Risk 2: Agent Prompts Break

**Mitigation**: Test all agent invocations after reorganization

### Risk 3: User Confusion

**Mitigation**: Update README.md with clear navigation, add README.md to each new directory

### Risk 4: External Links Break

**Mitigation**: GitHub automatically redirects old file paths for a period

---

## 🎯 Success Criteria

1. ✅ Root directory has ≤ 9 files (AGENTS.md and CLAUDE.md remain in root)
2. ✅ All other documentation organized in /docs subdirectories
3. ✅ No broken links in README.md or onboarding docs
4. ✅ All agent prompts still functional
5. ✅ User journey validation still passes
6. ✅ Git history preserved for all moved files
7. ✅ Each new directory has README.md index

---

**Status**: PLAN READY - Awaiting approval to implement

**Estimated Time**: 2-3 hours (move files + update references + test)

**Recommended Ticket**: Create new Linear ticket (e.g., {{TICKET_PREFIX}}-327) for this reorganization work
