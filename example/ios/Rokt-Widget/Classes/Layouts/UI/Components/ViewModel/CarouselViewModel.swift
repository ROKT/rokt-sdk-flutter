//
//  CarouselViewModel.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation
import Combine

@available(iOS 15, *)
class CarouselViewModel: ObservableObject {
    let model: CarouselUIModel
    let baseDI: BaseDependencyInjection

    init(model: CarouselUIModel,
         baseDI: BaseDependencyInjection) {
        self.model = model
        self.baseDI = baseDI
    }
    
    func sendImpressionEvents(currentOffer: Int) {
        sendSlotImpressionEvent(currentOffer: currentOffer)
        sendCreativeImpressionEvent(currentOffer: currentOffer)
    }
    
    func sendSlotImpressionEvent(currentOffer: Int) {
        if let instanceGuid = getSlotInstance(currentOffer: currentOffer) {
            baseDI.eventProcessor.sendSlotImpressionEvent(instanceGuid: instanceGuid)
        }
    }

    func sendCreativeImpressionEvent(currentOffer: Int) {
        if let instanceGuid = getCreativeInstance(currentOffer: currentOffer) {
            baseDI.eventProcessor.sendSlotImpressionEvent(instanceGuid: instanceGuid)
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
    
    func getCreativeInstance(currentOffer: Int) -> String? {
        guard baseDI.slots.count > currentOffer,
              let offer = baseDI.slots[currentOffer].offer
        else { return nil }

        return offer.creative.instanceGuid
    }
}
