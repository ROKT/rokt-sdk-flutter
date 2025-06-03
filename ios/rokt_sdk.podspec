#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint rokt_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'rokt_sdk'
  s.version          = '4.10.0'
  s.summary          = 'Rokt Mobile SDK to integrate ROKT Api into Flutter application'
  s.description      = <<-DESC
Rokt Mobile SDK to integrate ROKT Api into Flutter application.
                       DESC
  s.homepage         = 'https://docs.rokt.com/docs/developers/integration-guides/flutter/overview'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'ROKT DEV' => 'nativeappsdev@rokt.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'Rokt-Widget', '4.10.0'
  s.platform = :ios, '12.0'
  s.resource_bundles = { "Rokt-Widget" => ["PrivacyInfo.xcprivacy"] }

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
