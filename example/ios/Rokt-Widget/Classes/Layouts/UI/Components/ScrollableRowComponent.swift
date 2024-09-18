//
//  ScrollableRowComponent.swift
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
struct ScrollableRowComponent: View {
    @SwiftUI.Environment(\.colorScheme) var colorScheme

    let config: ComponentConfig
    let model: RowUIModel
    let baseDI: BaseDependencyInjection

    @Binding var parentWidth: CGFloat?
    @Binding var parentHeight: CGFloat?
    @Binding var styleState: StyleState
    @State private var availableWidth: CGFloat? = nil
    @State private var availableHeight: CGFloat? = nil
    @State private var contentSize: CGFloat = .zero
    
    let parentOverride: ComponentParentOverride?

    var body: some View {
        ScrollView(.horizontal) {
            RowComponent(config: config,
                         model: model,
                         baseDI: baseDI,
                         parentWidth: $parentWidth,
                         parentHeight: $parentHeight,
                         styleState: $styleState,
                         parentOverride: parentOverride)
            .readSize { newSize in
                contentSize = newSize.width
            }
        }.frame(maxWidth: contentSize)
    }
    
}
