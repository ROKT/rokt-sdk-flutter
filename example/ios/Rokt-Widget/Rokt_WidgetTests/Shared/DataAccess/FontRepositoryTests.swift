//
//  FontRepositoryTests.swift
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

class FontRepositoryTests: XCTestCase {
    override func setUp() {
        super.setUp()

        FontRepositoryTests.prepareTestFiles()

        FontRepositoryTests.deleteAllTestFiles()
    }

    override func tearDown() {
        FontRepositoryTests.deleteAllTestFiles()

        super.tearDown()
    }

    // MARK: - File name management
    func test_setFontDownloadURLFileName_updatesFileName() {
        FontRepository.setFontDownloadURLFileName("some-fake-name")

        XCTAssertEqual(FontRepository.fontDownloadURLFileName, "some-fake-name")
    }

    func test_setFontDownloadDetailFileName_updatesFileName() {
        FontRepository.setFontDownloadDetailFileName("some-random-name")

        XCTAssertEqual(FontRepository.fontDownloadDetailFileName, "some-random-name")
    }

    // MARK: - Font Details
    func test_saveFontDetails_shouldSaveDataToFile() throws {
        let expectation = expectation(description: "expect font details to tbe writter")

        FontRepository.saveFontDetail(key: "test", values: ["key": "value"]) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        let fontDetails = try XCTUnwrap(FontRepositoryTests.downloadDetailPayloadWith(key: "test"))

        XCTAssertEqual(fontDetails, ["key": "value"])
    }

    func test_loadFontDetail_returnsSavedFontDetail() throws {
        FontRepository.saveFontDetail(key: "test", values: ["key": "value"])

        let fontDetails = try XCTUnwrap(FontRepository.loadFontDetail(key: "test"))

        XCTAssertEqual(fontDetails, ["key": "value"])
    }

