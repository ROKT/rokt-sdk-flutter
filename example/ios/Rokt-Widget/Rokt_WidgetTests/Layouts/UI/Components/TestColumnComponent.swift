//
//  TestColumnComponent.swift
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
final class TestColumnComponent: XCTestCase {
    func test_column() throws {
        let view = TestPlaceHolder(layout: LayoutSchemaUIModel.column(get_model()))

        let vstack = try view.inspect().view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .view(LayoutSchemaComponent.self)
            .view(ColumnComponent.self)
            .actualView()
            .inspect()
            .vStack()

        // test custom modifier class
        let paddingModifier = try vstack.modifier(PaddingModifier.self)
        XCTAssertEqual(try paddingModifier.actualView().padding, FrameAlignmentProperty(top: 18, right: 24, bottom: 0, left: 24))
        
        // test the effect of custom modifier
        let padding = try vstack.padding()
        XCTAssertEqual(padding, EdgeInsets(top: 18.0, leading: 24.0, bottom: 0.0, trailing: 24.0))
        
        // Test weight = 1 add maxWidth .infinity
        let flexFrame = try vstack.flexFrame()
        XCTAssertEqual(flexFrame.maxWidth, .infinity)

        // background
        let backgroundModifier = try vstack.modifier(BackgroundModifier.self)
        let backgroundStyle = try backgroundModifier.actualView().backgroundStyle

        XCTAssertEqual(backgroundStyle?.backgroundColor, ThemeColor(light: "#F5C1C4", dark: "#F5C1C4"))

        // border
        let borderModifier = try vstack.modifier(BorderModifier.self)
        let borderStyle = try borderModifier.actualView().borderStyle

        XCTAssertNil(borderStyle)

        // alignment
        let alignment = try vstack.alignment()
        XCTAssertEqual(alignment, .center)
    }
    
    func get_model() -> ColumnUIModel {
        let layoutPlugin = LayoutPlugin(pluginInstanceGuid: "", breakpoints: nil, layout: nil, slots: [], targetElementSelector: "")
        let transformer = LayoutTransformer(layoutPlugin: layoutPlugin)
        let column = ModelTestData.ColumnData.columnWithBasicText()
        return transformer.getColumn(column.styles, children: transformer.transformChildren(column.children, slot: nil))
    }

}
