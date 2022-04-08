# rokt_sdk

The Rokt Flutter SDK enables you to integrate Rokt into your native mobile apps to drive more value from—and for—your customers.

The Rokt SDK for Flutter applications can be used by Rokt partners to display overlay or embedded placements, or by Rokt advertisers to record conversions for campaigns.

## Usage

To use this plugin, add following code in your pubspec.yaml file.
```
dependencies:
  flutter:
    sdk: flutter

  rokt_sdk:
    git:
      url: git@github.com:ROKT/rokt-sdk-flutter.git
      ref: release-0.0.x
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

## How to run the example app locally
- Open project in Android Studio for changing the code
- run following commands in terminal or equalivant in Android Studio
- run `flutter clean`
- run `flutter pub get`
- run `flutter run`

## License
```
Copyright 2020 Rokt Pte Ltd

Licensed under the Rokt Software Development Kit (SDK) Terms of Use
Version 2.0 (the "License");

You may not use this file except in compliance with the License.