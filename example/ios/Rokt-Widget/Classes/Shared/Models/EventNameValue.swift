//
//  EventNameValue.swift
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
struct EventNameValue: Codable {
    let name: String
    let value: String
    
    func getDictionaty() -> [String: String] {
        var dictionary = [String: String]()
        dictionary[BE_NAME] = self.name
        dictionary[BE_VALUE] = self.value
        return dictionary
    }
}
