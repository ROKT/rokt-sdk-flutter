//
//  NetworkingHelper.swift
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

import UIKit

typealias ResponseHeaders = [AnyHashable: Any]

/// Networking helper class that makes HTTP requests
class NetworkingHelper {
    static let shared = NetworkingHelper()

    internal var httpClient: HTTPClientAdapter!

    private init() {
        self.httpClient = createHTTPClient()
    }

    private func createHTTPClient(timeout: Double = 7) -> RoktHTTPClient {
        let configuration = URLSessionConfiguration.default

        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData

        return RoktHTTPClient(sessionConfiguration: configuration)
    }

    class func updateTimeout(timeout: Double) {
        shared.httpClient.updateTimeout(timeout: timeout)
    }

    class func performPost(url: String,
                           body: [String: Any]?,
                           headers: [String: String]? = nil,
                           extraErrorCheck: Bool = false,
                           onRequestStart: (() -> Void)? = nil,
                           success: ((NSDictionary, Data?, ResponseHeaders?) -> Void)? = nil,
                           failure: ((Error, Int?, String) -> Void)? = nil,
                           retryCount: Int = 0) {
        guard let resolvedClient = shared.httpClient as? RoktHTTPClient else { return }

        resolvedClient.startRequestWith(
            urlAddress: url,
            method: .post,
            parameters: body,
            parameterArray: nil,
            headers: getCommonHeaders(headers),
            onRequestStart: onRequestStart,
            completionHandler: { requestResult in
                processHTTPRequestResult(httpResult: requestResult, 
                                         success: success) { error, errorCode, errorReponse in
                    if retriableResponse(
                        error: error,
                        code: errorCode,
                        extraErrorCheck: extraErrorCheck
                    ) && retryCount < kMaxRetries {
                        performPost(url: url,
                                    body: body,
                                    headers: headers,
                                    extraErrorCheck: extraErrorCheck,
                                    onRequestStart: onRequestStart,
                                    success: success,
                                    failure: failure,
                                    retryCount: retryCount + 1)
                    } else {
                        failure?(error, errorCode, errorReponse)
                    }
                }
            })
    }

    class func performPost(urlString: String,
                           bodyArray: [[String: Any]]?,
                           headers: [String: String]? = nil,
                           extraErrorCheck: Bool = false,
                           onRequestStart: (() -> Void)? = nil,
                           success: ((NSDictionary, Data?, ResponseHeaders?) -> Void)? = nil,
                           failure: ((Error, Int?, String) -> Void)? = nil,
                           retryCount: Int = 0) {
        guard let resolvedClient = shared.httpClient as? RoktHTTPClient else { return }

        resolvedClient.startRequestWith(
            urlAddress: urlString,
            method: .post,
            parameters: nil,
            parameterArray: bodyArray,
            headers: getCommonHeaders(headers),
            onRequestStart: onRequestStart
        ) { requestResult in
            processHTTPRequestResult(httpResult: requestResult, success: success) { error, errorCode, errorReponse in
                if retriableResponse(
                    error: error,
                    code: errorCode,
                    extraErrorCheck: extraErrorCheck
                ) && retryCount < kMaxRetries {
                    performPost(urlString: urlString,
                                bodyArray: bodyArray,
                                headers: headers,
                                extraErrorCheck: extraErrorCheck,
                                onRequestStart: onRequestStart,
                                success: success,
                                failure: failure,
                                retryCount: retryCount + 1)
                } else {
                    failure?(error, errorCode, errorReponse)
                }
            }
        }
    }

    class func performGet(
        url: String,
        params: [String: Any]?,
        headers: [String: String]? = nil,
        extraErrorCheck: Bool = false,
        success: ((NSDictionary, Data?, ResponseHeaders?) -> Void)? = nil,
        failure: ((Error, Int?, String) -> Void)? = nil,
        retryCount: Int = 0
    ) {
        guard let resolvedClient = shared.httpClient as? RoktHTTPClient else { return }

        resolvedClient.startRequestWith(
            urlAddress: url,
            method: .get,
            parameters: params,
            parameterArray: nil,
            headers: getCommonHeaders(headers),
            completionHandler: { requestResult in
                processHTTPRequestResult(httpResult: requestResult, 
                                         success: success) { error, errorCode, errorReponse in
                    if retriableResponse(
                        error: error,
                        code: errorCode,
                        extraErrorCheck: extraErrorCheck
                    ) && retryCount < kMaxRetries {
                        performGet(url: url,
                                   params: params,
                                   headers: headers,
                                   extraErrorCheck: extraErrorCheck,
                                   success: success,
                                   failure: failure,
                                   retryCount: retryCount + 1)
                    } else {
                        failure?(error, errorCode, errorReponse)
                    }
                }
            })
    }

