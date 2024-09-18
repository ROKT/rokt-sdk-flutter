//
//  TextModelTests.swift
//  Rokt_WidgetTests
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import XCTest

@available(iOS 15, *)
final class TextModelTests: XCTestCase {
    func test_styledText_text_model_uppercase() {
        let sut = ModelTestData.TextData.uppercase()
        let textUIModel = RichTextUIModel(value: sut.value, defaultStyle: sut.styles?.elements?.own.compactMap{ $0.default },
                                          openLinks: nil)
        textUIModel.updateBoundValueWithStyling()
        XCTAssertEqual(textUIModel.boundValue, "ORDER NUMBER: UK171359906")
    }
    
    func test_styledText_text_model_lowerCase() {
        let sut = ModelTestData.TextData.lowercase()
        let textUIModel = RichTextUIModel(value: sut.value, defaultStyle: sut.styles?.elements?.own.compactMap{ $0.default },
                                          openLinks: nil)
        textUIModel.updateBoundValueWithStyling()
        XCTAssertEqual(textUIModel.boundValue, "order number: uk171359906")
    }

    func test_styledText_text_model_none() {
        let sut = ModelTestData.TextData.none()
        let textUIModel = RichTextUIModel(value: sut.value, defaultStyle: sut.styles?.elements?.own.compactMap{ $0.default },
                                          openLinks: nil)
        textUIModel.updateBoundValueWithStyling()
        XCTAssertEqual(textUIModel.boundValue, "ORDER Number: Uk171359906")
    }

    func test_styledText_text_model_capitalize() {
        let sut = ModelTestData.TextData.capitalize()
        let textUIModel = RichTextUIModel(value: sut.value, defaultStyle: sut.styles?.elements?.own.compactMap{ $0.default },
                                          openLinks: nil)
        textUIModel.updateBoundValueWithStyling()
        XCTAssertEqual(textUIModel.boundValue, "Order Number: Uk171359906")
    }

    func test_styledText_text_model_default_none() {
        let sut = ModelTestData.TextData.noValue()
        let textUIModel = RichTextUIModel(value: sut.value, defaultStyle: sut.styles?.elements?.own.compactMap{ $0.default },
                                          openLinks: nil)
        textUIModel.updateBoundValueWithStyling()
        XCTAssertEqual(textUIModel.boundValue, "OrDeR Number: Uk171359906")
    }
}
