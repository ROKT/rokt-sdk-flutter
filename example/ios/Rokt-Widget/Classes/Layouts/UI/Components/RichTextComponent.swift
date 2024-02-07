//
//  TextComponent.swift
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
struct RichTextComponent: View {
    @SwiftUI.Environment(\.colorScheme) var colorScheme

    var style: RichTextStyle? {
        model.defaultStyle
    }

    var dimensionStyle: DimensionStylingProperties? { style?.dimension }
    var flexStyle: FlexChildStylingProperties? { style?.flexChild }
    var spacingStyle: SpacingStylingProperties? { style?.spacing }
    var backgroundStyle: BackgroundStylingProperties? { style?.background }
    var linkStyle: InlineTextStylingProperties? { model.linkStyle?.text }

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
    @ObservedObject var model: RichTextUIModel
    let baseDI: BaseDependencyInjection

    @Binding var parentWidth: CGFloat?
    @Binding var parentHeight: CGFloat?

    let parentVerticalAlignment: VerticalAlignment?
    let parentHorizontalAlignment: HorizontalAlignment?

    // for indicator styling
    let borderStyle: BorderStylingProperties?

    @State private var hasValidated = false
    
    @Binding var currentIndex: Int
    var totalOffers: Int
    var stateReplacedValue: String {
        TextComponentBNFHelper.replaceStates(model.boundValue,
                                             currentOffer: "\(currentIndex + 1)",
                                             totalOffers: "\(totalOffers)")
    }

    var textView: Text {
        if model.attributedString.description.contains("%^") || model.attributedString.description.contains("^%") {
            return Text(stateReplacedValue)
        } else if model.attributedString.description.isEmpty {
            return Text(stateReplacedValue)
        } else {
            return Text(model.attributedString)
        }
    }

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

    init(
        parent: ComponentParent,
        model: RichTextUIModel,
        baseDI: BaseDependencyInjection,
        parentWidth: Binding<CGFloat?>,
        parentHeight: Binding<CGFloat?>,
        parentVerticalAlignment: VerticalAlignment?,
        parentHorizontalAlignment: HorizontalAlignment?,
        borderStyle: BorderStylingProperties?
    ) {
        self.parent = parent
        self.model = model
        self.baseDI = baseDI

        _parentWidth = parentWidth
        _parentHeight = parentHeight

        self.parentVerticalAlignment = parentVerticalAlignment
        self.parentHorizontalAlignment = parentHorizontalAlignment
        self.borderStyle = borderStyle

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
                    border: borderStyle ?? nil,
                    background: backgroundStyle,
                    parent: parent,
                    parentWidth: $parentWidth,
                    parentHeight: $parentHeight,
                    parentVerticalAlignment: parentVerticalAlignment,
                    parentHorizontalAlignment: parentHorizontalAlignment,
                    defaultHeight: .wrapContent,
                    defaultWidth: .wrapContent
                )
                .onAppear {
                    if model.attributedString.description.isEmpty == true {
                        baseDI.eventProcessor.sendHTMLParseErrorEvent(html: stateReplacedValue)
                    }
                }
        }
    }

    func build() -> some View {
        return textView
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
            .tint(Color(hex: style?.text?.textColor?.adaptiveColor))
            .environment(\.openURL, OpenURLAction(handler: handleURL))
    }

    func handleURL(_ url: URL) -> OpenURLAction.Result {
        LinkHandler.staticLinkHandler(url: url,
                                      open: model.openLinks ?? .internally,
                                      sessionId: baseDI.eventProcessor.sessionId)
        return .handled
    }
}
