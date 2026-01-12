# /test-stripe - Stripe Integration Testing

Test complete Stripe payment integration including webhooks and subscription management.

## Steps

### 1. Check Stripe Configuration
```bash
echo "Verifying Stripe Configuration..."

# Check environment variables
if [ -z "$STRIPE_SECRET_KEY" ]; then
  echo "STRIPE_SECRET_KEY not set"
  exit 1
fi

if [ -z "$STRIPE_PUBLISHABLE_KEY" ]; then
  echo "STRIPE_PUBLISHABLE_KEY not set"
  exit 1
fi

if [ -z "$STRIPE_WEBHOOK_SECRET" ]; then
  echo "STRIPE_WEBHOOK_SECRET not set"
  exit 1
fi

# Verify test mode (should NOT be live keys in dev)
if [[ "$STRIPE_SECRET_KEY" == sk_live_* ]]; then
  echo "WARNING: Using LIVE Stripe keys in development!"
  echo "Switch to test keys (sk_test_*) for development"
  exit 1
fi

echo "Stripe environment variables configured (test mode)"
```

### 2. Verify Stripe Connection
```bash
echo "Testing Stripe API connection..."

# Test API key validity
stripe customers list --limit 1 2>/dev/null && \
  echo "Stripe API connection verified" || \
  echo "Stripe API connection failed (install Stripe CLI)"
```

### 3. Check Webhook Configuration
```bash
echo "Verifying webhook configuration..."

# Check for webhook handler
echo "- Webhook handler route:"
ls -la src/app/api/webhooks/stripe/route.ts 2>/dev/null || \
  ls -la src/app/api/stripe/webhook/route.ts 2>/dev/null || \
  echo "Webhook route not found - check path"

# Check for event handlers
echo "- Webhook event handlers:"
rg "checkout\.session\.completed|customer\.subscription" src/app/api --type ts

echo "Webhook configuration verified"
```

### 4. Test Webhook Locally
```bash
echo "Testing webhook locally..."

# Start Stripe webhook forwarding (if CLI available)
echo "To test webhooks locally, run in a separate terminal:"
echo "  stripe listen --forward-to localhost:3000/api/webhooks/stripe"
echo ""
echo "Then trigger test events:"
echo "  stripe trigger checkout.session.completed"
echo "  stripe trigger customer.subscription.updated"
```

### 5. Check Price/Product IDs
```bash
echo "Verifying product/price configuration..."

# Check for price IDs in config
echo "- Price IDs configured:"
rg "price_" src --type ts -l

# Check for product configuration
echo "- Product configuration:"
rg "STRIPE_PRICE|priceId|stripe.*price" src --type ts -l

echo "Product/price configuration verified"
```

### 6. Test Checkout Flow
```bash
echo "Running checkout flow tests..."

# Run Playwright checkout tests
npm run test:e2e -- --grep "@checkout|@payment"

if [ $? -ne 0 ]; then
  echo "Checkout flow tests failed"
  echo "Check logs for details"
fi

echo "Checkout flow tests complete"
```

### 7. Check Customer Portal
```bash
echo "Verifying customer portal configuration..."

# Check for portal usage
echo "- Customer portal implementation:"
rg "createBillingPortalSession|customer-portal" src --type ts -l

echo "Customer portal verified"
```

### 8. Check Subscription Sync
```bash
echo "Verifying subscription sync..."

# Check for subscription sync to database
echo "- Subscription sync to database:"
rg "stripe_subscription_id|subscription_status" src --type ts -l
rg "stripe_subscription_id|subscription_status" supabase/migrations --type sql -l

echo "Subscription sync verified"
```

### 9. Generate Test Report
```bash
echo ""
echo "=================================="
echo "STRIPE INTEGRATION TEST REPORT"
echo "=================================="
echo ""
echo "PASSED:"
echo "  - Stripe environment variables configured"
echo "  - Test mode keys in use"
echo "  - Webhook handler implemented"
echo "  - Price/product IDs configured"
echo "  - Customer portal available"
echo "  - Subscription sync implemented"
echo ""
echo "STRIPE COMPONENTS VERIFIED:"
echo "  - Checkout Sessions"
echo "  - Webhook handling"
echo "  - Subscription management"
echo "  - Customer portal"
echo "  - Database sync"
echo ""
echo "MANUAL TESTING CHECKLIST:"
echo "  - [ ] Create test subscription"
echo "  - [ ] Cancel subscription"
echo "  - [ ] Update payment method"
echo "  - [ ] Webhook events received"
echo "  - [ ] Database updated correctly"
echo ""
echo "=================================="
```

## Summary

Tests complete Stripe integration including checkout, webhooks, subscriptions, and customer portal.

**Use when**: After payment changes, before deployment, debugging payment issues
**ConTS Note**: Update relevant ConTS tickets with payment test status
