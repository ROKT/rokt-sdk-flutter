//
//  CloseButtonUIModel.swift
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
struct CloseButtonUIModel: Identifiable, Hashable {
    let id: UUID = UUID()
    let children: [LayoutSchemaUIModel]?
    let defaultStyle: [CloseButtonStyles]?
    let pressedStyle: [CloseButtonStyles]?
    let hoveredStyle: [CloseButtonStyles]?
    let disabledStyle: [CloseButtonStyles]?
    
    init(children: [LayoutSchemaUIModel]?,
         defaultStyle: [CloseButtonStyles]?,
         pressedStyle: [CloseButtonStyles]?,
         hoveredStyle: [CloseButtonStyles]?,
         disabledStyle: [CloseButtonStyles]?) {
        self.children = children
        self.defaultStyle = defaultStyle
        self.pressedStyle = pressedStyle
        self.hoveredStyle = hoveredStyle
        self.disabledStyle = disabledStyle
    }
    
}
