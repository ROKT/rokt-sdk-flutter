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
    fileprivate let ARGS = "args"
    fileprivate let CALL_LISTENER = "callListener"
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
    
    public func execute(_ call: FlutterMethodCall,
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

            let configMap = args["config"] as? [String: String] ?? [String: String] ()
            let config = configMap.isEmpty ? nil : buildRoktConfig(configMap)
            
            let callBackId = args["callbackId"] as? Int ?? 0
            var callbackMap = [String: Any] ()
            callbackMap["id"] = callBackId
            Rokt.events(viewName: viewName, onEvent: { roktEvent in
                self.handleEvents(roktEvent, viewName: viewName)
            })
            Rokt.execute(viewName: viewName, attributes: attributes, placements: placements, config: config, onLoad: {
                // Optional callback for when the Rokt placement loads
                callbackMap[self.ARGS] = "load"
                self.channel.invokeMethod(self.CALL_LISTENER, arguments: callbackMap)
            }, onUnLoad: {
                // Optional callback for when the Rokt placement unloads
                callbackMap[self.ARGS] = "unload"
                self.channel.invokeMethod(self.CALL_LISTENER, arguments: callbackMap)
            }, onShouldShowLoadingIndicator: {
                // Optional callback to show a loading indicator
                callbackMap[self.ARGS] = "onShouldShowLoadingIndicator"
                self.channel.invokeMethod(self.CALL_LISTENER, arguments: callbackMap)
            }, onShouldHideLoadingIndicator: {
                // Optional callback to hide a loading indicator
                callbackMap[self.ARGS] = "onShouldHideLoadingIndicator"
                self.channel.invokeMethod(self.CALL_LISTENER, arguments: callbackMap)
            },
             onEmbeddedSizeChange: { selectedPlacement, widgetHeight in
                // Optional callback to get selectedPlacement and height required by the placement every time the height of the placement changes
                if let placeholders = args["placeholders"] as? [Int: String] {
                    for (placeholderId, placeholderName) in placeholders {
                        for (id, flutterView) in self.factory.platformViews {
                            if id == placeholderId && placeholderName == selectedPlacement {
                                flutterView.sendUpdatedHeight(height: widgetHeight)
                            }
                        }
                    }
                }
            })
            
            result(SUCCESS)
        } else {
            result(FAIL)
        }
    }
    
    public func logging(_ call: FlutterMethodCall,
                           result: @escaping FlutterResult) {
        
        if let args = call.arguments as? Dictionary<String, Any>{
            let enable = args["enable"] as? Bool ?? false
            Rokt.setLoggingEnabled(enable: enable)
            result(SUCCESS)
        } else {
            result(FAIL)
        }
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

    private func buildRoktConfig(_ config: Dictionary<String, String>) -> RoktConfig {
        let builder = RoktConfig.Builder()
        config["colorMode"].map {
            builder.colorMode($0.toColorMode())
        }
        return builder.build()
    }

    private func handleEvents(_ roktEvent: RoktEvent, viewName: String? = nil) {
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


