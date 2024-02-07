//
//  RoktEmbeddedComponentViewModel.swift
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
struct RoktEmbeddedViewModel {
    let layouts: [LayoutSchemaUIModel]?
    let baseDI: BaseDependencyInjection
    
    func sendPluginImpressionEvent() {
        baseDI.eventProcessor.sendPluginImpressionEvent()
    }
    
    func sendSignalActivationEvent() {
        baseDI.eventProcessor.sendSignalActivationEvent()
    }
}
