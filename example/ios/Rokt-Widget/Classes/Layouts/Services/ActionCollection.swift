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

class ActionCollection {
    typealias shareFunction = ()->Void
    static let shared = ActionCollection()
    private let internalQueue = DispatchQueue(label: "com.rokt.actions",
                                              qos: .default,
                                              attributes: .concurrent)
    struct EventItem {
        var actionName: String
        var function: shareFunction
    }
    
    private var dicCallbacks: [String:EventItem] = [String:EventItem]()
    
    func add(actionName:String, closure:@escaping shareFunction) {
        internalQueue.sync {
            dicCallbacks[actionName] = EventItem(actionName: actionName, function: closure)
        }
    }
    
    subscript(actionName: String) -> shareFunction {
        get {
            internalQueue.sync {
                if let callback = self.dicCallbacks[actionName] {
                    return callback.function
                }
                return error
            }
        }
        
        set {
            internalQueue.sync {
                dicCallbacks[actionName] = EventItem(actionName: actionName, function: newValue)
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
