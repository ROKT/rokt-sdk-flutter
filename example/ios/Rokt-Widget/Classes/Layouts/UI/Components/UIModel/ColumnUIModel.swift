//
//  ColumnUIModel.swift
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
struct ColumnUIModel: Identifiable, Hashable {
    let id: UUID = UUID()
    var children: [LayoutSchemaUIModel]?
    let defaultStyle: ColumnStyle?
    let pressedStyle: ColumnStyle?
    let hoveredStyle: ColumnStyle?
    let disabledStyle: ColumnStyle?
    
    init(children: [LayoutSchemaUIModel]?,
         defaultStyle: ColumnStyle?,
         pressedStyle: ColumnStyle?,
         hoveredStyle: ColumnStyle?,
         disabledStyle: ColumnStyle?) {
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
