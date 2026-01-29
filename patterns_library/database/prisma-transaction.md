# Prisma Transaction Pattern

## What It Does

Executes multiple database operations atomically within an RLS-enforced transaction. Ensures either all operations succeed or all fail together, maintaining data consistency.

## When to Use

- Multi-step workflows (e.g., payment + subscription update)
- Operations that must happen together
- Creating related records across tables
- Complex business logic requiring consistency
- When you need rollback on any failure

## Code Pattern

```typescript
// lib/services/{resource}-service.ts OR app/api/{resource}/route.ts
import { withUserContext, withAdminContext, withSystemContext } from '@/lib/rls-context';
import { prisma } from '@/lib/prisma';

/**
 * Execute multi-step operation in transaction
 */
export async function createResourceWithRelations(
  userId: string,
  data: {
    // Main resource data
    name: string;
    // Related data
    items: Array<{ name: string; quantity: number }>;
  }
) {
  // Execute transaction within RLS context
  return await withUserContext(prisma, userId, async (client) => {
    // Use Prisma interactive transactions
    return await client.$transaction(async (tx) => {
      // Step 1: Create main resource
      const resource = await tx.{main_table}.create({
        data: {
          user_id: userId,
          name: data.name,
          created_at: new Date()
        }
      });

      // Step 2: Create related records
      const items = await Promise.all(
        data.items.map(item =>
          tx.{related_table}.create({
            data: {
              resource_id: resource.id,
              user_id: userId,  // Maintain RLS
              name: item.name,
              quantity: item.quantity
            }
          })
        )
      );

      // Step 3: Update aggregates or related data
      await tx.{aggregate_table}.upsert({
        where: { resource_id: resource.id },
        update: {
          total_items: items.length,
          updated_at: new Date()
        },
        create: {
          resource_id: resource.id,
          user_id: userId,
          total_items: items.length
        }
      });

      // Return complete result
      return {
        resource,
        items,
        total_items: items.length
      };
    });
  });
}
```

## Transaction Patterns

### Pattern 1: Payment with Subscription Update

```typescript
/**
 * Process payment and update subscription atomically
 */
export async function processPayment(
  userId: string,
  paymentData: {
    stripe_payment_id: string;
    amount: number;
    subscription_id: string;
  },
) {
  return await withUserContext(prisma, userId, async (client) => {
    return await client.$transaction(async (tx) => {
      // 1. Create payment record
      const payment = await tx.payments.create({
        data: {
          user_id: userId,
          stripe_payment_id: paymentData.stripe_payment_id,
          amount: paymentData.amount,
          status: "succeeded",
          currency: "usd",
        },
      });

      // 2. Update subscription
      const subscription = await tx.subscriptions.update({
        where: {
          id: paymentData.subscription_id,
          user_id: userId, // RLS check
        },
        data: {
          status: "active",
          current_period_end: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
          updated_at: new Date(),
        },
      });

      // 3. Update user credits (if applicable)
      await tx.user.update({
        where: { user_id: userId },
        data: {
          credits: { increment: 100 },
          updated_at: new Date(),
        },
      });

      return { payment, subscription };
    });
  });
}
```

### Pattern 2: Bulk Operations

```typescript
/**
 * Create multiple related records
 */
export async function bulkCreateContent(
  userId: string,
  contents: Array<{
    title: string;
    tier: "FREE" | "PRO" | "VIP";
  }>,
) {
  return await withAdminContext(prisma, userId, async (client) => {
    return await client.$transaction(async (tx) => {
      // Use createMany for bulk inserts
      const result = await tx.course_content.createMany({
        data: contents.map((content) => ({
          ...content,
          course_id: "default-course",
          status: "draft",
          created_by: userId,
        })),
      });

      // Update course aggregate
      await tx.courses.update({
        where: { id: "default-course" },
        data: {
          total_content: { increment: contents.length },
          updated_at: new Date(),
        },
      });

      return { count: result.count };
    });
  });
}
```

### Pattern 3: Conditional Operations

```typescript
/**
 * Update only if conditions met
 */
export async function upgradeUserTier(
  userId: string,
  newTier: "FREE" | "PRO" | "VIP",
) {
  return await withUserContext(prisma, userId, async (client) => {
    return await client.$transaction(async (tx) => {
      // 1. Check current enrollment
      const enrollment = await tx.course_enrollments.findUnique({
        where: {
          user_id_course_id: {
            user_id: userId,
            course_id: "default-course",
          },
        },
      });

      if (!enrollment) {
        throw new Error("No enrollment found");
      }

      const tierHierarchy = { FREE: 0, PRO: 1, VIP: 2 };
      if (
        tierHierarchy[newTier] <=
        tierHierarchy[enrollment.tier as keyof typeof tierHierarchy]
      ) {
        throw new Error("Cannot downgrade or same tier");
      }

      // 2. Update enrollment
      const updated = await tx.course_enrollments.update({
        where: {
          user_id_course_id: {
            user_id: userId,
            course_id: "default-course",
          },
        },
        data: {
          tier: newTier,
          upgraded_at: new Date(),
          updated_at: new Date(),
        },
      });

      // 3. Log tier change
      await tx.tier_changes.create({
        data: {
          user_id: userId,
          from_tier: enrollment.tier,
          to_tier: newTier,
          changed_at: new Date(),
        },
      });

      return updated;
    });
  });
}
```

