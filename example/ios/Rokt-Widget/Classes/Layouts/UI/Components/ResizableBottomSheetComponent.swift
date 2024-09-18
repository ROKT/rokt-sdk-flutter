//
//  ResizableBottomSheetComponent.swift
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
struct ResizableBottomSheetComponent: View {
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    let model: BottomSheetUIModel?
    let baseDI: BaseDependencyInjection
    let onSizeChange: ((CGFloat) -> Void)?
    var style: BottomSheetStyles? {
        model?.defaultStyle?.count ?? -1 > breakpointIndex ? model?.defaultStyle?[breakpointIndex] : nil
    }
    
    @State var breakpointIndex = 0
    @State var lastUpdatedHeight:CGFloat = 0
    
    @State private var availableWidth: CGFloat? = nil
    @State private var availableHeight: CGFloat? = nil
    
    @StateObject var globalScreenSize = GlobalScreenSize()
    var body: some View {
        ScrollView {
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
                                parentHeight: $availableHeight,
                                onSizeChange: onSizeChange)
            .frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .leading)
            .background(backgroundStyle: style?.background)
            .readSize(spacing: style?.spacing) { size in
                availableWidth = size.width
                availableHeight = size.height
                
                // 0 at the start
                globalScreenSize.width = size.width
                globalScreenSize.height = size.height
            }
            .environmentObject(globalScreenSize)
            .onChange(of: globalScreenSize.width) { newSize in
                // run it in background thread for smooth transition
                DispatchQueue.background.async {
                    // update breakpoint index
                    let index = min(baseDI.sharedData.getGlobalBreakpointIndex(newSize),
                                    (model?.defaultStyle?.count ?? 1) - 1)
                    breakpointIndex = index >= 0 ? index : 0
                }
            }
        }
        .background(backgroundStyle: style?.background)
    }
    
    // BottomSheet height has to be wrapContent
    private func updateButtomSheetHeight(dimension: DimensionStylingProperties?) -> DimensionStylingProperties? {
        guard let dimension, let _ = dimension.height else { return dimension }

            return DimensionStylingProperties(minWidth: dimension.minWidth,
                                              maxWidth: dimension.maxWidth,
                                              width: dimension.width,
                                              minHeight: dimension.minHeight,
                                              maxHeight: dimension.maxHeight,
                                              height: .fit(.wrapContent), 
                                              rotateZ: dimension.rotateZ)
        
    }
}
