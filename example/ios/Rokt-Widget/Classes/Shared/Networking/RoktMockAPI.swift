//
//  RoktMockAPI.swift
//  Rokt-Widget
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

internal class RoktMockAPI {

    class func initialize(roktTagId: String,
                          success: ((InitRespose) -> Void)? = nil,
                          failure: ((Error, Int?, String) -> Void)? = nil) {
        success?(InitRespose(timeout: 8000, delay: 0,
                             clientSessionTimeout: 1800000,
                             fonts: [],
                             featureFlags: InitFeatureFlags(
                                roktTrackingStatus: true,
                                shouldLogFontHappyPath: true,
                                shouldUseFontRegisterWithUrl: true,
                                featureFlags: ["mobile-sdk-use-partner-events": FeatureFlagItem(match: true),
                                               "mobile-sdk-use-bounding-box": FeatureFlagItem(match: true),
                                               "mobile-sdk-use-timings-api": FeatureFlagItem(match: true)])))
    }

    class func downloadFonts(_ fonts: [FontModel]) {}

    class func getPlacement(params: [String: Any],
                            roktTagId: String,
                            trackingConsent: UInt?,
                            success: ((PageViewData?) -> Void)? = nil,
                            failure: ((Error, Int?, String) -> Void)? = nil) {

        if let path = Bundle.main.path(forResource: getPlacementJsonName(roktTagId), ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                success?(PageViewData(placementResponseData: data))
            } catch { success?(nil) }
        } else { success?(nil) }
    }

    @available(iOS 15, *)
    class func getExperienceData(
        params: [String: Any],
        roktTagId: String,
        trackingConsent: UInt?,
        onRequestStart: (() -> Void)?,
        successPlacement: ((PageViewData?) -> Void)? = nil,
        successLayout: ((PageModel?) -> Void)? = nil,
        failure: ((Error, Int?, String) -> Void)? = nil
    ) {
        onRequestStart?()
        
        switch getExperienceDataOverload(roktTagId) {
        case .placements:
            getPlacement(
                params: params,
                roktTagId: roktTagId,
                trackingConsent: trackingConsent,
                success: successPlacement
            )
        case .layouts:
            if let path = Bundle.main.path(forResource: getPlacementJsonName(roktTagId), ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    let experienceResponse = try JSONDecoder().decode(ExperienceResponse.self, from: data)

                    guard let outerlayoutSchema = experienceResponse.getPageModel()
                    else {
                        successLayout?(nil)
                        return
                    }

                    successLayout?(outerlayoutSchema)
                } catch let error {
                    Log.d("\(kParsingLayoutError) \(error)")
                    RoktAPIHelper.sendDiagnostics(message: kValidationErrorCode,
                                                  callStack: kParsingLayoutError + error.localizedDescription)
                    successLayout?(nil)
                }
            } else {
                successLayout?(nil)
            }
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private class func getPlacementJsonName(_ roktTagId: String) -> String {
        switch roktTagId {
        case "2731619347947643042_67700f1c96584c97be7e540a8358e830": // Placement Custom embedded 1
            return "placement_embedded_loc_1"
        case "2731619347947643042_2871d443712b433587bc4813b8ff8af1": // Placement Custom embedded 2
            return "placement_embedded_loc_2"
        case "2731619347947643042_441d1e3cb3ef4a58891da6aca8ddebdf": // Placement Embedded
            return "placement"
        case "2731619347947643042_441d1e3cb3ef4a58891da6aca8ddeb34": // Placement PayMar
            return "placement_paymar"
        case "2731619347947643042_22bde905d7f14db8a6e4fab89210b122": // Placement Custom lightbox 2
            return "placement_custom_light_box_2"
        case "2731619347947643042_441d1e3cb3ef4a58891da6aca8ddebdg": // Placement Multiple placement 1
            return "multiple_placement_1"
        case "2731619347947643042_2871d443712b433587bc4813b8ff8af3": // Placement Multiple placement 2
            return "multiple_placement_2"
        case "2731619347947643042_2231d443712b433587bc4813b8ff8222": // Placement Overlay
            return "placement_overlay"
        case "2731619347947643042_3331d443712b433587bc4813b8ff8233": // Placement BottomSheet
            return "placement_bottom_sheet"
        case "2731619347947643042_3331d443712b433587bc4813b8ff8244": // Placement Overlay + Vinted
            return "placement_overlay_vinted"
        case "2731619347947643042_3331d443712b433587bc4813b8ff8255": // Placement Lightbox + Vinted
            return "placement_light_box_vinted"
        case "2731619347947643042_3331d443712b433587bc4813b8ff8266": // Placement Embedded + Vinted
            return "placement_embedded_vinted"
        case "2731619347947643042_3331d443712b433587bc4813b8ff1111": // Layout playground
            return "layout_playground"
        case "2731619347947643042_3331d443712b433587bc4813b8ff8213": // Layout overlay
            return "boohoo_overlay"
        case "2731619347947643042_3331d443712b433587bc4813b8ff8214": // Layout overlay 1
            return "layout_overlay_1"
        case "2731619347947643042_3331d443712b433587bc4813b8ff8215": // Layout Carousel
            return "layout_carousel"
        case "2731619347947643042_3331d443712b433587bc4813b8ff8216": // Layout Grouped
            return "layout_grouped_distribution"
        case "2731619347947643042_3331d443712b433587bc48444333222": // Layout bottomSheet
            return "layout_bottomsheet"
        case "2731619347947643042_3331d443712b433587bc4813b8ff8300": // Layout embedded 1
            return "layout_embedded_1"
        case "2731619347947643042_3331d443712b433587bc4813b8ff8302": // Layout embedded 2
            return "layout_embedded_2"
        case "2731619347947643042_3331d443712b433587bc4813b8ff8453": // Layout multiple 1
            return "layout_multiple_1"
        case "2731619347947643042_3331d443712b433587bc4813b8ff8411": // Layout multiple 2
            return "layout_multiple_2"
        case "2731619347947643042_3331d443712b433587bc4813b8ff8777": // Layout embedded 4
            return "layout_embedded_4"
        default:
            return "placement_light_box" // Placement Lightbox
        }
    }

    // return placements/layouts header based on the name of the json
    private class func getExperienceDataOverload(_ roktTagId: String) ->
    PlacementAndLayoutHeaderBridge.DataResponseType {
        return getPlacementJsonName(roktTagId).contains("placement") ? .placements : .layouts
    }

    class func sendEvent(paramsArray: [[String: Any]],
                         sessionId: String?,
                         success: (() -> Void)? = nil,
                         failure: ((Error, Int?, String) -> Void)? = nil) {
        do {
            let params =  try JSONSerialization.data(withJSONObject: paramsArray, options: [])
            Log.d(String(bytes: params, encoding: .utf8) ?? "")
        } catch {}
        success?()
    }

    class func sendDiagnostics(params: [String: Any],
                               success: (() -> Void)? = nil,
                               failure: ((Error, Int?, String) -> Void)? = nil) {
        do {
            let params =  try JSONSerialization.data(withJSONObject: params, options: [])
            Log.d(String(bytes: params, encoding: .utf8) ?? "")
        } catch {}
        success?()
    }
    
    class func sendTimings(timingsRequest: TimingsRequest) {
        guard Rokt.shared.initFeatureFlags.isEnabled(.timingsEnabled) else { return }
        do {
            let params = try JSONSerialization.data(withJSONObject: timingsRequest.toDictionary(), options: [])
            Log.d(String(bytes: params, encoding: .utf8) ?? "")
        } catch {}
    }
}
