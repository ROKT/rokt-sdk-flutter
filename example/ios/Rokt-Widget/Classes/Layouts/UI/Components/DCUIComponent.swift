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
struct DCUIComponent {
    static let closeAction = "Close"
    static let unloadAction = "Unload"

    func loadLayout(sessionId: String,
                    layoutPlugin: LayoutPlugin,
                    startDate: Date,
                    placements: [String: RoktEmbeddedView]?,
                    layout: RoktLayout?,
                    onLoad: @escaping (() -> Void),
                    onUnLoad: @escaping (() -> Void),
                    onEmbeddedSizeChange: @escaping (String, CGFloat) -> Void,
                    onEvent: @escaping (RoktEventType, RoktEventHandler) -> Void) {
        let baseDI = BaseDependencyInjection(sessionId: sessionId,
                                             pluginInstanceGuid: layoutPlugin.pluginInstanceGuid,
                                             startDate: startDate,
                                             slots: layoutPlugin.slots)
        baseDI.sharedData.items[SharedData.breakPointsSharedKey] = layoutPlugin.breakpoints
        
        baseDI.eventProcessor.sendSignalLoadStartEvent()

        baseDI.setLayoutType(.unknown)

        let layoutTransformer = LayoutTransformer(layoutPlugin: layoutPlugin)
        if let layoutUIModel = layoutTransformer.transform() {
            switch layoutUIModel {
            case .overlay(let model):
                baseDI.setLayoutType(.overlayLayout)

                showOverlay(placementType: .Overlay,
                            baseDI: baseDI,
                            onLoad: onLoad,
                            onUnLoad: onUnLoad) {
                    OverlayComponent(model: model, baseDI: baseDI)
                }
            case .bottomSheet(let model):
                baseDI.setLayoutType(.bottomSheetLayout)

                showOverlay(placementType: .BottomSheet,
                            bottomSheetUIModel: model,
                            baseDI: baseDI,
                            onLoad: onLoad,
                            onUnLoad: onUnLoad) {
                    BottomSheetComponent(model: model, baseDI: baseDI)
                }
            default:
                baseDI.setLayoutType(.embeddedLayout)

                showEmbedded(placements: placements,
                             layout: layout,
                             baseDI: baseDI,
                             layoutPlugin: layoutPlugin,
                             layoutUIModel: layoutUIModel,
                             onLoad: onLoad,
                             onUnLoad: onUnLoad,
                             onEmbeddedSizeChange: onEmbeddedSizeChange)
            }
        }

        baseDI.eventProcessor.sendSignalLoadCompleteEvent()
    }
    
    func showEmbedded(placements: [String: RoktEmbeddedView]?,
                      layout: RoktLayout?,
                      baseDI: BaseDependencyInjection,
                      layoutPlugin: LayoutPlugin,
                      layoutUIModel: LayoutSchemaUIModel,
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
                    }
                    
                    func onSizeChange(size: CGFloat) {
                        embedded.updateEmbeddedSize(size)
                        onEmbeddedSizeChange(targetElement, size)
                    }
                    
                } else if let layout, layout.locationName == layoutPlugin.targetElementSelector {
                    
                    layout.loadLayout(layoutUIModel: layoutUIModel,
                                      baseDI: baseDI,
                                      onSDKLoaded: onLoad,
                                      onSDKUnloaded: onUnLoad)
                    
                } else {
                    RoktAPIHelper.sendDiagnostics(message: kAPIExecuteErrorCode, callStack: kEmbeddedLayoutDoesntExistMessage
                                                  + targetElement + kLocationDoesNotExist, sessionId: baseDI.eventProcessor.sessionId)
                    onUnLoad()
                }
            }
        }
    }
    
    func showOverlay<Content: View>(placementType: PlacementType?,
                                    bottomSheetUIModel: BottomSheetUIModel? = nil,
                                    baseDI: BaseDependencyInjection,
                                    onLoad: @escaping (() -> Void),
                                    onUnLoad: @escaping (() -> Void),
                                    @ViewBuilder builder: @escaping () -> Content) {
        DispatchQueue.main.async {
            if let viewController = getTopViewController() {
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
}
