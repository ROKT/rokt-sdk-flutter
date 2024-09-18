//
//  TestPlaceHolder.swift
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
struct TestPlaceHolder: View {
    let layout: LayoutSchemaUIModel
    var baseDI = BaseDependencyInjection(sessionId: "",
                                         pluginModel: mockPluginModel,
                                         config: nil)
    var body: some View {
        EmbeddedComponent(layout: layout, baseDI: baseDI, onLoad: nil, onSizeChange: nil)
    }
}

