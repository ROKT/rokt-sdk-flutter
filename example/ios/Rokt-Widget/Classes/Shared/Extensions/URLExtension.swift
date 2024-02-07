//
//  URLExtension.swift
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

internal extension URL {
    
    func isWebURL() -> Bool {
        return URL.isWebURL(url: self.absoluteString)
    }
    
    static func isWebURL(url: String) -> Bool {
        return url.lowercased().hasPrefix(kHttpPrefix) || url.lowercased().hasPrefix(kHttpsPrefix)
    }
}
