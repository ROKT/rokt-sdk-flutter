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
import Rokt_Widget

@objc(RoktSdkPlugin)
public class SwiftRoktSdkPlugin: NSObject, FlutterPlugin {
    /// Host apps set this closure in AppDelegate to provide payment extension instances.
    /// The factory receives the extension type (e.g. "stripe") and a config dictionary,
    /// and returns a fully constructed `PaymentExtension` or `nil`.
    public static var paymentExtensionFactory: ((_ type: String, _ config: [String: String]) -> PaymentExtension?)?

    fileprivate let INIT_METHOD = "initialize"
    fileprivate let SET_CUSTOM_BASE_URL_METHOD = "setCustomBaseURL"
    fileprivate let SELECT_PLACEMENTS_METHOD = "selectPlacements"
    fileprivate let SELECT_SHOPPABLE_ADS_METHOD = "selectShoppableAds"
    fileprivate let REGISTER_PAYMENT_EXTENSION_METHOD = "registerPaymentExtension"
    fileprivate let PURCHASE_FINALIZED_METHOD = "purchaseFinalized"
    fileprivate let SET_SESSION_ID_METHOD = "setSessionId"
    fileprivate let GET_SESSION_ID_METHOD = "getSessionId"
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
        _ = warnIfSDKLoadedTwice
        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: registrar.messenger())
        let factory = RoktWidgetFactory(messenger: registrar.messenger())
        let handler = RoktMethodCallHandler(channel: channel, factory: factory, registrar: registrar)
        let instance = SwiftRoktSdkPlugin(channel: channel, factory: factory, registrar: registrar, handler: handler)
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.register(factory, withId: VIEW_CALL_DELEGATE)
    }

    // Getting the Rokt SDK from both CocoaPods and Swift Package Manager links a second copy. That
    // builds cleanly, then misbehaves at runtime. Rokt is a Swift class with no Objective-C name of its
    // own, so the runtime reports it by its demangled name. Runs once.
    private static let warnIfSDKLoadedTwice: Void = {
        let duplicates = imageCounts(forClassNames: ["Rokt_Widget.Rokt", "RoktEmbeddedView"])
            .filter { $0.value > 1 }
            .map { "\($0.key) x\($0.value)" }
            .sorted()
        if !duplicates.isEmpty {
            NSLog("[Rokt] The Rokt SDK is loaded more than once (%@). This happens when it comes from both CocoaPods and Swift Package Manager: remove the Rokt pods from your Podfile. See the iOS section of the rokt_sdk README.", duplicates.joined(separator: ", "))
        }
    }()

    // Counts, per class name, the loaded images inside the app bundle that define it. System images
    // are skipped: scanning them all takes seconds, the bundle takes milliseconds.
    private static func imageCounts(forClassNames names: [String]) -> [String: Int] {
        var counts = Dictionary(uniqueKeysWithValues: names.map { ($0, 0) })
        let bundlePath = Bundle.main.bundlePath
        var imageCount: UInt32 = 0
        let images = objc_copyImageNames(&imageCount)
        defer { free(images) }
        for i in 0..<Int(imageCount) where String(cString: images[i]).hasPrefix(bundlePath) {
            var classCount: UInt32 = 0
            guard let classes = objc_copyClassNamesForImage(images[i], &classCount) else { continue }
            defer { free(classes) }
            for j in 0..<Int(classCount) {
                let name = String(cString: classes[j])
                if let count = counts[name] { counts[name] = count + 1 }
            }
        }
        return counts
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == INIT_METHOD {
            handler.initialize(call, result: result)
        } else if call.method == SET_CUSTOM_BASE_URL_METHOD {
            handler.setCustomBaseURL(call, result: result)
        } else if call.method == SELECT_PLACEMENTS_METHOD {
            handler.selectPlacements(call, result: result)
        } else if call.method == SELECT_SHOPPABLE_ADS_METHOD {
            handler.selectShoppableAds(call, result: result)
        } else if call.method == REGISTER_PAYMENT_EXTENSION_METHOD {
            handler.registerPaymentExtension(call, result: result)
        } else if call.method == PURCHASE_FINALIZED_METHOD {
            handler.purchaseFinalized(call, result: result)
        } else if call.method == SET_SESSION_ID_METHOD {
            handler.setSessionId(call, result: result)
        } else if call.method == GET_SESSION_ID_METHOD {
            handler.getSessionId(call, result: result)
        } else {
            result("Not implemented")
        }
    }
}
