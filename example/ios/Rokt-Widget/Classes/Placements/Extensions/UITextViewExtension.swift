//
//  UITextViewExtension.swift
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

internal extension UITextView {
    var numberOfVisibleLines: Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font?.lineHeight ?? 1
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin,
                                         attributes: [.font: font as Any], context: nil)
        let lines = Int(textSize.height/charSize)
        return lines
    }
    func set(textViewData: TextViewData?, editingFinished: (() -> Void)? = nil) {
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
                    self.setParagraphStyle(text: text, lineSpacing: style.lineSpacing, alignment: style.alignment)
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
    
    func set(textViewData: TextViewData?, extraString: String, editingFinished: (() -> Void)? = nil) {
        var extendedTextViewData: TextViewData?
        if textViewData != nil {
            extendedTextViewData = TextViewData(text: textViewData!.text + extraString,
                                                textStyleViewData: textViewData!.textStyleViewData,
                                                padding: textViewData!.padding)
        }
        set(textViewData: extendedTextViewData, editingFinished: editingFinished)
    }
    
    private func setParagraphStyle(text: NSMutableAttributedString, lineSpacing: Float, alignment: ViewAlignment) {
        text.adjustParagraphStyle(lines: numberOfVisibleLines, lineSpacing: lineSpacing, alignment: alignment)
        attributedText = text
    }
    
    func getLasLineWidth() -> CGFloat {
        guard let message = self.attributedText else { return CGFloat.zero }

        let textViewSize = CGSize(width: self.bounds.width, height: .infinity)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: textViewSize)
        let textStorage = NSTextStorage(attributedString: message)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = .byWordWrapping
        textContainer.maximumNumberOfLines = 0

        let lastGlyphIndex = layoutManager.glyphIndexForCharacter(at: message.length - 1)
        let lastLineFragmentRect = layoutManager.lineFragmentUsedRect(forGlyphAt: lastGlyphIndex,
                                                                      effectiveRange: nil)

        return lastLineFragmentRect.maxX
    }
    
}
