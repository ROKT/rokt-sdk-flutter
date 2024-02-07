//
//  RowUIModel.swift
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
struct RowUIModel: Identifiable, Hashable, DomainMappableParent {
    let id: UUID = UUID()
    var children: [LayoutSchemaUIModel]?
    let defaultStyle: RowStyle?
    let pressedStyle: RowStyle?
    let hoveredStyle: RowStyle?
    let disabledStyle: RowStyle?
    init(children: [LayoutSchemaUIModel]?,
         defaultStyle: RowStyle?,
         pressedStyle: RowStyle?,
         hoveredStyle: RowStyle?,
         disabledStyle: RowStyle?) {
        self.children = children
        self.defaultStyle = defaultStyle
        self.pressedStyle = StyleTransformer.getUpdatedStyle(defaultStyle,
                                                             newStyle: pressedStyle)
        self.hoveredStyle = StyleTransformer.getUpdatedStyle(defaultStyle,
                                                             newStyle: hoveredStyle)
        self.disabledStyle = StyleTransformer.getUpdatedStyle(defaultStyle,
                                                              newStyle: disabledStyle)
    }
    
}
