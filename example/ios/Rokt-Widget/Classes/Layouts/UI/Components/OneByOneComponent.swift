//
//  OneByOneComponent.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import SwiftUI

@available(iOS 15, *)
struct OneByOneComponent: View {
    var style: OneByOneDistributionStyles? {
        return model.defaultStyle
    }
    
    var containerStyle: ContainerStylingProperties? { style?.container }
    var dimensionStyle: DimensionStylingProperties? { style?.dimension }
    var flexStyle: FlexChildStylingProperties? { style?.flexChild }
    var borderStyle: BorderStylingProperties? { style?.border }
    var spacingStyle: SpacingStylingProperties? { style?.spacing }
    var backgroundStyle: BackgroundStylingProperties? { style?.background }
    
    var transition: Transition? { model.transition }
    
    let parent: ComponentParent
    let model: OneByOneUIModel

    @ObservedObject var viewModel: OneByOneViewModel
    @Binding var parentWidth: CGFloat?
    @Binding var parentHeight: CGFloat?
    @Binding var styleState: StyleState
    
    @State var currentOffer = 0
    @State private var toggleTransition = false

    let parentVerticalAlignment: VerticalAlignment?
    let parentHorizontalAlignment: HorizontalAlignment?

    var parentBackgroundStyle: BackgroundStylingProperties?

    var passableBackgroundStyle: BackgroundStylingProperties? {
        backgroundStyle ?? parentBackgroundStyle
    }

    init(
        parent: ComponentParent,
        model: OneByOneUIModel,
        baseDI: BaseDependencyInjection,
        parentWidth: Binding<CGFloat?>,
        parentHeight: Binding<CGFloat?>,
        styleState: Binding<StyleState>,
        parentVerticalAlignment: VerticalAlignment?,
        parentHorizontalAlignment: HorizontalAlignment?,
        parentBackgroundStyle: BackgroundStylingProperties? = nil
    ) {
        self.parent = parent
        self.viewModel = OneByOneViewModel(model: model,
                                           baseDI: baseDI)
        _parentWidth = parentWidth
        _parentHeight = parentHeight
        _styleState = styleState

        self.parentVerticalAlignment = parentVerticalAlignment
        self.parentHorizontalAlignment = parentHorizontalAlignment
        self.parentBackgroundStyle = parentBackgroundStyle
        
        self.model = model
    }
    
    var verticalAlignment: VerticalAlignmentProperty {
        if let justifyContent = containerStyle?.alignItems?.asVerticalAlignmentProperty {
            return justifyContent
        } else if let parentAlign = parentVerticalAlignment?.asVerticalAlignmentProperty {
            return parentAlign
        } else {
            return .top
        }
    }

    var horizontalAlignment: HorizontalAlignmentProperty {
        if let alignItems = containerStyle?.justifyContent?.asHorizontalAlignmentProperty {
            return alignItems
        } else if let parentAlign = parentHorizontalAlignment?.asHorizontalAlignmentProperty {
            return parentAlign
        } else {
            return .start
        }
    }
    
    var body: some View {
        if let children = viewModel.model.children, !children.isEmpty {
            LayoutSchemaComponent(parent: parent,
                                  layout: children[currentOffer],
                                  baseDI: getBaseDI(),
                                  parentWidth: $parentWidth,
                                  parentHeight: $parentHeight,
                                  styleState: $styleState,
                                  parentVerticalAlignment: parentVerticalAlignment,
                                  parentHorizontalAlignment: parentHorizontalAlignment,
                                  parentBackgroundStyle: passableBackgroundStyle)
            .applyLayoutModifier(verticalAlignmentProperty: verticalAlignment,
                                 horizontalAlignmentProperty: horizontalAlignment,
                                 spacing: spacingStyle,
                                 dimension: dimensionStyle,
                                 flex: flexStyle,
                                 border: borderStyle,
                                 background: backgroundStyle,
                                 parent: parent,
                                 parentWidth: $parentWidth,
                                 parentHeight: $parentHeight,
                                 parentVerticalAlignment: parentVerticalAlignment,
                                 parentHorizontalAlignment: parentHorizontalAlignment,
                                 parentBackgroundStyle: passableBackgroundStyle,
                                 defaultHeight: .wrapContent,
                                 defaultWidth: .wrapContent,
                                 isContainer: true)
            .opacity(getOpacity())
            .onLoad {
                registerActions()
                toggleTransition = true
                viewModel.sendImpressionEvents(currentOffer: currentOffer)
            }
            .onChange(of: currentOffer) { newValue in
                transitionIn()
                viewModel.sendImpressionEvents(currentOffer: newValue)
            }
        }
    }
    
    func registerActions() {
        viewModel.baseDI.actionCollection["nextOffer"] = goToNextOffer
    }

    func goToNextOffer() {
        if currentOffer + 1 < viewModel.model.children?.count ?? 0 {
            transitionToNextOffer()
        } else {
            if case .embeddedLayout = viewModel.baseDI.layoutType() {
                viewModel.sendDismissalCollapsedEvent()
            } else {
                viewModel.sendDismissalNoMoreOfferEvent()
            }

            exit()
        }
    }
    
    func exit() {
        viewModel.baseDI.actionCollection["Close"]()
    }
    
    func transitionIn() {
        switch transition {
        case .fadeInOut(let settings):
            let duration = Double(settings.duration)/1000/2
            withAnimation(
                .easeIn(duration: Double(duration))) {
                toggleTransition = true
            }
        default:
            return
        }
    }
    
    func transitionToNextOffer() {
        switch transition {
        case .fadeInOut(let settings):
            let duration = Double(settings.duration)/1000/2
            withAnimation(.easeOut(duration: duration)) {
                toggleTransition = false
            }

            // Wait to complete fade out of previous offer
            // Must not run on `main` as that prevents `@State` from changing
            DispatchQueue.background.asyncAfter(deadline: .now() + duration) {
                self.currentOffer = currentOffer + 1
            }
        default:
            self.currentOffer = currentOffer + 1
        }
    }
    
    func getBaseDI() -> BaseDependencyInjection {
        viewModel.baseDI.sharedData.items[SharedData.currentOfferIndexKey] = $currentOffer
        viewModel.baseDI.sharedData.items[SharedData.totalItemsKey] = viewModel.model.children?.count ?? 0
        return viewModel.baseDI
    }
    
    func getOpacity() -> Double {
        switch transition {
        case .fadeInOut(_):
            return toggleTransition ? 1 : 0
        default:
            return 1
        }
    }
}
