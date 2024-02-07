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

    private func progressionPredicatesMatched(currentOfferIndex: Int) -> Bool? {
        // don't apply if the predicates is empty
        guard !progressionPredicates.isEmpty else { return nil }

        // Predicates need to applied if all of the preicates are meet.
        // The default is true and will be used by && operation on each predicates
        var matched = true

        progressionPredicates.forEach { predicate in
            if let value = Int(predicate.value) {
                switch predicate.condition {
                case .is:
                    matched = matched && currentOfferIndex == value
                case .isNot:
                    matched = matched && currentOfferIndex != value
                case .isAbove:
                    matched = matched && currentOfferIndex > value
                case .isBelow:
                    matched = matched && currentOfferIndex < value
                }
            }
        }

        return matched
    }
    
    private func positionPredicatesMatched(currentOfferIndex: Int, totalOffers: Int) -> Bool? {
        // don't apply if the predicates is empty
        guard !positionPredicates.isEmpty else { return nil }

        // Predicates need to applied if all of the preicates are meet.
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
                    matched = matched && currentOfferIndex == position
                case .isNot:
                    matched = matched && currentOfferIndex != position
                case .isAbove:
                    matched = matched && currentOfferIndex > position
                case .isBelow:
                    matched = matched && currentOfferIndex < position
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

    func shouldApply(currentOfferIndex: Int, totalOffers: Int, width: CGFloat) -> Bool {
        let progressionMatched = progressionPredicatesMatched(currentOfferIndex: currentOfferIndex)
        let positionMatched = positionPredicatesMatched(currentOfferIndex: currentOfferIndex, totalOffers: totalOffers)
        let breakPointsMatched = breakPointOrientationPredicatesMatched(width: width)

        if progressionMatched == nil && breakPointsMatched == nil && positionMatched == nil {
            return false
        }
        
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
        
        return matched
    }
}
