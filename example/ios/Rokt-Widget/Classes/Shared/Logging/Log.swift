//
//  Log.swift
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

/// Helper Logging struct
struct Log {
    /// Prints in build and stage only
    static func d(_ msg: String, line: Int = #line, fileName: String = #file, funcName: String = #function) {
        if let configuration = Bundle(for: Rokt.self).object(forInfoDictionaryKey: "Configuration") as? String {
            if configuration.contains("STAGE") ||
                configuration.contains("MOCK") ||
                config.environment == .Local ||
                config.environment == .Stage {
                let fname = (fileName as NSString).lastPathComponent
                print("[\(fname) \(funcName):\(line)]", msg)
            }
        }
    }
    /// Prints in debug only if debug enabled
    static func i(_ msg: String) {
        if Rokt.shared.debugLogEnabled {
            #if DEBUG
                print(msg)
            #endif
        }
    }
    
    /// Prints an error message in debug only
    static func error(_ msg: String, line: Int = #line, fileName: String = #file, funcName: String = #function) {
        d("ERROR: \(msg)!!", line: line, fileName: fileName, funcName: funcName)
    }
}
