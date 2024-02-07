//
//  DataImageUIModel.swift
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
class DataImageUIModel: Hashable, Identifiable, ObservableObject{
    
    let id: UUID = UUID()
    
    let image: CreativeImage?
    let defaultStyle: DataImageStyles?
    let pressedStyle: DataImageStyles?
    let hoveredStyle: DataImageStyles?
    let disabledStyle: DataImageStyles?
    
    init(image: CreativeImage?,
         defaultStyle: DataImageStyles?,
         pressedStyle: DataImageStyles?,
         hoveredStyle: DataImageStyles?,
         disabledStyle: DataImageStyles?) {
        self.image = image
        self.defaultStyle = defaultStyle
        self.pressedStyle = StyleTransformer.getUpdatedStyle(defaultStyle, newStyle: pressedStyle)
        self.hoveredStyle = StyleTransformer.getUpdatedStyle(defaultStyle, newStyle: hoveredStyle)
        self.disabledStyle = StyleTransformer.getUpdatedStyle(defaultStyle, newStyle: disabledStyle)
    }
}
