//
//  TestOfferButton.swift
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

class TestOfferButton: XCTestCase {
    
    func test_offer_button_initialized() {
        let styles = getDefualtStyles()
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        let button = OfferButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30),
                                 buttonStyles: styles, traitCollection: view.traitCollection)
        
        XCTAssertEqual(button.layer.cornerRadius, 5)
        XCTAssertEqual(button.layer.borderWidth, 3)
        XCTAssertEqual(button.layer.borderColor, UIColor(hexString: "#121212").cgColor)
        
    }
    
    func test_offer_button_with_html_text() {
        let styles = getDefualtStyles()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        let button = OfferButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30),
                                 buttonStyles: styles, traitCollection: view.traitCollection)
        
        button.set(text: "<strong>yes</strong>", styles: styles, traitCollection: button.traitCollection)
        let exp = expectation(description: "Test after 0.5 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.5)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(button.titleLabel?.text, "yes")
            XCTAssertEqual(button.titleLabel?.textColor.cgColor, UIColor(hexString: "#000000").cgColor)
            XCTAssertEqual(button.titleLabel?.font.familyName, "Arial")
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    func test_offer_button_update_text() {
        let styles = getDefualtStyles()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        let button = OfferButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30),
                                 buttonStyles: styles, traitCollection: view.traitCollection)
        
        button.updateButtons(text: "no")
        let exp = expectation(description: "Test after 0.5 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.5)
         if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(button.titleLabel?.text, "no")
         } else {
             XCTFail("Delay interrupted")
         }
    }
    
    func test_offer_button_update_html_text() {
        let styles = getDefualtStyles()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        let button = OfferButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30),
                                 buttonStyles: styles, traitCollection: view.traitCollection)
        
        button.updateButtons(text: "<i>no</i>")
        let exp = expectation(description: "Test after 0.5 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.5)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(button.titleLabel?.text, "no")
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    private func getDefualtStyles() -> ButtonStylesViewData {
        let defaultTextStyle = TextStyleViewData(fontFamily: "Arial",
                                                 fontSize: 12,
                                                 fontColor: [0: "#000000", 1: "#ffffff"],
                                                 backgroundColor: [0: "#ffffff", 1: "#000000"])
        let pressedTextStyle = TextStyleViewData(fontFamily: "Arial",
                                                 fontSize: 12,
                                                 fontColor: [0: "#333333", 1: "#ffffff"],
                                                 backgroundColor: [0: "#aaaaaa", 1: "#000000"])
        
        return ButtonStylesViewData(
            defaultStyle: ButtonStyleViewData(textStyleViewData: defaultTextStyle,
                                              cornerRadius: 5, borderThickness: 3,
                                              borderColor: [0: "#121212", 1: "#333333"]),
            pressedStyle: ButtonStyleViewData(textStyleViewData: pressedTextStyle,
                                              cornerRadius: 5, borderThickness: 3,
                                              borderColor: [0: "#121212", 1: "#333333"]))
    }

}
