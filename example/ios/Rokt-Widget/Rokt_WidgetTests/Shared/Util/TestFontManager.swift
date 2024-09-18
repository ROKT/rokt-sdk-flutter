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
    var hasFetched = false
    var errors = [String]()

    override func setUp() {
        super.setUp()

        if !hasFetched {
            FontManager.getExistingFontsByPostScriptName()
            hasFetched = true
        }
        Rokt.shared.roktTagId = "123"

        self.stubDiagnostics(onDiagnosticsReceive: { (error) in
            self.errors.append(error)
        })

        XCTestCase.prepareTestFiles()
        XCTestCase.deleteAllTestFiles()

    }

    override func tearDown() {
        XCTestCase.deleteAllTestFiles()

        super.tearDown()
    }

    func test_isDownloadFontRequired_withNewFont_shouldReturnTrue() {
        let isDownloadFontRequired = FontManager.isDownloadingFontRequired(font: FontModel(name: "test", url: "test url"))

        XCTAssertTrue(isDownloadFontRequired)
    }

    func test_saveFonDetails_withPostScript_usesPostScriptNameInsteadOfFamilyName() throws {
        let font = FontModel(name: "test font", url: "test url", postScriptName: "font post script")
        
        FontManager.saveFontDetails(font: font)

        let fontArray = try XCTUnwrap(FontRepository.loadAllFontURLs())
        let fontDetail = try XCTUnwrap(FontRepository.loadFontDetail(key: "test url"))

        XCTAssertEqual(fontArray, ["test url"])
        XCTAssertEqual(fontDetail["name"], "font post script")
    }

    func test_saveFontDetails_withoutPostScript_usesFamilyName() throws {
        let font = FontModel(name: "test font", url: "test url", postScriptName: nil)
        
        FontManager.saveFontDetails(font: font)
        
        let fontArray = try XCTUnwrap(FontRepository.loadAllFontURLs())
        let fontDetail = try XCTUnwrap(FontRepository.loadFontDetail(key: "test url"))

        XCTAssertEqual(fontArray, ["test url"])
        XCTAssertEqual(fontDetail["name"], "test font")
    }

    func test_isFontExpired_forUnexpiredDates_returnsFalse() {
        let now = Date().timeIntervalSince1970
        let about6Days = Calendar.current.date(byAdding: .day, value: -6, to: Date())!.timeIntervalSince1970
        let about2Days = Calendar.current.date(byAdding: .day, value: -2, to: Date())!.timeIntervalSince1970

        XCTAssertFalse(FontManager.isFontExpired(timeStamp: now))
        XCTAssertFalse(FontManager.isFontExpired(timeStamp: about2Days))
        XCTAssertFalse(FontManager.isFontExpired(timeStamp: about6Days))
    }

    func test_isFontExpired_forUnexpiredDate_returnsTrue() {
        let about9Days = Calendar.current.date(byAdding: .day, value: -9, to: Date())!.timeIntervalSince1970
        XCTAssertTrue(FontManager.isFontExpired(timeStamp: about9Days))
    }

    func test_getFileURL_returnsMappedURL() throws {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let expectedURL = documentsUrl.appendingPathComponent("test.ttf")

        let url = try XCTUnwrap(FontManager.getFileUrl(name: "test"))

        XCTAssertEqual(url, expectedURL)
    }

    func test_isSystemFont_forSystemFont_returnsTrue() {
        let font = FontModel(name: "ArialMT", url: "")

        XCTAssertTrue(FontManager.isSystemFont(font: font))
    }
    
    func test_registerGraphicFont_registerDuplicate_sendsNoDiagnostics() {
        let font = UIFont.systemFont(ofSize: 15.0)
        let fontName = font.fontName as NSString
        let cgFont = CGFont(fontName)!
        
        FontManager.registerGraphicFont(cgFont: cgFont, fontUrlString: "Test", logLoadType: kLogFontPreloadedType)
        
        let exp = expectation(description: "Test after 0.1 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.1)
        
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(errors.isEmpty)
        } else {
            XCTFail("Diagnostics sent on reregister")
        }
    } 
    @available(iOS 16.0, *)
    func test_registerURLFont_withError_registersFontError() {
        let font = UIFont.systemFont(ofSize: 15.0)
        let fontName = font.fontName as NSString
        let cgFont = CGFont(fontName)!
        
        FontManager.registerURLFont(fileUrl: URL.currentDirectory(), cgFont: cgFont,
                                    fontUrlString: "Test",
                                    logLoadType: kLogFontPreloadedType)
        
        let exp = expectation(description: "Test after 0.1 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.1)

        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(errors.contains("[FONT]"))
        } else {
            XCTFail("No diagnostics")
        }
    
    }

    func test_isSystemFont_forNonExistentFont_shouldReturnFalse() {
        let font = FontModel(name: "some other font", url: "")

        XCTAssertFalse(FontManager.isSystemFont(font: font))
    }
}
