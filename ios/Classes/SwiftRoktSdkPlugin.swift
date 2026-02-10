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
    fileprivate let INIT_METHOD = "initialize"
    fileprivate let SELECT_PLACEMENTS_METHOD = "selectPlacements"
    fileprivate let PURCHASE_FINALIZED_METHOD = "purchaseFinalized"
    fileprivate static let CHANNEL_NAME = "rokt_sdk"
    fileprivate static let VIEW_CALL_DELEGATE = "rokt_sdk.rokt.com/rokt_widget"
    
    let channel: FlutterMethodChannel
    let factory: RoktWidgetFactory
    let registrar: FlutterPluginRegistrar
    let handler: RoktMethodCallHandler
    
    init(channel: FlutterMethodChannel, factory: RoktWidgetFactory, registrar: FlutterPluginRegistrar, handler: RoktMethodCallHandler) {
        self.channel = channel
        self.factory = factory
        self.registrar = registrar
        self.handler = handler
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: registrar.messenger())
        let factory = RoktWidgetFactory(messenger: registrar.messenger())
        let handler = RoktMethodCallHandler(channel: channel, factory: factory, registrar: registrar)
        let instance = SwiftRoktSdkPlugin(channel: channel, factory: factory, registrar: registrar, handler: handler)
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.register(factory, withId: VIEW_CALL_DELEGATE)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == INIT_METHOD {
            handler.initialize(call, result: result)
        } else if call.method == SELECT_PLACEMENTS_METHOD {
            handler.selectPlacements(call, result: result)
        } else if call.method == PURCHASE_FINALIZED_METHOD {
            handler.purchaseFinalized(call, result: result)
        } else {
            result("Not implemented")
        }
    }
}
