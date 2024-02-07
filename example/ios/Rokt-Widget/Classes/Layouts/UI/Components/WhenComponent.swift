//
//  WhenComponent.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import SwiftUI
import Combine

@available(iOS 15, *)
struct WhenComponent: View {
    let parent: ComponentParent
    let viewModel: WhenViewModel

    @Binding var parentWidth: CGFloat?
    @Binding var parentHeight: CGFloat?
    @Binding var styleState: StyleState

    @Binding var currentIndex: Int
    let totalOffers: Int

    @EnvironmentObject var globalScreenSize: GlobalScreenSize

    let parentVerticalAlignment: VerticalAlignment?
    let parentHorizontalAlignment: HorizontalAlignment?

    init(
        parent: ComponentParent,
        model: WhenUIModel,
        baseDI: BaseDependencyInjection,
        parentWidth: Binding<CGFloat?>,
        parentHeight: Binding<CGFloat?>,
        styleState: Binding<StyleState>,
        parentVerticalAlignment: VerticalAlignment?,
        parentHorizontalAlignment: HorizontalAlignment?
    ) {
        self.parent = parent
        self.viewModel = WhenViewModel(model: model,
                                       baseDI: baseDI)
        _parentWidth = parentWidth
        _parentHeight = parentHeight
        _styleState = styleState
        _currentIndex = baseDI.sharedData.items[SharedData.currentOfferIndexKey] as? Binding<Int> ?? .constant(0)
        totalOffers = baseDI.sharedData.items[SharedData.totalItemsKey] as? Int ?? 0

        self.parentVerticalAlignment = parentVerticalAlignment
        self.parentHorizontalAlignment = parentHorizontalAlignment
    }

    var body: some View {
        // add more breakpoint conditions here
        if viewModel.shouldApply(currentOfferIndex: currentIndex,
                                 totalOffers: totalOffers,
                                 width: globalScreenSize.width ?? 0) {
            if let children = viewModel.model.children {
                ForEach(children, id: \.self) { child in
                    LayoutSchemaComponent(parent: parent,
                                          layout: child,
                                          baseDI: viewModel.baseDI,
                                          parentWidth: $parentWidth,
                                          parentHeight: $parentHeight,
                                          styleState: $styleState,
                                          parentVerticalAlignment: parentVerticalAlignment,
                                          parentHorizontalAlignment: parentHorizontalAlignment)
                }
            }
        }
    }
}
