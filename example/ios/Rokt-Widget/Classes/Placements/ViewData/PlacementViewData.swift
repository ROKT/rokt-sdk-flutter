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

class PlacementViewData {
    let instanceGuid: String
    let pageInstanceGuid: String
    let launchDelayMilliseconds: Int?
    let placementLayoutCode: PlacementLayoutCode?
    let offerLayoutCode: String?
    let backgroundColor: ColorMap
    let offers: [OfferViewData]
    let footerViewData: FooterViewData
    let backgroundWithoutFooterViewData: BackgroundWithoutFooterViewData
    let positiveButton: ButtonStylesViewData
    let negativeButton: ButtonStylesViewData?
    let positiveButtonFirst: Bool
    let buttonsStacked: Bool
    let margin: FrameAlignment
    var startDate: Date
    var responseReceivedDate: Date
    let urlInExternalBrowser: Bool
    let cornerRadius: Float?
    let borderThickness: Float?
    let borderColor: ColorMap?
    let isNegativeButtonVisible: Bool
    let canLoadNextOffer: Bool

    let titleDivider: DividerViewDataWithDimensions?

    let isNavigateButtonVisible: Bool
    let navigateToButtonStyles: ButtonWithDimensionStylesViewData?
    let navigateToButtonData: PlacementButtonViewData?
    let navigateToDivider: DividerViewDataWithDimensions?
    let isNavigateToButtonCloseOnTap: Bool

    // JWT inside `placements`
    let placementsJWTToken: String
    let placementId: String

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
        self.instanceGuid = instanceGuid
        self.pageInstanceGuid = pageInstanceGuid
        self.launchDelayMilliseconds = launchDelayMilliseconds
        self.placementLayoutCode = placementLayoutCode
        self.offerLayoutCode = offerLayoutCode
        self.backgroundColor = backgroundColor
        self.titleDivider = titleDivider
        self.offers = offers
        self.footerViewData = footerViewData
        self.positiveButton = positiveButton
        self.negativeButton = negativeButton
        self.navigateToButtonData = navigateToButtonData
        self.navigateToButtonStyles = navigateToButtonStyles
        self.navigateToDivider = navigateToDivider
        self.positiveButtonFirst = positiveButtonFirst
        self.buttonsStacked = buttonsStacked
        self.margin = margin
        self.startDate = startDate
        self.responseReceivedDate = responseReceivedDate
        self.urlInExternalBrowser = urlInExternalBrowser
        self.cornerRadius = cornerRadius
        self.borderThickness = borderThickness
        self.borderColor = borderColor
        self.backgroundWithoutFooterViewData = backgroundWithoutFooterViewData
        self.isNegativeButtonVisible = isNegativeButtonVisible
        self.isNavigateButtonVisible = isNavigateButtonVisible
        self.canLoadNextOffer = canLoadNextOffer
        self.isNavigateToButtonCloseOnTap = isNavigateToButtonCloseOnTap
        self.placementsJWTToken = placementsJWTToken
        self.placementId = placementId
    }
}
