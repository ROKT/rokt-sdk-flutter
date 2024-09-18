//
//  PlacementAndLayoutHeaderBridge.swift
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

class PlacementAndLayoutHeaderBridge {
    enum DataResponseType {
        // DCUI
        case layouts
        // Legacy
        case placements
    }

    static func dataResponseFor(responseHeaders: ResponseHeaders?) -> DataResponseType {
        guard let responseHeaders,
              let responseValue = responseHeaders[kExperienceType] as? String
        else { return .placements }

        if responseValue.lowercased() == kPlacementsValue.lowercased() {
            return .placements
        } else if responseValue.lowercased() == kLayoutsValue.lowercased() {
            return .layouts
        } else {
            return .placements
        }
    }
}
