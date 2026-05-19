# AGENTS

## Versioning

- Never edit the `VERSION` file, `version:` in `pubspec.yaml`, or `s.version` in `ios/rokt_sdk.podspec`. The Flutter plugin version is bumped by the release workflow, not in feature PRs.
- Native SDK dependency versions (`Rokt-Widget` in the podspec, `com.rokt:roktsdk` in `android/build.gradle`) can be bumped as part of feature work that requires them.
- Add user-visible changes to the `## [Unreleased]` section of `CHANGELOG.md`. Do not add a new dated version heading — the release workflow does that.
