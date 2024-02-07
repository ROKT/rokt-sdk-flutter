//
//  TestEventProcessor.swift
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

final class TestEventProcessor: XCTestCase {
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

    // MARK: Events
    
    func test_signal_load_start_event() throws {
        // Arrange
        let eventProcessor = get_event_processor()
        
        // Act
        eventProcessor.sendSignalLoadStartEvent()
        
        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalLoadStart", parentGuid: "instanceGuid")))
        } else {
            XCTFail("No event")
        }
    }
    
    func test_signal_load_complete_event() throws {
        // Arrange
        let eventProcessor = get_event_processor()
        
        // Act
        eventProcessor.sendSignalLoadCompleteEvent()
        
        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalLoadComplete", parentGuid: "instanceGuid")))
        } else {
            XCTFail("No event")
        }
    }
    
    func test_plugin_impression_event() throws {
        // Arrange
        let eventProcessor = get_event_processor()
        
        // Act
        eventProcessor.sendPluginImpressionEvent()
        
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
    
    func test_slot_impression_event() throws {
        // Arrange
        let eventProcessor = get_event_processor()
        
        // Act
        eventProcessor.sendSlotImpressionEvent(instanceGuid: "instanceGuid")
        
        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalImpression", parentGuid: "instanceGuid")))
        } else {
            XCTFail("No event")
        }
    }
    
    func test_plugin_activation_event() throws {
        // Arrange
        let eventProcessor = get_event_processor()
        
        // Act
        eventProcessor.sendSignalActivationEvent()
        
        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalActivation", parentGuid: "instanceGuid")))
        } else {
            XCTFail("No event")
        }
    }
    
    func test_dismissal_no_more_offer_event() throws {
        // Arrange
        var eventProcessor = get_event_processor()
        
        // Act
        eventProcessor.dismissOption = .noMoreOffer
        eventProcessor.sendDismissalEvent()
        
        // Assert
        let exp = expectation(description: "Test after 0.35 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.35)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalDismissal", parentGuid: "instanceGuid")))
            let event = events[events.lastIndex(of: EventModel(eventType: "SignalDismissal", parentGuid: "instanceGuid"))!]
            
            XCTAssertTrue(event.containNameInMetadata(name: kInitiator))
            XCTAssertTrue(event.containValueInMetadata(value: kNoMoreOfferToShow))
        } else {
            XCTFail("No event")
        }
    }
    
    func test_dismissal_dimissed_event() throws {
        // Arrange
        var eventProcessor = get_event_processor()
        
        // Act
        eventProcessor.dismissOption = .defaultDismiss
        eventProcessor.sendDismissalEvent()
        
        // Assert
        let exp = expectation(description: "Test after 0.5 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.5)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalDismissal", parentGuid: "instanceGuid")))
            let event = events[events.lastIndex(of: EventModel(eventType: "SignalDismissal", parentGuid: "instanceGuid"))!]
            
            XCTAssertTrue(event.containNameInMetadata(name: kInitiator))
            XCTAssertTrue(event.containValueInMetadata(value: kDismissed))
        } else {
            XCTFail("No event")
        }
    }
    
    func get_event_processor() -> EventProcessor {
        return EventProcessor(sessionId: "session", pluginInstanceGuid: "instanceGuid", startDate: startDate)
    }
}
