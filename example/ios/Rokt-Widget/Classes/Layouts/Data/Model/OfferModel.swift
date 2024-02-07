//
//  OfferModel.swift
//  Pods
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation

struct OfferModel: Codable {
    let campaignId: String?
    let creative: CreativeModel
}

struct CreativeModel: Codable {
    let referralCreativeId: String
    let instanceGuid: String
    let copy: [String: String]
    let images: [String: CreativeImage]?
    let links: [String: CreativeLink]?

    let responseOptionsMap: ResponseOptionList?
}

struct CreativeImage: Codable, Hashable {
    let light: String?
    let dark: String?
    let alt: String?
    let title: String?
}

struct ResponseOptionList: Codable {
    let positive: ResponseOption?
    let negative: ResponseOption?
}

struct CreativeLink: Codable, Hashable {
    let url: String?
    let title: String?
}
