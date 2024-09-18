//
//  EventDateFormatter.swift
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
class EventDateFormatter {

    static let dateFormatter = DateFormatter()

    static func getDateString(_ date: Date) -> String {
        dateFormatter.locale = Locale(identifier: kBaseLocale)
        dateFormatter.dateFormat = kEventTimeStamp
        dateFormatter.timeZone = TimeZone(abbreviation: kUTCTimeStamp)
        return dateFormatter.string(from: date)
    }
}
