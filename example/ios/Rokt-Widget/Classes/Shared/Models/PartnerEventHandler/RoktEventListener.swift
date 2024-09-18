//
//  RoktEventListener.swift
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

protocol RoktEventListener {
    func onOfferEngagement()
    func onPositiveEngagement()
    func onPlacementInteractive()
    func onPlacementReady()
    func onPlacementClosed()
    func onPlacementCompleted()
    func onPlacementFailure()
}

extension RoktEventListener {
    func addAllListeners(eventCollection: EventCollection) {
        eventCollection[.OfferEngagement] = onOfferEngagement
        eventCollection[.PositiveEngagement] = onPositiveEngagement
        eventCollection[.PlacementInteractive] = onPlacementInteractive
        eventCollection[.PlacementReady] = onPlacementReady
        eventCollection[.PlacementClosed] = onPlacementClosed
        eventCollection[.PlacementCompleted] = onPlacementCompleted
        eventCollection[.PlacementFailure] = onPlacementFailure
    }
}
