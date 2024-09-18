//
//  ZStackUIModel.swift
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
struct ZStackUIModel: Identifiable, Hashable {
    let id: UUID = UUID()
    var children: [LayoutSchemaUIModel]?
    let defaultStyle: [ZStackStyle]?
    let pressedStyle: [ZStackStyle]?
    let hoveredStyle: [ZStackStyle]?
    let disabledStyle: [ZStackStyle]?
    let accessibilityGrouped: Bool
    
    init(children: [LayoutSchemaUIModel]?,
         defaultStyle: [ZStackStyle]?,
         pressedStyle: [ZStackStyle]?,
         hoveredStyle: [ZStackStyle]?,
         disabledStyle: [ZStackStyle]?,
         accessibilityGrouped: Bool) {
        self.children = children
        self.defaultStyle = defaultStyle
        self.pressedStyle = pressedStyle
        self.hoveredStyle = hoveredStyle
        self.disabledStyle = disabledStyle
        self.accessibilityGrouped = accessibilityGrouped
    }
}
