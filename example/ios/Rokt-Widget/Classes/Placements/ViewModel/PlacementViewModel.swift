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
        placement.offers[currentOffer]
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
        sendEvent(
            .SignalLoadStart,
            parentGuid: placement.instanceGuid,
            jwtToken: placement.placementsJWTToken
        )
    }

    internal func sendSignalLoadCompleteEvent() {
        sendEvent(
            .SignalLoadComplete,
            parentGuid: placement.instanceGuid,
            jwtToken: placement.placementsJWTToken
        )
    }

    internal func sendPlacementImpressionEvent() {
        sendEvent(.SignalImpression,
                  parentGuid: placement.instanceGuid,
                  extraMetadata:
                    [EventNameValue(name: BE_PAGE_SIGNAL_LOAD,
                                    value: EventDateFormatter.getDateString(placement.startDate)),
                     EventNameValue(name: BE_PAGE_RENDER_ENGINE,
                                    value: BE_RENDER_ENGINE_PLACEMENTS),
                     EventNameValue(name: BE_PAGE_SIGNAL_COMPLETE,
                                    value: EventDateFormatter.getDateString(placement.responseReceivedDate))],
                  jwtToken: placement.placementsJWTToken)
    }

    internal func sendSlotImpressionEvent() {
        sendEvent(
            .SignalImpression,
            parentGuid: offer.instanceGuid,
            jwtToken: offer.slotJWTToken
        )
    }

    internal func sendSignalActivationEvent() {
        sendEvent(
            .SignalActivation,
            parentGuid: placement.instanceGuid,
            jwtToken: placement.placementsJWTToken
        )
    }

    internal func sendDismissalEndMessageEvent() {
        sendEvent(.SignalDismissal,
                  parentGuid: placement.instanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kEndMessage)],
                  jwtToken: placement.placementsJWTToken)
    }

    internal func sendDismissalCollapsedEvent() {
        sendEvent(.SignalDismissal,
                  parentGuid: placement.instanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kCollapsed)],
                  jwtToken: placement.placementsJWTToken)
    }

    internal func sendDismissalCloseEvent() {
        sendEvent(.SignalDismissal,
                  parentGuid: placement.instanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kCloseButton)],
                  jwtToken: placement.placementsJWTToken)
    }

    internal func sendDismissalNoMoreOfferEvent() {
        sendEvent(.SignalDismissal,
                  parentGuid: placement.instanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kNoMoreOfferToShow)],
                  jwtToken: placement.placementsJWTToken)
    }

    internal func sendDefaultDismissEvent() {
        sendEvent(.SignalDismissal,
                  parentGuid: placement.instanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kDismissed)],
                  jwtToken: placement.placementsJWTToken)
    }

    internal func sendDismissalPartnerTriggeredEvent() {
        sendEvent(.SignalDismissal,
                  parentGuid: placement.instanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kPartnerTriggered)],
                  jwtToken: placement.placementsJWTToken)
    }

    internal func sendDismissalNegativeButtonEvent() {
        sendEvent(.SignalDismissal,
                  parentGuid: placement.instanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kNegativeButtonDismissal)],
                  jwtToken: placement.placementsJWTToken)
    }

    internal func sendDismissalNavigateBackToAppEvent() {
        sendEvent(.SignalDismissal,
                  parentGuid: placement.instanceGuid,
                  extraMetadata: [EventNameValue(name: kInitiator, value: kNavigateBackToAppButton)],
                  jwtToken: placement.placementsJWTToken)
    }

    private func sendEvent(
        _ eventType: EventType,
        parentGuid: String,
        extraMetadata: [EventNameValue] = [EventNameValue](),
        jwtToken: String
    ) {
        let evenRequest = EventRequest(
            sessionId: sessionId,
            eventType: eventType,
            parentGuid: parentGuid,
            extraMetadata: extraMetadata,
            jwtToken: jwtToken
        )

        RoktAPIHelper.sendEvent(evenRequest: evenRequest)
    }

    // MARK: Button actions
    private func getValidCurrentOffer() -> OfferViewData? {
        // on empty offers, let callback handle end of journey without events
        guard !placement.offers.isEmpty else {
            RoktAPIHelper.sendDiagnostics(message: kViewErrorCode,
                                          callStack: kEmptyOffersError,
                                          sessionId: sessionId)
            // set to offers.count to satisfy isJourneyEnded condition
            currentOffer = placement.offers.count
            placementCallback.animateToNextOffer()
            return nil
        }

        // on invalid offer index, let callback handle end of journey without events
        guard placement.offers.indices.contains(currentOffer) else {
            RoktAPIHelper.sendDiagnostics(message: kViewErrorCode,
                                          callStack: String(
                                            format: kInvalidOfferIndexError, currentOffer, placement.offers.count),
                                          sessionId: sessionId)
            // set to offers.count to satisfy isJourneyEnded condition
            currentOffer = placement.offers.count
            placementCallback.animateToNextOffer()
            return nil
        }
        return placement.offers[currentOffer]
    }

    internal func checkFirstPositiveEngagement() {
        if !isFirstPositiveEngagementSend {
            isFirstPositiveEngagementSend = true
            self.onEvent?(RoktEventType.FirstPositiveEngagement,
                          RoktEventHandler(sessionId: sessionId,
                                           pageInstanceGuid: placement.pageInstanceGuid,
                                           jwtToken: placement.placementsJWTToken))
        }
    }

    internal func yesAction(parentViewController: UIViewController?) {
        checkFirstPositiveEngagement()
        guard let offer = getValidCurrentOffer() else { return }

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
        guard let offer = getValidCurrentOffer() else { return }

        if let negativeViewData = offer.negativeButtonLabel {
            OfferButtonHandler.noActionHandler(buttonViewData: negativeViewData, sessionId: sessionId,
                                               callback: self)
        }
    }

    internal func closeOnNegativeResponse() {
        placementCallback.closeOnNegativeResponse()
    }

    // MARK: offer
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

    // MARK: diagnostics
    internal func sendWebViewDiagnostics() {
        RoktAPIHelper.sendDiagnostics(message: kWebViewErrorCode, callStack: kStaticPageError,
                                      sessionId: sessionId)
    }
}

extension PlacementViewModel: RoktWebViewCallback {
    func onWebViewClosed() {
        goToNextOffer()
    }
}
