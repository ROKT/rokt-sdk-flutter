# rokt_sdk

The Rokt Flutter SDK enables you to integrate Rokt into your native mobile apps to drive more value from—and for—your customers.

The Rokt SDK for Flutter applications can be used by Rokt partners to display overlay or embedded placements, or by Rokt advertisers to record conversions for campaigns.

## Resident Experts

- Danial Motahari - danial.motahari@rokt.com
- Sahil Suri - sahil.suri@rokt.com

| Environment | Build |
| ----------- | :----- |
| release |  [![CircleCI](https://dl.circleci.com/status-badge/img/gh/ROKT/rokt-sdk-flutter/tree/release-3%2E11%2Ex.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/ROKT/rokt-sdk-flutter/tree/release-3%2E11%2Ex)

## Usage

To use this plugin, add following code in your pubspec.yaml file.
```
dependencies:
  flutter:
    sdk: flutter

  rokt_sdk: ^3.14.2
```

## Getting Started

### Android
1) Set the minSdkVersion and enable multidex in `android/app/build.gradle:`
```
android {
defaultConfig {
minSdkVersion 19
multidexEnabled true

    }
}
```
This means that app will only be available for users that run Android SDK 19 or higher.

2) Include appcompat dependency
`implementation 'androidx.appcompat:appcompat:x.x.x’`
   The theme of android/app should extend from AppCompat Theme family, example:
   

   `<style name="NormalTheme" parent="Theme.AppCompat.DayNight.DarkActionBar"/>`

### iOS
Rokt iOS SDK supports iOS version 10 and above

## How to update the SDK
_ Run `flutter clean`
- Delete /ios/Pods
- Delete /ios/Podfile.lock 
- Run `flutter pub get`
- From inside ios folder, run `pod install`

## Initializing the Rokt SDK
Initialize the Rokt SDK prior to using it. We recommend calling the initi method in the beginning of the applications.
```
// The following will reveal a demo integration. To view your integration:
// 1) Replace the integration test tag ID (222) with your unique Rokt Tag ID
// 2) Replace 1.0.0 with the application version
RoktSdk.initialize('222', appVersion: '1.0.0');
```

## Overlay placements
Execute the Rokt iOS SDK in your desired view and add all appropriate customer attributes.
The SDK provides optional callback events for when the view loads and unloads.

```
import 'package:rokt_sdk/rokt_sdk.dart';

void executeRokt() {
    // Replace RoktExperience with your viewName
    RoktSdk.execute(
                    viewName: "RoktExperience",
                    attributes: {"email": "j.smith@example.com",
                        "firstname": "Jenny",
                        "lastname": "Smith",
                        "mobile": "(555)867-5309",
                        "postcode": "90210",
                        "country": "US"},
                    onLoad: () {
                        // Optional callback for when the Rokt placement loads
                    },
                    onUnLoad: () {
                        // Optional callback for when the Rokt placement unloads
                    },
                    onShouldShowLoadingIndicator: () {
                        // Optional callback to show a loading indicator
                    },
                    onShouldHideLoadingIndicator: () {
                        // Optional callback to hide a loading indicator
                    });
}
```
To run an placement in the sandbox environment, the list of attributes passed to Rokt needs to be updated to include `"sandbox": "true"`

## Embedded placements
### add Rokt Widget

add `const RoktWidget(placeholderName: "RoktEmbedded1")` in your view.
please make sure that the view is created on the visible area of the screen and then call showWidget.
RoktWidget has a callback to notify when widget is created which could be utilized.
`RoktWidget(placeholderName: "RoktEmbedded1", onWidgetCreated: () { showWidget() })`

### Execute Rokt
```
import 'package:rokt_sdk/rokt_sdk.dart';

void showWidget() {
    // Replace RoktExperience with your viewName
    RoktSdk.execute(
                    viewName: "RoktExperience",
                    attributes: {"email": "j.smith@example.com",
                        "firstname": "Jenny",
                        "lastname": "Smith",
                        "mobile": "(555)867-5309",
                        "postcode": "90210",
                        "country": "US"},
                    onLoad: () {
                        // Optional callback for when the Rokt placement loads
                    },
                    onUnLoad: () {
                        // Optional callback for when the Rokt placement unloads
                    },
                    onShouldShowLoadingIndicator: () {
                        // Optional callback to show a loading indicator
                    },
                    onShouldHideLoadingIndicator: () {
                        // Optional callback to hide a loading indicator
                    });
}
```

To run an placement in the sandbox environment, the list of attributes passed to Rokt needs to be updated to include `"sandbox": "true"`

## Requirements

Download [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) for editor and install [Flutter SDK](https://docs.flutter.dev/get-started/install/macos)

## Project structure

This project consists of sdk Plugin which contains [lib](lib)] which is the main entry for the sdk plugin, [android](android), [iOS](ios) platform specific code for the sdk plugin
and an [example App](example) which is a sample App to run the sdk plugin.

## Publishing SDK
This SDK is published to [pub.dev](https://pub.dev/) [here](https://pub.dev/packages/rokt_sdk). You can publish the alpha or prod package.
To publish the package, you need to modify pubspec.yaml and update the version field. We should append ```-alpha``` after version if we intend to publish
the alpha package. Make sure you add the changes in CHANGELOG.md.
Publishing the package is possible through [CircleCi](https://app.circleci.com/pipelines/github/ROKT/rokt-sdk-flutter) or [Buildkite](https://buildkite.com/rokt/rokt-flutter-sdk) by approving the ```hold_for_publish``` job.

## How to manually publish sdk ?

1. Make sure you have following environment variables set:
   ```
   PUB_DEV_PUBLISH_ACCESS_TOKEN=
   PUB_DEV_PUBLISH_REFRESH_TOKEN=
   PUB_DEV_PUBLISH_TOKEN_ENDPOINT=
   PUB_DEV_PUBLISH_EXPIRATION=
   ```
2. Run following command
   ```
   cd .circleci
   ./pub_login.sh
   dart pub publish -f
    ```

## How to manually run UI Test ?
UI test are located inside example app and you can run it by executing below command
```
flutter test integration_test/app_test.dart
```

## How to run the example app locally
- Open project in Android Studio for changing the code
- Run following commands in terminal or equivalent in Android Studio
- Run `flutter clean`
- Run `flutter pub get`
- Run `flutter run`

## What are the branches?

There is one main branch with **release-** prefix. This branch is where all development branches are merged into. Publishing the package is possible with **release-** prefix branches only.

## Update Rokt Native Sdk
To update the iOS rokt sdk, make the following changes.
``` open ios/rokt_sdk.podspec
   s.version          = 'X.X.X'
   s.dependency 'Rokt-Widget', '~> X.X.X'
```
For Android, do the folliwing
``` open android/build.gradle
   implementation "com.rokt:roktsdk:X.X.X"
```
## License

Copyright 2020 Rokt Pte Ltd

Licensed under the Rokt Software Development Kit (SDK) Terms of Use
Version 2.0 (the "License");

You may not use this file except in compliance with the License.
