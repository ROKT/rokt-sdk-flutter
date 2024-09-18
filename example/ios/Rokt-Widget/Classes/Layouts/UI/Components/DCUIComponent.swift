//
//  OverlayComponent.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import UIKit
import SwiftUI

@available(iOS 15, *)
class DCUIComponent: RoktEventListener {
    
    var onRoktEvent: ((RoktEvent) -> Void)?
    var pluginId: String?
    
    func loadLayout(sessionId: String,
                    layoutPlugin: LayoutPlugin,
                    startDate: Date,
                    responseReceivedDate: Date,
                    placements: [String: RoktEmbeddedView]?,
                    layout: RoktLayout?,
                    config: RoktConfig?,
                    onLoad: @escaping (() -> Void),
                    onUnLoad: @escaping (() -> Void),
                    onEmbeddedSizeChange: @escaping (String, CGFloat) -> Void,
                    on2stepEvent: @escaping (RoktEventType, RoktEventHandler) -> Void,
                    onRoktEvent: @escaping (RoktEvent) -> Void) throws {
        self.pluginId = layoutPlugin.pluginId
        self.onRoktEvent = onRoktEvent
        
        let baseDIPluginModel = BaseDependencyInjectionPluginModel(
            instanceGuid: layoutPlugin.pluginInstanceGuid,
            configJWTToken: layoutPlugin.pluginConfigJWTToken,
            id: layoutPlugin.pluginId,
            name: layoutPlugin.pluginName)
        
        let baseDI = BaseDependencyInjection(sessionId: sessionId,
                                             pluginModel: baseDIPluginModel,
                                             startDate: startDate,
                                             responseReceivedDate: responseReceivedDate,
                                             slots: layoutPlugin.slots,
                                             config: config)

        baseDI.sharedData.items[SharedData.breakPointsSharedKey] = layoutPlugin.breakpoints
        baseDI.sharedData.items[SharedData.layoutSettingsKey] = layoutPlugin.settings

        baseDI.eventProcessor.sendSignalLoadStartEvent()
        
        baseDI.setLayoutType(.unknown)
        
        func firstPositiveEngagement(_: Any? = nil) {
            on2stepEvent(RoktEventType.FirstPositiveEngagement,
                    RoktEventHandler(sessionId: sessionId,
                                     pageInstanceGuid: layoutPlugin.pluginInstanceGuid,
                                     jwtToken: layoutPlugin.pluginConfigJWTToken))
        }
        
        baseDI.actionCollection[.positiveEngaged] = firstPositiveEngagement
        addAllListeners(eventCollection: baseDI.eventCollection)
        
        let layoutTransformer = LayoutTransformer(layoutPlugin: layoutPlugin, config: config)
        do {
            if let layoutUIModel = try layoutTransformer.transform() {
                switch layoutUIModel {
                case .overlay(let model):
                    baseDI.setLayoutType(.overlayLayout)
                    
                    showOverlay(placementType: .Overlay,
                                baseDI: baseDI,
                                onLoad: onLoad,
                                onUnLoad: onUnLoad) {_ in 
                        OverlayComponent(model: model, baseDI: baseDI)
                            .customColorMode(colorMode: config?.colorMode)
                    }
                case .bottomSheet(let model):
                    baseDI.setLayoutType(.bottomSheetLayout)
                    
                    showOverlay(placementType: .BottomSheet,
                                bottomSheetUIModel: model,
                                baseDI: baseDI,
                                onLoad: onLoad,
                                onUnLoad: onUnLoad) { onSizeChange in
                        if #available(iOS 16.0, *),
                           model.defaultStyle?.first?.dimension?.height == nil ||
                            model.defaultStyle?.first?.dimension?.height == .fit(.wrapContent) {
                            ResizableBottomSheetComponent(model: model, baseDI: baseDI, onSizeChange: onSizeChange)
                                .customColorMode(colorMode: config?.colorMode)
                        } else {
                            BottomSheetComponent(model: model, baseDI: baseDI)
                                .customColorMode(colorMode: config?.colorMode)
                        }
                    }
                default:
                    baseDI.setLayoutType(.embeddedLayout)
                    
                    showEmbedded(placements: placements,
                                 layout: layout,
                                 baseDI: baseDI,
                                 layoutPlugin: layoutPlugin,
                                 layoutUIModel: layoutUIModel,
                                 config: config,
                                 onLoad: onLoad,
                                 onUnLoad: onUnLoad,
                                 onEmbeddedSizeChange: onEmbeddedSizeChange)
                    
                }
            }
            baseDI.eventProcessor.sendEventsOnTransformerSuccess()
        } catch LayoutTransformerError.InvalidColor(color: let color) {
            // invalid color error
            RoktAPIHelper.sendDiagnostics(message: kValidationErrorCode,
                                          callStack: kColorInvalid + color,
                                          sessionId: baseDI.eventProcessor.sessionId)
            Log.i("Rokt: Invalid color in schema")
            throw LayoutFailureError.layoutTransformerError(pluginId: pluginId)
        } catch {
            // generic validation error
            RoktAPIHelper.sendDiagnostics(message: kValidationErrorCode,
                                          callStack: kLayoutInvalid,
                                          sessionId: baseDI.eventProcessor.sessionId)
            Log.i("Rokt: Invalid schema")
            throw LayoutFailureError.layoutTransformerError(pluginId: pluginId)
        }
    }
    
