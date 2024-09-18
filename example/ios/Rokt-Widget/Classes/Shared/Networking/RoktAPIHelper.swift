//
//  RoktAPIHelper.swift
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
import UIKit

/// Helper class to request and process Rokt api response details
internal class RoktAPIHelper {
    /// Rokt initialize API call
    ///
    /// - Parameters:
    ///   - roktTagId: The tag id provided by Rokt, associated with the client's account
    ///   - success: Function to execute after a successfull call to the API.
    ///              Returns timeout, delay, session timeout and fonts
    ///   - failure: Function to execute after an unseccessfull call to the API
    class func initialize(roktTagId: String,
                          success: ((InitRespose) -> Void)? = nil,
                          failure: ((Error, Int?, String) -> Void)? = nil) {
        if isMock() {
            RoktMockAPI.initialize(roktTagId: roktTagId, success: success, failure: failure)
        } else {
            RoktNetWorkAPI.initialize(roktTagId: roktTagId, success: success, failure: failure)
        }
    }

    /// Rokt donwload fonts API call
    ///
    /// - Parameters:
    ///   - fonts: The fonts that should be downloaded and installed to be used in the widget
    class func downloadFonts(_ fonts: [FontModel]) {
        FontManager.downloadFonts(fonts)
    }

    /// Rokt Placement API call
    ///
    /// - Parameters:
    ///   - viewName: The name that should be displayed in the widget
    ///   - attributes: A string dictionary containing the parameters that should be displayed in the widget
    ///   - roktTagId: The tag id provided by Rokt, associated with the client's account
    ///   - successPlacement: Function to execute after a successfull PLACEMENT call to the API
    ///   - successLayout: Function to execute after a successfull LAYOUTS call to the API
    ///   - failure: Function to execute after an unseccessfull call to the API
    @available(iOS 15, *)
    class func getExperienceData(viewName: String?,
                                 attributes: [String: Any],
                                 roktTagId: String,
                                 trackingConsent: UInt?,
                                 config: RoktConfig?,
                                 onRequestStart: (() -> Void)?,
                                 successPlacement: ((PageViewData?) -> Void)? = nil,
                                 successLayout: ((PageModel?) -> Void)? = nil,
                                 failure: ((Error, Int?, String) -> Void)? = nil) {
        // extract the privacy KVPs BEFORE sanitising `attributes`
        let privacyControlPayload = getPrivacyControlPayload(attributes: attributes)
        
        // extract the pageInit timestamp, if available
        if let pageInitAttr = getPageInitData(attributes: attributes),
           let validPageInitTime = Rokt.shared.processedTimingsRequests?.getValidPageInitTime(pageInitAttr) {
            Rokt.shared.processedTimingsRequests?.setPageInitTime(validPageInitTime)
        }

        let mutableAttributes = appendColorModeIfDoesNotExist(attributes: attributes, config: config)
        let sanitisedAttributes = removeAttributesToSanitise(attributes: mutableAttributes)

        var params: [String: Any] = [
            BE_ATTRIBUTES_KEY: sanitisedAttributes
        ]

        if let vName = viewName {
            params[BE_VIEW_NAME_KEY] = vName
        }

        if !privacyControlPayload.isEmpty {
            params[BE_PRIVACY_CONTROL_KEY] = privacyControlPayload
        }

        if isMock() {
            RoktMockAPI.getExperienceData(
                params: params,
                roktTagId: roktTagId,
                trackingConsent: trackingConsent,
                onRequestStart: onRequestStart,
                successPlacement: successPlacement,
                successLayout: successLayout,
                failure: failure
            )
        } else {
            RoktNetWorkAPI.getExperienceData(
                params: params,
                roktTagId: roktTagId,
                trackingConsent: trackingConsent,
                onRequestStart: onRequestStart,
                successPlacement: successPlacement,
                successLayout: successLayout,
                failure: failure
            )
        }
    }

