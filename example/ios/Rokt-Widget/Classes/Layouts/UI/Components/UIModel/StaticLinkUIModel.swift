//
//  StaticLinkUIModel.swift
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
struct StaticLinkUIModel: Identifiable, Hashable {
    let id: UUID = UUID()
    var children: [LayoutSchemaUIModel]?
    
    let src: String
    let open: LinkOpenTarget
    let defaultStyle: [StaticLinkStyles]?
    let pressedStyle: [StaticLinkStyles]?
    let hoveredStyle: [StaticLinkStyles]?
    let disabledStyle: [StaticLinkStyles]?

    init(children: [LayoutSchemaUIModel]?,
         src: String,
         open: LinkOpenTarget,
         defaultStyle: [StaticLinkStyles]?,
         pressedStyle: [StaticLinkStyles]?,
         hoveredStyle: [StaticLinkStyles]?,
         disabledStyle: [StaticLinkStyles]?) {
        self.children = children
        
        self.src = src
        self.open = open
        self.defaultStyle = defaultStyle
        self.pressedStyle = pressedStyle
        self.hoveredStyle = hoveredStyle
        self.disabledStyle = disabledStyle
    }
    
}
