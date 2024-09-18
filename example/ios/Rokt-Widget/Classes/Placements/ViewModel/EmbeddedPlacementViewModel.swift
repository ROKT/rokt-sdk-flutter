//
//  EmbeddedPlacementViewModel.swift
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

class EmbeddedPlacementViewModel: PlacementViewModel {
    var placement: EmbeddedViewData!
    var sessionId: String!

    init(
        _ sessionId: String,
        placement: EmbeddedViewData,
        placementCallback: PlacementViewModelCallback,
        onEvent: @escaping (RoktEventType, RoktEventHandler) -> Void
    ) {
        self.placement = placement
        self.sessionId = sessionId

        super.init(
            sessionId,
            placement: placement,
            placementCallback: placementCallback,
            onEvent: onEvent
        )
    }

    internal func isEndedWithMessage() -> Bool {
        return placement.endMessageViewData != nil
    }
}