    func test_remove_font_details() throws {
        FontRepository.saveFontDetail(key: "test", values: ["key": "value"])

        let fontDetails = try XCTUnwrap(FontRepository.loadFontDetail(key: "test"))

        XCTAssertEqual(fontDetails, ["key": "value"])

        let expectation = expectation(description: "ezxpect font details to tbe writter")

        FontRepository.removeFontDetail(key: "test") {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        XCTAssertNil(FontRepository.loadFontDetail(key: "test"))
    }

    // MARK: - Font URLs
    func test_saveFontURL_shouldSaveDataToFile() {
        let expectation = expectation(description: "expect font details to tbe writter")

        FontRepository.saveFontUrl(key: "test-url") {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        let url = FontRepositoryTests.fontURLPayloadWith(key: "test-url")

        XCTAssertEqual(url, "test-url")
    }

    func test_saveFontURL_insertMultipleFontURLs_shouldSaveAllToFile() throws {
        let expectation1 = expectation(description: "save font 1")
        let expectation2 = expectation(description: "save font 2")

        FontRepository.saveFontUrl(key: "test-1") {
            expectation1.fulfill()
        }
        FontRepository.saveFontUrl(key: "test-2") {
            expectation2.fulfill()
        }

        waitForExpectations(timeout: 1)

        let savedURLs = try XCTUnwrap(FontRepository.loadAllFontURLs())

        XCTAssertEqual(["test-1", "test-2"], savedURLs.sorted())
    }

    func test_saveFontURL_doesNotInsertDuplicates() throws {
        let expectation1 = expectation(description: "save font 1")
        let expectation2 = expectation(description: "save font 1 again")

        FontRepository.saveFontUrl(key: "test-1") {
            expectation1.fulfill()
        }
        FontRepository.saveFontUrl(key: "test-1") {
            expectation2.fulfill()
        }

        waitForExpectations(timeout: 1)

        let savedURLs = try XCTUnwrap(FontRepository.loadAllFontURLs())

        XCTAssertEqual(["test-1"], savedURLs)
    }

    func test_loadFontURLs_withNoData_returnsNil() {
        XCTAssertNil(FontRepository.loadAllFontURLs())
    }

    func test_loadFontURLs_withSavedURLs_returnsURLs() throws {
        let testURLs = ["test-1", "test-2", "test-3"]

        let expectation1 = expectation(description: "save font 1")
        let expectation2 = expectation(description: "save font 2")
        let expectation3 = expectation(description: "save font 3")

        FontRepository.saveFontUrl(key: "test-1") {
            expectation1.fulfill()
        }
        FontRepository.saveFontUrl(key: "test-2") {
            expectation2.fulfill()
        }
        FontRepository.saveFontUrl(key: "test-3") {
            expectation3.fulfill()
        }

        waitForExpectations(timeout: 1)

        let savedURLs = try XCTUnwrap(FontRepository.loadAllFontURLs())

        XCTAssertEqual(testURLs.sorted(), savedURLs.sorted())
    }

    func test_removeFontURL_removesTargetURL() throws {
        XCTAssertNil(FontRepository.loadAllFontURLs())

        let expectation1 = expectation(description: "save font 1")
        let expectation2 = expectation(description: "save font 2")
        let expectation3 = expectation(description: "save font 3")

        FontRepository.saveFontUrl(key: "test-1") {
            expectation1.fulfill()
        }
        FontRepository.saveFontUrl(key: "test-2") {
            expectation2.fulfill()
        }
        FontRepository.saveFontUrl(key: "test-3") {
            expectation3.fulfill()
        }

        let deletionExpectation = expectation(description: "delete font url")

        FontRepository.removeFontUrl(key: "test-1") {
            deletionExpectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        let savedURLs = try XCTUnwrap(FontRepository.loadAllFontURLs())

        XCTAssertEqual(["test-2", "test-3"], savedURLs.sorted())
    }

    func test_seriesOfReadAndWriteOperations_resolvesAllOperationsWithoutResourceLock() {
        let group = DispatchGroup()

        for _ in 0...20 {
            group.enter()
            DispatchQueue.global().async {
                let sleepVal = arc4random() % 1000
                usleep(sleepVal)

                FontRepository.saveFontUrl(key: "somekey-\(sleepVal)")

                group.leave()
            }

            group.enter()
            DispatchQueue.global().async {
                let sleepVal = arc4random() % 1000
                usleep(sleepVal)

                _ = FontRepository.loadAllFontURLs()

                group.leave()
            }
        }

        let result = group.wait(timeout: DispatchTime.now() + 20)

        XCTAssertEqual(result, .success)
    }
}

extension XCTestCase {
    private static let fontDownloadURLFileName = "test_fontDownloadDetailFileName"
    private static let fontDownloadDetailFileName = "test_RoktFontDownloadedDetail"

    static func prepareTestFiles() {
        FontRepository.setFontDownloadURLFileName(FontRepositoryTests.fontDownloadURLFileName)
        FontRepository.setFontDownloadDetailFileName(FontRepositoryTests.fontDownloadDetailFileName)
    }

    static func deleteAllTestFiles() {
        deleteJSONFileWith(name: fontDownloadURLFileName)
        deleteJSONFileWith(name: fontDownloadDetailFileName)
    }

    static func downloadURLFileURL() -> URL? {
        fileURLFor(fileName: fontDownloadURLFileName)
    }

    static func downloadDetailFileURL() -> URL? {
        fileURLFor(fileName: fontDownloadDetailFileName)
    }

    static func fileURLFor(fileName: String) -> URL? {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            XCTFail("documents url does not exist")
            return nil
        }

        return documentsUrl.appendingPathComponent(fileName).appendingPathExtension("json")
    }

    static func deleteJSONFileWith(name: String) {
        guard let fileURL = fileURLFor(fileName: name)
        else {
            XCTFail("could not create file url")
            return
        }

        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }

        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            XCTFail("could not delete test file with error \(error.localizedDescription)")
        }
    }

    static func downloadDetailPayloadWith(key: String) -> [String: String]? {
        guard let downloadDetailURL = downloadDetailFileURL(),
              FileManager.default.fileExists(atPath: downloadDetailURL.path)
        else {
            XCTFail("download detail file does not exist")
            return nil
        }

        do {
            let data = try Data(contentsOf: downloadDetailURL, options: .mappedIfSafe)
            let decodedData = try? JSONDecoder().decode([String: [String: String]].self, from: data)

            return decodedData?[key]
        } catch {
            XCTFail("could not decode download detail file with error \(error.localizedDescription)")
            return nil
        }
    }

    static func fontURLPayloadWith(key: String) -> String? {
        guard let downloadDetailURL = downloadURLFileURL(),
              FileManager.default.fileExists(atPath: downloadDetailURL.path)
        else {
            XCTFail("download detail file does not exist")
            return nil
        }

        do {
            let data = try Data(contentsOf: downloadDetailURL, options: .mappedIfSafe)
            let decodedData = try JSONDecoder().decode([String].self, from: data)
            
            guard let indexOfKey = decodedData.firstIndex(of: key) else { return nil }

            return decodedData[indexOfKey]
        } catch {
            XCTFail("could not decode URL file with error \(error.localizedDescription)")
            return nil
        }
    }
}
