//
//  LabelProperties.swift
//  Rokt-Widget
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

class LabelProperties: LayoutProperties {
    let label: UILabel?

    init(label: UILabel?,
         height: NSLayoutConstraint,
         spacingTop: NSLayoutConstraint? = nil,
         spacingRight: NSLayoutConstraint? = nil,
         spacingBottom: NSLayoutConstraint? = nil,
         spacingLeft: NSLayoutConstraint? = nil) {
        self.label = label
        super.init(height: height,
                   spacingTop: spacingTop,
                   spacingRight: spacingRight,
                   spacingBottom: spacingBottom,
                   spacingLeft: spacingLeft)
    }

    func resizeLabel() {
        if label?.text == "" {
            resizeToZero()
        } else {
            label?.layoutIfNeeded()
            label?.sizeToFit()
            resizeToHeight(newHeight: label?.frame.height)
        }
    }
}
