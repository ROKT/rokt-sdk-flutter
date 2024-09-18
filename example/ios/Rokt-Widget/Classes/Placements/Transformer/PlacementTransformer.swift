//
//  PlacementTransformer.swift
//  Pods
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

enum TransformerError: Error, Equatable {
    case KeyIsMissing(key: String)
    case ValueIsNil(key: String)
    case TypeMissMatch(key: String)
    case NotSupported(key: String)
    case ComponentIsMissing(key: String)
}

enum CustomFontWeight: String {
    case normal
    case thin
    case ultraLight = "ultralight"
    case light
    case medium
    case semiBold = "semibold"
    case bold
    case extraBold = "extrabold"
    case black

    var asUIFontWeight: UIFont.Weight {
        switch self {
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        case .light: return .light
        case .normal: return .regular
        case .medium: return .medium
        case .semiBold: return .semibold
        case .bold: return .bold
        case .extraBold: return .heavy
        case .black: return .black
        }
    }
}

class PlacementTransformer {
    let placement: Placement
    let pageInstanceGuid: String
    let startDate: Date
    let responseReceivedDate: Date

    internal let placementConfigurableText = "Placement Configurable"
    private let position1 = "Position1"
    private let position2Plus = "Position2+"
    private let circleWithText = "circleWithText"
    private let showEndMessage = "ShowEndMessage"
    private let signalTypeText = "SignalType"
    private let defaultPageIndicatorStart = 1
    private let defaultPageIndicatorDashesWidth: Float = 32
    private let defaultPageIndicatorDashesHeight: Float = 4
    private let responseOrderPositiveFirst = "positiveFirst"
    private let buttonDisplayStacked = "Stacked"
    private let validOfferLayouts = ["MobileSdkOfferLayout1"]
    private let hidden = "Hidden"
    private let visible = "Visible"

    init(placement: Placement, pageInstanceGuid: String, startDate: Date, responseReceivedDate: Date) {
        self.placement = placement
        self.pageInstanceGuid = pageInstanceGuid
        self.startDate = startDate
        self.responseReceivedDate = responseReceivedDate
    }

    // MARK: Transformers
    internal func transformPlacement() throws -> PlacementViewData {
        do {
            switch placement.placementLayoutCode {
            case .lightboxLayout, .overlayLayout, .bottomSheetLayout:
                return try getLightBoxPlacement()
            case .embeddedLayout:
                return try getEmbeddedPlacement()
            default:
                throw TransformerError.NotSupported(
                    key: kPlacementLayoutCode + (placement.placementLayoutCode?.rawValue ?? ""))
            }
        }
    }

    private func getLightBoxPlacement() throws -> LightBoxViewData {
        let negativeButtonVisibilityAndStyle = try getNegativeButtonVisibilityAndStyle()
        let navigateButtonVisibilityAndStyle = try getNavigateButtonVisibilityAndStyle()

        return LightBoxViewData(instanceGuid: placement.instanceGuid,
                                pageInstanceGuid: pageInstanceGuid,
                                launchDelayMilliseconds: try getOptionalInt(MobilePlacementLaunchDelayMilliseconds),
                                placementLayoutCode: placement.placementLayoutCode,
                                offerLayoutCode: try transformOfferLayout(),
                                backgroundColor: try getColorMap(MobilePlacementBackgroundColorLight,
                                                                 keyDark: MobilePlacementBackgroundColorDark),
                                offers: try transformOffers(),
                                titleDivider: try transformTitleDivider(),
                                footerViewData: try transformFooter(),
                                backgroundWithoutFooterViewData: try transformBackgroundWithoutFooter(),
                                positiveButton: try transformPositiveButtonStyles(),
                                negativeButton: negativeButtonVisibilityAndStyle.1,
                                navigateToButtonData: try getNavigateButtonData(),
                                navigateToButtonStyles: navigateButtonVisibilityAndStyle.1,
                                navigateToDivider: try transformNavigateButtonDivider(),
                                positiveButtonFirst: try transformResponseOrder(),
                                buttonsStacked: try transformButtobStacked(),
                                title: try transformTitleView(),
                                margin: try getFrameAlignment(MobilePlacementMargin),
                                startDate: startDate,
                                responseReceivedDate: responseReceivedDate,
                                urlInExternalBrowser:
                                    try getOptionalBool(MobilePlacementStaticLinkActionDefaultMobileBrowser) ?? false,
                                lightboxBackground: try getOptionalColorMap(
                                    MobilePlacementLightBoxBackgroundColorLight,
                                    keyDark: MobilePlacementLightBoxBackgroundColorDark),
                                cornerRadius: try getOptionalFloat(MobilePlacementCornerRadius),
                                borderThickness: try getOptionalFloat(MobilePlacementBorderThickness),
                                borderColor: try getOptionalColorMap(
                                    MobilePlacementBorderColorLight,
                                    keyDark: MobilePlacementBorderColorDark),
                                bottomSheetExpandable:
                                    try getOptionalBool(MobilePlacementBottomSheetExpandable) ?? false,
                                bottomSheetDismissible:
                                    try getOptionalBool(MobilePlacementBottomSheetDismissible) ?? false,
                                isNegativeButtonVisible: negativeButtonVisibilityAndStyle.0,
                                isNavigateButtonVisible: navigateButtonVisibilityAndStyle.0,
                                canLoadNextOffer: try getOptionalBool(MobilePlacementCanLoadNextOffer) ?? true,
                                isNavigateToButtonCloseOnTap:
                                    try getOptionalBool(MobilePlacementNavigateButtonShouldCloseOnPress) ?? true,
                                titlePosition: getTitlePosition(key: MobilePlacementTitlePosition),
                                titleMargin:
                                    try getOptionalFrameAlignment(MobilePlacementTitleMargin) ??
                                    FrameAlignment(top: 8, right: 10, bottom: 8, left: 16),
                                placementsJWTToken: placement.placementsJWTToken,
                                placementId: placement.id)
    }

    private func getEmbeddedPlacement() throws -> EmbeddedViewData {
        let negativeButtonVisibilityAndStyle = try getNegativeButtonVisibilityAndStyle()

        return EmbeddedViewData(instanceGuid: placement.instanceGuid,
                                pageInstanceGuid: pageInstanceGuid,
                                launchDelayMilliseconds: try getOptionalInt(MobilePlacementLaunchDelayMilliseconds),
                                placementLayoutCode: placement.placementLayoutCode,
                                offerLayoutCode: try transformOfferLayout(),
                                backgroundColor: try getColorMap(
                                    MobilePlacementBackgroundColorLight,
                                    keyDark: MobilePlacementBackgroundColorDark),
                                offers: try transformOffers(),
                                footerViewData: try transformFooter(),
                                backgroundWithoutFooterViewData: try transformBackgroundWithoutFooter(),
                                positiveButton: try transformPositiveButtonStyles(),
                                negativeButton: negativeButtonVisibilityAndStyle.1,
                                navigateToButtonData: nil,
                                navigateToButtonStyles: nil,
                                navigateToDivider: nil,
                                positiveButtonFirst: try transformResponseOrder(),
                                buttonsStacked: try transformButtobStacked(),
                                targetElement: placement.targetElementSelector,
                                endMessageViewData:
                                    try getOptionalString(MobilePlacementEndOfJourneyBehavior) == showEndMessage ?
                                    try transformEndMessage(): nil,
                                padding: try getFrameAlignment(MobilePlacementPadding),
                                margin: try getFrameAlignment(MobilePlacementMargin),
                                startDate: startDate,
                                responseReceivedDate: responseReceivedDate,
                                urlInExternalBrowser:
                                    try getOptionalBool(MobilePlacementStaticLinkActionDefaultMobileBrowser) ?? false,
                                cornerRadius: try getOptionalFloat(MobilePlacementCornerRadius),
                                borderThickness: try getOptionalFloat(MobilePlacementBorderThickness),
                                borderColor: try getOptionalColorMap(
                                    MobilePlacementBorderColorLight,
                                    keyDark: MobilePlacementBorderColorDark),
                                isNegativeButtonVisible: negativeButtonVisibilityAndStyle.0,
                                isNavigateButtonVisible: false,
                                canLoadNextOffer: try getOptionalBool(MobilePlacementCanLoadNextOffer) ?? true,
                                isNavigateToButtonCloseOnTap:
                                    try getOptionalBool(MobilePlacementNavigateButtonShouldCloseOnPress) ?? true,
                                placementsJWTToken: placement.placementsJWTToken,
                                placementId: placement.id)
    }

