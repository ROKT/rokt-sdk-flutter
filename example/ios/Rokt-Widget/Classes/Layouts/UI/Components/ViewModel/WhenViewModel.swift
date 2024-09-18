//
//  WhenViewModel.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation

@available(iOS 15, *)
struct WhenViewModel {
    let model: WhenUIModel
    let baseDI: BaseDependencyInjection

    private var darkModePredicates: [DarkModePredicate] {
        model.predicates?.compactMap {
            switch $0 {
            case .darkMode(let predicate): return predicate
            default: return nil
            }
        } ?? []
    }

    private var progressionPredicates: [ProgressionPredicate] { model.predicates?.compactMap {
        switch $0 {
        case .progression(let predicate): return predicate
        default: return nil
        }
    } ?? [] }
    
    private var breakPointPredicates: [BreakpointPredicate] { model.predicates?.compactMap {
        switch $0 {
        case .breakpoint(let predicate): return predicate
        default: return nil
        }
    } ?? [] }
    
    private var positionPredicates: [PositionPredicate] { model.predicates?.compactMap {
        switch $0 {
        case .position(let predicate): return predicate
        default: return nil
        }
    } ?? [] }
    
    private var staticBooleanPredicates: [StaticBooleanPredicate] { model.predicates?.compactMap {
        switch $0 {
        case .staticBoolean(let predicate): return predicate
        default: return nil
        }
    } ?? [] }
    
    private var creativeCopyPredicates: [CreativeCopyPredicate] { model.predicates?.compactMap {
        switch $0 {
        case .creativeCopy(let predicate): return predicate
        default: return nil
        }
    } ?? [] }
    
    private var staticStringPredicates: [StaticStringPredicate] { model.predicates?.compactMap {
        switch $0 {
        case .staticString(let predicate): return predicate
        default: return nil
        }
    } ?? [] }
    
    private var customStatePredicates: [CustomStatePredicate] { model.predicates?.compactMap {
        switch $0 {
        case .customState(let predicate): return predicate
        default: return nil
        }
    } ?? [] }

    private func progressionPredicatesMatched(currentProgress: Int) -> Bool? {
        // currentProgress refer to currentOffer in Onebyone and current page in carousel
        
        // don't apply if the predicates is empty
        guard !progressionPredicates.isEmpty else { return nil }

        // Predicates need to applied if all of the preicates are met.
        // The default is true and will be used by && operation on each predicates
        var matched = true

        progressionPredicates.forEach { predicate in
            if let value = Int(predicate.value) {
                switch predicate.condition {
                case .is:
                    matched = matched && currentProgress == value
                case .isNot:
                    matched = matched && currentProgress != value
                case .isAbove:
                    matched = matched && currentProgress > value
                case .isBelow:
                    matched = matched && currentProgress < value
                }
            }
        }

        return matched
    }
    
    private func positionPredicatesMatched(offerPosition: Int?, totalOffers: Int) -> Bool? {
        
        // don't apply if the predicates is empty
        guard !positionPredicates.isEmpty else { return nil }

        // position should not apply on outer layer to match web behaviour
        guard let offerPosition else { return false}
        
        // Predicates need to applied if all of the preicates are met.
        // The default is true and will be used by && operation on each predicates
        var matched = true

        positionPredicates.forEach { predicate in
            if let value = Int(predicate.value) {
                // If the predicate value is negative, the value should be calculated from last
                // Eg: Total offers = 4, Predicate value = -1 then the result should be 3(last position)
                //     Total offers = 4, Predicate value = -2 then the result should be 2(second last position)
                let position = value >= 0 ? value : totalOffers + value
                
                switch predicate.condition {
                case .is:
                    matched = matched && offerPosition == position
                case .isNot:
                    matched = matched && offerPosition != position
                case .isAbove:
                    matched = matched && offerPosition > position
                case .isBelow:
                    matched = matched && offerPosition < position
                }
            }
        }

        return matched
    }

    private func breakPointOrientationPredicatesMatched(width: CGFloat) -> Bool? {
        guard !breakPointPredicates.isEmpty,
              let globalBreakPoints = baseDI.sharedData.items[SharedData.breakPointsSharedKey] as? BreakPoint,
              !globalBreakPoints.isEmpty
        else { return nil }

        var matched = true

        breakPointPredicates.forEach { predicate in
            if let globalBreakPointValue = globalBreakPoints[predicate.value] {
                switch predicate.condition {
                case .is:
                    matched = matched && Double(width).precised() == (Double(globalBreakPointValue).precised())
                case .isNot:
                    matched = matched && Double(width).precised() != (Double(globalBreakPointValue).precised())
                case .isAbove:
                    matched = matched && Double(width).precised() > (Double(globalBreakPointValue).precised())
                case .isBelow:
                    matched = matched && Double(width).precised() < (Double(globalBreakPointValue).precised())
                }
            }
        }

        return matched
    }

