//
//  BasicTextComponent.swift
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
struct BasicTextComponent: View {
    @SwiftUI.Environment(\.colorScheme) var colorScheme

    var style: BasicTextStyle? { model.currentStylingProperties }
    var dimensionStyle: DimensionStylingProperties? { style?.dimension }
    var flexStyle: FlexChildStylingProperties? { style?.flexChild }
    var spacingStyle: SpacingStylingProperties? { style?.spacing }
    var backgroundStyle: BackgroundStylingProperties? { style?.background }
    
    var lineLimit: Int? {
        guard let lineLimit = style?.text?.lineLimit else { return nil }
        return Int(lineLimit)
    }
    var lineHeight: CGFloat {
        guard let lineHeight = style?.text?.lineHeight,
              let fontLineHeight = style?.text?.styledUIFont?.lineHeight
        else {
            return 0
        }
        return CGFloat(lineHeight) - fontLineHeight
    }
    
    var lineHeightPadding: CGFloat {
        guard let lineHeight = style?.text?.lineHeight,
              let fontLineHeight = style?.text?.styledUIFont?.lineHeight,
              CGFloat(lineHeight) > fontLineHeight
        else {
            return 0
        }
        return (CGFloat(lineHeight) - fontLineHeight)/2
    }

    let parent: ComponentParent
    @ObservedObject var model: BasicTextUIModel
    let baseDI: BaseDependencyInjection

    @Binding var parentWidth: CGFloat?
    @Binding var parentHeight: CGFloat?

    @Binding var styleState: StyleState
    
    @Binding var currentIndex: Int
    var totalOffers: Int
    var stateReplacedValue: String {
        TextComponentBNFHelper.replaceStates(model.boundValue,
                                          currentOffer: "\(currentIndex + 1)",
                                          totalOffers: "\(totalOffers)")
    }

    let parentVerticalAlignment: VerticalAlignment?
    let parentHorizontalAlignment: HorizontalAlignment?

    let expandsToContainerOnSelfAlign: Bool

    var verticalAlignment: VerticalAlignmentProperty {
        parentVerticalAlignment?.asVerticalAlignmentProperty ?? .top
    }

    var horizontalAlignment: HorizontalAlignmentProperty {
        if let textAlign = style?.text?.horizontalTextAlign?.asHorizontalAlignmentProperty {
            return textAlign
        } else if let parentAlign = parentHorizontalAlignment?.asHorizontalAlignmentProperty {
            return parentAlign
        } else {
            return .start
        }
    }

    var horizontalAlignmentOverride: HorizontalAlignment? {
        style?.text?.horizontalTextAlign?.asAlignment.horizontal
    }
    
    init(
        parent: ComponentParent,
        model: BasicTextUIModel,
        baseDI: BaseDependencyInjection,
        parentWidth: Binding<CGFloat?>,
        parentHeight: Binding<CGFloat?>,
        styleState: Binding<StyleState>,
        parentVerticalAlignment: VerticalAlignment?,
        parentHorizontalAlignment: HorizontalAlignment?,
        expandsToContainerOnSelfAlign: Bool
    ) {
        self.parent = parent
        self.model = model
        self.baseDI = baseDI

        _parentWidth = parentWidth
        _parentHeight = parentHeight
        _styleState = styleState

        self.parentVerticalAlignment = parentVerticalAlignment
        self.parentHorizontalAlignment = parentHorizontalAlignment
        self.expandsToContainerOnSelfAlign = expandsToContainerOnSelfAlign

        _currentIndex = baseDI.sharedData.items[SharedData.currentOfferIndexKey] as? Binding<Int> ?? .constant(0)
        totalOffers = baseDI.sharedData.items[SharedData.totalItemsKey] as? Int ?? 1
    }

    var body: some View {
        if !stateReplacedValue.isEmpty {
            build()
                .applyLayoutModifier(
                    verticalAlignmentProperty: verticalAlignment,
                    horizontalAlignmentProperty: horizontalAlignment,
                    spacing: spacingStyle,
                    dimension: dimensionStyle,
                    flex: flexStyle,
                    border: nil,
                    background: backgroundStyle,
                    parent: parent,
                    parentWidth: $parentWidth,
                    parentHeight: $parentHeight,
                    parentVerticalAlignment: parentVerticalAlignment,
                    parentHorizontalAlignment: parentHorizontalAlignment,
                    horizontalAlignmentOverride: horizontalAlignmentOverride,
                    defaultHeight: .wrapContent,
                    defaultWidth: .wrapContent,
                    expandsToContainerOnSelfAlign: expandsToContainerOnSelfAlign
                )
                .onChange(of: styleState) { styleState in
                    model.styleState = styleState
                }
        }
    }

    func build() -> some View {
        Text(stateReplacedValue)
            .baselineOffset(style?.text?.baselineOffset ?? 0)
            .underline(style?.text?.textDecoration == .underline)
            .strikethrough(style?.text?.textDecoration == .strikeThrough)
            .tracking(CGFloat(style?.text?.letterSpacing ?? 0))
            .lineSpacing(lineHeight)
            .padding(.vertical, lineHeightPadding)
            .multilineTextAlignment(style?.text?.horizontalTextAlign?.asTextAlignment ?? .leading)
            .lineLimit(lineLimit)
            // fixedSize required for consistent lineLimit behaviour
            .fixedSize(horizontal: false, vertical: true)
            .font(style?.text?.styledFont)
            .foregroundColor(hex: style?.text?.textColor?.adaptiveColor)
    }
}
