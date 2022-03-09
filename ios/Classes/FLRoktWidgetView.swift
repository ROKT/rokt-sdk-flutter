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
    private var _view: UIView
    private var roktEmbeddedView: RoktEmbeddedView?
    let id: Int64
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        self.id = viewId
        _view = UIView()
        super.init()
        createNativeView(view: _view)
    }
    
    func view() -> UIView {
        return _view
    }
    
    func getRoktEmbeddedPlacement() -> RoktEmbeddedView? {
        // set the width to match parent
        if roktEmbeddedView?.frame.width == 0 {
            roktEmbeddedView?.frame = CGRect(x: 0, y: 0, width: _view.frame.width, height: 0)
        }
        return roktEmbeddedView
    }
    
    func createNativeView(view _view: UIView){
        roktEmbeddedView = RoktEmbeddedView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
         _view.addSubview(roktEmbeddedView!)
    }
}

