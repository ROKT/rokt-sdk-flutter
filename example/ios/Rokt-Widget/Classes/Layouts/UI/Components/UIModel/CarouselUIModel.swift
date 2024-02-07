//
//  CarouselUIModel.swift
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
struct CarouselUIModel: Identifiable, Hashable {
    let id: UUID = UUID()
    var children: [LayoutSchemaUIModel]?
    let defaultStyle: CarouselDistributionStyles?
    let viewableItems: [UInt8]
    let peekThroughSize: [PeekThroughSize]
    
    init(children: [LayoutSchemaUIModel]?,
         defaultStyle: CarouselDistributionStyles?,
         viewableItems: [UInt8],
         peekThroughSize: [PeekThroughSize]) {
        self.children = children
        self.defaultStyle = defaultStyle
        self.viewableItems = viewableItems
        self.peekThroughSize = peekThroughSize
    }
}