    // MARK: transform title
    internal func transformTitleView() throws -> TitleViewData {
        return TitleViewData(textViewData:
                                TextViewData(text: try getString(MobilePlacementTitleContent),
                                             textStyleViewData: try getTextStyle(
                                                keyFontFamily: MobilePlacementTitleFontFamily,
                                                keyFontWeight: MobilePlacementTitleFontWeight,
                                                keySize: MobilePlacementTitleFontSize,
                                                keyColorLight: MobilePlacementTitleFontColorLight,
                                                keyColorDark: MobilePlacementTitleFontColorDark,
                                                keyAlignment: MobilePlacementTitleAlignment,
                                                keyLineSpacing: MobilePlacementTitleLineSpacing,
                                                keyBackgroundColorLight: MobilePlacementTitleBackgroundColorLight,
                                                keyBackgroundColorDark: MobilePlacementTitleBackgroundColorDark,
                                                keyShouldWordWrap: MobilePlacementTitleShouldWordWrap)
                                ),
                             backgroundColor: try getColorMap(MobilePlacementTitleBackgroundColorLight,
                                                              keyDark: MobilePlacementTitleBackgroundColorDark),
                             closeButtonColor: try getColorMap(MobilePlacementTitleCloseButtonColorLight,
                                                               keyDark: MobilePlacementTitleCloseButtonColorDark),
                             closeButtonCircleColor: try getOptionalColorMap(
                                MobilePlacementTitleCloseButtonCircleColorLight,
                                keyDark: MobilePlacementTitleCloseButtonCircleColorDark),
                             closeButtonThinVariant:
                                try getOptionalBool(MobilePlacementTitleCloseButtonThinVariant) ?? false)
    }

    // MARK: transform offer layout
    internal func transformOfferLayout() throws -> String {
        if validOfferLayouts.contains(placement.offerLayoutCode) {
            return placement.offerLayoutCode
        }
        throw TransformerError.NotSupported(key: kOfferLayout + placement.offerLayoutCode)
    }
    // MARK: transform creative response order
    internal func transformResponseOrder() throws -> Bool {
        if let responseOrder = try getOptionalString(MobileCreativeResponseOrder),
           responseOrder != responseOrderPositiveFirst {
            return false
        }
        return true
    }
    // MARK: transform creative button Display
    internal func transformButtobStacked() throws -> Bool {
        if let isStacked = try getOptionalString(MobileCreativeButtonDisplay) {
            return isStacked == buttonDisplayStacked
        }
        return true
    }
    // MARK: transform end message
    internal func transformEndMessage() throws -> EndMessageViewData {
        let title = TextViewData(text: try  getString(MobilePlacementEndMessageTitleContent),
                                 textStyleViewData: try getTextStyle(
                                    keyFontFamily: MobilePlacementEndMessageTitleFontFamily,
                                    keyFontWeight: MobilePlacementEndMessageTitleFontWeight,
                                    keySize: MobilePlacementEndMessageTitleFontSize,
                                    keyColorLight: MobilePlacementEndMessageTitleFontColorLight,
                                    keyColorDark: MobilePlacementEndMessageTitleFontColorDark,
                                    keyAlignment: MobilePlacementEndMessageTitleAlignment,
                                    keyLineSpacing: MobilePlacementEndMessageTitleLineSpacing))
        let content = TextViewData(text: try  getString(MobilePlacementEndMessageBodyContent),
                                   textStyleViewData: try getTextStyle(
                                    keyFontFamily: MobilePlacementEndMessageBodyFontFamily,
                                    keyFontWeight: MobilePlacementEndMessageBodyFontWeight,
                                    keySize: MobilePlacementEndMessageBodyFontSize,
                                    keyColorLight: MobilePlacementEndMessageBodyFontColorLight,
                                    keyColorDark: MobilePlacementEndMessageBodyFontColorDark,
                                    keyAlignment: MobilePlacementEndMessageBodyAlignment,
                                    keyLineSpacing: MobilePlacementEndMessageBodyLineSpacing))
        return EndMessageViewData(title: title, content: content)
    }

    // MARK: transform offers
    internal func transformOffers() throws -> [OfferViewData] {
        var validIndex = 0
        if let slots = placement.slots {
            return try slots.map { slot in
                let offer = try transformOffer(slot: slot, validIndex: validIndex)
                if !offer.isGhostOffer() { validIndex += 1 }
                return offer
            }
        }
        return []
    }

    // MARK: - Negative Button Visibility and Style
    private func getNegativeButtonVisibilityAndStyle() throws -> (Bool, ButtonStylesViewData?) {
        let isNegativeButtonVisible = try getOptionalBool(MobileCreativeNegativeButtonShow) ?? true
        var negativeButtonStyles: ButtonStylesViewData? = try transformNegativeButtonStyles()

        if !isNegativeButtonVisible {
            negativeButtonStyles = nil
        }

        if isNegativeButtonVisible && negativeButtonStyles == nil {
            throw TransformerError.ComponentIsMissing(key: "NegativeButton")
        }

        return (isNegativeButtonVisible, negativeButtonStyles)
    }

    // MARK: - NavigateButton Data
    internal func getNavigateButtonData() throws -> PlacementButtonViewData? {
        if (try getOptionalBool(MobilePlacementNavigateButtonShow) ?? false) == false {
            return nil
        }
        let rawText = try getString(MobilePlacementNavigateButtonText)
        let styledText = try transformButtonText(text: rawText, key: MobilePlacementNavigateButtonTextCaseOption)
        let shouldCloseOnPress = try getOptionalBool(MobilePlacementNavigateButtonShouldCloseOnPress) ?? true

        return PlacementButtonViewData(
            text: styledText,
            closeOnPress: shouldCloseOnPress
        )
    }

    // MARK: - Navigate Button Visibility and Style
    internal func getNavigateButtonVisibilityAndStyle() throws -> (Bool, ButtonWithDimensionStylesViewData?) {
        let isNavigateButtonVisible = try getOptionalBool(MobilePlacementNavigateButtonShow) ?? false
        var navigateButtonStyles: ButtonWithDimensionStylesViewData? = transformNavigateButtonStyles()

        if isNavigateButtonVisible == false {
            navigateButtonStyles = nil
        }

        if isNavigateButtonVisible && navigateButtonStyles == nil {
            throw TransformerError.ComponentIsMissing(key: "NavigateButton")
        }

        return (isNavigateButtonVisible, navigateButtonStyles)
    }

    // MARK: transform Navigate button styles
    internal func transformNavigateButtonStyles() -> ButtonWithDimensionStylesViewData? {
        let defaultStyle =
            try? getButtonStyle(keyFontFamily: MobilePlacementNavigateButtonDefaultFontFamily,
                                keyFontWeight: MobilePlacementNavigateButtonDefaultFontWeight,
                                keySize: MobilePlacementNavigateButtonDefaultFontSize,
                                keyColorLight: MobilePlacementNavigateButtonDefaultFontColorLight,
                                keyColorDark: MobilePlacementNavigateButtonDefaultFontColorDark,
                                keyCornerRadius: MobilePlacementNavigateButtonDefaultCornerRadius,
                                keyBorderThickness: MobilePlacementNavigateButtonDefaultBorderThickness,
                                keyBorderColorLight: MobilePlacementNavigateButtonDefaultBorderColorLight,
                                keyBorderColorDark: MobilePlacementNavigateButtonDefaultBorderColorDark,
                                keyBackgroundColorLight: MobilePlacementNavigateButtonDefaultBackgroundColorLight,
                                keyBackgroundColorDark: MobilePlacementNavigateButtonDefaultBackgroundColorDark)
        let pressedStyle =
            try? getButtonStyle(keyFontFamily: MobilePlacementNavigateButtonPressedFontFamily,
                                keyFontWeight: MobilePlacementNavigateButtonPressedFontWeight,
                                keySize: MobilePlacementNavigateButtonPressedFontSize,
                                keyColorLight: MobilePlacementNavigateButtonPressedFontColorLight,
                                keyColorDark: MobilePlacementNavigateButtonPressedFontColorDark,
                                keyCornerRadius: MobilePlacementNavigateButtonPressedCornerRadius,
                                keyBorderThickness: MobilePlacementNavigateButtonPressedBorderThickness,
                                keyBorderColorLight: MobilePlacementNavigateButtonPressedBorderColorLight,
                                keyBorderColorDark: MobilePlacementNavigateButtonPressedBorderColorDark,
                                keyBackgroundColorLight: MobilePlacementNavigateButtonPressedBackgroundColorLight,
                                keyBackgroundColorDark: MobilePlacementNavigateButtonPressedBackgroundColorDark)

        // default
        var margin = FrameAlignment(top: 16, right: 0, bottom: 16, left: 0)
        if let explicitMargin = try? getOptionalFrameAlignment(MobilePlacementNavigateButtonMargin) {
            margin = explicitMargin
        }

        // default
        var minHeight = kButtonsHeight
        if let explicitHeight = try? getOptionalFloat(MobilePlacementNavigateButtonMinHeight) {
            minHeight = CGFloat(explicitHeight)
        }

        // pressed styles are ALWAYS required in the Placements context
        guard let defaultStyle, let pressedStyle else { return nil }

        return ButtonWithDimensionStylesViewData(
            defaultStyle: defaultStyle,
            pressedStyle: pressedStyle,
            margin: margin,
            minHeight: minHeight
        )
    }

