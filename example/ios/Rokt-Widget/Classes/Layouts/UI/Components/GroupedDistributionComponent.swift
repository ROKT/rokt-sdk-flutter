//
//  GroupedDistributionComponent.swift
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
struct GroupedDistributionComponent: View {
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    
    var style: GroupedDistributionStyles? {
        return model.defaultStyle?.count ?? -1 > breakpointIndex ? model.defaultStyle?[breakpointIndex] : nil
    }
    
    @EnvironmentObject var globalScreenSize: GlobalScreenSize
    @State var breakpointIndex = 0
    @State var frameChangeIndex: Int = 0
    
    var containerStyle: ContainerStylingProperties? { style?.container }
    var dimensionStyle: DimensionStylingProperties? { style?.dimension }
    var flexStyle: FlexChildStylingProperties? { style?.flexChild }
    var borderStyle: BorderStylingProperties? { style?.border }
    var spacingStyle: SpacingStylingProperties? { style?.spacing }
    var backgroundStyle: BackgroundStylingProperties? { style?.background }
    
    var transition: Transition? { model.transition }
    
    let config: ComponentConfig
    let model: GroupedDistributionUIModel

    @ObservedObject var viewModel: GroupedDistributionViewModel
    @Binding var parentWidth: CGFloat?
    @Binding var parentHeight: CGFloat?
    @Binding var styleState: StyleState
    
    @State var currentGroup = 0
    @State private var toggleTransition = false
    @State private var currentLeadingOffer = 0
    
    @State var customStateMap: CustomStateMap? = nil
    
    @AccessibilityFocusState private var shouldFocusAccessibility: Bool
    var accessibilityAnnouncement: String {
        String(format: kPageAnnouncement,
               currentGroup + 1,
               viewModel.model.children?.count ?? 1)
    }

    let parentOverride: ComponentParentOverride?

    var passableBackgroundStyle: BackgroundStylingProperties? {
        backgroundStyle ?? parentOverride?.parentBackgroundStyle
    }

    init(
        config: ComponentConfig,
        model: GroupedDistributionUIModel,
        baseDI: BaseDependencyInjection,
        parentWidth: Binding<CGFloat?>,
        parentHeight: Binding<CGFloat?>,
        styleState: Binding<StyleState>,
        parentOverride: ComponentParentOverride?
    ) {
        self.config = config
        self.viewModel = GroupedDistributionViewModel(model: model,
                                           baseDI: baseDI)
        _parentWidth = parentWidth
        _parentHeight = parentHeight
        _styleState = styleState

        self.parentOverride = parentOverride
        self.model = model
    }
    
    var verticalAlignment: VerticalAlignmentProperty {
        if let justifyContent = containerStyle?.alignItems?.asVerticalAlignmentProperty {
            return justifyContent
        } else if let parentAlign = parentOverride?.parentVerticalAlignment?.asVerticalAlignmentProperty {
            return parentAlign
        } else {
            return .top
        }
    }

    var horizontalAlignment: HorizontalAlignmentProperty {
        if let alignItems = containerStyle?.justifyContent?.asHorizontalAlignmentProperty {
            return alignItems
        } else if let parentAlign = parentOverride?.parentHorizontalAlignment?.asHorizontalAlignmentProperty {
            return parentAlign
        } else {
            return .start
        }
    }
    
    @State var viewableItems: Int = 1
    var children: [LayoutSchemaUIModel] {
        guard let children = viewModel.model.children, !children.isEmpty else {
            return []
        }
        return children
    }
    
    var totalOffers: Int {
        children.count
    }
    
    var pages: [[LayoutSchemaUIModel]] {
        stride(from: 0, to: totalOffers, by: viewableItems).map {
            Array(children[$0 ..< $0.advanced(by: min(viewableItems, children.endIndex - $0))])
        }
    }
    
    var totalPages: Int {
        pages.count
    }
    
    var gap: CGFloat {
        CGFloat(containerStyle?.gap ?? 0)
    }
    
