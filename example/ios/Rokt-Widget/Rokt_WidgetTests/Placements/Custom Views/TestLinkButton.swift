//
//  TestLinkButton.swift
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

class TestLinkButton: XCTestCase {

    func test_link_button() {
        let linkViewData = getDefualtLinkView(text: "click me")
        
        let linkButton = LinkButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        
        linkButton.set(linkViewData: linkViewData)
        let exp = expectation(description: "Test after 0.1 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.1)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(linkButton.titleLabel?.text, "click me")
            XCTAssertEqual(linkButton.titleLabel?.textColor.cgColor, UIColor(hexString: "#000000").cgColor)
            XCTAssertEqual(linkButton.titleLabel?.font.familyName, "Arial")
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    func test_link_button_with_html() {
        let linkViewData = getDefualtLinkView(text: "click <b>me</b>")
        
        let linkButton = LinkButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        
        linkButton.set(linkViewData: linkViewData)
        let exp = expectation(description: "Test after 0.1 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.1)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(linkButton.titleLabel?.text, "click me")
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    private func getDefualtLinkView(text: String) -> LinkViewData {
        let defaultTextStyle = TextStyleViewData(fontFamily: "Arial",
                                                 fontSize: 12,
                                                 fontColor: [0: "#000000", 1: "#ffffff"],
                                                 backgroundColor: [0: "#ffffff", 1: "#000000"])
        return LinkViewData(text: text, link: "", textStyleViewData: defaultTextStyle, underline: false)
    }

}
