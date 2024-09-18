//
//  WhenComponent.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import SwiftUI
import Combine

@available(iOS 15, *)
struct WhenComponent: View {
    let config: ComponentConfig
    let viewModel: WhenViewModel

    @Binding var parentWidth: CGFloat?
    @Binding var parentHeight: CGFloat?
    @Binding var styleState: StyleState

    @Binding var currentProgress: Int
    let totalOffers: Int
    
    @Binding var customStateMap: CustomStateMap?

    @EnvironmentObject var globalScreenSize: GlobalScreenSize

    let parentOverride: ComponentParentOverride?

    @SwiftUI.Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var visible: Bool? = nil
    @State private var toggleTransition = false

    private var shouldApply: Bool {
        viewModel.shouldApply(
            WhenComponentUIState(
                currentProgress: currentProgress,
                totalOffers: totalOffers,
                position: config.position,
                width: globalScreenSize.width ?? 0,
                isDarkMode: colorScheme == .dark,
                customStateMap: customStateMap
            )
        )
    }
    
    private var getOpacity: Double {
        toggleTransition ? 1 : 0
    }
    
    init(
        config: ComponentConfig,
        model: WhenUIModel,
        baseDI: BaseDependencyInjection,
        parentWidth: Binding<CGFloat?>,
        parentHeight: Binding<CGFloat?>,
        styleState: Binding<StyleState>,
        parentOverride: ComponentParentOverride?
    ) {
        self.config = config
        self.viewModel = WhenViewModel(model: model,
                                       baseDI: baseDI)
        _parentWidth = parentWidth
        _parentHeight = parentHeight
        _styleState = styleState
        _currentProgress = baseDI.sharedData.items[SharedData.currentProgressKey] as? Binding<Int> ?? .constant(0)
        totalOffers = baseDI.sharedData.items[SharedData.totalItemsKey] as? Int ?? 0
        _customStateMap = baseDI.sharedData.items[SharedData.customStateMap] as? Binding<CustomStateMap?> ?? .constant(nil)

        self.parentOverride = parentOverride
    }

    var body: some View {
        Group {
            if let visible {
                if visible {
                    buildComponent()
                }
            } else if shouldApply {
                buildComponent()
            }
        }
        .opacity(getOpacity)
        .onChange(of: shouldApply) { newValue in
            if newValue {
                transitionIn()
            } else {
                transitionOut()
            }
        }
        .onLoad {
            transitionIn()
        }
    }
    
    @ViewBuilder private func buildComponent() -> some View {
        if let children = viewModel.model.children {
            ForEach(children, id: \.self) { child in
                LayoutSchemaComponent(config: config,
                                      layout: child,
                                      baseDI: viewModel.baseDI,
                                      parentWidth: $parentWidth,
                                      parentHeight: $parentHeight,
                                      styleState: $styleState,
                                      parentOverride: parentOverride)
            }
        }
    }
    
    private func transitionIn() {
        visible = true
        withAnimation(
            .easeIn(duration: viewModel.model.fadeInDuration)) {
                toggleTransition = true
            }
    }
    
    private func transitionOut() {
        if #available(iOS 17.0, *) {
            withAnimation(
                .easeOut(duration: viewModel.model.fadeOutDuration)) {
                    toggleTransition = false
                } completion: {
                    visible = false
                }
        } else {
            // Earlier versions must set visibility after a manual delay
            withAnimation(
                .easeOut(duration: viewModel.model.fadeOutDuration)) {
                    toggleTransition = false
                }
            DispatchQueue.main.asyncAfter(deadline: .now() + viewModel.model.fadeOutDuration) {
                visible = false
            }
        }
    }
}

struct WhenComponentUIState {
    let currentProgress: Int
    let totalOffers: Int
    let position: Int?
    let width: CGFloat
    let isDarkMode: Bool
    let customStateMap: CustomStateMap?
}
