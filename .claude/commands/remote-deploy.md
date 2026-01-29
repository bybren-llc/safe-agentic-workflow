---
description: Deploy latest Docker image to remote staging environment
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
---

# Remote Deploy Command

Deploy the latest Docker image to your remote staging environment.

> **📋 TEMPLATE**: This command is a template. See "Customization Guide" below to adapt for your infrastructure.

## Quick Deploy Command

Execute single deploy command on remote host:

```bash
# ┌─────────────────────────────────────────────────────────────────────┐
# │ CUSTOMIZE: Replace with your SSH connection details                  │
# │ - SSH_KEY_PATH: Path to your SSH private key                        │
# │ - REMOTE_USER: Your username on the remote host                     │
# │ - REMOTE_HOST: Hostname or IP of your staging server                │
# │ - PROJECT_PATH: Path to your project on the remote host             │
# │ - DEPLOY_SCRIPT: Your deployment script path                        │
# └─────────────────────────────────────────────────────────────────────┘
ssh -i {{SSH_KEY_PATH}} {{REMOTE_USER}}@{{REMOTE_HOST}} "cd {{PROJECT_PATH}} && {{DEPLOY_SCRIPT}}"

# Example with real values:
# ssh -i ~/.ssh/id_ed25519_staging user@staging.example.com "cd ~/app && ./scripts/deploy.sh"
```

This command should handle:

1. Pull latest image from container registry
2. Start staging compose (no source mounts)
3. Wait for health check
4. Report status with container revision

Expected output on success:

```text
Deploying to staging environment...
Pulling latest image...
Starting staging services...
Waiting for health check...
Deploy complete!
Status: Up 5 seconds (health: starting)
Revision: abc1234
URL: http://localhost:{{STAGING_PORT}}
```

Expected duration: 2-5 minutes

## Success Criteria

- Container running (healthy)
- Health endpoint returns 200
- Image revision matches latest commit

## Error Handling

### Pull Failed

Possible causes:

- Registry auth expired - run `docker login {{REGISTRY}}`
- Disk space full - run `df -h` on remote host

### Health Check Failed

The deploy script should show recent logs. Common actions:

- Check logs for startup errors
- Verify database connection
- Run `/remote-rollback` to restore previous working state

## Verify Deployment

After deployment, verify with:

```bash
# ┌─────────────────────────────────────────────────────────────────────┐
# │ CUSTOMIZE: Replace with your health check endpoint and port         │
# └─────────────────────────────────────────────────────────────────────┘

# Health check
curl -s http://{{REMOTE_HOST}}:{{STAGING_PORT}}/api/health | jq

# Container status
ssh -i {{SSH_KEY_PATH}} {{REMOTE_USER}}@{{REMOTE_HOST}} "docker ps --filter name={{CONTAINER_NAME}}"
```

## Customization Guide

To adapt this command for your infrastructure, replace these placeholders:

| Placeholder        | Description                   | Example                     |
| ------------------ | ----------------------------- | --------------------------- |
| `{{SSH_KEY_PATH}}`   | Path to SSH private key       | `~/.ssh/id_ed25519_staging` |
| `{{REMOTE_USER}}`    | Username on remote host       | `deploy`                    |
| `{{REMOTE_HOST}}`    | Staging server hostname/IP    | `staging.example.com`       |
| `{{PROJECT_PATH}}`   | Project directory on remote   | `~/app`                     |
| `{{DEPLOY_SCRIPT}}`  | Your deployment script        | `./scripts/deploy.sh`       |
| `{{STAGING_PORT}}`   | Port your staging app runs on | `3001`                      |
| `{{CONTAINER_NAME}}` | Docker container name         | `myapp-staging`             |
| `{{REGISTRY}}`       | Container registry URL        | `ghcr.io/myorg/myapp`       |

## Related Commands

- `/remote-health` - Full health dashboard
- `/remote-logs` - View container logs
- `/remote-rollback` - Rollback to previous image
- `/remote-status` - Check if update needed
