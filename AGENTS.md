# Rokt Flutter SDK - Agent Instructions

`rokt_sdk` is a Flutter plugin wrapping the native Rokt iOS and Android SDKs. Anything a config
file already states — dependency versions, lint rules, deployment targets, CI step order — is
deliberately not repeated here; read `pubspec.yaml`, `analysis_options.yaml`, `.trunk/trunk.yaml`
and `.github/workflows/` instead. `README.md` covers integration and `RELEASING.md` covers
releases.

## This is a PUBLIC repository

Everything pushed here is world-readable and permanent: code, comments, commit messages, branch
names, PR titles and descriptions, review comments, test names, fixtures and assets. Closing a
PR, renaming a branch or force-pushing does not take any of it back, because GitHub keeps a
closed PR's original branch name and commits. The first push is the one that counts.

Never include:

- Partner, client or advertiser names, or any detail that could identify one (account, tenant
  or campaign IDs, deal terms, integration specifics). Say "a partner" or use a synthetic
  example, in branch names too.
- Partner brand assets: logos, screenshots or copy. Demo and sample content uses fictional
  brands.
- Internal service, system or class names, internal hostnames, dashboards, or links to private
  repos and tickets.
- Backend detail, especially how a payload is validated server-side. Describe what the SDK
  sends and receives, in partner-facing terms, and refer to a server change generically ("to
  match the server contract").

Before each push, PR, comment or reply, read the exact outgoing text, branch name included. If
you are unsure whether a detail is safe, leave it out and ask privately. Do not publish first
and edit it out later.

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

The example app gets its iOS dependencies from Swift Package Manager, so building it for iOS needs
Flutter 3.44 or later (or 3.41 or later with `flutter config --enable-swift-package-manager`) and
no CocoaPods (trap 7). CocoaPods is still supported for apps that turn
Swift Package Manager off; the `build_ios_cocoapods` job in `.github/workflows/test-ios.yml` checks
that path by rewriting the example to use a Podfile, with CocoaPods from `example/Gemfile` via
Bundler.

### Command traps

1. **`trunk` before `flutter pub get` is actively misleading, not merely incomplete.** With no
   `.dart_tool/package_config.json`, `dart analyze` reports every `package:` import as
   `uri_does_not_exist` plus a cascade of undefined names, and `dart format` falls back to the
   newest language version, whose "tall" style reformats most of the Dart files in the repo. After
   `pub get`, the language version comes from the `environment: sdk:` lower bound in
   `pubspec.yaml`, which is old enough to keep the previous short style, and the committed code
   is already correct. `.github/workflows/pull_request.yml` runs both `pub get`s before Trunk
   Check for exactly this reason. Raising that lower bound past Dart 3.7 reformats most of the Dart
   source.
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
   `.github/workflows/pull_request.yml` passes the Ruby and Xcode versions to `test-ios.yml`, and
   the Flutter version to `test-android.yml`, explicitly, so editing those defaults changes
   nothing. The Flutter and Ruby versions come from repository-level Actions variables, so you
   cannot read the version CI actually uses out of this repository. `test-ios.yml` takes no Flutter
   version from its callers: it reads its own variable, `SPM_FLUTTER_VERSION`, and falls back to
   the version written in that file, because the example needs a Flutter with Swift Package
   Manager. Android and Trunk use `FLUTTER_VERSION`.
6. **Zizmor checks only some pull requests, and is not required.** `.github/workflows/zizmor.yml`
   fails on any finding, but it triggers only on changes under `.github/workflows/` or
   `.github/actions/`, so a change to `.github/dependabot.yml` alone gets no check even though
   zizmor audits that file. Branch protection does not require it either.
7. **The example's iOS build fails unless the checkout directory is named `rokt_sdk`.** Swift
   Package Manager takes the path-dependent plugin's package identity from the enclosing directory
   name, and when it differs, resolution stops with "unable to override package 'rokt_sdk' because
   its identity … doesn't match"
   ([flutter/flutter#186881](https://github.com/flutter/flutter/issues/186881)). A symlink does not
   help, because the real path is used. CI checks out into `rokt_sdk/` for this reason; locally,
   use a clone or a copy with that name.

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

The native Rokt SDK version appears in these places:

- `ios/rokt_sdk/Package.swift` — `Rokt-Widget` from `https://github.com/ROKT/rokt-sdk-ios`, via
  `.upToNextMajor`, which permits any minor within the major. This is the one iOS pin:
  `ios/rokt_sdk.podspec` parses the version out of this line at `pod install` time and declares
  the same range, so keep the URL and the `.upToNextMajor(from:)` form. The URL matches the one the
  mParticle Rokt kit uses, so an app with both resolves one copy of the SDK.
- `android/build.gradle` — `com.rokt:roktsdk`, from Maven Central.
- `example/ios/Runner.xcodeproj/project.pbxproj` — `RoktPaymentExtension`, as a Swift package with
  an up-to-next-major requirement. Only the example app pulls it; the plugin does not.
  `Package.resolved` is ignored, so CI builds the newest versions a new app would get.

So bump the iOS native version in `ios/rokt_sdk/Package.swift` only. Raising the minimum there
raises it for both dependency managers; to keep apps off a bad native release, raise the minimum
past it. iOS and Android are on different major version lines and
have been for several releases — do not try to make the two numbers match.

`ios/rokt_sdk/Package.swift` also path-depends on a sibling `FlutterFramework` package that the
Flutter tool generates, so it is not buildable on its own with `swift build`.

## Pull requests

- Base branch is `main`. `master` and `develop` still exist and are stale; ignore them.
- Checks include organisation-level apps not defined in this repo (Cortex catalog lint, security
  and paved-roads bots, Graphite mergeability). All checks are expected to pass on every PR here,
  so a red one is a real failure rather than background noise. Only Trunk Check and the two
  Build & Test jobs are required by branch protection, though, and both Build & Test jobs declare
  `needs: trunk-check` — so a Trunk failure reports them as skipped, not failed, and the PR still
  cannot merge.
- `main` requires an approving review from the `CODEOWNERS` team and dismisses stale approvals on
  every push, so land the approval last: a follow-up commit silently un-approves the PR. It does
  not require the branch to be current with `main`, so you never have to rebase to merge. Branch
  protection is not in the tree — read it with
  `gh api repos/ROKT/rokt-sdk-flutter/branches/main/protection` if you need to re-check this.
