//
//  TestWebViewViewModel.swift
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
//

import XCTest
import Mocker


class TestWebViewViewModel: XCTestCase {
    var events = [EventModel]()
    var errors = [String]()

    override func setUpWithError() throws {
        Rokt.shared.roktTagId = "123"
        self.stubEvents(onEventReceive: { [self] event in
            self.events.append(event)
        })
        self.stubDiagnostics(onDiagnosticsReceive: { (error) in
            self.errors.append(error)
        })
    }

    func test_webview_diagnostics() throws {
        // Arrange
        let viewModel = WebViewViewModel(url: URL(string: "https://www.rokt.com"), sessionId: "", campaignId: "")
        
        // Act
        viewModel.sendWebViewDiagnostics(URL(string: "https://www.example.com"), error: URLError(.badURL))
        
        // Assert
        let exp = expectation(description: "Test after 0.1 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.1)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(errors.contains(kWebViewErrorCode))
        } else {
            XCTFail("No diagnostics")
        }
        
    }
    
    //MARK: getErrorMessage
    func test_getErrorMessage_valid() throws {
        // Arange
        let viewModel = WebViewViewModel(url: URL(string: "https://www.rokt.com"), sessionId: "", campaignId: "")
        // Act
        let errorMessage = viewModel.getErrorMessage(URL(string: "https://www.example.com"), error: URLError(.badURL))
        
        // Assert
        XCTAssertEqual(errorMessage, "OriginalUrl: https://www.rokt.com ,brokenUrl: https://www.example.com The operation couldn’t be completed. (NSURLErrorDomain error -1000.)")
    }
        
    func test_getErrorMessage_nil() throws {
        // Arange
        let viewModel = WebViewViewModel(url: URL(string: "https://www.rokt.com"), sessionId: "", campaignId: "")
        // Act
        let errorMessage = viewModel.getErrorMessage(nil, error: URLError(.badURL))
        
        // Assert
        XCTAssertEqual(errorMessage, "OriginalUrl: https://www.rokt.com ,brokenUrl:  The operation couldn’t be completed. (NSURLErrorDomain error -1000.)")
        
    }
    
    //MARK: isSupportedUrl
    func test_isSupportedUrl_valid_http() throws {
        // Arange
        let viewModel = WebViewViewModel(url: URL(string: ""), sessionId: "", campaignId: "")
        // Act
        let isSupported = viewModel.isSupportedUrl("http://www.rokt.com")
        // Assert
        XCTAssertTrue(isSupported)
    }
    
    func test_isSupportedUrl_valid_https() throws {
        // Arange
        let viewModel = WebViewViewModel(url: URL(string: ""), sessionId: "", campaignId: "")
        // Act
        let isSupported = viewModel.isSupportedUrl("https://www.rokt.com")
        // Assert
        XCTAssertTrue(isSupported)
    }
    
    func test_isSupportedUrl_valid_https_capital() throws {
        // Arange
        let viewModel = WebViewViewModel(url: URL(string: ""), sessionId: "", campaignId: "")
        // Act
        let isSupported = viewModel.isSupportedUrl("HTTPS://www.rokt.com")
        // Assert
        XCTAssertTrue(isSupported)
    }
    
    func test_isSupportedUrl_invalid() throws {
        // Arange
        let viewModel = WebViewViewModel(url: URL(string: ""), sessionId: "", campaignId: "")
        // Act
        let isSupported = viewModel.isSupportedUrl("://something")
        // Assert
        XCTAssertFalse(isSupported)
    }

    func test_isSupportedUrl_invalid_contains() throws {
        // Arange
        let viewModel = WebViewViewModel(url: URL(string: ""), sessionId: "", campaignId: "")
        // Act
        let isSupported = viewModel.isSupportedUrl("://http:something")
        // Assert
        XCTAssertFalse(isSupported)
    }
    
}
