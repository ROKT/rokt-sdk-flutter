# Rokt Flutter SDK

## Project Overview

The Rokt Flutter SDK (`rokt_sdk`) is a Flutter plugin that enables Rokt partners and advertisers to integrate Rokt placements into Flutter mobile applications. It provides a unified Dart API that bridges to native Android (Kotlin) and iOS (Swift) Rokt SDKs. The plugin supports overlay placements, embedded placements, and conversion tracking. It is published to [pub.dev](https://pub.dev/packages/rokt_sdk).

**Current version:** 4.11.0

Owned by the **sdk-engineering** team. Resident experts: Thomson Thomas and James Newman.

## Architecture

The SDK follows a Flutter plugin bridge pattern:

```text
┌─────────────────────────────────────────────────┐
│              Flutter Application                │
│         (uses rokt_sdk Dart package)            │
└───────────────┬─────────────────────────────────┘
                │
┌───────────────▼─────────────────────────────────┐
│          Dart Interface Layer (lib/)             │
│  rokt_sdk.dart  - RoktSdk class (init/execute)  │
│  rokt_widget.dart - RoktWidget embedded view    │
│  rokt_sdk_controller.dart - MethodChannel comms │
│  widget_controller.dart - per-widget channels   │
└───────┬───────────────────────────┬─────────────┘
        │ MethodChannel "rokt_sdk"  │
        │ EventChannel "RoktEvents" │
┌───────▼──────────┐    ┌──────────▼──────────────┐
│ Android (Kotlin)  │    │    iOS (Swift)           │
│ RoktSdkPlugin     │    │ SwiftRoktSdkPlugin      │
│ MethodCallHandler │    │ RoktMethodCallHandler    │
│ RoktWidgetFactory │    │ RoktWidgetFactory        │
│ → com.rokt:roktsdk│    │ → Rokt-Widget CocoaPod   │
└──────────────────┘    └─────────────────────────┘
```

- **Dart layer** (`lib/`): Exposes `RoktSdk` (initialize, execute, logging, purchaseFinalized, session management) and `RoktWidget` (embedded placement view). Communicates with native via `MethodChannel('rokt_sdk')` and `EventChannel('RoktEvents')`.
- **Android native** (`android/`): Kotlin plugin bridging to `com.rokt:roktsdk:4.13.0`. Handles platform view registration, method call routing, and event subscription via Kotlin coroutines/flows.
- **iOS native** (`ios/`): Swift plugin bridging to `Rokt-Widget ~> 4.15.0` CocoaPod. Handles method call routing, embedded views, and event streaming.

## Tech Stack

| Component             | Version/Details                                                                |
| --------------------- | ------------------------------------------------------------------------------ |
| Dart SDK              | >=2.16.1 <4.0.0                                                                |
| Flutter               | >=2.5.0                                                                        |
| Kotlin                | 1.9.10                                                                         |
| Android Gradle Plugin | 8.6.0                                                                          |
| Android compileSdk    | 35                                                                             |
| Android minSdk        | 21                                                                             |
| Swift                 | 5.0                                                                            |
| iOS minimum           | 12.0                                                                           |
| Native Android SDK    | `com.rokt:roktsdk:4.13.0`                                                      |
| Native iOS SDK        | `Rokt-Widget ~> 4.15.0`                                                        |
| Lint (Dart)           | `flutter_lints` + `dart_code_metrics`                                          |
| CI linting            | Trunk (markdownlint, prettier, ktlint, actionlint, shellcheck, yamllint, etc.) |

## Development Guide

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install/macos) installed and configured
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter plugins
- For Android: Kotlin 1.8+, Android Gradle Plugin 7.4+, Gradle 7.5+, JDK 17
- For iOS: Xcode (16.4 recommended), iOS 12+ deployment target, Ruby (for CocoaPods/Bundler)
- [Trunk CLI](https://docs.trunk.io/cli) for linting

### Quick Start

```shell
# Clone and set up
git clone git@github.com:ROKT/rokt-sdk-flutter.git
cd rokt-sdk-flutter
flutter clean
flutter pub get

# Run the example app
cd example
flutter pub get
flutter run
```

### Common Tasks

| Task                            | Command                                                                         |
| ------------------------------- | ------------------------------------------------------------------------------- |
| Clean project                   | `flutter clean`                                                                 |
| Get dependencies                | `flutter pub get`                                                               |
| Run unit tests                  | `flutter test`                                                                  |
| Run integration tests (Android) | `cd example && flutter test integration_test/app_test.dart`                     |
| Run integration tests (iOS)     | `cd example && flutter test integration_test/app_test.dart -d <simulator-udid>` |
| Analyze code                    | `flutter analyze`                                                               |
| Run Trunk linting               | `trunk check`                                                                   |
| Format with Trunk               | `trunk fmt`                                                                     |
| Dry-run publish                 | `flutter pub publish --dry-run`                                                 |

### Updating the SDK After Changes

```shell
flutter clean
# Delete iOS artifacts
rm -rf ios/Pods ios/Podfile.lock
flutter pub get
cd ios && pod install
```

## CI/CD Pipeline

CI/CD runs via **GitHub Actions** (`.github/workflows/`).

### Pull Request Workflow (`pull_request.yml`)

Triggers on every PR and `workflow_dispatch`:

1. **Trunk code check** — Sets up Flutter, runs `flutter pub get` (root + example), then runs `trunk-io/trunk-action` with `check-mode: all`
2. **Build & Test iOS** (after trunk) — Uses `test-ios.yml` reusable workflow: sets up Ruby, Flutter, Xcode 16.4; installs CocoaPods; runs `flutter test` and integration tests on iPhone 16 simulator
3. **Build & Test Android** (after trunk) — Uses `test-android.yml` reusable workflow: sets up Flutter, JDK 17, Android SDK; runs integration tests on API 29 emulator (Pixel 6 profile)
4. **GChat notification** — Notifies Google Chat on non-draft PRs after tests pass

### Release Workflow

1. **Create draft release** (`draft-release-publish.yml`) — Manual trigger, bumps version (major/minor/patch) in `VERSION` and `pubspec.yaml`, updates `CHANGELOG.md`, runs dry-run publish, creates a PR
2. **Release from main** (`release-from-main.yml`) — Triggers when `VERSION` file changes on main: runs iOS + Android tests, publishes to pub.dev, creates GitHub release, pushes release notes to `ROKT/rokt-docs`

### Other Workflows

- **Trunk upgrade** (`trunk-upgrade.yml`) — Monthly cron or manual, upgrades Trunk linter versions

## Environment Variables

| Variable                         | Purpose                                           |
| -------------------------------- | ------------------------------------------------- |
| `PUB_DEV_PUBLISH_ACCESS_TOKEN`   | OAuth access token for pub.dev publishing         |
| `PUB_DEV_PUBLISH_REFRESH_TOKEN`  | OAuth refresh token for pub.dev publishing        |
| `PUB_DEV_PUBLISH_TOKEN_ENDPOINT` | OAuth token endpoint for pub.dev publishing       |
| `PUB_DEV_PUBLISH_EXPIRATION`     | Token expiration timestamp for pub.dev publishing |

These are used by `pub_login.sh` to create `~/.config/dart/pub-credentials.json` during CI publishing.

## Project Structure

```text
rokt-sdk-flutter/
├── lib/                        # Dart plugin source
│   ├── rokt_sdk.dart           # Main entry point (RoktSdk, RoktConfig, CacheConfig, ColorMode)
│   └── src/
│       ├── rokt_sdk_controller.dart  # MethodChannel controller (singleton)
│       ├── rokt_widget.dart          # RoktWidget embedded view (StatefulWidget)
│       └── widget_controller.dart    # Per-widget MethodChannel for height/padding
├── android/                    # Android native plugin (Kotlin)
│   ├── build.gradle            # Android build config, native SDK dependency
│   └── src/main/kotlin/com/rokt/rokt_sdk/
│       ├── RoktSdkPlugin.kt         # FlutterPlugin entry point
│       ├── MethodCallHandlerImpl.kt  # Method call routing & event subscriptions
│       ├── RoktCallbackImpl.kt       # Callback bridge
│       ├── RoktWidget.kt             # Android platform view
│       └── RoktWidgetFactory.kt      # Platform view factory
├── ios/                        # iOS native plugin (Swift)
│   ├── rokt_sdk.podspec        # CocoaPods spec, native SDK dependency
│   ├── Classes/
│   │   ├── SwiftRoktSdkPlugin.swift     # FlutterPlugin entry point
│   │   ├── RoktMethodCallHandler.swift  # Method call routing & events
│   │   ├── FLRoktWidgetView.swift       # iOS platform view
│   │   └── RoktWidgetFactory.swift      # Platform view factory
│   └── PrivacyInfo.xcprivacy
├── example/                    # Example Flutter app
│   ├── lib/main.dart           # Demo app with init/execute
│   └── integration_test/       # Integration tests
├── test/                       # Unit tests
│   └── rokt_sdk_test.dart
├── .github/workflows/          # GitHub Actions CI/CD
├── .trunk/                     # Trunk linting configuration
├── .cortex/                    # Service catalog metadata
├── pubspec.yaml                # Package manifest
├── VERSION                     # Version file (drives releases)
├── CHANGELOG.md                # Keep-a-Changelog format
├── RELEASING.md                # Release process documentation
├── pub_login.sh                # pub.dev credential setup script
└── analysis_options.yaml       # Dart/Flutter lint rules
```

## Observability

- **Cortex tag:** `flutter-sdk`
- **Service tier:** 3
- **On-call:** Mobile Integrations (OpsGenie schedule: `Mobile Integrations_schedule`)
- **Datadog dashboard:** [Mobile SDK Detailed Error View](https://rokt.datadoghq.com/dashboard/nsi-c8c-gtd)
- **Buildkite pipeline:** `rokt-flutter-sdk`

## Team Ownership

- **CODEOWNERS:** `@ROKT/sdk-engineering` (all files)
- **Cortex groups:** `lang-dart`, `lang-kotlin`, `lang-swift`, `serviceTier-3`

## Maintaining This Document

When making changes to this repository that affect the information documented here
(build commands, dependencies, architecture, deployment configuration, etc.),
please update this document to keep it accurate. This file is the primary reference
for AI coding assistants working in this codebase.
