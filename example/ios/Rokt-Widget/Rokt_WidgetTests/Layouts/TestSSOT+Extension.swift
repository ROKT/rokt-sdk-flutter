//
//  TestSSOT+Extension.swift
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

final class TestSSOT_Extension: XCTestCase {
    var errors = [String]()

    override func setUpWithError() throws {
        // setup network mock
        Rokt.shared.roktTagId = "123"
        self.stubDiagnostics(onDiagnosticsReceive: { (error) in
            self.errors.append(error)
        })
    }

    func test_invalid_font_send_diagnostics() throws {
        // Arrang
        let textStylingProperties = TextStylingProperties(textColor: nil, fontSize: 18, fontFamily: "InvalidFont", fontWeight: .w100, lineHeight: nil, horizontalTextAlign: nil, baselineTextAlign: .super, fontStyle: nil, textTransform: nil, letterSpacing: nil, textDecoration: nil, lineLimit: nil)
        // Act
        let _ = textStylingProperties.weightedUIFont
        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertGreaterThan(errors.count, 0)
            XCTAssertTrue(self.errors.contains("[VIEW]"))
        } else {
            XCTFail("No error")
        }
    }    
    
    func test_valid_font_dont_send_diagnostics() throws {
        // Arrang
        let textStylingProperties = TextStylingProperties(textColor: nil, fontSize: 18, fontFamily: "Arial", fontWeight: .w100, lineHeight: nil, horizontalTextAlign: nil, baselineTextAlign: .super, fontStyle: nil, textTransform: nil, letterSpacing: nil, textDecoration: nil, lineLimit: nil)
        // Act
        let _ = textStylingProperties.weightedUIFont
        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(errors.count, 0)
        } else {
            XCTFail("Error on valid font")
        }
    }    
    
    func test_valid_font_dont_send_diagnostics_without_fontsize() throws {
        // Arrang
        let textStylingProperties = TextStylingProperties(textColor: nil, fontSize: nil, fontFamily: "Arial", fontWeight: .w100, lineHeight: nil, horizontalTextAlign: nil, baselineTextAlign: .super, fontStyle: nil, textTransform: nil, letterSpacing: nil, textDecoration: nil, lineLimit: nil)
        // Act
        let _ = textStylingProperties.weightedUIFont
        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(errors.count, 0)
        } else {
            XCTFail("Error on valid font")
        }
    }

}
