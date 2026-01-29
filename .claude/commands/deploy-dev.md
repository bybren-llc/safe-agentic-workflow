---
description: Deploy latest Docker image to {{DEV_MACHINE}} dev environment
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
---

> **📋 TEMPLATE**: This command is a template. See "Customization Guide" below to adapt for your infrastructure.

> **DEPRECATED**: This command is an alias to `/remote-deploy`. Use `/remote-deploy` directly.

This command calls `/remote-deploy` which is the canonical command for deploying to {{DEV_MACHINE}}.

## Usage

```bash
/remote-deploy
```

## Why Deprecated?

Per {{TICKET_PREFIX}}-445, we canonicalized around `/remote-*` and `/local-*` naming:

- `/remote-*` = {{DEV_MACHINE}} operations (staging-first, then dev)
- `/local-*` = Local machine operations

## Related Commands

- `/remote-deploy` - **Canonical** - Deploy latest image to {{DEV_MACHINE}}
- `/remote-status` - Check if {{DEV_MACHINE}} needs update
- `/remote-health` - Health dashboard for {{DEV_MACHINE}}
- `/remote-logs` - View {{DEV_MACHINE}} container logs
- `/remote-rollback` - Rollback {{DEV_MACHINE}} to previous image

## Customization Guide

To adapt this command for your infrastructure, replace these placeholders:

| Placeholder       | Description                  | Example                           |
| ----------------- | ---------------------------- | --------------------------------- |
| `{{TICKET_PREFIX}}` | Your Linear ticket prefix    | `WOR`, `PROJ`, `TASK`             |
| `{{DEV_MACHINE}}`   | Your remote dev machine name | `Pop OS`, `staging`, `dev-server` |
