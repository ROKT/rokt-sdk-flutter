//
//  ProcessedEventViewModel.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation

class ProcessedEventViewModel {
    internal var processedEvents = Set<ProcessedEvent>()

    internal func insertProcessedEvent(_ req: EventRequest) -> Bool {
        let pendingEvent = ProcessedEvent(sessionId: req.sessionId,
                                          parentGuid: req.parentGuid,
                                          eventType: req.eventType,
                                          pageInstanceGuid: req.pageInstanceGuid,
                                          attributes: req.attributes)
        return processedEvents.insert(pendingEvent).inserted
    }
}