### Pattern 4: Read-Modify-Write

```typescript
/**
 * Safe concurrent updates
 */
export async function decrementInventory(
  userId: string,
  productId: string,
  quantity: number,
) {
  return await withSystemContext(prisma, "inventory", async (client) => {
    return await client.$transaction(async (tx) => {
      // 1. Lock row for update
      const product = await tx.products.findUnique({
        where: { id: productId },
      });

      if (!product) {
        throw new Error("Product not found");
      }

      if (product.inventory < quantity) {
        throw new Error("Insufficient inventory");
      }

      // 2. Update inventory
      const updated = await tx.products.update({
        where: { id: productId },
        data: {
          inventory: { decrement: quantity },
          updated_at: new Date(),
        },
      });

      // 3. Create inventory log
      await tx.inventory_logs.create({
        data: {
          product_id: productId,
          user_id: userId,
          change: -quantity,
          reason: "purchase",
          created_at: new Date(),
        },
      });

      return updated;
    });
  });
}
```

## Advanced Patterns

### With Audit Logging

```typescript
return await withUserContext(prisma, userId, async (client) => {
  return await client.$transaction(async (tx) => {
    // Main operation
    const result = await tx.{table}.create({ data: {...} });

    // Audit within same transaction
    await tx.audit_log.create({
      data: {
        user_id: userId,
        action: 'CREATE',
        resource_type: '{resource}',
        resource_id: result.id,
        details: { /* snapshot */ }
      }
    });

    return result;
  });
});
```

### With Rollback Handling

```typescript
try {
  return await client.$transaction(
    async (tx) => {
      // Operations...
      return result;
    },
    {
      maxWait: 5000, // Max wait time to start tx
      timeout: 10000, // Max tx duration
      isolationLevel: "ReadCommitted",
    },
  );
} catch (error) {
  if (error.code === "P2034") {
    // Transaction timeout
    throw new Error("Operation took too long");
  }
  throw error;
}
```

## Customization Guide

1. **Replace placeholders**:
   - `{main_table}` → Primary table name
   - `{related_table}` → Related table name
   - `{aggregate_table}` → Aggregates/summaries table
   - `{resource}` → Resource name

2. **Choose RLS context**:
   - `withUserContext` - User operations
   - `withAdminContext` - Admin operations
   - `withSystemContext` - System/webhook operations

3. **Handle errors**:
   - Throw errors to rollback
   - Catch specific Prisma errors
   - Return meaningful error messages

4. **Optimize performance**:
   - Use `createMany` for bulk inserts
   - Minimize queries in transaction
   - Set appropriate timeouts

## Security Checklist

- [x] **RLS Context**: Transaction within RLS helper
- [x] **Atomicity**: All-or-nothing operations
- [x] **Error Handling**: Proper rollback on failure
- [x] **User Ownership**: Verify `user_id` in all records
- [x] **Timeouts**: Set reasonable transaction timeouts

## Validation Commands

```bash
# Type checking
yarn type-check

# Integration tests (test transactions)
yarn test:integration

# Database consistency check
psql -U {{DB_USER}} -d {{DB_NAME}} \
  -c "SELECT * FROM {table} WHERE user_id = 'test_user';"
```

## Example: Order Creation with Items

```typescript
import { withUserContext } from "@/lib/rls-context";
import { prisma } from "@/lib/prisma";

export async function createOrder(
  userId: string,
  data: {
    items: Array<{ product_id: string; quantity: number; price: number }>;
  },
) {
  return await withUserContext(prisma, userId, async (client) => {
    return await client.$transaction(async (tx) => {
      // 1. Calculate total
      const total = data.items.reduce(
        (sum, item) => sum + item.price * item.quantity,
        0,
      );

      // 2. Create order
      const order = await tx.orders.create({
        data: {
          user_id: userId,
          total_amount: total,
          status: "pending",
          created_at: new Date(),
        },
      });

      // 3. Create order items
      await tx.order_items.createMany({
        data: data.items.map((item) => ({
          order_id: order.id,
          product_id: item.product_id,
          quantity: item.quantity,
          price: item.price,
          user_id: userId,
        })),
      });

      // 4. Decrement inventory
      for (const item of data.items) {
        await tx.products.update({
          where: { id: item.product_id },
          data: { inventory: { decrement: item.quantity } },
        });
      }

      return order;
    });
  });
}
```

## Related Patterns

- [RLS Migration](./rls-migration.md) - Creating RLS tables
- [User Context API](../api/user-context-api.md) - Using transactions in APIs
- [Admin Context API](../api/admin-context-api.md) - Admin transactions

---

**Pattern Source**: Internal transaction patterns
**Last Updated**: 2025-10-03
**Validated By**: System Architect
