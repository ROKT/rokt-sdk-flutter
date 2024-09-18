//
//  RoktHTTPParameterEncoder.swift
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

protocol RoktHTTPParameterEncodable {}

extension URLComponents: RoktHTTPParameterEncodable {}
extension URLRequest: RoktHTTPParameterEncodable {}

protocol RoktHTTPParameterEncoder {
    var id: String { get }

    func encode(
        parameterEncodable: RoktHTTPParameterEncodable,
        parameters: RoktHTTPParameters?,
        parameterArray: RoktHTTPParameterArray?,
        httpMethod: RoktHTTPMethod
    ) -> RoktHTTPParameterEncodable
}

final class RoktHTTPURLEncoder: RoktHTTPParameterEncoder {
    let id = String(describing: RoktHTTPURLEncoder.self)

    func encode(
        parameterEncodable: RoktHTTPParameterEncodable,
        parameters: RoktHTTPParameters?,
        parameterArray: RoktHTTPParameterArray?,
        httpMethod: RoktHTTPMethod
    ) -> RoktHTTPParameterEncodable {
        guard case .get = httpMethod,
              var components = parameterEncodable as? URLComponents,
              let parameters,
              !parameters.isEmpty
        else { return parameterEncodable }

        var queryItems: [URLQueryItem] = []

        for (key, value) in parameters {
            switch value {
            case let intVal as Int:
                queryItems.append(URLQueryItem(name: key, value: String(intVal)))
            case let doubleval as Double:
                queryItems.append(URLQueryItem(name: key, value: String(doubleval)))
            case let boolVal as Bool:
                queryItems.append(URLQueryItem(name: key, value: String(boolVal)))
            case let strVal as String:
                queryItems.append(URLQueryItem(name: key, value: String(strVal)))
            default:
                break
            }
        }
        components.queryItems = queryItems.sorted { $0.name < $1.name }

        let escapedQuery = encodeSpecialCharactersIn(
            urlPercentEncodedQuery: components.percentEncodedQuery,
            httpMethod: httpMethod
        )
        components.percentEncodedQuery = escapedQuery

        return components
    }

    // `+` should be percent encoded when part of the URL
    // `+` should NOT be percent encoded when part of the form data
    private func encodeSpecialCharactersIn(
        urlPercentEncodedQuery: String?,
        httpMethod: RoktHTTPMethod
    ) -> String? {
        guard case .get = httpMethod else { return urlPercentEncodedQuery }

        return urlPercentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
    }
}

final class RoktHTTPBodyEncoder: RoktHTTPParameterEncoder {
    let id = String(describing: RoktHTTPBodyEncoder.self)

    func encode(
        parameterEncodable: RoktHTTPParameterEncodable,
        parameters: RoktHTTPParameters?,
        parameterArray: RoktHTTPParameterArray?,
        httpMethod: RoktHTTPMethod
    ) -> RoktHTTPParameterEncodable {
        guard case .post = httpMethod,
              let request = parameterEncodable as? URLRequest
        else { return parameterEncodable }

        var decoratedRequest = setAcceptHeaderIfDoesNotExist(request: request)

        if let parameters, !parameters.isEmpty {
            decoratedRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        } else if let parameterArray, !parameterArray.isEmpty {
            decoratedRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameterArray, options: [])
        }

        return decoratedRequest
    }

    private func setAcceptHeaderIfDoesNotExist(request: URLRequest) -> URLRequest {
        var decoratedRequest = request

        guard decoratedRequest.value(forHTTPHeaderField: kContentType) == nil else { return decoratedRequest }

        decoratedRequest.setValue(kJsonAccept, forHTTPHeaderField: kContentType)
        decoratedRequest.setValue(kJsonAccept, forHTTPHeaderField: kAcceptHeader)

        return decoratedRequest
    }
}
