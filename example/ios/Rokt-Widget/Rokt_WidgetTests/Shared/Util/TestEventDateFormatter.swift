//
//  TestEventDateFormatter.swift
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

class TestEventDateFormatter: XCTestCase {

    func test_date_formatter() throws {
        let date = Date(timeIntervalSince1970: 0)
        
        XCTAssertEqual(EventDateFormatter.getDateString(date), "1970-01-01T12:00:00.000Z")
    }
}
