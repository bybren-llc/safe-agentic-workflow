# Dark Factory Templates

Configuration templates for tmux sessions and merge queue enforcement. Copy and
customize these for your environment.

## Files

### `tmux.conf`

tmux configuration optimized for AI agent sessions:
- 50,000 line scrollback buffer
- Mouse support enabled (for Cursor SSH terminal)
- Pane border titles showing agent role names
- Alt+Arrow pane switching (no prefix needed)
- Prefix+L to tail all session logs in a popup
- Activity monitoring enabled
- Base index starts at 1

### `env.template`

Environment configuration copied to `~/.dark-factory/env` during setup. Contains:
- Project settings (`FACTORY_PROJECT_DIR`, `FACTORY_MAIN_BRANCH`, `FACTORY_TICKET_PREFIX`)
- Remote access settings (`FACTORY_SSH_KEY`, `FACTORY_REMOTE_HOST`, `FACTORY_REMOTE_USER`)
- Feature flags (`FACTORY_USE_WORKTREES`, `FACTORY_AUTO_PERMISSIONS`)
- Claude Code settings (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`)
- Merge policy settings (do not change -- enforced by setup script)

### `team-layouts/`

tmux pane layout scripts sourced by `factory-start.sh`. Each creates a specific
arrangement of panes and starts Claude Code in each one.

| Layout | Panes | Agents | Use Case |
|--------|-------|--------|----------|
| `story-team.sh` | 3 | TDM + BE + QAS | Small stories, bug fixes |
| `feature-team.sh` | 5 | TDM + BE + FE + QAS + RTE | Feature development |
| `epic-team.sh` | 9 | TDM + BSA + ARCH + Security + BE + FE + Data + QAS + RTE | Full SAFe team for epics |

### `github/merge-queue-ruleset.json`

GitHub branch ruleset template for merge queue enforcement. Import via
Settings > Rules > Rulesets in your GitHub repository.

Enforces:
- Squash-only merge method
- Merge queue required (ALLGREEN grouping)
- Required status checks (customize for your CI)
- No bypass actors
- `strict_required_status_checks_policy: false` (queue handles serialization)

See [MERGE-QUEUE-POLICY.md](../docs/MERGE-QUEUE-POLICY.md) for full documentation.
