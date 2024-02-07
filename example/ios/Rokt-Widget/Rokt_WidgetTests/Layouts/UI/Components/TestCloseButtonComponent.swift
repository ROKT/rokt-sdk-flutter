//
//  TestCloseButtonComponent.swift
//  Rokt_WidgetTests
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import XCTest
import SwiftUI
import ViewInspector

@available(iOS 15.0, *)
final class TestCloseButtonComponent: XCTestCase {

    func test_creative_response() throws {

        let view = TestPlaceHolder(layout: LayoutSchemaUIModel.closeButton(get_model()))

        let closeButton = try view.inspect().view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .view(LayoutSchemaComponent.self)
            .view(CloseButtonComponent.self)
            .actualView()
            .inspect()
            .hStack()

        // test custom modifier class
        let paddingModifier = try closeButton.modifier(PaddingModifier.self)
        XCTAssertEqual(try paddingModifier.actualView().padding, FrameAlignmentProperty(top: 10, right: 10, bottom: 10, left: 10))
        
        // test the effect of custom modifier
        let padding = try closeButton.padding()
        XCTAssertEqual(padding, EdgeInsets(top: 10.0, leading: 10.0, bottom: 10.0, trailing: 10.0))
    }
    
    func get_model() -> CloseButtonUIModel {
        let layoutPlugin = LayoutPlugin(pluginInstanceGuid: "", breakpoints: nil, layout: nil, slots: [], targetElementSelector: "")
        let transformer = LayoutTransformer(layoutPlugin: layoutPlugin)
        let closeButton = ModelTestData.CloseButtonData.closeButton()
        return transformer.getCloseButton(styles: closeButton.styles,
                                          children: transformer.transformChildren(closeButton.children, slot: nil))
    }

}
