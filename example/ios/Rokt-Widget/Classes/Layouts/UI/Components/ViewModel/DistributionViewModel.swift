//
//  DistributionViewModel.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation

@available(iOS 13.0, *)
class DistributionViewModel {
    let baseDI: BaseDependencyInjection
    
    init(baseDI: BaseDependencyInjection) {
        self.baseDI = baseDI
    }
    
    func sendImpressionEvents(currentOffer: Int) {
        sendSlotImpressionEvent(currentOffer: currentOffer)
        sendCreativeImpressionEvent(currentOffer: currentOffer)
    }
    
    func sendSlotImpressionEvent(currentOffer: Int) {
        guard let slotJWTToken = getSlotJWTToken(currentOffer: currentOffer) else { return }

        if let instanceGuid = getSlotInstance(currentOffer: currentOffer) {
            baseDI.eventProcessor.sendSlotImpressionEvent(
                instanceGuid: instanceGuid,
                jwtToken: slotJWTToken
            )
        }
    }

    func sendCreativeImpressionEvent(currentOffer: Int) {
        guard let creativeJWTToken = getCreativeJWTToken(currentOffer: currentOffer) else { return }
        
        if let instanceGuid = getCreativeInstance(currentOffer: currentOffer) {
            baseDI.eventProcessor.sendSlotImpressionEvent(
                instanceGuid: instanceGuid,
                jwtToken: creativeJWTToken
            )
        }
    }
    
    func sendCreativeViewedEvent(currentOffer: Int) {
        guard let creativeJWTToken = getCreativeJWTToken(currentOffer: currentOffer) else { return }

        if let instanceGuid = getCreativeInstance(currentOffer: currentOffer) {
            baseDI.eventProcessor.sendSignalViewedEvent(
                instanceGuid: instanceGuid,
                jwtToken: creativeJWTToken
            )
        }
    }
    
    func sendDismissalNoMoreOfferEvent() {
        baseDI.eventProcessor.dismissOption = .noMoreOffer
        baseDI.eventProcessor.sendDismissalEvent()
    }

    func sendDismissalCollapsedEvent() {
        baseDI.eventProcessor.dismissOption = .collapsed
        baseDI.eventProcessor.sendDismissalEvent()
    }
    
    func getSlotInstance(currentOffer: Int) -> String? {
        guard baseDI.slots.count > currentOffer else { return nil }
        return baseDI.slots[currentOffer].instanceGuid
    }

    func getSlotJWTToken(currentOffer: Int) -> String? {
        guard baseDI.slots.count > currentOffer else { return nil }
        return baseDI.slots[currentOffer].jwtToken
    }

    func getCreativeInstance(currentOffer: Int) -> String? {
        guard baseDI.slots.count > currentOffer,
              let offer = baseDI.slots[currentOffer].offer
        else { return nil }

        return offer.creative.instanceGuid
    }

    func getCreativeJWTToken(currentOffer: Int) -> String? {
        guard baseDI.slots.count > currentOffer,
              let offer = baseDI.slots[currentOffer].offer
        else { return nil }

        return offer.creative.jwtToken
    }
}
