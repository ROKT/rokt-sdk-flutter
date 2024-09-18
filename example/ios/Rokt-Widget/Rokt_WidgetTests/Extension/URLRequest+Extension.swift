//
//  URLRequest+Extension.swift
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
//

import Foundation

extension URLRequest {
    func bodyStreamAsJSON() -> Any? {
        guard let bodyStream = self.httpBodyStream else { return nil }

        bodyStream.open()

        let bufferSize: Int = 16

        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)

        var data = Data()

        while bodyStream.hasBytesAvailable {
            let readData = bodyStream.read(buffer, maxLength: bufferSize)
            data.append(buffer, count: readData)
        }

        buffer.deallocate()

        bodyStream.close()

        return try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
    }
}
