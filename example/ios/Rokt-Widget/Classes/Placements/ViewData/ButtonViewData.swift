//
//  ButtonViewData.swift
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

struct ButtonViewData: Equatable {
    let text: String
    let instanceGuid: String
    let action: Action?
    let url: String?
    let eventType: EventType
    let actionInExternalBrowser: Bool
    let closeOnPress: Bool
    let responseJWTToken: String

    init(text: String,
         instanceGuid: String,
         action: Action? = nil,
         url: String? = nil,
         eventType: EventType,
         actionInExternalBrowser: Bool,
         closeOnPress: Bool,
         responseJWTToken: String) {
        self.text = text
        self.instanceGuid = instanceGuid
        self.action = action
        self.url = url
        self.eventType = eventType
        self.actionInExternalBrowser = actionInExternalBrowser
        self.closeOnPress = closeOnPress
        self.responseJWTToken = responseJWTToken
    }
}

struct PlacementButtonViewData: Equatable {
    let text: String
    let action: Action
    let eventType: EventType?
    let closeOnPress: Bool

    init(
        text: String,
        action: Action = .captureOnly,
        eventType: EventType? = nil,
        closeOnPress: Bool
    ) {
        self.text = text
        self.action = action
        self.eventType = eventType
        self.closeOnPress = closeOnPress
    }
}
