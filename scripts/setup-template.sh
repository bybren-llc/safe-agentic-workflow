#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# GitHub Template Setup Wizard
# ============================================================================
# This script customizes the template repository for your project.
# Run once after creating a new repo from the template.
#
# Usage: bash scripts/setup-template.sh
# Compatible with GNU sed (Linux) and BSD sed (macOS).
# ============================================================================

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# --- Cross-platform sed helper ---
# BSD sed (macOS) requires -i '' while GNU sed uses -i alone.
_sed_inplace() {
  if sed --version 2>/dev/null | grep -q 'GNU'; then
    sed -i "$@"
  else
    sed -i '' "$@"
  fi
}

echo "============================================"
echo "  AI Agent Harness - Template Setup Wizard"
echo "============================================"
echo ""
echo "This will replace all template placeholders with your project values."
echo "Press Ctrl+C to cancel at any time."
echo ""

# --- Collect values ---

echo "--- Project Identity ---"
read -rp "Project name (e.g., my-saas-app): " PROJECT_NAME
read -rp "Project repo name (e.g., my-saas-app): " PROJECT_REPO
read -rp "Project short name / acronym (e.g., ACME): " PROJECT_SHORT
read -rp "Project domain (e.g., acme.com): " PROJECT_DOMAIN

echo ""
echo "--- Organization ---"
read -rp "GitHub org or username (e.g., acme-corp): " GITHUB_ORG
read -rp "Company/org display name (e.g., Acme Corp): " COMPANY_NAME

echo ""
echo "--- Author ---"
read -rp "Author full name (e.g., Jane Smith): " AUTHOR_NAME
read -rp "Author first name (e.g., Jane): " AUTHOR_FIRST_NAME
read -rp "Author last name (e.g., Smith): " AUTHOR_LAST_NAME
read -rp "Author GitHub handle (e.g., janesmith): " AUTHOR_HANDLE
read -rp "Author email (e.g., jane@acme.com): " AUTHOR_EMAIL
read -rp "Author website URL (e.g., https://janesmith.dev): " AUTHOR_WEBSITE
read -rp "Security contact email (e.g., security@acme.com): " SECURITY_EMAIL

echo ""
echo "--- Workflow ---"
read -rp "Linear ticket prefix (e.g., ACM): " TICKET_PREFIX
read -rp "Linear workspace slug (e.g., acme): " LINEAR_WORKSPACE
read -rp "Main branch name [main]: " MAIN_BRANCH
MAIN_BRANCH="${MAIN_BRANCH:-main}"

echo ""
echo "--- Infrastructure ---"
read -rp "Database user (e.g., app_user): " DB_USER
read -rp "Database password (e.g., app_password): " DB_PASSWORD
read -rp "Database name (e.g., app_dev): " DB_NAME
read -rp "Database container name (e.g., app-postgres): " DB_CONTAINER
read -rp "Dev container name (e.g., app-dev): " DEV_CONTAINER
read -rp "Staging container name (e.g., app-staging): " STAGING_CONTAINER
read -rp "Container registry (e.g., ghcr.io/acme-corp): " CONTAINER_REGISTRY

# Derived values
TICKET_PREFIX_LOWER=$(echo "$TICKET_PREFIX" | tr '[:upper:]' '[:lower:]')
AUTHOR_INITIALS="${AUTHOR_FIRST_NAME:0:1}. ${AUTHOR_LAST_NAME:0:1}."
GITHUB_REPO_URL="https://github.com/${GITHUB_ORG}/${PROJECT_REPO}"

echo ""
echo "--- Review your values ---"
echo "  Project name:       $PROJECT_NAME"
echo "  Project repo:       $PROJECT_REPO"
echo "  Project short:      $PROJECT_SHORT"
echo "  Project domain:     $PROJECT_DOMAIN"
echo "  GitHub org:         $GITHUB_ORG"
echo "  Company:            $COMPANY_NAME"
echo "  Author:             $AUTHOR_NAME ($AUTHOR_HANDLE) <$AUTHOR_EMAIL>"
echo "  Author website:     $AUTHOR_WEBSITE"
echo "  Author initials:    $AUTHOR_INITIALS"
echo "  Security email:     $SECURITY_EMAIL"
echo "  Ticket prefix:      $TICKET_PREFIX ($TICKET_PREFIX_LOWER)"
echo "  Linear workspace:   $LINEAR_WORKSPACE"
echo "  Main branch:        $MAIN_BRANCH"
echo "  Database:           $DB_USER / $DB_NAME ($DB_CONTAINER)"
echo "  Dev container:      $DEV_CONTAINER"
echo "  Staging container:  $STAGING_CONTAINER"
echo "  Registry:           $CONTAINER_REGISTRY"
echo "  Repo URL:           $GITHUB_REPO_URL"
echo ""
read -rp "Proceed? (y/N): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "Aborted."
  exit 1
fi

echo ""
echo "Applying replacements..."

# --- Define replacements (order matters: longer/more-specific strings first) ---

