//
//  TestWhenViewModel.swift
//  Rokt_WidgetTests
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import XCTest
import SwiftUI

@available(iOS 15, *)
final class TestWhenViewModel: XCTestCase {
    
    func test_should_apply_progression_is_valid() {
        // Arrange
        let predicate = WhenPredicate.progression(
            ProgressionPredicate(condition: .is, value: "0"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "", pluginInstanceGuid: ""))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 0, totalOffers: 1, width: 100)
        
        // Assert
        XCTAssertTrue(shouldApply)
    }
    
    func test_should_apply_progression_is_invalid() {
        // Arrange
        let predicate = WhenPredicate.progression(
            ProgressionPredicate(condition: .is, value: "1"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "", pluginInstanceGuid: ""))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 0, totalOffers: 1, width: 100)
        
        // Assert
        XCTAssertFalse(shouldApply)
    }
    
    func test_should_apply_progression_is_not_valid() {
        // Arrange
        let predicate = WhenPredicate.progression(
            ProgressionPredicate(condition: .isNot, value: "1"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "", pluginInstanceGuid: ""))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 0, totalOffers: 1, width: 100)
        
        // Assert
        XCTAssertTrue(shouldApply)
    }
    
    func test_should_apply_progression_is_not_invalid() {
        // Arrange
        let predicate = WhenPredicate.progression(
            ProgressionPredicate(condition: .isNot, value: "1"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "", pluginInstanceGuid: ""))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 1, totalOffers: 1, width: 100)
        
        // Assert
        XCTAssertFalse(shouldApply)
    }
    
    func test_should_apply_progression_above_valid() {
        // Arrange
        let predicate = WhenPredicate.progression(
            ProgressionPredicate(condition: .isAbove, value: "0"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "", pluginInstanceGuid: ""))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 1, totalOffers: 1, width: 100)
        
        // Assert
        XCTAssertTrue(shouldApply)
    }
    
    func test_should_apply_progression_above_invalid() {
        // Arrange
        let predicate = WhenPredicate.progression(
            ProgressionPredicate(condition: .isAbove, value: "1"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "", pluginInstanceGuid: ""))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 1, totalOffers: 1, width: 100)
        
        // Assert
        XCTAssertFalse(shouldApply)
    }
    
    func test_should_apply_progression_below_valid() {
        // Arrange
        let predicate = WhenPredicate.progression(
            ProgressionPredicate(condition: .isBelow, value: "1"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "", pluginInstanceGuid: ""))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 0, totalOffers: 1, width: 100)
        
        // Assert
        XCTAssertTrue(shouldApply)
    }
    
    func test_should_apply_progression_below_invalid() {
        // Arrange
        let predicate = WhenPredicate.progression(
            ProgressionPredicate(condition: .isBelow, value: "2"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "", pluginInstanceGuid: ""))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 3, totalOffers: 3, width: 100)
        
        // Assert
        XCTAssertFalse(shouldApply)
    }
       
    // MARK: position
    func test_should_apply_position_is_valid() {
        // Arrange
        let predicate = WhenPredicate.position(
            PositionPredicate(condition: .is, value: "0"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "", pluginInstanceGuid: ""))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 0, totalOffers: 1, width: 100)
        
        // Assert
        XCTAssertTrue(shouldApply)
    }
    
    func test_should_apply_position_negative_is_valid() {
        // Arrange
        let predicate = WhenPredicate.position(
            PositionPredicate(condition: .is, value: "-1"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "", pluginInstanceGuid: ""))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 1, totalOffers: 2, width: 100)
        
        // Assert
        XCTAssertTrue(shouldApply)
    }
    
    func test_should_apply_position_is_invalid() {
        // Arrange
        let predicate = WhenPredicate.position(
            PositionPredicate(condition: .is, value: "1"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "", pluginInstanceGuid: ""))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 0, totalOffers: 1, width: 100)
        
        // Assert
        XCTAssertFalse(shouldApply)
    }
    
    func test_should_apply_position_negative_is_invalid() {
        // Arrange
        let predicate = WhenPredicate.position(
            PositionPredicate(condition: .is, value: "-1"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "", pluginInstanceGuid: ""))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 0, totalOffers: 2, width: 100)
        
        // Assert
        XCTAssertFalse(shouldApply)
    }
    
    func test_should_apply_position_is_not_valid() {
        // Arrange
        let predicate = WhenPredicate.position(
            PositionPredicate(condition: .isNot, value: "1"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "", pluginInstanceGuid: ""))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 0, totalOffers: 1, width: 100)
        
        // Assert
        XCTAssertTrue(shouldApply)
    }
    
    func test_should_apply_position_is_not_invalid() {
        // Arrange
        let predicate = WhenPredicate.position(
            PositionPredicate(condition: .isNot, value: "1"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "", pluginInstanceGuid: ""))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 1, totalOffers: 1, width: 100)
        
        // Assert
        XCTAssertFalse(shouldApply)
    }
    
    func test_should_apply_position_above_valid() {
        // Arrange
        let predicate = WhenPredicate.position(
            PositionPredicate(condition: .isAbove, value: "0"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "", pluginInstanceGuid: ""))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 1, totalOffers: 1, width: 100)
        
        // Assert
        XCTAssertTrue(shouldApply)
    }
    
    func test_should_apply_position_above_invalid() {
        // Arrange
        let predicate = WhenPredicate.position(
            PositionPredicate(condition: .isAbove, value: "1"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "", pluginInstanceGuid: ""))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 1, totalOffers: 1, width: 100)
        
        // Assert
        XCTAssertFalse(shouldApply)
    }
    
    func test_should_apply_position_below_valid() {
        // Arrange
        let predicate = WhenPredicate.position(
            PositionPredicate(condition: .isBelow, value: "1"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "", pluginInstanceGuid: ""))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 0, totalOffers: 1, width: 100)
        
        // Assert
        XCTAssertTrue(shouldApply)
    }
    
    func test_should_apply_position_below_invalid() {
        // Arrange
        let predicate = WhenPredicate.position(
            PositionPredicate(condition: .isBelow, value: "2"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "", pluginInstanceGuid: ""))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 3, totalOffers: 3, width: 100)
        
        // Assert
        XCTAssertFalse(shouldApply)
    }
    
    // MARK: Breakpoint
    
    func test_should_apply_breakpoint_is_valid() {
        // Arrange
        let predicate = WhenPredicate.breakpoint(
            BreakpointPredicate(condition: .is, value: "mobile"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "",
                                                                   pluginInstanceGuid: "",
                                                                   sharedData: get_shared_data_with_breakpoints()))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 0, totalOffers: 1, width: 1)
        
        // Assert
        XCTAssertTrue(shouldApply)
    }
    
    func test_should_apply_breakpoint_is_invalid() {
        // Arrange
        let predicate = WhenPredicate.breakpoint(
            BreakpointPredicate(condition: .is, value: "mobile"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "",
                                                                   pluginInstanceGuid: "",
                                                                   sharedData: get_shared_data_with_breakpoints()))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 0, totalOffers: 1, width: 501)
        
        // Assert
        XCTAssertFalse(shouldApply)
    }
    
    func test_should_apply_breakpoint_is_not_valid() {
        // Arrange
        let predicate = WhenPredicate.breakpoint(
            BreakpointPredicate(condition: .isNot, value: "mobile"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "",
                                                                   pluginInstanceGuid: "",
                                                                   sharedData: get_shared_data_with_breakpoints()))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 0, totalOffers: 1, width: 501)
        
        // Assert
        XCTAssertTrue(shouldApply)
    }
    
    func test_should_apply_breakpoint_is_not_invalid() {
        // Arrange
        let predicate = WhenPredicate.breakpoint(
            BreakpointPredicate(condition: .isNot, value: "mobile"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "",
                                                                   pluginInstanceGuid: "",
                                                                   sharedData: get_shared_data_with_breakpoints()))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 0, totalOffers: 1, width: 1)
        
        // Assert
        XCTAssertFalse(shouldApply)
    }
    
    func test_should_apply_breakpoint_is_below_valid() {
        // Arrange
        let predicate = WhenPredicate.breakpoint(
            BreakpointPredicate(condition: .isBelow, value: "tablet"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "",
                                                                   pluginInstanceGuid: "",
                                                                   sharedData: get_shared_data_with_breakpoints()))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 0, totalOffers: 1, width: 200)
        
        // Assert
        XCTAssertTrue(shouldApply)
    }
    
    func test_should_apply_breakpoint_is_below_invalid() {
        // Arrange
        let predicate = WhenPredicate.breakpoint(
            BreakpointPredicate(condition: .isBelow, value: "tablet"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "",
                                                                   pluginInstanceGuid: "",
                                                                   sharedData: get_shared_data_with_breakpoints()))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 0, totalOffers: 1, width: 600)
        
        // Assert
        XCTAssertFalse(shouldApply)
    }
    
    func test_should_apply_breakpoint_is_above_valid() {
        // Arrange
        let predicate = WhenPredicate.breakpoint(
            BreakpointPredicate(condition: .isAbove, value: "tablet"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "",
                                                                   pluginInstanceGuid: "",
                                                                   sharedData: get_shared_data_with_breakpoints()))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 0, totalOffers: 1, width: 1000)
        
        // Assert
        XCTAssertTrue(shouldApply)
    }
    
    func test_should_apply_breakpoint_is_above_invalid() {
        // Arrange
        let predicate = WhenPredicate.breakpoint(
            BreakpointPredicate(condition: .isAbove, value: "tablet"))
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate]),
                                   baseDI: BaseDependencyInjection(sessionId: "",
                                                                   pluginInstanceGuid: "",
                                                                   sharedData: get_shared_data_with_breakpoints()))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 0, totalOffers: 1, width: 400)
        
        // Assert
        XCTAssertFalse(shouldApply)
    }
    
    // MARK: Combination
    
    
    // Test multiple predicates together
    func test_should_apply_breakpoint_position_progression_is_valid() {
        // Arrange
        let predicate1 = WhenPredicate.breakpoint(
            BreakpointPredicate(condition: .is, value: "mobile"))
        let predicate2 = WhenPredicate.position(
            PositionPredicate(condition: .is, value: "-1"))
        let predicate3 = WhenPredicate.progression(
            ProgressionPredicate(condition: .is, value: "0"))
        
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate1, predicate2, predicate3]),
                                   baseDI: BaseDependencyInjection(sessionId: "",
                                                                   pluginInstanceGuid: "",
                                                                   sharedData: get_shared_data_with_breakpoints()))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 0, totalOffers: 1, width: 1)
        
        // Assert
        XCTAssertTrue(shouldApply)
    }
    
    // Test multiple predicates together
    func test_should_apply_breakpoint_position_progression_is_invalid() {
        // Arrange
        let predicate1 = WhenPredicate.breakpoint(
            BreakpointPredicate(condition: .is, value: "mobile"))
        // This one should fail
        let predicate2 = WhenPredicate.position(
            PositionPredicate(condition: .is, value: "-2"))
        let predicate3 = WhenPredicate.progression(
            ProgressionPredicate(condition: .is, value: "0"))
        
        let whenVM = WhenViewModel(model:
                                    WhenUIModel(children: [],
                                                predicates: [predicate1, predicate2, predicate3]),
                                   baseDI: BaseDependencyInjection(sessionId: "",
                                                                   pluginInstanceGuid: "",
                                                                   sharedData: get_shared_data_with_breakpoints()))
        // Act
        let shouldApply = whenVM.shouldApply(currentOfferIndex: 0, totalOffers: 1, width: 1)
        
        // Assert
        XCTAssertFalse(shouldApply)
    }
    
    func get_shared_data_with_breakpoints() -> SharedData {
        let sharedData = SharedData()
        sharedData.items[SharedData.breakPointsSharedKey] = ["mobile": 1,"tablet": 500, "desktop": 1000] as BreakPoint
        return sharedData
    }
    
}
