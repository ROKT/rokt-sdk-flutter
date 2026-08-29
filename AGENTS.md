# Rokt Flutter SDK - Agent Instructions

`rokt_sdk` is a Flutter plugin wrapping the native Rokt iOS and Android SDKs. Anything a config
file already states — dependency versions, lint rules, deployment targets, CI step order — is
deliberately not repeated here; read `pubspec.yaml`, `analysis_options.yaml`, `.trunk/trunk.yaml`
and `.github/workflows/` instead. `README.md` covers integration and `RELEASING.md` covers
releases.

## Commands

Run `flutter pub get` in **both** the repo root and `example/` before anything else. Several
tools are silently wrong without it (trap 1).

| Task                                                 | Command                                                                 |
| ---------------------------------------------------- | ----------------------------------------------------------------------- |
| Plugin unit tests (Dart-to-native channel contract)  | `flutter test` from the repo root                                       |
| Example widget test                                  | `cd example && flutter test`                                            |
| Integration test (needs a booted device or emulator) | `cd example && flutter test integration_test/app_test.dart -d <device>` |
| Lint, format and analyze exactly as CI does          | `trunk check --all`, `trunk fmt`                                        |
| Something runnable                                   | `cd example && flutter build apk --debug`, or `flutter run`             |

There is no app at the repo root, so `flutter build` and `flutter run` work only from `example/`,
which path-depends on `../`. The example app is the only way to exercise the plugin end to end,
and it is what CI builds.

Running the iOS integration test locally also needs CocoaPods via Bundler, from **two** separate
Gemfiles (`example/Gemfile` and `example/ios/Gemfile`) before `pod install`; see
`.github/workflows/test-ios.yml`.

### Command traps

1. **`trunk` before `flutter pub get` is actively misleading, not merely incomplete.** With no
   `.dart_tool/package_config.json`, `dart analyze` reports every `package:` import as
   `uri_does_not_exist` plus a cascade of undefined names, and `dart format` falls back to the
   newest language version, whose "tall" style rewrites every Dart file in the repo. After
   `pub get`, the language version comes from the `environment: sdk:` lower bound in
   `pubspec.yaml`, which is old enough to keep the previous short style, and the committed code
   is already correct. `.github/workflows/pull_request.yml` runs both `pub get`s before Trunk
   Check for exactly this reason. Raising that lower bound past Dart 3.7 reformats the entire
   repo.
2. **CI never runs the root `flutter test`.** Both platform jobs change into `example/` first
   (`.github/workflows/test-ios.yml`, `.github/workflows/test-android.yml`), so
   `test/rokt_sdk_test.dart` — the suite that pins the arguments sent over the `rokt_sdk` method
   channel — is executed by no workflow at all. Run it yourself; a green PR says nothing about
   it. The Android job runs only the integration test, not the example widget test.
3. **Nothing calls `flutter analyze` or `dart analyze` directly.** Analysis reaches CI only via
   the `dart` linter that `.trunk/trunk.yaml` enables, which shells out to
   `dart analyze --no-fatal-warnings`. Trunk is the whole lint gate.
4. **The `dart_code_metrics` block in `analysis_options.yaml` is inert.** That package is not in
   `dev_dependencies`, so nothing installs it and none of those metrics or rules are enforced
   anywhere.
5. **The reusable workflows' `default:` input values are dead code for PR CI.**
   `.github/workflows/pull_request.yml` passes the Flutter, Ruby and Xcode versions explicitly,
   so editing the defaults in `test-ios.yml` or `test-android.yml` changes nothing. The Flutter
   and Ruby versions come from repository-level Actions variables, so you cannot read the version
   CI actually uses out of this repository.
6. **Zizmor is advisory only.** `.github/workflows/zizmor.yml` sets `continue-on-error: true`,
   and it triggers only on changes under `.github/`. A green or absent workflow-security check
   does not mean there were no findings.

## Lint conventions the toolchain would not lead you to expect

The root `analysis_options.yaml` includes `package:lints/recommended.yaml`, the plain Dart set,
not `package:flutter_lints/flutter.yaml` — so Flutter-specific lints are off at the root, while
`example/analysis_options.yaml` does include the Flutter set. On top of that the root turns on a
long list of rules that neither default set enables, most importantly
`public_member_api_docs`: every new public member in `lib/` needs a `///` doc comment or Trunk
fails. A clean analyze here means more than it usually does.

## Versioning and changelog

- Never edit the `VERSION` file, `version:` in `pubspec.yaml`, or `s.version` in
  `ios/rokt_sdk.podspec`. The release workflow bumps all three; see `RELEASING.md`.
- Do not hand-write `CHANGELOG.md` entries. The release draft generates the whole version
  section from the squash-merge PR titles since the last tag and inserts it beneath
  `## [Unreleased]`, so a hand-written entry there gets duplicated by the generated one and then
  stranded under `Unreleased` permanently.
- **Your PR title becomes the public changelog line.** It is parsed as a conventional commit and
  bucketed by type; an unrecognised or absent type still ships, under "Changed". No CI check
  enforces the format. The parser lives in `ROKT/rokt-workflows`, `actions/generate-changelog`.

## Native SDK pins

The native Rokt SDK version appears in several places, and they do not agree by construction:

- `ios/rokt_sdk.podspec` — `Rokt-Widget`, for CocoaPods consumers. The `~> x.y.z` form permits
  patch upgrades only.
- `ios/rokt_sdk/Package.swift` — the same native SDK for Swift Package Manager consumers, via
  `.upToNextMajor`, which permits any minor within the major.
- `android/build.gradle` — `com.rokt:roktsdk`, served from Rokt's own Maven repo, not Maven
  Central.
- `example/ios/Podfile` — `RoktPaymentExtension`, pinned to a git tag. Only the example app pulls
  it; the plugin does not.

So bump the iOS native version in **both** `ios/rokt_sdk.podspec` and `ios/rokt_sdk/Package.swift`,
and note the two ranges are not equivalent: narrowing the podspec to exclude a bad native release
does not stop SPM consumers resolving it. iOS and Android are on different major version lines and
have been for several releases — do not try to make the two numbers match.

`ios/rokt_sdk/Package.swift` also path-depends on a sibling `FlutterFramework` package that the
Flutter tool generates, so it is not buildable on its own with `swift build`.

## Pull requests

- Base branch is `main`. `master` and `develop` still exist and are stale; ignore them.
- Checks include organisation-level apps not defined in this repo (Cortex catalog lint, security
  and paved-roads bots, Graphite mergeability). All checks are expected to pass on every PR here,
  so a red one is a real failure rather than background noise.
