# Rokt Flutter SDK

The Rokt Flutter SDK enables you to integrate Rokt into your native mobile apps to drive more value from—and for—your customers. The SDK supports both iOS and Android platforms through a unified Flutter interface.

The Rokt SDK for Flutter applications can be used by Rokt partners to display overlay or embedded placements, or by Rokt advertisers to record
conversions for campaigns.

| Environment | Build                                                                                                                                                                          |
| ----------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| release     | [![Build](https://github.com/ROKT/rokt-sdk-flutter/actions/workflows/pull_request.yml/badge.svg)](https://github.com/ROKT/rokt-sdk-flutter/actions/workflows/pull_request.yml) |

## Resident Experts

- Thomson Thomas - <thomson.thomas@rokt.com>
- Danial Motahari - <danial.motahari@rokt.com>
- Sahil Suri - <sahil.suri@rokt.com>

## Service Architecture

The Rokt Flutter SDK is structured as a Flutter plugin that provides a Dart interface to platform-specific native SDKs:

- **Dart Interface Layer**: Located in the `lib` directory, provides the API surface for Flutter applications
- **Platform-Specific Implementations**:
  - `android` directory contains the Kotlin implementation using the native Android Rokt-Widget SDK
  - `ios` directory contains the Swift implementation using the native iOS Rokt-Widget SDK
- **Example Application**: Located in the `example` directory, demonstrates how to implement the SDK

The SDK follows a bridge pattern to connect the Flutter framework with native platform capabilities, enabling seamless integration with Rokt's services.

## Local Development Setup

### Requirements

To develop with or contribute to this SDK, you'll need:

- [Flutter SDK](https://docs.flutter.dev/get-started/install/macos) properly installed and configured
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter plugins
- For Android development:
  - Kotlin version 1.8.0 or newer
  - Android Gradle plugin 7.4.0 or newer
  - Gradle version 7.5 or newer
- For iOS development:
  - iOS 12 or above
  - Xcode with required dependencies

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

## Implementation Guide

### Adding SDK to Your App

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter

  rokt_sdk: ^4.0.0
```

### Platform-Specific Setup

#### Android

1. Set the minSdkVersion and enable multidex in `android/app/build.gradle`:

```gradle
android {
  defaultConfig {
    minSdkVersion 21
    multidexEnabled true
  }
}
```

2. Include appcompat dependency:

   ```gradle
   implementation 'androidx.appcompat:appcompat:x.x.x'
   ```

3. The theme of android/app should extend from AppCompat Theme family:
   ```xml
   <style name="NormalTheme" parent="Theme.AppCompat.DayNight.DarkActionBar"/>
   ```

#### iOS

Rokt iOS SDK supports iOS version 12 and above. No additional configuration is needed.

### SDK Initialization

```dart
// The following will reveal a demo integration. To view your integration:
// 1) Replace the integration test tag ID (222) with your unique Rokt Tag ID
// 2) Replace 1.0.0 with the application version
RoktSdk.initialize('222', appVersion: '1.0.0');
```

### Updating the SDK

- Run `flutter clean`
- Delete /ios/Pods
- Delete /ios/Podfile.lock
- Run `flutter pub get`
- From inside ios folder, run `pod install`

### Implementation Types

#### Overlay Placements

Execute the Rokt iOS SDK in your desired view and add all appropriate customer attributes.
The SDK provides optional callback events for when the view loads and unloads.

```dart
import 'package:rokt_sdk/rokt_sdk.dart';

RoktSdk.execute(
  viewName: "RoktExperience",
  attributes: {
    "email": "j.smith@example.com",
    "firstname": "Jenny",
    "lastname": "Smith",
    "mobile": "(555)867-5309",
    "postcode": "90210",
    "country": "US"
  },
  onLoad: () {
    // Optional callback for when the Rokt placement loads
  },
  onUnLoad: () {
    // Optional callback for when the Rokt placement unloads
  }
);
```

#### Embedded Placements

1. Add `RoktWidget` to your view:

```dart
const RoktWidget(placeholderName: "RoktEmbedded1", onWidgetCreated: () { showWidget(); })
```

## Key Dependencies & Gotchas

### Dependencies

- **Android**:

  - Requires `androidx.appcompat` compatibility
  - Uses native Android Rokt-Widget SDK (currently referenced version in `android/build.gradle`)

- **iOS**:
  - Uses native iOS Rokt-Widget SDK (referenced in `ios/rokt_sdk.podspec`)

#### Updating Native SDKs

To update the iOS SDK:

```yaml
// ios/rokt_sdk.podspec
s.version          = 'X.X.X'
s.dependency 'Rokt-Widget', '~> X.X.X'
```

For Android:

It's currently using the latest snapshot of the development build from Maven Central.

To update the SDK to a specific version:

```gradle
// android/build.gradle
implementation "com.rokt:roktsdk:X.X.X"
```

### Gotchas

- Always run `flutter clean` before updating the SDK version
- For embedded placements, ensure the view is in the visible area of the screen before calling `execute`
- To run in sandbox mode, add `"sandbox": "true"` to your attributes
- When upgrading the native SDKs, you must update both the podspec version and the dependency version

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
