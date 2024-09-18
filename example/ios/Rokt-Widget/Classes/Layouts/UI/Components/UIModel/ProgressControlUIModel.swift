//
//  ProgressControlUIModel.swift
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
struct ProgressControlUIModel: Identifiable, Hashable {
    let id: UUID = UUID()
    var children: [LayoutSchemaUIModel]?
    let defaultStyle: [ProgressControlStyle]?
    let pressedStyle: [ProgressControlStyle]?
    let hoveredStyle: [ProgressControlStyle]?
    let disabledStyle: [ProgressControlStyle]?
    let direction: ProgressionDirection
    
    init(children: [LayoutSchemaUIModel]?,
         defaultStyle: [ProgressControlStyle]?,
         pressedStyle: [ProgressControlStyle]?,
         hoveredStyle: [ProgressControlStyle]?,
         disabledStyle: [ProgressControlStyle]?,
         direction: ProgressionDirection) {
        self.children = children
        self.defaultStyle = defaultStyle
        self.pressedStyle = pressedStyle
        self.hoveredStyle = hoveredStyle
        self.disabledStyle = disabledStyle
        self.direction = direction
    }
    
}
