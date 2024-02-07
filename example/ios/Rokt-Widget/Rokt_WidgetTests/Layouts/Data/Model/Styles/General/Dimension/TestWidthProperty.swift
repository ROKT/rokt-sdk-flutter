//
//  WidthProperty.swift
//  Rokt_WidgetTests
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import XCTest

enum TestConstants {
    static let decoder = JSONDecoder()
}

final class TestWidthProperty: XCTestCase {
    func test_width_percentage_nil()  {
        // Arrange
        let width = WidthProperty(dimensionType: nil)
        // Act
        let widthPercentage = width.widthPercentage
        // Assert
        XCTAssertNil(widthPercentage)
    }
    
    func test_width_percentage_value_nil()  {
        // Arrange
        let width = WidthProperty(dimensionType: nil)
        // Act
        let widthPercentage = width.widthPercentage
        // Assert
        XCTAssertNil(widthPercentage)
    }
    
    func test_width_percentage_value_valid()  {
        // Arrange
        let width = WidthProperty(dimensionType: .percentage(100))
        // Act
        let widthPercentage = width.widthPercentage
        // Assert
        XCTAssertEqual(widthPercentage, 100)
    }

    func test_init_withValidValues_shouldParseAllValues() throws {
        let rawValues: [String: Any] = [
            "value": "fit-width",
            "type": "fit"
        ]

        let data = try JSONSerialization.data(withJSONObject: rawValues)
        let sut = try TestConstants.decoder.decode(WidthProperty.self, from: data)

        let dimensionValue = try XCTUnwrap(sut)

        guard case .fit(let fitProperty) = dimensionValue.dimensionType else {
            XCTFail("Could not generate fitProperty")
            return
        }

        XCTAssertEqual(fitProperty, .fitWidth)
        XCTAssertNil(sut.widthPercentage)
    }

    func test_init_withFixedType_shouldParseAllValues() throws {
        let rawValues: [String: Any] = [
            "value": 333,
            "type": "fixed"
        ]

        let data = try JSONSerialization.data(withJSONObject: rawValues)
        let sut = try TestConstants.decoder.decode(WidthProperty.self, from: data)

        let dimensionValue = try XCTUnwrap(sut)

        guard case .fixed(let fixedValue) = dimensionValue.dimensionType else {
            XCTFail("Could not generate fitProperty")
            return
        }

        XCTAssertEqual(fixedValue, 333.0)
        XCTAssertNil(sut.widthPercentage)
    }

    func test_init_withPercentageType_shouldParseAllValues() throws {
        let rawValues: [String: Any] = [
            "value": 23,
            "type": "percentage"
        ]

        let data = try JSONSerialization.data(withJSONObject: rawValues)
        let sut = try TestConstants.decoder.decode(WidthProperty.self, from: data)

        let dimensionValue = try XCTUnwrap(sut)

        guard case .percentage(let percentageValue) = dimensionValue.dimensionType else {
            XCTFail("Could not generate fitProperty")
            return
        }

        XCTAssertEqual(percentageValue, 23)
        XCTAssertEqual(sut.widthPercentage, 23)
    }

    func test_init_withInvalidDimensionType_throwsError() throws {
        let rawValues: [String: Any] = [
            "value": "fit-width",
            "type": "invalid-type"
        ]

        let data = try JSONSerialization.data(withJSONObject: rawValues)
        XCTAssertThrowsError(try TestConstants.decoder.decode(WidthProperty.self, from: data))
    }

    func test_init_usingDimensionType() {
        let dimension = WidthDimensionType.percentage(30)
        let sut = WidthProperty(dimensionType: dimension)

        XCTAssertEqual(sut.dimensionType, dimension)
        XCTAssertEqual(sut.widthPercentage, 30)
    }

    func test_init_withInValidDimensionType_throwsError() throws {
        let rawValues: [String: Any] = [
            "value": "fit-width"
        ]

        let data = try JSONSerialization.data(withJSONObject: rawValues)
        XCTAssertThrowsError(try TestConstants.decoder.decode(WidthProperty.self, from: data))
    }
}
