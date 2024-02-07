//
//  TestUserDefaultsDataAccess.swift
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

class TestUserDefaultsDataAccess: XCTestCase {

    func test_set_font_details() {
        UserDefaultsDataAccess.setFontDetails(key: "test", values: ["key": "value"])
        
        let fontDetails = UserDefaults.standard.dictionary(forKey: "test") as? [String: String]
        
        XCTAssertNotNil(fontDetails)
        XCTAssertEqual(fontDetails, ["key": "value"])
    }
    
    func test_get_font_details() {
        UserDefaults.standard.set(["key": "value"], forKey: "test")
        
        let fontDetails = UserDefaultsDataAccess.getFontDetails(key: "test")
        
        XCTAssertNotNil(fontDetails)
        XCTAssertEqual(fontDetails, ["key": "value"])
    }
    
    func test_remove_font_details() {
        UserDefaultsDataAccess.setFontDetails(key: "test", values: ["key": "value"])
        
        let fontDetails = UserDefaultsDataAccess.getFontDetails(key: "test")
        
        XCTAssertNotNil(fontDetails)
        XCTAssertEqual(fontDetails, ["key": "value"])
        
        UserDefaultsDataAccess.removeFontDetails(key: "test")
        XCTAssertNil(UserDefaultsDataAccess.getFontDetails(key: "test"))
    }
    
    func test_get_font_array_empty() {
         XCTAssertEqual([], UserDefaultsDataAccess.getFontArray())
    }
    
    func test_add_get_to_font_array() {
        UserDefaultsDataAccess.addToFontArray(key: "test")
        let fontArray = UserDefaultsDataAccess.getFontArray()
        XCTAssertNotNil(fontArray)
        XCTAssertEqual(fontArray, ["test"])
    }
    
    func test_add_multiple_to_font_array_dont_have_redundant() {
        UserDefaultsDataAccess.addToFontArray(key: "test")
        UserDefaultsDataAccess.addToFontArray(key: "test")
        let fontArray = UserDefaultsDataAccess.getFontArray()
        XCTAssertEqual(fontArray, ["test"])
    }
    
    func test_remove_font_array() {
        UserDefaultsDataAccess.addToFontArray(key: "test")
        UserDefaultsDataAccess.addToFontArray(key: "test2")
        
        UserDefaultsDataAccess.removeFontFromFontArray(key: "test")
        
        let fontArray = UserDefaultsDataAccess.getFontArray()
        
        XCTAssertEqual(fontArray, ["test2"])
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        UserDefaultsDataAccess.removeFontFromFontArray(key: "test")
        UserDefaultsDataAccess.removeFontFromFontArray(key: "test2")
        UserDefaultsDataAccess.removeFontDetails(key: "test")
    }

}
