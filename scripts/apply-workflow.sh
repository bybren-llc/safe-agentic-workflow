#!/bin/bash

# apply-workflow.sh
# This script integrates the {{PROJECT_SHORT}} SAFe-Agentic-Workflow template into your project.

set -e

# --- Configuration Variables ---
TEMPLATE_DIR="$(dirname "$0")"
TARGET_DIR="."

# --- Helper Functions ---
log_info() { echo -e "\033[0;34mINFO:\033[0m $1"; }
log_success() { echo -e "\033[0;32mSUCCESS:\033[0m $1"; }
log_warn() { echo -e "\033[0;33mWARN:\033[0m $1"; }
log_error() { echo -e "\033[0;31mERROR:\033[0m $1"; exit 1; }

# --- Main Script ---
log_info "Starting {{PROJECT_SHORT}} SAFe-Agentic-Workflow integration..."

# 1. Get User Input

# Choose AI Agent Provider
log_info "Which AI agent provider will your team be using?"
log_info "  1) Claude Code (Recommended, fully automated)"
log_info "  2) Augment (Guided starter kit)"
read -p "Enter your choice [1]: " AGENT_PROVIDER_CHOICE
AGENT_PROVIDER_CHOICE=${AGENT_PROVIDER_CHOICE:-1}

case $AGENT_PROVIDER_CHOICE in
  1)
    AGENT_PROVIDER="claude_code"
    AGENT_CONFIG_DIR=".claude"
    log_info "Selected Claude Code."
    ;;
  2)
    AGENT_PROVIDER="augment"
    AGENT_CONFIG_DIR=".augment"
    log_info "Selected Augment."
    ;;
  *)
    log_error "Invalid choice. Please enter 1 or 2."
    ;;
esac

# Get Project Ticket Prefix
read -p "Enter your project's ticket prefix (e.g., WOR, REND): " TICKET_PREFIX
if [ -z "$TICKET_PREFIX" ]; then
  log_error "Ticket prefix cannot be empty."
fi

# Get Primary Development Branch
read -p "Enter your primary development branch (e.g., dev, main): " PRIMARY_DEV_BRANCH
if [ -z "$PRIMARY_DEV_BRANCH" ]; then
  log_error "Primary development branch cannot be empty."
fi

# Get Project Git URL (for CONTRIBUTING.md example)
read -p "Enter your project's Git URL (e.g., https://github.com/org/repo): " PROJECT_GIT_URL
if [ -z "$PROJECT_GIT_URL" ]; then
  log_warn "Project Git URL is recommended but not required."
fi

# Get Project Name (for CONTRIBUTING.md example)
PROJECT_NAME=$(basename "$PROJECT_GIT_URL" .git)
if [ -z "$PROJECT_NAME" ]; then
  read -p "Enter your project's name (e.g., my-app): " PROJECT_NAME
  if [ -z "$PROJECT_NAME" ]; then
    log_warn "Project name is recommended but not required."
  fi
fi

# Get Project Management Tool URL Prefix (e.g., https://linear.app/org/issue)
read -p "Enter your project management tool's issue URL prefix (e.g., https://linear.app/org/issue): " TICKET_URL_PREFIX
if [ -z "$TICKET_URL_PREFIX" ]; then
  log_warn "Project management tool URL prefix is recommended but not required."
fi

# --- Copy Universal Files ---
log_info "Copying universal workflow files..."

# Copy AGENTS.md
cp "$TEMPLATE_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md"

# Copy project_workflow directory
mkdir -p "$TARGET_DIR/project_workflow"
cp -r "$TEMPLATE_DIR/project_workflow/." "$TARGET_DIR/project_workflow/"

# Copy patterns_library directory
mkdir -p "$TARGET_DIR/patterns_library"
cp -r "$TEMPLATE_DIR/patterns_library/." "$TARGET_DIR/patterns_library/"

# Copy specs_templates directory
mkdir -p "$TARGET_DIR/specs_templates"
cp -r "$TEMPLATE_DIR/specs_templates/." "$TARGET_DIR/specs_templates/"

# Copy linting_configs directory
mkdir -p "$TARGET_DIR/linting_configs"
cp -r "$TEMPLATE_DIR/linting_configs/." "$TARGET_DIR/linting_configs/"

# --- Copy Provider-Specific Files ---
log_info "Copying $AGENT_PROVIDER-specific agent files..."

