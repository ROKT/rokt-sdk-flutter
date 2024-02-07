//
//  FontViewData.swift
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

import UIKit

struct TextStyleViewData: Equatable {
    let fontFamily: String
    let fontSize: Float
    let fontColor: ColorMap
    let backgroundColor: ColorMap?
    let alignment: ViewAlignment
    let lineSpacing: Float
    let lineBreakMode: NSLineBreakMode
    
    init(
        fontFamily: String,
        fontSize: Float,
        fontColor: ColorMap,
        backgroundColor: ColorMap?,
        alignment: ViewAlignment = .start,
        lineSpacing: Float = kDefaultLineSpacing,
        lineBreakMode: NSLineBreakMode = .byTruncatingTail
    ) {
        self.fontFamily = fontFamily
        self.fontSize = fontSize
        self.fontColor = fontColor
        self.backgroundColor = backgroundColor
        self.alignment = alignment
        self.lineSpacing = lineSpacing
        self.lineBreakMode = lineBreakMode
    }
}
