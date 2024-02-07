//
//  FlexChildStylingPropertiesModel.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import SwiftUI

struct FlexChildStylingPropertiesModel: Decodable, Hashable {
    let weight: Float?
    let alignSelf: AlignSelf?
    let order: Float?
}

@available(iOS 13, *)
extension FlexPosition {

    var asHorizontalAlignment: Alignment {
        switch self {
        case .flexStart: return .leading
        case .center: return .center
        case .flexEnd: return .trailing
        }
    }

    var asVerticalAlignment: Alignment {
        switch self {
        case .flexStart: return .top
        case .center: return .center
        case .flexEnd: return .bottom
        }
    }

    var asHorizontalAlignmentProperty: HorizontalAlignmentProperty {
        self.asHorizontalAlignment.asHorizontalAlignmentProperty
    }

    var asVerticalAlignmentProperty: VerticalAlignmentProperty {
        self.asVerticalAlignment.asVerticalAlignmentProperty
    }
}
@available(iOS 13, *)
extension Alignment {
    // Breaks down `Alignment` to axis-specific types
    var asHorizontalType: HorizontalAlignment? {
        switch self {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        default: return nil
        }
    }

    var asVerticalType: VerticalAlignment? {
        switch self {
        case .top: return .top
        case .center: return .center
        case .bottom: return .bottom
        default: return nil
        }
    }

    var asHorizontalAlignmentProperty: HorizontalAlignmentProperty {
        switch self {
        case .trailing:
            return .end
        case .center:
            return .center
        default:
            return .start
        }
    }

    var asVerticalAlignmentProperty: VerticalAlignmentProperty {
        switch self {
        case .bottom:
            return .bottom
        case .center:
            return .center
        default:
            return .top
        }
    }
}

// Swift does not support inheritance for `enum` so we need to replicate `FlexPosition`
enum AlignSelf: String, Decodable, Hashable {
    case center
    case flexStart = "flex-start"
    case flexEnd = "flex-end"
    case stretch
}
