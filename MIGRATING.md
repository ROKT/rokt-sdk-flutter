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

## Migrating from versions < 4.8.x

Migration steps were not provided prior to version 4.8.x. If you're upgrading from older versions, follow the [initial integration steps](https://docs.rokt.com/developers/integration-guides/flutter/how-to/integrating-and-initializing).
