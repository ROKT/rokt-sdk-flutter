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
    @SwiftUI.Environment(\.sizeCategory) var sizeCategory

    var style: RichTextStyle? {
        model.defaultStyle?.count ?? -1 > breakpointIndex ? model.defaultStyle?[breakpointIndex] : nil
    }

    var dimensionStyle: DimensionStylingProperties? { style?.dimension }
    var flexStyle: FlexChildStylingProperties? { style?.flexChild }
    var spacingStyle: SpacingStylingProperties? { style?.spacing }
    var backgroundStyle: BackgroundStylingProperties? { style?.background }
    var linkStyle: InlineTextStylingProperties? {
        model.linkStyle?.count ?? -1 > breakpointLinkIndex ? model.linkStyle?[breakpointLinkIndex].text : nil
    }
    
    @EnvironmentObject var globalScreenSize: GlobalScreenSize
    @State var breakpointIndex: Int = 0
    @State var breakpointLinkIndex: Int = 0
    
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

    let config: ComponentConfig
    @ObservedObject var model: RichTextUIModel
    let baseDI: BaseDependencyInjection

    @Binding var parentWidth: CGFloat?
    @Binding var parentHeight: CGFloat?

    let parentOverride: ComponentParentOverride?

    // for indicator styling
    let borderStyle: BorderStylingProperties?

    @State private var hasValidated = false
    
    @Binding var currentIndex: Int
    @Binding var viewableItems: Int

    var totalOffers: Int
    var totalPages: Int {
        return Int(ceil(Double(totalOffers)/Double(viewableItems)))
    }
    var stateReplacedAttributedString: NSAttributedString {
        let text = model.attributedString.description.isEmpty ? NSAttributedString(string: model.boundValue) : model.attributedString
        
        let replacedText = TextComponentBNFHelper.replaceStates(text,
                                                                currentOffer: "\(currentIndex + 1)",
                                                                totalOffers: "\(totalPages)")
        return replacedText
    }
    
    var stateReplacedText: String {
        TextComponentBNFHelper.replaceStates(model.boundValue,
                                             currentOffer: "\(currentIndex + 1)",
                                             totalOffers: "\(totalPages)")
    }

    var textView: Text {
        if model.attributedString.description.contains(BNFSeparator.startDelimiter.rawValue) || model.attributedString.description.contains(BNFSeparator.endDelimiter.rawValue) {
            return Text(AttributedString(stateReplacedAttributedString))
        } else if model.attributedString.description.isEmpty {
            return Text(stateReplacedText)
        } else {
            return Text(AttributedString(model.attributedString))
        }
    }

    var verticalAlignment: VerticalAlignmentProperty {
        parentOverride?.parentVerticalAlignment?.asVerticalAlignmentProperty ?? .top
    }

    var horizontalAlignment: HorizontalAlignmentProperty {
        if let textAlign = style?.text?.horizontalTextAlign?.asHorizontalAlignmentProperty {
            return textAlign
        } else if let parentAlign = parentOverride?.parentHorizontalAlignment?.asHorizontalAlignmentProperty {
            return parentAlign
        } else {
            return .start
        }
    }

    init(
        config: ComponentConfig,
        model: RichTextUIModel,
        baseDI: BaseDependencyInjection,
        parentWidth: Binding<CGFloat?>,
        parentHeight: Binding<CGFloat?>,
        parentOverride: ComponentParentOverride?,
        borderStyle: BorderStylingProperties?
    ) {
        self.config = config
        self.model = model
        self.baseDI = baseDI

        _parentWidth = parentWidth
        _parentHeight = parentHeight

        self.parentOverride = parentOverride
        self.borderStyle = borderStyle

        _currentIndex = baseDI.sharedData.items[SharedData.currentProgressKey] as? Binding<Int> ?? .constant(0)
        totalOffers = baseDI.sharedData.items[SharedData.totalItemsKey] as? Int ?? 1
        _viewableItems = baseDI.sharedData.items[SharedData.viewableItemsKey] as? Binding<Int> ?? .constant(1)
    }

    var body: some View {
        if !stateReplacedText.isEmpty {
            build()
                .applyLayoutModifier(
                    verticalAlignmentProperty: verticalAlignment,
                    horizontalAlignmentProperty: horizontalAlignment,
                    spacing: spacingStyle,
                    dimension: dimensionStyle,
                    flex: flexStyle,
                    border: borderStyle ?? nil,
                    background: backgroundStyle,
                    parent: config.parent,
                    parentWidth: $parentWidth,
                    parentHeight: $parentHeight,
                    parentOverride: parentOverride,
                    defaultHeight: .wrapContent,
                    defaultWidth: .wrapContent
                )
                .onChange(of: globalScreenSize.width) { newSize in
                    // run it in background thread for smooth transition
                    DispatchQueue.background.async {
                        // update breakpoint index for default style
                        let index = min(baseDI.sharedData.getGlobalBreakpointIndex(newSize),
                                        (model.defaultStyle?.count ?? 1) - 1)
                        breakpointIndex = index >= 0 ? index : 0
                        
                        // update breakpoint index for link style
                        let linkIndex = min(baseDI.sharedData.getGlobalBreakpointIndex(newSize),
                                        (model.linkStyle?.count ?? 1) - 1)
                        breakpointLinkIndex = linkIndex >= 0 ? linkIndex : 0
                        
                        DispatchQueue.main.async {
                            model.breakpointIndex = breakpointIndex
                            model.breakpointLinkIndex = breakpointLinkIndex
                            model.updateAttributedString(colorScheme)
                        }
                    }
                }
                .onChange(of: colorScheme) { newSchema in
                    DispatchQueue.main.async {
                        model.updateAttributedString(newSchema)
                    }
                }
                .onChange(of: sizeCategory) { _ in
                    DispatchQueue.main.async {
                        model.updateAttributedString(colorScheme)
                    }
                }
                .onAppear {
                    if model.attributedString.description.isEmpty && stateReplacedAttributedString.description.isEmpty {
                        baseDI.eventProcessor.sendHTMLParseErrorEvent(html: stateReplacedAttributedString.description)
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
            .scaledFont(textStyle: style?.text)
            .tint(Color(hex: style?.text?.textColor?.getAdaptiveColor(colorScheme)))
            .environment(\.openURL, OpenURLAction(handler: handleURL))
    }

    func handleURL(_ url: URL) -> OpenURLAction.Result {
        LinkHandler.shared.staticLinkHandler(url: url,
                                      open: model.openLinks ?? .internally,
                                      sessionId: baseDI.eventProcessor.sessionId)
        return .handled
    }
}
