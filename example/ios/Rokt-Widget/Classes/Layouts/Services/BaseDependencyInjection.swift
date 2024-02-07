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
    
    init(sessionId: String,
         pluginInstanceGuid: String,
         startDate: Date = Date(),
         sharedData: SharedData = SharedData(),
         slots: [SlotModel] = []) {
        self.eventProcessor = EventProcessor(sessionId: sessionId,
                                             pluginInstanceGuid: pluginInstanceGuid,
                                             startDate: startDate)
        self.sharedData = sharedData
        self.slots = slots
        self.actionCollection = ActionCollection()
    }

    func setLayoutType(_ type: PlacementLayoutCode) {
        sharedData.items[SharedData.layoutType] = type
    }

    func layoutType() -> PlacementLayoutCode {
        (sharedData.items[SharedData.layoutType] as? PlacementLayoutCode) ?? .unknown
    }
}
