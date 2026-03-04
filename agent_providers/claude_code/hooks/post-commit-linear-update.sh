#!/bin/bash
# Post-Commit Hook: Linear Update
#
# Auto-updates Linear ticket with commit hash after successful commit
# Triggered after git commit operations

# Get the latest commit hash and message
COMMIT_HASH=$(git log -1 --format="%H" 2>/dev/null)
COMMIT_MSG=$(git log -1 --format="%s" 2>/dev/null)

# Extract Linear ticket from commit message ({{TICKET_PREFIX}}-XXX format)
LINEAR_TICKET=$(echo "$COMMIT_MSG" | grep -oE "{{TICKET_PREFIX}}-[0-9]+" | head -1)

if [ -z "$LINEAR_TICKET" ]; then
  echo "ℹ️  No Linear ticket found in commit message"
  exit 0
fi

if [ -z "$COMMIT_HASH" ]; then
  echo "⚠️  Could not retrieve commit hash"
  exit 0
fi

# Create comment for Linear (TDM will see this in session notes)
COMMENT="📝 Commit: ${COMMIT_HASH:0:8} - $COMMIT_MSG"

echo "✅ Linear update ready for $LINEAR_TICKET"
echo "   $COMMENT"
echo ""
echo "   Note: TDM agent can add this to Linear with:"
echo "   mcp__{{MCP_LINEAR_SERVER}}__create_comment(issueId='$LINEAR_TICKET', body='$COMMENT')"

# Exit successfully (actual Linear update done by TDM agent)
exit 0
