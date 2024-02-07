//
//  TestOverlayComponent.swift
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
final class TestOverlayComponent: XCTestCase {
    func testOverlayComponent() throws {
        let view = TestOverlayPlaceholder(layout: getModel())

        let zStack = try view.inspect().view(TestOverlayPlaceholder.self)
            .view(OverlayComponent.self)
            .actualView()
            .inspect()
            .zStack()

        // Outer + Child
        XCTAssertEqual(zStack.count, 2)

        // background
        let backgroundModifier = try zStack.modifier(BackgroundModifier.self)
        let backgroundStyle = try backgroundModifier.actualView().backgroundStyle

        XCTAssertEqual(backgroundStyle?.backgroundColor, ThemeColor(light: "#520E0A13", dark: "#520E0A13"))
    }

    func getModel() -> OverlayUIModel {
        let layoutPlugin = LayoutPlugin(pluginInstanceGuid: "", breakpoints: nil, layout: nil, slots: [], targetElementSelector: "")
        let transformer = LayoutTransformer(layoutPlugin: layoutPlugin)
        let overlay = ModelTestData.OverlayData.singleTextOverlay()
        return transformer.getOverlay(overlay.styles, settings: nil, children: transformer.transformChildren(overlay.children, slot: nil))
    }
}
