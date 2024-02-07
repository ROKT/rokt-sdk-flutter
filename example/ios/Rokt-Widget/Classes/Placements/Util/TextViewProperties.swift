//
//  TextViewProperties.swift
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

class TextViewProperties: LayoutProperties {
    let textView: UITextView?
    
    init(textView: UITextView?,
         height: NSLayoutConstraint,
         spacingTop: NSLayoutConstraint? = nil,
         spacingRight: NSLayoutConstraint? = nil,
         spacingBottom: NSLayoutConstraint? = nil,
         spacingLeft: NSLayoutConstraint? = nil,
         removeSpacingTopOnEmpty: Bool? = true) {
        self.textView = textView
        super.init(height: height,
                   spacingTop: spacingTop,
                   spacingRight: spacingRight,
                   spacingBottom: spacingBottom,
                   spacingLeft: spacingLeft,
                   removeSpacingTopOnEmpty: removeSpacingTopOnEmpty)
    }
    
    func resizeTextView() {
        if textView?.text == "" {
            resizeToZero()
        } else {
            textView?.layoutIfNeeded()
            textView?.sizeToFit()
            resizeToHeight(newHeight: textView?.frame.height)
        }
    }
}
