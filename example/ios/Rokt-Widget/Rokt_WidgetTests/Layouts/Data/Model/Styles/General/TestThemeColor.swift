//
//  TestThemeColor.swift
//  Rokt_WidgetTests
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import XCTest

final class TestThemeColor: XCTestCase {
    
    func test_theme_color() throws {
        // Arrange
        let color = ThemeColor(light: "#FFFFFF", dark: "#000000")
        // Act
        var adaptiveColor = "#FFFFFF"
        if #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                adaptiveColor = "#000000"
            }
        }
        // Assert
        XCTAssertEqual(adaptiveColor, color.adaptiveColor)
    }
    
}
