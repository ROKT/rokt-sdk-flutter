//
//  RoktFrameworkType.swift
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

/// Rokt public framework type enum
@objc public enum RoktFrameworkType: Int {
    case iOS
    case Cordova
    case ReactNative
    case Flutter

    // `objc` enums have to be `Int` types. this maps types to meaningful text
    var toString: String {
        switch self {
        case .iOS:
            return "iOS"
        case .Cordova:
            return "cordova"
        case .ReactNative:
            return "reactNative"
        case .Flutter:
            return "flutter"
        default:
            return "iOS"
        }
    }
}
