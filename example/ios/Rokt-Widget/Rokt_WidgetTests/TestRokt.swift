//
//  Rokt_WidgetTests.swift
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

class TestRokt: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_setEnvironment_valid_Stage() {
        Rokt.setEnvironment(environment: .Stage)
        XCTAssertEqual(config.environment, Environment.Stage)
        XCTAssertEqual(kBaseURL, Environment.Stage.baseURL)
    }
    
    func test_setEnvironment_valid_Prod() {
        Rokt.setEnvironment(environment: .Prod)
        XCTAssertEqual(config.environment, Environment.Prod)
        XCTAssertEqual(kBaseURL, Environment.Prod.baseURL)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
