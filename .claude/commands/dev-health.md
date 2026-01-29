---
description: Check {{DEV_MACHINE}} dev environment health dashboard
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
---

> **📋 TEMPLATE**: This command is a template. See "Customization Guide" below to adapt for your infrastructure.

> **DEPRECATED**: This command is an alias to `/remote-health`. Use `/remote-health` directly.

This command calls `/remote-health` which is the canonical command for {{DEV_MACHINE}} health checks.

## Usage

```bash
/remote-health
```

## Why Deprecated?

Per {{TICKET_PREFIX}}-445, we canonicalized around `/remote-*` and `/local-*` naming:

- `/remote-*` = {{DEV_MACHINE}} operations (staging-first, then dev)
- `/local-*` = Local machine operations

## Related Commands

- `/remote-health` - **Canonical** - Health dashboard for {{DEV_MACHINE}}
- `/remote-status` - Check if {{DEV_MACHINE}} needs update
- `/remote-deploy` - Deploy latest image to {{DEV_MACHINE}}
- `/remote-logs` - View {{DEV_MACHINE}} container logs

## Customization Guide

To adapt this command for your infrastructure, replace these placeholders:

| Placeholder       | Description                  | Example                           |
| ----------------- | ---------------------------- | --------------------------------- |
| `{{TICKET_PREFIX}}` | Your Linear ticket prefix    | `WOR`, `PROJ`, `TASK`             |
| `{{DEV_MACHINE}}`   | Your remote dev machine name | `Pop OS`, `staging`, `dev-server` |
