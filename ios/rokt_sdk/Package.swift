// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "rokt_sdk",
    platforms: [
        .iOS("15.0"),
    ],
    products: [
        .library(name: "rokt-sdk", targets: ["rokt_sdk"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        // rokt_sdk.podspec reads this version: keep the URL and the upToNextMajor(from:) form. The URL
        // matches the one the mParticle Rokt kit uses, so an app with both resolves one copy of the SDK.
        .package(url: "https://github.com/ROKT/rokt-sdk-ios", .upToNextMajor(from: "5.3.4")),
    ],
    targets: [
        .target(
            name: "rokt_sdk",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "Rokt-Widget", package: "rokt-sdk-ios"),
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        ),
    ]
)
