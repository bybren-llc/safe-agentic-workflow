# Cursor IDE SSH Guide

How to observe and interact with your Dark Factory from Cursor IDE via SSH.

---

## Overview

The Dark Factory runs on a remote headless machine. You connect from your
local Cursor IDE using the Remote-SSH extension, giving you:

- Terminal access to tmux sessions (watch agents work in real-time)
- File explorer showing worktree changes as they happen
- Full editing capability if you need to intervene

---

## Setup

### 1. Configure SSH Access

Ensure you can SSH into your remote machine:

```bash
# Test connection
ssh {{REMOTE_USER}}@{{REMOTE_HOST}}

# Add to ~/.ssh/config for convenience
Host dark-factory
    HostName {{REMOTE_HOST}}
    User {{REMOTE_USER}}
    IdentityFile {{SSH_KEY_PATH}}
    ForwardAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

### 2. Install Remote-SSH in Cursor

1. Open Cursor
2. Extensions panel (Ctrl+Shift+X)
3. Search "Remote - SSH" (Microsoft)
4. Install

### 3. Connect to Remote Machine

1. Press Ctrl+Shift+P (Command Palette)
2. Type "Remote-SSH: Connect to Host"
3. Select `dark-factory` (or enter `{{REMOTE_USER}}@{{REMOTE_HOST}}`)
4. Cursor opens a new window connected to the remote machine

### 4. Open the Project

Once connected:
1. File > Open Folder
2. Navigate to your project directory (`{{PROJECT_PATH}}`)
3. Cursor now shows the remote filesystem

---

## Observing Agent Work

### Terminal: Attach to tmux

Open a terminal in Cursor (Ctrl+\`), then:

```bash
# See what's running
./dark-factory/scripts/factory-status.sh

# Attach to a session (read-only mode recommended)
tmux attach -t factory-{{TICKET_PREFIX}}-123 -r

# Attach to observe a specific agent
./dark-factory/scripts/factory-attach.sh factory-{{TICKET_PREFIX}}-123 2
```

**Tip**: Use Cursor's terminal split (Ctrl+Shift+5) to watch multiple agents:
- Terminal 1: `tmux attach -t <session> -r` (full session view)
- Terminal 2: `tail -f ~/.dark-factory/logs/<session>/*.log` (live logs)

### File Explorer: Watch Changes

If agents use git worktrees, open the worktree directory:
```
~/.dark-factory/worktrees/<session-name>/agent-0/
```

Cursor's file explorer will show changes as agents write files. Use the
Source Control panel (Ctrl+Shift+G) to see diffs in real-time.

### Status Dashboard

Run the status dashboard in a dedicated terminal:
```bash
watch -n 5 ./dark-factory/scripts/factory-status.sh
```

This refreshes every 5 seconds, showing agent health at a glance.

---

## Intervening

If you need to send input to an agent:

1. Attach to the session (without `-r` flag):
   ```bash
   tmux attach -t factory-{{TICKET_PREFIX}}-123
   ```
2. Navigate to the target pane (Alt+Arrow or Prefix+q then pane number)
3. Type your input

**Warning**: Avoid typing in agent panes during active work -- agents may
misinterpret terminal input. Use `factory-stop.sh` to pause, then restart.

---

## Persistent Connections with mosh

SSH connections can drop over time. Use `mosh` for a persistent connection:

```bash
# Install mosh on both machines
# Local: brew install mosh
# Remote: apt install mosh

# Connect via mosh
mosh {{REMOTE_USER}}@{{REMOTE_HOST}}

# Then attach to tmux inside mosh
tmux attach -t factory-{{TICKET_PREFIX}}-123 -r
```

mosh survives network changes, laptop sleep, and temporary disconnects.

---

## Tips

- **Read-only attach** (`-r` flag) prevents accidental keystrokes in agent panes
- **Multiple terminals** in Cursor let you monitor different aspects simultaneously
- **Cursor's search** (Ctrl+Shift+F) works across worktree files, useful for
  finding what agents have changed
- **Git blame** in Cursor shows which agent (commit author) made each change
- If using tmux inside Cursor's terminal and nested tmux conflicts with
  keybindings, set a different prefix for the factory tmux config or use
  `tmux -L dark-factory` to run a separate tmux server
