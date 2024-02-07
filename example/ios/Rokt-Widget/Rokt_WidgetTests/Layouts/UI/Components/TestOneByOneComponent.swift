//
//  TestOneByOneComponent.swift
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
final class TestOneByOneComponent: XCTestCase {
    
    func test_one_by_one() throws {
        
        let view = TestPlaceHolder(layout: LayoutSchemaUIModel.oneByOne(get_model()))
        
        let oneByOne = try view.inspect().view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .view(LayoutSchemaComponent.self)
            .view(OneByOneComponent.self)
            .actualView()
            .inspect()
            .find(LayoutSchemaComponent.self)

        // test custom modifier class
        let paddingModifier = try oneByOne.modifier(PaddingModifier.self)
        XCTAssertEqual(try paddingModifier.actualView().padding, FrameAlignmentProperty(top: 3, right: 4, bottom: 5, left: 6))

        // test the effect of custom modifier
        let padding = try oneByOne.padding()
        XCTAssertEqual(padding, EdgeInsets(top: 3.0, leading: 6.0, bottom: 5.0, trailing: 4.0))
    }
    
    func get_model() -> OneByOneUIModel {
        let slots = ModelTestData.PageModelData.withBNF().layoutPlugins?.first?.slots
        let layoutPlugin = LayoutPlugin(pluginInstanceGuid: "", breakpoints: nil, layout: nil, slots: slots!, targetElementSelector: "")
        let transformer = LayoutTransformer(layoutPlugin: layoutPlugin)
        let model = ModelTestData.OneByOneData.oneByOne()
        return transformer.getOneByOne(oneByOneModel: model!)
    }
}
