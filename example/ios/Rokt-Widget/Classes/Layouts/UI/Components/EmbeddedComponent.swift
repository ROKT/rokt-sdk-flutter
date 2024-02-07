//
//  EmbeddedComponent.swift
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

struct EmbeddedComponent: View {
    let layout: LayoutSchemaUIModel
    let baseDI: BaseDependencyInjection
    let onLoad: (() -> Void)?
    let onSizeChange: ((CGFloat) -> Void)?
    
    @State var lastUpdatedHeight:CGFloat = 0
    @State private var availableWidth: CGFloat? = nil
    @State private var availableHeight: CGFloat? = nil
    
    @StateObject var globalScreenSize = GlobalScreenSize()

    var body: some View {
        LayoutSchemaComponent(parent: .column,
                              layout: layout,
                              baseDI: baseDI,
                              parentWidth: $availableWidth,
                              parentHeight: $availableHeight,
                              styleState: .constant(.default))
        .readSize { size in
            availableWidth = size.width
            availableHeight = size.height
            
            notifyHeightChanged(size.height)
            
            // 0 at the start
            globalScreenSize.width = size.width
            globalScreenSize.height = size.height
        }
        .onLoad {
            baseDI.eventProcessor.sendPluginImpressionEvent()
            onLoad?()
        }
        .onFirstTouch {
            baseDI.eventProcessor.sendSignalActivationEvent()
        }
        .environmentObject(globalScreenSize)
    }
    
    func notifyHeightChanged(_ newHeight: CGFloat) {
        if lastUpdatedHeight != newHeight {
            onSizeChange?(newHeight)
            lastUpdatedHeight = newHeight
        }
    }
}
