//
//  TestStringExtension.swift
//  Rokt_WidgetTests
//
//  Copyright 2020 Rokt Pte Ltd
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import XCTest

class TestStringExtension: XCTestCase {

    func test_capital_empty() throws {
        let text = ""
        XCTAssertEqual(text, text.titleCase)
    }

    func test_capital_one_word() throws {
        let text = "something"
        XCTAssertEqual(text.titleCase, "Something")
    }
    
    func test_capital_two_words() throws {
        let text = "something else"
        XCTAssertEqual(text.titleCase, "Something Else")
    }
    
    func test_capital_three_words() throws {
        let text = "one two three?"
        XCTAssertEqual(text.titleCase, "One Two Three?")
    }
    
    func test_start_with_non_letter() throws {
        let text = "!one 2two ~three"
        XCTAssertEqual(text.titleCase, "!one 2two ~three")
    }
    
    func test_dont_change_other_letters() throws {
        let text = "oneTwoThree?"
        XCTAssertEqual(text.titleCase, "OneTwoThree?")
    }
    
    func test_title_case_on_nil() throws {
        let text: String? = nil
        XCTAssertEqual(text?.titleCase, nil)
    }
}
