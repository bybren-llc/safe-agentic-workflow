---
name: stripe-patterns
description: >
  Stripe payment integration patterns for checkout flows, webhooks, and
  subscriptions. Use when implementing payment flows, handling Stripe webhooks,
  working with subscriptions or invoices, testing payment functionality, or
  handling refunds and disputes. Do NOT use for non-payment API routes.
---

# Stripe Patterns Skill

> **TEMPLATE**: This skill uses `{{PLACEHOLDER}}` tokens. Replace with your project values before use.

## Purpose

Guide safe and consistent Stripe integration. Routes to existing payment patterns and provides evidence templates for testing.

## When This Skill Applies

- Creating or modifying checkout flows
- Implementing Stripe webhooks
- Working with subscriptions or invoices
- Testing payment functionality
- Handling refunds or disputes

## Canonical Code References

### Configuration

- **Stripe Client Factory**: `{{STRIPE_CONFIG_PATH}}`
  - Use factory function for consistent API version
  - Never hardcode API keys

### API Routes

- **Checkout Session**: `{{CHECKOUT_ROUTE_PATH}}`
- **Webhook Handler**: `{{WEBHOOK_ROUTE_PATH}}`

### Helpers

- **Payment Helpers**: `{{PAYMENT_HELPERS_PATH}}` (use RLS context)
- **Subscription Helpers**: `{{SUBSCRIPTION_HELPERS_PATH}}`
- **Invoice Helpers**: `{{INVOICE_HELPERS_PATH}}`

## Critical Rules

### Test Mode Safety Checklist

Before ANY payment work:

- [ ] Verify `STRIPE_SECRET_KEY` starts with `sk_test_`
- [ ] Confirm test webhook secret (`whsec_...` from Stripe CLI)
- [ ] Use test card numbers only (4242...)
- [ ] Never use production keys in development

### Idempotency Checklist

For webhook handlers:

- [ ] Store event ID before processing
- [ ] Check for duplicate events
- [ ] Use database transactions
- [ ] Return 200 OK even on idempotency skip

```typescript
// Idempotent webhook pattern
await withSystemContext(db, "webhook", async (client) => {
  // Check if already processed
  const existing = await client.webhook_events.findUnique({
    where: { stripe_event_id: event.id },
  });
  if (existing) {
    console.log(`Skipping duplicate event: ${event.id}`);
    return;
  }

  // Process and record
  await client.webhook_events.create({
    data: {
      stripe_event_id: event.id,
      event_type: event.type,
      processed_at: new Date(),
    },
  });
});
```

### Webhook Signature Verification

**ALWAYS** verify webhook signatures:

```typescript
import { stripe } from "{{STRIPE_CONFIG_PATH}}";

const signature = request.headers.get("stripe-signature");
const event = stripe.webhooks.constructEvent(
  body,
  signature,
  process.env.STRIPE_WEBHOOK_SECRET,
);
```

## Common Patterns

### Create Checkout Session

```typescript
import { createStripeClient } from "{{STRIPE_CONFIG_PATH}}";
import { withUserContext } from "{{RLS_IMPORT}}";

export async function createCheckout(userId: string, priceId: string) {
  const stripe = createStripeClient();

  const session = await stripe.checkout.sessions.create({
    mode: "subscription",
    line_items: [{ price: priceId, quantity: 1 }],
    success_url: `${process.env.{{APP_URL_ENV}}}/success?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${process.env.{{APP_URL_ENV}}}/pricing`,
    metadata: { userId },
  });

  return session;
}
```

### Handle Subscription Events

```typescript
// Webhook event types to handle
const SUBSCRIPTION_EVENTS = [
  "customer.subscription.created",
  "customer.subscription.updated",
  "customer.subscription.deleted",
  "invoice.payment_succeeded",
  "invoice.payment_failed",
];
```

## Local Testing

```bash
# Forward webhooks to local dev server
stripe listen --forward-to localhost:{{DEV_PORT}}/api/v1/webhooks/stripe

# Trigger test events
stripe trigger checkout.session.completed
stripe trigger invoice.payment_succeeded
stripe trigger customer.subscription.deleted
```

## Evidence Template for Ticket System

When completing payment work, attach this evidence:

```markdown
**Payment Testing Evidence**

- [ ] Test mode verified (`sk_test_` key)
- [ ] Webhook signature verification tested
- [ ] Idempotency tested (duplicate event handling)
- [ ] Success flow tested (card 4242...)
- [ ] Failure flow tested (card 4000000000000002)
- [ ] Subscription lifecycle tested (create/update/cancel)

**Test Results:**
- Checkout session: [session_id]
- Webhook events processed: [count]
- Subscription status: [active/cancelled]
```

## Authoritative References

- **Stripe Config**: `{{STRIPE_CONFIG_PATH}}`
- **Webhook Route**: `{{WEBHOOK_ROUTE_PATH}}`
- **Payment Tests**: `{{PAYMENT_TESTS_PATH}}`
- **Stripe Docs**: https://stripe.com/docs
