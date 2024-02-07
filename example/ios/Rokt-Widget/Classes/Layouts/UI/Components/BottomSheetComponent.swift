//
//  BottomSheetComponent.swift
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
struct BottomSheetComponent: View {
    let model: BottomSheetUIModel?
    let baseDI: BaseDependencyInjection
    var style: BottomSheetStyles? {
        model?.defaultStyle
    }
    
    @State private var availableWidth: CGFloat? = nil
    @State private var availableHeight: CGFloat? = nil
    
    @StateObject var globalScreenSize = GlobalScreenSize()
    var body: some View {
        OuterLayerComponent(layouts: model?.children,
                              style: StylingPropertiesModel(
                                container: style?.container,
                                background: style?.background,
                                dimension: updateButtomSheetHeight(dimension: style?.dimension),
                                flexChild: style?.flexChild,
                                spacing: style?.spacing,
                                border: style?.border),
                              baseDI: baseDI,
                              parentWidth: $availableWidth,
                              parentHeight: $availableHeight)
        .frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .leading)
        .background(backgroundStyle: style?.background)
        .readSize { size in
            availableWidth = size.width
            availableHeight = size.height
            
            // 0 at the start
            globalScreenSize.width = size.width
            globalScreenSize.height = size.height
        }
        .environmentObject(globalScreenSize)
    }
    
    // BottomSheet height already applied to the viewController level
    // if height value is percentage, instead of applying percentage, need to use fit-height
    // to occupy whole area instead of applying percentage twice
    private func updateButtomSheetHeight(dimension: DimensionStylingProperties?) -> DimensionStylingProperties? {
        guard let dimension, let height = dimension.height else { return dimension }

        switch height {
        case .percentage(_):
            return DimensionStylingProperties(minWidth: dimension.minWidth,
                                              maxWidth: dimension.maxWidth,
                                              width: dimension.width,
                                              minHeight: dimension.minHeight,
                                              maxHeight: dimension.maxHeight,
                                              height: .fit(.fitHeight))
        default:
            return dimension
        }
    }
}
