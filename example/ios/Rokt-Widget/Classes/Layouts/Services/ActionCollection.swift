//
//  EventBus.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation

enum RoktActionType: String {
    case close
    case nextOffer
    case unload
    case positiveEngaged
    case nextGroup
    case previousGroup
    case checkBoundingBox
    case checkBoundingBoxMissized
    case toggleCustomState
}

class ActionCollection {
    typealias ShareFunction = ((Any?) -> Void)
    static let shared = ActionCollection()
    private let internalQueue = DispatchQueue(label: "com.rokt.actions",
                                              qos: .default,
                                              attributes: .concurrent)
    struct EventItem {
        var actionType: RoktActionType
        var function: ShareFunction
    }
    
    private var dicCallbacks: [RoktActionType: EventItem] = [RoktActionType: EventItem]()
    
    func add(actionType: RoktActionType, closure:@escaping ShareFunction) {
        internalQueue.sync {
            dicCallbacks[actionType] = EventItem(actionType: actionType, function: closure)
        }
    }
    
    subscript(actionType: RoktActionType) -> ShareFunction {
        get {
            internalQueue.sync {
                if let callback = self.dicCallbacks[actionType] {
                    return { (param: Any?) -> Void in return callback.function(param) }
                }
                return { (_: Any?) -> Void in return self.error() }
            }
        }
        
        set {
            internalQueue.sync {
                dicCallbacks[actionType] = EventItem(actionType: actionType, function: newValue)
            }
        }
    }
    
    func reset() {
        internalQueue.sync {
            dicCallbacks.removeAll()
        }
    }
    
    func error() {
        // TODO: Add diagnostics
        Log.d("error try catch closure function")
    }
    
}
