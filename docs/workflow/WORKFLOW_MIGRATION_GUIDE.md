# Workflow Migration Guide: v1.0 → v1.1

**Date**: 2025-10-06
**Audience**: Development teams working on {{PROJECT_SHORT}}-app
**Purpose**: Help teams understand and adopt workflow v1.1 changes

---

## 🎯 TL;DR (Quick Summary)

**What Changed**:

- **Pre-Implementation Gate**: TDM now verifies CONTRIBUTING.md compliance BEFORE code changes
- **2 New PR Review Stages**: System Architect → ARCHitect-in-CLI → Scott (was: direct to Scott)
- **Structured Feedback Loop**: TDM coordinates fixes when reviews request changes

**Why It Matters**:

- Fewer issues reach Scott's review (save human time)
- Higher code quality through multi-stage review
- Clearer escalation path for issues

**When to Use**:

- All new PRs use v1.1 (starting with Free Tools feature)
- Existing open PRs can finish on v1.0

---

## 📋 What You Need to Know

### If You're Creating a New PR (Use v1.1)

**Before you had**:

````text
1. Get Linear issue
2. Create spec
3. Implement
4. Test
5. Create PR
6. Wait for Scott's review
```text

**Now you have** (v1.1):

```text
1. Get Linear issue
2. Create spec
3. **WAIT FOR TDM PRE-GATE** 👈 NEW
   - TDM verifies branch naming: {{TICKET_PREFIX}}-XXX-...
   - TDM verifies Linear is "In Progress"
   - TDM verifies CONTRIBUTING.md compliance
4. Implement (only after gate passes)
5. Test
6. Create PR
7. **System Architect reviews** 👈 NEW
8. **ARCHitect-in-CLI reviews** 👈 NEW
9. Scott reviews and merges (same as before)
```text

**Key Difference**: You can't start coding until TDM verifies everything is set up correctly.

---

### If You're Reviewing an Existing PR (v1.0 or v1.1)

**How to tell which version**:

Look at PR description or Linear ticket comments:

- **v1.0 PR**: No mention of System Architect or ARCHitect-in-CLI review
- **v1.1 PR**: Will have System Architect review comments + ARCHitect-in-CLI review

**If it's v1.0**: Use old review process (direct to Scott)
**If it's v1.1**: Follow new review chain (agent reviews first)

---

## 🚀 Adopting v1.1 (Step-by-Step)

### Step 1: Understand the Pre-Implementation Gate

**What TDM Checks Before You Start Coding**:

```bash
# 1. Branch naming correct?
git branch --show-current
# Must be: {{TICKET_PREFIX}}-{number}-{description}
# Example: {{TICKET_PREFIX}}-321-free-tools-bonus

# 2. Synced with latest dev?
git pull origin dev
# Must have no conflicts

# 3. Linear ticket "In Progress"?
# Check Linear board manually or via mcp__linear-mcp__get_issue

# 4. Ready for atomic commits?
git status
# Must be clean working tree
```text

**If ANY check fails**: TDM will block work and escalate to you. Fix the issue first.

**Example TDM Blocking Message**:

```text
BLOCKER: Pre-implementation gate failed
- Issue: Branch name is "feature/add-tools" (incorrect)
- Required: {{TICKET_PREFIX}}-XXX-free-tools-bonus
- Action: Rename branch and try again

Do NOT start implementation until gate passes.
```text

---

### Step 2: Work as Normal (Implementation)

Once pre-gate passes, work is the same as v1.0:

- Read spec created by BSA
- Implement using patterns
- Make atomic commits: `type(scope): description [{{TICKET_PREFIX}}-XXX]`
- Run `yarn ci:validate` before pushing

**No changes here** - just know you went through the gate first.

---

### Step 3: Understand the New PR Review Chain

**Old Flow (v1.0)**:

```sql
PR created → Scott reviews → {{AUTHOR_NAME}} merges
```text

**New Flow (v1.1)**:

```sql
PR created
  ↓
