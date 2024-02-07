//
//  TestProgressIndicatorComponent.swift
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
final class TestProgressIndicatorComponent: XCTestCase {

    func test_progress_indicator() throws {

        let view = TestPlaceHolder(layout: LayoutSchemaUIModel.progressIndicator(get_model(
            model: ModelTestData.ProgressIndicatorData.progressIndicator())))

        let progressIndicator = try view.inspect().view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .view(LayoutSchemaComponent.self)
            .view(ProgressIndicatorComponent.self)
            .actualView()
            .inspect()
            .hStack()

        // test custom modifier class
        let paddingModifier = try progressIndicator.modifier(PaddingModifier.self)
        XCTAssertEqual(try paddingModifier.actualView().padding, FrameAlignmentProperty(top: 10, right: 10, bottom: 10, left: 10))
        
        // test the effect of custom modifier
        let padding = try progressIndicator.padding()
        XCTAssertEqual(padding, EdgeInsets(top: 10.0, leading: 10.0, bottom: 10.0, trailing: 10.0))
    }
    
    func test_start_position_progress_indicator() throws {

        let view = TestPlaceHolder(layout: LayoutSchemaUIModel.progressIndicator(get_model(
            model: ModelTestData.ProgressIndicatorData.startPosition())))
        
        let progressIndicatorComponent = try view.inspect().view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .view(LayoutSchemaComponent.self)
            .view(ProgressIndicatorComponent.self)
            .actualView()
        
        let progressIndicatorView = try progressIndicatorComponent
            .inspect()

        // test page indicator is empty view as startPosition=2
        XCTAssertNotNil(try progressIndicatorView.emptyView())
        XCTAssertEqual(progressIndicatorComponent.startIndex, 1)
    }
    
    func get_model(model: ProgressIndicatorModel) -> ProgressIndicatorUIModel {
        let layoutPlugin = LayoutPlugin(pluginInstanceGuid: "", breakpoints: nil, layout: nil, slots: [], targetElementSelector: "")
        let transformer = LayoutTransformer(layoutPlugin: layoutPlugin)
        return transformer.getProgressIndicatorUIModel(model)
    }

}
