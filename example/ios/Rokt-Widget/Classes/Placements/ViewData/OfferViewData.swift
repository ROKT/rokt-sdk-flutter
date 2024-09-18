//
//  OfferViewData.swift
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

struct OfferViewData: Equatable {
    let instanceGuid: String
    let creativeInstanceGuid: String?
    let positiveButtonLabel: ButtonViewData?
    let negativeButtonLabel: ButtonViewData?
    let content: OfferContentViewData?
    let image: ImageViewData?
    let campaignId: String?
    let background: ColorMap?
    let padding: FrameAlignment?
    let disclaimer: DisclaimerViewData?
    let termsAndConditionsButton: LinkViewData?
    let privacyPolicyButton: LinkViewData?
    let beforeOfferViewData: TextViewData?
    let confirmationMessage: ConfirmationMessageViewData?
    let pageIndicator: PageIndicatorViewData?
    let afterOfferViewData: TextViewData?
    let isNegativeButtonVisible: Bool?

    let slotJWTToken: String
    let creativeJWTToken: String

    init(instanceGuid: String,
         creativeInstanceGuid: String? = nil,
         positiveButtonLabel: ButtonViewData? = nil,
         negativeButtonLabel: ButtonViewData? = nil,
         content: OfferContentViewData? = nil,
         image: ImageViewData? = nil,
         campaignId: String? = nil,
         background: ColorMap? = nil,
         padding: FrameAlignment? = nil,
         disclaimer: DisclaimerViewData? = nil,
         termsAndConditionsButton: LinkViewData? = nil,
         privacyPolicyButton: LinkViewData? = nil,
         beforeOfferViewData: TextViewData? = nil,
         confirmationMessage: ConfirmationMessageViewData? = nil,
         pageIndicator: PageIndicatorViewData? = nil,
         afterOfferViewData: TextViewData? = nil,
         isNegativeButtonVisible: Bool? = true,
         slotJWTToken: String,
         creativeJWTToken: String) {
        self.instanceGuid = instanceGuid
        self.creativeInstanceGuid = creativeInstanceGuid
        self.positiveButtonLabel = positiveButtonLabel
        self.negativeButtonLabel = negativeButtonLabel
        self.content = content
        self.image = image
        self.campaignId = campaignId
        self.background = background
        self.padding = padding
        self.disclaimer = disclaimer
        self.termsAndConditionsButton = termsAndConditionsButton
        self.privacyPolicyButton = privacyPolicyButton
        self.beforeOfferViewData = beforeOfferViewData
        self.confirmationMessage = confirmationMessage
        self.pageIndicator = pageIndicator
        self.afterOfferViewData = afterOfferViewData
        self.isNegativeButtonVisible = isNegativeButtonVisible
        self.slotJWTToken = slotJWTToken
        self.creativeJWTToken = creativeJWTToken
    }

    func isGhostOffer() -> Bool {
        if  self.creativeInstanceGuid == nil &&
                self.content == nil &&
                self.positiveButtonLabel == nil &&
                self.negativeButtonLabel == nil &&
                self.image == nil &&
                self.background == nil &&
                self.padding == nil &&
                self.disclaimer == nil &&
                self.termsAndConditionsButton == nil &&
                self.privacyPolicyButton == nil {
            return true
        }
        return false
    }
}
