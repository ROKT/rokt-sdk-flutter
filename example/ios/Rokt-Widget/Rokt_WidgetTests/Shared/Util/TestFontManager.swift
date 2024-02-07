//
//  TestFontManager.swift
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

class TestFontManager: XCTestCase {

    func test_is_download_font_required() {
        let isDownloadFontRequired = FontManager.isDownloadingFontRequired(font: FontModel(name: "test", url: "test url"))
        
        XCTAssertTrue(isDownloadFontRequired)
    }
    
    func test_save_font_details() {
        let font = FontModel(name: "test font", url: "test url")
        
        FontManager.saveFontDatails(font: font)
        
        let fontArray = UserDefaultsDataAccess.getFontArray()
        let fontDetail = UserDefaultsDataAccess.getFontDetails(key: "test url")
        
        XCTAssertEqual(fontArray, ["test url"])
        XCTAssertEqual(fontDetail?["name"], "test font")
    }
    
    func test_is_font_expired() {
        let about6Days = Calendar.current.date(byAdding: .day, value: -6, to: Date())!.timeIntervalSince1970
        let about2Days = Calendar.current.date(byAdding: .day, value: -2, to: Date())!.timeIntervalSince1970
        let about9Days = Calendar.current.date(byAdding: .day, value: -9, to: Date())!.timeIntervalSince1970
        
        XCTAssertFalse(FontManager.isFontExpired(timeStamp: Date().timeIntervalSince1970))

        XCTAssertFalse(FontManager.isFontExpired(timeStamp: about2Days))
        
    XCTAssertFalse(FontManager.isFontExpired(timeStamp: about6Days))

        XCTAssertTrue(FontManager.isFontExpired(timeStamp: about9Days))
    }
    
    func test_get_file_url() {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let expectedURL = documentsUrl.appendingPathComponent("test.ttf")
        
        let url = FontManager.getFileUrl(name: "test")
        
        XCTAssertEqual(url, expectedURL)
    }
    
    func test_system_font_exist() {
        let font = FontModel(name: "ArialMT", url: "")
        
        XCTAssertTrue(FontManager.isSystemFont(font: font))
    }
    
    func test_system_doesnt_font_exist() {
        let font = FontModel(name: "some other font", url: "")
        
        XCTAssertFalse(FontManager.isSystemFont(font: font))
    }
        
    override func tearDown() {
        UserDefaultsDataAccess.removeFontFromFontArray(key: "test url")
        UserDefaultsDataAccess.removeFontDetails(key: "test url")
    }

}
