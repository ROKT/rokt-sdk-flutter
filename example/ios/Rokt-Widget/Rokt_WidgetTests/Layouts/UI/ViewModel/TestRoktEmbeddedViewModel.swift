//
//  TestRoktEmbeddedViewModel.swift
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
import Mocker

@available(iOS 15, *)
final class TestRoktEmbeddedViewModel: XCTestCase {

    var events = [EventModel]()
    var errors = [String]()
    var engagementEvents = [RoktEventType]()
    let startDate = Date()

    override func setUpWithError() throws {
        Rokt.shared.roktTagId = "123"
        self.stubEvents(onEventReceive: { [self] event in
            self.events.append(event)
        })
        self.stubDiagnostics(onDiagnosticsReceive: { (error) in
            self.errors.append(error)
        })
    }
    
    func test_plugin_impression_event() throws {
        // Arrange
        let viewModel = RoktEmbeddedViewModel(layouts: [], baseDI: get_base_di())
        
        // Act
        viewModel.sendPluginImpressionEvent()
        
        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalImpression", parentGuid: "instanceGuid")))
            let event = events[events.lastIndex(of: EventModel(eventType: "SignalImpression", parentGuid: "instanceGuid"))!]
            
            XCTAssertTrue(event.containNameInMetadata(name: BE_PAGE_SIGNAL_LOAD))
            XCTAssertTrue(event.containValueInMetadata(value: EventDateFormatter.getDateString(startDate)))
        } else {
            XCTFail("No event")
        }
    }
    
    func test_plugin_activation_event() throws {
        // Arrange
        let viewModel = RoktEmbeddedViewModel(layouts: [], baseDI: get_base_di())
        
        // Act
        viewModel.sendSignalActivationEvent()
        
        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalActivation", parentGuid: "instanceGuid")))
        } else {
            XCTFail("No event")
        }
    }
    
    func get_base_di() -> BaseDependencyInjection {
        return BaseDependencyInjection(sessionId: "session", pluginInstanceGuid: "instanceGuid", startDate: startDate)
    }
}
