---
name: payment-patterns
description: Guide safe and consistent Polar payment integration. Routes to existing payment patterns and provides evidence templates for testing.
---

# Payment Patterns (Polar)

## Purpose
Guide safe and consistent Polar payment integration for ConTStack subscriptions and checkouts.

## When to Use
- Creating checkout flows
- Implementing payment webhooks
- Managing subscriptions
- Testing payment flows
- Handling refunds/credits

## Canonical Locations

| Component | Path |
|-----------|------|
| Configuration | `lib/polar-config.ts` |
| Checkout | `app/api/payments/checkout/route.ts` |
| Webhooks | `app/api/payments/webhook/route.ts` |
| Subscription helpers | `utils/data/subscriptions/` |
| Payment utilities | `utils/data/payments/` |

## Test Mode Checklist (MANDATORY)

Before ANY payment work:

- [ ] Using sandbox/test access token (not production)
- [ ] Webhook URL configured for test environment
- [ ] Test customer account created
- [ ] Webhook signature validation enabled

## Webhook Signature Verification

**ALWAYS** verify webhook signatures. Never trust unverified payloads.

```typescript
import { validateEvent } from '@polar-sh/sdk/webhooks';

export async function POST(request: Request) {
  const payload = await request.text();
  const signature = request.headers.get('webhook-signature');
  
  if (!signature) {
    return new Response('Missing signature', { status: 401 });
  }
  
  try {
    const event = validateEvent(
      payload, 
      signature, 
      process.env.POLAR_WEBHOOK_SECRET!
    );
    
    switch (event.type) {
      case 'subscription.created':
        await handleSubscriptionCreated(event.data);
        break;
      case 'subscription.updated':
        await handleSubscriptionUpdated(event.data);
        break;
      case 'subscription.canceled':
        await handleSubscriptionCanceled(event.data);
        break;
      case 'order.created':
        await handleOrderCreated(event.data);
        break;
    }
    
    return new Response('OK', { status: 200 });
  } catch (error) {
    console.error('Webhook verification failed:', error);
    return new Response('Invalid signature', { status: 401 });
  }
}
```

## Checkout Session Pattern

```typescript
import { Polar } from '@polar-sh/sdk';

const polar = new Polar({ 
  accessToken: process.env.POLAR_ACCESS_TOKEN! 
});

export async function createCheckout(
  productId: string,
  customerEmail: string,
  organizationId: string
) {
  const checkout = await polar.checkouts.create({
    productId,
    successUrl: `${process.env.NEXT_PUBLIC_APP_URL}/checkout/success`,
    customerEmail,
    metadata: {
      organizationId, // CRITICAL: For multi-tenant tracking
    },
  });
  
  return checkout.url;
}
```

## Idempotency Checklist

Payment operations MUST be idempotent:

- [ ] Store webhook event IDs in database
- [ ] Check for duplicate events before processing
- [ ] Use database transactions for state changes
- [ ] Always return 200 OK after successful processing (even for duplicates)

```typescript
async function handleWebhookEvent(event: PolarEvent) {
  // Check for duplicate
  const existing = await ctx.db
    .query("webhookEvents")
    .withIndex("by_eventId", q => q.eq("eventId", event.id))
    .first();
    
  if (existing) {
    console.log(`Duplicate event ${event.id}, skipping`);
    return; // Still return 200 OK
  }
  
  // Store event first (idempotency key)
  await ctx.db.insert("webhookEvents", {
    eventId: event.id,
    type: event.type,
    processedAt: Date.now(),
  });
  
  // Then process
  await processEvent(event);
}
```

## Multi-Tenant Integration

**CRITICAL**: Always associate payments with organizations.

```typescript
// When creating checkout
metadata: {
  organizationId: user.organizationId,
  userId: user._id,
}

// When processing webhook
const { organizationId } = event.data.metadata;
await ctx.db.insert("subscriptions", {
  organizationId, // Required for multi-tenant isolation
  polarSubscriptionId: event.data.id,
  status: event.data.status,
  // ...
});
```

## Evidence Checklist (Before PR)

- [ ] Test mode verification confirmed
- [ ] Webhook signature validation tested
- [ ] Idempotency tested (send same event twice)
- [ ] Success flow tested end-to-end
- [ ] Failure/cancellation flow tested
- [ ] Multi-tenant isolation verified
- [ ] Subscription status synced to Convex

## Environment Variables

```bash
# Required
POLAR_ACCESS_TOKEN=polar_at_xxx  # Sandbox for dev
POLAR_WEBHOOK_SECRET=whsec_xxx

# Production (different values)
# POLAR_ACCESS_TOKEN=polar_at_live_xxx
# POLAR_WEBHOOK_SECRET=whsec_live_xxx
```

## Forbidden Patterns

- **NEVER** use production keys in development
- **NEVER** skip webhook signature verification
- **NEVER** process payments without organization context
- **NEVER** store raw card data (Polar handles this)
