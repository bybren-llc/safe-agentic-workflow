# Webhook Handler Pattern

## What It Does

Creates a secure webhook endpoint for processing external service events (Stripe, Clerk, third-party APIs). Validates signatures, processes events, and updates database with system-level RLS context.

## When to Use

- Stripe payment webhooks
- Clerk authentication webhooks
- Third-party service notifications
- Asynchronous event processing
- System-level data updates

## Code Pattern

```typescript
// app/api/webhooks/{service}/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { headers } from 'next/headers';
import { withSystemContext } from '@/lib/rls-context';
import { prisma } from '@/lib/prisma';

/**
 * POST /api/webhooks/{service} - Process webhook events
 */
export async function POST(req: NextRequest) {
  try {
    // 1. Verify webhook signature
    const body = await req.text();
    const signature = headers().get('{signature-header}');

    if (!signature) {
      console.error('Missing webhook signature');
      return NextResponse.json(
        { error: 'Missing signature' },
        { status: 400 }
      );
    }

    if (!process.env.{{SERVICE}}_WEBHOOK_SECRET) {
      console.error('Webhook secret not configured');
      return NextResponse.json(
        { error: 'Webhook configuration error' },
        { status: 500 }
      );
    }

    // 2. Construct and verify event
    const event = {service_sdk}.webhooks.constructEvent(
      body,
      signature,
      process.env.{{SERVICE}}_WEBHOOK_SECRET
    );

    // 3. Process event based on type
    const result = await processWebhookEvent(event);

    // 4. Success response
    return NextResponse.json({
      received: true,
      event_type: event.type,
      event_id: event.id
    });

  } catch (error) {
    console.error('Webhook processing error:', error);

    // Signature verification failures
    if (error instanceof Error && error.message.includes('signature')) {
      return NextResponse.json(
        { error: 'Invalid signature' },
        { status: 400 }
      );
    }

    return NextResponse.json(
      { error: 'Webhook processing failed' },
      { status: 500 }
    );
  }
}

/**
 * Process webhook event by type
 */
async function processWebhookEvent(event: {EventType}): Promise<any> {
  switch (event.type) {
    case '{event.type.created}':
      return await handleCreatedEvent(event);

    case '{event.type.updated}':
      return await handleUpdatedEvent(event);

    case '{event.type.deleted}':
      return await handleDeletedEvent(event);

    default:
      console.log(`Unhandled event type: ${event.type}`);
      return { status: 'unhandled', eventType: event.type };
  }
}

/**
 * Handle created event
 */
async function handleCreatedEvent(event: {EventType}) {
  const data = event.data.object as {DataType};

  // Process with system-level RLS context
  const result = await withSystemContext(
    prisma,
    'webhook_{service}',
    async (client) => {
      // 1. Create or update database record
      const record = await client.{table_name}.upsert({
        where: { external_id: data.id },
        update: {
          status: data.status,
          metadata: data.metadata,
          updated_at: new Date()
        },
        create: {
          external_id: data.id,
          status: data.status,
          metadata: data.metadata,
          // ... other fields
        }
      });

      // 2. Optional: Trigger dependent updates
      if (data.{related_field}) {
        await client.{related_table}.update({
          where: { id: data.{related_field} },
          data: { /* updates */ }
        });
      }

      // 3. Log webhook event for audit
      await client.webhook_events.create({
        data: {
          event_type: event.type,
          event_id: event.id,
          service: '{service}',
          processed: true,
          processed_at: new Date(),
          event_data: event.data as any
        }
      });

      return record;
    }
  );

  return { status: 'processed', record_id: result.id };
}

/**
 * Handle updated event
 */
async function handleUpdatedEvent(event: {EventType}) {
  const data = event.data.object as {DataType};

  const result = await withSystemContext(
    prisma,
    'webhook_{service}',
    async (client) => {
      return client.{table_name}.update({
        where: { external_id: data.id },
        data: {
          status: data.status,
          updated_at: new Date()
        }
      });
    }
  );

  return { status: 'updated', record_id: result.id };
}

/**
 * Handle deleted event
 */
async function handleDeletedEvent(event: {EventType}) {
  const data = event.data.object as {DataType};

  const result = await withSystemContext(
    prisma,
    'webhook_{service}',
    async (client) => {
      return client.{table_name}.update({
        where: { external_id: data.id },
        data: {
          status: 'deleted',
          deleted_at: new Date()
        }
      });
    }
  );

  return { status: 'deleted', record_id: result.id };
}
```

## Customization Guide

1. **Replace placeholders**:
   - `{service}` → Service name (e.g., `stripe`, `clerk`)
   - `{{SERVICE}}` → Uppercase for env vars (e.g., `STRIPE`, `CLERK`)
   - `{signature-header}` → Header name (e.g., `stripe-signature`)
   - `{service_sdk}` → SDK variable (e.g., `stripe`, `clerkClient`)
   - `{EventType}` → SDK event type
   - `{DataType}` → Event data type
   - `{table_name}` → Database table

2. **Update event handlers**:
   - Add event types you need to handle
   - Implement business logic for each event
   - Handle related data updates

3. **Add error recovery**:
   - Implement retry logic if needed
   - Log failures for manual intervention
   - Send alerts for critical failures

4. **Security considerations**:
   - Always verify signatures
   - Use system RLS context (not user context)
   - Log all webhook events for audit

## Security Checklist

- [x] **Signature Verification**: Always verify webhook signatures
- [x] **System Context**: Use `withSystemContext()` for database ops
- [x] **Env Validation**: Check webhook secret exists
- [x] **Error Logging**: Log failures with context
- [x] **Audit Trail**: Store webhook events in database
- [x] **Idempotency**: Handle duplicate events gracefully

## Validation Commands

```bash
# Type checking
yarn type-check

# Linting
yarn lint

# Integration tests
yarn test:integration

# Manual webhook test (if SDK provides)
{service} webhooks test --endpoint http://localhost:3000/api/webhooks/{service}
```

## Example: Stripe Payment Webhook

```typescript
// app/api/webhooks/stripe/route.ts
import { NextRequest, NextResponse } from "next/server";
import { headers } from "next/headers";
import Stripe from "stripe";
import { withSystemContext } from "@/lib/rls-context";
import { prisma } from "@/lib/prisma";

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: "2024-04-10",
});

export async function POST(req: NextRequest) {
  try {
    const body = await req.text();
    const signature = headers().get("stripe-signature")!;

    const event = stripe.webhooks.constructEvent(
      body,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!,
    );

    if (event.type === "payment_intent.succeeded") {
      const paymentIntent = event.data.object as Stripe.PaymentIntent;

      await withSystemContext(prisma, "webhook_stripe", async (client) => {
        await client.payments.create({
          data: {
            stripe_payment_id: paymentIntent.id,
            user_id: paymentIntent.metadata.user_id,
            amount: paymentIntent.amount,
            currency: paymentIntent.currency,
            status: "succeeded",
          },
        });
      });
    }

    return NextResponse.json({ received: true });
  } catch (error) {
    console.error("Stripe webhook error:", error);
    return NextResponse.json(
      { error: "Webhook processing failed" },
      { status: 400 },
    );
  }
}
```

## Related Patterns

- [User Context API](./user-context-api.md) - For user operations
- [Admin Context API](./admin-context-api.md) - For admin operations
- [API Integration Test](../testing/api-integration-test.md) - Testing webhooks

---

**Pattern Source**: `app/api/payments/webhook/route.ts`
**Last Updated**: 2025-10-03
**Validated By**: System Architect
