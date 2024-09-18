//
//  TimingMetric.swift
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

class TimingMetric: Codable {
    let name: TimingType
    let value: Date
    
    init(name: TimingType, value: Date) {
        self.name = name
        self.value = value
    }
    
    internal func toDictionary() -> [String: String] {
        var dictionary = [String: String]()
        dictionary[BE_NAME] = self.name.rawValue
        dictionary[BE_VALUE] = String(Int(self.value.timeIntervalSince1970 * 1000))
        return dictionary
    }
}

enum TimingType: String, Codable {
    case initStart
    case initEnd
    case pageInit
    case selectionStart
    case selectionEnd
    case experiencesRequestStart
    case experiencesRequestEnd
    case placementInteractive
}
