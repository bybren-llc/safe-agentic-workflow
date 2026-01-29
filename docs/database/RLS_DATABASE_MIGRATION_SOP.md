# 🔒 RLS Database Migration Standard Operating Procedures (SOP)

## 🎯 Purpose

This document establishes **mandatory procedures** for maintaining Row Level Security (RLS) when making database schema changes. **All database migrations MUST follow these procedures** to maintain security compliance.

**Created**: 2025-09-02  
**Author**: {{ARCHITECT_NAME}} (SAFe ARCHitect)  
**Status**: MANDATORY - Effective immediately upon RLS deployment  
**Enforcement**: All PRs with database changes require RLS review

---

## ⚠️ CRITICAL REQUIREMENT

**ANY database schema change that adds tables or columns containing user data MUST include corresponding RLS policy updates.**

Failure to maintain RLS policies creates **security vulnerabilities** where users could access other users' data.

---

## 🚨 BANNED PRACTICES

**CRITICAL**: The following practices have caused production security incidents and are BANNED.

### ❌ BANNED: Separate RLS Policy Files

**Issue**: Prisma `migrate deploy` only executes `migration.sql`, completely ignores separate `rls_policies.sql` files

**Impact**: Production incident {{TICKET_PREFIX}}-221/{{TICKET_PREFIX}}-222 (Sept 2025) - RLS policies not applied, 4+ hour emergency debugging

**What NOT to do**:

```sql
-- ❌ WRONG: migration.sql
CREATE TABLE user_data (id SERIAL PRIMARY KEY, ...);

-- ❌ WRONG: rls_policies.sql (IGNORED BY PRISMA!)
ALTER TABLE user_data ENABLE ROW LEVEL SECURITY;
```

**Correct approach**: ALL RLS in migration.sql

```sql
-- ✅ CORRECT: migration.sql (everything in ONE file)
CREATE TABLE user_data (id SERIAL PRIMARY KEY, ...);
ALTER TABLE user_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_data FORCE ROW LEVEL SECURITY;
CREATE POLICY ...
```

**Reference**: `docs/database/PRISMA_MIGRATION_BEST_PRACTICES.md`

---

### ❌ BANNED: Using `npx prisma migrate resolve --applied`

**Issue**: Only updates Prisma's migration tracking WITHOUT executing SQL

**Impact**: Production incident {{TICKET_PREFIX}}-315 (Oct 2025) - Tables created WITHOUT RLS protection

**What happened**:

1. Developer ran `npx prisma migrate resolve --applied MIGRATION_NAME`
2. Prisma marked migration as "applied" ✅
3. SQL was NEVER executed ❌
4. Tables created without RLS (security vulnerability)

**Detection**: Check `_prisma_migrations` table:

```sql
SELECT migration_name, finished_at, applied_steps_count
FROM _prisma_migrations
WHERE migration_name = 'YOUR_MIGRATION';

-- If applied_steps_count = 0 → Migration NOT executed!
```

**ONLY valid use**: Mark already-manually-applied migration as resolved  
**MUST verify**: SQL actually executed via manual psql application

**Prevention**: Use `scripts/pre-migration-audit.ts` before production

---

### ❌ BANNED: Manual RLS Application After Migration

**Issue**: Breaks deployment automation, creates schema drift

**Why it happens**: Prisma ignores separate RLS files (see above)

**Correct approach**: Embed RLS in migration.sql from the start

**If RLS missing**: Create new migration with RLS, don't manually apply

---

## 📊 Decision Tree for RLS Requirements

```
New Database Change
        │
        ├─> Is it a new table?
        │   │
        │   ├─> YES → Does it contain user-specific data?
        │   │         │
        │   │         ├─> YES → REQUIRES RLS POLICIES
        │   │         └─> NO → Document why RLS not needed
        │   │
        │   └─> NO → Is it a new column?
        │             │
        │             ├─> Contains user_id? → UPDATE EXISTING POLICIES
        │             └─> Contains sensitive data? → REVIEW RLS REQUIREMENTS
        │
        └─> All changes → UPDATE DOCUMENTATION
```

---

## 🔧 SOP for Adding New Tables

### Step 1: Determine RLS Requirements

#### Tables REQUIRING RLS Protection

- Contains `user_id` column
- Stores personal/financial data
- Contains user-generated content
- Tracks user activity or preferences
- Stores authentication/authorization data

#### Tables NOT Requiring RLS

- Global configuration tables
- Reference/lookup tables (like `subscriptions_plans`)
- System-wide settings
- Public content tables

### Step 2: Create Migration with RLS

