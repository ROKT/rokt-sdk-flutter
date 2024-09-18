//
//  RoktLayout.swift
//  Pods
//
//  Copyright 2020 Rokt Pte Ltd
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import SwiftUI

@available(iOS 15, *)
public struct RoktLayout: View {
    
    @Binding var sdkTriggered: Bool

    private let viewName: String?
    internal let locationName: String
    private let attributes: [String: String]
    private let config: RoktConfig?
    private let onLoad: (() -> Void)?
    private let onUnLoad: (() -> Void)?
    private let onShouldShowLoadingIndicator: (() -> Void)?
    private let onShouldHideLoadingIndicator: (() -> Void)?
    private let onRoktEvent: ((RoktEvent) -> Void)?
    
    @State private var layoutInitialized = false
    @State private var layoutUIModel: LayoutSchemaUIModel?
    @State private var baseDI: BaseDependencyInjection?
    @State private var onSDKLoaded: (() -> Void)?
    @State private var isVisible = true
    
    public init(sdkTriggered: Binding<Bool>,
                viewName: String? = nil,
                locationName: String = "",
                attributes: [String: String],
                config: RoktConfig? = nil,
                onLoad: (() -> Void)? = nil,
                onUnLoad: (() -> Void)? = nil,
                onShouldShowLoadingIndicator: (() -> Void)? = nil,
                onShouldHideLoadingIndicator: (() -> Void)? = nil) {
        _sdkTriggered = sdkTriggered
        self.viewName = viewName
        self.locationName = locationName
        self.attributes = attributes
        self.config = config
        self.onLoad = onLoad
        self.onUnLoad = onUnLoad
        self.onShouldShowLoadingIndicator = onShouldShowLoadingIndicator
        self.onShouldHideLoadingIndicator = onShouldHideLoadingIndicator
        self.onRoktEvent = nil
    }
    
    public init(sdkTriggered: Binding<Bool>,
                viewName: String? = nil,
                locationName: String = "",
                attributes: [String: String],
                config: RoktConfig? = nil,
                onEvent: ((RoktEvent) -> Void)? = nil) {
        _sdkTriggered = sdkTriggered
        self.viewName = viewName
        self.locationName = locationName
        self.attributes = attributes
        self.config = config
        self.onLoad = nil
        self.onUnLoad = nil
        self.onShouldShowLoadingIndicator = nil
        self.onShouldHideLoadingIndicator = nil
        self.onRoktEvent = onEvent
    }
    
    public var body: some View {
        VStack{
            if layoutInitialized && isVisible,
               let layoutUIModel, let baseDI, let onSDKLoaded {
                EmbeddedComponent(layout: layoutUIModel, baseDI: baseDI,
                                  onLoad: onSDKLoaded, onSizeChange: nil)
                .customColorMode(colorMode: config?.colorMode)
            }
        }
        .onAppear {
            if sdkTriggered {
                execute()
            }
        }
        .onChange(of: sdkTriggered) { isTriggered in
            if isTriggered {
                execute()
            }
        }
    }
    
    private func execute() {
        Rokt.execute(viewName: viewName,
                     attributes: attributes,
                     layout: self,
                     config: config,
                     onLoad: onLoad,
                     onUnLoad: onUnLoad,
                     onShouldShowLoadingIndicator: onShouldShowLoadingIndicator,
                     onShouldHideLoadingIndicator: onShouldHideLoadingIndicator,
                     onRoktEvent: onRoktEvent)
    }
    
    internal func loadLayout(layoutUIModel: LayoutSchemaUIModel?,
                             baseDI: BaseDependencyInjection?,
                             onSDKLoaded: (() -> Void)?,
                             onSDKUnloaded: (() -> Void)?) {
        self.layoutUIModel = layoutUIModel
        self.baseDI = baseDI
        self.onSDKLoaded = onSDKLoaded
        self.layoutInitialized = true
        
        baseDI?.actionCollection[.close] = closeEmbedded
        func closeEmbedded(_: Any? = nil) {
            // remove the view
            self.isVisible = false
            // call onUnload of SDK
            onSDKUnloaded?()
        }
    }
}