    // MARK: - transform Navigate button Divider
    internal func transformTitleDivider() throws -> DividerViewDataWithDimensions {
        let dividerBackground = try getOptionalColorMap(
            MobilePlacementTitleDividerBackgroundColorLight,
            keyDark: MobilePlacementTitleDividerBackgroundColorDark
        )

        let dividerShow = try getOptionalBool(MobilePlacementTitleDividerShow) ?? false

        var dividerHeight = CGFloat(2)
        if let explicitHeight = try getOptionalFloat(MobilePlacementTitleDividerHeight) {
            dividerHeight = CGFloat(explicitHeight)
        }

        // default
        var margin = FrameAlignment(top: 16, right: 0, bottom: 16, left: 0)
        if let explicitMargin = try getOptionalFrameAlignment(MobilePlacementTitleDividerMargin) {
            margin = explicitMargin
        }

        return DividerViewDataWithDimensions(
            backgroundColor: dividerBackground,
            isVisible: dividerShow,
            height: dividerHeight,
            margin: margin
        )
    }

    internal func transformNavigateButtonDivider() throws -> DividerViewDataWithDimensions {
        let dividerBackground = try getOptionalColorMap(
            MobilePlacementNavigateButtonDividerBackgroundColorLight,
            keyDark: MobilePlacementNavigateButtonDividerBackgroundColorDark
        )

        let dividerShow = try getOptionalBool(MobilePlacementNavigateButtonDividerShow) ?? false

        var dividerHeight = CGFloat(2)
        if let explicitHeight = try getOptionalFloat(MobilePlacementNavigateButtonDividerHeight) {
            dividerHeight = CGFloat(explicitHeight)
        }

        // default
        var margin = FrameAlignment(top: 16, right: 0, bottom: 0, left: 0)
        if let explicitMargin = try getOptionalFrameAlignment(MobilePlacementNavigateButtonDividerMargin) {
            margin = explicitMargin
        }

        return DividerViewDataWithDimensions(
            backgroundColor: dividerBackground,
            isVisible: dividerShow,
            height: dividerHeight,
            margin: margin
        )
    }

    // MARK: transform offer
    internal func transformOffer(slot: Slot, validIndex: Int) throws -> OfferViewData {
        guard let offer = slot.offer else {
            return OfferViewData(
                instanceGuid: slot.instanceGuid,
                slotJWTToken: slot.slotJWTToken,
                creativeJWTToken: ""
            )
        }

        let totalValidOffer = getValidOfferCount()

        let image = ImageViewData(imageUrl: try transformCreativeImage(validIndex: validIndex,
                                                                       from: slot.offer?.creative.copy),
                                  imageHideOnDark: try getOptionalString(MobileCreativeImageVisibility) != visible,
                                  imageMaxHeight: try getOptionalFloat(MobileCreativeImageMaxHeight),
                                  imageMaxWidth: try getOptionalFloat(MobileCreativeImageMaxWidth),
                                  creativeTitleImageArrangment: try transferCreativeTitleImageArrangement(),
                                  creativeTitleImageAlignment: try transferCreativeTitleImageAlignment(),
                                  creativeTitleImageSpacing:
                                    try getOptionalFloat(MobileCreativeTitleWithImageSpacing) ?? 0)
        return OfferViewData(instanceGuid: slot.instanceGuid,
                             creativeInstanceGuid: slot.offer?.creative.instanceGuid,
                             positiveButtonLabel: try transferPositiveButton(offer: offer),
                             negativeButtonLabel: try transferNegativeButton(offer: offer),
                             content: try transformOfferContent(slot: slot),
                             image: image,
                             campaignId: offer.campaignId,
                             background: try getColorMap(MobileOfferBackgroundColorLight,
                                                         keyDark: MobileOfferBackgroundColorDark),
                             padding: try getFrameAlignment(MobileOfferPadding),
                             disclaimer: try transformDisclaimer(from: slot.offer?.creative.copy),
                             termsAndConditionsButton: try transformOfferTermsAndConditions(
                                from: slot.offer?.creative.copy),
                             privacyPolicyButton: try transformOfferPrivacyPolicy(from: slot.offer?.creative.copy),
                             beforeOfferViewData: try transformBeforeOffer(validIndex: validIndex),
                             confirmationMessage: try transformConfirmationMessage(validIndex: validIndex,
                                                                                   from: slot.offer?.creative.copy),
                             pageIndicator: try transformPageIndicator(validIndex: validIndex,
                                                                       totalValidOffers: totalValidOffer),
                             afterOfferViewData: try transformAfterOffer(validIndex: validIndex),
                             slotJWTToken: slot.slotJWTToken,
                             creativeJWTToken: slot.offer?.creative.creativeJWTToken ?? "")
    }

    internal func transformOfferContent(slot: Slot) throws -> OfferContentViewData {
        var contentBody, contentTitle, imageTitle: TextViewData?
        let titleText = try transferOfferTitleText(slot: slot)
        let contentTitleIsInline = try getOptionalBool(MobileCreativeInLineCopyWithHeading) ?? true

        if try transferCreativeTitleImageArrangement() != .bottom {
            // applies when title is inline with image (PayMar)
            contentBody = try transferOfferTextViewData(try transferOfferContentText(slot: slot, title: nil))
            imageTitle = try transferOfferTitleTextViewData(titleText: titleText)
        } else if contentTitleIsInline {
            // applies when title is inline with offer copy
            contentBody = try transferOfferTextViewData(try transferOfferContentText(slot: slot, title: titleText))
        } else {
            // applies when title is on its own separate line
            contentBody = try transferOfferTextViewData(try transferOfferContentText(slot: slot, title: nil))
            contentTitle = try transferOfferTitleTextViewData(titleText: titleText)
        }

        return OfferContentViewData(title: contentTitle,
                                    body: contentBody,
                                    imageTitle: imageTitle)
    }

    private func transferOfferTextViewData(_ text: String) throws -> TextViewData {
        return TextViewData(text: text,
                            textStyleViewData:
                                try getTextStyle(keyFontFamily: MobileCreativeFontFamily,
                                                 keyFontWeight: MobileCreativeFontWeight,
                                                 keySize: MobileCreativeFontSize,
                                                 keyColorLight: MobileCreativeFontColorLight,
                                                 keyColorDark: MobileCreativeFontColorDark,
                                                 keyAlignment: MobileCreativeAlignment,
                                                 keyLineSpacing: MobileCreativeLineSpacing))
    }

    // default the OfferTitleTextStyles with OfferTextStyle
    private func transferOfferTitleTextViewData(titleText: String?) throws -> TextViewData? {
        guard let titleText else {
            return nil
        }

        let fontFamily = try getOptionalString(MobileCreativeTitleFontFamily)
            ?? getString(MobileCreativeFontFamily)
        let fontWeight = getOptionalFontWeight(MobileCreativeTitleFontWeight)
            ?? getOptionalFontWeight(MobileCreativeFontWeight)
        let fontSize = try getOptionalFloat(MobileCreativeTitleFontSize) ?? getFloat(MobileCreativeFontSize)
        let fontColor = try getOptionalColorMap(MobileCreativeTitleFontColorLight,
                                                keyDark: MobileCreativeTitleFontColorDark)
            ?? getColorMap(MobileCreativeFontColorLight,
                           keyDark: MobileCreativeFontColorDark)
        let textAlignment = try getOptionalAlignment(MobileCreativeTitleAlignment)
            ?? getAlignment(MobileCreativeAlignment)
        let lineSpacing = try getOptionalFloat(MobileCreativeTitleLineSpacing)
            ?? (getOptionalFloat(MobileCreativeLineSpacing) ?? kDefaultLineSpacing )

        return TextViewData(text: titleText,
                            textStyleViewData: TextStyleViewData(fontFamily: fontFamily,
                                                                 fontWeight: fontWeight,
                                                                 fontSize: fontSize,
                                                                 fontColor: fontColor,
                                                                 backgroundColor: nil,
                                                                 alignment: textAlignment,
                                                                 lineSpacing: lineSpacing))
    }

