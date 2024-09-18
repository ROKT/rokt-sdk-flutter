//
//  TextViewData.swift
//  Pods
//
//  Copyright 2020 Rokt Pte Ltd
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation

struct ImageViewData: Equatable {
    let imageUrl: String?
    let imageHideOnDark: Bool
    let imageMaxHeight: Float?
    let imageMaxWidth: Float?
    let creativeTitleImageArrangment: CreativeTitleImageArrangement
    let creativeTitleImageAlignment: CreativeTitleImageAlignment
    let creativeTitleImageSpacing: Float

    init(imageUrl: String? = nil,
         imageHideOnDark: Bool,
         imageMaxHeight: Float? = nil,
         imageMaxWidth: Float? = nil,
         creativeTitleImageArrangment: CreativeTitleImageArrangement,
         creativeTitleImageAlignment: CreativeTitleImageAlignment,
         creativeTitleImageSpacing: Float) {
        self.imageUrl = imageUrl
        self.imageHideOnDark = imageHideOnDark
        self.imageMaxHeight = imageMaxHeight
        self.imageMaxWidth = imageMaxWidth
        self.creativeTitleImageArrangment = creativeTitleImageArrangment
        self.creativeTitleImageAlignment = creativeTitleImageAlignment
        self.creativeTitleImageSpacing = creativeTitleImageSpacing
    }
}
