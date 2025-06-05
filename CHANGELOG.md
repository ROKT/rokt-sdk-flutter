<!-- markdownlint-disable MD024 -->

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [4.10.0] - 2025-06-04

### Added

- Real time events
- Support new response action type `ExternalPaymentTrigger`
- Sessions are now retained between app restarts

### Fixed

- Fixed the issue with cross-platform embedded layout height in position 2+

## [4.9.0] - 2025-04-04

### Added

- Added Passthrough links support to the OpenUrl event

### Fixed

- Fix an issue with border radius not being correctly applied
- Fix Rokt.close() API not closing the overlay and bottomsheet as expected
- Fixed a crash due to Navigation Component ViewModelOwner mismatch
- Fixed the issue with cross-platform embedded layout height calculation

## [4.8.1] - 2025-02-27

### Fixed

- Fix button pressed style not working
- Fix text color in dark mode
- Fix unwanted PlacementFailure partner event
- Fix navigation Bar black color display

## [4.8.0] - 2025-02-05

### Added

- Added [UX Helper](https://github.com/ROKT/rokt-ux-helper-android) as a dependency to handle all rendering logic
- Added support for Edge to edge display

### Fixed

- Theming conflicts with partner applications by prefixing all resources with rokt\_

## [4.7.0] - 2024-12-17

### Added

- Add caching support

### Fixed

- Fix untagged socket strict mode violation issue
- Fix bottomSheet not closing fully due to order change in backhandler
- Fix font weight issue when font postscript name is used

## [4.6.1] - 2024-10-31

### Fixed

- Fixed ANR issues during Rokt.init call
- Fixed container shadow
- Fix app crash when using androidxNavigation 2.8.1 or above

## [4.6.0] - 2024-09-27

### Added

- Add expand to show functionality
- Added new Rokt.init function with ability to have callback and events
- Modifier and Events in the Jetpack Composable API integration

### Fixed

- Fixed status bar color issue
- Fixed bottomsheet height change animation
- Add wait for init to complete when execute is called
- Made partner callback in execute a weak reference
- Fix crash when Activity becomes null
- Rare ANR issues on init
- Fix container shadow issue
- Fix app crash when using androidxNavigation 2.8.1

## [4.5.1] - 2024-08-23

### Fixed

- Fixed app crash on RecyclerView due to Jetpack Compose viewCompositionStrategy

## [4.5.0] - 2024-08-09

### Added

- Added ScrollableRow and ScrollableColumn layout
- Added NonInteractableChildren, OuterLayoutNonInteractableChildren, and LayoutVariantNonInteractableChildren
- Added FlexJustification and FlexAlignment for Container styling properties (FlexChild also uses FlexAlignment)

### Removed

- Removed scroll and auto properties from Overflow enum
- Removed is_important_for_accessibility properties from DataIcon, DataImage, StaticIcon, StaticImage, and ProgressIndicator
- Removed CloseButtonChildren, CreativeResponseChildren, ProgressControlChildren, StaticLinkChildren, and StaticLinkLayoutVariantChildren
- Removed settings property from ProgressIndicator, GroupedDistribution, CarouselDistribution, and Overlay nodes
- Removed LayoutStyleTransition
- Removed FlexPosition
- Removed CreativeCopy and Position predicates from the Outer Layout

### Changed

- Changed is_important_for_accessibility to accessibility_hidden in ProgressIndicator
- Changed WhenTransition property names from `in` and `out` to `in_transition` and `out_transition` respectively
- Changed how styling transitions are defined with updated LayoutStyles generic
- Changed OverlayChildren to ModalChildren with closeOnComplete support

### Fixed

- Fixed app crash when loaded corrupted fonts
- Downloading fonts in init simultaneously
- Fixed rich text link styling
- Fixed nested data binding in creative response

## [4.4.1] - 2024-07-16

### Fixed

- Fixed `Execute` call without `init` state issue causing application crash due to missing dependencies

## [4.4.0] - 2024-07-03

### Added

- Rokt partner app configuration setting to control color mode
- Metrics to capture lost Execute calls on failed Inits for improved PRF measurement

### Fixed

- Fixed multi-page session issue
- Fixed Bottomsheet restart issue

## [4.3.1] - 2024-05-23

### Fixed

- Fixed default Bottom-sheet animation issue
- SDK state restoration on Activity restart
- Ensured placement persists when app is resumed
- Jetpack Compose recomposition fixes

## [4.3.0] - 2024-04-23

### Added

- Feature flag support
- Partner events integration
- Layout builder support

### Fixed

- Fixed Flutter embedded placement on Android 14
- Fixed app crash on process restart
- Fixed Kotlin flow invariant violation

## [4.2.2] - 2024-03-27

### Fixed

- Fixed signal recording issue

## [4.2.1] - 2024-03-21

### Fixed

- Fixed font management to support both font family and postscript names

## [4.2.0] - 2024-03-13

### Added

- Font management improvements

## [4.1.0] - 2024-02-26

### Added

- Carousel distribution
- Grouped distribution
- Accessibility support
- SignalViewed reporting

### Fixed

- Fixed onShouldShowLoadingIndicator and onShouldHideLoadingIndicator callbacks
- Fixed back button behavior on overlay
- Removed unwanted ripple animation on buttons

## [4.0.0-alpha.3]

### Added

- Introduces Layouts

## [3.15.0]

### Added

- Support for additional close button at the bottom of the placement and updates to header design.

## [3.14.2]

### Changed

- Updated Rokt SDKs and interfaces and General bug fixes

## [3.14.1]

### Changed

- Updated Rokt SDKs and interfaces

## [3.14.0]

### Added

- Added Support for New Layout and General bug fixes.

## [3.13.0]

### Changed

- Updated Rokt SDKs and interfaces, text-based progress bar

## [3.12.1-alpha.2]

### Changed

- Updated Rokt SDKs and interfaces

## [3.12.1-alpha.1]

### Changed

- Updated Rokt SDKs and interfaces

## [3.12.1]

### Changed

- Updated Rokt SDKs and interfaces, Allow static links to be opened with the default mobile browser.

## [3.12.0]

### Changed

- Updated Rokt SDKs and interfaces, Bug fixes, close placements on negative button, and updates to styling configurables.

## [3.11.0]

### Changed

- Updated Rokt SDKs and interfaces, support show image on dark mode.

## [3.10.1-alpha.2]

### Changed

- Updated Rokt SDKs and interfaces

## [3.10.1-alpha.1]

### Changed

- Updated Rokt SDKs and interfaces

## [3.10.0]

### Added

- Support word wrap for Title text.

### Changed

- Updated Rokt SDKs and interfaces.

## [3.9.1]

### Changed

- Updated Rokt SDKs and interfaces, performance improvements and bug fixes

## [3.9.0]

### Changed

- Updated Rokt SDKs and interfaces
- Use default mobile browser for actions.

## [3.8.0]

### Added

- Bottomsheet placement

### Changed

- Updated Rokt SDKs and interfaces.

## [3.7.0]

### Changed

- Updated Rokt SDKs and interfaces, Customisable progress bar

## [3.6.3]

### Added

- Flutter SDK 3.0 supported

## [3.6.3-alpha.1]

### Added

- Supporting Flutter SDK 3.0

## [3.6.2]

### Changed

- Updated Padding and Margin for Embedded Placement

## [3.6.1]

### Changed

- Updated Rokt SDKs and interfaces

## [3.6.0]

- Introducing Rokt flutter SDK

[unreleased]: https://github.com/ROKT/rokt-sdk-flutter/compare/4.10.0...HEAD
[4.10.0]: https://github.com/ROKT/rokt-sdk-flutter/compare/4.9.0...4.10.0
[4.9.0]: https://github.com/ROKT/rokt-sdk-flutter/compare/v4.8.1...4.9.0
[4.8.1]: https://github.com/ROKT/rokt-sdk-flutter/compare/v4.8.0...v4.8.1
[4.8.0]: https://github.com/ROKT/rokt-sdk-flutter/compare/v4.7.0...v4.8.0
[4.7.0]: https://github.com/ROKT/rokt-sdk-flutter/compare/v4.6.1...v4.7.0
[4.6.1]: https://github.com/ROKT/rokt-sdk-flutter/compare/v4.6.0...v4.6.1
[4.6.0]: https://github.com/ROKT/rokt-sdk-flutter/compare/v4.5.1...v4.6.0
[4.5.1]: https://github.com/ROKT/rokt-sdk-flutter/compare/v4.5.0...v4.5.1
[4.5.0]: https://github.com/ROKT/rokt-sdk-flutter/compare/v4.4.1...v4.5.0
[4.4.1]: https://github.com/ROKT/rokt-sdk-flutter/compare/v4.4.0...v4.4.1
[4.4.0]: https://github.com/ROKT/rokt-sdk-flutter/compare/v4.3.1...v4.4.0
[4.3.1]: https://github.com/ROKT/rokt-sdk-flutter/compare/v4.3.0...v4.3.1
[4.3.0]: https://github.com/ROKT/rokt-sdk-flutter/compare/v4.2.2...v4.3.0
[4.2.2]: https://github.com/ROKT/rokt-sdk-flutter/compare/v4.2.1...v4.2.2
[4.2.1]: https://github.com/ROKT/rokt-sdk-flutter/compare/v4.2.0...v4.2.1
[4.2.0]: https://github.com/ROKT/rokt-sdk-flutter/compare/v4.1.0...v4.2.0
[4.1.0]: https://github.com/ROKT/rokt-sdk-flutter/compare/v4.0.11-alpha.100...v4.1.0
[4.0.0-alpha.3]: https://github.com/ROKT/rokt-sdk-flutter/compare/v3.15.0...v4.0.0-alpha.3
[3.15.0]: https://github.com/ROKT/rokt-sdk-flutter/compare/v3.14.2...v3.15.0
[3.14.2]: https://github.com/ROKT/rokt-sdk-flutter/compare/v3.14.1...v3.14.2
[3.14.1]: https://github.com/ROKT/rokt-sdk-flutter/compare/v3.14.0...v3.14.1
[3.14.0]: https://github.com/ROKT/rokt-sdk-flutter/compare/v3.13.0...v3.14.0
[3.13.0]: https://github.com/ROKT/rokt-sdk-flutter/compare/v3.12.1...v3.13.0
[3.12.1-alpha.2]: https://github.com/ROKT/rokt-sdk-flutter/compare/v3.12.1...v3.12.1-alpha.2
[3.12.1-alpha.1]: https://github.com/ROKT/rokt-sdk-flutter/compare/v3.12.1...v3.12.1-alpha.1
[3.12.1]: https://github.com/ROKT/rokt-sdk-flutter/compare/v3.12.0...v3.12.1
[3.12.0]: https://github.com/ROKT/rokt-sdk-flutter/compare/v3.11.0...v3.12.0
[3.11.0]: https://github.com/ROKT/rokt-sdk-flutter/compare/v3.10.0...v3.11.0
[3.10.1-alpha.2]: https://github.com/ROKT/rokt-sdk-flutter/compare/v3.10.0...v3.10.1-alpha.2
[3.10.1-alpha.1]: https://github.com/ROKT/rokt-sdk-flutter/compare/v3.10.0...v3.10.1-alpha.1
[3.10.0]: https://github.com/ROKT/rokt-sdk-flutter/compare/v3.9.1...v3.10.0
[3.9.1]: https://github.com/ROKT/rokt-sdk-flutter/compare/v3.9.0...v3.9.1
[3.9.0]: https://github.com/ROKT/rokt-sdk-flutter/compare/v3.8.0...v3.9.0
[3.8.0]: https://github.com/ROKT/rokt-sdk-flutter/compare/v3.7.0...v3.8.0
[3.7.0]: https://github.com/ROKT/rokt-sdk-flutter/compare/v3.6.3...v3.7.0
[3.6.3]: https://github.com/ROKT/rokt-sdk-flutter/compare/v3.6.2...v3.6.3
[3.6.3-alpha.1]: https://github.com/ROKT/rokt-sdk-flutter/compare/v3.6.2...v3.6.3-alpha.1
[3.6.2]: https://github.com/ROKT/rokt-sdk-flutter/compare/v3.6.1...v3.6.2
[3.6.1]: https://github.com/ROKT/rokt-sdk-flutter/compare/v3.6.0...v3.6.1
[3.6.0]: https://github.com/ROKT/rokt-sdk-flutter/releases/tag/v3.6.0
