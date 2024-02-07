//
//  TestFontPropertiesModel.swift
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

final class TestFontPropertiesModel: XCTestCase {
    func test_converted_weight_default() {
        assert_font_weight(nil, fontWeight: .normal)
    }
    
    func test_converted_weight_thin() {
        assert_font_weight("100", fontWeight: .thin)
    }
    
    func test_converted_weight_ultra_light() {
        assert_font_weight("200", fontWeight: .ultralight)
    }
    
    func test_converted_weight_light() {
        assert_font_weight("300", fontWeight: .light)
    }
    
    func test_converted_weight_normal() {
        assert_font_weight("400", fontWeight: .normal)
    }
    
    func test_converted_weight_medium() {
        assert_font_weight("500", fontWeight: .medium)
    }
    
    func test_converted_weight_semibold() {
        assert_font_weight("600", fontWeight: .semibold)
    }
    
    func test_converted_weight_bold() {
        assert_font_weight("700", fontWeight: .bold)
    }
    
    func test_converted_weight_heavy() {
        assert_font_weight("800", fontWeight: .heavy)
    }
    
    func test_converted_weight_black() {
        assert_font_weight("900", fontWeight: .black)
    }
    
    private func assert_font_weight(_ weight: String?, fontWeight: FontWeightUIModel) {
        // Arrange
        let font = FontPropertiesModel(size: 10, family: "Arial", weight: weight, style: nil)
        // Act
        let convertedWeight = font.convertedWeight
        // Assert
        XCTAssertEqual(convertedWeight, fontWeight)
    }

    func test_init_shouldCalculateValues() throws {
        let rawValues: [String: Any] = [
            "size": 10,
            "family": "Arial",
            "weight": "thin",
            "style": "italic"
        ]

        let data = try JSONSerialization.data(withJSONObject: rawValues)
        let sut = try TestConstants.decoder.decode(FontPropertiesModel.self, from: data)

        XCTAssertEqual(sut.size, 10)
        XCTAssertEqual(sut.family, "Arial")
        XCTAssertEqual(sut.weight, "thin")
        XCTAssertEqual(sut.style, .italic)

        let targetFont = UIFont(name: "Arial", size: 10)?.withWeight(.thin)

        XCTAssertEqual(sut.weightedUIFont, targetFont)

        let tFont = try XCTUnwrap(targetFont)

        XCTAssertEqual(sut.styledFont, Font(tFont.setItalic()))
        XCTAssertEqual(sut.styledUIFont, tFont.setItalic())
        XCTAssertEqual(sut.convertedWeight, .thin)
    }

    func test_init_withoutSize_returnsNilFonts() throws {
        let rawValues: [String: Any] = [
            "family": "Arial",
            "weight": "thin",
            "style": "italic"
        ]

        let data = try JSONSerialization.data(withJSONObject: rawValues)
        let sut = try TestConstants.decoder.decode(FontPropertiesModel.self, from: data)

        XCTAssertNil(sut.weightedUIFont)
        XCTAssertNil(sut.styledFont)
        XCTAssertNil(sut.styledUIFont)
    }

    func test_init_withoutStyle_returnsWeightedFont() throws {
        let rawValues: [String: Any] = [
            "size": 10,
            "family": "Arial",
            "weight": "thin"
        ]

        let data = try JSONSerialization.data(withJSONObject: rawValues)
        let sut = try TestConstants.decoder.decode(FontPropertiesModel.self, from: data)

        let weightedFont = try XCTUnwrap(sut.weightedUIFont)

        XCTAssertEqual(sut.styledFont, Font(weightedFont))
        XCTAssertEqual(sut.styledUIFont, weightedFont)
    }

    func test_regularStyle_returnsRegularFont() throws {
        let rawValues: [String: Any] = [
            "size": 10,
            "family": "Arial",
            "weight": "thin",
            "style": "normal"
        ]

        let data = try JSONSerialization.data(withJSONObject: rawValues)
        let sut = try TestConstants.decoder.decode(FontPropertiesModel.self, from: data)

        let weightedFont = try XCTUnwrap(sut.weightedUIFont)

        XCTAssertEqual(sut.styledFont, Font(weightedFont))
        XCTAssertEqual(sut.styledUIFont, weightedFont)
    }
}
