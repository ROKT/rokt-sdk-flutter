//
//  TestUILabelExtensions.swift
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

class TestUILabelExtensions: XCTestCase {

    func test_setLabel_valid() {
        let textView = TextViewData(text: "Text",
                                    textStyleViewData:
            TextStyleViewData(fontFamily: "Arial",
                              fontSize: 12,
                              fontColor: [0: "#000000", 1: "#ffffff"],
                              backgroundColor: [0: "#ffffff", 1: "#000000"],
                              alignment: .center,
                              lineSpacing: 1))
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        label.set(textViewData: textView)
        
        let exp = expectation(description: "Test after 0.1 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.1)
         if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(label.font.familyName, "Arial")
            XCTAssertEqual(label.font.pointSize, 12)
            XCTAssertEqual(label.textAlignment, NSTextAlignment.center)
         } else {
             XCTFail("Delay interrupted")
         }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