    var viewableChildren: [LayoutSchemaUIModel] {
        guard !children.isEmpty else { return [] }
        guard currentGroup < totalPages else { return [] }
        return pages[currentGroup]
    }
    
    func getViewableChildren() -> [LayoutSchemaUIModel] {
        guard !children.isEmpty else { return [] }
        guard currentGroup < totalPages else { return [] }
        return pages[currentGroup]
    }
    
    var body: some View {
        if !children.isEmpty {
            build(page: getViewableChildren())
                .applyLayoutModifier(verticalAlignmentProperty: verticalAlignment,
                                     horizontalAlignmentProperty: horizontalAlignment,
                                     spacing: spacingStyle,
                                     dimension: dimensionStyle,
                                     flex: flexStyle,
                                     border: borderStyle,
                                     background: backgroundStyle,
                                     parent: config.parent,
                                     parentWidth: $parentWidth,
                                     parentHeight: $parentHeight,
                                     parentOverride: parentOverride?.updateBackground(passableBackgroundStyle),
                                     defaultHeight: .wrapContent,
                                     defaultWidth: .wrapContent,
                                     isContainer: true,
                                     frameChangeIndex: $frameChangeIndex)
                .onLoad {
                    registerActions()
                    shouldFocusAccessibility = true
                }
                .accessibilityElement(children: .contain)
                .accessibilityFocused($shouldFocusAccessibility)
                .accessibilityLabel(accessibilityAnnouncement)
                .onChange(of: currentLeadingOffer) { newValue in
                    viewModel.sendViewableImpressionEvents(viewableItems: viewableItems,
                                                           currentLeadingOffer: newValue)
                    shouldFocusAccessibility = true
                    UIAccessibility.post(notification: .announcement,
                                         argument: accessibilityAnnouncement)
                }
                .onChange(of: globalScreenSize.width) { newSize in
                    // run it in background thread for smooth transition
                    DispatchQueue.background.async {
                        // update breakpoint index
                        let index = min(viewModel.baseDI.sharedData.getGlobalBreakpointIndex(newSize),
                                        (model.defaultStyle?.count ?? 1) - 1)
                        breakpointIndex = index >= 0 ? index : 0
                        frameChangeIndex = frameChangeIndex + 1
                        setViewableItemsForBreakpoint(newSize)
                        // set viewableItems first then send impressions for offers based on viewableItems
                        // duplicated events will be filtered out
                        viewModel.sendViewableImpressionEvents(viewableItems: viewableItems,
                                                               currentLeadingOffer: currentLeadingOffer)
                    }
                }
        }
    }
    
    func build(page: [LayoutSchemaUIModel]) -> some View {
        return VStack(alignment: columnPerpendicularAxisAlignment(alignItems: containerStyle?.alignItems),
                      spacing: gap) {
            ForEach(page, id: \.self) { child in
                if let childIndex = children.firstIndex(of: child) {
                    LayoutSchemaComponent(config: config.updatePosition(childIndex),
                                          layout: child,
                                          baseDI: getBaseDI(),
                                          parentWidth: $parentWidth,
                                          parentHeight: $parentHeight,
                                          styleState: $styleState,
                                          parentOverride: parentOverride?.updateBackground(passableBackgroundStyle))
                    .opacity(getOpacity())
                    .onLoad {
                        toggleTransition = true
                    }
                    .onBecomingViewed {
                        viewModel.sendCreativeViewedEvent(currentOffer: childIndex)
                    }
                }
            }
            
        }
    }
    
    func registerActions() {
        viewModel.baseDI.actionCollection[.nextOffer] = goToNextOffer
        viewModel.baseDI.actionCollection[.nextGroup] = goToNextGroup
        viewModel.baseDI.actionCollection[.previousGroup] = goToPreviousGroup
        viewModel.baseDI.actionCollection[.toggleCustomState] = toggleCustomState
    }

    func goToNextGroup(_: Any? = nil) {
        if currentGroup + 1 < totalPages {
            transitionToNextGroup()
        } else if viewModel.baseDI.closeOnComplete() {
            // when on last page AND closeOnComplete is true
            if case .embeddedLayout = viewModel.baseDI.layoutType() {
                viewModel.sendDismissalCollapsedEvent()
            } else {
                viewModel.sendDismissalNoMoreOfferEvent()
            }

            exit()
        }
    }
    
