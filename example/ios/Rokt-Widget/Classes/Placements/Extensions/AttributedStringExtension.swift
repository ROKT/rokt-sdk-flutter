//
//  AttributedStringExtension.swift
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

internal extension NSMutableAttributedString {
    func setFontFace(font: UIFont, color: UIColor? = nil) {
        beginEditing()
        
        self.enumerateAttribute(.font, in: NSRange(location: 0, length: self.length)) { (value, range, _) in
            if let f = value as? UIFont,
                let newFontDescriptor = f.fontDescriptor.withFamily(font.familyName)
                    .withSymbolicTraits(f.fontDescriptor.symbolicTraits) {
                let newFont = UIFont(descriptor: newFontDescriptor, size: font.pointSize)
                removeAttribute(.font, range: range)
                addAttribute(.font, value: newFont, range: range)
                if let color = color {
                    removeAttribute(.foregroundColor, range: range)
                    addAttribute(.foregroundColor, value: color, range: range)
                }
            }
        }
        
        endEditing()
    }
    
    func adjustParagraphStyle(
        lines: Int,
        lineSpacing: Float,
        alignment: ViewAlignment,
        lineBreakMode: NSLineBreakMode? = nil
    ) {
        beginEditing()
        let paragraphStyle = NSMutableParagraphStyle()

        if let lineBreakMode = lineBreakMode {
            paragraphStyle.lineBreakMode = lineBreakMode
        }

        if lines == 1 {
            paragraphStyle.lineSpacing = 0
        } else {
            paragraphStyle.lineSpacing = CGFloat(lineSpacing)
        }
        paragraphStyle.alignment = getAlignment(alignment)
        addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: self.length))
        endEditing()
    }
    
    func getAlignment(_ alignment: ViewAlignment) -> NSTextAlignment {
        switch alignment {
        case .center:
            return .center
        case .start:
            return .left
        case .end:
            return .right
        default:
            return .left
        }
    }
}
