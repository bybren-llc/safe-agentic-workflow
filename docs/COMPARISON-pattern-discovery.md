# Pattern Discovery: WTFB vs ConTStack Comparison

> Comprehensive analysis of pattern management approaches to inform unified strategy

**Created**: 2026-01-12
**Purpose**: Decision support for merging pattern discovery mechanisms

---

## 1. Executive Summary

### WTFB Approach: Centralized Pattern Library
WTFB uses a **dedicated pattern-discovery skill** that triggers before any implementation work. Patterns are stored in a centralized `docs/patterns/` directory, organized by category (api, ui, database, testing, ci). The skill enforces a "pattern-first" development methodology where agents MUST check the pattern library before writing new code.

### ConTStack Approach: Hierarchical CLAUDE.md Structure
ConTStack embeds patterns **directly within hierarchical CLAUDE.md files** distributed throughout the codebase. Patterns are discovered through progressive disclosure (navigate from root to package-specific guides) and Quick Find Commands. This approach co-locates pattern documentation with the code it describes.

### Key Difference
- **WTFB**: Separation of concerns - patterns live apart from code
- **ConTStack**: Integration - patterns live alongside code they describe

---

## 2. How Pattern Discovery Works in WTFB

### 2.1 When It Triggers

The pattern-discovery skill activates when:
- About to create a new API route
- About to create a new UI component
- About to add database operations
- About to write integration tests
- User asks "how do I implement..." or "how should I build..."
- Starting work on any feature implementation

**Key Principle**: ALWAYS check patterns BEFORE writing new code.

### 2.2 What It Searches For

Three-step discovery protocol:

**Step 1: Check Pattern Library**
```bash
ls docs/patterns/api/      # API route patterns
ls docs/patterns/ui/       # UI component patterns
ls docs/patterns/database/ # Database operation patterns
ls docs/patterns/testing/  # Testing patterns
```

**Step 2: Review Pattern Index**
The skill references `docs/patterns/README.md` which contains a master index table mapping pattern categories to available patterns.

**Step 3: Apply or Escalate**
- If pattern exists: Copy, customize, validate
- If pattern missing: Search codebase for similar implementations, consider extraction (BSA/ARCHitect only), report gap

### 2.3 Where Patterns Are Stored

```
docs/patterns/
├── README.md               # Pattern index and usage guide
├── api/
│   ├── user-context-api.md
│   ├── admin-context-api.md
│   ├── webhook-handler.md
│   ├── zod-validation-api.md
│   └── bonus-content-delivery.md
├── ui/
│   ├── authenticated-page.md
│   ├── form-with-validation.md
│   ├── data-table.md
│   └── marketing-page.md
├── database/
│   ├── rls-migration.md
│   ├── prisma-transaction.md
│   └── server-component-direct-access.md
├── testing/
│   ├── api-integration-test.md
│   └── e2e-user-flow.md
└── ci/
    ├── service-configuration-pattern.md
    └── database-setup-pattern.md
```

### 2.4 How Patterns Are Documented

Each pattern file follows a consistent template:
- **Purpose**: What problem the pattern solves
- **Code Template**: Copy-paste ready code
- **Customization Guide**: How to adapt for specific use case
- **Validation Commands**: How to verify correct implementation
- **Security Requirements**: Mandatory security considerations

**Pattern Matching Guide** (task-to-pattern lookup):

| If you need to...                  | Use this pattern                  |
| ---------------------------------- | --------------------------------- |
| Create authenticated API endpoint  | `api/user-context-api.md`         |
| Create admin-only API endpoint     | `api/admin-context-api.md`        |
| Handle external webhooks           | `api/webhook-handler.md`          |
| Create protected page              | `ui/authenticated-page.md`        |
| Build form with validation         | `ui/form-with-validation.md`      |

---

## 3. How Pattern Discovery Works in ConTStack

### 3.1 Hierarchical CLAUDE.md Structure

