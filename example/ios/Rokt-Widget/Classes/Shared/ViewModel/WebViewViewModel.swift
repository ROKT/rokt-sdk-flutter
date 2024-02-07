//
//  WebViewViewModel.swift
//  Pods
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

struct WebViewViewModel {
    let url: URL!
    let sessionId: String!
    let campaignId: String?
    var lastUrl: String = ""
    
    internal func sendWebViewDiagnostics(_ brokenUrl: URL?, error: Error) {
        RoktAPIHelper.sendDiagnostics(message: kWebViewErrorCode,
                                      callStack: getErrorMessage(brokenUrl, error: error),
                                      sessionId: sessionId, campaignId: campaignId)
    }
    
    internal func getErrorMessage(_ brokenUrl: URL?, error: Error) -> String {
        return "OriginalUrl: " + url.absoluteString +
            " ,brokenUrl: " + (brokenUrl?.absoluteString ?? lastUrl) +
            " " + error.localizedDescription
    }
    
    internal func isSupportedUrl(_ link: String) -> Bool {
        return link.lowercased().hasPrefix(kHttpPrefix) || link.lowercased().hasPrefix(kHttpsPrefix)
    }
}
