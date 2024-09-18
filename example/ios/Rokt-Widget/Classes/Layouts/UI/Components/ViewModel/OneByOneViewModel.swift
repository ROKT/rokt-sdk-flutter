//
//  OneByOneViewModel.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation
import Combine

@available(iOS 15, *)
class OneByOneViewModel: DistributionViewModel, ObservableObject {
    let model: OneByOneUIModel

    init(model: OneByOneUIModel,
         baseDI: BaseDependencyInjection) {
        self.model = model
        super.init(baseDI: baseDI)
    }
}
