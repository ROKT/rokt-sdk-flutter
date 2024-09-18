//
//  OneByOneUIModel.swift
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
struct OneByOneUIModel: Identifiable, Hashable {
    
    let id: UUID = UUID()
    var children: [LayoutSchemaUIModel]?
    let defaultStyle: [OneByOneDistributionStyles]?
    let transition: Transition?
    
    init(children: [LayoutSchemaUIModel]?,
         defaultStyle: [OneByOneDistributionStyles]?,
         transition: Transition?) {
        self.children = children
        self.defaultStyle = defaultStyle
        self.transition = transition
    }
}
