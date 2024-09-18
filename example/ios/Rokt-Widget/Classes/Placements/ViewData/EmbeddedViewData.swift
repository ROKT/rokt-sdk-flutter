//
//  EmbeddedViewData.swift
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

import Foundation

class EmbeddedViewData: PlacementViewData {
    let targetElement: String
    let endMessageViewData: EndMessageViewData?
    let padding: FrameAlignment

    init(instanceGuid: String,
         pageInstanceGuid: String,
         launchDelayMilliseconds: Int?,
         placementLayoutCode: PlacementLayoutCode?,
         offerLayoutCode: String?,
         backgroundColor: ColorMap,
         offers: [OfferViewData],
         footerViewData: FooterViewData,
         backgroundWithoutFooterViewData: BackgroundWithoutFooterViewData,
         positiveButton: ButtonStylesViewData,
         negativeButton: ButtonStylesViewData?,
         navigateToButtonData: PlacementButtonViewData?,
         navigateToButtonStyles: ButtonWithDimensionStylesViewData?,
         navigateToDivider: DividerViewDataWithDimensions?,
         positiveButtonFirst: Bool,
         buttonsStacked: Bool,
         targetElement: String,
         endMessageViewData: EndMessageViewData?,
         padding: FrameAlignment,
         margin: FrameAlignment,
         startDate: Date,
         responseReceivedDate: Date,
         urlInExternalBrowser: Bool,
         cornerRadius: Float?,
         borderThickness: Float?,
         borderColor: ColorMap?,
         isNegativeButtonVisible: Bool = true,
         isNavigateButtonVisible: Bool = false,
         canLoadNextOffer: Bool = true,
         isNavigateToButtonCloseOnTap: Bool = true,
         placementsJWTToken: String,
         placementId: String
    ) {
        self.targetElement = targetElement
        self.endMessageViewData = endMessageViewData
        self.padding = padding
        super.init(instanceGuid: instanceGuid,
                   pageInstanceGuid: pageInstanceGuid,
                   launchDelayMilliseconds: launchDelayMilliseconds,
                   placementLayoutCode: placementLayoutCode,
                   offerLayoutCode: offerLayoutCode,
                   backgroundColor: backgroundColor,
                   offers: offers,
                   titleDivider: nil,
                   footerViewData: footerViewData,
                   backgroundWithoutFooterViewData: backgroundWithoutFooterViewData,
                   positiveButton: positiveButton,
                   negativeButton: negativeButton,
                   navigateToButtonData: navigateToButtonData,
                   navigateToButtonStyles: navigateToButtonStyles,
                   navigateToDivider: navigateToDivider,
                   positiveButtonFirst: positiveButtonFirst,
                   buttonsStacked: buttonsStacked,
                   margin: margin,
                   startDate: startDate,
                   responseReceivedDate: responseReceivedDate,
                   urlInExternalBrowser: urlInExternalBrowser,
                   cornerRadius: cornerRadius,
                   borderThickness: borderThickness,
                   borderColor: borderColor,
                   isNegativeButtonVisible: isNegativeButtonVisible,
                   isNavigateButtonVisible: isNavigateButtonVisible,
                   canLoadNextOffer: canLoadNextOffer,
                   isNavigateToButtonCloseOnTap: isNavigateToButtonCloseOnTap,
                   placementsJWTToken: placementsJWTToken,
                   placementId: placementId)
    }
}