    private func showEmbedded(placements: [String: RoktEmbeddedView]?,
                              layout: RoktLayout?,
                              baseDI: BaseDependencyInjection,
                              layoutPlugin: LayoutPlugin,
                              layoutUIModel: LayoutSchemaUIModel,
                              config: RoktConfig?,
                              onLoad: @escaping (() -> Void),
                              onUnLoad: @escaping (() -> Void),
                              onEmbeddedSizeChange: @escaping (String, CGFloat) -> Void) {
        DispatchQueue.main.async {
            if  let targetElement = layoutPlugin.targetElementSelector {
                if let embedded = placements?[targetElement] {
                    embedded.loadEmbeddedLayout(
                        baseDI: baseDI,
                        onUnLoad: onUnLoad,
                        onSizeChange: onSizeChange
                    ) {
                        EmbeddedComponent(
                            layout: layoutUIModel,
                            baseDI: baseDI,
                            onLoad: onLoad,
                            onSizeChange: onSizeChange
                        )
                        .customColorMode(colorMode: config?.colorMode)
                    }
                    
                    func onSizeChange(size: CGFloat) {
                        embedded.updateEmbeddedSize(size)
                        onEmbeddedSizeChange(targetElement, size)
                        if Rokt.shared.initFeatureFlags.isEnabled(.boundingBox) {
                            baseDI.actionCollection[.checkBoundingBoxMissized](nil)
                        }
                    }
                    
                } else if let layout, layout.locationName == layoutPlugin.targetElementSelector {
                    
                    layout.loadLayout(layoutUIModel: layoutUIModel,
                                      baseDI: baseDI,
                                      onSDKLoaded: onLoad,
                                      onSDKUnloaded: onUnLoad)
                    
                } else {
                    RoktAPIHelper.sendDiagnostics(message: kAPIExecuteErrorCode, callStack: kEmbeddedLayoutDoesntExistMessage
                                                  + targetElement + kLocationDoesNotExist, sessionId: baseDI.eventProcessor.sessionId)
                    Log.i("Rokt: Embedded layout doesn't exist")
                    onUnLoad()
                }
            }
        }
    }
    
    private func showOverlay<Content: View>(placementType: PlacementType?,
                                            bottomSheetUIModel: BottomSheetUIModel? = nil,
                                            baseDI: BaseDependencyInjection,
                                            onLoad: @escaping (() -> Void),
                                            onUnLoad: @escaping (() -> Void),
                                            @ViewBuilder builder: @escaping (((CGFloat) -> Void)?) -> Content) {
        DispatchQueue.main.async {
            if let viewController = self.getTopViewController() {
                viewController.present(placementType: placementType,
                                       bottomSheetUIModel: bottomSheetUIModel,
                                       baseDI: baseDI,
                                       onLoad: onLoad,
                                       onUnLoad: onUnLoad,
                                       builder: builder)
            }
        }
    }
    
    private func getTopViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
    
    internal func onOfferEngagement() {
        onRoktEvent?(RoktEvent.OfferEngagement(placementId: pluginId))
    }
    
    internal func onPositiveEngagement() {
        onRoktEvent?(RoktEvent.PositiveEngagement(placementId: pluginId))
    }
    
    internal func onPlacementInteractive() {
        onRoktEvent?(RoktEvent.PlacementInteractive(placementId: pluginId))
    }
    
    internal func onPlacementReady() {
        onRoktEvent?(RoktEvent.PlacementReady(placementId: pluginId))
    }
    
    internal func onPlacementClosed() {
        onRoktEvent?(RoktEvent.PlacementClosed(placementId: pluginId))
    }
    
    internal func onPlacementCompleted() {
        onRoktEvent?(RoktEvent.PlacementCompleted(placementId: pluginId))
    }
    
    internal func onPlacementFailure() {
        onRoktEvent?(RoktEvent.PlacementFailure(placementId: pluginId))
    }
}
