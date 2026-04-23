# rokt_sdk_example

Rokt SDK Example application is a sample app built to showcase Rokt SDK functionality including Select Placements and Shoppable Ads (iOS only).

## Features

- **Initialize** the Rokt SDK with a Tag ID
- **Select Placements** — display overlay or embedded placements with customer attributes
- **Shoppable Ads (iOS only)** — register a payment extension and display shoppable ad placements
- **RoktEvents** — listen for placement and shoppable lifecycle events via an EventChannel

## Platform-Specific Defaults

The example app automatically loads platform-appropriate default attributes:

- **iOS** — includes shoppable ads attributes (shipping address, payment type, confirmation ref, etc.)
- **Android** — includes basic attributes (email, name, mobile, postcode, country)

You can edit the attributes JSON directly in the text field at runtime.

## How to Run Locally

1. Open the project in the IDE of your choice
2. Run the following commands:

```shell
flutter clean
flutter pub get
flutter run
```

### iOS Setup (Shoppable Ads)

The example app's `AppDelegate.swift` registers a `paymentExtensionFactory` for Stripe Apple Pay. To test shoppable ads:

1. Ensure you have a valid Apple Pay merchant ID in the entitlements
2. Enter a Stripe publishable key in the Stripe Key field and tap **Register**
3. Tap **Shoppable Ads** to display a shoppable placement

### Running Integration Tests

```shell
cd example
flutter test integration_test/app_test.dart
```
