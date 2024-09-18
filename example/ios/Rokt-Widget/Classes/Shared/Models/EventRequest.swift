//
//  EventRequest.swift
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

struct EventRequest: Codable {
    var sessionId: String
    var eventType: EventType
    var parentGuid: String
    var attributes: [EventNameValue]
    var metadata: [EventNameValue]
    var pageInstanceGuid: String
    var jwtToken: String

    init(sessionId: String,
         eventType: EventType,
         parentGuid: String,
         eventTime: Date = Date(),
         extraMetadata: [EventNameValue] = [EventNameValue](),
         attributes: [String: String] = [String: String](),
         pageInstanceGuid: String = "",
         jwtToken: String
    ) {
        self.sessionId = sessionId
        self.eventType = eventType
        self.parentGuid = parentGuid
        self.attributes = EventRequest.convertDictionaryToNameValue(attributes)
        self.pageInstanceGuid = pageInstanceGuid
        self.metadata = [EventNameValue(name: BE_CLIENT_TIME_STAMP,
                                        value: EventDateFormatter.getDateString(eventTime)),
                         EventNameValue(name: BE_CAPTURE_METHOD,
                                        value: kClientProvided)] + extraMetadata
        self.jwtToken = jwtToken
    }

    func getParams() -> [String: Any] {
        return [
            BE_SESSION_ID_KEY: sessionId,
            BE_PARENT_GUID_KEY: parentGuid,
            BE_PAGE_INSTANCE_GUID_KEY: pageInstanceGuid,
            BE_EVENT_TYPE_KEY: eventType.rawValue,
            BE_INSTANCE_GUID: UUID().uuidString,
            BE_METADATA_KEY: getNameValueDictionary(metadata),
            BE_ATTRIBUTES_KEY: getNameValueDictionary(attributes),
            BE_JWT_TOKEN: jwtToken
        ]
    }    
    
    func getLog() -> String {
        let params: [String: Any] = [
            BE_SESSION_ID_KEY: sessionId,
            BE_PARENT_GUID_KEY: parentGuid,
            BE_PAGE_INSTANCE_GUID_KEY: pageInstanceGuid,
            BE_EVENT_TYPE_KEY: eventType.rawValue,
            BE_METADATA_KEY: getNameValueDictionary(metadata),
            BE_ATTRIBUTES_KEY: getNameValueDictionary(attributes)
        ]
        
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: params,
                                                            options: []),
              let jsonString = String(data: theJSONData, encoding: .utf8) else {
            return ""
        }
        return "RoktEventLog: \(jsonString)"
    }

    private func getNameValueDictionary(_ nameValues: [EventNameValue]) -> [[String: Any]] {
        return nameValues.map { $0.getDictionaty()}
    }

    private static func convertDictionaryToNameValue(_ from: [String: String]) -> [EventNameValue] {
        return from.map { EventNameValue(name: $0.key, value: $0.value)}
    }
}

enum EventType: String, Codable {
    case SignalImpression
    case SignalInitialize
    case SignalLoadStart
    case SignalLoadComplete
    case SignalGatedResponse
    case SignalResponse
    case SignalDismissal
    case CaptureAttributes
    case SignalActivation
    case SignalViewed
}
