//
//  TestExecuteSession.swift
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

final class TestExecuteSession: XCTestCase {

    // valid session should not be expired before expiry date
    func test_execute_session_valid_session() throws {
        //Arrange
        var executeSession = ExecuteSession(sessionId: "session", expiry: 1000)
        
        //Act
        let firstValidSession = executeSession.getSessionId(validSessionRequired: true)
        let secondValidSession = executeSession.getSessionId(validSessionRequired: true)
        
        //Assert
        XCTAssertEqual(firstValidSession, secondValidSession)
    }
    
    // valid session should be expired after expiry date
    func test_execute_session_invalid_session() throws {
        //Arrange
        var executeSession = ExecuteSession(sessionId: "session", expiry: 400)
        //Assert
        let exp = expectation(description: "Test after 0.5 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.5)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(executeSession.getSessionId(validSessionRequired: true), "")
        } else {
            XCTFail("Session is not expired")
        }
    }
    
    func test_execute_session_expired_session() throws {
        //Arrange
        var executeSession = ExecuteSession(sessionId: "session", expiry: 1000)
        
        //Act
        let firstValidSession = executeSession.getSessionId(validSessionRequired: false)
        let secondValidSession = executeSession.getSessionId(validSessionRequired: false)
        
        //Assert
        XCTAssertEqual(firstValidSession, secondValidSession)
    }
    
    // session should not be expired after expiry
    func test_execute_session_expired_session_after_expiry() throws {
        //Arrange
        var executeSession = ExecuteSession(sessionId: "session", expiry: 400)
        let date = Date()
        //Assert
        let exp = expectation(description: "Test after 0.5 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.5)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(executeSession.getSessionId(validSessionRequired: false), "session")
        } else {
            XCTFail("Session is expired")
        }
    }
}
