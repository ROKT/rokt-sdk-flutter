//
//  RoktNetworkAPI.swift
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

internal class RoktNetWorkAPI {
    /// Rokt initialize API call
    ///
    /// - Parameters:
    ///   - roktTagId: The tag id provided by Rokt, associated with the client's account
    ///   - success: Function to execute after a successfull call to the API. Returns timeout, delay and fonts
    ///   - failure: Function to execute after an unseccessfull call to the API
    class func initialize(roktTagId: String,
                          success: ((Double, Double, Double?, [FontModel], Bool) -> Void)? = nil,
                          failure: ((Error, Int?, String) -> Void)? = nil) {
           
           NetworkingHelper.performGet(url: kInitResourceUrl,
                                        params: nil,
                                        headers: [BE_TAG_ID_KEY: roktTagId],
                                        extraErrorCheck: true,
                                        success: { (dict, _, _) in
               if let initData = dict as? [String: Any],
                  let clientTimeout = initData[BE_CLIENT_TIMEOUT_KEY] as? Double,
                  let defaultLaunchDelay = initData[BE_DEFAULT_LAUNCH_DELAY_KEY] as? Double,
                  let successCallback = success {
                   let roktTrackingStatus = initData[BE_ROKT_FLAG_KEY] as? Bool ?? true
                   var fonts = [FontModel]()

                   if let fontDicts = initData[BE_FONTS_KEY] as? [[String: String]] {
                       fonts = fontDicts.compactMap({ (fontDict) -> FontModel? in
                           FontModel(fontDict: fontDict)
                       })
                   }
                   
                   let clientSessionTimeout = initData[BE_CLIENT_SESSION_TIMEOUT_KEY] as? Double

                   successCallback(clientTimeout, defaultLaunchDelay, clientSessionTimeout, fonts, roktTrackingStatus)
               }
           }, failure: failure)
       }
       
       /// Rokt donwload fonts API call
       ///
       /// - Parameters:
       ///   - fonts: The fonts that should be downloaded and installed to be used in the widget
    class func downloadFont(font: FontModel, destination: DownloadRequest.DownloadFileDestination?, fileUrl: URL,
                            isLastFont: Bool, retryCount: Int = 0) {
        guard let url = URL(string: font.url) else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = TimeInterval(exactly: defaultFontTimeout)!
        download(urlRequest, to: destination).response { response in
            if response.destinationURL != nil  && response.error == nil {
                FontManager.registerFont(font: font, fileUrl: fileUrl, isDownloaded: true)
            } else if response.error != nil {
                if retryCount < kMaxRetries && NetworkingHelper.retriableResponse(error: response.error!,
                                                                                  code: response.response?.statusCode) {
                    downloadFont(font: font, destination: destination, fileUrl: fileUrl, isLastFont: isLastFont,
                                 retryCount: retryCount + 1)
                    return
                } else {
                    Rokt.shared.isInitialized = false
                    let callstack = "\(kAPIFontErrorMessage) \(font.url), " +
                    "error: \(String(describing: response.error.debugDescription))"
                    RoktAPIHelper.sendDiagnostics(message: kAPIFontErrorCode, callStack: callstack)
                    Log.d(callstack)
                }
            }
            
            if isLastFont {
                NotificationCenter.default.post(Notification(name: Notification.Name(kFinishedDownloadingFonts)))
            }
        }
    }

    /// Rokt widget API call
    ///
    /// - Parameters:
    ///   - params: A string dictionary containing the parameters that should be displayed in the widget
    ///   - roktTagId: The tag id provided by Rokt, associated with the client's account
    ///   - success: Function to execute after a successfull call to the API. Returns timeout, delay and fonts
    ///   - failure: Function to execute after an unseccessfull call to the API
    class func getPlacement(params: [String: Any],
                            roktTagId: String,
                            trackingConsent: UInt?,
                            success: ((PageViewData?) -> Void)? = nil,
                            failure: ((Error, Int?, String) -> Void)? = nil) {
        var headers = getDefaultHeaders(tagId: roktTagId, validSessionRequired: true)
        if let trackingConsent = trackingConsent {
            headers[BE_TRACKING_CONSENT] = "\(trackingConsent)"
        }
        NetworkingHelper.performPost(url: kPlacementResourceUrl,
                                     body: params,
                                     headers: headers,
                                     extraErrorCheck: true,
                                     success: { (_, data, _) in
                                        if let placementResponse = data, let successCallback = success {
                                            successCallback(PageViewData(placementResponseData: placementResponse))
                                        }
                                        
        }, failure: failure)
    }
       