ConTStack uses a tree of CLAUDE.md files:

```
CLAUDE.md                           # Master guide - navigation map
├── apps/CLAUDE.md                  # App development router
│   ├── apps/app/CLAUDE.md          # Main SaaS app patterns
│   ├── apps/web/CLAUDE.md          # Marketing site patterns
│   └── apps/crm/CLAUDE.md          # CRM app patterns
├── packages/CLAUDE.md              # Package development router
│   ├── packages/backend/CLAUDE.md  # Convex backend patterns
│   ├── packages/ui/CLAUDE.md       # UI component patterns
│   ├── packages/email/CLAUDE.md    # Email template patterns
│   └── packages/llm/CLAUDE.md      # LLM integration patterns
├── tests/CLAUDE.md                 # Testing patterns
├── docker/CLAUDE.md                # Container patterns
└── infra/CLAUDE.md                 # Infrastructure patterns
```

### 3.2 Progressive Disclosure

Agents navigate from general to specific:

1. **Root CLAUDE.md**: Quick overview, navigation map, universal rules
2. **Category CLAUDE.md**: Router files with category-specific patterns
3. **Package/App CLAUDE.md**: Detailed patterns, code examples, troubleshooting

Example navigation path for auth pattern:
```
CLAUDE.md (navigation map)
  → apps/app/CLAUDE.md (auth integration patterns)
    → Authentication Integration Patterns section
      → Query Gating example
      → withAuthGuard HOC pattern
```

### 3.3 Quick Find Commands

ConTStack embeds CLI commands for pattern discovery within CLAUDE.md files:

**Component Discovery**:
```bash
# Find React component
rg -n "^export (function|const) .*Component" apps/*/src packages/ui/src --type tsx

# Find component usage
rg -n "<ComponentName" apps/*/src --type tsx
```

**Backend Discovery**:
```bash
# Find Convex mutation/query
rg -n "export const .* = (mutation|query|action)" packages/backend/convex --type ts

# Find auth helper usage
rg -n "requireAuth|requireOrganization|requirePermission" packages/backend/convex --type ts
```

### 3.4 Package/App-Specific Patterns

Patterns are embedded in context. Example from `packages/backend/CLAUDE.md`:

```typescript
// RBAC Pattern - embedded in documentation
export const myFunction = mutation({
  handler: async (ctx, args) => {
    const { identity, user } = await requireAuth(ctx)
    // Pattern code continues...
  }
})
```

Each CLAUDE.md contains:
- **Overview**: Package purpose and technology
- **Directory Structure**: File organization
- **Common Patterns**: Code examples with context
- **Quick Search Commands**: Discovery shortcuts
- **Troubleshooting**: Problem-solution pairs

---

## 4. Side-by-Side Comparison Table

| Aspect | WTFB | ConTStack |
|--------|------|-----------|
| **Pattern Storage Location** | Centralized `docs/patterns/` | Distributed across CLAUDE.md files |
| **Discovery Mechanism** | Skill triggers, checks library | Navigate hierarchy, use Quick Find |
| **Documentation Format** | Standalone markdown files per pattern | Embedded in context-specific guides |
| **Update Workflow** | BSA/ARCHitect extracts patterns | Anyone updates relevant CLAUDE.md |
| **Agent Discoverability** | Explicit skill with protocol | Progressive disclosure + grep |
| **Pattern Index** | `docs/patterns/README.md` | Root CLAUDE.md navigation map |
| **Pattern Matching** | Task-to-pattern lookup table | Context clues from file location |
| **Validation** | Commands after pattern application | Pre-PR validation in each guide |
| **Security Integration** | Separate security requirements | Inlined with pattern code |
| **Cross-Referencing** | None (patterns are standalone) | Extensive links between CLAUDE.md |
| **Code-Pattern Distance** | Separate from code | Adjacent to code (same directory) |
| **Extraction Process** | Formalized (BSA/ARCHitect only) | Organic (update when learning) |
| **Template Structure** | Consistent per pattern | Consistent per CLAUDE.md |
| **Version Control** | Patterns can drift from code | Patterns evolve with code |

