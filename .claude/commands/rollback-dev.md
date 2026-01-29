---
description: Rollback {{DEV_MACHINE}} dev environment to previous Docker image
argument-hint: [commit-sha]
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
---

> **📋 TEMPLATE**: This command is a template. See "Customization Guide" below to adapt for your infrastructure.

Rollback the {{DEV_MACHINE}} dev environment to a previous Docker image version.

## Workflow

### 1. Assess Current Situation

Get current problematic version:

```bash
# {{TICKET_PREFIX}}-445: Updated container name per Terminology Contract
ssh -i {{SSH_KEY_PATH}} {{REMOTE_USER}}@{{REMOTE_HOST}} "docker inspect {{PROJECT}}-dev-app | grep 'org.opencontainers.image.revision' | cut -d'\"' -f4"
```

Check current status:

```bash
curl -s http://{{REMOTE_HOST}}:3000/api/health 2>/dev/null || echo "Health check failed"
```

Document the issue for Linear ticket creation later.

### 2. List Available Rollback Targets

Show recent images on {{DEV_MACHINE}}:

```bash
ssh -i {{SSH_KEY_PATH}} {{REMOTE_USER}}@{{REMOTE_HOST}} "docker images {{REGISTRY}}/{{PROJECT_NAME}}/dev --format 'table {{.Tag}}\t{{.ID}}\t{{.CreatedAt}}'"
```

Cross-reference with git commits to show messages:

```bash
git log origin/dev -10 --oneline
```

### 3. Select Rollback Target

**If argument provided** (commit SHA like `e9722d4`):

- Use specified commit as rollback target
- Verify image exists with that SHA tag

**If no argument provided**:

- Display last 5 available images with commit messages
- Recommend previous stable version (before current)
- Ask user to confirm selection

Default behavior: Select image before current (most common rollback scenario)

### 4. Pull Rollback Image

Pull the specific version from registry:

```bash
ssh -i {{SSH_KEY_PATH}} {{REMOTE_USER}}@{{REMOTE_HOST}} "docker pull {{REGISTRY}}/{{PROJECT_NAME}}/dev:dev-{target-sha}"
```

If image not in registry (old version pruned), use local cached image.

### 5. Update Configuration

Create backup of current config:

```bash
ssh -i {{SSH_KEY_PATH}} {{REMOTE_USER}}@{{REMOTE_HOST}} "cd {{PROJECT_PATH}} && cp docker-compose.dev.yml docker-compose.dev.yml.backup.$(date +%Y%m%d_%H%M%S)"
```

Update docker-compose.dev.yml to use specific image tag:

```bash
# From: image: {{REGISTRY}}/{{PROJECT_NAME}}/dev:latest
# To:   image: {{REGISTRY}}/{{PROJECT_NAME}}/dev:dev-{target-sha}
```

Use SSH + sed for inline replacement:

```bash
ssh -i {{SSH_KEY_PATH}} {{REMOTE_USER}}@{{REMOTE_HOST}} "cd {{PROJECT_PATH}} && sed -i 's|{{REGISTRY}}/{{PROJECT_NAME}}/dev:latest|{{REGISTRY}}/{{PROJECT_NAME}}/dev:dev-{target-sha}|g' docker-compose.dev.yml"
```

### 6. Restart Services

Restart with rollback image:

```bash
ssh -i {{SSH_KEY_PATH}} {{REMOTE_USER}}@{{REMOTE_HOST}} "cd {{PROJECT_PATH}} && ./scripts/dev-docker.sh restart"
```

Monitor startup:

```bash
ssh -i {{SSH_KEY_PATH}} {{REMOTE_USER}}@{{REMOTE_HOST}} "cd {{PROJECT_PATH}} && ./scripts/dev-docker.sh logs --tail 50"
```

### 7. Verify Rollback Success

Check services started:

```bash
ssh -i {{SSH_KEY_PATH}} {{REMOTE_USER}}@{{REMOTE_HOST}} "docker ps --filter name={{PROJECT}}"
```

Verify health endpoint:

```bash
curl -s http://{{REMOTE_HOST}}:3000/api/health | jq
```

Confirm correct commit SHA:

```bash
# {{TICKET_PREFIX}}-445: Updated container name per Terminology Contract
ssh -i {{SSH_KEY_PATH}} {{REMOTE_USER}}@{{REMOTE_HOST}} "docker inspect {{PROJECT}}-dev-app | grep 'org.opencontainers.image.revision' | cut -d'\"' -f4"
```

### 8. Post-Rollback Actions

**If rollback successful**:

