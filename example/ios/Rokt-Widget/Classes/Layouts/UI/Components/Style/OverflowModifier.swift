//
//  OverflowModifier.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import SwiftUI

@available(iOS 15, *)
struct OverflowModifier: ViewModifier {
    let overFlow: Overflow?
    
    func body(content: Content) -> some View {
        switch overFlow {
        case .hidden:
            content.clipped()
        default: // nil and visibile
            content
        }
    }
    
}