declare -a REPLACEMENTS=(
  "{{GITHUB_REPO_URL}}|${GITHUB_REPO_URL}"
  "{{CONTAINER_REGISTRY}}|${CONTAINER_REGISTRY}"
  "{{STAGING_CONTAINER}}|${STAGING_CONTAINER}"
  "{{TICKET_PREFIX_LOWER}}|${TICKET_PREFIX_LOWER}"
  "{{DEV_CONTAINER}}|${DEV_CONTAINER}"
  "{{DB_CONTAINER}}|${DB_CONTAINER}"
  "{{DB_PASSWORD}}|${DB_PASSWORD}"
  "{{PROJECT_DOMAIN}}|${PROJECT_DOMAIN}"
  "{{PROJECT_SHORT}}|${PROJECT_SHORT}"
  "{{PROJECT_REPO}}|${PROJECT_REPO}"
  "{{PROJECT_NAME}}|${PROJECT_NAME}"
  "{{COMPANY_NAME}}|${COMPANY_NAME}"
  "{{AUTHOR_WEBSITE}}|${AUTHOR_WEBSITE}"
  "{{AUTHOR_FIRST_NAME}}|${AUTHOR_FIRST_NAME}"
  "{{AUTHOR_LAST_NAME}}|${AUTHOR_LAST_NAME}"
  "{{AUTHOR_INITIALS}}|${AUTHOR_INITIALS}"
  "{{AUTHOR_HANDLE}}|${AUTHOR_HANDLE}"
  "{{AUTHOR_EMAIL}}|${AUTHOR_EMAIL}"
  "{{AUTHOR_NAME}}|${AUTHOR_NAME}"
  "{{SECURITY_EMAIL}}|${SECURITY_EMAIL}"
  "{{TICKET_PREFIX}}|${TICKET_PREFIX}"
  "{{LINEAR_WORKSPACE}}|${LINEAR_WORKSPACE}"
  "{{MAIN_BRANCH}}|${MAIN_BRANCH}"
  "{{GITHUB_ORG}}|${GITHUB_ORG}"
  "{{DB_USER}}|${DB_USER}"
  "{{DB_NAME}}|${DB_NAME}"
)

# --- Apply replacements ---

for pair in "${REPLACEMENTS[@]}"; do
  OLD="${pair%%|*}"
  NEW="${pair#*|}"

  # Skip if old == new
  [[ "$OLD" == "$NEW" ]] && continue

  echo "  Replacing '$OLD' → '$NEW'"

  # Find all text files, excluding .git and node_modules
  find "$REPO_ROOT" \
    -type f \
    \( -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" \
       -o -name "*.sh" -o -name "*.py" -o -name "*.txt" -o -name "*.toml" \
       -o -name "*.bib" -o -name "*.cff" -o -name "*.mjs" -o -name "*.ts" \
       -o -name "NOTICE" -o -name "LICENSE" -o -name "CODEOWNERS" \
       -o -name ".env.template" -o -name ".gitignore" \) \
    ! -path "*/.git/*" \
    ! -path "*/node_modules/*" \
    -print0 | xargs -0 _sed_inplace "s|${OLD}|${NEW}|g"
done

echo ""
echo "Replacements complete."

# --- Remaining placeholders notice ---

REMAINING=$(grep -roh '{{[A-Z_]*}}' "$REPO_ROOT" \
  --include="*.md" --include="*.json" --include="*.yml" --include="*.yaml" \
  --include="*.sh" --include="*.cff" --include="*.bib" \
  2>/dev/null | sort -u | grep -v '^$' || true)

if [[ -n "$REMAINING" ]]; then
  echo "NOTE: The following placeholders remain (customize manually in CLAUDE.md"
  echo "and other config files for your specific technology stack):"
  echo ""
  echo "$REMAINING"
  echo ""
  echo "These are typically filled in as you configure your project's tech stack."
fi

# --- Clean up template-only artifacts ---

echo ""
echo "Cleaning up template-only files..."

rm -f "$REPO_ROOT/TEMPLATE_SETUP.md"
rm -f "$REPO_ROOT/scripts/setup-template.sh"

echo "Cleanup complete."

# --- Optional: reinitialize git ---

echo ""
read -rp "Reinitialize git history? This removes all previous commits. (y/N): " REINIT
if [[ "$REINIT" == "y" || "$REINIT" == "Y" ]]; then
  rm -rf "$REPO_ROOT/.git"
  cd "$REPO_ROOT"
  git init -b "$MAIN_BRANCH"
  git add -A
  git commit -m "feat: initialize ${PROJECT_NAME} from AI Agent Harness template"
  echo "Fresh git history created."
fi

echo ""
echo "============================================"
echo "  Setup complete!"
echo "============================================"
echo ""
echo "Next steps:"
echo "  1. Review the changes: git diff (if you didn't reinit)"
echo "  2. Update .env.template with your actual service keys"
echo "  3. Customize CLAUDE.md technology stack section (fill remaining {{...}} placeholders)"
echo "  4. Configure Linear workspace (see docs/onboarding/)"
echo "  5. Push to GitHub: git remote add origin ${GITHUB_REPO_URL}.git && git push -u origin ${MAIN_BRANCH}"
echo ""
