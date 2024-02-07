//
//  SSOT+Extension.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation
import SwiftUI

@available(iOS 13, *)
extension FontJustification {
    var asHorizontalAlignmentProperty: HorizontalAlignmentProperty {
        switch self {
        case .right:
            return .end
        case .center:
            return .center
        case .left:
            return .start
        case .end:
            return (DeviceLanguage.direction() == .leftToRight) ? .end : .start
        case .start, .justify:
            return (DeviceLanguage.direction() == .leftToRight) ? .start : .end
        }
    }

    var asAlignment: Alignment {
        switch self {
        case .right:
            return .trailing
        case .center:
            return .center
        case .left:
            return .leading
        case .end:
            return (DeviceLanguage.direction() == .leftToRight) ? .trailing : .leading
        case .start, .justify:
            return (DeviceLanguage.direction() == .leftToRight) ? .leading : .trailing
        }
    }

    var asTextAlignment: TextAlignment {
        switch self {
        case .right:
            return .trailing
        case .center:
            return .center
        case .left:
            return .leading
        case .end:
            return (DeviceLanguage.direction() == .leftToRight) ? .trailing : .leading
        case .start, .justify:
            return (DeviceLanguage.direction() == .leftToRight) ? .leading : .trailing
        }
    }
}

@available(iOS 13, *)
extension TextStylingProperties {
    private func asDistinctWeight(numericWeight: Int) -> FontWeightUIModel {
        switch numericWeight {
            case ...199: return .thin
            case 200...299: return .ultralight
            case 300...399: return .light
            case 400...499: return .normal
            case 500...599: return .medium
            case 600...699: return .semibold
            case 700...799: return .bold
            case 800...899: return .heavy
            case 900...: return .black
            default: return .normal
        }
    }

    var convertedWeight: FontWeightUIModel {
        guard let fontWeight, let nWeight = Int(fontWeight.rawValue) else { return .normal }

        return asDistinctWeight(numericWeight: nWeight)
    }

    var weightedUIFont: UIFont? {
        guard let fontSize else { return nil }

        // default to SanFrancisco font
        var uiFont: UIFont = .systemFont(ofSize: CGFloat(fontSize))

        if let fontFamily, let customFont = UIFont(name: fontFamily, size: CGFloat(fontSize)) {
            // update if possible
            uiFont = customFont
        }

        return uiFont.withWeight(convertedWeight.asUIFontWeight)
    }

    var styledFont: Font? {
        guard let weightedUIFont else { return nil }

        guard let fontStyle else { return Font(weightedUIFont) }

        switch fontStyle {
        case .italic: return Font(weightedUIFont.setItalic())
        default: return Font(weightedUIFont)
        }
    }
    
    var styledUIFont: UIFont? {
        guard let weightedUIFont else { return nil }
        
        guard let fontStyle else { return weightedUIFont }
        
        switch fontStyle {
        case .italic: return weightedUIFont.setItalic()
        default: return weightedUIFont
        }
    }

    var baselineOffset: CGFloat {
        guard let baselineTextAlign, let weightedUIFont else { return 0 }

        switch baselineTextAlign {
        case .sub: return weightedUIFont.ascender * -0.5
        case .super: return weightedUIFont.ascender * 0.5
        case .baseline: return 0
        }
    }
}

struct DeviceLanguage {
    static func direction() -> Locale.LanguageDirection {
        guard let language = Locale.current.languageCode else { return .leftToRight }

        return Locale.characterDirection(forLanguage: language)
    }
}
