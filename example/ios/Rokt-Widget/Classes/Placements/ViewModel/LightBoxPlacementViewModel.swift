//
//  LightBoxPlacementViewModel.swift
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

enum DismissOptions {
    case closeButton, noMoreOffer, defaultDimiss, partnerTriggered, negativeButton, navigateBackToApp
}

class LightBoxPlacementViewModel: PlacementViewModel {
    var placement: LightBoxViewData!
    var sessionId: String!
    
    init(_ sessionId: String, placement: LightBoxViewData,
         placementCallback: PlacementViewModelCallback,
         onEvent: @escaping (RoktEventType, RoktEventHandler) -> Void) {
        self.placement = placement
        self.sessionId = sessionId
        super.init(sessionId, placement: placement,
                   placementCallback: placementCallback,
                   onEvent: onEvent)
    }
    
    internal func sendDismissalEvent(_ dismissOption: DismissOptions) {
        switch dismissOption {
        case .noMoreOffer:
            sendDismissalNoMoreOfferEvent()
        case .closeButton:
            sendDismissalCloseEvent()
        case .partnerTriggered:
            sendDismissalPartnerTriggeredEvent()
        case .negativeButton:
            sendDismissalNegativeButtonEvent()
        case .navigateBackToApp:
            sendDismissalNavigateBackToAppEvent()
        default:
            sendDefaultDismissEvent()
        }
    }

    func numberOfLinesForTitle() -> Int {
        let titleLineBreakMode = placement.title.textViewData.textStyleViewData.lineBreakMode

        return (titleLineBreakMode == .byWordWrapping) ? 0 : 1
    }
}
