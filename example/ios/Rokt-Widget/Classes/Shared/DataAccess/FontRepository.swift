//
//  FontRepository.swift
//  Rokt-Widget
//
//  Copyright 2020 Rokt Pte Ltd
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation

class FontRepository {
    // [`font_url`: [`font_name`: `font_save_date`]]
    typealias FontDetails = [String: [String: String]]
    typealias FontURLs = [String]

    static let fileStorageQueueName = "com.rokt.filemanagement.queue"

    private(set) static var fontDownloadURLFileName = "RoktFontDownloadedUrl"
    private(set) static var fontDownloadDetailFileName = "RoktFontDownloadedDetail"

    private static let fontDetailsSaveErrorPrefix = "Failed to save font details:"
    private static let fontDetailsLoadErrorPrefix = "Failed to load font details:"
    private static let fontDetailsDeleteErrorPrefix = "Failed to delete font details:"

    private static let fontURLSaveErrorPrefix = "Failed to save font urls:"
    private static let fontURLLoadErrorPrefix = "Failed to load font urls:"
    private static let fontURLDeleteErrorPrefix = "Failed to delete font urls:"

    static let shared = FontRepository()
    private let fileStorage: FileStorage
    private static var backingStore: FileStorage { FontRepository.shared.fileStorage }

    private init() {
        fileStorage = ConcurrentQueueFileStorageDecorator(
            queueName: FontRepository.fileStorageQueueName,
            decoratee: JSONBackingStore()
        )
    }

    // MARK: - Font URLs - array of registered [`font_url`]
    static func saveFontUrl(key: String, completion: (() -> Void)? = nil) {
        var decodedFileContents: FontURLs = loadAllFontURLs() ?? []
        decodedFileContents.addIfNotExists(key)

        saveFontURLsToFile(
            fontURLs: decodedFileContents,
            errorPrefix: fontURLSaveErrorPrefix,
            completion: completion
        )
    }

    static func removeFontUrl(key: String, completion: (() -> Void)? = nil) {
        var decodedFileContents: FontURLs = loadAllFontURLs() ?? []

        guard let indexOfKey = decodedFileContents.firstIndex(of: key) else { return }

        decodedFileContents.remove(at: indexOfKey)

        saveFontURLsToFile(
            fontURLs: decodedFileContents,
            errorPrefix: fontURLDeleteErrorPrefix,
            completion: completion
        )
    }

    static func loadAllFontURLs() -> FontURLs? {
        guard let fileURL = getFileUrl(name: fontDownloadURLFileName) else { return nil }

        let decodedFileContents: [String]? = backingStore.contentsOfFileAt(url: fileURL) { result in
            if case .failure(let error) = result {
                sendDiagnosticWith(prefix: fontURLLoadErrorPrefix, error: error)
            }
        }

        return decodedFileContents
    }

    // MARK: - Font Details
    // FontDetails is a dictionary containing registered font urls and their registration names
    // [`font_url`: [`font_name`: `font_save_date`]]
    static func saveFontDetail(
        key: String,
        values: [String: String],
        completion: (() -> Void)? = nil
    ) {
        var decodedFileContents: FontDetails = loadAllFontDetails()
        decodedFileContents[key] = values

        saveFontDetailsToFile(
            fontDetails: decodedFileContents,
            errorPrefix: fontDetailsSaveErrorPrefix,
            completion: completion
        )
    }

    static func removeFontDetail(key: String, completion: (() -> Void)? = nil) {
        var decodedFileContents: FontDetails = loadAllFontDetails()
        decodedFileContents.removeValue(forKey: key)

        saveFontDetailsToFile(
            fontDetails: decodedFileContents,
            errorPrefix: fontDetailsDeleteErrorPrefix,
            completion: completion
        )
    }

    private static func loadAllFontDetails() -> FontDetails {
        guard let fileURL = getFileUrl(name: fontDownloadDetailFileName) else { return [:] }

        let decodedFileContents: FontDetails? = backingStore.contentsOfFileAt(url: fileURL) { result in
            if case .failure(let error) = result {
                sendDiagnosticWith(prefix: fontDetailsLoadErrorPrefix, error: error)
            }
        }

        return decodedFileContents ?? [:]
    }

    static func loadFontDetail(key: String) -> [String: String]? {
        loadAllFontDetails()[key]
    }

    // MARK: - Save to file
    private static func saveFontURLsToFile(
        fontURLs: [String],
        errorPrefix: String,
        completion: (() -> Void)? = nil
    ) {
        guard let fileURL = getFileUrl(name: fontDownloadURLFileName) else { return }

        saveToFile(
            data: fontURLs,
            to: fileURL,
            errorPrefix: errorPrefix,
            completion: completion
        )
    }

    private static func saveFontDetailsToFile(
        fontDetails: FontDetails,
        errorPrefix: String,
        completion: (() -> Void)? = nil
    ) {
        guard let fileURL = getFileUrl(name: fontDownloadDetailFileName) else { return }

        saveToFile(
            data: fontDetails,
            to: fileURL,
            errorPrefix: errorPrefix,
            completion: completion
        )
    }

    private static func saveToFile<T: Encodable>(
        data: T,
        to fileURL: URL,
        errorPrefix: String,
        completion: (() -> Void)? = nil
    ) {
        backingStore.write(payload: data, to: fileURL) { result in
            switch result {
            case .success:
                completion?()
            case .failure(let error):
                sendDiagnosticWith(prefix: errorPrefix, error: error)
            }
        }
    }

    // MARK: - Diagnostics
    private static func sendDiagnosticWith(prefix: String, error: Error) {
        RoktAPIHelper.sendDiagnostics(
            message: kAPIFontErrorCode,
            callStack: "\(prefix) \(error.localizedDescription)"
        )
    }

    // MARK: - FileName management
    static func setFontDownloadURLFileName(_ fileName: String) {
        fontDownloadURLFileName = fileName
    }

    static func setFontDownloadDetailFileName(_ fileName: String) {
        fontDownloadDetailFileName = fileName
    }

    internal static func getFileUrl(name: String) -> URL? {
        if let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fullPath = documentsUrl.appendingPathComponent(name).appendingPathExtension("json")
            return fullPath
        }
        return nil
    }

    internal static func isFileExist(name: String) -> Bool {
        guard let fileURL = getFileUrl(name: name) else { return false }
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
}

internal extension RangeReplaceableCollection where Element: Equatable {
    mutating func addIfNotExists(_ element: Element) {
        if let index = firstIndex(of: element) {
            remove(at: index)
        }
        insert(element, at: startIndex)
    }
}
