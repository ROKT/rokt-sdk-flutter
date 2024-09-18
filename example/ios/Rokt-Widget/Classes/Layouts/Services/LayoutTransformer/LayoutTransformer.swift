//
//  LayoutTransformer.swift
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
struct LayoutTransformer<Expander: PayloadExpander, Extractor: DataExtractor> where Expander.T == OfferModel {
    let layoutPlugin: LayoutPlugin
    let expander: Expander
    let extractor: Extractor
    let config: RoktConfig?
    
    init(
        layoutPlugin: LayoutPlugin,
        expander: Expander = BNFPayloadExpander(),
        extractor: Extractor = BNFDataExtractor(),
        config: RoktConfig? = nil
    ) {
        self.layoutPlugin = layoutPlugin
        self.expander = expander
        self.extractor = extractor
        self.config = config
    }
    
    func transform() throws -> LayoutSchemaUIModel? {
        guard let layout = layoutPlugin.layout else { return nil}
        
        let transformedUIModels = try transform(layout)
        
        for (slotIndex, slot) in layoutPlugin.slots.enumerated() {
            expander.expand(
                layoutVariant: transformedUIModels,
                parent: nil,
                creativeParent: nil,
                using: slot.offer,
                dataSourceIndex: slotIndex,
                usesDataSourceIndex: nil
            )
        }
        
        AttributedStringTransformer.convertRichTextHTMLIfExists(uiModel: transformedUIModels, config: config)
        
        return transformedUIModels
    }
    
    func transform<T: Codable>(_ layout: T, slot: SlotModel? = nil) throws -> LayoutSchemaUIModel {
        if let layout = layout as? LayoutSchemaModel {
            return try transform(layout, slot: slot)
        } else if let layout = layout as? AccessibilityGroupedLayoutChildren {
            return try transform(layout, slot: slot)
        } else {
            return .empty
        }
    }
    
    func transform(_ layout: LayoutSchemaModel, slot: SlotModel? = nil) throws -> LayoutSchemaUIModel {
        switch layout {
        case .row(let rowModel):
            return .row(try getRow(rowModel.styles, children: transformChildren(rowModel.children, slot: slot)))
        case .column(let columnModel):
            return .column(try getColumn(columnModel.styles, children: transformChildren(columnModel.children, slot: slot)))
        case .zStack(let zStackModel):
            return .zStack(try getZStack(zStackModel.styles,
                                         children: transformChildren(zStackModel.children, slot: slot)))
        case .basicText(let basicTextModel): return .basicText(try getBasicText(basicTextModel))
        case .staticImage(let imageModel): return .staticImage(try getStaticImage(imageModel))
        case .richText(let richTextModel):
            return .richText(try getRichText(richTextModel))
            
        case .dataImage(let imageModel): return .dataImage(try getDataImage(imageModel, slot: slot))
        case .progressIndicator(let progressIndicatorModel):
            return .progressIndicator(try getProgressIndicatorUIModel(progressIndicatorModel))
        case .creativeResponse(let model):
            return try getCreativeResponse(responseKey: model.responseKey,
                                           openLinks: model.openLinks,
                                           styles: model.styles,
                                           children: transformChildren(model.children, slot: slot),
                                           slot: slot)
        case .oneByOneDistribution(let oneByOneModel):
            return .oneByOne(try getOneByOne(oneByOneModel: oneByOneModel))
        case .overlay(let overlayModel):
            return .overlay(try getOverlay(overlayModel.styles,
                                           allowBackdropToClose: overlayModel.allowBackdropToClose,
                                           children: transformChildren(overlayModel.children, slot: slot)))
        case .bottomSheet(let bottomSheetModel):
            return .bottomSheet(try getBottomSheet(bottomSheetModel.styles,
                                                   allowBackdropToClose: bottomSheetModel.allowBackdropToClose,
                                                   children: transformChildren(bottomSheetModel.children, slot: slot)))
        case .when(let whenModel):
            return .when(getWhenNode(children: try transformChildren(whenModel.children, slot: slot),
                                     predicates: whenModel.predicates,
                                     transition: whenModel.transition))
        case .staticLink(let staticLinkModel):
            return .staticLink(try getStaticLink(src: staticLinkModel.src,
                                                 open: staticLinkModel.open,
                                                 styles: staticLinkModel.styles,
                                                 children: transformChildren(staticLinkModel.children, slot: slot)))
        case .closeButton(let closeButtonModel):
            return .closeButton(try getCloseButton(styles: closeButtonModel.styles,
                                                   children: transformChildren(closeButtonModel.children, slot: slot)))
        case .carouselDistribution(let carouselModel):
            return .carousel(try getCarousel(carouselModel: carouselModel))
        case .groupedDistribution(let groupedModel):
            return .groupDistribution(try getGroupedDistribution(groupedModel: groupedModel))
        case .progressControl(let progressControlModel):
            return .progressControl(try getProgressControl(styles: progressControlModel.styles,
                                                           direction: progressControlModel.direction,
                                                           children: transformChildren(progressControlModel.children,
                                                                                       slot: slot)))
        case .accessibilityGrouped(let accessibilityGroupedModel):
            return try getAccessibilityGrouped(child: accessibilityGroupedModel.child,
                                               slot: slot)
        case .scrollableColumn(let columnModel):
            return .scrollableColumn(try getScrollableColumn(columnModel.styles,
                                                             children:
                                                                transformChildren(columnModel.children, slot: slot)))
        case .scrollableRow(let rowModel):
            return .scrollableRow(try getScrollableRow(rowModel.styles,
                                                       children: transformChildren(rowModel.children, slot: slot)))
        case .toggleButtonStateTrigger(let buttonModel):
            return .toggleButton(try getToggleButton(customStateKey: buttonModel.customStateKey,
                                                     styles: buttonModel.styles,
                                                     children: transformChildren(buttonModel.children,
                                                                                 slot: slot)))
        }
    }
    
