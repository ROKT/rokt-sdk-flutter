//
//  OuterLayoutSchemaModel.swift
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

@available(iOS 13, *)
struct OuterLayoutSchemaNetworkModel: Decodable {
    let breakpoints: BreakPoint?
    let layout: LayoutSchemaModel?
    let settings: LayoutSettings?
}

@available(iOS 13, *)
struct OuterLayoutSchemaValidationModel: Decodable {
    let breakpoints: BreakPoint?
    let layout: OuterLayoutSchemaModel?
    let settings: LayoutSettings?
}
