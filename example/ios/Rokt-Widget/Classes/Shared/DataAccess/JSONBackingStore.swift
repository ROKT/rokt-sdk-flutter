//
//  JSONBackingStore.swift
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

protocol FileStorage {
    func write<T: Encodable>(payload: T, to fileURL: URL, completion: ((Result<Void, Error>) -> Void)?)
    func contentsOfFileAt<T: Decodable>(url: URL, completion: ((Result<T, Error>) -> Void)?) -> T?
    func getFileUrl(fileName: String) -> URL?
    func isFileExistent(fileName: String) -> Bool
}

class JSONBackingStore: FileStorage {
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func write<T: Encodable>(payload: T, to fileURL: URL, completion: ((Result<Void, Error>) -> Void)?) {
        do {
            let encodedData = try JSONEncoder().encode(payload)
            try encodedData.write(to: fileURL)
            completion?(.success(()))
        } catch {
            completion?(.failure(error))
        }
    }

    func contentsOfFileAt<T: Decodable>(url: URL, completion: ((Result<T, Error>) -> Void)?) -> T? {
        do {
            guard fileManager.fileExists(atPath: url.path) else { return nil }

            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            let decodedData = try JSONDecoder().decode(T.self, from: data)

            completion?(.success(decodedData))

            return decodedData
        } catch {
            completion?(.failure(error))

            return nil
        }
    }

    func getFileUrl(fileName: String) -> URL? {
        guard let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            return nil
        }
        return documentsUrl.appendingPathComponent(fileName).appendingPathExtension("json")
    }

    func isFileExistent(fileName: String) -> Bool {
        guard let fileURL = getFileUrl(fileName: fileName) else { return false }
        return fileManager.fileExists(atPath: fileURL.path)
    }
}