```sql
-- Example: Adding new user_preferences table

-- 1. Create table (in Prisma migration)
CREATE TABLE user_preferences (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    theme VARCHAR(50),
    notifications BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES "user"(user_id)
);

-- 2. Create index for RLS performance
CREATE INDEX user_preferences_user_id_idx ON user_preferences(user_id);

-- 3. Enable RLS (MANDATORY)
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences FORCE ROW LEVEL SECURITY;

-- 4. Create RLS policies for {{DB_USER}} (superuser)
CREATE POLICY user_preferences_isolation ON user_preferences
    FOR ALL
    TO {{DB_USER}}
    USING (user_id = current_setting('app.current_user_id', true));

-- 5. Create RLS policies for {{LINEAR_WORKSPACE}}_app_user (application user)
CREATE POLICY user_preferences_app_isolation ON user_preferences
    FOR ALL
    TO {{LINEAR_WORKSPACE}}_app_user
    USING (user_id = current_setting('app.current_user_id', true));
```

### Step 3: Update RLS Documentation

Add to `/scripts/rls-maintenance-log.sql`:

```sql
-- Date: YYYY-MM-DD
-- Developer: [Name]
-- Table: user_preferences
-- Reason: User customization settings
-- RLS: User isolation policy applied
-- Linear: [Ticket number]
```

### Step 4: Test RLS Implementation

```sql
-- Test script for new table RLS
-- Run as {{LINEAR_WORKSPACE}}_app_user

-- Set context for test user
SET app.current_user_id = 'test_user_123';

-- Should only see own preferences
SELECT COUNT(*) FROM user_preferences; -- Should be 0 or user's records only

-- Try to access other user's data (should return 0)
SET app.current_user_id = 'different_user';
SELECT COUNT(*) FROM user_preferences WHERE user_id = 'test_user_123'; -- Must be 0
```

---

## 📋 Database Migration Checklist

### Pre-Migration Requirements

- [ ] **Identify data classification**
  - [ ] User-specific data? → Requires RLS
  - [ ] Financial data? → Requires RLS
  - [ ] System data? → May require admin-only RLS
  - [ ] Public data? → Document no RLS needed

- [ ] **Design RLS policies**
  - [ ] User isolation pattern for user data
  - [ ] Role-based pattern for admin data
  - [ ] System context pattern for webhook data

- [ ] **Performance considerations**
  - [ ] Index on user_id column
  - [ ] Index on any column used in RLS policy

- [ ] **Documentation planning**
  - [ ] Update DATA_DICTIONARY.md with new schema changes
  - [ ] Plan Confluence documentation updates
  - [ ] Identify any related documentation requiring updates

- [ ] **Verify RLS in migration.sql** (not separate files)
  - [ ] Run: `npx tsx scripts/validate-migration-rls.ts MIGRATION_NAME`
  - [ ] Confirm: RLS statements present in migration.sql
  - [ ] Confirm: No separate rls_policies.sql files

- [ ] **Verify migration actually executed locally**
  - [ ] Run: `npx tsx scripts/pre-migration-audit.ts MIGRATION_NAME`
  - [ ] Confirm: `applied_steps_count > 0` in \_prisma_migrations
  - [ ] Confirm: Tables exist with RLS enabled
  - [ ] Confirm: Policies created (not just tables)

### Migration Implementation

- [ ] **Prisma Schema Update**

  ```prisma
  model UserPreferences {
    id        Int      @id @default(autoincrement())
    userId    String   @map("user_id")
    theme     String?
    createdAt DateTime @default(now()) @map("created_at")
    user      User     @relation(fields: [userId], references: [userId])

    @@index([userId])
    @@map("user_preferences")
  }
  ```

- [ ] **SQL Migration File**
  - [ ] Table creation
  - [ ] Index creation
  - [ ] RLS enablement
  - [ ] Policy creation

- [ ] **Helper Function Updates**

  ```typescript
  // utils/data/userPreferences/userPreferencesHelpers.ts
  export const getUserPreferences = async (userId: string) => {
    // RLS context automatically applied via lib/rls-context.ts
    return await prisma.userPreferences.findUnique({
      where: { userId },
    });
  };
  ```

### Post-Migration Validation

- [ ] **Security Testing**

  ```bash
  # Run RLS validation script
  psql -U {{LINEAR_WORKSPACE}}_app_user -d {{DB_NAME}} < scripts/test-new-table-rls.sql
  ```

