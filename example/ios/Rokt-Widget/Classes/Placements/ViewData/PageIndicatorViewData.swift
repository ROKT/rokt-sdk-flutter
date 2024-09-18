//
//  PageIndicatorViewData.swift
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
struct PageIndicatorViewData: Equatable {
    let type: PageIndicatorType
    let seenItems: Int
    let unseenItems: Int
    let backgroundSeen: ColorMap
    let backgroundUnseen: ColorMap
    let textViewDataSeen: TextStyleViewData?
    let textViewDataUnseen: TextStyleViewData?
    let paddingSize: Float
    let diameter: Float
    let startIndex: Int
    let location: PageIndicatorLocation
    let dashesWidth: Float
    let dashesHeight: Float
    let margin: FrameAlignment?
    let textBasedIndicatorViewData: TextViewData?
}
