//
//  ImageUIModel.swift
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
struct StaticImageUIModel: Hashable, Identifiable {

    let id: UUID = UUID()
    
    let url: StaticImageUrl?
    let alt: String?
    let defaultStyle: StaticImageStyles?
    let pressedStyle: StaticImageStyles?
    let hoveredStyle: StaticImageStyles?
    let disabledStyle: StaticImageStyles?
    
    init(url: StaticImageUrl?,
         alt: String?,
         defaultStyle: StaticImageStyles?,
         pressedStyle: StaticImageStyles?,
         hoveredStyle: StaticImageStyles?,
         disabledStyle: StaticImageStyles?) {
        self.url = url
        self.alt = alt
        self.defaultStyle = defaultStyle
        self.pressedStyle = StyleTransformer.getUpdatedStyle(defaultStyle, newStyle: pressedStyle)
        self.hoveredStyle = StyleTransformer.getUpdatedStyle(defaultStyle, newStyle: hoveredStyle)
        self.disabledStyle = StyleTransformer.getUpdatedStyle(defaultStyle, newStyle: disabledStyle)
    }
}