    private func darkModePredicatesMatched(isDarkMode: Bool) -> Bool? {
        // don't apply if the predicates is empty
        guard !darkModePredicates.isEmpty else { return nil }

        // Predicates need to applied if all of the predicates are met.
        // The default is true and will be used by && operation on each predicate
        var matched = true

        darkModePredicates.forEach { predicate in
            switch predicate.condition {
            case .is:
                matched = matched && isDarkMode == predicate.value
            case .isNot:
                matched = matched && isDarkMode != predicate.value
            }
        }
        
        return matched
    }
    
    private func staticBooleanPredicatesMatched() -> Bool? {

        guard !staticBooleanPredicates.isEmpty else { return nil }

        // Predicates need to applied if all of the predicates are met.
        // The default is true and will be used by && operation on each predicate
        var matched = true

        staticBooleanPredicates.forEach { predicate in
            switch predicate.condition {
            case .isTrue:
                matched = matched && predicate.value
            case .isFalse:
                matched = matched && !predicate.value
            }
        }

        return matched
    }
    
    private func creativeCopyMatched(offerPosition: Int) -> Bool? {
        guard !creativeCopyPredicates.isEmpty else { return nil }

        // Predicates need to applied if all of the predicates are met.
        // The default is true and will be used by && operation on each predicate
        var matched = true

        creativeCopyPredicates.forEach { predicate in
            let value = predicate.value
            
            switch predicate.condition {
            case .exists:
                matched = matched && !(getCreativeCopy(offerPosition)[value] ?? "").isEmpty
            case .notExists:
                matched = matched && getCreativeCopy(offerPosition)[value] == nil
            }
        }

        return matched
    }
    
    private func getCreativeCopy(_ offerPosition: Int) -> [String: String] {
        guard baseDI.slots.count > offerPosition else { return [:] }
        return baseDI.slots[offerPosition].offer?.creative.copy ?? [:]
    }
    
    private func staticStringPredicatesMatched() -> Bool? {

        guard !staticStringPredicates.isEmpty else { return nil }

        // Predicates need to applied if all of the predicates are met.
        // The default is true and will be used by && operation on each predicate
        var matched = true

        staticStringPredicates.forEach { predicate in
            switch predicate.condition {
            case .is:
                matched = matched && (predicate.input == predicate.value)
            case .isNot:
                matched = matched && (predicate.input != predicate.value)
            }
        }

        return matched
    }
    
    private func customStatePredicatesMatched(customStateMap: CustomStateMap?, position: Int?) -> Bool? {
        guard !customStatePredicates.isEmpty else { return nil }

        // Predicates need to applied if all of the predicates are met.
        // The default is true and will be used by && operation on each predicate
        var matched = true

        customStatePredicates.forEach { predicate in
            let customStateId = CustomStateIdentifiable(position: position, key: predicate.key)
            let customStateValue = customStateMap?[customStateId] ?? 0
            switch predicate.condition {
            case .is:
                matched = matched && customStateValue == predicate.value
            case .isNot:
                matched = matched && customStateValue != predicate.value
            case .isAbove:
                matched = matched && customStateValue > predicate.value
            case .isBelow:
                matched = matched && customStateValue < predicate.value
            }
        }

        return matched
    }

    func shouldApply(_ uiState: WhenComponentUIState) -> Bool {

        let progressionMatched = progressionPredicatesMatched(currentProgress: uiState.currentProgress)
        let positionMatched = positionPredicatesMatched(offerPosition: uiState.position,
                                                        totalOffers: uiState.totalOffers)
        let breakPointsMatched = breakPointOrientationPredicatesMatched(width: uiState.width)
        let darkModeMatched = darkModePredicatesMatched(isDarkMode: uiState.isDarkMode)
        let staticBooleanMatched = staticBooleanPredicatesMatched()
        let creativeCopyMatched = creativeCopyMatched(offerPosition: uiState.currentProgress)
        let staticStringMatched = staticStringPredicatesMatched()
        let customStateMatched = customStatePredicatesMatched(customStateMap: uiState.customStateMap, position: uiState.position)

        if progressionMatched == nil &&
            breakPointsMatched == nil &&
            positionMatched == nil &&
            darkModeMatched == nil &&
            staticBooleanMatched == nil &&
            creativeCopyMatched == nil &&
            staticStringMatched == nil &&
            customStateMatched == nil
        { return true }
        
        var matched = true
        
        if let progressionMatched {
            matched = matched && progressionMatched
        }
        
        if let positionMatched {
            matched = matched && positionMatched
        }
        
        if let breakPointsMatched {
            matched = matched && breakPointsMatched
        }

        if let darkModeMatched {
            matched = matched && darkModeMatched
        }
        
        if let staticBooleanMatched {
            matched = matched && staticBooleanMatched
        }
        
        if let creativeCopyMatched {
            matched = matched && creativeCopyMatched
        }
        
        if let staticStringMatched {
            matched = matched && staticStringMatched
        }
        
        if let customStateMatched {
            matched = matched && customStateMatched
        }

        return matched
    }
}
