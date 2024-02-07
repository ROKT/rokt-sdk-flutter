//
//  AttributedStringExtension.swift
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

extension RoktAPIHelper {
    /// Extracts all privacy control KVPs from the partner's attributes
    /// - Parameter attributes: a hashmap of additional information sent by the partner
    /// - Returns: a hashmap of all privacy KVP sent by the partner
    class func getPrivacyControlPayload(attributes: [String: Any]) -> [String: Bool] {
        guard let castedAttrs = attributes as? [String: String] else { return [:] }

        return [
            kNoFunctional: castedAttrs[kNoFunctional],
            kNoTargeting: castedAttrs[kNoTargeting],
            kDoNotShareOrSell: castedAttrs[kDoNotShareOrSell],
            kGpcEnabled: castedAttrs[kGpcEnabled]
        ]
            .compactMapValues { $0 }
            .mapValues { Bool($0.lowercased()) }
            .compactMapValues { $0 }
    }

    /// Removes all privacy control KVPs from partner attributes
    /// - Parameter attributes: a hashmap of additional information sent by the partner
    /// - Returns: partner `attributes` without privacy control KVPs
    class func removeAllPrivacyControlData(attributes: [String: Any]) -> [String: Any] {
        var mutablePayload = attributes

        let privacyControlFields = [
            kNoFunctional,
            kNoTargeting,
            kDoNotShareOrSell,
            kGpcEnabled
        ]

        privacyControlFields.forEach { mutablePayload.removeValue(forKey: $0) }

        return mutablePayload
    }
}
