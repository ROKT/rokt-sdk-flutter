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
    internal var manager: SessionManager!
    
    private init() {
        self.manager = createManager()
    }
    
    // Creates a session manager with custom timeout
    private func createManager(timeout: Double = 7) -> SessionManager {
        let configuration = URLSessionConfiguration.default
        
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        return SessionManager(configuration: configuration)
    }    
    
    // Updates the custom timeout for the session manager
    class func updateTimeout(timeout: Double) {
        shared.manager.session.configuration.timeoutIntervalForRequest = timeout
        shared.manager.session.configuration.timeoutIntervalForResource = timeout
    }
    
    class func performPost(url: String,
                           body: [String: Any]?,
                           headers: [String: String]? = nil,
                           extraErrorCheck: Bool = false,
                           success: ((NSDictionary, Data?, ResponseHeaders?) -> Void)? = nil,
                           failure: ((Error, Int?, String) -> Void)? = nil,
                           retryCount: Int = 0) {
        shared.manager.request(url,
                               method: .post,
                               parameters: body,
                               encoding: JSONEncoding.default,
                               headers: getCommonHeaders(headers)).validate()
            .responseJSON { response in
                processResponse(response: response, success: success, failure: { (error, code, response) in
                    if retriableResponse(error: error, code: code,
                                         extraErrorCheck: extraErrorCheck) && retryCount < kMaxRetries {
                        performPost(url: url,
                                    body: body,
                                    headers: headers,
                                    extraErrorCheck: extraErrorCheck,
                                    success: success,
                                    failure: failure,
                                    retryCount: retryCount + 1)
                    } else {
                        failure?(error, code, response)
                    }
                })
        }
    }
    
    class func performPost(urlString: String,
                           bodyArray: [[String: Any]]?,
                           headers: [String: String]? = nil,
                           extraErrorCheck: Bool = false,
                           success: ((NSDictionary, Data?, ResponseHeaders?) -> Void)? = nil,
                           failure: ((Error, Int?, String) -> Void)? = nil,
                           retryCount: Int = 0) {
        guard let url = URL(string: urlString) else {return}
        var request = URLRequest(url: url)
        request.httpMethod = kPost
        
        for (key, value) in getCommonHeaders(headers) {
            request.setValue(value, forHTTPHeaderField: key)
        }
        if let bodyArray = bodyArray {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: bodyArray, options: [])
            } catch {}
        }

        shared.manager.request(request).validate()
            .responseJSON { response in
                processResponse(response: response, success: success, failure: { (error, code, response) in
                    if retriableResponse(error: error, code: code,
                                         extraErrorCheck: extraErrorCheck) && retryCount < kMaxRetries {
                        performPost(urlString: urlString,
                                    bodyArray: bodyArray,
                                    headers: headers,
                                    extraErrorCheck: extraErrorCheck,
                                    success: success,
                                    failure: failure,
                                    retryCount: retryCount + 1)
                    } else {
                        failure?(error, code, response)
                    }
                })
        }
    }
    
    class func performGet(url: String,
                          params: [String: Any]?,
                          headers: [String: String]? = nil,
                          extraErrorCheck: Bool = false,
                          success: ((NSDictionary, Data?, ResponseHeaders?) -> Void)? = nil,
                          failure: ((Error, Int?, String) -> Void)? = nil,
                          retryCount: Int = 0) {
        shared.manager.request(url,
                               method: .get,
                               parameters: params,
                               encoding: URLEncoding.default,
                               headers: getCommonHeaders(headers)).validate()
            .responseJSON { response in
                processResponse(response: response, success: success, failure: { (error, code, response) in
                    if retriableResponse(error: error,
                                         code: code,
                                         extraErrorCheck: extraErrorCheck) && retryCount < kMaxRetries {
                        performGet(url: url,
                                   params: params,
                                   headers: headers,
                                   extraErrorCheck: extraErrorCheck,
                                   success: success,
                                   failure: failure,
                                   retryCount: retryCount + 1)
                    } else {
                        failure?(error, code, response)
                    }
                })
        }
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
    class private func processResponse(
        response: DataResponse<Any>,
        success: ((NSDictionary, Data?, (ResponseHeaders?)) -> Void)?,
        failure: ((Error, Int?, String) -> Void)?
    ) {
        switch response.result {
        case .success:
            var dict = [:] as NSDictionary
            
            if let responseDict = response.result.value as? NSDictionary {
                dict = responseDict
            } else if let array = response.result.value as? NSArray {
                dict = [kArrayResponseKey: array]
            }
            
            success?(dict, response.data, response.response?.allHeaderFields)
        case .failure(let error):
            if let statusCode = response.response?.statusCode {
                if statusCode == NSURLErrorNotConnectedToInternet {
                    Log.d(StringHelper.localizedStringFor(kNetworkErrorKey, comment: kNetworkErrorComment))
                    return
                } else if statusCode == HTTP_ERROR_UNAUTHORIZED {
                    Log.d(StringHelper.localizedStringFor(kUnauthorizedKey, comment: kUnauthorizedComment))
                    return
                }
            }
            
            Log.d(response.response?.description ?? StringHelper.localizedStringFor(kApiErrorKey, comment: kApiErrorC))
            Log.d(error.localizedDescription)
            
            var responseString: String?
            
            if let data = response.data {
                responseString = String(data: data, encoding: String.Encoding.utf8)
                if responseString == "" {
                    responseString = kEmptyResponse
                }
                
                let errorString = error.localizedDescription
                let apiResponseString = StringHelper.localizedStringFor(kApiResponseKey, comment: kApiResponseComment)
                let status = "\(apiResponseString) \(errorString) \(responseString ?? "")"
                
                Log.d(status)
            }
            
            failure?(error, response.response?.statusCode, responseString ?? kNoResponse)
        }
    }
}