- [ ] **Documentation Updates** (MANDATORY)
  - [ ] **UPDATE DATA_DICTIONARY.md** (Single source of truth for AI agents)
    - [ ] Add new table/column definitions with purpose and constraints
    - [ ] Update table count metrics in quick reference
    - [ ] Document RLS policy additions with policy count
    - [ ] Add relationship mappings for new foreign keys
    - [ ] Update "Recent Changes" section with Linear ticket reference
  - [ ] **Update related documentation**
    - [ ] Add table to protected tables list in RLS docs
    - [ ] Update CONTRIBUTING.md if new documentation requirements
    - [ ] Schedule Confluence documentation sync
  - [ ] **Team notification**
    - [ ] Announce schema changes in team channels
    - [ ] Update any affected API documentation

- [ ] **Code Review Requirements**
  - [ ] RLS policies reviewed by security owner
  - [ ] Performance impact assessed
  - [ ] Test coverage confirmed

- [ ] **Production Deployment Verification**
  - [ ] Run: `./scripts/verify-migration-status.sh production`
  - [ ] Verify: Table count matches expectation
  - [ ] Verify: RLS policy count matches expectation
  - [ ] Verify: Specific tables have RLS enabled
  - [ ] Verify: Application health check passes

---

## 📚 Documentation Compliance Requirements

### MANDATORY: Single Source of Truth Maintenance

**ALL database schema changes MUST update the DATA_DICTIONARY.md file immediately.**

This ensures:

- ✅ AI agents have complete context without external tool calls
- ✅ Development teams have current schema reference
- ✅ Documentation remains synchronized with actual database state
- ✅ Code reviews can verify schema against documentation

### Documentation Update Workflow

```bash
# 1. Update schema
npx prisma migrate dev --name add_new_table

# 2. Update documentation (MANDATORY)
# Edit docs/database/DATA_DICTIONARY.md:
# - Add table definition to "Detailed Schema" section
# - Update table count in "Quick Reference"
# - Add RLS policy count if applicable
# - Update "Recent Changes" section with {{TICKET_PREFIX}}-XXX reference

# 3. Commit both schema and docs together
git add prisma/migrations/ docs/database/DATA_DICTIONARY.md
git commit -m "feat(db): add new table with documentation [{{TICKET_PREFIX}}-XXX]"
```

### Documentation Audit Trail

Every schema change MUST include:

1. **Linear ticket reference** in commit message
2. **Purpose documentation** explaining the business need
3. **RLS policy documentation** if user data is involved
4. **Relationship mapping** if foreign keys are added
5. **Migration timestamp** in "Recent Changes" section

### Failure to Update Documentation

**Non-compliance consequences:**

- ❌ PR will be rejected by code review
- ❌ Schema drift between teams
- ❌ AI agents unable to provide accurate database guidance
- ❌ Security review delays
- ❌ Production deployment blocks

---

## 🚨 Common Mistakes to Avoid

### ❌ DON'T: Add user data tables without RLS

```sql
-- WRONG - No RLS protection
CREATE TABLE user_settings (
    user_id VARCHAR(255),
    settings JSONB
);
```

### ✅ DO: Always enable RLS for user data

```sql
-- CORRECT - RLS enabled and configured
CREATE TABLE user_settings (
    user_id VARCHAR(255),
    settings JSONB
);
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings FORCE ROW LEVEL SECURITY;
CREATE POLICY user_settings_isolation ON user_settings
    FOR ALL TO {{DB_USER}}
    USING (user_id = current_setting('app.current_user_id', true));
```

### ❌ DON'T: Forget indexes for RLS columns

```sql
-- WRONG - Missing index will cause performance issues
CREATE POLICY slow_policy ON big_table
    USING (user_id = current_setting('app.current_user_id', true));
```

### ✅ DO: Create indexes for policy columns

```sql
-- CORRECT - Index ensures fast RLS checks
CREATE INDEX big_table_user_id_idx ON big_table(user_id);
CREATE POLICY fast_policy ON big_table
    USING (user_id = current_setting('app.current_user_id', true));
```

---

## 👥 Team Responsibilities

### Database Developer

- Include RLS in initial migration design
- Create appropriate indexes
- Test RLS policies locally
- Document RLS decisions

### Code Reviewer

- Verify RLS policies for new tables
- Check for performance indexes
- Ensure documentation updated
- Validate test coverage

### Security Owner (Scott/ARCHitect)

- Final approval for RLS changes
- Audit policy effectiveness
- Update security documentation
- Train team on RLS requirements

### DevOps

- Deploy RLS policies to production
- Monitor query performance
- Maintain RLS in backups/restores
- Update deployment scripts

---

## 📝 RLS Maintenance Log Template

Create `/scripts/rls-maintenance-YYYY.sql`:

