//
//  BaseDependencyInjection.swift
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

@available(iOS 13.0, *)
class BaseDependencyInjection {
    var sharedData: SharedData
    var eventProcessor: EventProcessor
    let slots: [SlotModel]
    let actionCollection: ActionCollection
    let eventCollection: EventCollection
    let config: RoktConfig?
    
    init(sessionId: String,
         pluginModel: BaseDependencyInjectionPluginModel,
         startDate: Date = Date(),
         responseReceivedDate: Date = Date(),
         sharedData: SharedData = SharedData(),
         slots: [SlotModel] = [],
         config: RoktConfig?,
         timings: [TimingMetric] = []) {
        self.actionCollection = ActionCollection()
        self.eventCollection = EventCollection()
        self.eventProcessor = EventProcessor(sessionId: sessionId,
                                             pluginInstanceGuid: pluginModel.instanceGuid,
                                             pluginId: pluginModel.id,
                                             pluginName: pluginModel.name,
                                             startDate: startDate,
                                             actionCollection: actionCollection,
                                             eventCollection: eventCollection,
                                             responseReceivedDate: responseReceivedDate,
                                             pluginConfigJWTToken: pluginModel.configJWTToken)

        self.sharedData = sharedData
        self.slots = slots
        self.config = config
    }

    func setLayoutType(_ type: PlacementLayoutCode) {
        sharedData.items[SharedData.layoutType] = type
    }

    func layoutType() -> PlacementLayoutCode {
        (sharedData.items[SharedData.layoutType] as? PlacementLayoutCode) ?? .unknown
    }
    
    func closeOnComplete() -> Bool {
        guard let layoutSettings = sharedData.items[SharedData.layoutSettingsKey] as? LayoutSettings,
              let closeOnComplete = layoutSettings.closeOnComplete
        else {
            return true
        }
        return closeOnComplete
    }
}

struct BaseDependencyInjectionPluginModel {
    let instanceGuid: String
    let configJWTToken: String
    let id: String?
    let name: String?
}
