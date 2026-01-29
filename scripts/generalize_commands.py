#!/usr/bin/env python3
"""
Generalize .claude/commands/*.md files with placeholder syntax.
This script updates command files to use templates instead of hardcoded values.
"""

import os
import re
from pathlib import Path

COMMANDS_DIR = Path("/home/{{AUTHOR_HANDLE}}/Projects/{{PROJECT_REPO}}/.claude/commands")

TEMPLATE_NOTICE = """> **📋 TEMPLATE**: This command is a template. See "Customization Guide" below to adapt for your infrastructure.
"""

def add_template_notice(content: str) -> str:
    """Add template notice after frontmatter if not present."""
    if "📋 TEMPLATE" in content:
        return content

    # Find the end of frontmatter (second ---)
    parts = content.split("---", 2)
    if len(parts) >= 3:
        # parts[0] is empty, parts[1] is frontmatter, parts[2] is rest
        return f"---{parts[1]}---\n\n{TEMPLATE_NOTICE}\n{parts[2]}"
    return content

def replace_patterns(content: str, patterns: dict) -> str:
    """Replace multiple patterns in content."""
    for old, new in patterns.items():
        content = content.replace(old, new)
    return content

def add_customization_guide(content: str, placeholders: list) -> str:
    """Add customization guide if not present."""
    if "## Customization Guide" in content:
        return content

    guide = "\n## Customization Guide\n\n"
    guide += "To adapt this command for your infrastructure, replace these placeholders:\n\n"
    guide += "| Placeholder       | Description                    | Example                          |\n"
    guide += "| ----------------- | ------------------------------ | -------------------------------- |\n"

    for placeholder, description, example in placeholders:
        guide += f"| `{placeholder}`{' ' * (17 - len(placeholder))} | {description}{' ' * (30 - len(description))} | {example}{' ' * (32 - len(example))} |\n"

    return content + guide

def process_deprecated_alias(filepath: Path):
    """Process deprecated alias files (check-docker-status, dev-health, deploy-dev, dev-logs)."""
    print(f"Processing {filepath.name}...")
    content = filepath.read_text()

    # Add template notice
    content = add_template_notice(content)

    # Replace patterns
    patterns = {
        "Pop OS": "{DEV_MACHINE}",
        "{{TICKET_PREFIX}}-": "{TICKET_PREFIX}-",
    }
    content = replace_patterns(content, patterns)

    # Add customization guide
    placeholders = [
        ("{TICKET_PREFIX}", "Your Linear ticket prefix", "`WOR`, `PROJ`, `TASK`"),
        ("{DEV_MACHINE}", "Your remote dev machine name", "`Pop OS`, `staging`, `dev-server`"),
    ]
    content = add_customization_guide(content, placeholders)

    filepath.write_text(content)
    print(f"  ✓ Updated {filepath.name}")

def process_workflow_command(filepath: Path):
    """Process workflow command files (start-work, pre-pr, quick-fix, local-sync, audit-deps, test-pr-docker)."""
    print(f"Processing {filepath.name}...")
    content = filepath.read_text()

    # Add template notice
    content = add_template_notice(content)

    # Replace {{TICKET_PREFIX}}- with {TICKET_PREFIX}-
    content = content.replace("{{TICKET_PREFIX}}-", "{TICKET_PREFIX}-")

    # Only add customization guide if the file actually uses placeholders
    if "{TICKET_PREFIX}" in content:
        placeholders = [
            ("{TICKET_PREFIX}", "Your Linear ticket prefix", "`WOR`, `PROJ`, `TASK`"),
        ]
        content = add_customization_guide(content, placeholders)

    filepath.write_text(content)
    print(f"  ✓ Updated {filepath.name}")

def process_rollback_dev(filepath: Path):
    """Special handling for rollback-dev.md with extensive SSH commands."""
    print(f"Processing {filepath.name} (special handling)...")
    content = filepath.read_text()

    # Add template notice
    content = add_template_notice(content)

    # Replace all hardcoded values with placeholders
    patterns = {
        "~/.ssh/id_ed25519_pop_os": "{SSH_KEY_PATH}",
        "{{AUTHOR_HANDLE}}@pop-os": "{REMOTE_USER}@{REMOTE_HOST}",
        "pop-os:": "{REMOTE_HOST}:",
        "http://pop-os:": "http://{REMOTE_HOST}:",
        "~/Projects/{{LINEAR_WORKSPACE}}-team": "{PROJECT_PATH}",
        "{{CONTAINER_REGISTRY}}/{{LINEAR_WORKSPACE}}-app/dev": "{REGISTRY}/{PROJECT_NAME}/dev",
        "{{DEV_CONTAINER}}": "{PROJECT}-dev-app",
        "name={{LINEAR_WORKSPACE}}": "name={PROJECT}",
        "Pop OS": "{DEV_MACHINE}",
        "{{TICKET_PREFIX}}-": "{TICKET_PREFIX}-",
    }
    content = replace_patterns(content, patterns)

    # Add customization guide with all placeholders
    placeholders = [
        ("{TICKET_PREFIX}", "Your Linear ticket prefix", "`WOR`, `PROJ`, `TASK`"),
        ("{SSH_KEY_PATH}", "Path to SSH private key", "`~/.ssh/id_ed25519_staging`"),
        ("{REMOTE_USER}", "Username on remote host", "`deploy`, `{{AUTHOR_HANDLE}}`"),
        ("{REMOTE_HOST}", "Remote host name/IP", "`pop-os`, `staging.example.com`"),
        ("{PROJECT_PATH}", "Project directory on remote", "`~/Projects/{{LINEAR_WORKSPACE}}-team`, `~/app`"),
        ("{REGISTRY}", "Container registry URL", "`{{CONTAINER_REGISTRY}}`"),
        ("{PROJECT_NAME}", "Project name in registry", "`{{LINEAR_WORKSPACE}}-app`, `myapp`"),
        ("{PROJECT}", "Short project identifier", "`{{LINEAR_WORKSPACE}}`, `myapp`"),
        ("{DEV_MACHINE}", "Remote dev machine name", "`Pop OS`, `staging`, `dev-server`"),
    ]
    content = add_customization_guide(content, placeholders)

    filepath.write_text(content)
    print(f"  ✓ Updated {filepath.name}")

def main():
    print("Generalizing Claude command files...\n")

    # Process deprecated alias files
    deprecated_aliases = [
        "check-docker-status.md",
        "dev-health.md",
        "deploy-dev.md",
        "dev-logs.md",
    ]

    for filename in deprecated_aliases:
        filepath = COMMANDS_DIR / filename
        if filepath.exists():
            process_deprecated_alias(filepath)

    # Process workflow command files
    workflow_commands = [
        "start-work.md",
        "pre-pr.md",
        "quick-fix.md",
        "local-sync.md",
        "audit-deps.md",
        "test-pr-docker.md",
    ]

    for filename in workflow_commands:
        filepath = COMMANDS_DIR / filename
        if filepath.exists():
            process_workflow_command(filepath)

    # Special handling for rollback-dev.md
    rollback_file = COMMANDS_DIR / "rollback-dev.md"
    if rollback_file.exists():
        process_rollback_dev(rollback_file)

    print("\n✅ Command generalization complete!")
    print("\nRun 'git diff .claude/commands/' to review changes")

if __name__ == "__main__":
    main()
