//
//  TestOfferViewModel.swift
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

class TestOfferViewModel: XCTestCase {
    var events = [EventModel]()
    var errors = [String]()

    override func setUpWithError() throws {
        // setup network mock
        Rokt.shared.roktTagId = "123"
        self.stubEvents(onEventReceive: { [self] event in
            self.events.append(event)
        })
        self.stubDiagnostics(onDiagnosticsReceive: { (error) in
            self.errors.append(error)
        })
    }

    func test_send_impression_event() throws {
        // Arrange
        let viewModel = OfferViewModel("", urlInExternalBrowser: false)
       
        // Act
        viewModel.sendImpressionEvent("123")

        // Assert
        let exp = expectation(description: "Test after 0.4 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.4)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalImpression", parentGuid: "123")))
        } else {
            XCTFail("No event")
        }
    }
    
    func test_webview_diagnostics() throws {
        // Arrange
        let viewModel = OfferViewModel("", urlInExternalBrowser: false)
        
        // Act
        viewModel.sendWebViewDiagnostics()
        
        // Assert
        let exp = expectation(description: "Test after 0.1 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.1)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(errors.contains(kWebViewErrorCode))
        } else {
            XCTFail("No diagnostics")
        }
        
    }
    
    func test_image_max_height_detault() throws {
        // Arrange
        let viewModel = OfferViewModel("", urlInExternalBrowser: false)
        
        // Act
        let imageMaxHeight = viewModel.getImageMaxHeight(nil)
        
        // Assert
        XCTAssertEqual(imageMaxHeight, kImageOfferHeight)
    }
    
    func test_image_max_height_custom() throws {
        // Arrange
        let viewModel = OfferViewModel("", urlInExternalBrowser: false)
        
        // Act
        let imageMaxHeight = viewModel.getImageMaxHeight(90)
        
        // Assert
        XCTAssertEqual(imageMaxHeight, 90)
    }
    
}
