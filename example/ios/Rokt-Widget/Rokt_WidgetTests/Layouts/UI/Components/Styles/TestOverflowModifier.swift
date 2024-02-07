//
//  TestOverflowModifier.swift
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
final class TestOverflowModifier: XCTestCase {
    
    func test_column_with_overflow() throws {

        let view = TestPlaceHolder(layout: LayoutSchemaUIModel.column(get_model()))

        let hstack = try view.inspect().view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .view(LayoutSchemaComponent.self)
            .view(ColumnComponent.self)
            .actualView()
            .inspect()
            .vStack()

        // test overflow modifier
        let overflowModifier = try hstack.modifier(OverflowModifier.self).actualView()
        
        XCTAssertEqual(overflowModifier.overFlow, .scroll)
        XCTAssertEqual(overflowModifier.axis, .vertical)
    }
    
    func get_model() -> ColumnUIModel {
        let layoutPlugin = LayoutPlugin(pluginInstanceGuid: "", breakpoints: nil, layout: nil, slots: [], targetElementSelector: "")
        let transformer = LayoutTransformer(layoutPlugin: layoutPlugin)
        let column = ModelTestData.ColumnData.columnWithOverflow()
        return transformer.getColumn(column.styles, children: transformer.transformChildren(column.children, slot: nil))
    }

}
