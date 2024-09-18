//
//  TestNetworkingHelper.swift
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

class TestNetworkingHelper: XCTestCase {

    func test_common_header_defaults() throws {
        let headers = NetworkingHelper.getCommonHeaders([:])
        
        XCTAssertNotNil(headers["rokt-os-type"])
        XCTAssertNotNil(headers["rokt-ui-locale"])
        XCTAssertNotNil(headers["Content-Type"])
        XCTAssertNotNil(headers["rokt-os-version"])
        XCTAssertNotNil(headers["rokt-device-model"])
        XCTAssertNotNil(headers["Accept"])
        XCTAssertNotNil(headers["rokt-package-name"])
    }

}
