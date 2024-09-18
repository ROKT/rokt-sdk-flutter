//
//  EventProcessor.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation
import SwiftUI

enum LayoutDismissOptions {
    case closeButton, noMoreOffer, endMessage, collapsed, defaultDismiss, partnerTriggered
}

struct EventProcessor {
    let sessionId: String
    let pluginInstanceGuid: String
    let pluginId: String?
    let pluginName: String?
    let startDate: Date
    let actionCollection: ActionCollection
    let eventCollection: EventCollection
    var responseReceivedDate: Date
    var isFirstPositiveEngagementSend = false
    
    let pluginConfigJWTToken: String

    var dismissOption: LayoutDismissOptions?

    func sendSignalLoadStartEvent() {
        sendEvent(.SignalLoadStart, parentGuid: pluginInstanceGuid, jwtToken: pluginConfigJWTToken)
    }
    
    func sendEventsOnTransformerSuccess() {
        sendPlacementReadyEventCallback()
        sendSignalLoadCompleteEvent()
    }
    
    private func sendPlacementReadyEventCallback() {
        eventCollection[.PlacementReady]()
    }

    private func sendSignalLoadCompleteEvent() {
        sendEvent(.SignalLoadComplete, parentGuid: pluginInstanceGuid, jwtToken: pluginConfigJWTToken)
    }

    func sendSignalActivationEvent() {
        sendEvent(.SignalActivation, parentGuid: pluginInstanceGuid, jwtToken: pluginConfigJWTToken)
    }
    
    func sendEventsOnLoad() {
        sendPlacementInteractiveEventCallback()
        sendPluginImpressionEvent()
        
        sendTimingsWithPlacementInteractive()
    }
    
    private func sendPlacementInteractiveEventCallback() {
        eventCollection[.PlacementInteractive]()
    }

    private func sendPluginImpressionEvent() {
        sendEvent(.SignalImpression,
                  parentGuid: pluginInstanceGuid,
                  extraMetadata:
                    [EventNameValue(name: BE_PAGE_SIGNAL_LOAD,
                                    value: EventDateFormatter.getDateString(startDate)),
                     EventNameValue(name: BE_PAGE_RENDER_ENGINE,
                                    value: BE_RENDER_ENGINE_LAYOUTS),
                     EventNameValue(name: BE_PAGE_SIGNAL_COMPLETE,
                                    value: EventDateFormatter.getDateString(responseReceivedDate))],
                  jwtToken: pluginConfigJWTToken)
    }
    
    func sendSlotImpressionEvent(instanceGuid: String, jwtToken: String) {
        sendEvent(.SignalImpression, parentGuid: instanceGuid, jwtToken: jwtToken)
    }

    func sendSignalViewedEvent(instanceGuid: String, jwtToken: String) {
        sendEvent(.SignalViewed, parentGuid: instanceGuid, jwtToken: jwtToken)
    }

    mutating func sendSignalResponseEvent(instanceGuid: String, jwtToken: String, isPositive: Bool) {
        sendEngagementEventCallback(isPositive: isPositive)
        sendEvent(
            .SignalResponse,
            parentGuid: instanceGuid,
            jwtToken: jwtToken
        )
    }
    mutating func sendGatedSignalResponseEvent(instanceGuid: String, jwtToken: String, isPositive: Bool) {
        sendEngagementEventCallback(isPositive: isPositive)
        sendEvent(.SignalGatedResponse,
                  parentGuid: instanceGuid,
                  jwtToken: jwtToken
        )
    }
    
    func sendDismissalEvent() {
        sendDismissalEventCallback()
        switch dismissOption {
        case .noMoreOffer:
            sendDismissalNoMoreOfferEvent()
        case .closeButton:
            sendDismissalCloseEvent()
        case .endMessage:
            sendDismissalEndMessageEvent()
        case .collapsed:
            sendDismissalCollapsedEvent()
        case .partnerTriggered:
            sendDismissalPartnerTriggeredEvent()
        default:
            sendDefaultDismissEvent()
        }
    }
    
    private func sendDismissalEndMessageEvent() {
        sendEvent(.SignalDismissal, parentGuid: pluginInstanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kEndMessage)],
                  jwtToken: pluginConfigJWTToken)
    }
    
    private func sendDismissalCollapsedEvent() {
        sendEvent(.SignalDismissal, parentGuid: pluginInstanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kCollapsed)],
                  jwtToken: pluginConfigJWTToken)
    }
    
    private func sendDismissalCloseEvent() {
        sendEvent(.SignalDismissal, parentGuid: pluginInstanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kCloseButton)],
                  jwtToken: pluginConfigJWTToken)
    }
    private func sendDismissalPartnerTriggeredEvent() {
        sendEvent(.SignalDismissal, parentGuid: pluginInstanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kPartnerTriggered)],
                  jwtToken: pluginConfigJWTToken)
    }
    
    private func sendDismissalNoMoreOfferEvent() {
        sendEvent(.SignalDismissal, parentGuid: pluginInstanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kNoMoreOfferToShow)],
                  jwtToken: pluginConfigJWTToken)
    }
    
    private func sendDefaultDismissEvent() {
        sendEvent(.SignalDismissal, parentGuid: pluginInstanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kDismissed)],
                  jwtToken: pluginConfigJWTToken)
    }

    func sendHTMLParseErrorEvent(html: String) {
        RoktAPIHelper.sendDiagnostics(
            message: kViewErrorCode,
            callStack: kInvalidHTMLFormatError + html
        )
    }

    func sendTimingsWithPlacementInteractive() {
        Rokt.shared.processedTimingsRequests?.processTimingsRequest(pluginId: self.pluginId,
                                                                    pluginName: self.pluginName,
                                                                    placementInteractiveTime: DateHandler.currentDate(),
                                                                    sessionId: self.sessionId)
    }
    
    private mutating func sendEngagementEventCallback(isPositive: Bool) {
        eventCollection[.OfferEngagement]()
        
        if isPositive {
            eventCollection[.PositiveEngagement]()
            
            if !isFirstPositiveEngagementSend {
                actionCollection[.positiveEngaged](nil)
                isFirstPositiveEngagementSend = true
            }
        }
    }
    
    private func sendDismissalEventCallback() {
        switch dismissOption {
        case .noMoreOffer, .endMessage, .collapsed:
            eventCollection[.PlacementCompleted]()
        case .closeButton, .partnerTriggered:
            eventCollection[.PlacementClosed]()
        default:
            eventCollection[.PlacementClosed]()
        }
    }
    
    func sendEvent(
        _ eventType: EventType,
        parentGuid: String,
        extraMetadata: [EventNameValue] = [EventNameValue](),
        jwtToken: String
    ) {
        RoktAPIHelper.sendEvent(evenRequest: EventRequest(
            sessionId: sessionId,
            eventType: eventType,
            parentGuid: parentGuid,
            extraMetadata: extraMetadata,
            jwtToken: jwtToken
        ))
    }
}
