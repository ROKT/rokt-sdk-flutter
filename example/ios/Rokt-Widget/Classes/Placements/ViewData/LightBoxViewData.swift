//
//  PlacementViewData.swift
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

enum TitlePosition: String {
    case inline
    case bottom
}

class LightBoxViewData: PlacementViewData {
    let title: TitleViewData
    let titlePosition: TitlePosition
    let titleMargin: FrameAlignment
    let lightboxBackground: ColorMap?
    let bottomSheetExpandable: Bool
    let bottomSheetDismissible: Bool

    init(instanceGuid: String,
         pageInstanceGuid: String,
         launchDelayMilliseconds: Int?,
         placementLayoutCode: PlacementLayoutCode?,
         offerLayoutCode: String?,
         backgroundColor: ColorMap,
         offers: [OfferViewData],
         titleDivider: DividerViewDataWithDimensions?,
         footerViewData: FooterViewData,
         backgroundWithoutFooterViewData: BackgroundWithoutFooterViewData,
         positiveButton: ButtonStylesViewData,
         negativeButton: ButtonStylesViewData?,
         navigateToButtonData: PlacementButtonViewData?,
         navigateToButtonStyles: ButtonWithDimensionStylesViewData?,
         navigateToDivider: DividerViewDataWithDimensions?,
         positiveButtonFirst: Bool,
         buttonsStacked: Bool,
         title: TitleViewData,
         margin: FrameAlignment,
         startDate: Date,
         responseReceivedDate: Date,
         urlInExternalBrowser: Bool,
         lightboxBackground: ColorMap?,
         cornerRadius: Float?,
         borderThickness: Float?,
         borderColor: ColorMap?,
         bottomSheetExpandable: Bool,
         bottomSheetDismissible: Bool,
         isNegativeButtonVisible: Bool = true,
         isNavigateButtonVisible: Bool = false,
         canLoadNextOffer: Bool = true,
         isNavigateToButtonCloseOnTap: Bool = true,
         titlePosition: TitlePosition = .inline,
         titleMargin: FrameAlignment,
         placementsJWTToken: String,
         placementId: String
    ) {
        self.title = title
        self.lightboxBackground = lightboxBackground
        self.bottomSheetExpandable = bottomSheetExpandable
        self.bottomSheetDismissible = bottomSheetDismissible
        self.titlePosition = titlePosition
        self.titleMargin = titleMargin

        super.init(instanceGuid: instanceGuid,
                   pageInstanceGuid: pageInstanceGuid,
                   launchDelayMilliseconds: launchDelayMilliseconds,
                   placementLayoutCode: placementLayoutCode,
                   offerLayoutCode: offerLayoutCode,
                   backgroundColor: backgroundColor,
                   offers: offers,
                   titleDivider: titleDivider,
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
