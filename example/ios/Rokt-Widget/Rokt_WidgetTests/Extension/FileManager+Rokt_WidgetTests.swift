//
//  FileManager+Rokt_WidgetTests.swift
//  Rokt_WidgetTests
//
//  Copyright 2020 Rokt Pte Ltd
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/
//

import Foundation

extension FileManager {
    static let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)

    static let testDirectoryURL = temporaryDirectoryURL.appendingPathComponent("com.rokt.test.unit")

    @discardableResult
    static func createDirectoryAt(path: String) -> Bool {
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            return false
        }
    }

    static func temporaryFileURL() -> URL {
        FileManager.testDirectoryURL.appendingPathComponent(UUID().uuidString)
    }

    @discardableResult
    static func removeItem(atPath path: String) -> Bool {
        do {
            try FileManager.default.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }

    @discardableResult
    static func removeItem(at url: URL) -> Bool {
        removeItem(atPath: url.path)
    }

    @discardableResult
    static func removeAllItemsInsideDirectory(atPath path: String) -> Bool {
        let enumerator = FileManager.default.enumerator(atPath: path)
        var result = true

        while let fileName = enumerator?.nextObject() as? String {
            let success = removeItem(atPath: path + "/\(fileName)")
            if !success { result = false }
        }

        return result
    }

    @discardableResult
    static func removeAllItemsInsideDirectory(url: URL) -> Bool {
        removeAllItemsInsideDirectory(atPath: url.path)
    }
}
