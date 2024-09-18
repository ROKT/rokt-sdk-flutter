//
//  RoktConfig.swift
//  Rokt-Widget
//
//  Copyright 2020 Rokt Pte Ltd
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation

@objc public class RoktConfig: NSObject {
    let colorMode: ColorMode
    
    private init(colorMode: ColorMode) {
        self.colorMode = colorMode
    }
    
    @objc public enum ColorMode: Int {
        case light
        case dark
        case system
    }
    
    @objc public class Builder: NSObject {
        var colorMode: ColorMode?
        
        @objc public func colorMode(_ colorMode: ColorMode) -> Builder {
            self.colorMode = colorMode
            return self
        }
        
        @objc public func build() -> RoktConfig {
            return RoktConfig(colorMode: colorMode ?? .system)
        }
        
    }
}
