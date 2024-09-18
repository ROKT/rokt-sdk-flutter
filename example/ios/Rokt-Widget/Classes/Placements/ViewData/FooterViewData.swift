//
//  FooterViewData.swift
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

struct FooterViewData: Equatable {
    let backgroundColor: ColorMap?
    let roktPrivacyPolicy: LinkViewData?
    let partnerPrivacyPolicy: LinkViewData?
    let footerDivider: DividerViewDataWithDimensions
    let alignment: ViewAlignment

    init(backgroundColor: ColorMap? = nil,
         roktPrivacyPolicy: LinkViewData? = nil,
         partnerPrivacyPolicy: LinkViewData? = nil,
         footerDivider: DividerViewDataWithDimensions,
         alignment: ViewAlignment) {
        self.backgroundColor = backgroundColor
        self.roktPrivacyPolicy = roktPrivacyPolicy
        self.partnerPrivacyPolicy = partnerPrivacyPolicy
        self.footerDivider = footerDivider
        self.alignment = alignment
    }
}
