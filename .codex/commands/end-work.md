# End Work Command

You are completing a work session. Execute final checklist before context switch or session end.

## Completion Checklist

### 1. Work Status

Verify current state:

```bash
git status
git log origin/{{MAIN_BRANCH}}..HEAD --oneline
```

Status options:
- **Work Complete**: Ready for PR
- **Work In Progress**: Safe stopping point, commit and document
- **Blocked**: Document blockers

### 2. Commit All Work

If uncommitted changes exist, suggest committing:

```bash
git add .
git commit -m "type(scope): description [{{TICKET_PREFIX}}-XXX]"
```

Verify all work committed:

```bash
git status
```

Should show clean working tree.

### 3. Documentation Status

Quick check:
- [ ] Inline comments for complex logic?
- [ ] README updated if new feature?
- [ ] CODEX.md/CONTRIBUTING.md updated if workflow changed?
- [ ] Linear ticket status current?

### 4. Update Linear Ticket

> **Note**: Tickets referenced in commit messages (e.g., `[{{TICKET_PREFIX}}-XXX]`) auto-sync to Done when the PR merges via the GitHub-Linear integration. Manually close any child stories not referenced in commits.

Based on work status:

**If Complete**:
- Update ticket status to "Ready for Review" or "In Progress"
- Add comment summarizing work done
- Link to PR if created

**If In Progress**:
- Update ticket with progress notes
- Document any blockers or questions
- Set status appropriately

**If Blocked**:
- Document blocker clearly
- Add comments to ticket
- Tag appropriate people

### 5. Context Preservation

If stopping mid-work, document:
- What was completed
- What's next
- Any decisions made
- Any blockers encountered
- Questions to discuss

### 6. Branch Status

Decide next action:

**If Ready for PR**:
- Push branch: `git push origin {branch-name}`
- Create PR (or remind to create)
- Reference `pre-pr.md` command

**If In Progress**:
- Push work: `git push origin {branch-name}` (if exists)
- Or: Keep local until next session

## Output Format

Provide summary:
- Work status (complete/in-progress/blocked)
- All changes committed
- Documentation current
- Linear ticket updated
- Context preserved (if needed)
- Ready for next session

Include any action items for user:
- PR creation needed?
- Blockers to resolve?
- Questions to answer?
- Follow-up tasks?

## Success Criteria

Session ends cleanly:
- No uncommitted work (if complete)
- or: Safe stopping point documented (if in-progress)
- Linear ticket reflects current status
- Next session can pick up smoothly

This ensures continuity and prevents context loss.
