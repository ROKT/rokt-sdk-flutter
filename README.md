# Rokt Flutter SDK

The Rokt Flutter SDK enables you to integrate Rokt into your native mobile apps to drive more value from—and for—your customers. The SDK supports both iOS and Android platforms through a unified Flutter interface.

The Rokt SDK for Flutter applications can be used by Rokt partners to display overlay or embedded placements, or by Rokt advertisers to record
conversions for campaigns.

| Environment | Build                                                                                                                                                                          |
| ----------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| release     | [![Build](https://github.com/ROKT/rokt-sdk-flutter/actions/workflows/pull_request.yml/badge.svg)](https://github.com/ROKT/rokt-sdk-flutter/actions/workflows/pull_request.yml) |

## Resident Experts

- Thomson Thomas - <thomson.thomas@rokt.com>
- James Newman - <james.newman@rokt.com>

## Service Architecture

The Rokt Flutter SDK is structured as a Flutter plugin that provides a Dart interface to platform-specific native SDKs:

- **Dart Interface Layer**: Located in the `lib` directory, provides the API surface for Flutter applications
- **Platform-Specific Implementations**:
  - `android` directory contains the Kotlin implementation using the native Android Rokt SDK (`com.rokt:roktsdk`)
  - `ios` directory contains the Swift implementation using the native iOS Rokt SDK (`Rokt-Widget`)
- **Example Application**: Located in the `example` directory, demonstrates how to implement the SDK

The SDK follows a bridge pattern to connect the Flutter framework with native platform capabilities, enabling seamless integration with Rokt's services.

## Local Development Setup

### Requirements

To develop with or contribute to this SDK, you'll need:

- [Flutter SDK](https://docs.flutter.dev/get-started/install/macos) properly installed and configured
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter plugins
- For Android development:
  - Kotlin 2.1.20 or newer (required by Rokt Android SDK 6.x)
  - Android Gradle Plugin 8.6.0 or newer
  - Gradle 8.9 or newer
  - Android API level 23+ (minSdk)
- For iOS development:
  - iOS 15 or above
  - Xcode with required dependencies
  - The example app uses Swift Package Manager, so it needs Flutter 3.44 or later, or 3.41 or later with `flutter config --enable-swift-package-manager`. Check the repository out into a directory named `rokt_sdk`: Swift Package Manager takes the plugin's package identity from that directory name, and resolution fails when it differs from the Dart package name ([flutter/flutter#186881](https://github.com/flutter/flutter/issues/186881)).

### Setup Steps

1. Clone the repository
2. Run `flutter clean`
3. Run `flutter pub get`
4. To run the example app:
   ```shell
   cd example
   flutter run
   ```

### Testing

To run integration tests:

```shell
flutter test integration_test/app_test.dart
```

### Pull request validation

Pull requests always run change detection and a Trunk code check. Shared Dart, package, example, and integration-test changes select both platform suites; Android- or iOS-only changes select only that platform. Documentation and release-workflow changes use the quick Trunk path, while build configuration, validation workflow, renamed, empty, and unknown paths fail closed to both platforms.

An always-running `PR Gate` fails when selected validation fails or is cancelled. The existing `Trunk code check`, `Build & Test Android / test_android`, and `Build & Test iOS / test_ios` contexts remain available during branch-protection migration. After `PR Gate` exists on the default branch, repository administrators can replace those required contexts with `PR Gate`.

## Implementation Guide

### Adding SDK to Your App

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter

  rokt_sdk: ^5.0.0
```

### Platform-Specific Setup

#### Android

Requires Android API level 23+ (Android 6.0 Marshmallow or above).

1. Set the minSdkVersion and enable multidex in `android/app/build.gradle`:

```gradle
android {
  defaultConfig {
    minSdkVersion 23
    multidexEnabled true
  }
}
```

2. Include appcompat dependency:

   ```gradle
   implementation 'androidx.appcompat:appcompat:1.4.1'
   ```

3. The theme of android/app should extend from AppCompat Theme family:
   ```xml
   <style name="NormalTheme" parent="Theme.AppCompat.DayNight.DarkActionBar"/>
   ```

#### iOS

Rokt iOS SDK supports iOS version 15 and above. The plugin brings in the Rokt iOS SDK (`Rokt-Widget`) with whichever dependency manager Flutter uses for your app, so you don't add it yourself.

##### Swift Package Manager

Flutter uses Swift Package Manager by default from 3.44, and you can turn it on from 3.41 with `flutter config --enable-swift-package-manager`. The plugin's Swift package brings in the Rokt iOS SDK, so don't add any Rokt pods to `ios/Podfile`: `Rokt-Widget`, `RoktContracts`, `RoktUXHelper`, `DcuiSchema` or `RoktPaymentExtension`. Commit the Xcode project change Flutter makes and `ios/Runner.xcworkspace/xcshareddata/swiftpm/Package.resolved`.

> **Warning:** Get the Rokt SDK from only one dependency manager. If a pod and a Swift package both bring it in, the app still builds, but it contains two copies of the SDK. The plugin logs `[Rokt] The Rokt SDK is loaded more than once` at launch when this happens. See [Moving iOS from CocoaPods to Swift Package Manager](MIGRATING.md#ios-moving-from-cocoapods-to-swift-package-manager).

Flutter versions before 3.41 can't build the plugin with Swift Package Manager. Keep it turned off there and use CocoaPods.

##### CocoaPods (deprecated)

CocoaPods trunk becomes read-only on 2 December 2026, so no new Rokt pod versions can be published after that date. With Swift Package Manager turned off, `pod install` brings in the Rokt iOS SDK through the plugin, with no Podfile change. To stay on CocoaPods for now, turn Swift Package Manager off for your app in its `pubspec.yaml`:

```yaml
flutter:
  config:
    enable-swift-package-manager: false
```

Flutter plans to remove this option in a future release.

##### Troubleshooting

- `[Rokt] The Rokt SDK is loaded more than once`: the SDK comes from both CocoaPods and Swift Package Manager. Remove the Rokt pods from `ios/Podfile`.
- Package resolution fails, for example `no versions of '…' match the requirement`, or the build uses an old minimum iOS version: run `flutter clean`, then in Xcode choose **File > Packages > Reset Package Caches**.

### SDK Initialization

```dart
// The following will reveal a demo integration. To view your integration:
// 1) Replace the integration test tag ID (222) with your unique Rokt Tag ID
// 2) Replace 1.0.0 with the application version
RoktSdk.initialize('222', appVersion: '1.0.0');
```

### Updating the SDK

- Run `flutter clean`
- Run `flutter pub get`
- With Swift Package Manager, build the app and commit the updated `Package.resolved`. If Xcode keeps an old native SDK version, choose **File > Packages > Reset Package Caches**.
- With CocoaPods, delete `ios/Pods` and `ios/Podfile.lock`, then run `pod install` from inside the `ios` folder.

### Implementation Types

#### Overlay Placements

Select placements in your desired view and add all appropriate customer attributes.

```dart
import 'package:rokt_sdk/rokt_sdk.dart';

RoktSdk.selectPlacements(
  viewName: "RoktExperience",
  attributes: {
    "email": "j.smith@example.com",
    "firstname": "Jenny",
    "lastname": "Smith",
    "mobile": "(555)867-5309",
    "postcode": "90210",
    "country": "US"
  }
);
```

#### Embedded Placements

1. Add `RoktWidget` to your view:

```dart
const RoktWidget(placeholderName: "RoktEmbedded1", onWidgetCreated: () { showWidget(); })
```

#### Shoppable Ads (iOS only)

Shoppable Ads allow users to make instant purchases directly from ad placements. This feature requires a payment extension to be registered before displaying shoppable ads.

1. Add the native payment extension to your iOS app. With Swift Package Manager, open `ios/Runner.xcworkspace` in Xcode, choose **File > Add Package Dependencies…**, enter `https://github.com/ROKT/rokt-payment-extension-ios`, and add the `RoktPaymentExtension` product to the **Runner** target. With CocoaPods, add it to your `Podfile` instead:

```ruby
pod 'RoktPaymentExtension'
```

2. Set the payment extension factory in your `AppDelegate.swift`:

```swift
import RoktPaymentExtension
import rokt_sdk

// In application(_:didFinishLaunchingWithOptions:), after GeneratedPluginRegistrant.register:
SwiftRoktSdkPlugin.paymentExtensionFactory = { type, config in
    switch type {
    case "stripe":
        guard let merchantId = config["applePayMerchantId"] else { return nil }
        return RoktPaymentExtension(
            applePayMerchantId: merchantId
        )
    default:
        return nil
    }
}
```

3. Register the payment extension and display shoppable ads:

```dart
import 'package:rokt_sdk/rokt_sdk.dart';

// Register payment extension (call once after initialize)
RoktSdk.registerPaymentExtension(
  extensionType: 'stripe',
  config: {
    'stripeKey': 'YOUR_STRIPE_PUBLISHABLE_KEY',
    'applePayMerchantId': 'merchant.com.yourapp.rokt',
  },
);

// Display shoppable ads (always overlay)
RoktSdk.selectShoppableAds(
  viewName: "ConfirmationPage",
  attributes: {
    "email": "j.smith@example.com",
    "firstname": "Jenny",
    "lastname": "Smith",
    "confirmationref": "ORDER-12345",
  },
);
```

4. Handle shoppable events via the `RoktEvents` EventChannel:

```dart
const EventChannel roktEventChannel = EventChannel('RoktEvents');

roktEventChannel.receiveBroadcastStream().listen((dynamic event) {
  final eventName = event['event'];
  if (eventName == 'CartItemInstantPurchase') {
    print("Purchase completed: ${event['catalogItemId']}");
  } else if (eventName == 'CartItemInstantPurchaseFailure') {
    print("Purchase failed: ${event['error']}");
  }
});
```

## Key Dependencies & Gotchas

### Native SDK Versions

This Flutter plugin bundles native Rokt SDKs. Current versions are defined in the platform manifests:

- Android: `android/build.gradle` (`com.rokt:roktsdk`)
- iOS: `ios/rokt_sdk/Package.swift` (`Rokt-Widget`). `ios/rokt_sdk.podspec` reads the version from there, so CocoaPods and Swift Package Manager resolve the same range.

### Dependencies

- **Android**:
  - Requires `androidx.appcompat` compatibility
  - Uses `com.rokt:roktsdk` from Maven Central (see `android/build.gradle`)
  - Requires minSdk 23 and Kotlin 2.1.20+ when building the plugin locally

- **iOS**:
  - Uses `Rokt-Widget` from Swift Package Manager (`ios/rokt_sdk/Package.swift`) or, deprecated, CocoaPods (`ios/rokt_sdk.podspec`)
  - Requires iOS 15.0+

#### Updating Native SDKs

To update the iOS SDK, change the `rokt-sdk-ios` version in `ios/rokt_sdk/Package.swift`. The podspec reads it from there.

For Android, change the `com.rokt:roktsdk` version in `android/build.gradle`.

See `CHANGELOG.md` for release notes when bumping native SDK versions.

### Gotchas

- Always run `flutter clean` before updating the SDK version
- Android apps must target API level 23+ to use this plugin (required by Rokt Android SDK 6.x)
- For embedded placements, ensure the view is in the visible area of the screen before calling `selectPlacements`
- To run in sandbox mode, add `"sandbox": "true"` to your attributes
- When upgrading the native SDKs, update `android/build.gradle` and `ios/rokt_sdk/Package.swift`, then document changes in `CHANGELOG.md`
- Shoppable Ads (`selectShoppableAds`, `registerPaymentExtension`) are iOS-only; Android calls are no-ops

## Making Changes and Deployment

### Branch Structure

There is one **main** branch. This branch is where all development branches are merged into. Publishing the package is possible with **main** only.

### Publishing the SDK

This SDK is published to [pub.dev](https://pub.dev/packages/rokt_sdk).

#### Automated Publishing (Recommended)

The SDK can be released via the [Mobile Release Pipeline](https://github.com/ROKT/mobile-release-pipeline). Follow the instructions in the Mobile Release Pipeline repo to release.

#### Manual Publishing

1. Update version in `pubspec.yaml` (append `-alpha` for alpha releases)
2. Update `CHANGELOG.md` with your changes
3. Ensure you have the required environment variables:
   ```shell
   PUB_DEV_PUBLISH_ACCESS_TOKEN=
   PUB_DEV_PUBLISH_REFRESH_TOKEN=
   PUB_DEV_PUBLISH_TOKEN_ENDPOINT=
   PUB_DEV_PUBLISH_EXPIRATION=
   ```
4. Run the publishing commands:
   ```shell
   cd .buildkite
   ./pub_login.sh
   dart pub publish -f
   ```

## License

Copyright 2020 Rokt Pte Ltd

Licensed under the Rokt Software Development Kit (SDK) Terms of Use
Version 2.0 (the "License");

You may not use this file except in compliance with the License.