    func transform(_ layout: AccessibilityGroupedLayoutChildren, slot: SlotModel? = nil) throws -> LayoutSchemaUIModel {
        switch layout {
        case .row(let rowModel):
            return .row(try getRow(rowModel.styles, children: transformChildren(rowModel.children, slot: slot)))
        case .column(let columnModel):
            return .column(try getColumn(columnModel.styles,children: transformChildren(columnModel.children, slot: slot)))
        case .zStack(let zStackModel):
            return .zStack(try getZStack(zStackModel.styles, children: transformChildren(zStackModel.children, slot: slot)))
        }
    }
    
    func transformChildren<T: Codable>(_ layouts: [T]?, slot: SlotModel?) throws -> [LayoutSchemaUIModel]? {
        guard let layouts else { return nil }
        
        var children: [LayoutSchemaUIModel] = []
        
        try layouts.forEach { layout in
            children.append(try transform(layout, slot: slot))
        }
        
        return children
    }
    
    // attach inner layout into outer layout and transform to UI Model
    func getOneByOne(oneByOneModel: OneByOneDistributionModel<WhenPredicate>) throws -> OneByOneUIModel {
        var children: [LayoutSchemaUIModel] = []
        
        try layoutPlugin.slots.forEach { slot in
            if let innerLayout = slot.layoutVariant?.layoutVariantSchema {
                children.append(try transform(innerLayout, slot: slot))
            }
        }
        let updateStyles = try StyleTransformer.updatedStyles(oneByOneModel.styles?.elements?.own)
        return OneByOneUIModel(children: children,
                               defaultStyle: updateStyles.compactMap{$0.default},
                               transition: oneByOneModel.transition)
    }
    
    func getCarousel(carouselModel: CarouselDistributionModel<WhenPredicate>) throws -> CarouselUIModel {
        var children: [LayoutSchemaUIModel] = []
        
        try layoutPlugin.slots.forEach { slot in
            if let innerLayout = slot.layoutVariant?.layoutVariantSchema {
                children.append(try transform(innerLayout, slot: slot))
            }
        }
        let updateStyles = try StyleTransformer.updatedStyles(carouselModel.styles?.elements?.own)
        return CarouselUIModel(children: children,
                               defaultStyle: updateStyles.compactMap{$0.default},
                               viewableItems: carouselModel.viewableItems,
                               peekThroughSize: carouselModel.peekThroughSize
        )
    }    
    
