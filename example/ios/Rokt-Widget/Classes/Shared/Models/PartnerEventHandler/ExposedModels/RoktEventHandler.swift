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

@objc public class RoktEventHandler: RoktEvent {
    private var sessionId: String
    private var pageInstanceGuid: String
    private var jwtToken: String

    init(sessionId: String, pageInstanceGuid: String, jwtToken: String) {
        self.sessionId = sessionId
        self.pageInstanceGuid = pageInstanceGuid
        self.jwtToken = jwtToken
    }

    @objc public func setFulfillmentAttributes(attributes: [String: String]) {
        RoktAPIHelper.sendEvent(evenRequest:
                                    EventRequest(sessionId: sessionId,
                                                 eventType: .CaptureAttributes,
                                                 parentGuid: sessionId,
                                                 attributes: attributes,
                                                 pageInstanceGuid: pageInstanceGuid,
                                                 jwtToken: jwtToken))
    }

    internal func getRoktEvent(placementId: String?) -> RoktEvent {
        return RoktEvent.FirstPositiveEngagement(sessionId: sessionId,
                                                 pageInstanceGuid: pageInstanceGuid,
                                                 jwtToken: jwtToken,
                                                 placementId: placementId)
    }

}
