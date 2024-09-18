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
        let view = TestPlaceHolder(layout: LayoutSchemaUIModel.creativeResponse(try get_model()))
        
        let creativeResponse = try view.inspect().view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .vStack()[0]
            .view(LayoutSchemaComponent.self)
            .view(CreativeResponseComponent.self)
            .actualView()
            .inspect()
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
        let view = TestPlaceHolder(layout: LayoutSchemaUIModel.creativeResponse(try get_model()))
        
        let sut = try view.inspect().view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .vStack()[0]
            .view(LayoutSchemaComponent.self)
            .view(CreativeResponseComponent.self)
            .actualView()
        
        let defaultStyle = sut.viewModel.model.defaultStyle?[0]
        
        XCTAssertEqual(sut.style, defaultStyle)
        XCTAssertEqual(sut.containerStyle, defaultStyle?.container)
        XCTAssertEqual(sut.dimensionStyle, defaultStyle?.dimension)
        XCTAssertEqual(sut.flexStyle, defaultStyle?.flexChild)
        XCTAssertEqual(sut.borderStyle, defaultStyle?.border)
        XCTAssertEqual(sut.backgroundStyle, defaultStyle?.background)
        XCTAssertEqual(sut.passableBackgroundStyle, defaultStyle?.background)
        
        XCTAssertEqual(sut.verticalAlignment, .top)
        XCTAssertEqual(sut.horizontalAlignment, .center)
        
        XCTAssertEqual(sut.verticalAlignmentOverride, .center)
        XCTAssertEqual(sut.horizontalAlignment, .center)
    }
    
    func get_model() throws -> CreativeResponseUIModel {
        let transformer = LayoutTransformer(layoutPlugin: get_mock_layout_plugin())
        let creativeResponse = ModelTestData.CreativeResponseData.positive()
        return try transformer.getCreativeResponseUIModel(responseKey: creativeResponse?.responseKey ?? "",
                                                          openLinks: nil,
                                                          styles: creativeResponse?.styles, children: transformer.transformChildren(creativeResponse?.children, slot: nil), slot: nil)
        
    }
    
}
