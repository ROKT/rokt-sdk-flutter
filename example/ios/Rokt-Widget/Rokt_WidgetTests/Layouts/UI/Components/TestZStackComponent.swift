//
//  TestZStackComponent.swift
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
final class TestZStackComponent: XCTestCase {
    enum LayoutName {
        case style, alignment
    }
    
    func test_zStackComponent_withStyles_isApplied() throws {
        let view = TestPlaceHolder(layout: LayoutSchemaUIModel.zStack(try get_model(LayoutName.style)))
        
        let zstack = try view.inspect().view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .vStack()[0]
            .view(LayoutSchemaComponent.self)
            .view(ZStackComponent.self)
            .actualView()
            .inspect()
            .zStack()
        
        // padding
        let paddingModifier = try zstack.modifier(PaddingModifier.self)
        XCTAssertEqual(try paddingModifier.actualView().padding, FrameAlignmentProperty(top: 18, right: 24, bottom: 0, left: 24))
        let padding = try zstack.padding()
        XCTAssertEqual(padding, EdgeInsets(top: 18.0, leading: 24.0, bottom: 0.0, trailing: 24.0))
        
        // background
        let backgroundModifier = try zstack.modifier(BackgroundModifier.self)
        let backgroundStyle = try backgroundModifier.actualView().backgroundStyle
        
        XCTAssertEqual(backgroundStyle?.backgroundColor, ThemeColor(light: "#F5C1C4", dark: "#F5C1C4"))
        
        // border
        let borderModifier = try zstack.modifier(BorderModifier.self)
        let borderStyle = try borderModifier.actualView().borderStyle
        
        XCTAssertNil(borderStyle)
        
        // alignment
        let alignment = try zstack.alignment()
        XCTAssertEqual(alignment, .center)
    }
    
    func get_model(_ layoutName: LayoutName) throws -> ZStackUIModel {
        let transformer = LayoutTransformer(layoutPlugin: get_mock_layout_plugin())
        let zstack = ModelTestData.ZStackData.zStackWithStyles()
        return try transformer.getZStack(zstack.styles,
                                         children: transformer.transformChildren(zstack.children, slot: nil))
        
    }
    
}
