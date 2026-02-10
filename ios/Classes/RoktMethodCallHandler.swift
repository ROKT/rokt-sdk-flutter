//
//  RoktMethodCallHandler.swift
//  rokt_sdk
//
//  Copyright 2020 Rokt Pte Ltd
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Flutter
import UIKit
import Rokt_Widget

class RoktMethodCallHandler: NSObject, FlutterStreamHandler {
    fileprivate let SUCCESS = "success"
    fileprivate let FAIL = "fail"
    fileprivate let EVENT_CHANNEL = "RoktEvents"

    let channel: FlutterMethodChannel
    let factory: RoktWidgetFactory
    let registrar: FlutterPluginRegistrar
    let roktEventChannel: FlutterEventChannel
    var eventListeners = [FlutterEventSink]()

    init(channel: FlutterMethodChannel, factory: RoktWidgetFactory, registrar: FlutterPluginRegistrar) {
        self.channel = channel
        self.factory = factory
        self.registrar = registrar
        self.roktEventChannel = FlutterEventChannel(name: EVENT_CHANNEL, binaryMessenger: registrar.messenger())
        super.init()
        self.roktEventChannel.setStreamHandler(self)
    }

    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        eventListeners.append(eventSink)
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }

    public func initialize(_ call: FlutterMethodCall,
                           result: @escaping FlutterResult) {

        if let args = call.arguments as? Dictionary<String, Any>,
           let roktTagId = args["roktTagId"] as? String {
            let fontFilePathMap = args["fontFilePathMap"] as? Dictionary<String, String>
            if let typefaces = fontFilePathMap {
                registerPartnerFonts(typefaces)
            }
            Rokt.setFrameworkType(frameworkType: .Flutter)
            Rokt.globalEvents { roktEvent in
                self.handleEvents(roktEvent)
            }
            Rokt.initWith(roktTagId: roktTagId)
            result(SUCCESS)
        } else {
            result(FAIL)
        }
    }

    public func selectPlacements(_ call: FlutterMethodCall,
                                 result: @escaping FlutterResult) {

        if let args = call.arguments as? Dictionary<String, Any>,
           let viewName = args["viewName"] as? String,
           let attributes = args["attributes"] as? [String: String] {

            var placements = [String: RoktEmbeddedView]()
            if let placeholders = args["placeholders"] as? [Int: String] {
                for (placeholderId, placeholderName) in placeholders {
                    for (id, flutterView) in factory.platformViews {
                        if id == placeholderId {
                            placements[placeholderName] = flutterView.roktEmbeddedView
                        }
                    }
                }
            }

            let configMap = args["config"] as? [String: Any] ?? [String: Any] ()
            let config = configMap.isEmpty ? nil : buildRoktConfig(configMap)

            let placeholders = args["placeholders"] as? [Int: String]
            Rokt.selectPlacements(
                identifier: viewName,
                attributes: attributes,
                placements: placements,
                config: config,
                onEvent: { roktEvent in
                    self.handleEvents(
                        roktEvent,
                        viewName: viewName,
                        placeholders: placeholders
                    )
                }
            )

            result(SUCCESS)
        } else {
            result(FAIL)
        }
    }

    public func purchaseFinalized(_ call: FlutterMethodCall,
                                result: @escaping FlutterResult) {
        if let args = call.arguments as? Dictionary<String, Any>,
           let placementId = args["placementId"] as? String,
           let catalogItemId = args["catalogItemId"] as? String,
           let success = args["success"] as? Bool {

            if #available(iOS 15.0, *) {
                Rokt.purchaseFinalized(
                    identifier: placementId,
                    catalogItemId: catalogItemId, 
                    success: success
                )
                result(SUCCESS)
                return
            }
        }
        result(FAIL)
    }

    private func registerPartnerFonts(_ typefaces: Dictionary<String, String>) {
        let bundle = Bundle.main
        for (_, fileName) in typefaces {
            let fontKey = registrar.lookupKey(forAsset: fileName)
            let path = bundle.path(forResource: fontKey, ofType: nil)
            var errorRef: Unmanaged<CFError>? = nil
            guard let filePath = path, path?.isEmpty == false else {
                continue
            }
            let fontUrl = NSURL(fileURLWithPath: filePath)
            CTFontManagerRegisterFontsForURL(fontUrl, .process, &errorRef)
        }
    }

    private func buildRoktConfig(_ config: Dictionary<String, Any>) -> RoktConfig {
        let builder = RoktConfig.Builder()

        if let colorMode = config["colorMode"] as? String {
            builder.colorMode(colorMode.toColorMode())
        }

        if let cacheConfig = config["cacheConfig"] as? [String: Any] {
            let cacheDuration = cacheConfig["cacheDurationInSeconds"] as? Double ?? RoktConfig.CacheConfig.maxCacheDuration
            let cachedAttributes = cacheConfig["cacheAttributes"] as? [String: String]
            builder.cacheConfig(RoktConfig.CacheConfig(cacheDuration: cacheDuration, cacheAttributes: cachedAttributes))
        }

        return builder.build()
    }

    private func handleEvents(
        _ roktEvent: RoktEvent,
        viewName: String? = nil,
        placeholders: [Int: String]? = nil
    ) {
        var eventParamMap = [String: String] ()
        var eventName = ""
        var placementId: String?
        if let event = roktEvent as? RoktEvent.FirstPositiveEngagement {
            eventName = "FirstPositiveEngagement"
            placementId = event.placementId
        } else if let event = roktEvent as? RoktEvent.ShowLoadingIndicator {
            eventName = "ShowLoadingIndicator"
        } else if let event = roktEvent as? RoktEvent.HideLoadingIndicator {
            eventName = "HideLoadingIndicator"
        } else if let event = roktEvent as? RoktEvent.OfferEngagement {
            eventName = "OfferEngagement"
            placementId = event.placementId
        } else if let event = roktEvent as? RoktEvent.PositiveEngagement {
            eventName = "PositiveEngagement"
            placementId = event.placementId
        } else if let event = roktEvent as? RoktEvent.PlacementReady {
            eventName = "PlacementReady"
            placementId = event.placementId
        } else if let event = roktEvent as? RoktEvent.PlacementInteractive {
            eventName = "PlacementInteractive"
            placementId = event.placementId
        } else if let event = roktEvent as? RoktEvent.PlacementFailure {
            eventName = "PlacementFailure"
            placementId = event.placementId
        } else if let event = roktEvent as? RoktEvent.PlacementCompleted {
            eventName = "PlacementCompleted"
            placementId = event.placementId
        } else if let event = roktEvent as? RoktEvent.PlacementClosed {
            eventName = "PlacementClosed"
            placementId = event.placementId
        } else if let event = roktEvent as? RoktEvent.InitComplete {
            eventName = "InitComplete"
            eventParamMap["status"] = String(event.success)
        } else if let event = roktEvent as? RoktEvent.OpenUrl {
            eventName = "OpenUrl"
            eventParamMap["url"] = event.url
            placementId = event.placementId
        } else if let event = roktEvent as? RoktEvent.CartItemInstantPurchase {
            eventName = "CartItemInstantPurchase"
            eventParamMap["cartItemId"] = event.cartItemId
            eventParamMap["catalogItemId"] = event.catalogItemId
            eventParamMap["currency"] = event.currency
            eventParamMap["description"] = event.description
            eventParamMap["linkedProductId"] = event.linkedProductId ?? ""
            eventParamMap["name"] = event.name
            eventParamMap["providerData"] = event.providerData
            if let totalPrice = event.totalPrice {
                eventParamMap["totalPrice"] = "\(totalPrice)"
            }
            if let quantity = event.quantity {
                eventParamMap["quantity"] = "\(quantity)"
            }
            if let unitPrice = event.unitPrice {
                eventParamMap["unitPrice"] = "\(unitPrice)"
            }
            placementId = event.placementId
        } else if let event = roktEvent as? RoktEvent.EmbeddedSizeChanged {
            eventName = "EmbeddedSizeChanged"
            placementId = event.placementId
            eventParamMap["updatedHeight"] = "\(event.updatedHeight)"
            if let placeholders = placeholders {
                for (placeholderId, placeholderName) in placeholders {
                    for (id, flutterView) in self.factory.platformViews {
                        if id == placeholderId && placeholderName == event.placementId {
                            flutterView.sendUpdatedHeight(height: Double(event.updatedHeight))
                        }
                    }
                }
            }
        }

        eventParamMap["event"] = eventName
        if (viewName != nil) {
            eventParamMap["viewName"] = viewName
        }
        if (placementId != nil) {
            eventParamMap["placementId"] = placementId
        }
        for listener in self.eventListeners {
            listener(eventParamMap)
        }
    }

}

fileprivate extension String {
    func toColorMode() -> RoktConfig.ColorMode {
        return switch self {
            case "light": .light
            case "dark": .dark
            default: .system
        }
    }
}


