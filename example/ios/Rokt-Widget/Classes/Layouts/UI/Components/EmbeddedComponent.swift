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
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    let layout: LayoutSchemaUIModel
    let baseDI: BaseDependencyInjection
    let onLoad: (() -> Void)?
    let onSizeChange: ((CGFloat) -> Void)?
    
    @State var lastUpdatedHeight:CGFloat = 0
    @State private var availableWidth: CGFloat? = nil
    @State private var availableHeight: CGFloat? = nil
    
    @StateObject var globalScreenSize = GlobalScreenSize()

    var body: some View {
        VStack {
            LayoutSchemaComponent(config: ComponentConfig(parent: .column, position: nil),
                                  layout: layout,
                                  baseDI: baseDI,
                                  parentWidth: $availableWidth,
                                  parentHeight: $availableHeight,
                                  styleState: .constant(.default))
        }
        .frame(maxWidth: .infinity)
        .readSize { size in
            availableWidth = size.width
            availableHeight = size.height
            
            notifyHeightChanged(size.height)
            
            // 0 at the start
            globalScreenSize.width = size.width
            globalScreenSize.height = size.height
        }
        .onLoad {
            baseDI.eventProcessor.sendEventsOnLoad()
            Log.i("Rokt: Embedded view loaded")
            onLoad?()
            baseDI.actionCollection[.checkBoundingBox](nil)
        }
        .onFirstTouch {
            baseDI.eventProcessor.sendSignalActivationEvent()
        }
        .onChange(of: colorScheme) { newColor in
            DispatchQueue.main.async {
                AttributedStringTransformer
                    .convertRichTextHTMLIfExists(uiModel: layout,
                                                 config: baseDI.config,
                                                 colorScheme: newColor)
            }
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
