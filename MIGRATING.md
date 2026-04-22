# Migration guide

This document provides guidance on migrating to newer versions of the Rokt Flutter SDK.

## Migrating from versions < 5.0.0

### API Method Changes

- `execute()` was renamed and consolidated as `selectPlacements()`.
- Execute-style callbacks were removed:
  - `onLoad`
  - `onUnLoad`
  - `onShouldShowLoadingIndicator`
  - `onShouldHideLoadingIndicator`
  - native embedded size callback path (`onEmbeddedSizeChange`)
- `setLoggingEnabled()` was removed.
- `onInitComplete`-style callback flow is superseded by events.
- Integrations should now rely on the `RoktEvents` stream (for example: `InitComplete`, `ShowLoadingIndicator`, `PlacementReady`, `PlacementFailure`, `EmbeddedSizeChanged`).

### Example Migration

**Before:**

```dart
RoktSdk.initialize('YOUR_TAG_ID', appVersion: '1.0.0');

RoktSdk.setLoggingEnabled(enable: true);

RoktSdk.execute(
  viewName: "checkout",
  attributes: {"email": "user@example.com"},
  onLoad: () {},
  onUnLoad: () {},
  onShouldShowLoadingIndicator: () {},
  onShouldHideLoadingIndicator: () {},
);
```

**After:**

```dart
const EventChannel roktEventChannel = EventChannel('RoktEvents');

RoktSdk.initialize('YOUR_TAG_ID', appVersion: '1.0.0');

roktEventChannel.receiveBroadcastStream().listen((dynamic event) {
  // Handle InitComplete, ShowLoadingIndicator, PlacementReady,
  // PlacementFailure, EmbeddedSizeChanged, etc.
});

RoktSdk.selectPlacements(
  viewName: "checkout",
  attributes: {"email": "user@example.com"},
);
```

### Shoppable Ads (New in 5.0.0, iOS only)

Shoppable Ads allow users to make instant purchases directly from ad placements. This feature is currently available on iOS only.

#### Payment Extension Registration

Before displaying shoppable ads, register a payment extension. The host app must:

1. Add the native payment extension dependency to your iOS `Podfile`:

```ruby
pod 'RoktStripePaymentExtension', '~> 0.1'
```

2. Set the payment extension factory in your `AppDelegate.swift`:

```swift
import RoktStripePaymentExtension
import rokt_sdk

// In application(_:didFinishLaunchingWithOptions:), after GeneratedPluginRegistrant.register:
SwiftRoktSdkPlugin.paymentExtensionFactory = { type, config in
    switch type {
    case "stripe":
        guard let merchantId = config["applePayMerchantId"] else { return nil }
        return RoktStripePaymentExtension(
            applePayMerchantId: merchantId,
            countryCode: config["countryCode"] ?? "US"
        )
    default:
        return nil
    }
}
```

3. Register from Dart (call once after `initialize`, before `selectShoppableAds`):

```dart
RoktSdk.registerPaymentExtension(
  extensionType: 'stripe',
  config: {
    'stripeKey': 'YOUR_STRIPE_PUBLISHABLE_KEY',
    'applePayMerchantId': 'merchant.com.yourapp.rokt',
  },
);
```

#### Displaying Shoppable Ads

```dart
RoktSdk.selectShoppableAds(
  viewName: "ConfirmationPage",
  attributes: {
    "email": "user@example.com",
    "firstname": "John",
    "lastname": "Doe",
    "confirmationref": "ORDER-12345",
  },
);
```

#### Shoppable Ads Events

Shoppable Ads lifecycle events are delivered via the `RoktEvents` EventChannel:

| Event                              | Description                                  |
| ---------------------------------- | -------------------------------------------- |
| `CartItemInstantPurchaseInitiated` | User tapped "Buy", before payment processing |
| `CartItemInstantPurchase`          | Purchase completed successfully              |
| `CartItemInstantPurchaseFailure`   | Purchase failed                              |
| `InstantPurchaseDismissal`         | User dismissed the instant purchase overlay  |
| `CartItemDevicePay`                | Device payment (e.g. Apple Pay) triggered    |

#### Purchase Finalization

After a purchase completes, notify the SDK:

```dart
RoktSdk.purchaseFinalized(
  placementId: "placement-id",
  catalogItemId: "catalog-item-id",
  success: true,
);
```

### Platform Availability

| Feature                    | iOS   | Android           |
| -------------------------- | ----- | ----------------- |
| `selectPlacements`         | 5.0.0 | 5.0.0             |
| `selectShoppableAds`       | 5.0.0 | Not yet supported |
| `registerPaymentExtension` | 5.0.0 | Not yet supported |
| `purchaseFinalized`        | 5.0.0 | 5.0.0             |

## Migrating from versions < 4.8.x

Migration steps were not provided prior to version 4.8.x. If you're upgrading from older versions, follow the [initial integration steps](https://docs.rokt.com/developers/integration-guides/flutter/how-to/integrating-and-initializing).
