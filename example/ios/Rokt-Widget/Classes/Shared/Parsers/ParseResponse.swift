//
//  ParsePlacement.swift
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

typealias ColorMap = [Int: String]

class PlacementResponse: Decodable {
    let sessionId: String
    let page: Page?
    let placementContext: PlacementContext
    let placements: [Placement]

    enum CodingKeys: String, CodingKey {
        case sessionId
        case page
        case placementContext
        case placements
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        sessionId = try container.decode(String.self, forKey: .sessionId)
        page = try container.decodeIfPresent(Page.self, forKey: .page)
        placementContext = try container.decode(PlacementContext.self, forKey: .placementContext)
        placements = try container.decode([Placement].self, forKey: .placements)
    }
}

@available(iOS 13, *)
class ExperienceResponse: PlacementResponse {
    var plugins: [PluginWrapperModel]?

    enum CodingKeys: String, CodingKey {
        case plugins
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        plugins = try container.decodeIfPresent([PluginWrapperModel].self, forKey: .plugins)

        try super.init(from: decoder)
    }

    func getOuterLayoutSchema() -> OuterLayoutSchemaNetworkModel? {
        plugins?.first?.plugin?.config.outerLayoutSchema
    }

    func getAllInnerlayoutSchema() -> [LayoutVariantChildren]? {
        guard let slots = plugins?.first?.plugin?.config.slots else { return nil }

        return slots.compactMap { $0.layoutVariant?.layoutVariantSchema }
    }
    
    func getPlugins() -> [LayoutPlugin] {
        var layoutPlugins = [LayoutPlugin]()
        if let plugins {
            for pluginItem in plugins {
                let outerLayer = pluginItem.plugin?.config.outerLayoutSchema
                let layoutPlugin = LayoutPlugin(pluginInstanceGuid: pluginItem.plugin?.config.instanceGuid ?? "",
                                                breakpoints: outerLayer?.breakpoints,
                                                layout: outerLayer?.layout,
                                                slots: pluginItem.plugin?.config.slots ?? [],
                                                targetElementSelector: pluginItem.plugin?.targetElementSelector)
                layoutPlugins.append(layoutPlugin)
            }
        }
        return layoutPlugins
    }
    
    func getPageModel() -> PageModel? {
        guard let outerLayer = getOuterLayoutSchema(),
              outerLayer.layout != nil && getAllInnerlayoutSchema() != nil
        else { return nil }
        
        return PageModel(sessionId: sessionId,
                         pageInstanceGuid: placementContext.pageInstanceGuid,
                         layoutPlugins: getPlugins())
    }
    
}

struct Page: Codable {
    let pageId: String?
}

struct Placement: Codable {
    let id: String
    let targetElementSelector: String
    let offerLayoutCode: String
    let placementLayoutCode: PlacementLayoutCode?
    let placementConfigurables: [String: String]?
    let instanceGuid: String
    let slots: [Slot]?
}

struct PlacementContext: Codable {
    let roktTagId: String
    let pageInstanceGuid: String
}

struct Slot: Codable {
    let instanceGuid: String
    let offer: Offer?
}

struct Offer: Codable {
    let campaignId: String?
    let creative: Creative
}

struct Creative: Codable {
    let referralCreativeId: String
    let instanceGuid: String
    let copy: [String: String]

    let responseOptions: [ResponseOption]?
}

struct ResponseOption: Codable, Hashable {
    let id: String
    let action: Action?
    let instanceGuid: String
    let signalType: SignalType?
    let shortLabel: String?
    let longLabel: String?
    let shortSuccessLabel: String?
    let isPositive: Bool?
    let url: String?
}

// MARK: - Enums
enum EndOfJourneyBehavior: Int, Codable {
    case showEndMessage = 0
    case collapse = 1
}

enum ViewAlignment: String, Codable, CaseIterableDefaultLast {
    case start  = "start"
    case center = "center"
    case end    = "end"
    case unknown = ""
}

enum Action: String, Codable, CaseIterableDefaultLast {
    case url = "Url"
    case captureOnly = "CaptureOnly"
    case unknown
}

enum SignalType: String, Codable, CaseIterableDefaultLast {
    case signalResponse = "SignalResponse"
    case signalGatedResponse = "SignalGatedResponse"
    case unknown
}

enum TextCaseOptions: String, Codable, CaseIterableDefaultLast {
    case titleCase = "TitleCase"
    case uppercase = "UpperCase"
    case asTyped = "AsTyped"
}

enum PageIndicatorType: String, Codable, CaseIterableDefaultLast {
    case dashes
    case circleWithText
    case circle
    case text
}

enum PageIndicatorLocation: String, Codable, CaseIterableDefaultLast {
    case afterOffer
    case beforeOffer
}

enum CreativeTitleImageArrangement: String, Codable, CaseIterableDefaultLast {
    case start
    case end
    case bottom
}

enum CreativeTitleImageAlignment: String, Codable, CaseIterableDefaultLast {
    case top
    case bottom
    case center
}

enum PlacementLayoutCode: String, Codable, CaseIterableDefaultLast {
    case lightboxLayout = "MobileSdk.LightboxLayout"
    case embeddedLayout = "MobileSdk.EmbeddedLayout"
    case overlayLayout = "MobileSdk.OverlayLayout"
    case bottomSheetLayout = "MobileSdk.BottomSheetLayout"
    case unknown
}
