//
//  CreativeResponseViewModel.swift
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
struct CreativeResponseViewModel {
    let model: CreativeResponseUIModel
    let baseDI: BaseDependencyInjection
    
    func sendSignalResponseEvent() {
        guard let responseJWTToken = model.responseOptions?.responseJWTToken else { return }

        switch model.responseOptions?.signalType {
        case .signalGatedResponse:
            baseDI.eventProcessor.sendGatedSignalResponseEvent(
                instanceGuid: model.responseOptions?.instanceGuid ?? "",
                jwtToken: responseJWTToken,
                isPositive: model.responseKey == .positive)
        case .signalResponse:
            baseDI.eventProcessor.sendSignalResponseEvent(
                instanceGuid: model.responseOptions?.instanceGuid ?? "",
                jwtToken: responseJWTToken,
                isPositive: model.responseKey == .positive)
        default:
            break
        }
    }
    
    func goToNextOffer() {
        baseDI.actionCollection[.nextOffer](nil)
    }
    
    func getOfferUrl() -> URL? {
        guard let urlString = model.responseOptions?.url,
              model.responseOptions?.action == .url
        else { return nil }

        return URL(string: urlString)
    }
}
