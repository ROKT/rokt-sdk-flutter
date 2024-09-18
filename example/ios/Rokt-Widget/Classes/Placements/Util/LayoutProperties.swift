//
//  LayoutProperties.swift
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

class LayoutProperties {
    let height: NSLayoutConstraint?
    var spacingTop: NSLayoutConstraint?
    var spacingRight: NSLayoutConstraint?
    var spacingBottom: NSLayoutConstraint?
    var spacingLeft: NSLayoutConstraint?
    var removeSpacingTopOnEmpty: Bool?

    init(height: NSLayoutConstraint? = nil,
         spacingTop: NSLayoutConstraint? = nil,
         spacingRight: NSLayoutConstraint? = nil,
         spacingBottom: NSLayoutConstraint? = nil,
         spacingLeft: NSLayoutConstraint? = nil,
         removeSpacingTopOnEmpty: Bool? = true) {
        self.height = height
        self.spacingTop = spacingTop
        self.spacingRight = spacingRight
        self.spacingBottom = spacingBottom
        self.spacingLeft = spacingLeft
        self.removeSpacingTopOnEmpty = removeSpacingTopOnEmpty
    }

    func resizeToZero() {
        height?.constant = 0
        if let spacingTop = spacingTop,
           removeSpacingTopOnEmpty == true {
            spacingTop.constant = 0
        }
        if let spacingBottom = spacingBottom {
            spacingBottom.constant = 0
        }
    }

    func resizeToHeight(newHeight: CGFloat?) {
        height?.constant = newHeight ?? 0
    }
}
