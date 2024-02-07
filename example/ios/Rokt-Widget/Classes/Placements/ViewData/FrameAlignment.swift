//
//  FrameAlignment.swift
//  Pods
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
struct FrameAlignment: Equatable {
    let top: Float
    let right: Float
    let bottom: Float
    let left: Float
}

internal extension FrameAlignment {
    static let zero = FrameAlignment(top: 0, right: 0, bottom: 0, left: 0)
}
