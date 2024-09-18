//
//  OfferContentViewData.swift
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
struct OfferContentViewData: Equatable {
    let title: TextViewData?
    let body: TextViewData?
    let imageTitle: TextViewData?

    init(title: TextViewData? = nil,
         body: TextViewData? = nil,
         imageTitle: TextViewData? = nil) {
        self.title = title
        self.body = body
        self.imageTitle = imageTitle
    }
}
