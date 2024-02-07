//
//  TestRowComponent.swift
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
final class TestRowComponent: XCTestCase {
    func test_row() throws {
        let view = TestPlaceHolder(layout: LayoutSchemaUIModel.row(get_model()))

        let hstack = try view.inspect().view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .view(LayoutSchemaComponent.self)
            .view(RowComponent.self)
            .actualView()
            .inspect()
            .hStack()

        XCTAssertEqual(hstack.count, 1)

        // test custom modifier class
        let paddingModifier = try hstack.modifier(PaddingModifier.self)
        XCTAssertEqual(try paddingModifier.actualView().padding, FrameAlignmentProperty(top: 18, right: 24, bottom: 0, left: 24))
        
        // test the effect of custom modifier
        let padding = try hstack.padding()
        XCTAssertEqual(padding, EdgeInsets(top: 18.0, leading: 24.0, bottom: 0.0, trailing: 24.0))

        // background
        let backgroundModifier = try hstack.modifier(BackgroundModifier.self)
        let backgroundStyle = try backgroundModifier.actualView().backgroundStyle

        XCTAssertEqual(backgroundStyle?.backgroundColor, ThemeColor(light: "#F5C1C4", dark: "#F5C1C4"))

        // border
        let borderModifier = try hstack.modifier(BorderModifier.self)
        let borderStyle = try borderModifier.actualView().borderStyle

        XCTAssertNil(borderStyle)

        // alignment
        let alignment = try hstack.alignment()
        XCTAssertEqual(alignment, .center)
    }

    func test_rowComponent_computedProperties_usesModelProperties() throws {
        let view = TestPlaceHolder(layout: LayoutSchemaUIModel.row(get_model()))

        let sut = try view.inspect().view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .view(LayoutSchemaComponent.self)
            .view(RowComponent.self)
            .actualView()

        let model = sut.model

        XCTAssertEqual(sut.style, model.defaultStyle)

        XCTAssertEqual(sut.containerStyle, model.defaultStyle?.container)
        XCTAssertEqual(sut.dimensionStyle, model.defaultStyle?.dimension)
        XCTAssertEqual(sut.flexStyle, model.defaultStyle?.flexChild)
        XCTAssertEqual(sut.backgroundStyle, model.defaultStyle?.background)
        XCTAssertEqual(sut.spacingStyle, model.defaultStyle?.spacing)
        XCTAssertEqual(sut.borderStyle, model.defaultStyle?.border)

        XCTAssertEqual(sut.passableBackgroundStyle, model.defaultStyle?.background)

        XCTAssertEqual(sut.verticalAlignment, .center)
        XCTAssertEqual(sut.horizontalAlignment, .center)
    }
    
    func get_model() -> RowUIModel {
        let layoutPlugin = LayoutPlugin(pluginInstanceGuid: "", breakpoints: nil, layout: nil, slots: [], targetElementSelector: "")
        let transformer = LayoutTransformer(layoutPlugin: layoutPlugin)
        let row = ModelTestData.RowData.rowWithBasicText()
        return transformer.getRow(row.styles, children: transformer.transformChildren(row.children, slot: nil))
    }
}
