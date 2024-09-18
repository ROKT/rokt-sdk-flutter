//
//  RoktEvent.swift
//  Pods
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

@objc public class RoktEvent: NSObject {

    @objc public class ShowLoadingIndicator: RoktEvent {}

    @objc public class HideLoadingIndicator: RoktEvent {}

    @objc public class PlacementInteractive: RoktEvent {
        @objc public let placementId: String?

        init(placementId: String?) {
            self.placementId = placementId
        }
    }

    @objc public class PlacementReady: RoktEvent {
        @objc public let placementId: String?

        init(placementId: String?) {
            self.placementId = placementId
        }
    }

    @objc public class OfferEngagement: RoktEvent {
        @objc public let placementId: String?

        init(placementId: String?) {
            self.placementId = placementId
        }
    }

    @objc public class PositiveEngagement: RoktEvent {
        @objc public let placementId: String?

        init(placementId: String?) {
            self.placementId = placementId
        }
    }

    @objc public class PlacementClosed: RoktEvent {
        @objc public let placementId: String?

        init(placementId: String?) {
            self.placementId = placementId
        }
    }

    @objc public class PlacementCompleted: RoktEvent {
        @objc public let placementId: String?

        init(placementId: String?) {
            self.placementId = placementId
        }
    }

    @objc public class PlacementFailure: RoktEvent {
        @objc public let placementId: String?

        init(placementId: String?) {
            self.placementId = placementId
        }
    }

    @objc public class FirstPositiveEngagement: RoktEvent {
        private var sessionId: String
        private var pageInstanceGuid: String
        private var jwtToken: String
        @objc public let placementId: String?

        init(sessionId: String, pageInstanceGuid: String, jwtToken: String, placementId: String?) {
            self.sessionId = sessionId
            self.pageInstanceGuid = pageInstanceGuid
            self.jwtToken = jwtToken
            self.placementId = placementId
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

    }

}
