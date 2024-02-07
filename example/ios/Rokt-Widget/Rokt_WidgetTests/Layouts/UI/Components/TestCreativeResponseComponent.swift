//
//  TestCreativeResponseComponent.swift
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
final class TestCreativeResponseComponent: XCTestCase {
    func test_creative_response() throws {
        let view = TestPlaceHolder(layout: LayoutSchemaUIModel.creativeResponse(get_model()))

        let creativeResponse = try view.inspect().view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .view(LayoutSchemaComponent.self)
            .view(CreativeResponseComponent.self)
            .actualView()
            .inspect()
            .button()
            .labelView()
            .hStack()

        // test custom modifier class
        let paddingModifier = try creativeResponse.modifier(PaddingModifier.self)
        XCTAssertEqual(try paddingModifier.actualView().padding, FrameAlignmentProperty(top: 10, right: 10, bottom: 10, left: 10))
        
        // test the effect of custom modifier
        let padding = try creativeResponse.padding()
        XCTAssertEqual(padding, EdgeInsets(top: 10.0, leading: 10.0, bottom: 10.0, trailing: 10.0))

        // background
        let backgroundModifier = try creativeResponse.modifier(BackgroundModifier.self)
        let backgroundStyle = try backgroundModifier.actualView().backgroundStyle

        XCTAssertEqual(backgroundStyle?.backgroundColor, ThemeColor(light: "#000000", dark: nil))
    }

    func test_creativeResponse_computedProperties_usesModelProperties() throws {
        let view = TestPlaceHolder(layout: LayoutSchemaUIModel.creativeResponse(get_model()))

        let sut = try view.inspect().view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .view(LayoutSchemaComponent.self)
            .view(CreativeResponseComponent.self)
            .actualView()

        let model = sut.viewModel.model

        XCTAssertEqual(sut.style, model.defaultStyle)
        XCTAssertEqual(sut.containerStyle, model.defaultStyle?.container)
        XCTAssertEqual(sut.dimensionStyle, model.defaultStyle?.dimension)
        XCTAssertEqual(sut.flexStyle, model.defaultStyle?.flexChild)
        XCTAssertEqual(sut.borderStyle, model.defaultStyle?.border)
        XCTAssertEqual(sut.backgroundStyle, model.defaultStyle?.background)
        XCTAssertEqual(sut.passableBackgroundStyle, model.defaultStyle?.background)

        XCTAssertEqual(sut.verticalAlignment, .top)
        XCTAssertEqual(sut.horizontalAlignment, .center)

        XCTAssertEqual(sut.verticalAlignmentOverride, .center)
        XCTAssertEqual(sut.horizontalAlignment, .center)
    }
    
    func get_model() -> CreativeResponseUIModel {
        let layoutPlugin = LayoutPlugin(pluginInstanceGuid: "", breakpoints: nil, layout: nil, slots: [], targetElementSelector: "")
        let transformer = LayoutTransformer(layoutPlugin: layoutPlugin)
        let creativeResponse = ModelTestData.CreativeResponseData.positive()
        return transformer.getCreativeResponseUIModel(responseKey: creativeResponse?.responseKey ?? "",
                                                      openLinks: nil,
                                                      styles: creativeResponse?.styles, children: transformer.transformChildren(creativeResponse?.children, slot: nil), slot: nil)
        
    }

}
