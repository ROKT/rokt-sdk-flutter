//
//  TimingsRequest.swift
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

class TimingsRequest: Codable {
    let eventTime: Date
    let pageId: String?
    let pageInstanceGuid: String?
    let pluginId: String?
    let pluginName: String?
    let timings: [TimingMetric]
    
    init(eventTime: Date,
         pageId: String? = nil,
         pageInstanceGuid: String? = nil,
         pluginId: String? = nil,
         pluginName: String? = nil,
         timings: [TimingMetric]
    ) {
        self.eventTime = eventTime
        self.pageId = pageId
        self.pageInstanceGuid = pageInstanceGuid
        self.pluginId = pluginId
        self.pluginName = pluginName
        self.timings = timings
    }
    
    convenience init(pageId: String? = nil,
                     pageInstanceGuid: String? = nil,
                     pluginId: String? = nil,
                     pluginName: String? = nil,
                     timings: [TimingMetric]) {
        // Shortcut initialiser that sets eventTime current date
        self.init(eventTime: DateHandler.currentDate(),
                  pageId: pageId,
                  pageInstanceGuid: pageInstanceGuid,
                  pluginId: pluginId,
                  pluginName: pluginName,
                  timings: timings)
    }
    
    internal func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            BE_TIMINGS_EVENT_TIME_KEY: EventDateFormatter.getDateString(self.eventTime),
            BE_TIMINGS_TIMING_METRICS_KEY: timings.map { $0.toDictionary() }
        ]
        
        if let pluginId = self.pluginId {
            dict[BE_TIMINGS_PLUGIN_ID_KEY] = pluginId
        }
        if let pluginName = self.pluginName {
            dict[BE_TIMINGS_PLUGIN_NAME_KEY] = pluginName
        }
        
        return dict
    }
}
