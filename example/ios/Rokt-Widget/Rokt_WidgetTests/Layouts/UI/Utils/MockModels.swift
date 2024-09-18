//
//  MockModels.swift
//  Rokt_WidgetTests
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import SwiftUI

let mockPluginInstanceGuid = "pluginInstanceGuid"
let mockPluginConfigJWTToken = "plugin-config-token"
let mockPluginId = "pluginId"
let mockPluginName = "pluginName"
let mockPageId = "pageId"
let mockPageInstanceGuid = "pageInstanceGuid"

let mockPluginModel = BaseDependencyInjectionPluginModel(instanceGuid: mockPluginInstanceGuid,
                                                         configJWTToken: mockPluginConfigJWTToken,
                                                         id: mockPluginId,
                                                         name: mockPluginName)

func get_mock_layout_plugin(
    pluginInstanceGuid: String = "",
    breakpoints: BreakPoint? = nil,
    settings: LayoutSettings? = nil,
    layout: LayoutSchemaModel? = nil,
    slots: [SlotModel] = [],
    targetElementSelector: String? = "",
    pluginConfigJWTToken: String = "",
    pluginId: String? = "",
    pluginName: String? = "") -> LayoutPlugin {
    return LayoutPlugin(pluginInstanceGuid: pluginInstanceGuid,
                        breakpoints: breakpoints,
                        settings: settings,
                        layout: layout,
                        slots: slots,
                        targetElementSelector: targetElementSelector,
                        pluginConfigJWTToken: pluginConfigJWTToken,
                        pluginId: pluginId,
                        pluginName: pluginName)
}

func get_mock_uistate(currentProgress: Int = 0,
                      totalOffers: Int = 1,
                      position: Int? = nil,
                      width: CGFloat = 100,
                      isDarkMode: Bool = false,
                      customStateMap: CustomStateMap? = nil) -> WhenComponentUIState {
    return WhenComponentUIState(currentProgress: currentProgress,
                                totalOffers: totalOffers,
                                position: position,
                                width: width,
                                isDarkMode: isDarkMode,
                                customStateMap: customStateMap)
}