    func goToPreviousGroup(_: Any? = nil) {
        if currentGroup > 0 {
            transitionToPreviousGroup()
        }
    }
    
    // note this action only applies when viewableItems = 1
    func goToNextOffer(_: Any? = nil) {
        guard viewableItems == 1 else { return }
        if currentGroup + 1 < viewModel.model.children?.count ?? 0 {
            transitionToNextGroup()
        } else if viewModel.baseDI.closeOnComplete() {
            // when on last offer AND closeOnComplete is true
            if case .embeddedLayout = viewModel.baseDI.layoutType() {
                viewModel.sendDismissalCollapsedEvent()
            } else {
                viewModel.sendDismissalNoMoreOfferEvent()
            }

            exit()
        }
    }
    
    func exit() {
        viewModel.baseDI.actionCollection[.close](nil)
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
    
    func transitionToNextGroup() {
        switch transition {
        case .fadeInOut(let settings):
            let duration = Double(settings.duration)/1000/2
            withAnimation(.easeOut(duration: duration)) {
                toggleTransition = false
            }

            // Wait to complete fade out of previous offer
            // Must not run on `main` as that prevents `@State` from changing
            DispatchQueue.background.asyncAfter(deadline: .now() + duration) {
                self.currentGroup = currentGroup + 1
                self.currentLeadingOffer = currentGroup * viewableItems
            }
        default:
            self.currentGroup = currentGroup + 1
            self.currentLeadingOffer = currentGroup * viewableItems
        }
    }   
    
    func transitionToPreviousGroup() {
        switch transition {
        case .fadeInOut(let settings):
            let duration = Double(settings.duration)/1000/2
            withAnimation(.easeOut(duration: duration)) {
                toggleTransition = false
            }

            // Wait to complete fade out of previous offer
            // Must not run on `main` as that prevents `@State` from changing
            DispatchQueue.background.asyncAfter(deadline: .now() + duration) {
                self.currentGroup = currentGroup - 1
                self.currentLeadingOffer = currentGroup * viewableItems
            }
        default:
            self.currentGroup = currentGroup - 1
            self.currentLeadingOffer = currentGroup * viewableItems
        }
    }
    
    private func toggleCustomState(_ customStateId: Any?) {
        var mutatingCustomStateMap: CustomStateMap = customStateMap ?? CustomStateMap()
        self.customStateMap = mutatingCustomStateMap.toggleValueFor(customStateId)
    }
    
    func getBaseDI() -> BaseDependencyInjection {
        viewModel.baseDI.sharedData.items[SharedData.currentProgressKey] = $currentGroup
        viewModel.baseDI.sharedData.items[SharedData.totalItemsKey] = viewModel.model.children?.count ?? 0
        viewModel.baseDI.sharedData.items[SharedData.viewableItemsKey] = $viewableItems
        viewModel.baseDI.sharedData.items[SharedData.customStateMap] = $customStateMap
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
    
    func setViewableItemsForBreakpoint(_ newSize: CGFloat?) {
        let maxViewableItemsIndex = (viewModel.model.viewableItems.count) - 1
        
        let currentBreakpointIndex = viewModel.baseDI.sharedData.getGlobalBreakpointIndex(newSize)

        let index = max(min(currentBreakpointIndex, maxViewableItemsIndex), 0)
        let previousLeadingOffer = pages[currentGroup].first
        
        viewableItems = Int(viewModel.model.viewableItems[index])
        
        // navigate to the currect page
        navigateToBreakPointPage(previousLeadingOffer)
    }
    
    func navigateToBreakPointPage(_ currentLeadingOffer: LayoutSchemaUIModel?) {
        if let currentLeadingOffer {
            var newPageIndex = 0
            pages.forEach{ page in
                if page.contains(currentLeadingOffer) {
                    currentGroup = newPageIndex
                }
                newPageIndex += 1
            }
        }
    }
}