System Architect reviews (agent)
  ↓
  ├─ APPROVED? → ARCHitect-in-CLI reviews
  └─ CHANGES NEEDED? → TDM coordinates fixes → Loop back
  ↓
ARCHitect-in-CLI reviews (main Claude)
  ↓
  ├─ APPROVED? → Scott reviews
  └─ CHANGES NEEDED? → TDM coordinates fixes → Loop back
  ↓
Scott reviews & merges (same as before)
```text

**What This Means for You**:

- Expect PR comments from System Architect (agent)
- Expect PR comments from ARCHitect-in-CLI (main Claude)
- TDM will assign you fixes if needed
- Scott only reviews when agents approve

---

### Step 4: Responding to Agent Review Feedback

**If System Architect Requests Changes**:

1. TDM will create Linear comment: "System Architect found issues in PR #XXX"
2. TDM will assign you the fix work
3. Address feedback in your branch
4. Push changes
5. System Architect automatically re-reviews
6. Loop until approved

**If ARCHitect-in-CLI Requests Changes**:

Same process as above, but feedback from main Claude (me).

**Example Review Comment You Might See**:

```markdown
## System Architect Review - PR #XXX

### Issues Found:

1. **RLS Context Missing**: Line 45 in route.ts uses direct Prisma call
   - Required: Wrap in `withUserContext()`
   - Risk: Cross-user data access

2. **Missing Error Handling**: Line 67 doesn't catch promise rejection
   - Required: Add try/catch or .catch()
   - Risk: Unhandled errors crash app

### Action Required:

Please address these issues and push changes. I'll re-review automatically.

**Status**: CHANGES REQUESTED
```text

---

## 📖 Reference Guide

### When Should I Use v1.0 vs v1.1?

| Situation                                        | Version  | Notes                                     |
| ------------------------------------------------ | -------- | ----------------------------------------- |
| **New PR (created after 2025-10-06)**            | **v1.1** | All new work uses v1.1                    |
| **Existing open PR (created before 2025-10-06)** | **v1.0** | Finish on v1.0 to avoid disruption        |
| **Hotfix/Emergency**                             | **v1.0** | Skip agent reviews if critical            |
| **Database Migration**                           | **v1.1** | Use full review chain (security critical) |

---

### What Files Changed in v1.1?

| File                                      | Change      | Why You Care                              |
| ----------------------------------------- | ----------- | ----------------------------------------- |
| `docs/workflow/WORKFLOW_BASELINE_v1.0.md` | **NEW**     | Reference for old workflow                |
| `docs/workflow/WORKFLOW_CHANGES_v1.1.md`  | **NEW**     | See what changed and why                  |
| `docs/workflow/WORKFLOW_COMPARISON.md`    | **NEW**     | Side-by-side comparison                   |
| `docs/sop/AGENT_WORKFLOW_SOP.md`          | **UPDATED** | Now v1.1, read changelog                  |
| `.claude/agents/tdm.md`                   | **UPDATED** | TDM now does pre-gate + review escalation |
| `.claude/agents/system-architect.md`      | **UPDATED** | System Architect now does PR reviews      |

---

### How to Tell if Pre-Gate Passed?

**Look for this in Linear ticket comments**:

```markdown
## TDM Pre-Implementation Gate - PASSED ✅

Verified:

- [x] Branch: {{TICKET_PREFIX}}-321-free-tools-bonus
- [x] Linear status: In Progress
- [x] Git sync: Up-to-date with dev
- [x] CONTRIBUTING.md: Compliant

