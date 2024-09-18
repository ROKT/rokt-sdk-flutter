//
//  SharedData.swift
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

import SwiftUI

@available(iOS 13.0, *)
class SharedData: ObservableObject {
    static let breakPointsSharedKey = "breakPoints"     // BreakPoint
    static let currentProgressKey = "currentProgress"   // Binding<Int>
    static let totalItemsKey = "totalItems"             // Int
    static let layoutType = "layoutCode"                // PlacementLayoutCode
    static let viewableItemsKey = "viewableItems"       // Binding<Int>
    static let layoutSettingsKey = "layoutSettings"     // LayoutSettings
    static let customStateMap = "customStateMap"        // CustomStateMap

    @Published var _items = [String: Any]()

    let queue = DispatchQueue(label: kSharedDataItemsQueueLabel, attributes: .concurrent)
    var items: [String: Any] {
        get {
            queue.sync {
                return _items
            }
        }
        set {
            queue.async(flags: .barrier) {
                self._items = newValue
            }
        }
    }
    
    func getGlobalBreakpointIndex(_ width :CGFloat?) -> Int {
        guard let width,
              let globalBreakPoints = items[SharedData.breakPointsSharedKey] as? BreakPoint,
           !globalBreakPoints.isEmpty
            else { return 0 }
        
        let sortedGlobalBreakPoints = globalBreakPoints.sorted { $0.1 < $1.1 }
        var index = 0
        for breakpoint in sortedGlobalBreakPoints {
            if CGFloat(breakpoint.value) > width {
                return index
            }
            index += 1
        }
        
        return index
    }
}

typealias CustomStateMap = [CustomStateIdentifiable: Int]

extension CustomStateMap {
    mutating func toggleValueFor(_ customStateId: Any?) -> CustomStateMap {
        guard let customStateId = customStateId as? CustomStateIdentifiable else {
            return self
        }
        // Toggle value between 0 and 1 (if nil, toggle on to 1)
        self.updateValue((self[customStateId] ?? 0 == 1) ? 0 : 1, forKey: customStateId)
        return self
    }
}

struct CustomStateIdentifiable: Hashable {
    let position: Int?
    let key: String
}
