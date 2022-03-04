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

class RoktMethodCallHandler {
    public static func initialize(_ call: FlutterMethodCall,
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
    
    public static func execute(_ call: FlutterMethodCall,
                                  result: @escaping FlutterResult) {
        
        if let args = call.arguments as? Dictionary<String, Any>,
           let viewName = args["viewName"] as? String,
           let attributes = args["attributes"] as? [String: String]{
            
            Rokt.execute(viewName: viewName, attributes: attributes, onLoad: {
                // Optional callback for when the Rokt placement loads
                print("loaded")
            }, onUnLoad: {
                // Optional callback for when the Rokt placement unloads
                print("unloaded")
            }, onShouldShowLoadingIndicator: {
                // Optional callback to show a loading indicator
            }, onShouldHideLoadingIndicator: {
                // Optional callback to hide a loading indicator
            })
            
            result("success")
        } else {
            result("fail")
        }
    }
    
}