---

## 5. WTFB Strengths

### 5.1 Centralized Pattern Library
- **Single Source of Truth**: One location for all patterns
- **Easy Auditing**: Simple to review all patterns at once
- **Consistent Format**: Forced uniformity across pattern types
- **Onboarding**: New agents know exactly where to look

### 5.2 Explicit Extraction Workflow
- **Quality Control**: Only BSA/ARCHitect can add patterns
- **Deliberate Growth**: Patterns are intentionally curated
- **Gap Reporting**: Agents flag missing patterns for future extraction
- **No Duplicates**: Centralization prevents pattern proliferation

### 5.3 Pattern Templates
- **Copy-Paste Ready**: Minimal adaptation required
- **Validation Included**: Each pattern has test commands
- **Customization Guide**: Clear instructions for variation
- **Security Baked In**: RLS, auth, validation requirements mandatory

### 5.4 Task-to-Pattern Mapping
- **No Hunting**: Direct lookup table from need to solution
- **Cognitive Load Reduction**: Agents don't decide where to look
- **Exhaustive Coverage**: If it's not in the table, it doesn't exist

---

## 6. ConTStack Strengths

### 6.1 Progressive Disclosure
- **Reduced Overwhelm**: Start with overview, dive deeper as needed
- **Context Preservation**: Patterns shown with surrounding information
- **Just-in-Time Learning**: Access depth when needed, not before
- **Hierarchical Navigation**: Intuitive directory-based discovery

### 6.2 Patterns Co-located with Code
- **Single Mental Model**: Documentation and code in same place
- **Reduced Drift**: Patterns update when code updates
- **Immediate Context**: See pattern in its natural habitat
- **Easier Maintenance**: One PR updates both code and docs

### 6.3 Hierarchical Navigation
- **Parent Context**: Every CLAUDE.md references its parent
- **Specialization Tree**: General → Category → Specific
- **Cross-Linking**: Related patterns reference each other
- **Universal Rules**: Inherited from root CLAUDE.md

### 6.4 Quick Find Commands
- **Live Discovery**: Search actual codebase, not stale docs
- **Pattern by Example**: Find real implementations, not templates
- **Custom Searches**: Adapt commands for specific needs
- **Verification**: Commands prove patterns exist in code

---

## 7. Recommended Unified Approach

### 7.1 Keep Hierarchical CLAUDE.md Structure (ConTStack)

**Rationale**: Co-location with code prevents drift, progressive disclosure scales well.

**Implementation**:
- Maintain current CLAUDE.md hierarchy
- Each package/app CLAUDE.md contains its patterns
- Root CLAUDE.md provides navigation and universal rules
- Quick Find Commands remain embedded

### 7.2 Add WTFB Pattern Extraction Workflow

**Rationale**: Quality control and explicit curation prevent pattern sprawl.

**Implementation**:

Create a new skill: `/patterns` that:

1. **Triggers Before Implementation**:
   - Checks relevant CLAUDE.md files (not separate library)
   - Uses Quick Find Commands to verify pattern exists in code
   - Warns if no pattern found for task type

2. **Pattern Extraction Protocol**:
   - When agent discovers reusable pattern during work
   - Creates issue/task for pattern documentation
   - Pattern gets added to appropriate CLAUDE.md (not separate library)
   - BSA reviews pattern additions via PR

3. **Pattern Index in Root CLAUDE.md**:
   - Add a section mapping task types to CLAUDE.md locations
   - Similar to WTFB's task-to-pattern table but pointing to CLAUDE.md sections

### 7.3 Add Task-to-Pattern Lookup (WTFB Pattern Matching)

Add to root CLAUDE.md:

