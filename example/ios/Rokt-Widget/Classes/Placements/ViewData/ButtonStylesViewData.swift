//
//  ButtonStylesViewData.swift
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

// conform to NSObject to allow `isEqual` override
class ButtonStylesViewData: NSObject {
    let defaultStyle: ButtonStyleViewData
    let pressedStyle: ButtonStyleViewData

    init(
        defaultStyle: ButtonStyleViewData,
        pressedStyle: ButtonStyleViewData
    ) {
        self.defaultStyle = defaultStyle
        self.pressedStyle = pressedStyle
    }

    static func isEqual (lhs: ButtonStylesViewData, rhs: ButtonStylesViewData) -> Bool {
        lhs.defaultStyle == rhs.defaultStyle && lhs.pressedStyle == rhs.pressedStyle
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let buttonData = object as? ButtonStylesViewData else { return false }

        return defaultStyle == buttonData.defaultStyle &&
            pressedStyle == buttonData.pressedStyle
    }
}

class ButtonWithDimensionStylesViewData: ButtonStylesViewData {
    let margin: FrameAlignment
    let minHeight: CGFloat

    init(
        defaultStyle: ButtonStyleViewData,
        pressedStyle: ButtonStyleViewData,
        margin: FrameAlignment,
        minHeight: CGFloat
    ) {
        self.margin = margin
        self.minHeight = minHeight

        super.init(defaultStyle: defaultStyle, pressedStyle: pressedStyle)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let buttonData = object as? ButtonWithDimensionStylesViewData else { return false }

        return defaultStyle == buttonData.defaultStyle &&
            pressedStyle == buttonData.pressedStyle &&
            margin == buttonData.margin &&
            minHeight == buttonData.minHeight
    }
}
