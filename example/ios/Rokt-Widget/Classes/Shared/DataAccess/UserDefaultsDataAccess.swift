//
//  UserDefaultsDataAccess.swift
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

class UserDefaultsDataAccess {
    private static let widgetFonts = "RoktWidgetFonts"
    private static let fontQueueLabel = "RoktFontQueue"
    
    class func setFontDetails(key: String, values: [String: String]) {
        UserDefaults.standard.set(values, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func getFontDetails(key: String) -> [String: String]? {
        return UserDefaults.standard.dictionary(forKey: key) as? [String: String]
    }
    
    class func removeFontDetails(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func addToFontArray(key: String) {
        DispatchQueue(label: fontQueueLabel).sync {
            var existingFonts = getFontArray()
            if existingFonts == nil {
                existingFonts = [String]()
            }
            if !existingFonts!.contains(key) {
                existingFonts?.append(key)
            }
            UserDefaults.standard.set(existingFonts, forKey: widgetFonts)
            UserDefaults.standard.synchronize()
        }
    }
    
    class func getFontArray() -> [String]? {
        return UserDefaults.standard.array(forKey: widgetFonts) as? [String]
    }
    
    class func removeFontFromFontArray(key: String) {
        DispatchQueue(label: fontQueueLabel).sync {
            var existingFonts = getFontArray()
            if existingFonts == nil {
                existingFonts = [String]()
            }
            if existingFonts!.contains(key), let index = existingFonts?.firstIndex(of: key) {
                existingFonts!.remove(at: index)
            }
            UserDefaults.standard.set(existingFonts, forKey: widgetFonts)
            UserDefaults.standard.synchronize()
        }
    }
}
