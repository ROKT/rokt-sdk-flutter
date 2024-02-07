//
//  RoktEventHandler.swift
//  Rokt-Widget
//
//  Copyright 2020 Rokt Pte Ltd
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation
@objc public class RoktEventHandler: NSObject {
    private var sessionId: String
    private var pageInstanceGuid: String
    
    init(sessionId: String, pageInstanceGuid: String) {
        self.sessionId = sessionId
        self.pageInstanceGuid = pageInstanceGuid
    }
    
    @objc public func setFulfillmentAttributes(attributes: [String: String]) {
        RoktAPIHelper.sendEvent(evenRequest:
            EventRequest(sessionId: sessionId,
                         eventType: .CaptureAttributes,
                         parentGuid: sessionId,
                         attributes: attributes,
                         pageInstanceGuid: pageInstanceGuid))
    }
    
}
