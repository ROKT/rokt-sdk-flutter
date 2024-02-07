//
//  BackgroundWithoutFooterViewData.swift
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
struct BackgroundWithoutFooterViewData: Equatable {
    let backgroundColor: ColorMap?
    let cornerRadius: Float?
    let borderThickness: Float?
    let borderColor: ColorMap?
    let padding: FrameAlignment?
    
    init(backgroundColor: ColorMap?,
         cornerRadius: Float?,
         borderThickness: Float?,
         borderColor: ColorMap?,
         padding: FrameAlignment?) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.borderThickness = borderThickness
        self.borderColor = borderColor
        self.padding = padding
    }
}
