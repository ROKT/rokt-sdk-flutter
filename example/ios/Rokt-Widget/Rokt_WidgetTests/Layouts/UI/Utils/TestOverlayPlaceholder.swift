//
//  TestOverlayPlaceholder.swift
//  Rokt_WidgetTests
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import SwiftUI

@available(iOS 15.0, *)
struct TestOverlayPlaceholder: View {
    let layout: OverlayUIModel
    var baseDI = BaseDependencyInjection(sessionId: "", pluginInstanceGuid: "")
    var body: some View {
        OverlayComponent(model: layout, baseDI: baseDI)
    }
}

