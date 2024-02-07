//
//  OverlayComponent.swift
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
struct OverlayComponent: View {
    let model: OverlayUIModel?
    let baseDI: BaseDependencyInjection
    var wrapperStyle: OverlayWrapperStyles? {
        model?.wrapperStyle
    }
    var style: OverlayStyles? {
        model?.defaultStyle
    }
    
    @State private var availableWidth: CGFloat? = nil
    @State private var availableHeight: CGFloat? = nil
    
    @StateObject var globalScreenSize = GlobalScreenSize()
    var body: some View {
        ZStack(alignment: getOverlayAlignment(alignItem: wrapperStyle?.container?.alignItems,
                                              justifyContent: wrapperStyle?.container?.justifyContent)) {
            if (model?.settings?.allowBackdropToClose ?? false) {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        baseDI.actionCollection[DCUIComponent.closeAction]()
                    }
            }
            OuterLayerComponent(layouts: model?.children,
                                style: StylingPropertiesModel(
                                    container: style?.container,
                                    background: style?.background,
                                    dimension: style?.dimension,
                                    flexChild: style?.flexChild,
                                    spacing: style?.spacing,
                                    border: style?.border),
                                baseDI: baseDI,
                                parentWidth: $availableWidth,
                                parentHeight: $availableHeight)
        }
        .frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .top)
        .background(backgroundStyle: wrapperStyle?.background)
        .overflow(overflow: wrapperStyle?.container?.overflow, axis: .vertical)
        .readSize { size in
            availableWidth = size.width
            availableHeight = size.height
            
            // 0 at the start
            globalScreenSize.width = size.width
            globalScreenSize.height = size.height
        }
        .environmentObject(globalScreenSize)
        
    }
    
    private func getOverlayAlignment(alignItem: FlexPosition?,
                                     justifyContent: FlexPosition?) -> Alignment {
        guard alignItem != nil || justifyContent != nil  else { return .top } // default top
        if let alignItem, let justifyContent {
            switch alignItem {
            case .center:
                switch justifyContent {
                case .center:
                    return .center
                case .flexStart:
                    return .leading
                case .flexEnd:
                    return .trailing
                }
            case .flexStart:
                switch justifyContent {
                case .center:
                    return .top
                case .flexStart:
                    return .topLeading
                case .flexEnd:
                    return .topTrailing
                }
            case .flexEnd:
                switch justifyContent {
                case .center:
                    return .bottom
                case .flexStart:
                    return .bottomLeading
                case .flexEnd:
                    return .bottomTrailing
                }
            }
        } else if let justifyContent {
            switch justifyContent {
            case .center:
                return .center
            case .flexStart:
                return .leading
            case .flexEnd:
                return .trailing
            }
        } else {
            guard let alignItem else { return .top }
            switch alignItem {
            case .center:
                return .center
            case .flexStart:
                return .top
            case .flexEnd:
                return .bottom
            }
        }
    }
}
