//
//  ExecuteSession.swift
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
struct ExecuteSession {
    private var sessionId: String
    private let expiry: Double
    private var lastUsed: Date = Date()

    mutating func getSessionId(validSessionRequired: Bool) -> String {
        if validSessionRequired {
            guard isNotExpired() else {
                return ""
            }
        }
        // only extend the session when it is not expired
        if isNotExpired() {
            lastUsed = Date()
        }
        return sessionId
    }

    init(sessionId: String, expiry: Double) {
        self.sessionId = sessionId
        self.expiry = expiry
        self.lastUsed = Date()
    }

    func isNotExpired() -> Bool {
        return Date().timeIntervalSince(lastUsed) * 1000 < expiry
    }

}
