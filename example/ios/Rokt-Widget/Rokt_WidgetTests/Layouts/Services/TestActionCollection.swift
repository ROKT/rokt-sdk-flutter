//
//  TestEventCollection.swift
//  Rokt_WidgetTests
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import XCTest

final class TestActionCollection: XCTestCase {

    func test_event_collection_valid() {
        // Arrange
        var closeCalled = false
        func closeOverlay(_: Any? = nil) {
            closeCalled = true
        }
        ActionCollection.shared[.close] = closeOverlay
        // Act
        ActionCollection.shared[.close](nil)
        
        // Assert
        XCTAssertTrue(closeCalled)
    }
    
    
    func test_event_collection_invalid() {
        // Arrange
        var closeCalled = false
        func closeOverlay(_: Any? = nil) {
            closeCalled = true
        }
        ActionCollection.shared[.close] = closeOverlay
        // Act
        ActionCollection.shared[.nextOffer](nil)
        
        // Assert
        XCTAssertFalse(closeCalled)
    }
}
