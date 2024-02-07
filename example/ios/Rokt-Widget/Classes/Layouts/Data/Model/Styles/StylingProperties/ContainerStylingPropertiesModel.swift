//
//  ContainerStylingPropertiesModel.swift
//  rokt_Tests
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

@available(iOS 13, *)
struct ContainerStylingPropertiesModel: Decodable, Hashable {
    // primary axis (row = horizontal, column = vertical)
    // will only apply if the container has extra space
    // in SwiftUI, VStack/HStack will only be as tall/wide as the content. by default, VStack/HStack won't have extra space
    // extra space is achieved by fixed/percentage dimension
    let justifyContent: FlexPosition?
    
    // cross axis (row = vertical, column = horizontal)
    let alignItems: FlexPosition?
}