mkdir -p "$TARGET_DIR/$AGENT_CONFIG_DIR"
cp -r "$TEMPLATE_DIR/agent_providers/$AGENT_PROVIDER/." "$TARGET_DIR/$AGENT_CONFIG_DIR/"

# --- Process Placeholders ---
log_info "Customizing files with project-specific details..."

find "$TARGET_DIR" -type f \( -name "*.md" -o -name "*.yml" -o -name "*.sh" -o -name "*.json" \) -print0 | while IFS= read -r -d $'' file;
do
  sed -i "s|__TICKET_PREFIX__|$TICKET_PREFIX|g" "$file"
  sed -i "s|__PRIMARY_DEV_BRANCH__|$PRIMARY_DEV_BRANCH|g" "$file"
  sed -i "s|__PROJECT_GIT_URL__|$PROJECT_GIT_URL|g" "$file"
  sed -i "s|__PROJECT_NAME__|$PROJECT_NAME|g" "$file"
  sed -i "s|__TICKET_URL_PREFIX__|$TICKET_URL_PREFIX|g" "$file"
done

# --- Merge Package.json Scripts ---
log_info "Merging essential scripts into package.json..."

if [ -f "$TARGET_DIR/package.json" ]; then
  # Check if jq is installed for JSON manipulation
  if command -v jq &> /dev/null; then
    # Essential scripts to merge
    ESSENTIAL_SCRIPTS='{
      "ci:validate": "yarn type-check && yarn lint && yarn test:unit",
      "ci:build": "yarn build",
      "ci:test": "yarn test:unit && yarn test:integration",
      "type-check": "tsc --noEmit",
      "lint": "eslint .",
      "lint:fix": "eslint --fix .",
      "format:check": "prettier --check .",
      "test:unit": "jest --testPathPatterns=__tests__/unit --passWithNoTests",
      "test:integration": "jest --testPathPatterns=__tests__/integration --passWithNoTests",
      "test:smoke": "jest --testPathPatterns=__tests__/smoke --passWithNoTests"
    }'

    # Merge scripts (only add if they don't exist)
    jq --argjson new_scripts "$ESSENTIAL_SCRIPTS" \
      '.scripts = (.scripts // {}) + ($new_scripts | to_entries | map(select(.key as $k | ($k | in($ARGS.positional[0].scripts)) | not)) | from_entries)' \
      "$TARGET_DIR/package.json" > "$TARGET_DIR/package.json.tmp" && \
      mv "$TARGET_DIR/package.json.tmp" "$TARGET_DIR/package.json"

    log_success "Essential scripts merged into package.json"
  else
    log_warn "jq not installed. Please manually add CI scripts to package.json:"
    log_warn "  - ci:validate: yarn type-check && yarn lint && yarn test:unit"
    log_warn "  - ci:build: yarn build"
    log_warn "  - ci:test: yarn test:unit && yarn test:integration"
  fi
else
  log_warn "No package.json found. Skipping script merge."
fi

# --- Make Scripts Executable ---
log_info "Making scripts executable..."
chmod +x "$TARGET_DIR/project_workflow/scripts/setup-ci-cd.sh" 2>/dev/null || true
if [ "$AGENT_PROVIDER" = "claude_code" ]; then
  chmod +x "$TARGET_DIR/$AGENT_CONFIG_DIR/hooks/"*.sh 2>/dev/null || true
fi

# --- Final Steps ---
log_info "Adding .gitignore entries..."
# Add .claude/ or .augment/ to .gitignore
if ! grep -q "^$AGENT_CONFIG_DIR/" "$TARGET_DIR/.gitignore" 2>/dev/null; then
  echo -e "\n# AI Agent Configuration\n$AGENT_CONFIG_DIR/" >> "$TARGET_DIR/.gitignore"
fi

log_success "{{PROJECT_SHORT}} SAFe-Agentic-Workflow integration complete!"
log_info "Next steps:"
log_info "1. Review the new files in your project."
log_info "2. If you chose Augment, read $AGENT_CONFIG_DIR/README.md for manual setup."
log_info "3. Run 'bash project_workflow/scripts/setup-ci-cd.sh' to configure GitHub."
log_info "4. Review CONTRIBUTING.md and AGENTS.md with your team."
log_info "5. Start building with your new SAFe-Agentic-Workflow!"
