//
//  DomainMappableParent.swift
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

/// Entities that have `DomainMappable` children
@available(iOS 15, *)
protocol DomainMappableParent {
    var children: [LayoutSchemaUIModel]? { get set }
    mutating func updateChildren(_ updatedChildren: [LayoutSchemaUIModel]?)
}

@available(iOS 15, *)
extension DomainMappableParent {
    mutating func updateChildren(_ updatedChildren: [LayoutSchemaUIModel]?) {
        self.children = updatedChildren
    }
}

@available(iOS 15, *)
extension OverlayUIModel: DomainMappableParent {}

@available(iOS 15, *)
extension BottomSheetUIModel: DomainMappableParent {}

@available(iOS 15, *)
extension RowUIModel: DomainMappableParent {}

@available(iOS 15, *)
extension ColumnUIModel: DomainMappableParent {}

@available(iOS 15, *)
extension WhenUIModel: DomainMappableParent {}

@available(iOS 15, *)
extension CreativeResponseUIModel: DomainMappableParent {}

@available(iOS 15, *)
extension OneByOneUIModel: DomainMappableParent {}

@available(iOS 15, *)
extension CarouselUIModel: DomainMappableParent {}
