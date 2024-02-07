//
//  AttributedStringExtension.swift
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

import XCTest

final class TestROKTAPIHelperExtension: XCTestCase {
    // MARK: - Get Privacy Control Payload
    func test_getPrivacyControlPayload_attributeIsIncorrectType_returnsEmptyPayload() {
        let attributes = ["test": 123]

        let privacyControls = RoktAPIHelper.getPrivacyControlPayload(attributes: attributes)

        XCTAssertTrue(privacyControls.isEmpty)
    }

    func test_getPrivacyControlPayload_noPrivacyKVPs_returnsEmptyPayload() {
        let attributes = ["email": "emmanuel.tugado@rokt.com"]

        let privacyControls = RoktAPIHelper.getPrivacyControlPayload(attributes: attributes)

        XCTAssertTrue(privacyControls.isEmpty)
    }

    func test_getPrivacyControlPayload_allKVPsExist_returnsFullPayload() {
        let attributes = [
            kNoFunctional: "true",
            kNoTargeting: "false",
            kDoNotShareOrSell: "tRue",
            kGpcEnabled: "fALse"
        ]

        let privacyControls = RoktAPIHelper.getPrivacyControlPayload(attributes: attributes)

        assertPrivacyControlValues(
            privacyControls: privacyControls,
            isNoFunctional: true,
            isNoTargeting: false,
            isDoNotShareOrSell: true,
            isGPCEnabled: false
        )
    }

    func test_getPrivacyControlPayload_incompleteKVPsExist_returnsPartialPayload() {
        let attributes = [kNoTargeting: "true"]

        let privacyControls = RoktAPIHelper.getPrivacyControlPayload(attributes: attributes)

        assertPrivacyControlValues(
            privacyControls: privacyControls,
            isNoFunctional: nil,
            isNoTargeting: true,
            isDoNotShareOrSell: nil,
            isGPCEnabled: nil
        )
    }

    func test_getPrivacyControlPayload_withIncorrectValues_returnsEmptyPayload() {
        let attributes = [
            kNoFunctional: "hello",
            kNoTargeting: "world",
            kDoNotShareOrSell: "foo",
            kGpcEnabled: "bar"
        ]

        let privacyControls = RoktAPIHelper.getPrivacyControlPayload(attributes: attributes)

        XCTAssertTrue(privacyControls.isEmpty)
    }

    private func assertPrivacyControlValues(
        privacyControls: [String: Bool],
        isNoFunctional: Bool?,
        isNoTargeting: Bool?,
        isDoNotShareOrSell: Bool?,
        isGPCEnabled: Bool?
    ) {
        XCTAssertEqual(privacyControls[kNoFunctional], isNoFunctional)
        XCTAssertEqual(privacyControls[kNoTargeting], isNoTargeting)
        XCTAssertEqual(privacyControls[kDoNotShareOrSell], isDoNotShareOrSell)
        XCTAssertEqual(privacyControls[kGpcEnabled], isGPCEnabled)
    }
}

// MARK: - Remove Privacy KVP
extension TestROKTAPIHelperExtension {
    func test_removeAllPrivacyControlData_removesRelevantData() {
        let attributes = [
            kNoFunctional: "true",
            kNoTargeting: "true",
            kDoNotShareOrSell: "true",
            kGpcEnabled: "false",
            "extraData": "true"
        ]

        let sanitisedPayload = RoktAPIHelper.removeAllPrivacyControlData(attributes: attributes)

        XCTAssertEqual(sanitisedPayload.count, 1)
    }
}