```markdown
## Pattern Quick Reference

| If you need to...                  | Look in...                           |
| ---------------------------------- | ------------------------------------ |
| Create authenticated API endpoint  | packages/backend/CLAUDE.md#auth      |
| Create protected React page        | apps/app/CLAUDE.md#auth-guards       |
| Add Convex mutation                | packages/backend/CLAUDE.md#mutation  |
| Build UI component                 | packages/ui/CLAUDE.md#components     |
| Add E2E test                       | tests/CLAUDE.md#e2e-patterns         |
| Configure Docker                   | docker/CLAUDE.md#setup               |
```

### 7.4 Specific Recommendations

**Adopt from WTFB**:
1. Pre-implementation check protocol (skill trigger)
2. Task-to-pattern lookup table
3. Explicit gap reporting mechanism
4. Validation commands after pattern use
5. Pattern extraction workflow with review

**Keep from ConTStack**:
1. Hierarchical CLAUDE.md structure
2. Patterns co-located with code
3. Quick Find Commands for live discovery
4. Progressive disclosure navigation
5. Cross-references between guides

**Discard/Modify**:
- WTFB: Separate `docs/patterns/` directory (merge into CLAUDE.md)
- ConTStack: None of the current structure needs removal

---

## 8. Implementation Notes

### 8.1 Migration Path

1. **Phase 1: Add Pattern Index to CLAUDE.md** (30 min)
   - Add task-to-pattern lookup table to root CLAUDE.md
   - Create section anchors in child CLAUDE.md files

2. **Phase 2: Create Pattern Discovery Skill** (1-2 hours)
   - Adapt WTFB's pattern-discovery skill
   - Point to CLAUDE.md hierarchy instead of `docs/patterns/`
   - Include Quick Find Commands in skill execution

3. **Phase 3: Add Pattern Extraction Workflow** (1 hour)
   - Document pattern extraction process in contributing guide
   - Create issue template for pattern proposals
   - Add pre-commit hook reminder for pattern documentation

4. **Phase 4: Validate and Iterate** (ongoing)
   - Monitor pattern discovery success rate
   - Track pattern gaps reported by agents
   - Refine lookup table based on usage

### 8.2 Success Criteria

- Agents find relevant patterns within 2 navigation steps
- Pattern drift rate (pattern vs code mismatch) < 5%
- Time to discover pattern < 30 seconds for common tasks
- Pattern gap reports lead to documentation updates within 1 sprint

### 8.3 Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Lookup table becomes stale | Automated check: verify anchors exist |
| Skill slows development | Make skill non-blocking with warnings |
| Too many pattern locations | Limit to one pattern per task type |
| Extraction process too heavy | Lightweight PR review, not full arch review |

---

## 9. Decision Matrix

| Criterion | WTFB Only | ConTStack Only | Unified (Recommended) |
|-----------|-----------|----------------|----------------------|
| Discoverability | High | Medium | High |
| Maintenance Cost | Medium | Low | Low |
| Pattern Quality | High | Variable | High |
| Code-Doc Sync | Low | High | High |
| Scalability | Medium | High | High |
| Agent Autonomy | Low (must check) | High | Medium |
| Learning Curve | Low | Medium | Low |

**Recommendation**: Unified approach provides best balance of WTFB's discoverability and quality control with ConTStack's maintainability and code synchronization.

---

## 10. Appendix: File References

### WTFB Files Referenced
- `/home/user/wtfb-fork/.claude/skills/pattern-discovery/SKILL.md`

### ConTStack Files Referenced
- `/home/user/convex-v1/CLAUDE.md`
- `/home/user/convex-v1/apps/CLAUDE.md`
- `/home/user/convex-v1/apps/app/CLAUDE.md`
- `/home/user/convex-v1/packages/CLAUDE.md`
- `/home/user/convex-v1/packages/backend/CLAUDE.md`
- `/home/user/convex-v1/packages/ui/CLAUDE.md`

---

*Document created for WTFB-to-ConTStack adaptation project*
