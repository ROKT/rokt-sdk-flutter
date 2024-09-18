//
//  DividerViewData.swift
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
class DividerViewData: NSObject {
    let backgroundColor: ColorMap?
    let isVisible: Bool

    init(
        backgroundColor: ColorMap? = nil,
        isVisible: Bool = true
    ) {
        self.backgroundColor = backgroundColor
        self.isVisible = isVisible
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let dividerViewData = object as? DividerViewData else { return false }

        return backgroundColor == dividerViewData.backgroundColor &&
            isVisible == dividerViewData.isVisible
    }
}

class DividerViewDataWithDimensions: DividerViewData {
    let height: CGFloat
    let margin: FrameAlignment

    init(
        backgroundColor: ColorMap? = nil,
        isVisible: Bool,
        height: CGFloat,
        margin: FrameAlignment
    ) {
        self.height = height
        self.margin = margin

        super.init(backgroundColor: backgroundColor, isVisible: isVisible)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let dividerViewData = object as? DividerViewDataWithDimensions else { return false }

        return backgroundColor == dividerViewData.backgroundColor &&
            isVisible == dividerViewData.isVisible &&
            height == dividerViewData.height &&
            margin == dividerViewData.margin
    }
}
