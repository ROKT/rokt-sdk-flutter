//
//  DataImageComponent.swift
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
struct DataImageViewComponent: View {
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    
    private var style: DataImageStyles? {
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
    let model: DataImageUIModel
    
    @Binding var parentWidth: CGFloat?
    @Binding var parentHeight: CGFloat?
    @Binding var styleState: StyleState

    @State private var isImageValid = true
    
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
        if !isImageValid {
            EmptyView()
        } else if let image = model.image?.light, !image.isEmpty {
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
    }
    
    func build() -> some View {
        AsyncImageView(imageUrl: ThemeUrl(light: model.image?.light ?? "",
                                          dark: model.image?.dark),
                       scale: .fit,
                       alt: model.image?.alt,
                       isImageValid: $isImageValid)
    }
}