- Keep rollback configuration in place
- Create Linear ticket documenting the issue with broken version
- Include error logs and health check failures
- Tag ticket with `bug` and `deployment-rollback` labels
- Notify team via Slack about rollback

**If rollback still has issues**:

- Try rolling back to an even older version
- Check if issue is environmental (database, Redis, etc.)
- Escalate to team for investigation

### 9. Rollback Report

Provide comprehensive rollback summary:

```
⏮️  {{DEV_MACHINE}} Dev Environment Rollback

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Problem Detected
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Version:  3a49b85 - feat(ci): add Slack notifications [{{TICKET_PREFIX}}-350]
Issue:    Health check failing / Services crashing
Time:     Deployed 5 minutes ago

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Rollback Target
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Selected: e9722d4 - style(docs): apply markdown linting fixes [{{TICKET_PREFIX}}-347]
Reason:   Last known stable version
Age:      7 hours ago

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Rollback Progress
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[14:30:00] Backup config... ✅ docker-compose.dev.yml.backup.20251011_143000
[14:30:05] Pull rollback image... ✅ dev-e9722d4 (45s)
[14:30:50] Update config... ✅ Set to dev-e9722d4
[14:30:55] Restart services... ✅ Complete (28s)
[14:31:23] Health check... ✅ Passed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Post-Rollback Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Running:  e9722d4 - style(docs): apply markdown linting fixes [{{TICKET_PREFIX}}-347]
Status:   ✅ Healthy
URL:      http://{{REMOTE_HOST}}:3000
Duration: 1m 23s

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Rollback Complete - Environment Restored
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next steps:
• Create Linear ticket for broken version (3a49b85)
• Include error logs and symptoms
• Investigate root cause before redeploying
• Keep this version until fix is verified

To return to latest (when fixed):
  /remote-deploy
```

### 10. Restore to Latest (When Fixed)

When issue is resolved and new build is ready, restore to latest:

```bash
# Restore docker-compose.dev.yml to use :latest tag
ssh -i {{SSH_KEY_PATH}} {{REMOTE_USER}}@{{REMOTE_HOST}} "cd {{PROJECT_PATH}} && sed -i 's|{{REGISTRY}}/{{PROJECT_NAME}}/dev:dev-[a-f0-9]*|{{REGISTRY}}/{{PROJECT_NAME}}/dev:latest|g' docker-compose.dev.yml"

# Then deploy normally
/remote-deploy
```

## Error Handling

### Image Not Available

If rollback target image not found:

- Try older version
- Pull from registry manually
- Check available tags: `docker images | grep {{PROJECT_NAME}}`

### Services Still Failing

If rollback doesn't fix issue:

- Problem may be environmental (database, Redis, config)
- Check database status
- Verify environment variables unchanged
- Try even older version

### Configuration Restore Fails

If config update fails:

- Manually restore from backup
- Verify SSH permissions
- Check disk space

## Success Criteria

- ✅ Rollback target selected
- ✅ Config backed up
- ✅ Rollback image pulled/available
- ✅ Config updated to specific version
- ✅ Services restarted successfully
- ✅ Health check passes
- ✅ Correct commit SHA running
- ✅ Error logs clean
- ✅ Linear ticket created for issue

## Prevention

Document issue in Linear to prevent recurrence:

- What broke
- How it was detected
- What version caused it
- How to test for this issue before deployment
- Consider adding pre-deployment checks

## Customization Guide

To adapt this command for your infrastructure, replace these placeholders:

| Placeholder       | Description                 | Example                              |
| ----------------- | --------------------------- | ------------------------------------ |
| `{{TICKET_PREFIX}}` | Your Linear ticket prefix   | `WOR`, `PROJ`, `TASK`                |
| `{{SSH_KEY_PATH}}`  | Path to SSH private key     | `~/.ssh/id_ed25519_staging`          |
| `{{REMOTE_USER}}`   | Username on remote host     | `deploy`, `{{AUTHOR_HANDLE}}`               |
| `{{REMOTE_HOST}}`   | Remote host name/IP         | `pop-os`, `staging.example.com`      |
| `{{PROJECT_PATH}}`  | Project directory on remote | `~/Projects/{{PROJECT_NAME}}`, `~/app` |
| `{{REGISTRY}}`      | Container registry URL      | `{{CONTAINER_REGISTRY}}`                 |
| `{{PROJECT_NAME}}`  | Project name in registry    | `myapp`, `webapp`                    |
| `{{PROJECT}}`       | Short project identifier    | `myapp`, `webapp`                    |
| `{{DEV_MACHINE}}`   | Remote dev machine name     | `Pop OS`, `staging`, `dev-server`    |