    internal func transferOfferContentText(slot: Slot, title: String?) throws -> String {
        let content = try getString(MobileCreativeCopy, from: slot.offer?.creative.copy)
        if let title = title,
           try transferCreativeTitleImageArrangement() == .bottom {
            // if the CreativeTitleImageArrangement is not set or it is .bottom AND
            // CreativeInLineCopyWithHeading is not set or it is true, the title will be
            // attached to the content. Otherwise the title will be handeled in separate node

            return title + " " + content
        }
        return content
    }

    internal func transferOfferTitleText(slot: Slot) throws -> String? {
        guard let title = try getOptionalString(MobileCreativeTitle, from: slot.offer?.creative.copy)
        else { return nil }

        return title
    }

    // MARK: CreativeTitleImage Arrangement and Alignment
    internal func transferCreativeTitleImageArrangement() throws -> CreativeTitleImageArrangement {

        guard let arrangment = CreativeTitleImageArrangement(
                rawValue:
                    try getOptionalString(MobileCreativeTitleWithImageArrangement) ?? "") else {
            return .bottom
        }
        return arrangment
    }

    internal func transferCreativeTitleImageAlignment() throws -> CreativeTitleImageAlignment {

        guard let alignment = CreativeTitleImageAlignment(
                rawValue: try getOptionalString(MobileCreativeTitleWithImageAlignment) ?? "") else {
            return .center
        }
        return alignment
    }

    // MARK: offer buttons
    internal func transferPositiveButton(offer: Offer) throws -> ButtonViewData {
        guard let responseOption = offer.creative.responseOptions?.first(where: { $0.isPositive == true }) else {
            throw TransformerError.KeyIsMissing(key: kPositiveButton)
        }

        if responseOption.action == nil {
            throw TransformerError.KeyIsMissing(key: kResponseOptionAction)
        }

        if responseOption.action == .unknown {
            throw TransformerError.NotSupported(key: kResponseOptionAction)
        }
        let text = try transformButtonText(text: responseOption.shortLabel ?? "",
                                           key: MobileCreativePositiveButtonTextCaseOption)
        let positiveButton = ButtonViewData(text: text,
                                            instanceGuid: responseOption.instanceGuid,
                                            action: responseOption.action,
                                            url: responseOption.url,
                                            eventType: try getEventType(responseOption.signalType),
                                            actionInExternalBrowser:
                                                try transformActionDefaultMobileBrowser(),
                                            closeOnPress: try transformCloseOnPress(),
                                            responseJWTToken: responseOption.responseJWTToken
        )

        if positiveButton.action == Action.url && (positiveButton.url == nil || positiveButton.url == "") {
            throw TransformerError.KeyIsMissing(key: kUrlMission)
        }

        return positiveButton
    }

    internal func transferNegativeButton(offer: Offer) throws -> ButtonViewData {
        guard let responseOption = offer.creative.responseOptions?.first(where: { $0.isPositive == false }) else {
            throw TransformerError.KeyIsMissing(key: kNegativeButton)
        }
        let text = try transformButtonText(text: responseOption.shortLabel ?? "",
                                           key: MobileCreativeNegativeButtonTextCaseOption)
        return ButtonViewData(text: text,
                              instanceGuid: responseOption.instanceGuid,
                              action: responseOption.action,
                              url: responseOption.url,
                              eventType: try getEventType(responseOption.signalType),
                              actionInExternalBrowser: try transformActionDefaultMobileBrowser(),
                              closeOnPress: try transformCloseOnPress(),
                              responseJWTToken: responseOption.responseJWTToken)
    }

    internal func transformButtonText(text: String, key: ConfigKey) throws -> String {
        let textCaseOption = try getTextCaseOption(key)
        switch textCaseOption {
        case .asTyped:
            return text
        case .titleCase:
            return text.titleCase
        case .uppercase:
            return text.uppercased()
        }
    }

    internal func transformActionDefaultMobileBrowser() throws -> Bool {
        return try getOptionalBool(MobilePlacementActionDefaultMobileBrowser) ?? false
    }

    internal func transformCloseOnPress() throws -> Bool {
        return try getOptionalBool(MobileCreativeNegativeButtonCloseOnPress) ?? false
    }

    // MARK: transform Offer T&C and PP
    internal func transformOfferTermsAndConditions(from: [String: String]?) throws -> LinkViewData? {
        if let link = try getOptionalString(CreativeTermsAndConditionsLink, from: from),
           !link.isEmpty {
            let termsAndConditions =
                LinkViewData(text: try getString(CreativeTermsAndConditionsTitle, from: from),
                             link: getOfferLegalLinks(link: link),
                             textStyleViewData: getEmptyTextStyle(),
                             underline: try (getOptionalBool(MobileCreativeTermsButtonUnderline) ?? true))
            return termsAndConditions
        }
        return nil
    }

    internal func transformOfferPrivacyPolicy(from: [String: String]?) throws -> LinkViewData? {
        if let link = try getOptionalString(CreativePrivacyPolicyLink, from: from),
           !link.isEmpty {
            let privacyPolicy =
                LinkViewData(text: try getString(CreativePrivacyPolicyTitle, from: from),
                             link: getOfferLegalLinks(link: link),
                             textStyleViewData: getEmptyTextStyle(),
                             underline: try (getOptionalBool(MobileCreativePrivacyPolicyButtonUnderline) ?? true))
            return privacyPolicy
        }
        return nil
    }

    internal func getOfferLegalLinks(link: String) -> String {
        if URL.isWebURL(url: link) {
            return link
        }
        return kBaseURL + link
    }

    // MARK: transform page indicator
    internal func transformPageIndicator(validIndex: Int, totalValidOffers: Int) throws -> PageIndicatorViewData? {
        let pageIndicatorType = try getOptionalString(MobilePlacementPageIndicatorStartingPosition)

        // default false to mimic the existing behaviour (not to count position1)
        let countPosition1 = try getOptionalBool(MobilePlacementPageIndicatorCountPos1) ?? false

        let isPosition1plus = pageIndicatorType == position1
        let isPosition2plus = pageIndicatorType == position2Plus
        if (validIndex == 0 && isPosition1plus) || (validIndex > 0 && (isPosition1plus || isPosition2plus)) {
            return try transformValidPageIndicator(
                realIndex: transformRealIndexPageIndicator(validIndex: validIndex,
                                                           isPosition2plus: isPosition2plus,
                                                           countPosition1: countPosition1),
                realTotalOffers: transformTotalPageIndicator(totalValidOffers: totalValidOffers,
                                                             isPosition2plus: isPosition2plus,
                                                             countPosition1: countPosition1)) ?? nil
        }
        return nil
    }

    // Calculate Real index of pageIndicator
    // Reduce one if it is position2+ and no need to count position1
    private func transformRealIndexPageIndicator(validIndex: Int,
                                                 isPosition2plus: Bool,
                                                 countPosition1: Bool) -> Int {
        guard isPosition2plus && !countPosition1 else {
            return validIndex
        }
        return validIndex - 1
    }

    // Calculate number of total offers
    // Reduce one if it is position2+ and no need to count position1
    private func transformTotalPageIndicator(totalValidOffers: Int,
                                             isPosition2plus: Bool,
                                             countPosition1: Bool) -> Int {
        guard isPosition2plus && !countPosition1 else {
            return totalValidOffers
        }
        return totalValidOffers - 1
    }

