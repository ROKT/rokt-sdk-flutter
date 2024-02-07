//
//  EventModel.swift
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
struct EventModel: Equatable {
    var eventType: String
    var parentGuid: String
    var pageInstanceGuid: String?
    var metadata: [[String: String]]?
    var attributes: [[String: String]]?
    
    static func == (l: EventModel, r: EventModel) -> Bool {
        return l.eventType == r.eventType && l.parentGuid == r.parentGuid
    }
    
    func containNameInMetadata(name: String) -> Bool {
        return contains(metadata, key: "name", value: name)
    }
    
    func containValueInMetadata(value: String) -> Bool {
        return contains(metadata, key: "value", value: value)
    }
    
    func containNameInAttributes(name: String) -> Bool {
        return contains(attributes, key: "name", value: name)
    }
    
    func containValueInAttributes(value: String) -> Bool {
        return contains(attributes, key: "value", value: value)
    }
    
    func contains(_ nameValues: [[String: String]]?, key: String, value: String) -> Bool {
        if let nameValues = nameValues {
            for nameValue in nameValues {
                if nameValue[key] == value {
                    return true
                }
            }
        }
        return false
    }

}
