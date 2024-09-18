//
//  TestUIButtonExtension.swift
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

class TestUIButtonExtension: XCTestCase {

    func test_set_text_buttonstyles() {
        let defaultTextStyle = TextStyleViewData(fontFamily: "Arial",
                                                 fontSize: 12,
                                                 fontColor: [0: "#000000", 1: "#ffffff"],
                                                 backgroundColor: [0: "#ffffff", 1: "#000000"])
        let pressedTextStyle = TextStyleViewData(fontFamily: "Arial",
                                                 fontSize: 12,
                                                 fontColor: [0: "#333333", 1: "#ffffff"],
                                                 backgroundColor: [0: "#aaaaaa", 1: "#000000"])
        
        let styles = ButtonStylesViewData(
            defaultStyle: ButtonStyleViewData(textStyleViewData: defaultTextStyle,
                                              cornerRadius: 5, borderThickness: 3,
                                              borderColor: [0: "#121212", 1: "#333333"]),
            pressedStyle: ButtonStyleViewData(textStyleViewData: pressedTextStyle,
                                              cornerRadius: 5, borderThickness: 3,
                                              borderColor: [0: "#121212", 1: "#333333"]))
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        
        button.set(text: "test", styles: styles, traitCollection: button.traitCollection)
        let exp = expectation(description: "Test after 0.1 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.1)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(button.titleLabel?.text, "test")
            XCTAssertEqual(button.titleLabel?.textColor.cgColor, UIColor(hexString: "#000000").cgColor)
            XCTAssertEqual(button.titleLabel?.font.familyName, "Arial")
        } else {
            XCTFail("Delay interrupted")
        }
        
    }
    
    func test_set_text_textstyle() {
        let defaultTextStyle = TextStyleViewData(fontFamily: "Arial",
                                                 fontSize: 12,
                                                 fontColor: [0: "#000000", 1: "#ffffff"],
                                                 backgroundColor: [0: "#ffffff", 1: "#000000"])
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        
        button.set(text: "test", textStyle: defaultTextStyle, for: .normal, traitCollection: button.traitCollection)
        let exp = expectation(description: "Test after 0.1 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.1)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(button.titleLabel?.text, "test")
            XCTAssertEqual(button.titleLabel?.textColor.cgColor, UIColor(hexString: "#000000").cgColor)
            XCTAssertEqual(button.titleLabel?.font.familyName, "Arial")
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    func test_set_text_textstyle_html_valid() {
        let defaultTextStyle = TextStyleViewData(fontFamily: "Arial",
                                                 fontSize: 12,
                                                 fontColor: [0: "#000000", 1: "#ffffff"],
                                                 backgroundColor: [0: "#ffffff", 1: "#000000"])
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        
        button.set(text: "<b>test</b>", textStyle: defaultTextStyle, for: .normal,
                   traitCollection: button.traitCollection)
        let exp = expectation(description: "Test after 0.1 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.1)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(button.titleLabel?.text, "test")
        } else {
            XCTFail("Delay interrupted")
        }
        
    }
    
    func test_set_border() {
        let defaultTextStyle = TextStyleViewData(fontFamily: "Arial",
                                                 fontSize: 12,
                                                 fontColor: [0: "#000000", 1: "#ffffff"],
                                                 backgroundColor: [0: "#ffffff", 1: "#000000"])
        
        let buttonStyleViewData = ButtonStyleViewData(textStyleViewData: defaultTextStyle,
                                                      cornerRadius: 5,
                                                      borderThickness: 3,
                                                      borderColor: [0: "#545454", 1: "#656565"])
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        
        button.setBorder(style: buttonStyleViewData, traitCollection: button.traitCollection)
        
        XCTAssertEqual(button.layer.cornerRadius, 5)
        XCTAssertEqual(button.layer.borderWidth, 3)
        XCTAssertEqual(button.layer.borderColor, UIColor(hexString: "#545454").cgColor)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