    internal func transformValidPageIndicator(realIndex: Int, realTotalOffers: Int) throws -> PageIndicatorViewData? {
        let indicatorType = try getPageIndicatorType(MobilePlacementPageIndicatorType)
        var textViewDataSeen: TextStyleViewData?
        var textViewDataUnseen: TextStyleViewData?
        var textBasedIndicatorViewData: TextViewData?

        if indicatorType == .circleWithText {
            textViewDataSeen = try getTextStyle(keyFontFamily: MobilePlacementPageIndicatorSeenFontFamily,
                                                keyFontWeight: MobilePlacementPageIndicatorSeenFontWeight,
                                                keySize: MobilePlacementPageIndicatorSeenFontSize,
                                                keyColorLight: MobilePlacementPageIndicatorSeenFontColorLight,
                                                keyColorDark: MobilePlacementPageIndicatorSeenFontColorDark)

            textViewDataUnseen = try getTextStyle(keyFontFamily: MobilePlacementPageIndicatorUnseenFontFamily,
                                                  keyFontWeight: MobilePlacementPageIndicatorUnseenFontWeight,
                                                  keySize: MobilePlacementPageIndicatorUnseenFontSize,
                                                  keyColorLight: MobilePlacementPageIndicatorUnseenFontColorLight,
                                                  keyColorDark: MobilePlacementPageIndicatorUnseenFontColorDark)
        } else if indicatorType == .text {
            textBasedIndicatorViewData = try transformTextBasedPageIndicator(
                realIndex: realIndex, realTotalOffers: realTotalOffers)
        }
        return PageIndicatorViewData(type: indicatorType,
                                     seenItems: realIndex + 1,
                                     unseenItems: realTotalOffers - (realIndex + 1),
                                     backgroundSeen:
                                        try getColorMap(MobilePlacementPageIndicatorSeenColorLight,
                                                        keyDark: MobilePlacementPageIndicatorSeenColorDark),
                                     backgroundUnseen:
                                        try getColorMap(MobilePlacementPageIndicatorUnseenColorLight,
                                                        keyDark: MobilePlacementPageIndicatorUnseenColorDark),
                                     textViewDataSeen: textViewDataSeen,
                                     textViewDataUnseen: textViewDataUnseen,
                                     paddingSize: try getFloat(MobilePlacementPageIndicatorPadding),
                                     diameter: try getFloat(MobilePlacementPageIndicatorDiameter),
                                     startIndex: try getOptionalInt(MobilePlacementPageIndicatorStartNumberCounter)
                                        ?? defaultPageIndicatorStart,
                                     location: try getPageIndicatorLocation(MobilePlacementPageIndicatorLocation),
                                     dashesWidth: try getOptionalFloat(MobilePlacementPageIndicatorDashesWidth)
                                        ?? defaultPageIndicatorDashesWidth,
                                     dashesHeight: try getOptionalFloat(MobilePlacementPageIndicatorDashesHeight)
                                        ?? defaultPageIndicatorDashesHeight,
                                     margin: try getOptionalFrameAlignment(MobilePlacementPageIndicatorMargin),
                                     textBasedIndicatorViewData: textBasedIndicatorViewData)

    }

    internal func transformTextBasedPageIndicator(realIndex: Int, realTotalOffers: Int)
    throws -> TextViewData? {
        return TextViewData(
            text: try getString(MobilePlacementPageIndicatorTextContent),
            textStyleViewData: try getTextStyle(
                keyFontFamily: MobilePlacementPageIndicatorTextFontFamily,
                keyFontWeight: MobilePlacementPageIndicatorTextFontWeight,
                keySize: MobilePlacementPageIndicatorTextFontSize,
                keyColorLight: MobilePlacementPageIndicatorTextFontColorLight,
                keyColorDark: MobilePlacementPageIndicatorTextFontColorDark,
                keyAlignment: MobilePlacementPageIndicatorTextAlignment,
                keyLineSpacing: MobilePlacementPageIndicatorTextLineSpacing
            ))
    }

    // MARK: transform before offer
    internal func transformBeforeOffer(validIndex: Int) throws -> TextViewData? {
        let optionalContent = try getOptionalString(MobilePlacementBeforeOfferCopyContent)
        let showBeforeOfferPos1: Bool = try (getOptionalBool(MobilePlacementBeforeOfferShowPosition1) ?? false)
        let showBeforeOfferPos2Plus: Bool = try
            (getOptionalBool(MobilePlacementBeforeOfferShowPosition2Plus) ?? false)
        if let content = optionalContent,
           (validIndex == 0 && showBeforeOfferPos1) ||
            (validIndex != 0 && showBeforeOfferPos2Plus) {
            return TextViewData(text: content,
                                textStyleViewData: try getTextStyle(
                                    keyFontFamily: MobilePlacementBeforeOfferCopyFontFamily,
                                    keyFontWeight: MobilePlacementBeforeOfferCopyFontWeight,
                                    keySize: MobilePlacementBeforeOfferCopyFontSize,
                                    keyColorLight: MobilePlacementBeforeOfferCopyFontColorLight,
                                    keyColorDark: MobilePlacementBeforeOfferCopyFontColorDark,
                                    keyAlignment: MobilePlacementBeforeOfferCopyAlignment,
                                    keyLineSpacing: MobilePlacementBeforeOfferCopyLineSpacing),
                                padding: try getOptionalFrameAlignment(MobilePlacementBeforeOfferMargin))
        }
        return nil
    }

    // MARK: transform confirmation message
    internal func transformConfirmationMessage(validIndex: Int, from: [String: String]?) throws ->
    ConfirmationMessageViewData? {
        return ConfirmationMessageViewData(textViewData:
                                            try transformConfirmationMessageTextView(validIndex: validIndex,
                                                                                     from: from),
                                           margin:
                                            try getOptionalFrameAlignment(MobileCreativeConfirmationMessageMargin))
    }

    // MARK: transform confirmation message text view data
    internal func transformConfirmationMessageTextView(validIndex: Int, from: [String: String]?) throws
    -> TextViewData? {
        let optionalConfirmationMessage = try getOptionalString(CreativeConfirmationMessage, from: from)
        let showConfirmationPos1: Bool = try (getOptionalBool(MobileCreativeConfirmationMessageShowPosition1) ?? false)
        let showConfirmationPos2Plus: Bool = try
            (getOptionalBool(MobileCreativeConfirmationMessageShowPosition2Plus) ?? false)
        if let confirmationMessage = optionalConfirmationMessage,
           (validIndex == 0 && showConfirmationPos1) ||
            (validIndex != 0 && showConfirmationPos2Plus) {
            return TextViewData(text: confirmationMessage,
                                textStyleViewData:
                                    try getTextStyle(keyFontFamily: MobileCreativeConfirmationMessageFontFamily,
                                                     keyFontWeight: MobileCreativeConfirmationMessageFontWeight,
                                                     keySize: MobileCreativeConfirmationMessageFontSize,
                                                     keyColorLight: MobileCreativeConfirmationMessageFontColorLight,
                                                     keyColorDark: MobileCreativeConfirmationMessageFontColorDark,
                                                     keyAlignment: MobileCreativeConfirmationMessageAlignment,
                                                     keyLineSpacing: MobileCreativeConfirmationMessageLineSpacing),
                                padding: try getOptionalFrameAlignment(MobileCreativeConfirmationMessagePadding))
        }

        return nil
    }

    // MARK: transform creative image show
    internal func transformCreativeImage(validIndex: Int, from: [String: String]?) throws -> String? {
        if try getOptionalString(MobileCreativeImageVisibility) == hidden {
            return nil
        }
        let showImagePos1: Bool = try (getOptionalBool(MobileCreativeImageShowPosition1) ?? true)
        let showImagePos2Plus: Bool = try (getOptionalBool(MobileCreativeImageShowPosition2Plus) ?? true)
        if (validIndex == 0 && showImagePos1) ||
            (validIndex != 0 && showImagePos2Plus) {
            return try getOptionalString(MobileCreativeImageSrc,
                                         from: from)
        }
        return nil
    }

    // MARK: transform after offer
    internal func transformAfterOffer(validIndex: Int) throws -> TextViewData? {
        let optionalContentPos1 = try getOptionalString(MobilePlacementAfterOfferCopyPosition1Content)
        let optionalContentPos2Plus = try getOptionalString(MobilePlacementAfterOfferCopyPosition2PlusContent)
        let showAfterOfferPos1: Bool = try (getOptionalBool(MobilePlacementAfterOfferShowPosition1) ?? false)
        let showAfterOfferPos2Plus: Bool = try
            (getOptionalBool(MobilePlacementAfterOfferShowPosition2Plus) ?? false)
        if validIndex == 0 && showAfterOfferPos1,
           let content = optionalContentPos1 {
            return TextViewData(text: content,
                                textStyleViewData: try transformAfterOfferTextStyle(),
                                padding: try getOptionalFrameAlignment(MobilePlacementAfterOfferPadding))

        } else if validIndex != 0 && showAfterOfferPos2Plus,
                  let content = optionalContentPos2Plus {
            return TextViewData(text: content,
                                textStyleViewData: try transformAfterOfferTextStyle(),
                                padding: try getOptionalFrameAlignment(MobilePlacementAfterOfferPadding))
        }
        return nil
    }

