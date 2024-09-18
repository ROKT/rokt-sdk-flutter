//
//  String+Extension.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import SwiftUI

@available(iOS 15, *)
internal extension Text {
    init(html: String,
         textColorHex: String?,
         uiFont: UIFont?,
         linkStyles: InlineTextStylingProperties?,
         colorScheme: ColorScheme) {
        if let attributedString = try? html.htmlToAttributedString(textColorHex: textColorHex,
                                                                   uiFont: uiFont,
                                                                   linkStyles: linkStyles, 
                                                                   colorScheme: colorScheme) {
            self.init(AttributedString(attributedString))
        } else {
            self.init(html)
        }
    }
    
    init(string: String, attributedString: AttributedString?) {
        if let attributedString {
            self.init(attributedString)
        } else {
            self.init(string)
        }
    }
}

@available(iOS 15, *)
internal extension StringProtocol {
    func htmlToAttributedString(
        textColorHex: String?,
        uiFont: UIFont?,
        linkStyles: InlineTextStylingProperties?,
        colorScheme: ColorScheme
    ) throws -> NSAttributedString {
        var convertedText = String(self)

        if let textColorHex {
            convertedText = "<font color=\(textColorHex)>" + self + "</font>"
        }

        let nsAttrStr = try NSMutableAttributedString(
            data: Data(convertedText.utf8),
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        )

        let attributedString = try AttributedString(nsAttrStr, including: \.uiKit)

        // add font weight here
        let morphedAttributeString = attributedString.transformingAttributes(AttributeScopes.UIKitAttributes.FontAttribute.self) { attrFont in
            let isBold = (attrFont.value?.fontDescriptor.symbolicTraits.contains(.traitBold)) == true
            let isItalic = (attrFont.value?.fontDescriptor.symbolicTraits.contains(.traitItalic)) == true

            // remove font property override (TimesNewRoman)
            attrFont.value = nil

            guard var uiFont else { return }

            if isBold, let boldFont = uiFont.including(symbolicTraits: .traitBold) {
                uiFont = boldFont
            }

            if isItalic, let italicFont = uiFont.including(symbolicTraits: .traitItalic) {
                uiFont = italicFont
            }

            attrFont.value = uiFont
        }

        // link styling must happen last
        let mutableMorphed = NSMutableAttributedString(morphedAttributeString)

        return updateLinkStyles(linkStyles, attrStr: mutableMorphed, colorScheme: colorScheme)
    }

    private func updateLinkStyles(_ linkStyles: InlineTextStylingProperties?,
                                  attrStr: NSMutableAttributedString,
                                  colorScheme: ColorScheme) -> NSAttributedString {
        let attrStrCopy = attrStr

        guard let linkStyles else { return attrStrCopy }

        let attrRange = NSRange(0..<attrStrCopy.length)
        attrStrCopy.enumerateAttribute(.link, in: attrRange) { strValue, range, _ in
            guard strValue != nil else { return }

            setLinkColor(textColorHex: linkStyles.textColor?.getAdaptiveColor(colorScheme),
                         originalStr: attrStrCopy,
                         rangeToChange: range)
            setLinkTextTransform(transform: linkStyles.textTransform, originalStr: attrStrCopy, rangeToChange: range)
            setLinkTextDecoration(decoration: linkStyles.textDecoration, originalStr: attrStrCopy, rangeToChange: range)
            setLinkLetterSpacing(spacing: linkStyles.letterSpacing, originalStr: attrStrCopy, rangeToChange: range)

            setLinkFontProperties(
                fontFamily: linkStyles.fontFamily,
                fontWeight: linkStyles.fontWeight,
                fontSize: linkStyles.fontSize,
                fontStyle: linkStyles.fontStyle,
                fontBaselineAlignment: linkStyles.baselineTextAlign,
                originalStr: attrStrCopy,
                rangeToChange: range
            )
        }

        return attrStrCopy
    }

