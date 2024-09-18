//
//  TestCreativeResponseViewModel.swift
//  Rokt_WidgetTests
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import XCTest
import Mocker

@available(iOS 15, *)
final class TestCreativeResponseViewModel: XCTestCase {
    
    var events = [EventModel]()
    var errors = [String]()
    
    override func setUpWithError() throws {
        Rokt.shared.roktTagId = "123"
        self.stubEvents(onEventReceive: { [self] event in
            self.events.append(event)
        })
        self.stubDiagnostics(onDiagnosticsReceive: { (error) in
            self.errors.append(error)
        })
    }
    
    func test_send_signal_impression_event() throws {
        // Arrange
        let creativeResponseUIModel = CreativeResponseUIModel(children: [],
                                                              responseKey: .positive,
                                                              responseOptions:
                                                                ResponseOption(id: "",
                                                                               action: .url,
                                                                               instanceGuid: "creativeInstance",
                                                                               signalType: .signalResponse,
                                                                               shortLabel: "",
                                                                               longLabel: "",
                                                                               shortSuccessLabel: "",
                                                                               isPositive: nil,
                                                                               url: "", 
                                                                               responseJWTToken: "response-jwt"),
                                                              openLinks: nil,
                                                              defaultStyle: nil,
                                                              pressedStyle: nil,
                                                              hoveredStyle: nil,
                                                              disabledStyle: nil)
        let viewModel = CreativeResponseViewModel(model: creativeResponseUIModel, baseDI: get_base_di())
        
        // Act
        viewModel.sendSignalResponseEvent()
        
        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalResponse", parentGuid: "creativeInstance", jwtToken: "response-jwt")))
        } else {
            XCTFail("No event")
        }
    }
    
    func test_send_signal_gated_impression_event() throws {
        // Arrange
        let creativeResponseUIModel = CreativeResponseUIModel(children: [],
                                                              responseKey: .positive,
                                                              responseOptions:
                                                                ResponseOption(id: "",
                                                                               action: .url,
                                                                               instanceGuid: "creativeInstance",
                                                                               signalType: .signalGatedResponse,
                                                                               shortLabel: "",
                                                                               longLabel: "",
                                                                               shortSuccessLabel: "",
                                                                               isPositive: nil,
                                                                               url: "", 
                                                                               responseJWTToken: "response-jwt"),
                                                              openLinks: nil,
                                                              defaultStyle: nil,
                                                              pressedStyle: nil,
                                                              hoveredStyle: nil,
                                                              disabledStyle: nil)
        let viewModel = CreativeResponseViewModel(model: creativeResponseUIModel, baseDI: get_base_di())
        
        // Act
        viewModel.sendSignalResponseEvent()
        
        // Assert
        let exp = expectation(description: "Test after 0.5 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.5)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalGatedResponse", parentGuid: "creativeInstance", jwtToken: "response-jwt")))
        } else {
            XCTFail("No event")
        }
    }
    
    func test_get_valid_url() throws {
        // Arrange
        let creativeResponseUIModel = CreativeResponseUIModel(children: [],
                                                              responseKey: .positive,
                                                              responseOptions:
                                                                ResponseOption(id: "",
                                                                               action: .url,
                                                                               instanceGuid: "creativeInstance",
                                                                               signalType: .signalGatedResponse,
                                                                               shortLabel: "",
                                                                               longLabel: "",
                                                                               shortSuccessLabel: "",
                                                                               isPositive: nil,
                                                                               url: "https://www.google.com", 
                                                                               responseJWTToken: "response-jwt"),
                                                              openLinks: nil,
                                                              defaultStyle: nil,
                                                              pressedStyle: nil,
                                                              hoveredStyle: nil,
                                                              disabledStyle: nil)
        let viewModel = CreativeResponseViewModel(model: creativeResponseUIModel, baseDI: get_base_di())
        // Act
        let url = viewModel.getOfferUrl()
        // Assert
        XCTAssertEqual(url, URL(string: "https://www.google.com"))
    }
    
    func test_get_inavlid_url_nil() throws {
        // Arrange
        let creativeResponseUIModel = CreativeResponseUIModel(children: [],
                                                              responseKey: .positive,
                                                              responseOptions:
                                                                ResponseOption(id: "",
                                                                               action: .url,
                                                                               instanceGuid: "creativeInstance",
                                                                               signalType: .signalGatedResponse,
                                                                               shortLabel: "",
                                                                               longLabel: "",
                                                                               shortSuccessLabel: "",
                                                                               isPositive: nil,
                                                                               url: nil, 
                                                                               responseJWTToken: "response-jwt"),
                                                              openLinks: nil,
                                                              defaultStyle: nil,
                                                              pressedStyle: nil,
                                                              hoveredStyle: nil,
                                                              disabledStyle: nil)
        let viewModel = CreativeResponseViewModel(model: creativeResponseUIModel, baseDI: get_base_di())
        // Act
        let url = viewModel.getOfferUrl()
        // Assert
        XCTAssertNil(url)
    }
    
    
    func test_get_inavlid_url_nil_when_action_is_not_url() throws {
        // Arrange
        let creativeResponseUIModel = CreativeResponseUIModel(children: [],
                                                              responseKey: .positive,
                                                              responseOptions:
                                                                ResponseOption(id: "",
                                                                               action: .captureOnly,
                                                                               instanceGuid: "creativeInstance",
                                                                               signalType: .signalGatedResponse,
                                                                               shortLabel: "",
                                                                               longLabel: "",
                                                                               shortSuccessLabel: "",
                                                                               isPositive: nil,
                                                                               url: nil,
                                                                               responseJWTToken: "response-jwt"),
                                                              openLinks: nil,
                                                              defaultStyle: nil,
                                                              pressedStyle: nil,
                                                              hoveredStyle: nil,
                                                              disabledStyle: nil)
        let viewModel = CreativeResponseViewModel(model: creativeResponseUIModel, baseDI: get_base_di())
        // Act
        let url = viewModel.getOfferUrl()
        // Assert
        XCTAssertNil(url)
    }
    
    func get_base_di() -> BaseDependencyInjection {
        return BaseDependencyInjection(sessionId: "session",
                                       pluginModel: mockPluginModel,
                                       startDate: Date(),
                                       config: nil)
    }
    
}
