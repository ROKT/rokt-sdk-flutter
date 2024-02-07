//
//  ImageViewComponent.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import SwiftUI
import Combine

@available(iOS 15, *)
struct StaticImageViewComponent: View {
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    
    private var style: StaticImageStyles? {
        switch styleState {
        case .hovered :
            return model.hoveredStyle
        case .pressed :
            return model.pressedStyle
        case .disabled :
            return model.disabledStyle
        default:
            return model.defaultStyle
        }
    }

    var dimensionStyle: DimensionStylingProperties? { style?.dimension }
    var flexStyle: FlexChildStylingProperties? { style?.flexChild }
    var borderStyle: BorderStylingProperties? { style?.border }
    var spacingStyle: SpacingStylingProperties? { style?.spacing }
    var backgroundStyle: BackgroundStylingProperties? { style?.background }
    
    let parent: ComponentParent
    let model: StaticImageUIModel
    
    @Binding var parentWidth: CGFloat?
    @Binding var parentHeight: CGFloat?
    @Binding var styleState: StyleState

    @State private var isImageValid = false

    let parentVerticalAlignment: VerticalAlignment?
    let parentHorizontalAlignment: HorizontalAlignment?

    let expandsToContainerOnSelfAlign: Bool

    var verticalAlignment: VerticalAlignmentProperty {
        parentVerticalAlignment?.asVerticalAlignmentProperty ?? .center
    }

    var horizontalAlignment: HorizontalAlignmentProperty {
        parentHorizontalAlignment?.asHorizontalAlignmentProperty ?? .center
    }
    
    var body: some View {
        build()
            .applyLayoutModifier(
                verticalAlignmentProperty: verticalAlignment,
                horizontalAlignmentProperty: horizontalAlignment,
                spacing: spacingStyle,
                dimension: dimensionStyle,
                flex: flexStyle,
                border: borderStyle,
                background: backgroundStyle,
                parent: parent,
                parentWidth: $parentWidth,
                parentHeight: $parentHeight,
                parentVerticalAlignment: parentVerticalAlignment,
                parentHorizontalAlignment: parentHorizontalAlignment,
                defaultHeight: .wrapContent,
                defaultWidth: .wrapContent,
                expandsToContainerOnSelfAlign: expandsToContainerOnSelfAlign
            )
    }

    func build() -> some View {
        AsyncImageView(
            imageUrl: toThemeUrl(model.url),
            scale: .fit,
            alt: model.alt,
            isImageValid: $isImageValid
        )
    }
    
    func toThemeUrl(_ url: StaticImageUrl?) -> ThemeUrl? {
        guard let url else { return nil}
        return ThemeUrl(light: url.light, dark: url.dark)
    }
}

@available(iOS 15, *)
struct AsyncImageView: View {
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    
    let imageUrl: ThemeUrl?
    let scale: ContentMode?
    var alt: String? = nil

    private var imgURL: String {
        var iURL = ""

        switch colorScheme {
        case .light:
            iURL = imageUrl?.light ?? ""
        default:
            iURL = imageUrl?.dark ?? ""
        }

        return iURL
    }

    var stringBase64: String {
        // we will remove the data URI scheme, data:content/type;base64,
        guard let dataImagePrefix = imgURL.range(of: "data:image/"),
              let base64Suffix = imgURL.range(of: ";base64,")
        else { return imgURL }

        let uriSchemeRange = dataImagePrefix.lowerBound..<base64Suffix.upperBound
        let uriScheme = imgURL[uriSchemeRange]

        return imgURL.replacingOccurrences(of: uriScheme, with: "")
    }

    var isURLBase64Image: Bool {
        imgURL.contains("data:image/") && imgURL.contains(";base64")
    }

    @Binding var isImageValid: Bool

    var body: some View {
        if imageUrl != nil {
            if isURLBase64Image,
               let base64Data = Data(base64Encoded: stringBase64),
               let base64Image = UIImage(data: base64Data)
            {
                Image(uiImage: base64Image)
                    .resizable()
                    .aspectRatio(contentMode: scale ?? .fit)  // ensure static images do not expand out of bounds
                    .accessibilityLabel(alt ?? "")
            } else {
                AsyncImage(url: URL(string: imgURL)) { phase in
                    if let image = phase.image {  // valid
                        image
                            .resizable()
                    } else if phase.error != nil {  // error
                        let _ = setImageAsInvalid()
                        EmptyView()
                    } else {  // placeholder
                        EmptyView()
                    }
                }
                .aspectRatio(contentMode: scale ?? .fit)
                .accessibilityLabel(alt ?? "")
            }
        } else {
            EmptyView()
        }
    }

    func setImageAsInvalid() {
        DispatchQueue.main.async {
            isImageValid = false
        }
    }
}
