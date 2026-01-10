---
description: Check if remote Docker environment needs updating
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
---

# Remote Status Command

Compare the Docker image running on your remote host with the latest image in the registry.

> **📋 TEMPLATE**: This command is a template. See "Customization Guide" below to adapt for your infrastructure.

## Deployment Modes

Most Docker setups support two deployment modes:

| Mode            | Container Name      | Port   | Use Case                                    |
| --------------- | ------------------- | ------ | ------------------------------------------- |
| **Development** | `{PROJECT}-dev`     | `3000` | Hot-reload, source-mounted, local dev tools |
| **Staging**     | `{PROJECT}-staging` | `3001` | Production-like, self-contained, stable     |

**Dev mode uses standard ports** so local tools work by default.
**Staging mode is recommended** - it's stable and won't break during `git pull`.

## Workflow

### 1. Get Running Container Info

Check running container on remote host:

```bash
# ┌─────────────────────────────────────────────────────────────────────┐
# │ CUSTOMIZE: Replace with your SSH and container details              │
# └─────────────────────────────────────────────────────────────────────┘

# Check dev container
ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST} \
  "docker ps --filter name={PROJECT}-dev --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'"

# Check staging container
ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST} \
  "docker ps --filter name={PROJECT}-staging --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'"
```

Extract commit SHA from running container:

```bash
ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST} \
  "docker inspect {CONTAINER_NAME} | grep 'org.opencontainers.image.revision'"
```

Get image creation time:

```bash
ssh -i {SSH_KEY_PATH} {REMOTE_USER}@{REMOTE_HOST} \
  "docker images {REGISTRY}:latest --format '{{.CreatedAt}}'"
```

### 2. Get Latest Registry Image Info

Check latest commit on your main branch:

```bash
git fetch origin {MAIN_BRANCH}
git log origin/{MAIN_BRANCH} -1 --format='%H %s'
```

Check latest GitHub Actions build status:

```bash
gh run list --workflow={BUILD_WORKFLOW} --limit 3
```

### 3. Compare and Report Status

**If commit SHAs match**:

- ✅ Remote host is up-to-date
- Report current version info
- Show uptime
- No action needed

**If commit SHAs differ**:

- ⚠️ Update available
- Show current vs latest commits
- Check if CI build is complete
- If build in progress: show estimated completion
- If build complete: provide deployment command

### 4. Output Format

Display comprehensive status:

```text
🐳 Docker Image Status Check

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Remote Environment (Running)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Container: {CONTAINER_NAME}
Status:    ✅ Up 7 hours (healthy)
Image:     {REGISTRY}:latest
Commit:    e9722d4 - style(docs): apply markdown linting fixes
Created:   2025-10-11 08:20:15

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Container Registry (Latest)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Commit:    3a49b85 - feat(ci): add Slack notifications
Build:     ✅ Complete (31 seconds ago)
Status:    Ready to deploy

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Result: ⚠️  UPDATE AVAILABLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Changes since running version:
• feat(ci): add Slack notifications for Docker image builds

To deploy update:
/remote-deploy
```

### 5. Actionable Guidance

Based on status, provide appropriate next steps:

**Up-to-date**:

- "No action needed"
- Show next steps if user wants to check logs or health

**Update available + build complete**:

- "Ready to deploy"
- Provide `/remote-deploy` command
- Mention `/remote-status` to recheck before deploying

**Update available + build in progress**:

- "Build in progress (estimated X minutes remaining)"
- Provide link to CI run
- Suggest checking notifications for completion

**Build failed**:

- "Latest build failed"
- Link to CI failure
- Suggest checking logs

## Error Handling

If SSH fails:

- Check VPN/network connection
- Verify SSH key exists at `{SSH_KEY_PATH}`
- Provide manual SSH command

If container not found:

- Check if services are running
- Provide start command: `/remote-deploy`

## Customization Guide

To adapt this command for your infrastructure, replace these placeholders:

| Placeholder        | Description                    | Example                     |
| ------------------ | ------------------------------ | --------------------------- |
| `{SSH_KEY_PATH}`   | Path to SSH private key        | `~/.ssh/id_ed25519_staging` |
| `{REMOTE_USER}`    | Username on remote host        | `deploy`                    |
| `{REMOTE_HOST}`    | Remote server hostname/IP      | `staging.example.com`       |
| `{PROJECT}`        | Your project name              | `myapp`                     |
| `{CONTAINER_NAME}` | Docker container name          | `myapp-staging`             |
| `{REGISTRY}`       | Container registry URL         | `ghcr.io/myorg/myapp`       |
| `{MAIN_BRANCH}`    | Your main branch name          | `main` or `dev`             |
| `{BUILD_WORKFLOW}` | CI workflow that builds images | `build-image.yml`           |

## Success Criteria

- ✅ SSH connection successful
- ✅ Container info retrieved
- ✅ Registry status checked
- ✅ Clear status comparison
- ✅ Actionable next steps provided