**Status**: Work approved to begin
**Developer**: BE Developer agent assigned
```text

**If you don't see this**: Work hasn't started yet (gate not passed).

---

### How to Tell if Agent Review Completed?

**Look for PR comments from**:

- `System Architect` (agent review #1)
- `ARCHitect-in-the-CLI` (agent review #2)

**Status indicators**:

- ✅ `APPROVED` - Escalated to next reviewer
- ⚠️ `CHANGES REQUESTED` - TDM will coordinate fixes

---

## 🔄 Transition Period (Next 2 Weeks)

### Week 1 (2025-10-06 to 2025-10-13)

**Goal**: Test v1.1 with Free Tools feature

- **1 PR using v1.1** (Free Tools)
- Collect feedback on agent reviews
- Measure cycle time impact
- Adjust if needed

**Existing PRs**: Finish on v1.0

### Week 2 (2025-10-13 to 2025-10-20)

**Goal**: Expand v1.1 to all new PRs

- All new PRs use v1.1
- Document lessons learned
- Update team based on feedback
- Decide: Continue v1.1, iterate to v1.2, or rollback to v1.0

**Existing PRs**: Still finish on v1.0

---

## ⚠️ Common Issues & Solutions

### Issue: "TDM blocked my work - what do I do?"

**Cause**: Pre-implementation gate failed

**Solution**:

1. Read TDM's blocking message (tells you what failed)
2. Fix the issue (rename branch, sync git, update Linear, etc.)
3. Notify TDM or restart workflow
4. TDM will re-check and approve if fixed

### Issue: "System Architect approved but I can't merge"

**Cause**: Still waiting for ARCHitect-in-CLI review

**Solution**:
Wait for ARCHitect-in-CLI review (should be fast, <20 min). If >1 hour, ping Scott.

### Issue: "I made fixes but review status didn't update"

**Cause**: Agent hasn't re-reviewed yet

**Solution**:
Wait ~5-10 minutes for automated re-review. If still stuck, ping TDM agent or Scott.

### Issue: "Scott merged my PR without agent reviews"

**Cause**: Likely hotfix or emergency (v1.0 used)

**Solution**:
This is fine - v1.0 still valid for critical fixes. Just note it in PR description.

---

## 📊 Metrics We're Tracking (FYI)

To determine if v1.1 is working:

1. **Issue Catch Rate**: % of issues caught by agents vs Scott
2. **Cycle Time**: Average PR creation → merge time
3. **Iteration Count**: How many fix loops per PR
4. **Scott's Time**: Hours spent reviewing per week

**Target**: <20% of issues reach Scott, cycle time <1 day for agent reviews

---

## 🆘 Who to Contact

| Question                       | Contact                         |
| ------------------------------ | ------------------------------- |
| **Pre-gate failed, need help** | TDM agent or Scott              |
| **Agent review unclear**       | ARCHitect-in-the-CLI or Scott   |
| **Workflow confusion**         | Read this guide, then ask Scott |
| **Emergency/hotfix**           | Scott (skip to v1.0)            |

---

## 📚 Additional Resources

**Full Documentation**:

- `docs/workflow/WORKFLOW_BASELINE_v1.0.md` - Current state before v1.1
- `docs/workflow/WORKFLOW_CHANGES_v1.1.md` - What we're adding and why
- `docs/workflow/WORKFLOW_COMPARISON.md` - Side-by-side v1.0 vs v1.1
- `docs/sop/AGENT_WORKFLOW_SOP.md` - Complete workflow SOP (v1.1)
- `CONTRIBUTING.md` - Git workflow (unchanged)

**Agent Docs**:

- `.claude/agents/tdm.md` - TDM delivery manager (updated for v1.4)
- `.claude/agents/system-architect.md` - System Architect reviewer (updated for v1.1)

---

## ✅ Quick Start Checklist

**For Your Next PR**:

- [ ] Read this migration guide
- [ ] Understand pre-implementation gate
- [ ] Get Linear issue assigned
- [ ] Let BSA create spec
- [ ] **WAIT for TDM pre-gate approval**
- [ ] Implement once gate passes
- [ ] Test and create PR
- [ ] **Expect System Architect review**
- [ ] **Expect ARCHitect-in-CLI review**
- [ ] Address any feedback via TDM
- [ ] Scott reviews and merges when agents approve

---

**Questions?** Ask Scott or check the full documentation linked above.

**Feedback?** We're iterating on v1.1 - your input matters!

---

**Migration Guide Created**: 2025-10-06
**Author**: ARCHitect-in-the-CLI (Claude Code)
**Version**: 1.0 (for v1.0 → v1.1 transition)
````
