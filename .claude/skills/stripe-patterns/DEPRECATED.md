# DEPRECATED: stripe-patterns

> **This skill has been deprecated and replaced by `payment-patterns`.**

## Replacement

The `stripe-patterns` skill from the original WTFB harness has been replaced with `payment-patterns` in the ConTStack adaptation.

**New location:** `.claude/skills/payment-patterns/SKILL.md`

## Why This Changed

ConTStack uses **Polar** instead of **Stripe** for payment processing:

| Aspect | WTFB Original | ConTStack Adaptation |
|--------|---------------|----------------------|
| Provider | Stripe | Polar |
| SDK | `@stripe/stripe-js` | `@polar-sh/sdk` |
| Webhooks | Stripe webhook events | Polar webhook events |
| Checkout | Stripe Checkout | Polar Checkout |

## Key Differences

1. **SDK Import**: Use `@polar-sh/sdk` instead of Stripe SDK
2. **Webhook Verification**: Use `validateEvent` from `@polar-sh/sdk/webhooks`
3. **Environment Variables**:
   - `POLAR_ACCESS_TOKEN` replaces `STRIPE_SECRET_KEY`
   - `POLAR_WEBHOOK_SECRET` replaces `STRIPE_WEBHOOK_SECRET`
4. **Event Types**: Polar uses different event naming (e.g., `subscription.created` vs Stripe's `customer.subscription.created`)

## Migration Checklist

If you're migrating existing Stripe code:

- [ ] Replace Stripe SDK imports with Polar SDK
- [ ] Update webhook signature verification
- [ ] Map Stripe event types to Polar event types
- [ ] Update environment variables
- [ ] Update checkout session creation code
- [ ] Test all payment flows in Polar sandbox

## Cleanup Instructions

Once migration is complete, you can remove this directory:

```bash
rm -rf .claude/skills/stripe-patterns
```

## Reference

See the new payment patterns skill:
- **SKILL.md**: `.claude/skills/payment-patterns/SKILL.md`
- **README.md**: `.claude/skills/payment-patterns/README.md`

For the full tech stack mapping, see: `ADAPTATION.md`
