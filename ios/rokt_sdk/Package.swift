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
        .package(name: "Rokt-Widget", url: "https://github.com/ROKT/rokt-sdk-ios.git", .upToNextMajor(from: "5.3.4")),
    ],
    targets: [
        .target(
            name: "rokt_sdk",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "Rokt-Widget", package: "Rokt-Widget"),
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ],
            cSettings: [
                .headerSearchPath("include/rokt_sdk"),
            ]
        ),
    ]
)
