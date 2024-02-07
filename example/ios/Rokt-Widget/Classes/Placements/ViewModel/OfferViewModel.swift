//
//  OfferViewModel.swift
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
//

import Foundation

class OfferViewModel {
    var sessionId: String!
    let urlInExternalBrowser: Bool
    
    init(_ sessionId: String, urlInExternalBrowser: Bool) {
        self.sessionId = sessionId
        self.urlInExternalBrowser = urlInExternalBrowser
    }
    
    internal func sendWebViewDiagnostics(){
        RoktAPIHelper.sendDiagnostics(message: kWebViewErrorCode, callStack: kStaticPageError,
                                      sessionId: sessionId)
    }
    
    internal func sendImpressionEvent(_ creativeInstanceGuid: String?) {
        if let creativeInstanceGuid = creativeInstanceGuid {
            RoktAPIHelper.sendEvent(evenRequest:
                EventRequest(sessionId: sessionId, eventType: .SignalImpression,
                             parentGuid: creativeInstanceGuid ))
        }
    }
    
    internal func getImageMaxHeight(_ imageMaxHeight: Float?) -> Float {
        return imageMaxHeight ?? kImageOfferHeight
    }
    
}

