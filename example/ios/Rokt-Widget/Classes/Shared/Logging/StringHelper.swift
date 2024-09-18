//
//  StringHelper.swift
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

/// String helper class to get localized versions of strings
class StringHelper {
    class func localizedStringFor(_ key: String, comment: String) -> String {
        let podBundle = Bundle(for: Rokt.self)
        if let bundleURL = podBundle.url(forResource: kBundleName, withExtension: kBundleExtension),
           let bundle = Bundle(url: bundleURL) {

            return NSLocalizedString(key, bundle: bundle, comment: comment)
        }
        return ""
    }
}
