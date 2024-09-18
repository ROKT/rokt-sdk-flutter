//
//  ConcurrentQueueFileStorageDecorator.swift
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

class ConcurrentQueueFileStorageDecorator: FileStorage {
    private let concurrentQueue: DispatchQueue!
    private let decoratee: FileStorage

    init(queueName: String, decoratee: FileStorage) {
        self.concurrentQueue = DispatchQueue(label: queueName, attributes: .concurrent)
        self.decoratee = decoratee
    }

    // WRITES should be asynchronous and use a `barrier`
    func write<T: Encodable>(payload: T, to fileURL: URL, completion: ((Result<Void, Error>) -> Void)?) {
        concurrentQueue.async(flags: .barrier) { [weak self] in
            self?.decoratee.write(payload: payload, to: fileURL, completion: completion)
        }
    }

    // READS should be synchronous
    func contentsOfFileAt<T: Decodable>(url: URL, completion: ((Result<T, Error>) -> Void)?) -> T? {
        concurrentQueue.sync { [weak self] in
            self?.decoratee.contentsOfFileAt(url: url, completion: completion)
        }
    }

    func getFileUrl(fileName: String) -> URL? {
        decoratee.getFileUrl(fileName: fileName)
    }

    func isFileExistent(fileName: String) -> Bool {
        decoratee.isFileExistent(fileName: fileName)
    }
}
