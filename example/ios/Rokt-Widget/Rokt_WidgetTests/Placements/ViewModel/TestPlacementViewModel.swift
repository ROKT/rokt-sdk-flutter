//
//  TestPlacementViewModel.swift
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

class TestPlacementViewModel: XCTestCase, PlacementViewModelCallback {
    var events = [EventModel]()
    var errors = [String]()
    var engagementEvents = [RoktEventType]()
    let startDate = Date()
    
    override func setUpWithError() throws {
        Rokt.shared.roktTagId = "123"
        self.stubEvents(onEventReceive: { [self] event in
            self.events.append(event)
        })
        self.stubDiagnostics(onDiagnosticsReceive: { (error) in
            self.errors.append(error)
        })
    }
    
    // MARK: Events
    
    func test_signal_load_start_event() throws {
        // Arrange
        let viewModel = getPlacementViewModel()
        
        // Act
        viewModel.sendSignalLoadStartEvent()
        
        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalLoadStart", parentGuid: "placement1")))
        } else {
            XCTFail("No event")
        }
    }
    
    func test_signal_load_complete_event() throws {
        // Arrange
        let viewModel = getPlacementViewModel()
        
        // Act
        viewModel.sendSignalLoadCompleteEvent()
        
        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalLoadComplete", parentGuid: "placement1")))
        } else {
            XCTFail("No event")
        }
    }
    
    func test_placement_impression_event() throws {
        // Arrange
        let viewModel = getPlacementViewModel()
        
        // Act
        viewModel.sendPlacementImpressionEvent()
        
        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalImpression", parentGuid: "placement1")))
            let event = events[events.lastIndex(of: EventModel(eventType: "SignalImpression", parentGuid: "placement1"))!]
            
            XCTAssertTrue(event.containNameInMetadata(name: BE_PAGE_SIGNAL_LOAD))
            XCTAssertTrue(event.containValueInMetadata(value: EventDateFormatter.getDateString(startDate)))
        } else {
            XCTFail("No event")
        }
    }
    
    func test_slot_impression_event() throws {
        // Arrange
        let viewModel = getPlacementViewModel()
        
        // Act
        viewModel.sendSlotImpressionEvent()
        
        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalImpression", parentGuid: "Offer 1")))
        } else {
            XCTFail("No event")
        }
    }
    
    func test_signal_activation_event() throws {
        // Arrange
        let viewModel = getPlacementViewModel()
        
        // Act
        viewModel.sendSignalActivationEvent()
        
        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalActivation", parentGuid: "placement1")))
        } else {
            XCTFail("No event")
        }
    }
    
    func test_dismissal_end_message_event() throws {
        // Arrange
        let viewModel = getPlacementViewModel()
        
        // Act
        viewModel.sendDismissalEndMessageEvent()
        
        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalDismissal", parentGuid: "placement1")))
            let event = events[events.lastIndex(of: EventModel(eventType: "SignalDismissal", parentGuid: "placement1"))!]
            
            XCTAssertTrue(event.containNameInMetadata(name: kInitiator))
            XCTAssertTrue(event.containValueInMetadata(value: kEndMessage))
        } else {
            XCTFail("No event")
        }
    }

    func test_dismissal_collapsed_event() throws {
        // Arrange
        let viewModel = getPlacementViewModel()
        
        // Act
        viewModel.sendDismissalCollapsedEvent()
        
        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalDismissal", parentGuid: "placement1")))
            let event = events[events.lastIndex(of: EventModel(eventType: "SignalDismissal", parentGuid: "placement1"))!]
            
            XCTAssertTrue(event.containNameInMetadata(name: kInitiator))
            XCTAssertTrue(event.containValueInMetadata(value: kCollapsed))
        } else {
            XCTFail("No event")
        }
    }

    func test_dismissal_close_button_event() throws {
        // Arrange
        let viewModel = getPlacementViewModel()
        
        // Act
        viewModel.sendDismissalCloseEvent()
        
        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalDismissal", parentGuid: "placement1")))
            let event = events[events.lastIndex(of: EventModel(eventType: "SignalDismissal", parentGuid: "placement1"))!]
            
            XCTAssertTrue(event.containNameInMetadata(name: kInitiator))
            XCTAssertTrue(event.containValueInMetadata(value: kCloseButton))
        } else {
            XCTFail("No event")
        }
    }

    func test_dismissal_no_more_offer_event() throws {
        // Arrange
        let viewModel = getPlacementViewModel()
        
        // Act
        viewModel.sendDismissalNoMoreOfferEvent()
        
        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalDismissal", parentGuid: "placement1")))
            let event = events[events.lastIndex(of: EventModel(eventType: "SignalDismissal", parentGuid: "placement1"))!]
            
            XCTAssertTrue(event.containNameInMetadata(name: kInitiator))
            XCTAssertTrue(event.containValueInMetadata(value: kNoMoreOfferToShow))
        } else {
            XCTFail("No event")
        }
    }
    
    func test_dismissal_dimissed_event() throws {
        // Arrange
        let viewModel = getPlacementViewModel()
        
        // Act
        viewModel.sendDefaultDismissEvent()
        
        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalDismissal", parentGuid: "placement1")))
            let event = events[events.lastIndex(of: EventModel(eventType: "SignalDismissal", parentGuid: "placement1"))!]
            
            XCTAssertTrue(event.containNameInMetadata(name: kInitiator))
            XCTAssertTrue(event.containValueInMetadata(value: kDismissed))
        } else {
            XCTFail("No event")
        }
    }
    
    func test_check_first_positive_engagement() throws {
        // Arrange
        let viewModel = getPlacementViewModel()
        engagementEvents = [RoktEventType]()
        
        // Act
        viewModel.checkFirstPositiveEngagement()
        
        // Assert
        let exp = expectation(description: "Test after 0.2 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
           
            XCTAssertTrue(engagementEvents.count == 1)
            XCTAssertTrue(engagementEvents.contains(.FirstPositiveEngagement))
            
        } else {
            XCTFail("No event")
        }
    }
    
    func test_check_first_positive_engagement_trigger_only_once() throws {
        // Arrange
        let viewModel = getPlacementViewModel()
        engagementEvents = [RoktEventType]()
        
        // Act
        viewModel.checkFirstPositiveEngagement()
        viewModel.checkFirstPositiveEngagement()

        // Assert
        let exp = expectation(description: "Test after 0.2 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
           
            XCTAssertTrue(engagementEvents.count == 1)
            XCTAssertTrue(engagementEvents.contains(.FirstPositiveEngagement))
            
        } else {
            XCTFail("No event")
        }
    }
    
    
    //MARK: offer
    
    func test_go_to_next_offer_trigger_next_offer_impression() throws {
        // Arrange
        let viewModel = getPlacementViewModel()
        events = [EventModel]()
        
        // Act
        viewModel.goToNextOffer()
        
        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalImpression", parentGuid: "Offer 2")))
        } else {
            XCTFail("No event")
        }
    }
    
    func test_go_to_next_offer_skip_gost_offers() throws {
        // Arrange
        let viewModel = getPlacementViewModel()
        events = [EventModel]()
        
        // Act
        viewModel.goToNextOffer()
        
        // Assert
        let exp = expectation(description: "Test after 0.6 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.6)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalImpression", parentGuid: "Offer 3")))
            
        } else {
            XCTFail("No event")
        }
    }
    
    func test_is_journey_not_ended() throws {
        // Arrange
        let viewModel = getPlacementViewModel()
        events = [EventModel]()
        
        // Act
        let isEnded = viewModel.isJourneyEnded()
        
        // Assert
        XCTAssertFalse(isEnded)
    }
    
    func test_is_journey_ended() throws {
        // Arrange
        let viewModel = getPlacementViewModel()
        events = [EventModel]()
        
        // Act
        viewModel.goToNextOffer()
        let isEnded = viewModel.isJourneyEnded()
        
        // Assert
        XCTAssertTrue(isEnded)
    }
    
    //MARK: diagnostics
    func test_send_webview_diagnostics() throws {
        // Arrange
        let viewModel = getPlacementViewModel()
        
        // Act
        viewModel.sendWebViewDiagnostics()
        
        // Assert
        let exp = expectation(description: "Test after 0.1 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.1)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(errors.contains(kWebViewErrorCode))
        } else {
            XCTFail("No diagnostics")
        }
    }
    
    //MARK: RoktWebViewCallback
    func test_callback_move_to_next_offer() throws {
        // Arrange
        let viewModel = getPlacementViewModel()
        events = [EventModel]()
        
        // Act
        viewModel.onWebViewClosed()
        
        // Assert
        let exp = expectation(description: "Test after 0.3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(events.contains(EventModel(eventType: "SignalImpression", parentGuid: "Offer 2")))
        } else {
            XCTFail("No event")
        }
    }
    
    
    
    private func getPlacementViewModel() -> PlacementViewModel {
        return PlacementViewModel("",
                                  placement:
                                    PlacementViewData(instanceGuid: "placement1",
                                                      pageInstanceGuid: "",
                                                      launchDelayMilliseconds: 0,
                                                      placementLayoutCode: PlacementLayoutCode.embeddedLayout,
                                                      offerLayoutCode: "",
                                                      backgroundColor:
                                                        [0: "#ffffff", 1: "#ffffff"],
                                                      offers: getOffers(),
                                                      titleDivider: nil,
                                                      footerViewData: FooterViewData(backgroundColor: [0: "#ffffff", 1: "#ffffff"], roktPrivacyPolicy: nil, partnerPrivacyPolicy: nil,
                                                                                     footerDivider: DividerViewDataWithDimensions(backgroundColor: nil,
                                                                                                                                  isVisible: true,
                                                                                                                                  height: 2,
                                                                                                                                  margin: .zero),
                                                                                     alignment: .end),
                                                      backgroundWithoutFooterViewData: BackgroundWithoutFooterViewData(backgroundColor: nil, cornerRadius: nil, borderThickness: nil, borderColor: nil, padding: nil),
                                                      positiveButton: getButtonStylesViewData(),
                                                      negativeButton: getButtonStylesViewData(),
                                                      navigateToButtonData: nil,
                                                      navigateToButtonStyles: nil,
                                                      navigateToDivider: nil,
                                                      positiveButtonFirst: true,
                                                      buttonsStacked: true,
                                                      margin: FrameAlignment(top: 0, right: 0, bottom: 0, left: 0),
                                                      startDate:  startDate,
                                                      urlInExternalBrowser: false,
                                                      cornerRadius: 0,
                                                      borderThickness: 0,
                                                      borderColor: [0: "#ffffff", 1: "#ffffff"]),
                                  
                                  placementCallback: self,
                                  onEvent: onEvent)
    }
    
    func animateToNextOffer() {
        
    }
    
    func closeOnNegativeResponse() {}
    
    func onEvent(eventType: RoktEventType, eventHandler: RoktEventHandler) {
        engagementEvents.append(eventType)
    }
    
    func getOffers() -> [OfferViewData] {
        return [
            OfferViewData(instanceGuid: "Offer 1"), OfferViewData(instanceGuid: "Offer 2"), OfferViewData(instanceGuid: "Offer 3")]
    }
    
    private func getButtonStylesViewData() -> ButtonStylesViewData {
        return ButtonStylesViewData(defaultStyle: getButtonStyleViewData(),
                                    pressedStyle: getButtonStyleViewData())
    }
    
    private func getButtonStyleViewData() -> ButtonStyleViewData {
        return ButtonStyleViewData(
            textStyleViewData:
                TextStyleViewData(fontFamily: "",
                                  fontSize: 0,
                                  fontColor: [0: "#ffffff", 1: "#ffffff"],
                                  backgroundColor: [0: "#ffffff", 1: "#ffffff"]),
            cornerRadius: 0,
            borderThickness: 0,
            borderColor: [0: "#ffffff", 1: "#ffffff"])
    }
    
}
