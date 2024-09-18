//
//  MockTimingsRequest.swift
//  rokt_Tests
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
struct MockTimingsRequest: Equatable {
    var eventTime: String
    var pageId: String?
    var pageInstanceGuid: String?
    var pluginId: String?
    var pluginName: String?
    var timings: [[String: String]]

    static func == (l: MockTimingsRequest, r: MockTimingsRequest) -> Bool {
        return (l.eventTime == r.eventTime
                && l.pageId == r.pageId
                && l.pageInstanceGuid == r.pageInstanceGuid
                && l.pluginId == r.pluginId
                && l.pluginName == r.pluginName)
    }

    func containNameValueInTimings(name: String, value: String) -> Bool {
        return containsNameValuePair(self.timings, name: name, value: value)
    }

    func containsNameValuePair(_ nameValues: [[String: String]]?, name: String, value: String) -> Bool {
        if let nameValues = nameValues {
            for nameValue in nameValues {
                if nameValue["name"] == name,
                   nameValue["value"] == value {
                    return true
                }
            }
        }
        return false
    }
}
