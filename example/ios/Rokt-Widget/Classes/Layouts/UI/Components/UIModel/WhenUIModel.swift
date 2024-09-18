//
//  WhenUIModel.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation

@available(iOS 15, *)
struct WhenUIModel:  Identifiable, Hashable {
    let id: UUID = UUID()

    var children: [LayoutSchemaUIModel]?
    let predicates: [WhenPredicate]?
    let transition: WhenTransition?
    
    var fadeInDuration: Double {
        transition?.inTransition.map { transitions in
            transitions.compactMap {
                if case let .fadeIn(settings) = $0 {
                    return Double(settings.duration)/1000
                }
                return nil
            }
        }?.first ?? 0
    }
    
    var fadeOutDuration: Double {
        transition?.outTransition.map { transitions in
            transitions.compactMap {
                if case let .fadeOut(settings) = $0 {
                    return Double(settings.duration)/1000
                }
                return nil
            }
        }?.first ?? 0
    }
}