    internal func transformAfterOfferTextStyle() throws -> TextStyleViewData {
        return try getTextStyle(
            keyFontFamily: MobilePlacementAfterOfferCopyFontFamily,
            keyFontWeight: MobilePlacementAfterOfferCopyFontWeight,
            keySize: MobilePlacementAfterOfferCopyFontSize,
            keyColorLight: MobilePlacementAfterOfferCopyFontColorLight,
            keyColorDark: MobilePlacementAfterOfferCopyFontColorDark,
            keyAlignment: MobilePlacementAfterOfferCopyAlignment,
            keyLineSpacing: MobilePlacementAfterOfferCopyLineSpacing)
    }

    // MARK: transform disclaimer
    internal func transformDisclaimer(from: [String: String]?) throws -> DisclaimerViewData? {
        return DisclaimerViewData(textViewData: try transformDisclaimerTextView(from: from),
                                  margin: try getOptionalFrameAlignment(MobileCreativeDisclaimerMargin))
    }

    // MARK: transform disclaimer text view
    internal func transformDisclaimerTextView(from: [String: String]?) throws -> TextViewData? {
        let disclaimerText = try getOptionalString(CreativeDisclaimer, from: from)
        if let disclaimerText = disclaimerText {
            return
                TextViewData(text: disclaimerText,
                             textStyleViewData:
                                try getTextStyle(keyFontFamily: MobileCreativeDisclaimerFontFamily,
                                                 keyFontWeight: MobileCreativeDisclaimerFontWeight,
                                                 keySize: MobileCreativeDisclaimerFontSize,
                                                 keyColorLight: MobileCreativeDisclaimerFontColorLight,
                                                 keyColorDark: MobileCreativeDisclaimerFontColorDark,
                                                 keyAlignment: MobileCreativeDisclaimerAlignment,
                                                 keyLineSpacing: MobileCreativeDisclaimerLineSpacing,
                                                 keyBackgroundColorLight: MobileCreativeDisclaimerBackgroundColorLight,
                                                 keyBackgroundColorDark:
                                                    MobileCreativeDisclaimerBackgroundColorDark
                                )
                )
        }
        return nil
    }

    // MARK: transform positive button styles
    internal func transformPositiveButtonStyles() throws -> ButtonStylesViewData {
        let defaultStyle =
            try getButtonStyle(keyFontFamily: MobileCreativePositiveButtonDefaultFontFamily,
                               keyFontWeight: MobileCreativePositiveButtonDefaultFontWeight,
                               keySize: MobileCreativePositiveButtonDefaultFontSize,
                               keyColorLight: MobileCreativePositiveButtonDefaultFontColorLight,
                               keyColorDark: MobileCreativePositiveButtonDefaultFontColorDark,
                               keyCornerRadius: MobileCreativePositiveButtonDefaultCornerRadius,
                               keyBorderThickness: MobileCreativePositiveButtonDefaultBorderThickness,
                               keyBorderColorLight: MobileCreativePositiveButtonDefaultBorderColorLight,
                               keyBorderColorDark: MobileCreativePositiveButtonDefaultBorderColorDark,
                               keyBackgroundColorLight: MobileCreativePositiveButtonDefaultBackgroundColorLight,
                               keyBackgroundColorDark: MobileCreativePositiveButtonDefaultBackgroundColorDark)
        let pressedStyle =
            try getButtonStyle(keyFontFamily: MobileCreativePositiveButtonPressedFontFamily,
                               keyFontWeight: MobileCreativePositiveButtonPressedFontWeight,
                               keySize: MobileCreativePositiveButtonPressedFontSize,
                               keyColorLight: MobileCreativePositiveButtonPressedFontColorLight,
                               keyColorDark: MobileCreativePositiveButtonPressedFontColorDark,
                               keyCornerRadius: MobileCreativePositiveButtonPressedCornerRadius,
                               keyBorderThickness: MobileCreativePositiveButtonPressedBorderThickness,
                               keyBorderColorLight: MobileCreativePositiveButtonPressedBorderColorLight,
                               keyBorderColorDark: MobileCreativePositiveButtonPressedBorderColorDark,
                               keyBackgroundColorLight: MobileCreativePositiveButtonPressedBackgroundColorLight,
                               keyBackgroundColorDark: MobileCreativePositiveButtonPressedBackgroundColorDark)
        return ButtonStylesViewData(defaultStyle: defaultStyle, pressedStyle: pressedStyle)
    }

    // MARK: transform negative button styles
    internal func transformNegativeButtonStyles() throws -> ButtonStylesViewData {
        let defaultStyle =
            try getButtonStyle(keyFontFamily: MobileCreativeNegativeButtonDefaultFontFamily,
                               keyFontWeight: MobileCreativeNegativeButtonDefaultFontWeight,
                               keySize: MobileCreativeNegativeButtonDefaultFontSize,
                               keyColorLight: MobileCreativeNegativeButtonDefaultFontColorLight,
                               keyColorDark: MobileCreativeNegativeButtonDefaultFontColorDark,
                               keyCornerRadius: MobileCreativeNegativeButtonDefaultCornerRadius,
                               keyBorderThickness: MobileCreativeNegativeButtonDefaultBorderThickness,
                               keyBorderColorLight: MobileCreativeNegativeButtonDefaultBorderColorLight,
                               keyBorderColorDark: MobileCreativeNegativeButtonDefaultBorderColorDark,
                               keyBackgroundColorLight: MobileCreativeNegativeButtonDefaultBackgroundColorLight,
                               keyBackgroundColorDark: MobileCreativeNegativeButtonDefaultBackgroundColorDark)
        let pressedStyle =
            try getButtonStyle(keyFontFamily: MobileCreativeNegativeButtonPressedFontFamily,
                               keyFontWeight: MobileCreativeNegativeButtonPressedFontWeight,
                               keySize: MobileCreativeNegativeButtonPressedFontSize,
                               keyColorLight: MobileCreativeNegativeButtonPressedFontColorLight,
                               keyColorDark: MobileCreativeNegativeButtonPressedFontColorDark,
                               keyCornerRadius: MobileCreativeNegativeButtonPressedCornerRadius,
                               keyBorderThickness: MobileCreativeNegativeButtonPressedBorderThickness,
                               keyBorderColorLight: MobileCreativeNegativeButtonPressedBorderColorLight,
                               keyBorderColorDark: MobileCreativeNegativeButtonPressedBorderColorDark,
                               keyBackgroundColorLight: MobileCreativeNegativeButtonPressedBackgroundColorLight,
                               keyBackgroundColorDark: MobileCreativeNegativeButtonPressedBackgroundColorDark)

        return ButtonStylesViewData(defaultStyle: defaultStyle, pressedStyle: pressedStyle)
    }

    // MARK: transform background without footer
    internal func transformBackgroundWithoutFooter() throws -> BackgroundWithoutFooterViewData {
        let background = try getOptionalColorMap(MobilePlacementWithoutFooterBackgroundColorLight,
                                                 keyDark: MobilePlacementWithoutFooterBackgroundColorDark)
        let cornerRadius = try getOptionalFloat(MobilePlacementWithoutFooterCornerRadius)
        let borderThickness = try getOptionalFloat(MobilePlacementWithoutFooterBorderThickness)
        let borderColor = try getOptionalColorMap(MobilePlacementWithoutFooterBorderColorLight,
                                                  keyDark: MobilePlacementWithoutFooterBorderColorDark)
        let padding = try getOptionalFrameAlignment(MobilePlacementWithoutFooterPadding)
        return BackgroundWithoutFooterViewData(backgroundColor: background,
                                               cornerRadius: cornerRadius,
                                               borderThickness: borderThickness,
                                               borderColor: borderColor,
                                               padding: padding)
    }

