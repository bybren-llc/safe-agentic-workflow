# Claude Code Harness Troubleshooting

## Common Issues and Solutions

---

## Layer 1: Skills Issues

### Skills Not Triggering

**Symptom**: Claude doesn't use skill knowledge when it should.

**Causes and Fixes**:

1. **Description field too vague**

   Check the skill's YAML frontmatter:

   ```yaml
   ---
   name: my-skill
   description: Use when [specific context]. Provides [specific guidance].
   ---
   ```

   The `description` field must clearly state **when** to trigger.

2. **Skill file not in correct location**

   Skills must be in `.claude/skills/{skill-name}/SKILL.md`:

   ```text
   ✅ .claude/skills/rls-patterns/SKILL.md
   ❌ .claude/skills/rls-patterns.md
   ❌ .claude/rls-patterns/SKILL.md
   ```

3. **YAML frontmatter malformed**

   Must have exactly this format at top of file:

   ```yaml
   ---
   name: skill-name
   description: Clear description of when to use this skill.
   ---
   ```

   No extra fields, no missing dashes, no trailing spaces.

**Verification**:

Ask Claude: "What skills are available?"

Claude should list all skills with their descriptions.

### Known Issue: /skills Command Bug (v2.0.73)

**Symptom**: `/skills` command shows empty or error.

**Workaround**: Ask Claude directly instead of using the command:

```
What skills do you have access to?
```

**Status**: Tracked in [GitHub Issue #14733](https://github.com/anthropics/claude-code/issues/14733)

---

## Layer 2: Commands Issues

### Command Not Found

**Symptom**: `/my-command` doesn't work.

**Causes and Fixes**:

1. **File not in correct location**

   Commands must be in `.claude/commands/{command-name}.md`:

   ```text
   ✅ .claude/commands/start-work.md
   ❌ .claude/commands/start-work/command.md
   ```

2. **File extension wrong**

   Must be `.md` (markdown):

   ```text
   ✅ start-work.md
   ❌ start-work.txt
   ❌ start-work.yaml
   ```

3. **Command name mismatch**

   Filename (without `.md`) becomes the command name:
   - `start-work.md` → `/start-work`
   - `pre-pr.md` → `/pre-pr`

**Verification**:

```bash
ls -la .claude/commands/
```

Should show all `.md` files.

### Command Runs But Does Wrong Thing

**Symptom**: Command executes but doesn't behave as expected.

**Causes and Fixes**:

1. **Outdated command content**

   Check if command references stale paths or tools:

   ```bash
   cat .claude/commands/my-command.md
   ```

2. **Missing environment context**

   Some commands assume specific environment (Docker, database, etc.).
   Check command prerequisites in the command file.

3. **Ticket prefix mismatch**

   If command references `{{TICKET_PREFIX}}-XXX` but your project uses different prefix,
   update the command file.

---

## Layer 3: Hooks Issues

### Hooks Not Firing

**Symptom**: Expected reminder/blocker doesn't appear.

**Causes and Fixes**:

1. **Hook not in settings file**

   Check `.claude/settings.local.json` or global settings:

   ```bash
   cat .claude/settings.local.json | jq '.hooks'
   ```

2. **Matcher regex doesn't match**

   Hook matchers use regex. Test your matcher:

   ```javascript
   // Example: Bash.*git\s+commit
   // Matches: Bash tool with "git commit" or "git  commit"
   ```

3. **Hook command fails silently**

   Test hook command manually:

   ```bash
   # Copy command from hooks config and run it
   git branch --show-current 2>/dev/null | grep -q '^{{TICKET_PREFIX}}-[0-9]'
   echo $?  # 0 = matched, 1 = no match
   ```

**Verification**:

Run a git commit and watch for reminder messages. If no messages appear,
check hooks configuration.

### Hook Blocks When It Shouldn't

**Symptom**: Hook blocks action incorrectly.

**Causes and Fixes**:

1. **Matcher too broad**

   If matcher is `.*`, it matches everything. Make it specific:

   ```json
   "matcher": "Bash.*git\\s+push"  // Only matches git push
   ```

2. **Exit code wrong**

   Blockers use `exit 1`. If your hook exits 1 unintentionally, it blocks:

   ```bash
   # This blocks if grep fails (exit 1)
   grep -q 'pattern' file.txt

   # This doesn't block
   grep -q 'pattern' file.txt || true
   ```

### Hook Runs Multiple Times

**Symptom**: Same reminder appears multiple times.

**Cause**: Multiple hooks with overlapping matchers.

**Fix**: Review all hooks and consolidate overlapping matchers.

---

## Agent Profile Issues

### Wrong Agent Selected

**Symptom**: Claude uses wrong agent for the task.

**Causes and Fixes**:

1. **Agent description unclear**

   Check agent profile has clear "When to Use" section.

2. **Task ambiguous**

   Be specific when invoking agents:

   ```
   ❌ "Help with the database"
   ✅ "Create a migration to add user_roles table (Data Engineer)"
   ```

3. **Multiple agents could apply**

   Reference the agent matrix in `AGENTS.md` for correct selection.

### Agent Missing Tools

**Symptom**: Agent says it can't do something it should be able to do.

**Cause**: Agent profile may restrict tools.

**Fix**: Check agent profile for `Primary Tools` section. Some agents
intentionally have restricted tool access for safety (e.g., TDM has no Bash).

---

## Environment Issues

### Docker Not Running

**Symptom**: Commands fail with Docker errors.

**Fix**:

```bash
# Check Docker status
docker ps

# Start Docker containers
./scripts/dev-docker.sh start
# or
docker-compose up -d
```

### Database Connection Failed

**Symptom**: Prisma commands fail.

**Fix**:

```bash
# Check database is running
docker ps | grep postgres

# Test connection
npx prisma db pull

# If fails, check DATABASE_URL in .env
```

### Linear MCP Not Connected

**Symptom**: Linear commands fail.

**Fix**:

```bash
# Check MCP connection
claude mcp:status

# Reconnect Linear MCP
claude mcp:connect linear
```

---

## Validation Commands

Use these to verify harness health:

```bash
# Check all command files exist
ls -la .claude/commands/*.md | wc -l
# Expected: 24

# Check all skill directories exist
ls -d .claude/skills/*/SKILL.md | wc -l
# Expected: 17

# Check hooks config is valid JSON
cat .claude/settings.local.json | jq . > /dev/null && echo "Valid JSON"

# Check agent profiles exist
ls -la .claude/agents/*.md | wc -l
# Expected: 11
```

---

## Debug Mode

For detailed debugging, ask Claude:

```
Can you show me the current harness configuration?
- List available skills
- List available commands
- Show hooks configuration
```

---

## Getting Help

1. **Check this document first**
2. **Read the Whitepaper** - `docs/whitepapers/CLAUDE-CODE-HARNESS-MODERNIZATION-{{TICKET_PREFIX}}-444.md`
3. **Check AGENTS.md** - For agent selection guidance
4. **Check CONTRIBUTING.md** - For workflow issues

---

**Version**: 1.0
**Last Updated**: 2025-12-20
