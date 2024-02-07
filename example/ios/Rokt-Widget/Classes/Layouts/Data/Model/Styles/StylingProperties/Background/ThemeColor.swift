//
//  ThemeColor.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import UIKit

@available(iOS 13, *)
extension ThemeColor {
    var adaptiveColor: String? {
        switch UITraitCollection.current.userInterfaceStyle {
        case .light:
            return light
        case .dark:
            return dark
        default:
            return light
        }
    }
}
