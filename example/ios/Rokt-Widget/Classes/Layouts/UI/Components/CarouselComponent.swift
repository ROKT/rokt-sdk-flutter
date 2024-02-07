//
//  CarouselComponent.swift
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
struct CarouselComponent: View {
    @EnvironmentObject var globalScreenSize: GlobalScreenSize
    
    var style: CarouselDistributionStyles? {
        return model.defaultStyle
    }
    
    var containerStyle: ContainerStylingProperties? { style?.container }
    var dimensionStyle: DimensionStylingProperties? { style?.dimension }
    var flexStyle: FlexChildStylingProperties? { style?.flexChild }
    var borderStyle: BorderStylingProperties? { style?.border }
    var spacingStyle: SpacingStylingProperties? { style?.spacing }
    var backgroundStyle: BackgroundStylingProperties? { style?.background }
    
    let parent: ComponentParent
    let model: CarouselUIModel
    let baseDI: BaseDependencyInjection
    
    @ObservedObject var viewModel: CarouselViewModel
    @Binding var parentWidth: CGFloat?
    @Binding var parentHeight: CGFloat?
    @Binding var styleState: StyleState
    
    @State var currentOffer = 0
    @GestureState var offset: CGFloat = 0
    
    @State var geometryReaderHeight: CGFloat?
    
    let parentVerticalAlignment: VerticalAlignment?
    let parentHorizontalAlignment: HorizontalAlignment?
    
    var parentBackgroundStyle: BackgroundStylingProperties?
    
    var passableBackgroundStyle: BackgroundStylingProperties? {
        backgroundStyle ?? parentBackgroundStyle
    }
    
    init(
        parent: ComponentParent,
        model: CarouselUIModel,
        baseDI: BaseDependencyInjection,
        parentWidth: Binding<CGFloat?>,
        parentHeight: Binding<CGFloat?>,
        styleState: Binding<StyleState>,
        parentVerticalAlignment: VerticalAlignment?,
        parentHorizontalAlignment: HorizontalAlignment?,
        parentBackgroundStyle: BackgroundStylingProperties? = nil
    ) {
        self.parent = parent
        _parentWidth = parentWidth
        _parentHeight = parentHeight
        _styleState = styleState
        
        self.parentVerticalAlignment = parentVerticalAlignment
        self.parentHorizontalAlignment = parentHorizontalAlignment
        self.parentBackgroundStyle = parentBackgroundStyle
        
        self.model = model
        self.baseDI = baseDI
        
        self.viewModel = CarouselViewModel(model: model,
                                           baseDI: baseDI)
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
            GeometryReader { containerProxy in
                let totalOffers = children.count
                
                let peekThrough = getPeekThrough(width: containerProxy.size.width)
                let leadingPeekThrough = getOfferLeadingPeekThrough(peekThrough, totalOffers: totalOffers)
                let width = containerProxy.size.width - peekThrough*2
                
                LazyHStack(alignment: .center, spacing: 0) {
                    ForEach((0..<totalOffers), id: \.self) { childIndex in
                        LayoutSchemaComponent(parent: parent,
                                              layout: children[childIndex],
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
                        .frame(width: width, alignment: .top)
                        .offset(x: (containerProxy.size.width - width)/2 - peekThrough)
                        .overlay(
                            GeometryReader { childProxy -> Color in
                                DispatchQueue.main.async {
                                    geometryReaderHeight = max(geometryReaderHeight ?? 0, childProxy.size.height)
                                }
                                return Color.clear
                            }
                        )
                    }
                }
                .offset(x: (CGFloat(currentOffer) * -width) + offset + leadingPeekThrough)
                .gesture(
                    DragGesture()
                        .updating($offset, body: { value, out, _ in
                            out = value.translation.width
                        })
                        .onEnded({ value in
                            let progress = -value.translation.width/width
                            let roundProgress = Int(progress.rounded())
                            // ensure currentOffer is never below 0 or above totalOffers
                            currentOffer = max(min(currentOffer + roundProgress, totalOffers - 1), 0)
                        })
                )
            }
            .onLoad {
                registerActions()
                viewModel.sendImpressionEvents(currentOffer: currentOffer)
            }
            .onChange(of: currentOffer) { newValue in
                viewModel.sendImpressionEvents(currentOffer: newValue)
            }
            // workaround to set dynamic height otherwise GeometryReader fills available space
            .frame(height: geometryReaderHeight)
        }
    }
    
    func registerActions() {
        baseDI.actionCollection["nextOffer"] = goToNextOffer
    }
    
    func goToNextOffer() {
        if currentOffer + 1 < viewModel.model.children?.count ?? 0 {
            withAnimation(.linear) {
                self.currentOffer = currentOffer + 1
            }
        } else {
            if case .embeddedLayout = baseDI.layoutType() {
                viewModel.sendDismissalCollapsedEvent()
            } else {
                viewModel.sendDismissalNoMoreOfferEvent()
            }
            exit()
        }
    }
    
    func exit() {
        baseDI.actionCollection["Close"]()
    }
    
    func getPeekThrough(width: CGFloat) -> CGFloat {
        
        // get PeekThroughSize for breakpoint
        let breakPointPeekThrough: PeekThroughSize?
        guard let globalBreakPoints = baseDI.sharedData.items[SharedData.breakPointsSharedKey] as? BreakPoint,
              !globalBreakPoints.isEmpty
        else { return 0 }
        // TODO: calculate by breakpoint (currently only uses first value)
        breakPointPeekThrough = viewModel.model.peekThroughSize.first
        
        // convert PeekThroughSize to actual width
        switch breakPointPeekThrough {
        case .fixed(let peekthrough):
            return CGFloat(peekthrough)
        case .percentage(let percentage):
            return width * CGFloat(percentage/100)
        default:
            return 0
        }
    }
    
    func getOfferLeadingPeekThrough(_ peekThrough: CGFloat,
                                    totalOffers: Int) -> CGFloat {
        // This calculates the offset we require to apply peek through logic:
        // 1. 1st offer has trailing peek through of width=peekThrough*2
        // 2. Last offer has leading peek through of width=peekThrough*2
        // 3. In-between offers have both leading and trailing peek through of width=peekThrough
        return currentOffer == 0 ? 0
        : (currentOffer == totalOffers - 1
           ? peekThrough*2 : peekThrough)
    }
    
    func getBaseDI() -> BaseDependencyInjection {
        baseDI.sharedData.items[SharedData.currentOfferIndexKey] = $currentOffer
        baseDI.sharedData.items[SharedData.totalItemsKey] = viewModel.model.children?.count ?? 0
        return baseDI
    }
}