    func getGroupedDistribution(groupedModel: GroupedDistributionModel<WhenPredicate>) throws -> GroupedDistributionUIModel {
        var children: [LayoutSchemaUIModel] = []
        
        try layoutPlugin.slots.forEach { slot in
            if let innerLayout = slot.layoutVariant?.layoutVariantSchema {
                children.append(try transform(innerLayout, slot: slot))
            }
        }
        let updateStyles = try StyleTransformer.updatedStyles(groupedModel.styles?.elements?.own)
        return GroupedDistributionUIModel(children: children,
                                          defaultStyle: updateStyles.compactMap{$0.default}, 
                                          viewableItems: groupedModel.viewableItems, 
                                          transition: groupedModel.transition)
    }
    
    //MARK: Component Models
    func getStaticImage(_ imageModel: StaticImageModel<WhenPredicate>) throws -> StaticImageUIModel {
        let updateStyles = try StyleTransformer.updatedStyles(imageModel.styles?.elements?.own)
        return StaticImageUIModel(url: imageModel.url,
                                  alt: imageModel.alt,
                                  defaultStyle: updateStyles.compactMap{$0.default},
                                  pressedStyle: updateStyles.compactMap{$0.pressed},
                                  hoveredStyle: updateStyles.compactMap{$0.hovered},
                                  disabledStyle: updateStyles.compactMap{$0.disabled})
    }
    
    func getStaticLink(src: String,
                       open: LinkOpenTarget,
                       styles: LayoutStyle<StaticLinkElements, ConditionalStyleTransition<StaticLinkTransitions, WhenPredicate>>?,
                       children: [LayoutSchemaUIModel]?) throws -> StaticLinkUIModel {
        let updateStyles = try StyleTransformer.updatedStyles(styles?.elements?.own)
        return StaticLinkUIModel(children: children,
                                 src: src,
                                 open: open,
                                 defaultStyle: updateStyles.compactMap{$0.default},
                                 pressedStyle: updateStyles.compactMap{$0.pressed},
                                 hoveredStyle: updateStyles.compactMap{$0.hovered},
                                 disabledStyle: updateStyles.compactMap{$0.disabled})
    }
    
    func getCloseButton(styles: LayoutStyle<CloseButtonElements, ConditionalStyleTransition<CloseButtonTransitions, WhenPredicate>>?,
                        children: [LayoutSchemaUIModel]?) throws -> CloseButtonUIModel {
        let updateStyles = try StyleTransformer.updatedStyles(styles?.elements?.own)
        return CloseButtonUIModel(children: children,
                                  defaultStyle: updateStyles.compactMap{$0.default},
                                  pressedStyle: updateStyles.compactMap{$0.pressed},
                                  hoveredStyle: updateStyles.compactMap{$0.hovered},
                                  disabledStyle: updateStyles.compactMap{$0.disabled})
    }
    
    func getProgressControl(styles: LayoutStyle<ProgressControlElements, ConditionalStyleTransition<ProgressControlTransitions, WhenPredicate>>?,
                            direction: ProgressionDirection,
                            children: [LayoutSchemaUIModel]?) throws -> ProgressControlUIModel {
        let updateStyles = try StyleTransformer.updatedStyles(styles?.elements?.own)
        return ProgressControlUIModel(children: children,
                                      defaultStyle: updateStyles.compactMap{$0.default},
                                      pressedStyle: updateStyles.compactMap{$0.pressed},
                                      hoveredStyle: updateStyles.compactMap{$0.hovered},
                                      disabledStyle: updateStyles.compactMap{$0.disabled},
                                      direction: direction)
    }
    
    func getDataImage(_ imageModel: DataImageModel<WhenPredicate>, slot: SlotModel?) throws -> DataImageUIModel {
        let creativeImage = slot?.offer?.creative.images?[imageModel.imageKey]
        let updateStyles = try StyleTransformer.updatedStyles(imageModel.styles?.elements?.own)
        return DataImageUIModel(image: creativeImage,
                                defaultStyle: updateStyles.compactMap{$0.default},
                                pressedStyle: updateStyles.compactMap{$0.pressed},
                                hoveredStyle: updateStyles.compactMap{$0.hovered},
                                disabledStyle: updateStyles.compactMap{$0.disabled})
    }
    
