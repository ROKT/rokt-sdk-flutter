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

struct RoktMethodCallHandler {
    fileprivate let SUCCESS = "success"
    fileprivate let FAIL = "fail"
    fileprivate let ARGS = "args"
    fileprivate let CALL_LISTENER = "callListener"
    
    let channel: FlutterMethodChannel
    let factory: RoktWidgetFactory
    let registrar: FlutterPluginRegistrar
    
    public func initialize(_ call: FlutterMethodCall,
                           result: @escaping FlutterResult) {
        
        if let args = call.arguments as? Dictionary<String, Any>,
           let roktTagId = args["roktTagId"] as? String {
            let fontFilePathMap = args["fontFilePathMap"] as? Dictionary<String, String>
            if let typefaces = fontFilePathMap {
                registerPartnerFonts(typefaces)
            }
            Rokt.setFrameworkType(frameworkType: .Flutter)
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
            
            let callBackId = args["callbackId"] as? Int ?? 0
            var callbackMap = [String: Any] ()
            callbackMap["id"] = callBackId
            Rokt.execute(viewName: viewName, attributes: attributes, placements: placements, onLoad: {
                // Optional callback for when the Rokt placement loads
                callbackMap[ARGS] = "load"
                channel.invokeMethod(CALL_LISTENER, arguments: callbackMap)
            }, onUnLoad: {
                // Optional callback for when the Rokt placement unloads
                callbackMap[ARGS] = "unload"
                channel.invokeMethod(CALL_LISTENER, arguments: callbackMap)
            }, onShouldShowLoadingIndicator: {
                // Optional callback to show a loading indicator
                callbackMap[ARGS] = "onShouldShowLoadingIndicator"
                channel.invokeMethod(CALL_LISTENER, arguments: callbackMap)
            }, onShouldHideLoadingIndicator: {
                // Optional callback to hide a loading indicator
                callbackMap[ARGS] = "onShouldHideLoadingIndicator"
                channel.invokeMethod(CALL_LISTENER, arguments: callbackMap)
            },
             onEmbeddedSizeChange: { selectedPlacement, widgetHeight in
                // Optional callback to get selectedPlacement and height required by the placement every time the height of the placement changes
                if let placeholders = args["placeholders"] as? [Int: String] {
                    for (placeholderId, placeholderName) in placeholders {
                        for (id, flutterView) in factory.platformViews {
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

}


