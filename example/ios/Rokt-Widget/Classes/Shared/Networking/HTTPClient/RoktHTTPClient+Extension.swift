//
//  RoktHTTPClient+Extension.swift
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

internal enum RoktHTTPMethod: String {
    case get
    case post

    var asURLHTTPMethod: String { rawValue.uppercased() }
}

internal typealias RoktHTTPHeaders = [String: String]
internal typealias RoktHTTPParameters = [String: Any]
internal typealias RoktHTTPParameterArray = [[String: Any]]

internal struct RoktHTTPRequestResult {
    let httpURLResponse: HTTPURLResponse?
    let responseData: Data?
    let responseError: Error?
    let jsonSerialisedResponseData: Swift.Result<Any, Error>
}

internal struct RoktDownloadResult {
    let httpURLResponse: HTTPURLResponse?
    let downloadedFileLocalURL: URL?
    let downloadError: Error?
}
