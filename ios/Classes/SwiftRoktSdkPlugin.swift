//
//  SwiftRoktSdkPlugin.swift
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

public class SwiftRoktSdkPlugin: NSObject, FlutterPlugin {
    let channel: FlutterMethodChannel
    
    public init(channel: FlutterMethodChannel) {
        self.channel = channel
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "rokt_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftRoktSdkPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let handler = RoktMethodCallHandler(channel: channel)
        if call.method == "initialize" {
            handler.initialize(call, result: result)
            
        } else if call.method == "execute" {
            handler.execute(call, result: result)
        }else {
            result("iOS " + UIDevice.current.systemVersion)
        }
    }
}
