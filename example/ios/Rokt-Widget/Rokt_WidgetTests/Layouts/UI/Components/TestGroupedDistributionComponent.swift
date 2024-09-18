//
//  TestCarouselComponent.swift
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
final class TestGroupedDistributionComponent: XCTestCase {

    func test_grouped_distribution() throws {
        var closeActionCalled = false
        
        let view = TestPlaceHolder(layout: LayoutSchemaUIModel.groupDistribution(try get_model()))
        view.baseDI.actionCollection[.close] = { _ in
            closeActionCalled = true
        }
        
        let groupedComponent = try view.inspect().view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .vStack()[0]
            .view(LayoutSchemaComponent.self)
            .view(GroupedDistributionComponent.self)
            .actualView()
        
        let grouped = try groupedComponent
            .inspect()
            .vStack()
        
        // test custom modifier class
        let paddingModifier = try grouped.modifier(PaddingModifier.self)
        XCTAssertEqual(try paddingModifier.actualView().padding, FrameAlignmentProperty(top: 3, right: 4, bottom: 5, left: 6))
        
        // test the effect of custom modifier
        let padding = try grouped.padding()
        XCTAssertEqual(padding, EdgeInsets(top: 3.0, leading: 6.0, bottom: 5.0, trailing: 4.0))
        
        XCTAssertEqual(try grouped.accessibilityLabel().string(), "Page 1 of 1")

        groupedComponent.goToNextOffer()
        XCTAssertTrue(closeActionCalled)
    }
    
    func test_goToNextGroup_with_closeOnComplete_default() throws {
        var closeActionCalled = false
        
        let view = TestPlaceHolder(layout: LayoutSchemaUIModel.groupDistribution(try get_model()))
        view.baseDI.actionCollection[.close] = { _ in
            closeActionCalled = true
        }
        
        let groupedComponent = try view.inspect()
            .view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .vStack()[0]
            .view(LayoutSchemaComponent.self)
            .view(GroupedDistributionComponent.self)
            .actualView()

        groupedComponent.goToNextGroup()
        XCTAssertTrue(closeActionCalled)
    }
    
    func test_goToNextOffer_with_closeOnComplete_false() throws {
        var closeActionCalled = false
        let closeOnCompleteSettings = LayoutSettings(closeOnComplete: false)
        
        let view = TestPlaceHolder(layout: LayoutSchemaUIModel.groupDistribution(try get_model()))
        view.baseDI.sharedData.items[SharedData.layoutSettingsKey] = closeOnCompleteSettings
        view.baseDI.actionCollection[.close] = { _ in
            closeActionCalled = true
        }
        
        let groupedComponent = try view.inspect()
            .view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .vStack()[0]
            .view(LayoutSchemaComponent.self)
            .view(GroupedDistributionComponent.self)
            .actualView()

        groupedComponent.goToNextOffer()
        XCTAssertFalse(closeActionCalled)
    }
    
    func test_goToNextGroup_with_closeOnComplete_false() throws {
        var closeActionCalled = false
        let closeOnCompleteSettings = LayoutSettings(closeOnComplete: false)
        
        let view = TestPlaceHolder(layout: LayoutSchemaUIModel.groupDistribution(try get_model()))
        view.baseDI.sharedData.items[SharedData.layoutSettingsKey] = closeOnCompleteSettings
        view.baseDI.actionCollection[.close] = { _ in
            closeActionCalled = true
        }
        
        let groupedComponent = try view.inspect()
            .view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .vStack()[0]
            .view(LayoutSchemaComponent.self)
            .view(GroupedDistributionComponent.self)
            .actualView()

        groupedComponent.goToNextGroup()
        XCTAssertFalse(closeActionCalled)
    }
    
    func get_model() throws -> GroupedDistributionUIModel {
        let slots = ModelTestData.PageModelData.withBNF().layoutPlugins?.first?.slots
        let transformer = LayoutTransformer(layoutPlugin: get_mock_layout_plugin(slots: slots!))
        let model = ModelTestData.GroupedDistributionData.groupedDistribution()
        return try transformer.getGroupedDistribution(groupedModel: model!)
    }

}