    func getBasicText(_ basicTextModel: BasicTextModel<WhenPredicate>) throws -> BasicTextUIModel {
        let updateStyles = try StyleTransformer.updatedStyles(basicTextModel.styles?.elements?.own)
        return BasicTextUIModel(value: basicTextModel.value,
                                defaultStyle: updateStyles.compactMap{$0.default},
                                pressedStyle: updateStyles.compactMap{$0.pressed},
                                hoveredStyle: updateStyles.compactMap{$0.hovered},
                                disabledStyle: updateStyles.compactMap{$0.disabled})
    }
    
    func getRichText(_ richTextModel: RichTextModel<WhenPredicate>) throws -> RichTextUIModel {
        let updateStyles = try StyleTransformer.updatedStyles(richTextModel.styles?.elements?.own)
        let updateLinkStyles = try StyleTransformer.updatedStyles(richTextModel.styles?.elements?.link)
        return RichTextUIModel(value: richTextModel.value,
                               defaultStyle: updateStyles.compactMap{$0.default},
                               linkStyle: updateLinkStyles.compactMap{$0.default},
                               openLinks: richTextModel.openLinks)
    }
    
    func getColumn(_ styles: LayoutStyle<ColumnElements, ConditionalStyleTransition<ColumnTransitions, WhenPredicate>>?,
                   children: [LayoutSchemaUIModel]?,
                   accessibilityGrouped: Bool = false) throws -> ColumnUIModel {
        let updateStyles = try StyleTransformer.updatedStyles(styles?.elements?.own)
        return ColumnUIModel(children: children,
                             defaultStyle: updateStyles.compactMap{$0.default},
                             pressedStyle: updateStyles.compactMap{$0.pressed},
                             hoveredStyle: updateStyles.compactMap{$0.hovered},
                             disabledStyle: updateStyles.compactMap{$0.disabled}, 
                             accessibilityGrouped: accessibilityGrouped)
    }    
    
    func getScrollableColumn(_ styles: LayoutStyle<ScrollableColumnElements, ConditionalStyleTransition<ScrollableColumnTransitions, WhenPredicate>>?,
                   children: [LayoutSchemaUIModel]?,
                   accessibilityGrouped: Bool = false) throws -> ColumnUIModel {
        let updateStyles = try StyleTransformer.updatedStyles(styles?.elements?.own)
        return ColumnUIModel(children: children,
                             defaultStyle: updateStyles.compactMap {
            StyleTransformer.convertToColumnStyles($0.default)
        },
                             pressedStyle: updateStyles.compactMap {
            StyleTransformer.convertToColumnStyles($0.pressed)
        },
                             hoveredStyle: updateStyles.compactMap {
            StyleTransformer.convertToColumnStyles($0.hovered)
        },
                             disabledStyle: updateStyles.compactMap {
            StyleTransformer.convertToColumnStyles($0.disabled)
        },
                             accessibilityGrouped: accessibilityGrouped)
    }
    
    func getRow(_ styles: LayoutStyle<RowElements, ConditionalStyleTransition<RowTransitions, WhenPredicate>>?,
                children: [LayoutSchemaUIModel]?,
                accessibilityGrouped: Bool = false) throws -> RowUIModel {
        let updateStyles = try StyleTransformer.updatedStyles(styles?.elements?.own)
        
        return RowUIModel(children: children,
                          defaultStyle: updateStyles.compactMap{$0.default},
                          pressedStyle: updateStyles.compactMap{$0.pressed},
                          hoveredStyle: updateStyles.compactMap{$0.hovered},
                          disabledStyle: updateStyles.compactMap{$0.disabled}, 
                          accessibilityGrouped: accessibilityGrouped)
    }  
    
    func getScrollableRow(_ styles: LayoutStyle<ScrollableRowElements, ConditionalStyleTransition<ScrollableRowTransitions, WhenPredicate>>?,
                          children: [LayoutSchemaUIModel]?,
                          accessibilityGrouped: Bool = false) throws -> RowUIModel {
        let updateStyles = try StyleTransformer.updatedStyles(styles?.elements?.own)
        
        return RowUIModel(children: children,
                          defaultStyle: updateStyles.compactMap {
            StyleTransformer.convertToRowStyles($0.default)
        },
                          pressedStyle: updateStyles.compactMap {
            StyleTransformer.convertToRowStyles($0.pressed)
        },
                          hoveredStyle: updateStyles.compactMap {
            StyleTransformer.convertToRowStyles($0.hovered)
        },
                          disabledStyle: updateStyles.compactMap {
            StyleTransformer.convertToRowStyles($0.disabled)
        },
                          accessibilityGrouped: accessibilityGrouped)
    }
    
