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
            return model.hoveredStyle?.count ?? -1 > breakpointIndex ? model.hoveredStyle?[breakpointIndex] : nil
        case .pressed :
            return model.pressedStyle?.count ?? -1 > breakpointIndex ? model.pressedStyle?[breakpointIndex] : nil
        case .disabled :
            return model.disabledStyle?.count ?? -1 > breakpointIndex ? model.disabledStyle?[breakpointIndex] : nil
        default:
            return model.defaultStyle?.count ?? -1 > breakpointIndex ? model.defaultStyle?[breakpointIndex] : nil
        }
    }

    @EnvironmentObject var globalScreenSize: GlobalScreenSize
    @State var breakpointIndex = 0

    var dimensionStyle: DimensionStylingProperties? { style?.dimension }
    var flexStyle: FlexChildStylingProperties? { style?.flexChild }
    var borderStyle: BorderStylingProperties? { style?.border }
    var spacingStyle: SpacingStylingProperties? { style?.spacing }
    var backgroundStyle: BackgroundStylingProperties? { style?.background }
    
    let config: ComponentConfig
    let model: StaticImageUIModel
    let baseDI: BaseDependencyInjection
    
    @Binding var parentWidth: CGFloat?
    @Binding var parentHeight: CGFloat?
    @Binding var styleState: StyleState

    @State private var isImageValid = true
    
    let parentOverride: ComponentParentOverride?
    let expandsToContainerOnSelfAlign: Bool

    var verticalAlignment: VerticalAlignmentProperty {
        parentOverride?.parentVerticalAlignment?.asVerticalAlignmentProperty ?? .center
    }

    var horizontalAlignment: HorizontalAlignmentProperty {
        parentOverride?.parentHorizontalAlignment?.asHorizontalAlignmentProperty ?? .center
    }
    
    var body: some View {
        if isImageValid && hasUrlForColorScheme() {
            build()
                .applyLayoutModifier(
                    verticalAlignmentProperty: verticalAlignment,
                    horizontalAlignmentProperty: horizontalAlignment,
                    spacing: spacingStyle,
                    dimension: dimensionStyle,
                    flex: flexStyle,
                    border: borderStyle,
                    background: backgroundStyle,
                    parent: config.parent,
                    parentWidth: $parentWidth,
                    parentHeight: $parentHeight,
                    parentOverride: parentOverride,
                    defaultHeight: .wrapContent,
                    defaultWidth: .wrapContent,
                    expandsToContainerOnSelfAlign: expandsToContainerOnSelfAlign
                )
                .onChange(of: globalScreenSize.width) { newSize in
                    // run it in background thread for smooth transition
                    DispatchQueue.background.async {
                        // update breakpoint index
                        let index = min(baseDI.sharedData.getGlobalBreakpointIndex(newSize),
                                        (model.defaultStyle?.count ?? 1) - 1)
                        breakpointIndex = index >= 0 ? index : 0
                    }
                }
        } else {
            EmptyView()
        }
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
        return ThemeUrl(light: url.light, dark: url.dark ?? url.light)
    }
    
    func hasUrlForColorScheme() -> Bool {
        return (model.url?.light.isEmpty == false && colorScheme == .light)
        || ((model.url?.dark?.isEmpty == false || (model.url?.dark == nil && model.url?.light.isEmpty == false)) && colorScheme == .dark)
    }
}

@available(iOS 15, *)
struct AsyncImageView: View {
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    
    let imageUrl: ThemeUrl?
    let scale: BackgroundImageScale?
    var alt: String? = nil
    
    private var altString: String {
        alt ?? ""
    }

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
               let base64Image = UIImage(data: base64Data) {
                switch scale {
                case .crop: // no changes for crop, not resizing and scaling
                    Image(uiImage: base64Image)
                        .accessibilityLabel(altString)
                default:
                    Image(uiImage: base64Image)
                        .resizable()
                        .aspectRatio(contentMode: scale?.getScale() ?? .fit)
                        .accessibilityLabel(altString)
                }
            } else {
                AsyncImage(url: URL(string: imgURL)) { phase in
                    if let image = phase.image {  // valid
                        switch scale {
                        case .crop: // no changes for crop, not resizing and scaling
                            image
                        default: // fit as default
                            image
                                .resizable()
                                .aspectRatio(contentMode: scale?.getScale() ?? .fit)
                        }
                        
                    } else if phase.error != nil {  // error
                        let _ = setImageAsInvalid()
                        EmptyView()
                    } else {  // placeholder
                        EmptyView()
                    }
                }
                .accessibilityLabel(altString)
                .accessibilityHidden(altString.isEmpty)
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
