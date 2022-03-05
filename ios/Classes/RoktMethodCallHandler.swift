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
    let channel: FlutterMethodChannel
    
    public func initialize(_ call: FlutterMethodCall,
                                  result: @escaping FlutterResult) {
        
        if let args = call.arguments as? Dictionary<String, Any>,
           let roktTagId = args["roktTagId"] as? String {
            Rokt.initWith(roktTagId: roktTagId)
            print(roktTagId)
            result("success")
        } else {
            result("fail")
        }
    }
    
    public func execute(_ call: FlutterMethodCall,
                                  result: @escaping FlutterResult) {
        
        if let args = call.arguments as? Dictionary<String, Any>,
           let viewName = args["viewName"] as? String,
           let attributes = args["attributes"] as? [String: String]{
            
            let callBackId = args["callbackId"] as? Int ?? 0
            var callbackMap = [String: Any] ()
            callbackMap["id"] = callBackId
            Rokt.execute(viewName: viewName, attributes: attributes, onLoad: {
                // Optional callback for when the Rokt placement loads
                print("loaded")
                callbackMap["args"] = "load"
                channel.invokeMethod("callListener", arguments: callbackMap)
            }, onUnLoad: {
                // Optional callback for when the Rokt placement unloads
                print("unloaded")
                callbackMap["args"] = "unload"
                channel.invokeMethod("callListener", arguments: callbackMap)
            }, onShouldShowLoadingIndicator: {
                // Optional callback to show a loading indicator
                callbackMap["args"] = "onShouldShowLoadingIndicator"
                channel.invokeMethod("callListener", arguments: callbackMap)
            }, onShouldHideLoadingIndicator: {
                // Optional callback to hide a loading indicator
                callbackMap["args"] = "onShouldHideLoadingIndicator"
                channel.invokeMethod("callListener", arguments: callbackMap)
            })
            
            result("success")
        } else {
            result("fail")
        }
    }
    
}