    func getZStack(_ styles: LayoutStyle<ZStackElements, ConditionalStyleTransition<ZStackTransitions, WhenPredicate>>?,
                   children: [LayoutSchemaUIModel]?,
                   accessibilityGrouped: Bool = false) throws -> ZStackUIModel {
        let updateStyles = try StyleTransformer.updatedStyles(styles?.elements?.own)
        return ZStackUIModel(children: children,
                             defaultStyle: updateStyles.compactMap{$0.default},
                             pressedStyle: updateStyles.compactMap{$0.pressed},
                             hoveredStyle: updateStyles.compactMap{$0.hovered},
                             disabledStyle: updateStyles.compactMap{$0.disabled},
                             accessibilityGrouped: accessibilityGrouped)
    }
    
    func getAccessibilityGrouped(child: AccessibilityGroupedLayoutChildren,
                                 slot: SlotModel? = nil) throws -> LayoutSchemaUIModel {
        switch child {
        case .column(let columnModel):
            return .column(try getColumn(columnModel.styles,
                                         children: transformChildren(columnModel.children, slot: slot),
                                         accessibilityGrouped: true))
        case .row(let rowModel):
            return .row(try getRow(rowModel.styles,
                                   children: transformChildren(rowModel.children, slot: slot),
                                   accessibilityGrouped: true))
        case .zStack(let zStackModel):
            return .zStack(try getZStack(zStackModel.styles,
                                         children: transformChildren(zStackModel.children, slot: slot),
                                         accessibilityGrouped: true))
        }
    }
    
    func getOverlay(_ styles: LayoutStyle<OverlayElements, ConditionalStyleTransition<OverlayTransitions, WhenPredicate>>?,
                    allowBackdropToClose: Bool?,
                    children: [LayoutSchemaUIModel]?) throws -> OverlayUIModel {
        let updateStyles = try StyleTransformer.updatedStyles(styles?.elements?.own)
        let updateWrapperStyles = try StyleTransformer.updatedStyles(styles?.elements?.wrapper)
        return OverlayUIModel(children:children, 
                              allowBackdropToClose: allowBackdropToClose,
                              defaultStyle: updateStyles.compactMap{$0.default},
                              wrapperStyle: updateWrapperStyles.compactMap{$0.default})
    }
    
    func getBottomSheet(_ styles: LayoutStyle<BottomSheetElements, ConditionalStyleTransition<BottomSheetTransitions, WhenPredicate>>?,
                        allowBackdropToClose: Bool?,
                        children: [LayoutSchemaUIModel]?) throws -> BottomSheetUIModel {
        let updateStyles = try StyleTransformer.updatedStyles(styles?.elements?.own)
        return BottomSheetUIModel(children:children,
                                  allowBackdropToClose: allowBackdropToClose,
                                  defaultStyle: updateStyles.compactMap{$0.default})
    }
    
    func getCreativeResponse(responseKey: String,
                             openLinks: LinkOpenTarget?,
                             styles: LayoutStyle<CreativeResponseElements, ConditionalStyleTransition<CreativeResponseTransitions, WhenPredicate>>?,
                             children: [LayoutSchemaUIModel]?,
                             slot: SlotModel?) throws -> LayoutSchemaUIModel {
        guard let responseOptionsMap = slot?.offer?.creative.responseOptionsMap,
              (responseKey == BNFNamespace.CreativeResponseKey.positive.rawValue
               && responseOptionsMap.positive != nil)
                ||
                (responseKey == BNFNamespace.CreativeResponseKey.negative.rawValue
                 && responseOptionsMap.negative != nil)
        else {
            return .empty
        }
        
        return .creativeResponse(try getCreativeResponseUIModel(responseKey: responseKey,
                                                                openLinks: openLinks,
                                                                styles: styles,
                                                                children: children,
                                                                slot: slot))
    }
    
