//
//  TestDistributionViewModel.swift
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

final class TestDistributionViewModel: XCTestCase {
    var events = [EventModel]()
    var errors = [String]()
    let startDate = Date()

    override func setUpWithError() throws {
        Rokt.shared.roktTagId = "123"
        Rokt.shared.processedEvents = ProcessedEventViewModel()
        self.stubEvents(onEventReceive: { [self] event in
            print("event: \(event)")
            self.events.append(event)
        })
        self.stubDiagnostics(onDiagnosticsReceive: { (error) in
            self.errors.append(error)
        })
    }
    
    func test_slot_impression_event() throws {
        // Arrange
        let viewModel = getDistributionViewModel()

        // Act
        viewModel.sendSlotImpressionEvent(currentOffer: 0)

        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalImpression", parentGuid: "Slot1", jwtToken: "JwtToken0")))
        } else {
            XCTFail("No event")
        }
    } 
    
    func test_creative_impression_event() throws {
        // Arrange
        let viewModel = getDistributionViewModel()

        // Act
        viewModel.sendCreativeImpressionEvent(currentOffer: 0)

        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalImpression", parentGuid: "instanceGuid", jwtToken: "jwtToken1")))
        } else {
            XCTFail("No event")
        }
    }
    
    func test_dismissal_no_more_offer_event() throws {
        // Arrange
        let viewModel = getDistributionViewModel()

        // Act
        viewModel.sendDismissalNoMoreOfferEvent()

        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalDismissal",
                                                     parentGuid: mockPluginInstanceGuid,
                                                     jwtToken: mockPluginConfigJWTToken)))
            let event = events[events.lastIndex(of: EventModel(eventType: "SignalDismissal",
                                                               parentGuid: mockPluginInstanceGuid,
                                                               jwtToken: mockPluginConfigJWTToken))!]

            XCTAssertTrue(event.containNameInMetadata(name: kInitiator))
            XCTAssertTrue(event.containValueInMetadata(value: kNoMoreOfferToShow))
        } else {
            XCTFail("No event")
        }
    }
    
    func test_dismissal_collapsed_event() throws {
        // Arrange
        let viewModel = getDistributionViewModel()

        // Act
        viewModel.sendDismissalCollapsedEvent()

        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalDismissal",
                                                     parentGuid: mockPluginInstanceGuid,
                                                     jwtToken: mockPluginConfigJWTToken)))
            let event = events[events.lastIndex(of: EventModel(eventType: "SignalDismissal",
                                                               parentGuid: mockPluginInstanceGuid,
                                                               jwtToken: mockPluginConfigJWTToken))!]

            XCTAssertTrue(event.containNameInMetadata(name: kInitiator))
            XCTAssertTrue(event.containValueInMetadata(value: kCollapsed))
        } else {
            XCTFail("No event")
        }
    }


    private func getDistributionViewModel() -> DistributionViewModel {
        return DistributionViewModel(baseDI: 
                                        BaseDependencyInjection(sessionId: "SessionId",
                                                                pluginModel: mockPluginModel,
                                                                startDate: startDate,
                                                                slots: [getSlot()],
                                                                config: nil))
    }
    
    private func getSlot() -> SlotModel {
        return SlotModel(instanceGuid: "Slot1",
                         offer: OfferModel(campaignId: "Campaign1", creative: CreativeModel(referralCreativeId: "referralCreativeId1", instanceGuid: "instanceGuid", copy: [String:String](), images: nil, links: nil, responseOptionsMap: nil, jwtToken: "jwtToken1")), layoutVariant: nil, jwtToken: "JwtToken0")
    }
}
