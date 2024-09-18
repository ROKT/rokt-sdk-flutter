//
//  BNFNamespace.swift
//  Rokt-Widget
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

enum BNFNamespace: String, CaseIterable {
    case dataCreativeCopy = "DATA.creativeCopy"
    case dataCreativeResponse = "DATA.creativeResponse"
    case dataCreativeLink = "DATA.creativeLink"

    case state = "STATE"

    var withNamespaceSeparator: String { self.rawValue + BNFSeparator.namespace.rawValue }

    enum CreativeResponseKey: String {
        case positive
        case negative
    }
}
