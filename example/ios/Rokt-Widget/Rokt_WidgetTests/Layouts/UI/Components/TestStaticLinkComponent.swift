//
//  TestStaticLinkComponent.swift
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
final class TestStaticLinkComponent: XCTestCase {

    func test_static_link() throws {

        let view = TestPlaceHolder(layout: LayoutSchemaUIModel.staticLink(get_model()))

        let staticLink = try view.inspect().view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .view(LayoutSchemaComponent.self)
            .view(StaticLinkComponent.self)
            .actualView()
            .inspect()
            .hStack()

        // test custom modifier class
        let paddingModifier = try staticLink.modifier(PaddingModifier.self)
        XCTAssertEqual(try paddingModifier.actualView().padding, FrameAlignmentProperty(top: 13, right: 14, bottom: 15, left: 16))
        
        // test the effect of custom modifier
        let padding = try staticLink.padding()
        XCTAssertEqual(padding, EdgeInsets(top: 13.0, leading: 16.0, bottom: 15.0, trailing: 14.0))
    }
    
    func get_model() -> StaticLinkUIModel {
        let layoutPlugin = LayoutPlugin(pluginInstanceGuid: "", breakpoints: nil, layout: nil, slots: [], targetElementSelector: "")
        let transformer = LayoutTransformer(layoutPlugin: layoutPlugin)
        let model = ModelTestData.StaticLinkData.staticLink()
        return transformer.getStaticLink(src: model.src,
                                         open: model.open,
                                         styles: model.styles,
                                         children: transformer.transformChildren(model.children, slot: nil))
        
    }

}