    /// Rokt Placement API call
    ///
    /// - Parameters:
    ///   - viewName: The name that should be displayed in the widget
    ///   - attributes: A string dictionary containing the parameters that should be displayed in the widget
    ///   - roktTagId: The tag id provided by Rokt, associated with the client's account
    ///   - success: Function to execute after a successfull call to the API
    ///   - failure: Function to execute after an unseccessfull call to the API
    class func getPlacement(viewName: String?,
                            attributes: [String: Any],
                            roktTagId: String,
                            trackingConsent: UInt?,
                            success: ((PageViewData?) -> Void)? = nil,
                            failure: ((Error, Int?, String) -> Void)? = nil) {
        // extract the privacy KVPs BEFORE sanitising `attributes`
        let privacyControlPayload = getPrivacyControlPayload(attributes: attributes)
        let sanitisedAttributes = removeAttributesToSanitise(attributes: attributes)

        var params: [String: Any] = [BE_ATTRIBUTES_KEY: sanitisedAttributes]

        if let vName = viewName {
            params[BE_VIEW_NAME_KEY] = vName
        }

        if !privacyControlPayload.isEmpty {
            params[BE_PRIVACY_CONTROL_KEY] = privacyControlPayload
        }

        if isMock() {
            RoktMockAPI.getPlacement(
                params: params,
                roktTagId: roktTagId,
                trackingConsent: trackingConsent,
                success: success,
                failure: failure
            )
        } else {
            RoktNetWorkAPI.getPlacement(
                params: params,
                roktTagId: roktTagId,
                trackingConsent: trackingConsent,
                success: success,
                failure: failure
            )
        }
    }

    /// Rokt event API call
    ///
    /// - Parameters:
    ///   - evenRequest: The EventRequest related to the event
    ///   - success: Function to execute after a successfull call to the API
    ///   - failure: Function to execute after an unseccessfull call to the API
    class func sendEvent(evenRequest: EventRequest,
                         success: (() -> Void)? = nil,
                         failure: ((Error, Int?, String) -> Void)? = nil) {
        guard Rokt.shared.roktTagId != nil,
              Rokt.shared.processedEvents.insertProcessedEvent(evenRequest)
        else { return }

        EventQueue.call(event: evenRequest) { events in
            var eventsBody = [[String: Any]]()
            for event in events {
                eventsBody.append(event.getParams())
                if kEventsLoggingEnabled {
                    NSLog(event.getLog())
                }
            }

            if isMock() {
                RoktMockAPI.sendEvent(paramsArray: eventsBody, sessionId: evenRequest.sessionId,
                                      success: success, failure: failure)
            } else {
                RoktNetWorkAPI.sendEvent(paramsArray: eventsBody, sessionId: evenRequest.sessionId,
                                         success: success, failure: failure)
            }
        }

    }

    /// Rokt diagnostics API call
    ///
    /// - Parameters:
    ///   - message: The message related to the error
    ///   - callStack: The call stack or more information related to the error
    ///   - severity: severity of the error
    ///   - success: Function to execute after a successfull call to the API
    ///   - failure: Function to execute after an unseccessfull call to the API
    class func sendDiagnostics(message: String,
                               callStack: String,
                               severity: Severity = .error,
                               sessionId: String? = nil,
                               campaignId: String? = nil,
                               success: (() -> Void)? = nil,
                               failure: ((Error, Int?, String) -> Void)? = nil) {
        guard Rokt.shared.roktTagId != nil else { return }

        var params: [String: Any] = [BE_ERROR_CODE_KEY: message,
                                     BE_ERROR_STACK_TRACE_KEY: callStack,
                                     BE_ERROR_SEVERITY_KEY: severity.rawValue]
        var additional: [String: Any] = [:]
        if let sessionId = sessionId {
            additional[BE_ERROR_SESSIONID_KEY] = sessionId
        }
        if let campaignId = campaignId {
            additional[BE_ERROR_CAMPAIGNID_KEY] = campaignId
        }
        if !additional.isEmpty {
            params[BE_ERROR_ADDITIONAL_KEY] = additional
        }
        if isMock() {
            RoktMockAPI.sendDiagnostics(params: params, success: success, failure: failure)
        } else {
            RoktNetWorkAPI.sendDiagnostics(params: params, success: success, failure: failure)
        }
    }

    class func sendDedupedFontDiagnostics(_ fontFamily: String) {
        guard Rokt.shared.fontDiagnostics.insertProcessedFontDiagnostics(fontFamily) else {
            return
        }
        sendDiagnostics(message: kViewErrorCode,
                        callStack: kUIFontErrorMessage + fontFamily)
    }

    private class func isMock() -> Bool {
        return config.environment == .Mock
    }
    
    /// Rokt timings collection API call
    ///
    /// - Parameters:
    ///   - timingsRequest: TimingsRequest object of containing metadata and collected timings
    class func sendTimings(_ timingsRequest: TimingsRequest,
                           sessionId: String?) {
        guard Rokt.shared.initFeatureFlags.isEnabled(.timingsEnabled),
              Rokt.shared.roktTagId != nil
        else { return }

        if isMock() {
            RoktMockAPI.sendTimings(timingsRequest: timingsRequest)
        } else {
            RoktNetWorkAPI.sendTimings(timingsRequest: timingsRequest, sessionId: sessionId)
        }
    }
}