    class internal func retriableResponse(error: Error, code: Int?, extraErrorCheck: Bool = false) -> Bool {
        if error._code == NSURLErrorTimedOut {
            return true
        }

        if let c = code,
           c == HTTP_ERROR_INTERNAL ||
            c == HTTP_ERROR_BAD_GATEWAY ||
            c == HTTP_ERROR_SERVER_NOT_AVAILABLE {
            return true
        }

        if extraErrorCheck && (error._code == NSURLErrorNetworkConnectionLost ||
                                error._code == NSURLErrorCannotFindHost ||
                                error._code == NSURLErrorCannotConnectToHost ||
                                error._code == NSURLErrorNotConnectedToInternet ||
                                error._code == NSURLErrorDNSLookupFailed ||
                                error._code == NSURLErrorResourceUnavailable) {
            return true
        }

        return false
    }

    class internal func getCommonHeaders(_ headers: [String: String]?) -> [String: String] {
        var headersDict = [String: String]()
        if let existingHeaders = headers {
            for (key, value) in existingHeaders {
                headersDict.updateValue(value, forKey: key)
            }
        }

        headersDict.updateValue(kJsonAccept, forKey: kAcceptHeader)
        headersDict.updateValue(kJsonAccept, forKey: kContentType)
        headersDict.updateValue(kLibraryVersion, forKey: BE_SDK_VERSION_KEY)
        headersDict.updateValue(kOSType, forKey: BE_OS_TYPE_KEY)
        headersDict.updateValue(UIDevice.current.systemVersion, forKey: BE_OS_VERSION_KEY)
        headersDict.updateValue(UIDevice.modelName, forKey: BE_DEVICE_MODEL_KEY)
        headersDict.updateValue(Bundle.main.bundleIdentifier!, forKey: BE_PACKAGE_NAME_KEY)
        headersDict.updateValue(Locale.current.identifier, forKey: BE_UI_LOCALE_KEY)

        if let version = Bundle.main.infoDictionary?[kBundleShort]  as? String {
            headersDict.updateValue(version, forKey: BE_PACKAGE_VERSION_KEY)
        }

        return headersDict
    }

    // Gets the response dictionary from the response and calls the appropiate callback
    class private func processHTTPRequestResult(
        httpResult: RoktHTTPRequestResult,
        success: ((NSDictionary, Data?, (ResponseHeaders?)) -> Void)?,
        failure: ((Error, Int?, String) -> Void)?
    ) {
        switch httpResult.jsonSerialisedResponseData {
        case .success(let resultAny):
            var dict = [:] as NSDictionary

            if let responseDict = resultAny as? NSDictionary {
                dict = responseDict
            } else if let array = resultAny as? NSArray {
                dict = [kArrayResponseKey: array]
            }

            success?(dict, httpResult.responseData, httpResult.httpURLResponse?.allHeaderFields)
        case .failure(let error):
            if let statusCode = httpResult.httpURLResponse?.statusCode {
                if statusCode == NSURLErrorNotConnectedToInternet {
                    Log.d(StringHelper.localizedStringFor(kNetworkErrorKey, comment: kNetworkErrorComment))
                    return
                } else if statusCode == HTTP_ERROR_UNAUTHORIZED {
                    Log.d(StringHelper.localizedStringFor(kUnauthorizedKey, comment: kUnauthorizedComment))
                    return
                }
            }

            Log.d(httpResult.httpURLResponse?.description
                    ?? StringHelper.localizedStringFor(kApiErrorKey, comment: kApiErrorC))
            Log.d(error.localizedDescription)

            var responseString: String?

            if let responseData = httpResult.responseData {
                responseString = String(data: responseData, encoding: String.Encoding.utf8)
                if responseString == "" {
                    responseString = kEmptyResponse
                }

                let errorString = error.localizedDescription
                let apiResponseString = StringHelper.localizedStringFor(kApiResponseKey, comment: kApiResponseComment)
                let status = "\(apiResponseString) \(errorString) \(responseString ?? "")"

                Log.d(status)
            }
            failure?(error, httpResult.httpURLResponse?.statusCode, responseString ?? kNoResponse)
        }
    }
}

// MARK: - File download
extension NetworkingHelper {
    func downloadFile(
        source urlAddress: String,
        destinationURL: URL,
        options: [RoktDownloadOptions] = RoktDownloadOptions.allCases,
        parameters: RoktHTTPParameters? = nil,
        headers: RoktHTTPHeaders? = nil,
        requestTimeout: TimeInterval? = nil,
        completionHandler: ((RoktDownloadResult) -> Void)?
    ) {
        guard let resolvedClient = httpClient as? RoktHTTPClient else { return }

        resolvedClient.downloadFile(
            source: urlAddress,
            destinationURL: destinationURL,
            options: options,
            parameters: parameters,
            headers: headers,
            requestTimeout: requestTimeout,
            completionHandler: completionHandler
        )
    }
}
