//
//  UILabelExtension.swift
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

internal extension UILabel {
    var numberOfVisibleLines: Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin,
                                         attributes: [.font: font as Any], context: nil)
        let lines = Int(textSize.height/charSize)
        return lines
    }
    
    func set(
        textViewData: TextViewData?,
        lineBreakMode: NSLineBreakMode? = nil,
        editingFinished: (() -> Void)? = nil
    ) {
        DispatchQueue.main.async {
            if let textViewData = textViewData {
                if let attributedString = textViewData.text.htmlAttributed {
                    self.isHidden = false
                    let style = textViewData.textStyleViewData
                    let text = NSMutableAttributedString(attributedString: attributedString)
                    if let font = UIFont(name: style.fontFamily, size: CGFloat(style.fontSize)) {
                        text.setFontFace(font: font, color: UIColor(colorMap: style.fontColor, self.traitCollection))
                    }
                    // Need to set the text of the label to calculate the number of visible lines
                    self.attributedText = text

                    var lineBreak = textViewData.textStyleViewData.lineBreakMode

                    // currently used by text-based progress indicator
                    if let lineBreakOverride = lineBreakMode {
                        lineBreak = lineBreakOverride
                    }

                    self.setParagraphStyle(
                        text: text,
                        lineSpacing: style.lineSpacing,
                        alignment: style.alignment,
                        lineBreakMode: lineBreak
                    )

                    self.textAlignment = text.getAlignment(style.alignment)
                    if let backColor = style.backgroundColor {
                        self.backgroundColor = UIColor(colorMap: backColor, self.traitCollection)
                    }
                }
            } else {
                self.text = ""
                self.isHidden = true
            }
            editingFinished?()
        }
    }
    
    private func setParagraphStyle(
        text: NSMutableAttributedString,
        lineSpacing: Float,
        alignment: ViewAlignment,
        lineBreakMode: NSLineBreakMode? = nil
    ) {
        text.adjustParagraphStyle(
            lines: numberOfVisibleLines,
            lineSpacing: lineSpacing,
            alignment: alignment,
            lineBreakMode: lineBreakMode
        )

        attributedText = text
    }
    
    func set(pageIndicatorStyle: TextStyleViewData, text: String) {
        self.text = text
        font = UIFont(name: pageIndicatorStyle.fontFamily, size: CGFloat(pageIndicatorStyle.fontSize))
        textColor = UIColor(colorMap: pageIndicatorStyle.fontColor, self.traitCollection)
    }
}
