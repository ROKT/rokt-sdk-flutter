//
//  CreativeResponseUIModel.swift
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
struct CreativeResponseUIModel: Identifiable, Hashable {
    let id: UUID = UUID()
    var children: [LayoutSchemaUIModel]?
    let responseKey: BNFNamespace.CreativeResponseKey
    let responseOptions: ResponseOption?
    let openLinks: LinkOpenTarget?

    let defaultStyle: CreativeResponseStyles?
    let pressedStyle: CreativeResponseStyles?
    let hoveredStyle: CreativeResponseStyles?
    let disabledStyle: CreativeResponseStyles?

    init(children: [LayoutSchemaUIModel]?,
         responseKey: BNFNamespace.CreativeResponseKey,
         responseOptions: ResponseOption?,
         openLinks: LinkOpenTarget?,
         defaultStyle: CreativeResponseStyles?,
         pressedStyle: CreativeResponseStyles?,
         hoveredStyle: CreativeResponseStyles?,
         disabledStyle: CreativeResponseStyles?) {
        self.children = children
        self.responseKey = responseKey
        self.responseOptions = responseOptions
        self.defaultStyle = defaultStyle
        self.pressedStyle = StyleTransformer.getUpdatedStyle(defaultStyle,
                                                             newStyle: pressedStyle)
        self.hoveredStyle = StyleTransformer.getUpdatedStyle(defaultStyle,
                                                             newStyle: hoveredStyle)
        self.disabledStyle = StyleTransformer.getUpdatedStyle(defaultStyle,
                                                              newStyle: disabledStyle)
        self.openLinks = openLinks
    }
    
}
