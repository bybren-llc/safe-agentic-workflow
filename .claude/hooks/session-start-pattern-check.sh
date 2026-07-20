#!/bin/bash
# Session-Start Hook: Pattern Library Check
#
# Checks for pattern library updates on session start
# Reminds agents to check patterns_library/ before implementation

PATTERN_DIR="docs/patterns"
PATTERN_COUNT=$(find "$PATTERN_DIR" -name "*.md" -type f 2>/dev/null | wc -l)

if [ -d "$PATTERN_DIR" ]; then
  echo "📚 Pattern Library Status:"
  echo "   Location: $PATTERN_DIR"
  echo "   Available patterns: $PATTERN_COUNT"
  echo ""
  echo "   Quick Reference:"
  echo "   - API patterns: $PATTERN_DIR/api/"
  echo "   - UI patterns: $PATTERN_DIR/ui/"
  echo "   - Database patterns: $PATTERN_DIR/database/"
  echo "   - Testing patterns: $PATTERN_DIR/testing/"
  echo ""
  echo "   💡 Remember: Check pattern library BEFORE implementation!"
  echo "   Run: cat $PATTERN_DIR/README.md"
else
  echo "⚠️  Pattern library not found at $PATTERN_DIR"
fi

echo ""
echo "🤖 Agent System Ready"

# Report what is actually on disk rather than asserting a taxonomy.
# This banner previously printed "Model selection: ✅ Opus (planning), Sonnet
# (execution)" as a verified fact. It was false — every agent declares opus —
# and nothing here ever checked it. A green check for an unperformed check is
# worse than no line at all, so these are counted, not claimed.
AGENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../agents" 2>/dev/null && pwd)"
if [ -n "$AGENT_DIR" ] && [ -d "$AGENT_DIR" ]; then
  AGENT_COUNT=$(find "$AGENT_DIR" -maxdepth 1 -name '*.md' ! -name 'README.md' -type f | wc -l | tr -d ' ')
  # CR stripped per-line so CRLF checkouts still report real values instead of silently
  # showing none; quotes and trailing space tolerated as valid YAML.
  MODELS=$(awk '
      FNR==1 { n=0 }
      { sub(/\r$/, "") }
      /^---$/ { n++; next }
      n==1 && /^model:/ {
          sub(/^model:[[:space:]]*/, "")
          sub(/[[:space:]]+$/, "")
          gsub(/^["'"'"']|["'"'"']$/, "")
          print
      }' "$AGENT_DIR"/*.md 2>/dev/null | sort -u | paste -sd, - )
  echo "   ${AGENT_COUNT} agents available in .claude/agents/"
  echo "   Models in use: ${MODELS:-inherit (none declared)}"
else
  echo "   Agent directory not found"
fi
echo ""

exit 0
