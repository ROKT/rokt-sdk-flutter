#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint rokt_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'rokt_sdk'
  s.version          = '5.2.0'
  s.summary          = 'Rokt Mobile SDK to integrate ROKT Api into Flutter application'
  s.description      = <<-DESC
Rokt Mobile SDK to integrate ROKT Api into Flutter application.
                       DESC
  s.homepage         = 'https://docs.rokt.com/docs/developers/integration-guides/flutter/overview'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'ROKT DEV' => 'nativeappsdev@rokt.com' }
  s.source           = { :path => '.' }
  s.source_files = 'rokt_sdk/Sources/rokt_sdk/**/*.swift'
  s.dependency 'Flutter'
  # CocoaPods support is deprecated: Flutter builds the plugin with Swift Package Manager by default.
  # The Swift package manifest holds the one copy of the native SDK version; read it so the two cannot drift.
  manifest = File.read(File.join(__dir__, 'rokt_sdk', 'Package.swift'))
  sdk_version = manifest[/rokt-sdk-ios",\s*\.upToNextMajor\(from: "([^"]+)"\)/, 1] or
    raise 'rokt_sdk.podspec: rokt-sdk-ios version not found in Package.swift'
  s.dependency 'Rokt-Widget', ">= #{sdk_version}", "< #{sdk_version.to_i + 1}.0"
  s.platform = :ios, '15.0'
  s.resource_bundles = { "Rokt-Widget" => ["rokt_sdk/Sources/rokt_sdk/PrivacyInfo.xcprivacy"] }

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
