//
//  PageViewData.swift
//  Pods
//
//  Copyright 2020 Rokt Pte Ltd
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation

class PageViewData {
    let pageId: String?
    let sessionId: String
    let pageInstanceGuid: String
    let placementContextJWTToken: String
    let placements: [PlacementViewData]?

    init(
        pageId: String?,
        sessionId: String,
        pageInstanceGuid: String,
        placementContextJWTToken: String,
        placements: [PlacementViewData]?
    ) {
        self.pageId = pageId
        self.sessionId = sessionId
        self.pageInstanceGuid = pageInstanceGuid
        self.placementContextJWTToken = placementContextJWTToken
        self.placements = placements
    }

    convenience init?(placementResponseData: Data) {
        do {
            let placementResponse: PlacementResponse

            if #available(iOS 13, *) {
                placementResponse = try JSONDecoder().decode(ExperienceResponse.self, from: placementResponseData)
            } else {
                placementResponse = try JSONDecoder().decode(PlacementResponse.self, from: placementResponseData)
            }

            if placementResponse.placements.isEmpty {
                Log.d(StringHelper.localizedStringFor(kNoWidgetErrorMessage, comment: kNoWidgetErrorMessage))

                self.init(pageId: placementResponse.page?.pageId,
                          sessionId: placementResponse.sessionId,
                          pageInstanceGuid: placementResponse.placementContext.pageInstanceGuid,
                          placementContextJWTToken: placementResponse.placementContext.placementContextJWTToken,
                          placements: nil)
            } else {
                var placements = [PlacementViewData]()
                for placement in placementResponse.placements {
                    let transformer =
                        PlacementTransformer(placement: placement,
                                             pageInstanceGuid: placementResponse.placementContext.pageInstanceGuid,
                                             startDate: Date(), responseReceivedDate: Date())
                    placements.append(try transformer.transformPlacement())
                }

                self.init(pageId: placementResponse.page?.pageId,
                          sessionId: placementResponse.sessionId,
                          pageInstanceGuid: placementResponse.placementContext.pageInstanceGuid,
                          placementContextJWTToken: placementResponse.placementContext.placementContextJWTToken,
                          placements: placements)
            }
        } catch TransformerError.KeyIsMissing(key: let key) {
            PageViewData.sendDiagnostics(kKeyMissingError + key)
            return nil
        } catch TransformerError.ValueIsNil(key: let key) {
            PageViewData.sendDiagnostics(kValueIsNilError + key)
            return nil
        } catch TransformerError.TypeMissMatch(key: let key) {
            PageViewData.sendDiagnostics(kTypeMissMatch + key)
            return nil
        } catch TransformerError.NotSupported(key: let key) {
            PageViewData.sendDiagnostics(kNotSupported + key)
            return nil
        } catch {
            Log.d(error.localizedDescription)
            PageViewData.sendDiagnostics(kUnprocessableData)
            return nil
        }
    }

    private class func sendDiagnostics(_ callStack: String) {
        Log.d(kParsingPlacementError + callStack)
        RoktAPIHelper.sendDiagnostics(message: kValidationErrorCode,
                                      callStack: kParsingPlacementError + callStack)
    }

    internal func setStartDate(startDate: Date) {
        if let placements = placements {
            for placement in placements {
                placement.startDate = startDate
            }
        }
    }

    internal func setResponseReceivedDate(receivedDate: Date) {
        if let placements = placements {
            for placement in placements {
                placement.responseReceivedDate = receivedDate
            }
        }
    }

}