       /// Rokt event API call
       ///
       /// - Parameters:
       ///   - params: A string dictionary containing the parameters that should be displayed in the widget
       ///   - success: Function to execute after a successfull call to the API
       ///   - failure: Function to execute after an unseccessfull call to the API
    class func sendEvent(paramsArray: [[String: Any]],
                         sessionId: String?,
                         success: (() -> Void)? = nil,
                         failure: ((Error, Int?, String) -> Void)? = nil) {
           
        guard let tagId = Rokt.shared.roktTagId else { return }

        NetworkingHelper.performPost(urlString: kEventResourceUrl,
                                     bodyArray: paramsArray,
                                     headers: getDefaultHeaders(tagId: tagId),
                                     success: { (_, _, _)  in
            success?()
        }, failure: { (error, statusCode, response) in
            let callStack: String = "response: \(response) ,statusCode: \(String(describing: statusCode)) " +
            ",error: \(error.localizedDescription)"
            RoktAPIHelper.sendDiagnostics(message: kAPIEventErrorCode, callStack: callStack, sessionId: sessionId)
               Log.d(callStack)
               failure?(error, statusCode, response)
           })
       }
       
       /// Rokt diagnostics API call
       ///
       /// - Parameters:
       ///   - params: A string dictionary containing the parameters that should be displayed in the widget
       ///   - success: Function to execute after a successfull call to the API
       ///   - failure: Function to execute after an unseccessfull call to the API
    class func sendDiagnostics(params: [String: Any],
                               success: (() -> Void)? = nil,
                               failure: ((Error, Int?, String) -> Void)? = nil) {
           
        guard let tagId = Rokt.shared.roktTagId else { return }
        NetworkingHelper.performPost(url: kDiagnosticsResourceUrl,
                                     body: params,
                                     headers: getDefaultHeaders(tagId: tagId),
                                     success: { (_, _, _) in
            success?()
        }, failure: failure)
    }
    
    private class func getDefaultHeaders(tagId: String, validSessionRequired: Bool = false) -> [String: String] {
        var headers: [String: String] = [BE_TAG_ID_KEY: tagId]
        if let sessionId = Rokt.shared.executeSession?.getSessionId(validSessionRequired: validSessionRequired),
           !sessionId.isEmpty {
            headers[BE_HEADER_SESSION_ID_KEY] = sessionId
        }
        return headers
    }

    /// Fetch the Rokt `v1/experience` payload that returns either placements
    ///     or layouts based on `rokt-experience-type` header
    /// - Parameters:
    ///   - params: A string dictionary containing the parameters that should be displayed in the widget
    ///   - roktTagId: The tag id provided by Rokt, associated with the client's account
    ///   - successPlacement: Function to execute after a successfull call to the API. Returns timeout, delay and fonts.
    ///         Executed if placements is returned. `rokt-experience-type` is
    ///         either nonexistent or equal to `placements`
    ///   - successLayout: Function to execute after a successfull call to the API. Returns timeout, delay and fonts.
    ///         Executed if DCUI layouts is returned. Executed if placements is returned. `rokt-experience-type` is
    ///         either nonexistent or equal to `layouts`
    ///   - trackingConsent: Whether the user wants to be tracked via `ATTrackingManager`
    ///   - failure: Function to execute after an unseccessfull call to the API
    @available(iOS 13, *)
    static func getExperienceData(
        params: [String: Any],
        roktTagId: String,
        trackingConsent: UInt?,
        successPlacement: ((PageViewData?) -> Void)? = nil,
        successLayout: ((PageModel?) -> Void)? = nil,
        failure: ((Error, Int?, String) -> Void)? = nil
    ) {
        var headers = getDefaultHeaders(tagId: roktTagId, validSessionRequired: true)
        if let trackingConsent = trackingConsent {
            headers[BE_TRACKING_CONSENT] = "\(trackingConsent)"
        }

        headers[kLayoutsSchemaVersionHeader] = kLayoutsSchemaVersion

        NetworkingHelper.performPost(
            url: kExperiencesResourceURL,
            body: params,
            headers: headers,
            extraErrorCheck: true,
            success: { (_, data, responseHeaders) in
                let responseType = PlacementAndLayoutHeaderBridge.dataResponseFor(responseHeaders: responseHeaders)

                switch responseType {
                case .placements:
                    if let data, let successPlacement {
                        successPlacement(PageViewData(placementResponseData: data))
                    }
                case .layouts:
                    if let data, let successLayout {
                        do {
                            let experienceResponse = try JSONDecoder().decode(ExperienceResponse.self, from: data)
                            
                            guard let outerlayoutSchema = experienceResponse.getPageModel()
                            else {
                                successLayout(nil)
                                return
                            }
                            successLayout(outerlayoutSchema)
                        } catch(let error){
                            Log.d(kParsingLayoutError + error.localizedDescription)
                            RoktAPIHelper.sendDiagnostics(message: kValidationErrorCode,
                                                          callStack: kParsingLayoutError + error.localizedDescription)
                        }
                    }
                }
            },
            failure: failure)
    }
}
