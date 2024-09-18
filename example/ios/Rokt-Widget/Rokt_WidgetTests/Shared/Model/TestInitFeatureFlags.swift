//
//  TestInitFeatureFlags.swift
//  Rokt_WidgetTests
//
//  Copyright 2020 Rokt Pte Ltd
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import XCTest

final class TestInitFeatureFlags: XCTestCase {

    func test_default_init_feature_flag_is_off() {
        // Arrange
        let featureFlags = ["test": FeatureFlagItem(match: true)]
       
        // Act
        let isEnabled = getFeatureFlag(featureFlags).isEnabled(.openUrlFromRokt)

        // Assert
        XCTAssertFalse(isEnabled)
    }
    
    func test__init_feature_flag_is_off() {
        // Arrange
        let featureFlags = ["mobile-sdk-use-open-url-from-rokt": FeatureFlagItem(match: false)]
       
        // Act
        let isEnabled = getFeatureFlag(featureFlags).isEnabled(.openUrlFromRokt)

        // Assert
        XCTAssertFalse(isEnabled)
    }    
    
    func test__init_feature_flag_is_on() {
        // Arrange
        let featureFlags = ["mobile-sdk-use-open-url-from-rokt": FeatureFlagItem(match: true)]
       
        // Act
        let isEnabled = getFeatureFlag(featureFlags).isEnabled(.openUrlFromRokt)

        // Assert
        XCTAssertTrue(isEnabled)
    }


    private func getFeatureFlag(_ features: [String: FeatureFlagItem]) -> InitFeatureFlags {
        return InitFeatureFlags(roktTrackingStatus: true,
                                shouldLogFontHappyPath: false,
                                shouldUseFontRegisterWithUrl: false,
                                featureFlags: features)
    }
}
