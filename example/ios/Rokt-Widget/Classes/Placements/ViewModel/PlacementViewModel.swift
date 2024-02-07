//
//  PlacementViewModel.swift
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
//

import Foundation
import UIKit

protocol PlacementViewModelCallback {
    func animateToNextOffer()
    func closeOnNegativeResponse()
}

@objc internal protocol PlacementViewButtonActions {
    @objc func footerLinkButtonTapped(_ sender: LinkButton)
}

class PlacementViewModel: OfferButtonCallback {
    private var sessionId: String!
    private var placement: PlacementViewData!
    private var currentOffer = 0
    private var isFirstPositiveEngagementSend = false
    private var onEvent: ((RoktEventType, RoktEventHandler) -> Void)?
    private var placementCallback: PlacementViewModelCallback!

    private var shouldSendPositiveSignalResponseEvent: Bool {
        if placement.canLoadNextOffer {
            return true
        } else {
            return !hasSentPositiveResponse
        }
    }

    private var hasSentPositiveResponse = false

    var offer: OfferViewData {
        get {
            return placement.offers[currentOffer]
        }
    }
    
    init(_ sessionId: String, placement: PlacementViewData,
         placementCallback: PlacementViewModelCallback,
         onEvent: @escaping (RoktEventType, RoktEventHandler) -> Void) {
        self.sessionId = sessionId
        self.placement = placement
        self.placementCallback = placementCallback
        currentOffer = 0
        self.onEvent = onEvent
    }
    
    // MARK: Events
    
    internal func sendSignalLoadStartEvent() {
        sendEvent(.SignalLoadStart, parentGuid: placement.instanceGuid)
    }
    
    internal func sendSignalLoadCompleteEvent() {
        sendEvent(.SignalLoadComplete, parentGuid: placement.instanceGuid)
    }
    
    internal func sendPlacementImpressionEvent() {
        sendEvent(.SignalImpression,
                  parentGuid: placement.instanceGuid,
                  extraMetadata:
                    [EventNameValue(name: BE_PAGE_SIGNAL_LOAD,
                                    value: EventDateFormatter.getDateString(placement.startDate))])
    }
    
    internal func sendSlotImpressionEvent() {
        sendEvent(.SignalImpression, parentGuid: offer.instanceGuid)
    }
    
    internal func sendSignalActivationEvent() {
        sendEvent(.SignalActivation, parentGuid: placement.instanceGuid)
    }
    
    internal func sendDismissalEndMessageEvent() {
        sendEvent(.SignalDismissal, parentGuid: placement.instanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kEndMessage)])
    }
    
    internal func sendDismissalCollapsedEvent() {
        sendEvent(.SignalDismissal, parentGuid: placement.instanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kCollapsed)])
    }
    
    internal func sendDismissalCloseEvent() {
        sendEvent(.SignalDismissal, parentGuid: placement.instanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kCloseButton)])
    }
    
    internal func sendDismissalNoMoreOfferEvent() {
        sendEvent(.SignalDismissal, parentGuid: placement.instanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kNoMoreOfferToShow)])
    }
    
    internal func sendDefaultDismissEvent() {
        sendEvent(.SignalDismissal, parentGuid: placement.instanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kDismissed)])
    }
    
    internal func sendDismissalPartnerTriggeredEvent() {
        sendEvent(.SignalDismissal, parentGuid: placement.instanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kPartnerTriggered)])
    }
    
    internal func sendDismissalNegativeButtonEvent() {
        sendEvent(.SignalDismissal, parentGuid: placement.instanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kNegativeButtonDismissal)])
    }

    internal func sendDismissalNavigateBackToAppEvent() {
        sendEvent(.SignalDismissal, parentGuid: placement.instanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kNavigateBackToAppButton)])
    }
    
    private func sendEvent(_ eventType: EventType, parentGuid: String,
                           extraMetadata: [EventNameValue] = [EventNameValue]()){
        RoktAPIHelper.sendEvent(evenRequest:
                                    EventRequest(sessionId: sessionId, eventType: eventType, parentGuid: parentGuid, extraMetadata: extraMetadata))
    }
    
    //MARK: Button actions
    internal func checkFirstPositiveEngagement() {
        if !isFirstPositiveEngagementSend {
            isFirstPositiveEngagementSend = true
            self.onEvent?(RoktEventType.FirstPositiveEngagement,
                          RoktEventHandler(sessionId: sessionId, pageInstanceGuid: placement.pageInstanceGuid))
        }
    }
    
    internal func yesAction(parentViewController: UIViewController?) {
        checkFirstPositiveEngagement()

        let offer = placement.offers[currentOffer]

        if let viewContoller = parentViewController, let positiveViewData = offer.positiveButtonLabel {
            // send `SignalResponse` or `SignalGatedResponse`
            OfferButtonHandler.yesActionHandler(
                buttonViewData: positiveViewData,
                sessionId: sessionId,
                campaignId: offer.campaignId,
                callback: self,
                viewController: viewContoller,
                webviewCallback: self,
                shouldSendResponseEvent: shouldSendPositiveSignalResponseEvent
            )

            hasSentPositiveResponse = true
        } else {
            goToNextOffer()
        }
    }
    
    internal func noAction() {
        if let negativeViewData = placement.offers[currentOffer].negativeButtonLabel {
            OfferButtonHandler.noActionHandler(buttonViewData: negativeViewData, sessionId: sessionId,
                                               callback: self)
        }
    }
    
    internal func closeOnNegativeResponse() {
        placementCallback.closeOnNegativeResponse()
    }
    
    //MARK: offer
    internal func goToNextOffer() {
        guard placement.canLoadNextOffer else { return }

        currentOffer += 1
        
        if !isJourneyEnded() {
            sendSlotImpressionEvent()
        }

        if !isJourneyEnded() && offer.isGhostOffer() {
            goToNextOffer()
            return
        }

        placementCallback.animateToNextOffer()
    }
    
    internal func isJourneyEnded() -> Bool {
        return currentOffer >= placement.offers.count
    }

    //MARK: diagnostics
    internal func sendWebViewDiagnostics(){
        RoktAPIHelper.sendDiagnostics(message: kWebViewErrorCode, callStack: kStaticPageError,
                                      sessionId: sessionId)
    }
}

extension PlacementViewModel: RoktWebViewCallback {
    func onWebViewClosed() {
        goToNextOffer()
    }
}
