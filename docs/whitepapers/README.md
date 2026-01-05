# Claude Code Harness Whitepapers

This directory contains the complete documentation for the Claude Code harness architecture adopted for this repository.

## Documents

### 1. Claude Code Harness Modernization (Main Whitepaper)

**File**: `CLAUDE-CODE-HARNESS-MODERNIZATION-WOR-444.md`

The complete technical documentation of the three-layer harness architecture:

- Background and motivation
- Three-layer architecture (Hooks → Commands → Skills)
- All 17 skills with implementation details
- All 23 slash commands organized by category
- Phase 0-3 completion history
- SAFe role expansion vision
- Operational SOPs reference
- Lessons learned and migration checklist

### 2. Agent Perspective: Why This Harness Works

**File**: `CLAUDE-CODE-HARNESS-AGENT-PERSPECTIVE.md`

Philosophy and design principles from an agent's perspective:

- The expertise system view
- "Invisible when it works" principle
- Progressive disclosure model
- Pattern-first development philosophy
- Process as service, not control
- Round table collaboration model
- Documentation as product (for agents)

### 3. Knowledge Transfer Meta-Prompt

**File**: `CLAUDE-CODE-HARNESS-KT-META-PROMPT.md`

Adoption guide for teams wanting to implement this harness:

- Component extraction checklist
- Generalization guide (what to parameterize)
- Implementation steps (5 phases)
- Key insights to preserve
- File locations quick reference

### 4. Iteration Patterns Comparative Analysis

**File**: `ITERATION-PATTERNS-COMPARATIVE-ANALYSIS.md`

Comparative analysis of self-referential loops vs SAFe multi-agent orchestration:

- Ralph Wiggum (Anthropic's autonomous loop plugin) analysis
- SAFe Harness distributed multi-agent architecture
- Side-by-side comparison with ASCII diagrams
- Trust model analysis (self-trust vs distributed verification)
- Failure mode analysis and circuit breakers
- Integration recommendation (don't integrate - redundant)
- Validation of SAFe approach superiority for enterprise work

## Quick Start

1. **New to the harness?** Start with the Agent Perspective document to understand the philosophy
2. **Implementing the harness?** Use the KT Meta-Prompt as your guide
3. **Deep technical details?** The main whitepaper has everything

## Related Documentation

- **Harness README**: [/.claude/README.md](/.claude/README.md)
- **Setup Guide**: [/.claude/SETUP.md](/.claude/SETUP.md)
- **Troubleshooting**: [/.claude/TROUBLESHOOTING.md](/.claude/TROUBLESHOOTING.md)
- **Agent Profiles**: [/.claude/agents/](/.claude/agents/)

## Origin

These whitepapers document the harness developed during production use on the WTFB project and generalized for adoption by other SAFe/Agentic teams.

The harness was adopted into this repository in December 2025 as part of the harness-adoption initiative.
