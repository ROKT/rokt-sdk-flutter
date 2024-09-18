//
//  UIButtonExtension.swift
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

internal extension UIButton {
    func set(text: String?, styles: ButtonStylesViewData, traitCollection: UITraitCollection) {
        self.set(text: text,
                 textStyle: styles.defaultStyle.textStyleViewData,
                 for: .normal,
                 traitCollection: traitCollection)
        self.set(text: text,
                 textStyle: styles.pressedStyle.textStyleViewData,
                 for: .highlighted,
                 traitCollection: traitCollection)
    }

    func set(text: String?, textStyle: TextStyleViewData, for state: UIControl.State,
             traitCollection: UITraitCollection, editingFinished: (() -> Void)? = nil) {
        guard let font = UIFont(name: textStyle.fontFamily, size: CGFloat(textStyle.fontSize))
        else {
            // report diagnostics
            RoktAPIHelper.sendDedupedFontDiagnostics(textStyle.fontFamily)
            return
        }
        DispatchQueue.main.async {
            if let attributedText = text?.htmlAttributed {

                let title = NSMutableAttributedString(attributedString: attributedText)
                title.setFontFace(font: font,
                                  color: UIColor(colorMap: textStyle.fontColor, traitCollection),
                                  fontWeight: textStyle.fontWeight?.asUIFontWeight)
                self.setAttributedTitle(title, for: state)
                self.layoutIfNeeded()
                self.contentHorizontalAlignment = self.getContentHorizontalAlignment(alignment:
                                                                                        textStyle.alignment)
                title.adjustParagraphStyle(lines: self.titleLabel?.numberOfVisibleLines ?? 1,
                                           lineSpacing: textStyle.lineSpacing,
                                           alignment: textStyle.alignment)
                self.setAttributedTitle(title, for: state)
                if let background = textStyle.backgroundColor {
                    self.setBackgroundColor(color: UIColor(colorMap: background, traitCollection), for: state)
                }
            }
            editingFinished?()
        }
    }

    func setBorder(style: ButtonStyleViewData, traitCollection: UITraitCollection) {
        layer.cornerRadius = CGFloat(style.cornerRadius)
        layer.borderColor = UIColor(colorMap: style.borderColor, traitCollection).cgColor
        layer.borderWidth = CGFloat(style.borderThickness)
        clipsToBounds = true
    }

    func setBackgroundColor(color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()?.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.setBackgroundImage(colorImage, for: state)
    }

    private func getContentHorizontalAlignment(alignment: ViewAlignment) -> ContentHorizontalAlignment {
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
