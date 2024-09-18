//
//  TestEventProcessor.swift
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
import Mocker

final class TestEventProcessor: XCTestCase {
    var events = [EventModel]()
    var errors = [String]()
    var engagementEvents = [RoktEventType]()
    let startDate = Date()
    let responseReceivedDate = Date()
    var stubComponent = stubDCUIComponent()
    var timingsRequests = [MockTimingsRequest]()
    
    // Mocked time to test timings requests
    let timingsDate = Date()
    var timingsDateString: String {
        EventDateFormatter.getDateString(self.timingsDate)
    }
    var timingsDateEpoch: String {
        String(Int(timingsDate.timeIntervalSince1970 * 1000))
    }

    override func setUpWithError() throws {
        Rokt.shared.roktTagId = "123"
        Rokt.shared.processedEvents = ProcessedEventViewModel()
        
        // Mock date
        DateHandler.customDate = timingsDate
        
        // Setup timings that occur before event processor
        Rokt.shared.processedTimingsRequests = ProcessedTimingsRequestViewModel()
        Rokt.shared.processedTimingsRequests?.setInitStartTime()
        Rokt.shared.processedTimingsRequests?.setInitEndTime()
        Rokt.shared.processedTimingsRequests?.setPageInitTime()
        Rokt.shared.processedTimingsRequests?.setSelectionStartTime()
        Rokt.shared.processedTimingsRequests?.setExperiencesRequestStartTime()
        Rokt.shared.processedTimingsRequests?.setExperiencesRequestEndTime()
        Rokt.shared.processedTimingsRequests?.setSelectionEndTime()
        Rokt.shared.processedTimingsRequests?.setPageProperties(pageId: mockPageId,
                                                                pageInstanceGuid: mockPageInstanceGuid)
        
        Rokt.shared.initFeatureFlags = InitFeatureFlags(roktTrackingStatus: true,
                                                        shouldLogFontHappyPath: false,
                                                        shouldUseFontRegisterWithUrl: false,
                                                        featureFlags: ["mobile-sdk-use-timings-api": FeatureFlagItem(match: true)])

        self.stubEvents(onEventReceive: { [self] event in
            self.events.append(event)
        })
        self.stubDiagnostics(onDiagnosticsReceive: { (error) in
            self.errors.append(error)
        })
        self.stubTimings(onTimingsRequestReceive: { [self] request in
            self.timingsRequests.append(request)
        })
        self.stubComponent = stubDCUIComponent()
    }

