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

enum LayoutDismissOptions {
    case closeButton, noMoreOffer, endMessage, collapsed, defaultDismiss, partnerTriggered
}

struct EventProcessor {
    let sessionId: String
    let pluginInstanceGuid: String
    let startDate: Date
    
    var dismissOption: LayoutDismissOptions?
    
    func sendSignalLoadStartEvent() {
        sendEvent(.SignalLoadStart, parentGuid: pluginInstanceGuid)
    }
    
    func sendSignalLoadCompleteEvent() {
        sendEvent(.SignalLoadComplete, parentGuid: pluginInstanceGuid)
    }
    
    func sendPluginImpressionEvent() {
        sendEvent(.SignalImpression,
                  parentGuid: pluginInstanceGuid,
                  extraMetadata:
                    [EventNameValue(name: BE_PAGE_SIGNAL_LOAD,
                                    value: EventDateFormatter.getDateString(startDate))])
    }
    
    func sendSlotImpressionEvent(instanceGuid: String) {
        sendEvent(.SignalImpression, parentGuid: instanceGuid)
    }
    
    func sendSignalActivationEvent() {
        sendEvent(.SignalActivation, parentGuid: pluginInstanceGuid)
    }
    
    func sendSignalResponseEvent(instanceGuid: String) {
        sendEvent(.SignalResponse, parentGuid: instanceGuid)
    }
    
    func sendGatedSignalResponseEvent(instanceGuid: String) {
        sendEvent(.SignalGatedResponse, parentGuid: instanceGuid)
    }
    
    func sendDismissalEvent() {
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
                  extraMetadata: [EventNameValue(name: kInitiator, value: kEndMessage)])
    }
    
    private func sendDismissalCollapsedEvent() {
        sendEvent(.SignalDismissal, parentGuid: pluginInstanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kCollapsed)])
    }
    
    private func sendDismissalCloseEvent() {
        sendEvent(.SignalDismissal, parentGuid: pluginInstanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kCloseButton)])
    }
    private func sendDismissalPartnerTriggeredEvent() {
        sendEvent(.SignalDismissal, parentGuid: pluginInstanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kPartnerTriggered)])
    }
    
    private func sendDismissalNoMoreOfferEvent() {
        sendEvent(.SignalDismissal, parentGuid: pluginInstanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kNoMoreOfferToShow)])
    }
    
    private func sendDefaultDismissEvent() {
        sendEvent(.SignalDismissal, parentGuid: pluginInstanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kDismissed)])
    }

    func sendHTMLParseErrorEvent(html: String) {
        RoktAPIHelper.sendDiagnostics(
            message: kViewErrorCode,
            callStack: kInvalidHTMLFormatError + html
        )
    }
    
    func sendEvent(
        _ eventType: EventType,
        parentGuid: String,
        extraMetadata: [EventNameValue] = [EventNameValue]()
    ) {
        RoktAPIHelper.sendEvent(evenRequest: EventRequest(
            sessionId: sessionId,
            eventType: eventType,
            parentGuid: parentGuid,
            extraMetadata: extraMetadata
        ))
    }
}
