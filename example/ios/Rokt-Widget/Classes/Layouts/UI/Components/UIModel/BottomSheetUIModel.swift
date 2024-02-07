//
//  BottomSheetUIModel.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation

@available(iOS 15, *)
struct BottomSheetUIModel: Identifiable, Hashable {
    let id: UUID = UUID()
    var children: [LayoutSchemaUIModel]?
    let settings: BottomSheetSettings?
    let defaultStyle: BottomSheetStyles?
    
    init(children: [LayoutSchemaUIModel]?,
         settings: BottomSheetSettings?,
         defaultStyle: BottomSheetStyles?) {
        self.children = children
        self.settings = settings
        self.defaultStyle = defaultStyle
    }
}