    // MARK: Events
    func test_sendEventsOnTransformerSuccess_readyEventsAndLoadCompleteSignals_shouldSend() throws {
        // Arrange
        let baseDI = get_base_di()
        let eventProcessor = baseDI.eventProcessor
        self.stubComponent.addAllListeners(eventCollection: baseDI.eventCollection)

        // Act
        eventProcessor.sendEventsOnTransformerSuccess()

        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalLoadComplete",
                                                     parentGuid: mockPluginInstanceGuid,
                                                     jwtToken: mockPluginConfigJWTToken)))
            
            // Rokt callbacks
            XCTAssertEqual(stubComponent.roktEvents.count, 1)
            XCTAssertTrue(stubComponent.roktEvents.contains(.PlacementReady))
        } else {
            XCTFail("No event")
        }
    }
    
    func test_sendEventsOnLoad_interactiveEventsAndImpressionSignals_shouldSend() throws {
        // Arrange
        let baseDI = get_base_di()
        let eventProcessor = baseDI.eventProcessor
        self.stubComponent.addAllListeners(eventCollection: baseDI.eventCollection)

        // Act
        eventProcessor.sendEventsOnLoad()

        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalImpression",
                                                     parentGuid: mockPluginInstanceGuid,
                                                     jwtToken: mockPluginConfigJWTToken)))
            let event = events[events.lastIndex(of: EventModel(eventType: "SignalImpression",
                                                               parentGuid: mockPluginInstanceGuid,
                                                               jwtToken: mockPluginConfigJWTToken))!]

            XCTAssertTrue(event.containNameInMetadata(name: BE_PAGE_SIGNAL_LOAD))
            XCTAssertTrue(event.containValueInMetadata(value: EventDateFormatter.getDateString(startDate)))
            XCTAssertTrue(event.containNameInMetadata(name: BE_PAGE_RENDER_ENGINE))
            XCTAssertTrue(event.containValueInMetadata(value: BE_RENDER_ENGINE_LAYOUTS))
            
            // Rokt callbacks
            XCTAssertEqual(stubComponent.roktEvents.count, 1)
            XCTAssertTrue(stubComponent.roktEvents.contains(.PlacementInteractive))
        } else {
            XCTFail("No event")
        }
    }

    func test_slot_impression_event() throws {
        // Arrange
        let baseDI = get_base_di()
        let eventProcessor = baseDI.eventProcessor

        // Act
        eventProcessor.sendSlotImpressionEvent(instanceGuid: "instanceGuid", jwtToken: "jwt-token")

        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalImpression", parentGuid: "instanceGuid", jwtToken: "jwt-token")))
        } else {
            XCTFail("No event")
        }
    }

    func test_two_unique_slot_impression_event() throws {
        // Arrange
        let baseDI = get_base_di()
        let eventProcessor = baseDI.eventProcessor

        // Act
        eventProcessor.sendSlotImpressionEvent(instanceGuid: "instanceGuid1", jwtToken: "jwt-token")
        eventProcessor.sendSlotImpressionEvent(instanceGuid: "instanceGuid2", jwtToken: "jwt-token")

        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalImpression", parentGuid: "instanceGuid1", jwtToken: "jwt-token")))
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalImpression", parentGuid: "instanceGuid2", jwtToken: "jwt-token")))
            XCTAssertEqual(events.count, 2)
            XCTAssertEqual(Rokt.shared.processedEvents.processedEvents.count, 2)
        } else {
            XCTFail("No event")
        }
    }

    func test_two_duplicate_slot_impression_event() throws {
        // Arrange
        let baseDI = get_base_di()
        let eventProcessor = baseDI.eventProcessor

        // Act
        eventProcessor.sendSlotImpressionEvent(instanceGuid: "instanceGuid1", jwtToken: "jwt-token")
        eventProcessor.sendSlotImpressionEvent(instanceGuid: "instanceGuid1", jwtToken: "jwt-token")

        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalImpression", parentGuid: "instanceGuid1", jwtToken: "jwt-token")))
            XCTAssertEqual(events.count, 1)
            XCTAssertEqual(Rokt.shared.processedEvents.processedEvents.count, 1)
        } else {
            XCTFail("No event")
        }
    }

    func test_plugin_activation_event() throws {
        // Arrange
        let baseDI = get_base_di()
        let eventProcessor = baseDI.eventProcessor

        // Act
        eventProcessor.sendSignalActivationEvent()

        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalActivation",
                                                     parentGuid: mockPluginInstanceGuid,
                                                     jwtToken: mockPluginConfigJWTToken)))
        } else {
            XCTFail("No event")
        }
    }
    
    func test_sendSignalResponse_onPositive_engagementEventsAndSignals_shouldSend() throws {
        // Arrange
        let baseDI = get_base_di()
        var eventProcessor = baseDI.eventProcessor
        self.stubComponent.addAllListeners(eventCollection: baseDI.eventCollection)

        // Act
        eventProcessor.sendSignalResponseEvent(instanceGuid: "instanceGuid", jwtToken: "plugin-token", isPositive: true)

        // Assert
        let exp = expectation(description: "Test after 0.35 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.35)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalResponse", parentGuid: "instanceGuid", jwtToken: "plugin-token")))
            
            // Rokt callbacks
            XCTAssertEqual(stubComponent.roktEvents.count, 2)
            XCTAssertTrue(stubComponent.roktEvents.contains(.PositiveEngagement))
            XCTAssertTrue(stubComponent.roktEvents.contains(.OfferEngagement))
        } else {
            XCTFail("No event")
        }
    }

    func test_sendDismissal_onNoMoreOffer_dismissalEventsAndSignals_shouldSend() throws {
        // Arrange
        let baseDI = get_base_di()
        var eventProcessor = baseDI.eventProcessor
        self.stubComponent.addAllListeners(eventCollection: baseDI.eventCollection)

        // Act
        eventProcessor.dismissOption = .noMoreOffer
        eventProcessor.sendDismissalEvent()

        // Assert
        let exp = expectation(description: "Test after 0.35 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.35)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalDismissal",
                                                     parentGuid: mockPluginInstanceGuid,
                                                     jwtToken: mockPluginConfigJWTToken)))
            let event = events[events.lastIndex(of: EventModel(eventType: "SignalDismissal",
                                                               parentGuid: mockPluginInstanceGuid,
                                                               jwtToken: mockPluginConfigJWTToken))!]

            XCTAssertTrue(event.containNameInMetadata(name: kInitiator))
            XCTAssertTrue(event.containValueInMetadata(value: kNoMoreOfferToShow))
            
            // Rokt callbacks
            XCTAssertEqual(stubComponent.roktEvents.count, 1)
            XCTAssertTrue(stubComponent.roktEvents.contains(.PlacementCompleted))
        } else {
            XCTFail("No event")
        }
    }
    
    func test_sendDismissal_onCloseButton_dismissalEventsAndSignals_shouldSend() throws {
        // Arrange
        let baseDI = get_base_di()
        var eventProcessor = baseDI.eventProcessor
        self.stubComponent.addAllListeners(eventCollection: baseDI.eventCollection)

        // Act
        eventProcessor.dismissOption = .closeButton
        eventProcessor.sendDismissalEvent()

        // Assert
        let exp = expectation(description: "Test after 0.35 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.35)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalDismissal",
                                                     parentGuid: mockPluginInstanceGuid,
                                                     jwtToken: mockPluginConfigJWTToken)))
            let event = events[events.lastIndex(of: EventModel(eventType: "SignalDismissal",
                                                               parentGuid: mockPluginInstanceGuid,
                                                               jwtToken: mockPluginConfigJWTToken))!]

            XCTAssertTrue(event.containNameInMetadata(name: kInitiator))
            XCTAssertTrue(event.containValueInMetadata(value: kCloseButton))
            
            // Rokt callbacks
            XCTAssertEqual(stubComponent.roktEvents.count, 1)
            XCTAssertTrue(stubComponent.roktEvents.contains(.PlacementClosed))
        } else {
            XCTFail("No event")
        }
    }

    func test_dismissal_dimissed_event() throws {
        // Arrange
        let baseDI = get_base_di()
        var eventProcessor = baseDI.eventProcessor

        // Act
        eventProcessor.dismissOption = .defaultDismiss
        eventProcessor.sendDismissalEvent()

        // Assert
        let exp = expectation(description: "Test after 0.5 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.5)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalDismissal",
                                                     parentGuid: mockPluginInstanceGuid,
                                                     jwtToken: mockPluginConfigJWTToken)))
            let event = events[events.lastIndex(of: EventModel(eventType: "SignalDismissal",
                                                               parentGuid: mockPluginInstanceGuid,
                                                               jwtToken: mockPluginConfigJWTToken))!]
            XCTAssertTrue(event.containNameInMetadata(name: kInitiator))
            XCTAssertTrue(event.containValueInMetadata(value: kDismissed))
        } else {
            XCTFail("No event")
        }
    }
    
    // MARK: Timings
    func test_sendTimingsRequest_withPlacementInteractive_shouldContainAllTimings() throws {
        // Arrange
        let baseDI = get_base_di()
        let eventProcessor = baseDI.eventProcessor

        // Act
        eventProcessor.sendTimingsWithPlacementInteractive()

        // Assert
        let exp = expectation(description: "Test after 0.6 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.6)
        if result == XCTWaiter.Result.timedOut {
            let expectedTimingsRequest = MockTimingsRequest(eventTime: timingsDateString,
                                                            pageId: mockPageId,
                                                            pageInstanceGuid: mockPageInstanceGuid,
                                                            pluginId: mockPluginId,
                                                            pluginName: mockPluginName,
                                                            timings: [])
            XCTAssertTrue(timingsRequests.contains(expectedTimingsRequest))
            let matchedTimingsRequest = timingsRequests[timingsRequests.lastIndex(of: expectedTimingsRequest)!]
            XCTAssertTrue(matchedTimingsRequest.containNameValueInTimings(name: TimingType.initStart.rawValue,
                                                                          value: timingsDateEpoch))
            XCTAssertTrue(matchedTimingsRequest.containNameValueInTimings(name: TimingType.initEnd.rawValue,
                                                                          value: timingsDateEpoch))
            XCTAssertTrue(matchedTimingsRequest.containNameValueInTimings(name: TimingType.selectionStart.rawValue,
                                                                          value: timingsDateEpoch))
            XCTAssertTrue(matchedTimingsRequest.containNameValueInTimings(name: TimingType.experiencesRequestStart.rawValue,
                                                                          value: timingsDateEpoch))
            XCTAssertTrue(matchedTimingsRequest.containNameValueInTimings(name: TimingType.experiencesRequestEnd.rawValue,
                                                                          value: timingsDateEpoch))
            XCTAssertTrue(matchedTimingsRequest.containNameValueInTimings(name: TimingType.selectionEnd.rawValue,
                                                                          value: timingsDateEpoch))
            XCTAssertTrue(matchedTimingsRequest.containNameValueInTimings(name: TimingType.pageInit.rawValue,
                                                                          value: timingsDateEpoch))
            XCTAssertTrue(matchedTimingsRequest.containNameValueInTimings(name: TimingType.placementInteractive.rawValue,
                                                                          value: timingsDateEpoch))
        } else {
            XCTFail("No timings request")
        }
    }
    
    func get_base_di() -> BaseDependencyInjection {
        return BaseDependencyInjection(sessionId: "session",
                                       pluginModel: mockPluginModel,
                                       startDate: startDate,
                                       responseReceivedDate: responseReceivedDate,
                                       config: nil)
    }
}

class stubDCUIComponent: RoktEventListener {
    
    var roktEvents = [RoktEventListenerType]()
    
    func onOfferEngagement() {
        self.roktEvents.append(.OfferEngagement)
    }
    
    func onPositiveEngagement() {
        self.roktEvents.append(.PositiveEngagement)
    }
    
    func onShowLoadingIndicator() {
        self.roktEvents.append(.ShowLoadingIndicator)
    }
    
    func onHideLoadingIndicator() {
        self.roktEvents.append(.HideLoadingIndicator)
    }
    
    func onPlacementInteractive() {
        self.roktEvents.append(.PlacementInteractive)
    }
    
    func onPlacementReady() {
        self.roktEvents.append(.PlacementReady)
    }
    
    func onPlacementClosed() {
        self.roktEvents.append(.PlacementClosed)
    }
    
    func onPlacementCompleted() {
        self.roktEvents.append(.PlacementCompleted)
    }
    
    func onPlacementFailure() {
        self.roktEvents.append(.PlacementFailure)
    }
}