    private func setLinkColor(textColorHex: String?, originalStr: NSMutableAttributedString, rangeToChange: NSRange) {
        guard let textColorHex else { return }

        originalStr.addAttribute(
            NSAttributedString.Key.foregroundColor,
            value: UIColor(hexString: textColorHex),
            range: rangeToChange
        )
    }

    private func setLinkTextTransform(transform: TextTransform?, originalStr: NSMutableAttributedString, rangeToChange: NSRange) {
        guard let transform else { return }

        let origString = originalStr.string as NSString
        let displayText = origString.substring(with: rangeToChange)

        switch transform {
        case .uppercase:
            originalStr.replaceCharacters(
                in: rangeToChange,
                with: displayText.uppercased()
            )
        case .lowercase:
            originalStr.replaceCharacters(
                in: rangeToChange,
                with: displayText.lowercased()
            )
        case .capitalize:
            originalStr.replaceCharacters(
                in: rangeToChange,
                with: displayText.capitalized
            )
        default:
            break
        }
    }

    private func setLinkTextDecoration(decoration: TextDecoration?, originalStr: NSMutableAttributedString, rangeToChange: NSRange) {
        guard let decoration else { return }

        // remove default underline
        originalStr.removeAttribute(NSAttributedString.Key.underlineStyle, range: rangeToChange)

        switch decoration {
        case .underline:
            originalStr.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: rangeToChange)
        case .strikeThrough:
            originalStr.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: rangeToChange)
        case .none:
            originalStr.addAttribute(NSAttributedString.Key.underlineStyle, value: 0, range: rangeToChange)
            originalStr.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: rangeToChange)
        }
    }

    private func setLinkLetterSpacing(spacing: Float?, originalStr: NSMutableAttributedString, rangeToChange: NSRange) {
        guard let spacing else { return }

        originalStr.addAttribute(NSAttributedString.Key.kern, value: CGFloat(spacing), range: rangeToChange)
    }

    private func setLinkFontProperties(
        fontFamily: String?,
        fontWeight: FontWeight?,
        fontSize: Float?,
        fontStyle: FontStyle?,
        fontBaselineAlignment: FontBaselineAlignment?,
        originalStr: NSMutableAttributedString,
        rangeToChange: NSRange
    ) {
        originalStr.enumerateAttribute(.font, in: rangeToChange) { fontAtRange, fontRange, _ in
            guard let fRange = fontAtRange as? UIFont else { return }

            var updatedFont = fRange

            if let fontFamily, let customFont = UIFont(name: fontFamily, size: fRange.pointSize) {
                updatedFont = customFont
            }


            guard let fDesc = updatedFont.fontDescriptor.withSymbolicTraits([]) else { return }

            if let fontSize {
                updatedFont = UIFont(descriptor: fDesc, size: fontSize.getAsScaledFontSize())
            }

            if let fontWeight {
                updatedFont = updatedFont.withWeight(fontWeight.asUIFontWeight)
            }

            if let fontStyle {
                var traits: UIFontDescriptor.SymbolicTraits = []

                switch fontStyle {
                case .italic:
                    traits = traits.union(.traitItalic)
                case .normal:
                    traits = traits.union(.traitBold)
                }

                // have to check this again in case new descriptors like fontWeight were added
                guard let fontWithTraitsDescriptor = updatedFont.fontDescriptor.withSymbolicTraits(traits) else { return }

                updatedFont = UIFont(descriptor: fontWithTraitsDescriptor, size: updatedFont.pointSize)
            }

            // has to be applied last
            if let fontBaselineAlignment {
                var baselineOffset = CGFloat(0)
                switch fontBaselineAlignment {
                case .sub:
                    baselineOffset = updatedFont.ascender * -0.5
                case .super:
                    baselineOffset = updatedFont.ascender * 0.5
                default:
                    break
                }

                originalStr.addAttribute(.baselineOffset, value: baselineOffset, range: fontRange)
            }

            originalStr.addAttribute(.font, value: updatedFont, range: fontRange)
        }
    }
}
