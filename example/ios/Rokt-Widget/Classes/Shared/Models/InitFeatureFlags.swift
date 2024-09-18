//
//  InitFeatureFlags.swift
//  Rokt-Widget
//
//  Copyright 2020 Rokt Pte Ltd
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation

struct InitFeatureFlags {
    enum FeatureFlagType: String {
        case roktTrackingStatus
        case shouldLogFontHappyPath
        case shouldUseFontRegisterWithUrl
        case boundingBox = "mobile-sdk-use-bounding-box"
        case openUrlFromRokt = "mobile-sdk-use-open-url-from-rokt"
        case timingsEnabled = "mobile-sdk-use-timings-api"
    }

    private let roktTrackingStatus: Bool
    private let shouldLogFontHappyPath: Bool
    private let shouldUseFontRegisterWithUrl: Bool

    private let featureFlags: [String: FeatureFlagItem]

    init(roktTrackingStatus: Bool,
         shouldLogFontHappyPath: Bool,
         shouldUseFontRegisterWithUrl: Bool,
         featureFlags: [String: FeatureFlagItem]) {
        self.roktTrackingStatus = roktTrackingStatus
        self.shouldLogFontHappyPath = shouldLogFontHappyPath
        self.shouldUseFontRegisterWithUrl = shouldUseFontRegisterWithUrl
        self.featureFlags = featureFlags
    }

    func isEnabled(_ featureFlag: FeatureFlagType) -> Bool {
        switch featureFlag {
        case .roktTrackingStatus:
            return roktTrackingStatus
        case .shouldLogFontHappyPath:
            return shouldLogFontHappyPath
        case .shouldUseFontRegisterWithUrl:
            return shouldUseFontRegisterWithUrl
        default:
            return featureFlags[featureFlag.rawValue]?.match ?? false
        }
    }
}
