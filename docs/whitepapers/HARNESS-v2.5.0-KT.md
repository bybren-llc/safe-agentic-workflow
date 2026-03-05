# KT: Harness v2.5.0 --- Skills 2.0 + Agent Teams

## Summary

v2.5.0 is the largest feature release since the harness was open-sourced. It modernizes all 18 skills with Claude Code Skills 2.0 frontmatter, introduces Agent Teams for real-time multi-agent orchestration, and adds comprehensive documentation for GitHub-Linear auto-sync behavior.

**PR**: [#22](https://github.com/{{GITHUB_ORG}}/{{PROJECT_REPO}}/pull/22) (27 files, +1,194 lines)
**Epic**: [WOR-540](https://linear.app/{{LINEAR_WORKSPACE}}/issue/WOR-540) (16 tickets, all completed)
**Release**: v2.5.0 (March 2026)

## Context

After 2+ months of enterprise adoption (v2.3.0 to v2.4.0), teams identified that the harness's 17 skills used only basic YAML frontmatter (`name` and `description`) despite Claude Code 2.1+ supporting rich invocation control. Additionally, Claude Code's experimental Agent Teams feature (February 2026) offered a path to real-time multi-agent coordination --- a natural fit for the harness's 11-agent SAFe model.

Research was conducted on Claude Code's changelog (v2.1.0 through v2.1.69), official Skills 2.0 documentation, and Agent Teams docs. A gap analysis confirmed that zero skills used any Skills 2.0 features, and Agent Teams was not integrated at all.

## Key Decisions Made

1. **Skills 2.0 frontmatter is additive**: No breaking changes. Old skills continue to work. New frontmatter fields enhance behavior without requiring changes from adopters.

2. **Skill categorization by invocation pattern**: Skills were classified into 4 categories based on how they should be triggered:
   - Background knowledge (5 skills): `user-invocable: false` --- Claude auto-loads, hidden from `/` menu
   - Dangerous operations (3 skills): `disable-model-invocation: true` --- only user can invoke
   - Isolated execution (3 skills): `context: fork` + `agent: Explore` --- runs in subagent
   - Tool-restricted (7 skills): `allowed-tools` --- limits available tools per skill

3. **Agent Teams is opt-in experimental**: Disabled by default. Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. Can be fully removed via OPTIONAL-FEATURES.md checklist.

4. **team-coordination skill is Claude Code-only**: Agent Teams is a Claude Code feature. The Gemini provider stays at 17 skills. The `.gemini/skills/README.md` documents this explicitly.

5. **TDM is the natural team lead**: In the 11-agent SAFe model, the Technical Delivery Manager (TDM) maps to the Agent Teams "team lead" role, with TaskCreate/SendMessage/TaskList for coordination.

6. **GitHub-Linear auto-sync is documentation-only**: No code changes were needed. The behavior already exists via the GitHub-Linear integration. We just documented the workflow clearly so agents stop making redundant API calls.

## Implementation Details

### What Changed

#### Skills 2.0 Modernization (17 files)

All existing SKILL.md files received frontmatter updates:

| Category | Skills | New Fields |
|---|---|---|
| Background knowledge | rls-patterns, safe-workflow, api-patterns, frontend-patterns, stripe-patterns | `user-invocable: false` |
| Dangerous operations | deployment-sop, migration-patterns, release-patterns | `disable-model-invocation: true`, `argument-hint` |
| Isolated execution | pattern-discovery, security-audit, spec-creation | `context: fork`, `agent: Explore`, `allowed-tools` |
| Tool-restricted | agent-coordination, confluence-docs, git-advanced, linear-sop, orchestration-patterns, testing-patterns | `allowed-tools` (minimum necessary set) |

#### New Skill: team-coordination

- **Path**: `.claude/skills/team-coordination/SKILL.md`
- **Frontmatter**: `disable-model-invocation: true`, `argument-hint: "[task-description]"`, `allowed-tools: Read, Bash, Grep, Glob, Task`
- **Content**: 5 SAFe team patterns, communication patterns, quality gate hooks, team sizing guidelines, known limitations
- **Status**: Experimental (Claude Code only)

#### Agent Teams Infrastructure

| File | Purpose |
|---|---|
| `.claude/team-config.json` | Added `agent_teams` section with gate dependencies DAG |
| `.claude/settings.template.json` | Template for enabling experimental flag |
| `.claude/agents/tdm.md` | Added "Agent Teams Orchestration" section |
| `docs/onboarding/AGENT-TEAMS-GUIDE.md` | Comprehensive onboarding (548 lines) |
| `docs/guides/OPTIONAL-FEATURES.md` | Added Section 5: Agent Teams removal checklist |
| `docs/guides/SKILL_AUTHORING_GUIDE.md` | Updated for Skills 2.0 (7 new sections) |

#### GitHub-Linear Auto-Sync Documentation

Added notes to 7 files across `.claude/agents/`, `.claude/commands/`, `.claude/skills/`, and `agent_providers/`:

- Tickets referenced in commit messages (e.g., `[WOR-123]`) auto-move to Done on PR merge
- Child stories not referenced in commits must be manually closed
- Best practice: reference Feature-level tickets in commits

### How It Works

**Skills 2.0 Invocation Flow**:

1. Claude loads all skill descriptions into context at session start
2. For `user-invocable: false` skills: Claude auto-activates when context matches, but skill is hidden from `/` slash menu
3. For `disable-model-invocation: true` skills: Only appears in `/` menu, Claude cannot auto-trigger
4. For `context: fork` skills: Runs in isolated subagent, output returns to main conversation

**Agent Teams SAFe Flow**:

1. TDM creates team via TeamCreate with appropriate teammates
2. Tasks created with `addBlockedBy` dependencies matching SAFe gates
3. Implementation then QAS validation then RTE PR creation then Review then HITL merge
4. TeammateIdle/TaskCompleted hooks enforce quality standards
5. TDM sends shutdown_request when work completes

## Gotchas and Lessons Learned

1. **Background agents can't catch cross-document inconsistencies**: 9 parallel agents all produced internally correct output, but used inconsistent terminology (e.g., invented tool names vs real API names). A dedicated code review pass caught 4 MEDIUM findings.

2. **GitHub-Linear auto-sync only works for directly referenced tickets**: Commit messages like `[WOR-541]` auto-close WOR-541, but child stories (WOR-544 through WOR-555) that aren't in any commit message stay in Backlog. Teams must manually close orphaned child stories.

3. **Agent Teams tool names differ from intuition**: The real tools are `TeamCreate`, `Task` (with `team_name`), `SendMessage` (with `type: "shutdown_request"`), `TaskCreate`, `TaskList` --- not the intuitive names like `spawnTeammate` or `shutdownTeammate`.

4. **`context: fork` means no conversation context**: Skills using `context: fork` run as isolated subagents. They don't see the main conversation. This is correct for research/audit skills but wrong for background knowledge skills that need conversation context.

5. **Gemini parity is intentional at 17 skills**: The `team-coordination` skill requires Claude Code Agent Teams, which is provider-specific. Gemini stays at 17 skills, and this is documented in `.gemini/skills/README.md`.

## Testing / Verification

```bash
# Verify skill counts
ls .claude/skills/ | grep -v README | wc -l   # Expected: 18
ls .gemini/skills/ | grep -v README | wc -l   # Expected: 17

# Verify Skills 2.0 frontmatter applied
for skill in .claude/skills/*/SKILL.md; do
  echo "=== $(basename $(dirname $skill)) ==="
  head -10 "$skill" | grep -E "^(user-invocable|disable-model|context|agent|allowed-tools|argument-hint):"
done

# Verify no stale "17 skills" references
grep -rn "17 model-invoked\|17 skills\|17 Model" . --include="*.md" --include="*.cff" | grep -v node_modules | grep -v .git

# Verify JSON validity
python3 -c "import json; json.load(open('.claude/team-config.json'))" && echo "team-config.json: Valid"
python3 -c "import json; json.load(open('.claude/settings.template.json'))" && echo "settings.template.json: Valid"

# Verify new files exist
test -f .claude/skills/team-coordination/SKILL.md && echo "team-coordination: EXISTS"
test -f docs/onboarding/AGENT-TEAMS-GUIDE.md && echo "Agent Teams Guide: EXISTS"
test -f docs/guides/OPTIONAL-FEATURES.md && echo "Optional Features: EXISTS"
test -f docs/releases/v2.5.0-UPGRADE.md && echo "Upgrade Guide: EXISTS"
```

## Related Tickets

| Ticket | Title | Status |
|---|---|---|
| WOR-540 | v2.5.0 Epic: Agent Teams + Skills 2.0 | Done |
| WOR-541 | Feature A: Skills 2.0 Modernization | Done |
| WOR-542 | Feature B: Agent Teams Integration | Done |
| WOR-543 | Feature C: Documentation Updates | Done |
| WOR-544-547 | Skills 2.0 Stories (4) | Done |
| WOR-548-552 | Agent Teams Stories (5) | Done |
| WOR-553-555 | Documentation Stories (3) | Done |
| WOR-556 | v2.5.0 KT: Root Docs + Upgrade Guide + Confluence | In Progress |

## Future Work

1. **Gemini Agent Teams**: When Google adds multi-agent orchestration to Gemini CLI, create a Gemini-specific team-coordination skill
2. **Production validation of Agent Teams**: The feature is experimental --- document real-world usage patterns as teams adopt
3. **Automated upgrade verification**: Add a `scripts/verify-harness.sh` that checks skill counts, frontmatter validity, and config JSON
4. **Skills 2.0 hooks in production**: The `hooks` frontmatter field is available but not yet used in any harness skill --- evaluate for security-audit and deployment-sop
5. **Cross-provider skill sync**: Extend `sync-claude-harness.sh` to also sync `.gemini/` and `agent_providers/`

---

*This KT document is part of the [{{PROJECT_SHORT}} SAFe Agentic Workflow](https://github.com/{{GITHUB_ORG}}/{{PROJECT_REPO}}) harness. For upgrade instructions, see [v2.5.0-UPGRADE.md](../releases/v2.5.0-UPGRADE.md).*
