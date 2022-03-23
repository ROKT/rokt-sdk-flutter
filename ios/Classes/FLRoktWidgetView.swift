//
//  FLRoktWidgetView.swift
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

class FLRoktWidgetView: NSObject, FlutterPlatformView {
    let roktEmbeddedView: RoktEmbeddedView
    let id: Int64
    let channel: FlutterMethodChannel
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        self.id = viewId
        channel = FlutterMethodChannel(name: "rokt_widget_\(id)", binaryMessenger: messenger)
        roktEmbeddedView = RoktEmbeddedView()
        super.init()
    }
    
    func view() -> UIView {
        return roktEmbeddedView

    }
    
    private func resizeFrame(_ newHeight: Double = 0) {
        roktEmbeddedView.frame = CGRect(x: 0, y: 0, width: roktEmbeddedView.frame.width, height: newHeight)
    }
    
    func sendUpdatedHeight(height: Double){
        var callbackMap = [String: Any] ()
        resizeFrame(height)
        callbackMap["size"] = height
        channel.invokeMethod("viewHeightListener", arguments: callbackMap)
    }
}

