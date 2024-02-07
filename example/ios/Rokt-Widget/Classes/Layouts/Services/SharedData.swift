//
//  SharedData.swift
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

import SwiftUI

@available(iOS 13.0, *)
class SharedData: ObservableObject {
    static let breakPointsSharedKey = "breakPoints"     // BreakPoint
    static let currentOfferIndexKey = "currentOffer"    // Binding<Int>
    static let totalItemsKey = "totalItems"             // Int
    static let layoutType = "layoutCode"                // PlacementLayoutCode

    @Published var items = [String: Any]()
}

