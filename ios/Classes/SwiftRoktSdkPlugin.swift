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
    let factory: RoktWidgetFactory
    
    init(channel: FlutterMethodChannel, factory: RoktWidgetFactory) {
        self.channel = channel
        self.factory = factory
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "rokt_sdk", binaryMessenger: registrar.messenger())
        let factory = RoktWidgetFactory(messenger: registrar.messenger())
        let instance = SwiftRoktSdkPlugin(channel: channel, factory: factory)
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.register(factory, withId: "rokt_sdk.rokt.com/rokt_widget")
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let handler = RoktMethodCallHandler(channel: channel, factory: factory)
        if call.method == "initialize" {
            handler.initialize(call, result: result)
            
        } else if call.method == "execute" {
            handler.execute(call, result: result)
        }else {
            result("iOS " + UIDevice.current.systemVersion)
        }
    }
}
