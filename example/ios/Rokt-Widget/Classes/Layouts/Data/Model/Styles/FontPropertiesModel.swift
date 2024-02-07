//
//  FontPropertiesModel.swift
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
struct FontPropertiesModel: Decodable, Hashable {
    let size: CGFloat?
    let family: String?
    let weight: String?
    let style: FontStyle?

    var weightedUIFont: UIFont? {
        guard let size else { return nil }

        // default to SanFrancisco font
        var uiFont: UIFont = .systemFont(ofSize: size)

        if let family, let customFont = UIFont(name: family, size: size) {
            // update if possible
            uiFont = customFont
        }

        return uiFont.withWeight(convertedWeight.asUIFontWeight)
    }

    var styledFont: Font? {
        guard let weightedUIFont else { return nil }

        guard let style else { return Font(weightedUIFont) }

        switch style {
        case .italic: return Font(weightedUIFont.setItalic())
        default: return Font(weightedUIFont)
        }
    }

    var styledUIFont: UIFont? {
        guard let weightedUIFont else { return nil }

        guard let style else { return weightedUIFont }

        switch style {
        case .italic: return weightedUIFont.setItalic()
        default: return weightedUIFont
        }
    }

    var convertedWeight: FontWeightUIModel {
        guard let weight else { return .normal }

        if let fWeight = FontWeightUIModel(rawValue: weight) {
            return fWeight
        } else if let nWeight = Int(weight) {
            return asDistinctWeight(numericWeight: nWeight)
        } else {
            return .normal
        }
    }

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
}

enum FontWeightUIModel: String, Decodable {
    case thin
    case ultralight
    case light
    case normal
    case medium
    case semibold
    case bold
    case heavy
    case black

    // adapter pattern to map the platform-agnostic schema response
    // to Apple SDK's UIFont system
    var asUIFontWeight: UIFont.Weight {
        switch self {
        case .thin: return .thin
        case .ultralight: return .ultraLight
        case .light: return .light
        case .normal: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        }
    }
}

extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        var attributes = fontDescriptor.fontAttributes
        var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]

        traits[.weight] = weight

        attributes[.name] = nil
        attributes[.traits] = traits
        attributes[.family] = familyName

        let descriptor = UIFontDescriptor(fontAttributes: attributes)

        return UIFont(descriptor: descriptor, size: pointSize)
    }
}

extension UIFont {
    private var isItalic: Bool {
        fontDescriptor.symbolicTraits.contains(.traitItalic)
    }

    func setItalic() -> UIFont {
        guard !isItalic else { return self }

        var fontTraits = fontDescriptor.symbolicTraits
        fontTraits.insert(.traitItalic)

        guard let fontDescriptor = fontDescriptor.withSymbolicTraits(fontTraits) else { return self }

        return UIFont(descriptor: fontDescriptor, size: 0)
    }
}

extension FontWeight {
    var asUIFontWeight: UIFont.Weight {
        guard let asNumericWeight = Int(self.rawValue) else { return .regular }

        return asDistinctWeight(numericWeight: asNumericWeight).asUIFontWeight
    }

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
}
