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
    let content: TextViewData?
    let title: TextViewData?
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
    
    init(instanceGuid: String,
         creativeInstanceGuid: String? = nil,
         positiveButtonLabel: ButtonViewData? = nil,
         negativeButtonLabel: ButtonViewData? = nil,
         content: TextViewData? = nil,
         title: TextViewData? = nil,
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
         isNegativeButtonVisible: Bool? = true) {
        
        self.instanceGuid = instanceGuid
        self.creativeInstanceGuid = creativeInstanceGuid
        self.positiveButtonLabel = positiveButtonLabel
        self.negativeButtonLabel = negativeButtonLabel
        self.content = content
        self.title = title
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
