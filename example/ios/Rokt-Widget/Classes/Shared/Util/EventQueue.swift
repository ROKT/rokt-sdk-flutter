//
//  EventQueue.swift
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

class EventQueue: NSObject {
    private static weak var timer: Timer?
    static var events = [EventRequest]()
    static var callback: (([EventRequest]) -> Void)?

    static func call(event: EventRequest, callback: @escaping (([EventRequest]) -> Void)) {
        DispatchQueue(label: kEventQueueLabel).sync {
            EventQueue.events.append(event)
        }
        timer?.invalidate()
        let nextTimer = Timer.scheduledTimer(timeInterval: kEventDelay, target: self,
                                             selector: #selector(EventQueue.fireNow), userInfo: nil, repeats: false)
        timer = nextTimer
        self.callback = callback
    }

    @objc static func fireNow() {
        DispatchQueue(label: kEventQueueLabel).sync {
            EventQueue.callback?(EventQueue.events)
            EventQueue.events = [EventRequest]()
        }
    }
}