    func getCreativeResponseUIModel(responseKey: String,
                                    openLinks: LinkOpenTarget?,
                                    styles: LayoutStyle<CreativeResponseElements, ConditionalStyleTransition<CreativeResponseTransitions, WhenPredicate>>?,
                                    children: [LayoutSchemaUIModel]?,
                                    slot: SlotModel?) throws -> CreativeResponseUIModel {
        var responseOption: ResponseOption?
        var creativeResponseKey = BNFNamespace.CreativeResponseKey.positive
        
        if responseKey == BNFNamespace.CreativeResponseKey.positive.rawValue {
            responseOption = slot?.offer?.creative.responseOptionsMap?.positive
            creativeResponseKey = .positive
        }
        
        if responseKey == BNFNamespace.CreativeResponseKey.negative.rawValue {
            responseOption = slot?.offer?.creative.responseOptionsMap?.negative
            creativeResponseKey = .negative
        }
        let updateStyles = try StyleTransformer.updatedStyles(styles?.elements?.own)
        return CreativeResponseUIModel(children: children,
                                       responseKey: creativeResponseKey,
                                       responseOptions: responseOption,
                                       openLinks: openLinks,
                                       defaultStyle: updateStyles.compactMap{$0.default},
                                       pressedStyle: updateStyles.compactMap{$0.pressed},
                                       hoveredStyle: updateStyles.compactMap{$0.hovered},
                                       disabledStyle: updateStyles.compactMap{$0.disabled})
    }
    
    func getProgressIndicator(_ progressIndicatorModel: ProgressIndicatorModel<WhenPredicate>) throws -> LayoutSchemaUIModel {
        do {
            let indicatorData = try extractor.extractDataRepresentedBy(
                String.self,
                propertyChain: progressIndicatorModel.indicator,
                responseKey: nil,
                from: nil
            )
            
            guard case .state(let stateValue) = indicatorData,
                  DataBindingStateKeys.isValidKey(stateValue)
            else { return .empty }
            
            return .progressIndicator(try getProgressIndicatorUIModel(progressIndicatorModel))
        } catch {
            return .empty
        }
    }
    
    func getProgressIndicatorUIModel(_ progressIndicatorModel: ProgressIndicatorModel<WhenPredicate>) throws -> ProgressIndicatorUIModel {
        let updateStyles = try StyleTransformer.updatedStyles(progressIndicatorModel.styles?.elements?.own)
        let indicatorStyle = try StyleTransformer.updatedStyles(progressIndicatorModel.styles?.elements?.indicator)
        let seenIndicatorStyle =
        try StyleTransformer.updatedIndicatorStyles(indicatorStyle,
                                                    newStyles: progressIndicatorModel.styles?.elements?.seenIndicator)
        // active falls back to seen (which then falls back to indicator)
        let activeIndicatorStyle =
        try StyleTransformer.updatedIndicatorStyles(seenIndicatorStyle,
                                                    newStyles: progressIndicatorModel.styles?.elements?.activeIndicator)
        return ProgressIndicatorUIModel(
            indicator: progressIndicatorModel.indicator,
            defaultStyle: updateStyles.compactMap{$0.default},
            indicatorStyle: indicatorStyle.compactMap{$0.default},
            activeIndicatorStyle: activeIndicatorStyle.compactMap{$0.default},
            seenIndicatorStyle: seenIndicatorStyle.compactMap{$0.default},
            startPosition: progressIndicatorModel.startPosition,
            accessibilityHidden: progressIndicatorModel.accessibilityHidden
        )
    }
    
    func getWhenNode(children: [LayoutSchemaUIModel]?,
                     predicates: [WhenPredicate],
                     transition: WhenTransition?) -> WhenUIModel {
        return WhenUIModel(children: children,
                           predicates: predicates,
                           transition: transition)
    }
    
    func getToggleButton(customStateKey: String,
                         styles: LayoutStyle<ToggleButtonStateTriggerElements,
                         ConditionalStyleTransition<ToggleButtonStateTriggerTransitions, WhenPredicate>>?,
                         children: [LayoutSchemaUIModel]?) throws -> ToggleButtonUIModel {
        let updateStyles = try StyleTransformer.updatedStyles(styles?.elements?.own)
        return ToggleButtonUIModel(children: children,
                                   customStateKey: customStateKey,
                                   defaultStyle: updateStyles.compactMap{$0.default},
                                   pressedStyle: updateStyles.compactMap{$0.pressed},
                                   hoveredStyle: updateStyles.compactMap{$0.hovered},
                                   disabledStyle: updateStyles.compactMap{$0.disabled})
    }
}
