//
//  EventCollection.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation

class EventCollection {

    private var dicCallbacks: [RoktEventListenerType: EventItem] = [RoktEventListenerType: EventItem]()

    typealias ShareFunction = () -> Void
    private let queue = DispatchQueue(label: kRoktEventCollectionQueueLabel,
                                      qos: .default,
                                      attributes: .concurrent)
    struct EventItem {
        var eventType: RoktEventListenerType
        var function: ShareFunction
    }
    
    func add(eventType: RoktEventListenerType, closure: @escaping ShareFunction) {
        queue.sync {
            dicCallbacks[eventType] = EventItem(eventType: eventType, function: closure)
        }
    }
    
    subscript(eventType: RoktEventListenerType) -> ShareFunction {
        get {
            queue.sync {
                if let callback = self.dicCallbacks[eventType] {
                    return callback.function
                }
                return error
            }
        }
        
        set {
            queue.sync {
                dicCallbacks[eventType] = EventItem(eventType: eventType, function: newValue)
            }
        }
    }
    
    func reset() {
        queue.sync {
            dicCallbacks.removeAll()
        }
    }
    
    func error() {
        Log.d("error try catch closure function")
    }
    
}