    // MARK: transform footer
    internal func transformFooter() throws -> FooterViewData {
        var roktPrivacyPolicy, partnerPrivacyPolicy: LinkViewData?

        let isRoktPrivacyPolicyExist = placement.placementConfigurables?[
            MobilePlacementFooterRoktPrivacyPolicyLink] != nil &&
            placement.placementConfigurables?[MobilePlacementFooterRoktPrivacyPolicyLink] != ""
        let isPartnerPrivacyPolicyExist = placement.placementConfigurables?[
            MobilePlacementFooterPartnerPrivacyPolicyLink] != nil &&
            placement.placementConfigurables?[MobilePlacementFooterPartnerPrivacyPolicyLink] != ""

        if isRoktPrivacyPolicyExist {
            roktPrivacyPolicy = try transformFooterRoktPrivacy()
        }
        if isPartnerPrivacyPolicyExist {
            partnerPrivacyPolicy = try transformFooterPartnerPrivacy()
        }
        let background = try getOptionalColorMap(MobilePlacementFooterBackgroundColorLight,
                                                 keyDark: MobilePlacementFooterBackgroundColorDark)

        return FooterViewData(backgroundColor: background,
                              roktPrivacyPolicy: roktPrivacyPolicy,
                              partnerPrivacyPolicy: partnerPrivacyPolicy,
                              footerDivider: try transformFooterDivider(),
                              alignment: try getAlignment(MobilePlacementFooterAlignment,
                                                          defaultAlignment: .end))
    }

    internal func transformFooterRoktPrivacy() throws -> LinkViewData {
        let textStyle =
            try getTextStyle(keyFontFamily: MobilePlacementFooterRoktPrivacyPolicyFontFamily,
                             keyFontWeight: MobilePlacementFooterRoktPrivacyPolicyFontWeight,
                             keySize: MobilePlacementFooterRoktPrivacyPolicyFontSize,
                             keyColorLight: MobilePlacementFooterRoktPrivacyPolicyFontColorLight,
                             keyColorDark: MobilePlacementFooterRoktPrivacyPolicyFontColorDark,
                             keyAlignment: MobilePlacementFooterRoktPrivacyPolicyAlignment,
                             keyLineSpacing: MobilePlacementFooterRoktPrivacyPolicyLineSpacing,
                             keyBackgroundColorLight: MobilePlacementFooterRoktPrivacyPolicyBackgroundColorLight,
                             keyBackgroundColorDark: MobilePlacementFooterRoktPrivacyPolicyBackgroundColorDark )
        return LinkViewData(text: try getString(MobilePlacementFooterRoktPrivacyPolicyContent),
                            link: try getString(MobilePlacementFooterRoktPrivacyPolicyLink),
                            textStyleViewData: textStyle, underline: false)
    }

    internal func transformFooterPartnerPrivacy() throws -> LinkViewData {
        let textStyle =
            try getTextStyle(keyFontFamily: MobilePlacementFooterPartnerPrivacyPolicyFontFamily,
                             keyFontWeight: MobilePlacementFooterPartnerPrivacyPolicyFontWeight,
                             keySize: MobilePlacementFooterPartnerPrivacyPolicyFontSize,
                             keyColorLight: MobilePlacementFooterPartnerPrivacyPolicyFontColorLight,
                             keyColorDark: MobilePlacementFooterPartnerPrivacyPolicyFontColorDark,
                             keyAlignment: MobilePlacementFooterPartnerPrivacyPolicyAlignment,
                             keyLineSpacing: MobilePlacementFooterPartnerPrivacyPolicyLineSpacing,
                             keyBackgroundColorLight: MobilePlacementFooterPartnerPrivacyPolicyBackgroundColorLight,
                             keyBackgroundColorDark: MobilePlacementFooterPartnerPrivacyPolicyBackgroundColorDark )

        return LinkViewData(text: try getString(MobilePlacementFooterPartnerPrivacyPolicyContent),
                            link: try getString(MobilePlacementFooterPartnerPrivacyPolicyLink),
                            textStyleViewData: textStyle, underline: false)
    }

    internal func transformFooterDivider() throws -> DividerViewDataWithDimensions {
        let dividerBackground = try getOptionalColorMap(MobilePlacementFooterDividerBackgroundColorLight,
                                                        keyDark: MobilePlacementFooterDividerBackgroundColorDark)
        let dividerShow = try getOptionalBool(MobilePlacementFooterDividerShow) ?? true
        let dividerHeight = try getOptionalFloat(MobilePlacementFooterDividerHeight) ?? 2

        var defaultMargin = FrameAlignment(top: 10, right: 0, bottom: 0, left: 0)
        switch placement.placementLayoutCode {
        case .lightboxLayout, .overlayLayout, .bottomSheetLayout:
            defaultMargin = FrameAlignment(top: 0, right: 14, bottom: 0, left: 14)
        default:
            break
        }

        let dividerMargin = try getOptionalFrameAlignment(MobilePlacementFooterDividerMargin) ?? defaultMargin

        return DividerViewDataWithDimensions(
            backgroundColor: dividerBackground,
            isVisible: dividerShow,
            height: CGFloat(dividerHeight),
            margin: dividerMargin
        )
    }

    // MARK: Style helpers

    internal func getButtonStyle(keyFontFamily: ConfigKey,
                                 keyFontWeight: ConfigKey?,
                                 keySize: ConfigKey,
                                 keyColorLight: ConfigKey,
                                 keyColorDark: ConfigKey,
                                 keyCornerRadius: ConfigKey,
                                 keyBorderThickness: ConfigKey,
                                 keyBorderColorLight: ConfigKey,
                                 keyBorderColorDark: ConfigKey,
                                 keyBackgroundColorLight: ConfigKey,
                                 keyBackgroundColorDark: ConfigKey) throws -> ButtonStyleViewData {
        let textStyle = try getTextStyle(keyFontFamily: keyFontFamily,
                                         keyFontWeight: keyFontWeight,
                                         keySize: keySize,
                                         keyColorLight: keyColorLight,
                                         keyColorDark: keyColorDark,
                                         keyBackgroundColorLight: keyBackgroundColorLight,
                                         keyBackgroundColorDark: keyBackgroundColorDark, defaultAlignment: .center)
        let borderColor = try getColorMap(keyBorderColorLight, keyDark: keyBorderColorDark)

        return ButtonStyleViewData(textStyleViewData: textStyle,
                                   cornerRadius: try getFloat(keyCornerRadius),
                                   borderThickness: try getFloat(keyBorderThickness),
                                   borderColor: borderColor)
    }

    internal func getTextStyle(keyFontFamily: ConfigKey,
                               keyFontWeight: ConfigKey? = nil,
                               keySize: ConfigKey,
                               keyColorLight: ConfigKey,
                               keyColorDark: ConfigKey,
                               keyAlignment: ConfigKey? = nil,
                               keyLineSpacing: ConfigKey? = nil,
                               keyBackgroundColorLight: ConfigKey? = nil,
                               keyBackgroundColorDark: ConfigKey? = nil,
                               defaultAlignment: ViewAlignment = .start,
                               keyShouldWordWrap: ConfigKey? = nil) throws -> TextStyleViewData {
        // if the key does not exist, we fall back to text tail truncation
        var lineBreakMode: NSLineBreakMode = .byTruncatingTail
        if let kWordWrap = keyShouldWordWrap,
           let shouldWrap = try? (getOptionalBool(kWordWrap)) {
            lineBreakMode = shouldWrap ? .byWordWrapping : .byTruncatingTail
        }

        return TextStyleViewData(
            fontFamily: try getString(keyFontFamily),
            fontWeight: getOptionalFontWeight(keyFontWeight),
            fontSize: try getFloat(keySize),
            fontColor: try getColorMap(keyColorLight, keyDark: keyColorDark),
            backgroundColor: (keyBackgroundColorLight != nil && keyBackgroundColorDark != nil)
                ? try getOptionalColorMap(keyBackgroundColorLight!, keyDark: keyBackgroundColorDark!) : nil,
            alignment: try getAlignment(keyAlignment, defaultAlignment: defaultAlignment),
            lineSpacing: keyLineSpacing != nil ? try (getOptionalFloat(keyLineSpacing!) ?? kDefaultLineSpacing)
                : kDefaultLineSpacing,
            lineBreakMode: lineBreakMode
        )
    }

    internal func getEmptyTextStyle() -> TextStyleViewData {
        return TextStyleViewData(fontFamily: "",
                                 fontWeight: nil,
                                 fontSize: 16,
                                 fontColor: ColorMap(),
                                 backgroundColor: nil)
    }

