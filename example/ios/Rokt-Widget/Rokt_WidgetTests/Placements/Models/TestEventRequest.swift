//
//  TestEventRequest.swift
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

class TestEventRequest: XCTestCase {

    func test_event_with_correct_session_id_and_parenet_guid_and_event_type() {
        let eventRequest = EventRequest(sessionId: "sessionID",
                                        eventType: EventType.SignalImpression,
                                        parentGuid: "parentGuid",
                                        pageInstanceGuid: "page")
        
        XCTAssertEqual(eventRequest.sessionId, "sessionID")
        XCTAssertEqual(eventRequest.eventType, EventType.SignalImpression)
        XCTAssertEqual(eventRequest.parentGuid, "parentGuid")
        XCTAssertEqual(eventRequest.pageInstanceGuid, "page")
    }

    func test_event_create_date() {
        let eventTime = Date()
        let eventRequest = EventRequest(sessionId: "", eventType: EventType.SignalImpression, parentGuid: "", eventTime: eventTime)
        
        XCTAssertNotNil(eventRequest.metadata)
        XCTAssertNotNil(eventRequest.metadata[0])
        XCTAssertEqual(eventRequest.metadata[0].name, BE_CLIENT_TIME_STAMP)
        XCTAssertEqual(eventRequest.metadata[0].value, EventDateFormatter.getDateString(eventTime))
        XCTAssertNotNil(eventRequest.metadata[0].value)
    }
    
    func test_event_create_capture_method() {
        let eventRequest = EventRequest(sessionId: "", eventType: EventType.SignalImpression, parentGuid: "")
        
        XCTAssertNotNil(eventRequest.metadata[1])
        XCTAssertEqual(eventRequest.metadata[1].name, BE_CAPTURE_METHOD)
        XCTAssertEqual(eventRequest.metadata[1].value, kClientProvided)
    }
    
    func test_event_get_atrributes() {
        let eventRequest = EventRequest(sessionId: "", eventType: EventType.CaptureAttributes, parentGuid: "",
                                        attributes: ["email":"email@gmail.com"])
        
        XCTAssertNotNil(eventRequest.attributes[0])
        XCTAssertEqual(eventRequest.attributes[0].name, "email")
        XCTAssertEqual(eventRequest.attributes[0].value, "email@gmail.com")
    }
    
    func test_event_create_currect_time_stamp() {
        let eventRequest = EventRequest(sessionId: "", eventType: EventType.SignalImpression, parentGuid: "")
        let timeStampRegex = "^[0-9]{4}-[0-9]{2}-[0-9]{2}T([0-9]{2}:){2}[0-9]{2}.[0-9]{3}Z$"
        
        XCTAssertNotNil(eventRequest.metadata[0].value)
        XCTAssertTrue(matchesRegex(eventRequest.metadata[0].value, regex: timeStampRegex))
    }
    
    func test_event_get_params() {
        let eventRequest = EventRequest(sessionId: "sessionID",
                                        eventType: EventType.SignalImpression,
                                        parentGuid: "parentGuid",
                                        pageInstanceGuid: "page")
        
        let params = eventRequest.getParams()
        
        XCTAssertEqual(params[BE_SESSION_ID_KEY] as! String, "sessionID")
        XCTAssertEqual(params[BE_PARENT_GUID_KEY] as! String, "parentGuid")
        XCTAssertEqual(params[BE_PAGE_INSTANCE_GUID_KEY] as! String, "page")
        XCTAssertEqual(params[BE_EVENT_TYPE_KEY] as! String, EventType.SignalImpression.rawValue)
        XCTAssertNotNil(params[BE_ATTRIBUTES_KEY])
        XCTAssertNotNil(params[BE_INSTANCE_GUID])
        XCTAssertNotNil(params[BE_METADATA_KEY])
        
    }
    
    func test_event_get_params_defaults() {
        let eventRequest = EventRequest(sessionId: "sessionID",
                                        eventType: EventType.CaptureAttributes,
                                        parentGuid: "parentGuid")
        
        let params = eventRequest.getParams()
        
        XCTAssertEqual(params[BE_PAGE_INSTANCE_GUID_KEY] as! String, "")
        XCTAssertEqual(params[BE_EVENT_TYPE_KEY] as! String, EventType.CaptureAttributes.rawValue)
        XCTAssertNotNil(params[BE_METADATA_KEY])
        XCTAssertNotNil(params[BE_INSTANCE_GUID])
        XCTAssertNotNil(eventRequest.metadata[0])
        XCTAssertEqual(eventRequest.metadata[0].name, BE_CLIENT_TIME_STAMP)
        XCTAssertNotNil(eventRequest.metadata[0].value)
        XCTAssertEqual(eventRequest.metadata[1].name, BE_CAPTURE_METHOD)
        XCTAssertEqual(eventRequest.metadata[1].value, kClientProvided)
        XCTAssertNotNil(params[BE_ATTRIBUTES_KEY])
        
        
    }

    func matchesRegex(_ text: String, regex: String) -> Bool {
        return text.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }

}
