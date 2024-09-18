//
//  JSONBackingStoreTests.swift
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

final class JSONBackingStoreTests: XCTestCase {
    var sut: JSONBackingStore!
    let testFileName = "some-test-file"

    override func setUp() {
        super.setUp()
        
        sut = JSONBackingStore()

        XCTestCase.deleteJSONFileWith(name: testFileName)
    }

    override func tearDown() {
        XCTestCase.deleteJSONFileWith(name: testFileName)

        sut = nil

        super.tearDown()
    }

    func test_write_withData_completesSuccessfully() throws {
        sut.write(payload: anyEncodable(), to: testFileURL()) { [weak self] result in
            guard let self
            else {
                XCTFail("test class deallocated does not exist")
                return
            }

            switch result {
            case .success:
                guard let data = try? Data(contentsOf: self.testFileURL(), options: .mappedIfSafe),
                      let decodedData = try? JSONDecoder().decode([String: String].self, from: data)
                else {
                    XCTFail("data does not exist")
                    return
                }

                XCTAssertEqual(self.anyEncodable(), decodedData)
            case .failure:
                XCTFail("could not write file")
            }
        }
    }

    func test_contentsOfFile_retrievesFileContents() {
        sut.write(payload: anyEncodable(), to: testFileURL(), completion: nil)

        XCTAssertEqual(anyEncodable(), sut.contentsOfFileAt(url: testFileURL(), completion: nil))
    }

    func test_getFileURL_createsURLWithJSONExtension() throws {
        let url = try XCTUnwrap(sut.getFileUrl(fileName: testFileName))

        XCTAssertEqual(url, testFileURL())
    }

    func test_isFileExistent_forNonExistentFile_returnsFalse() {
        XCTAssertFalse(sut.isFileExistent(fileName: "abc"))
    }

    func test_isFileExistent_forExistingFile_returnsTrue() {
        let encodedData = try? JSONEncoder().encode(anyData())
        try? encodedData?.write(to: testFileURL())

        XCTAssertTrue(sut.isFileExistent(fileName: testFileName))
    }

    private func testFileURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(testFileName)
            .appendingPathExtension("json")
    }
}