    internal func getOptionalFontWeight(_ key: ConfigKey?) -> CustomFontWeight? {
        guard let key,
              let weightRaw = try? getOptionalString(key)
        else { return nil }

        return CustomFontWeight(rawValue: weightRaw.lowercased())
    }

    internal func getOptionalFrameAlignment(_ key: ConfigKey) throws -> FrameAlignment? {
        let frameAlignmentText = try getOptionalString(key)
        if let frameAlignmentText = frameAlignmentText {
            let frameAlignmentValues = frameAlignmentText.split(separator: " ")
            if frameAlignmentValues.count == 4 {
                let top = Float(frameAlignmentValues[0])
                let right = Float(frameAlignmentValues[1])
                let bottom = Float(frameAlignmentValues[2])
                let left = Float(frameAlignmentValues[3])
                if top != nil && right != nil && left != nil && bottom != nil {
                    return FrameAlignment(top: top!, right: right!, bottom: bottom!, left: left!)
                }
            }
        }
        return nil
    }

    internal func getFrameAlignment(_ key: ConfigKey) throws -> FrameAlignment {
        return try getOptionalFrameAlignment(key) ?? FrameAlignment(top: 0, right: 0, bottom: 0, left: 0)
    }

    internal func getValidOfferCount() -> Int {
        var total = 0
        if let slots = placement.slots {
            for slot in slots where slot.offer != nil {
                total += 1
            }
        }
        return total
    }

    // MARK: Configurable helper internal functions

    internal func getString(_ key: ConfigKey) throws -> String {
        if let configurable = placement.placementConfigurables {
            return try getString(key, from: configurable)
        }
        throw TransformerError.KeyIsMissing(key: placementConfigurableText)
    }

    internal func getOptionalString(_ key: ConfigKey) throws -> String? {
        if let configurable = placement.placementConfigurables {
            return try getOptionalString(key, from: configurable)
        }
        return nil
    }

    internal func getFloat(_ key: ConfigKey) throws -> Float {
        if let configurable = placement.placementConfigurables {
            return try getFloat(key, from: configurable)
        }
        throw TransformerError.KeyIsMissing(key: placementConfigurableText)
    }

    internal func getOptionalFloat(_ key: ConfigKey) throws -> Float? {
        if let configurable = placement.placementConfigurables {
            return try getOptionalFloat(key, from: configurable)
        }
        return nil
    }

    internal func getInt(_ key: ConfigKey) throws -> Int {
        if let configurable = placement.placementConfigurables {
            return try getInt(key, from: configurable)
        }
        throw TransformerError.KeyIsMissing(key: placementConfigurableText)
    }

    internal func getOptionalInt(_ key: ConfigKey) throws -> Int? {
        if let configurable = placement.placementConfigurables {
            return try getOptionalInt(key, from: configurable)
        }
        return nil
    }

    internal func getBool(_ key: ConfigKey) throws -> Bool {
        if let configurable = placement.placementConfigurables {
            return try getBool(key, from: configurable)
        }
        throw TransformerError.KeyIsMissing(key: placementConfigurableText)
    }

    internal func getOptionalBool(_ key: ConfigKey) throws -> Bool? {
        if let configurable = placement.placementConfigurables {
            return try getOptionalBool(key, from: configurable)
        }
        return nil
    }

    internal func getColorMap(_ keyLight: ConfigKey, keyDark: ConfigKey) throws -> ColorMap {
        let light = try getString(keyLight)
        let dark = try getString(keyDark)
        return [0: light, 1: dark]
    }

    internal func getOptionalColorMap(_ keyLight: ConfigKey, keyDark: ConfigKey) throws -> ColorMap? {
        if let light = try getOptionalString(keyLight), let dark = try getOptionalString(keyDark) {
            return [0: light, 1: dark]
        }
        return nil
    }

    internal func getAlignment(_ key: ConfigKey?, defaultAlignment: ViewAlignment = .start) throws -> ViewAlignment {
        guard let key else { return defaultAlignment }
        switch try getOptionalString(key) {
        case ViewAlignment.start.rawValue:
            return .start
        case ViewAlignment.center.rawValue:
            return .center
        case ViewAlignment.end.rawValue:
            return .end
        default:
            return defaultAlignment
        }
    }

    internal func getOptionalAlignment(_ key: ConfigKey?) throws -> ViewAlignment? {
        guard let key else { return nil }
        switch try getOptionalString(key) {
        case ViewAlignment.start.rawValue:
            return .start
        case ViewAlignment.center.rawValue:
            return .center
        case ViewAlignment.end.rawValue:
            return .end
        default:
            return nil
        }
    }

    internal func getTextCaseOption(_ key: ConfigKey,
                                    defaultCaseOption: TextCaseOptions = .asTyped) throws -> TextCaseOptions {
        guard let caseOption = TextCaseOptions(rawValue: try getOptionalString(key) ?? "") else {
            return defaultCaseOption
        }
        return caseOption
    }

    internal func getPageIndicatorType(_ key: ConfigKey,
                                       defaultPageIndicator: PageIndicatorType = .circle)
    throws -> PageIndicatorType {
        guard let type = PageIndicatorType(rawValue: try getOptionalString(key) ?? "") else {
            return defaultPageIndicator
        }
        return type
    }

    internal func getPageIndicatorLocation(_ key: ConfigKey,
                                           defaultLocation: PageIndicatorLocation = .beforeOffer)
    throws -> PageIndicatorLocation {
        guard let type = PageIndicatorLocation(rawValue: try getOptionalString(key) ?? "") else {
            return defaultLocation
        }
        return type
    }

    internal func getEventType(_ optionalSignalType: SignalType?) throws -> EventType {
        guard let signalType = optionalSignalType else {
            throw TransformerError.KeyIsMissing(key: signalTypeText)
        }
        switch signalType {
        case .signalResponse:
            return EventType.SignalResponse
        case .signalGatedResponse:
            return EventType.SignalGatedResponse
        case .unknown:
            throw TransformerError.NotSupported(key: signalTypeText)
        }
    }

    internal func getTitlePosition(key: ConfigKey, defaultTitlePosition: TitlePosition = .inline) -> TitlePosition {
        guard let titlePositionRaw = try? getOptionalString(key),
              let titlePositionConverted = TitlePosition(rawValue: titlePositionRaw)
        else { return defaultTitlePosition }

        return titlePositionConverted
    }
}

extension PlacementTransformer {
    // MARK: Helper internal functions
    func getOptionalString(_ key: ConfigKey, from: [String: String]?) throws -> String? {
        return from?[key]
    }

    func getString(_ key: ConfigKey, from: [String: String]?) throws -> String {
        if let value = try getOptionalString(key, from: from) {
            return value
        }
        throw TransformerError.KeyIsMissing(key: key)
    }

    func getFloat(_ key: ConfigKey, from: [String: String]) throws -> Float {
        if let stringValue = try getOptionalString(key, from: from) {
            if let value = Float(stringValue) {
                return value
            }
            throw TransformerError.TypeMissMatch(key: key)
        }
        throw TransformerError.KeyIsMissing(key: key)
    }

    func getOptionalFloat(_ key: ConfigKey, from: [String: String]) throws -> Float? {
        if let stringValue = try getOptionalString(key, from: from) {
            if let value = Float(stringValue) {
                return value
            }
            throw TransformerError.TypeMissMatch(key: key)
        }
        return nil
    }

    func getInt(_ key: ConfigKey, from: [String: String]) throws -> Int {
        if let value = Int(try getString(key, from: from)) {
            return value
        }
        throw TransformerError.TypeMissMatch(key: key)
    }

    func getOptionalInt(_ key: ConfigKey, from: [String: String]) throws -> Int? {
        if let stringValue = try getOptionalString(key, from: from) {
            if let value = Int(stringValue) {
                return value
            }
            throw TransformerError.TypeMissMatch(key: key)
        }
        return nil
    }

    func getBool(_ key: ConfigKey, from: [String: String]) throws -> Bool {
        if let value = Bool(try getString(key, from: from)) {
            return value
        }
        throw TransformerError.TypeMissMatch(key: key)
    }

    func getOptionalBool(_ key: ConfigKey, from: [String: String]) throws -> Bool? {
        if let stringValue = try getOptionalString(key, from: from) {
            if let value = Bool(stringValue) {
                return value
            }
            throw TransformerError.TypeMissMatch(key: key)
        }
        return nil
    }
}
