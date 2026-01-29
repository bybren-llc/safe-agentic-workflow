#!/bin/bash
# {{PROJECT_SHORT}} SAFe Multi-Agent Development - Agent Prompt Installation Script
# 
# This script installs the 11 agent prompts for Claude Code or Augment Code
# 
# Usage:
#   ./scripts/install-prompts.sh              # Install for current user (Claude Code)
#   ./scripts/install-prompts.sh --team       # Install for team sharing (in-project)
#   ./scripts/install-prompts.sh --augment    # Install for Augment Code
#   ./scripts/install-prompts.sh --help       # Show help

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Agent source directories
CLAUDE_AGENTS_DIR="$REPO_ROOT/.claude/agents"
AUGMENT_AGENTS_DIR="$REPO_ROOT/agent_providers/augment"

# Installation modes
MODE="user"  # Default: user installation for Claude Code

# ============================================================================
# Helper Functions
# ============================================================================

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

show_help() {
    cat << EOF
{{PROJECT_SHORT}} SAFe Agent Prompt Installation Script

USAGE:
    ./scripts/install-prompts.sh [OPTIONS]

OPTIONS:
    --user          Install agents for current user (default)
                    Location: ~/.claude/agents/
    
    --team          Use in-project agents for team sharing
                    Location: .claude/agents/ (already present)
                    No installation needed - Claude Code auto-detects
    
    --augment       Install agents for Augment Code
                    Location: ~/.augment/agents/
    
    --help          Show this help message

EXAMPLES:
    # Install for Claude Code (current user)
    ./scripts/install-prompts.sh

    # Use in-project agents (team sharing)
    ./scripts/install-prompts.sh --team

    # Install for Augment Code
    ./scripts/install-prompts.sh --augment

AGENT PROVIDERS:
    - Claude Code: Uses .claude/agents/ directory
    - Augment Code: Uses agent_providers/augment/ directory
    - Both: Provider-agnostic prompts in agent_providers/*/prompts/

For more information, see: docs/onboarding/AGENT-SETUP-GUIDE.md
EOF
}

verify_agent_files() {
    local source_dir="$1"
    local expected_count=11
    
    if [ ! -d "$source_dir" ]; then
        print_error "Agent directory not found: $source_dir"
        return 1
    fi
    
    local agent_count=$(find "$source_dir" -maxdepth 1 -name "*.md" -type f | wc -l)
    
    if [ "$agent_count" -ne "$expected_count" ]; then
        print_warning "Expected $expected_count agent files, found $agent_count"
        return 1
    fi
    
    print_success "Found $agent_count agent files in $source_dir"
    return 0
}

install_claude_user() {
    print_header "Installing Agents for Claude Code (User)"
    
    # Verify source files
    if ! verify_agent_files "$CLAUDE_AGENTS_DIR"; then
        print_error "Agent files verification failed"
        exit 1
    fi
    
    # Create user directory if it doesn't exist
    local user_agents_dir="$HOME/.claude/agents"
    mkdir -p "$user_agents_dir"
    
    print_info "Installing agents to: $user_agents_dir"
    
    # Copy agent files
    cp -v "$CLAUDE_AGENTS_DIR"/*.md "$user_agents_dir/"
    
    # Copy hooks if they exist
    if [ -d "$REPO_ROOT/.claude/hooks" ]; then
        local user_hooks_dir="$HOME/.claude/hooks"
        mkdir -p "$user_hooks_dir"
        cp -v "$REPO_ROOT/.claude/hooks"/*.sh "$user_hooks_dir/" 2>/dev/null || true
        chmod +x "$user_hooks_dir"/*.sh 2>/dev/null || true
        print_success "Hooks installed to: $user_hooks_dir"
    fi
    
    print_success "Installation complete!"
    print_info "Installed 11 agents to: $user_agents_dir"
    
    # List installed agents
    echo ""
    print_info "Installed agents:"
    ls -1 "$user_agents_dir"/*.md | xargs -n 1 basename | sed 's/\.md$//' | sed 's/^/  - /'
}

install_claude_team() {
    print_header "Using In-Project Agents (Team Sharing)"
    
    # Verify source files
    if ! verify_agent_files "$CLAUDE_AGENTS_DIR"; then
        print_error "Agent files verification failed"
        exit 1
    fi
    
    print_success "Agents are already in: $CLAUDE_AGENTS_DIR"
    print_info "Claude Code will auto-detect agents in .claude/agents/"
    print_info "No installation needed - agents are ready to use!"
    
    # List available agents
    echo ""
    print_info "Available agents:"
    ls -1 "$CLAUDE_AGENTS_DIR"/*.md | xargs -n 1 basename | sed 's/\.md$//' | sed 's/^/  - /'
    
    echo ""
    print_info "Team members can use these agents by:"
    echo "  1. Cloning this repository"
    echo "  2. Opening in Claude Code"
    echo "  3. Agents are automatically available!"
}

install_augment() {
    print_header "Installing Agents for Augment Code"
    
    # Verify source files
    if ! verify_agent_files "$AUGMENT_AGENTS_DIR"; then
        print_error "Augment agent files verification failed"
        exit 1
    fi
    
    # Create user directory if it doesn't exist
    local user_agents_dir="$HOME/.augment/agents"
    mkdir -p "$user_agents_dir"
    
    print_info "Installing agents to: $user_agents_dir"
    
    # Copy agent files
    cp -v "$AUGMENT_AGENTS_DIR"/*.md "$user_agents_dir/"
    
    print_success "Installation complete!"
    print_info "Installed agents to: $user_agents_dir"
    
    # List installed agents
    echo ""
    print_info "Installed agents:"
    ls -1 "$user_agents_dir"/*.md | xargs -n 1 basename | sed 's/\.md$//' | sed 's/^/  - /'
}

verify_installation() {
    print_header "Verifying Installation"
    
    case "$MODE" in
        user)
            local agents_dir="$HOME/.claude/agents"
            ;;
        team)
            local agents_dir="$CLAUDE_AGENTS_DIR"
            ;;
        augment)
            local agents_dir="$HOME/.augment/agents"
            ;;
    esac
    
    if verify_agent_files "$agents_dir"; then
        print_success "Installation verified successfully!"
        
        echo ""
        print_info "Next steps:"
        echo "  1. Open Claude Code or Augment Code"
        echo "  2. Try invoking an agent: @bsa What is your role?"
        echo "  3. See docs/onboarding/AGENT-SETUP-GUIDE.md for examples"
        echo "  4. Complete docs/onboarding/DAY-1-CHECKLIST.md"
    else
        print_error "Installation verification failed"
        exit 1
    fi
}

# ============================================================================
# Main Script
# ============================================================================

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --user)
            MODE="user"
            shift
            ;;
        --team)
            MODE="team"
            shift
            ;;
        --augment)
            MODE="augment"
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
done

# Run installation based on mode
case "$MODE" in
    user)
        install_claude_user
        ;;
    team)
        install_claude_team
        ;;
    augment)
        install_augment
        ;;
esac

# Verify installation
verify_installation

echo ""
print_success "🎉 Agent installation complete!"

