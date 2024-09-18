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
import UIKit

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
    
    class func getPageInitData(attributes: [String: Any]) -> String? {
        guard var castedAttrs = attributes as? [String: String] else { return nil }

        return castedAttrs.removeValue(forKey: BE_ATTRIBUTES_PAGE_INIT_KEY)
    }

    /// Removes all privacy control KVPs from partner attributes
    /// - Parameter attributes: a hashmap of additional information sent by the partner
    /// - Returns: partner `attributes` without privacy control and pageInit KVPs
    class func removeAttributesToSanitise(attributes: [String: Any]) -> [String: Any] {
        var mutablePayload = attributes

        let privacyControlFields = [
            kNoFunctional,
            kNoTargeting,
            kDoNotShareOrSell,
            kGpcEnabled
        ]

        privacyControlFields.forEach { mutablePayload.removeValue(forKey: $0) }
        mutablePayload.removeValue(forKey: BE_ATTRIBUTES_PAGE_INIT_KEY)

        return mutablePayload
    }

    class func appendColorModeIfDoesNotExist(attributes: [String: Any],
                                             config: RoktConfig?) -> [String: Any] {
        guard #available(iOS 13, *) else { return attributes }

        var mutablePayload = attributes

        if attributes[BE_COLOR_MODE_KEY] == nil {
            if let config {
                switch config.colorMode {
                case .light:
                    mutablePayload[BE_COLOR_MODE_KEY] = getColorMode(screenColorMode: .light)
                case .dark:
                    mutablePayload[BE_COLOR_MODE_KEY] = getColorMode(screenColorMode: .dark)
                case .system:
                    mutablePayload[BE_COLOR_MODE_KEY] = getColorMode()
                }
            } else {
                mutablePayload[BE_COLOR_MODE_KEY] = getColorMode()
            }
        }

        return mutablePayload
    }

    /// Extracts color mode from the user's device
    /// - Returns: device color mode which can either be dark | light
    @available(iOS 13.0, *)
    class func getColorMode(
        screenColorMode: UIUserInterfaceStyle = UIViewController().traitCollection.userInterfaceStyle
    ) -> String {
        var colorModeText: String

        // a `UIViewController` will always return the viewable colormode which is either `.dark` or `.light`
        switch screenColorMode {
        case .dark:
            colorModeText = "DARK"
        default:
            colorModeText = "LIGHT"
        }

        return colorModeText
    }
}
