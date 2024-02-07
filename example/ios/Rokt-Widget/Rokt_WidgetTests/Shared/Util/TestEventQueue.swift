//
//  TestEventQueue.swift
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

class TestEventQueue: XCTestCase {

    func test_send_one_event() {
        let expectation = self.expectation(description: "event to be called")
        EventQueue.call(event: EventRequest(sessionId: "session",
                                            eventType: .SignalLoadStart,
                                            parentGuid: "2")) { events in
            XCTAssertEqual(events.count, 1)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func test_send_two_events_separatly() {
        let expectation1 = self.expectation(description: "first event to be called")
        EventQueue.call(event: getSampleEvent()) { events in
            XCTAssertEqual(events.count, 1)
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
        
        let expectation2 = self.expectation(description: "second event to be called")
        EventQueue.call(event: getSampleEvent()) { events in
            XCTAssertEqual(events.count, 1)
            expectation2.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func test_send_multipe_events_together() {
        let expectation = self.expectation(description: "events to be called")
        EventQueue.call(event: getSampleEvent()) { _ in
        }
        EventQueue.call(event: getSampleEvent()) { _ in
        }
        EventQueue.call(event: getSampleEvent()) { _ in
        }
        EventQueue.call(event: getSampleEvent()) { events in
            XCTAssertEqual(events.count, 4)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func test_send_multipe_events_with_two_calls() {
        let expectation = self.expectation(description: "first events to be called")
        EventQueue.call(event: getSampleEvent()) { _ in
        }
        EventQueue.call(event: getSampleEvent()) { events in
            XCTAssertEqual(events.count, 2)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
        
        let expectation2 = self.expectation(description: "second events to be called")
        EventQueue.call(event: getSampleEvent()) { _ in
        }
        EventQueue.call(event: getSampleEvent()) { _ in
        }
        EventQueue.call(event: getSampleEvent()) { events in
            XCTAssertEqual(events.count, 3)
            expectation2.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    private func getSampleEvent() -> EventRequest {
        return EventRequest(sessionId: "", eventType: .SignalLoadStart, parentGuid: "")
    }

}