```sql
-- RLS Maintenance Log - YYYY
-- This file tracks all RLS policy changes for audit purposes

-- ============================================================================
-- Date: YYYY-MM-DD
-- Developer: [Name]
-- Linear Ticket: {{TICKET_PREFIX}}-XXX
-- Change Type: [NEW TABLE | UPDATE POLICY | REMOVE TABLE]
-- ============================================================================

-- Table: [table_name]
-- Reason: [Business justification]
-- Data Classification: [USER | ADMIN | SYSTEM | PUBLIC]

-- SQL Changes:
[Paste actual SQL here]

-- Testing performed:
-- [ ] Local RLS validation
-- [ ] Performance testing
-- [ ] Security audit

-- Reviewed by: [Reviewer name]
-- Approved by: [Security owner]
```

---

## 🔄 Quarterly RLS Audit Process

Every quarter, perform these checks:

1. **Policy Inventory**

   ```sql
   -- List all tables without RLS that might need it
   SELECT tablename
   FROM pg_tables
   WHERE schemaname = 'public'
     AND tablename NOT IN (
       SELECT tablename FROM pg_policies
     )
     AND tablename != '_prisma_migrations'
     AND tablename != 'subscriptions_plans';  -- Known exceptions
   ```

2. **Policy Effectiveness**

   ```sql
   -- Test each RLS policy still works
   -- Run scripts/rls-phase4-final-validation.sql
   ```

3. **Performance Review**

   ```sql
   -- Check for missing indexes
   SELECT tablename, policyname, qual
   FROM pg_policies
   WHERE qual LIKE '%user_id%'
     AND NOT EXISTS (
       SELECT 1 FROM pg_indexes
       WHERE tablename = pg_policies.tablename
         AND indexdef LIKE '%user_id%'
     );
   ```

---

## 🚀 Quick Reference Commands

### Add RLS to Existing Table

```bash
# Template for adding RLS to existing table
cat > add_rls_to_table.sql << 'EOF'
-- Enable RLS
ALTER TABLE [table_name] ENABLE ROW LEVEL SECURITY;
ALTER TABLE [table_name] FORCE ROW LEVEL SECURITY;

-- Create policy for superuser
CREATE POLICY [table_name]_isolation ON [table_name]
    FOR ALL TO {{DB_USER}}
    USING (user_id = current_setting('app.current_user_id', true));

-- Create policy for app user
CREATE POLICY [table_name]_app_isolation ON [table_name]
    FOR ALL TO {{LINEAR_WORKSPACE}}_app_user
    USING (user_id = current_setting('app.current_user_id', true));

-- Create index if missing
CREATE INDEX IF NOT EXISTS [table_name]_user_id_idx ON [table_name](user_id);
EOF
```

### Test RLS on New Table

```bash
# Quick test for new table RLS
psql -U {{LINEAR_WORKSPACE}}_app_user -d {{DB_NAME}} << 'EOF'
SET app.current_user_id = 'test_user';
SELECT COUNT(*) as visible_records FROM [table_name];
RESET app.current_user_id;
SELECT COUNT(*) as should_be_zero FROM [table_name];
EOF
```

---

## 📚 Additional Resources

- [Prisma Migration Best Practices](./PRISMA_MIGRATION_BEST_PRACTICES.md) - Embedding RLS in migrations
- [Production Migration Emergency Runbook](./PRODUCTION-MIGRATION-EMERGENCY-RUNBOOK.md) - Manual fallback procedures
- [Migration Verification Tools](../../scripts/MIGRATION_VERIFICATION_TOOLS.md) - Automated validation
- [Production Deployment Guide](./PRODUCTION_MIGRATION_DEPLOYMENT.md) - Automated deployment
- [RLS Implementation Guide](./RLS_IMPLEMENTATION_GUIDE.md) - Core RLS concepts
- [RLS Troubleshooting Guide](./RLS_TROUBLESHOOTING.md) - Debugging RLS issues
- [PostgreSQL RLS Documentation](https://www.postgresql.org/docs/current/ddl-rowsecurity.html) - Official PostgreSQL docs
- [Prisma Schema Reference](https://www.prisma.io/docs/reference/api-reference/prisma-schema-reference) - Prisma documentation

---

## ⚖️ Compliance Statement

This SOP is **mandatory** for all database changes in the {{PROJECT_NAME}} application. Non-compliance may result in:

- Security vulnerabilities
- Data privacy violations
- Failed security audits
- Production incidents

**All team members** working with database schemas are required to follow these procedures.

---

**Document Version**: 2.0
**Last Updated**: 2025-10-06
**Next Review**: Quarterly  
**Owner**: {{ARCHITECT_NAME}} (SAFe ARCHitect)
**Updated**: {{TICKET_PREFIX}}-321 (Production incident learnings - separate RLS files, migrate resolve misuse)
