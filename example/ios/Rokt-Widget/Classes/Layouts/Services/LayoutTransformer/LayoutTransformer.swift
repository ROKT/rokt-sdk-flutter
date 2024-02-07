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

    init(
        layoutPlugin: LayoutPlugin,
        expander: Expander = BNFPayloadExpander(),
        extractor: Extractor = BNFDataExtractor()
    ) {
        self.layoutPlugin = layoutPlugin
        self.expander = expander
        self.extractor = extractor
    }
    
    func transform() -> LayoutSchemaUIModel? {
        guard let layout = layoutPlugin.layout else { return nil}

        let transformedUIModels = transform(layout)

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

        convertRichTextHTMLIfExists(uiModel: transformedUIModels)

        return transformedUIModels
    }

    func convertRichTextHTMLIfExists(uiModel: LayoutSchemaUIModel) {
        switch uiModel {
        case .overlay(let parentModel):
            convertRichTextHTMLInChildren(parent: parentModel)
        case .bottomSheet(let parentModel):
            convertRichTextHTMLInChildren(parent: parentModel)
        case .row(let parentModel):
            convertRichTextHTMLInChildren(parent: parentModel)
        case .column(let parentModel):
            convertRichTextHTMLInChildren(parent: parentModel)
        case .oneByOne(let parentModel):
            convertRichTextHTMLInChildren(parent: parentModel)
        case .carousel(let parentModel):
            convertRichTextHTMLInChildren(parent: parentModel)
        case .when(let parentModel):
            convertRichTextHTMLInChildren(parent: parentModel)
        case .creativeResponse(let parentModel):
            convertRichTextHTMLInChildren(parent: parentModel)
        case .richText(let richTextUIModel):
            richTextUIModel.transformValueToAttributedString()
        default:
            break
        }
    }

    func convertRichTextHTMLInChildren(parent: DomainMappableParent) {
        guard let children = parent.children, !children.isEmpty else { return }

        children.forEach { convertRichTextHTMLIfExists(uiModel: $0) }
    }
    
    func transform<T: Codable>(_ layout: T, slot: SlotModel? = nil) -> LayoutSchemaUIModel {
        if let layout = layout as? LayoutSchemaModel {
            return transform(layout, slot: slot)
        } else if let layout = layout as? LayoutVariantSchemaModel {
            return transform(layout, slot: slot)
        } else if let layout = layout as? LayoutVariantChildren {
            return transform(layout, slot: slot)
        } else if let layout = layout as? OuterLayoutSchemaModel {
            return transform(layout, slot: slot)
        } else if let layout = layout as? OuterLayoutChildren {
            return transform(layout, slot: slot)
        } else if let layout = layout as? CreativeResponseChildren {
            return transform(layout, slot: slot)
        } else if let layout = layout as? OverlayChildren {
            return transform(layout, slot: slot)
        } else if let layout = layout as? BottomSheetChildren {
            return transform(layout, slot: slot)
        } else if let layout = layout as? StaticLinkChildren {
            return transform(layout, slot: slot)
        } else if let layout = layout as? CloseButtonChildren {
            return transform(layout, slot: slot)
        } else {
            return .empty
        }
    }
    
    func transform(_ layout: LayoutSchemaModel, slot: SlotModel? = nil) -> LayoutSchemaUIModel {
        switch layout {
        case .row(let rowModel):
            return .row(getRow(rowModel.styles, children: transformChildren(rowModel.children, slot: slot)))
        case .column(let columnModel):
            return .column(getColumn(columnModel.styles,children: transformChildren(columnModel.children, slot: slot)))
        case .basicText(let basicTextModel): return .basicText(getBasicText(basicTextModel))
        case .staticImage(let imageModel): return .staticImage(getStaticImage(imageModel))
        case .richText(let richTextModel):
            return .richText(getRichText(richTextModel))
            
        case .dataImage(let imageModel): return .dataImage(getDataImage(imageModel, slot: slot))
        case .progressIndicator(let progressIndicatorModel):
            return .progressIndicator(getProgressIndicatorUIModel(progressIndicatorModel))
        case .creativeResponse(let model):
            return getCreativeResponse(responseKey: model.responseKey,
                                       openLinks: model.openLinks,
                                       styles: model.styles,
                                       children: transformChildren(model.children, slot: slot),
                                       slot: slot)
        case .oneByOneDistribution(let oneByOneModel):
            return .oneByOne(getOneByOne(oneByOneModel: oneByOneModel))
        case .overlay(let overlayModel):
            return .overlay(getOverlay(overlayModel.styles, settings: overlayModel.settings,
                                       children: transformChildren(overlayModel.children, slot: slot)))
        case .bottomSheet(let bottomSheetModel):
            return .bottomSheet(getBottomSheet(bottomSheetModel.styles, settings: bottomSheetModel.settings,
                                               children: transformChildren(bottomSheetModel.children, slot: slot)))
        case .when(let whenModel):
            return .when(getWhenNode(children: transformChildren(whenModel.children, slot: slot),
                                     predicates: whenModel.predicates))
        case .staticLink(let staticLinkModel):
            return .staticLink(getStaticLink(src: staticLinkModel.src,
                                             open: staticLinkModel.open,
                                             styles: staticLinkModel.styles,
                                             children: transformChildren(staticLinkModel.children, slot: slot)))
        case .closeButton(let closeButtonModel):
            return .closeButton(getCloseButton(styles: closeButtonModel.styles,
                                               children: transformChildren(closeButtonModel.children, slot: slot)))
        case .carouselDistribution(let carouselModel):
            return .carousel(getCarousel(carouselModel: carouselModel))
        }
    }
    
    func transform(_ layout: LayoutVariantChildren, slot: SlotModel? = nil) -> LayoutSchemaUIModel {
        switch layout {
        case .row(let rowModel):
            return .row(getRow(rowModel.styles, children: transformChildren(rowModel.children, slot: slot)))
        case .column(let columnModel):
            return .column(getColumn(columnModel.styles,children: transformChildren(columnModel.children, slot: slot)))
        case .basicText(let basicTextModel): return .basicText(getBasicText(basicTextModel))
        case .staticImage(let imageModel): return .staticImage(getStaticImage(imageModel))
        case .dataImage(let imageModel): return .dataImage(getDataImage(imageModel, slot: slot))
        case .richText(let richTextModel):
            return .richText(getRichText(richTextModel))
        case .creativeResponse(let model):
            return getCreativeResponse(responseKey: model.responseKey,
                                       openLinks: model.openLinks,
                                       styles: model.styles,
                                       children: transformChildren(model.children, slot: slot),
                                       slot: slot)
        case .when(let whenModel):
            return .when(getWhenNode(children: transformChildren(whenModel.children, slot: slot),
                                     predicates: whenModel.predicates))
        case .staticLink(let staticLinkModel):
            return .staticLink(getStaticLink(src: staticLinkModel.src,
                                             open: staticLinkModel.open,
                                             styles: staticLinkModel.styles,
                                             children: transformChildren(staticLinkModel.children, slot: slot)))
        case .closeButton(let closeButtonModel):
            return .closeButton(getCloseButton(styles: closeButtonModel.styles,
                                               children: transformChildren(closeButtonModel.children, slot: slot)))
        }
    }
                
    func transform(_ layout: LayoutVariantSchemaModel, slot: SlotModel? = nil) -> LayoutSchemaUIModel {
        switch layout {
        case .row(let rowModel):
            return .row(getRow(rowModel.styles, children: transformChildren(rowModel.children, slot: slot)))
        case .column(let columnModel):
            return .column(getColumn(columnModel.styles,children: transformChildren(columnModel.children, slot: slot)))
        case .basicText(let basicTextModel): return .basicText(getBasicText(basicTextModel))
        case .staticImage(let imageModel): return .staticImage(getStaticImage(imageModel))
        case .dataImage(let imageModel): return .dataImage(getDataImage(imageModel, slot: slot))
        case .richText(let richTextModel):
            return .richText(getRichText(richTextModel))
        case .creativeResponse(let model):
            return getCreativeResponse(responseKey: model.responseKey,
                                       openLinks: model.openLinks,
                                       styles: model.styles,
                                       children: transformChildren(model.children, slot: slot),
                                       slot: slot)
        case .when(let whenModel):
            return .when(getWhenNode(children: transformChildren(whenModel.children, slot: slot),
                                     predicates: whenModel.predicates))
        case .staticLink(let staticLinkModel):
            return .staticLink(getStaticLink(src: staticLinkModel.src,
                                             open: staticLinkModel.open,
                                             styles: staticLinkModel.styles,
                                             children: transformChildren(staticLinkModel.children, slot: slot)))
        case .closeButton(let closeButtonModel):
            return .closeButton(getCloseButton(styles: closeButtonModel.styles,
                                               children: transformChildren(closeButtonModel.children, slot: slot)))
        }
    }
    
    func transform(_ layout: OuterLayoutSchemaModel, slot: SlotModel? = nil) -> LayoutSchemaUIModel {
        switch layout {
        case .row(let rowModel):
            return .row(getRow(rowModel.styles, children: transformChildren(rowModel.children, slot: slot)))
        case .column(let columnModel):
            return .column(getColumn(columnModel.styles,children: transformChildren(columnModel.children, slot: slot)))
        case .basicText(let basicTextModel): return .basicText(getBasicText(basicTextModel))
        case .staticImage(let imageModel): return .staticImage(getStaticImage(imageModel))
        case .richText(let richTextModel):
            return .richText(getRichText(richTextModel))
        case .progressIndicator(let progressIndicatorModel):
            return .progressIndicator(getProgressIndicatorUIModel(progressIndicatorModel))
        case .oneByOneDistribution(let oneByOneModel):
            return .oneByOne(getOneByOne(oneByOneModel: oneByOneModel))
        case .overlay(let overlayModel):
            return .overlay(getOverlay(overlayModel.styles, settings: overlayModel.settings,
                                       children: transformChildren(overlayModel.children, slot: slot)))
        case .bottomSheet(let bottomSheetModel):
            return .bottomSheet(getBottomSheet(bottomSheetModel.styles, settings: bottomSheetModel.settings,
                                               children: transformChildren(bottomSheetModel.children, slot: slot)))
        case .when(let whenModel):
            return .when(getWhenNode(children: transformChildren(whenModel.children, slot: slot),
                                     predicates: whenModel.predicates))
        case .staticLink(let staticLinkModel):
            return .staticLink(getStaticLink(src: staticLinkModel.src,
                                             open: staticLinkModel.open,
                                             styles: staticLinkModel.styles,
                                             children: transformChildren(staticLinkModel.children, slot: slot)))
        case .closeButton(let closeButtonModel):
            return .closeButton(getCloseButton(styles: closeButtonModel.styles,
                                               children: transformChildren(closeButtonModel.children, slot: slot)))
        case .carouselDistribution(let carouselModel):
            return .carousel(getCarousel(carouselModel: carouselModel))
        }
    }
          
    func transform(_ layout: OuterLayoutChildren, slot: SlotModel? = nil) -> LayoutSchemaUIModel {
        switch layout {
        case .row(let rowModel):
            return .row(getRow(rowModel.styles, children: transformChildren(rowModel.children, slot: slot)))
        case .column(let columnModel):
            return .column(getColumn(columnModel.styles,children: transformChildren(columnModel.children, slot: slot)))
        case .basicText(let basicTextModel): return .basicText(getBasicText(basicTextModel))
        case .staticImage(let imageModel): return .staticImage(getStaticImage(imageModel))
        case .richText(let richTextModel):
            return .richText(getRichText(richTextModel))
            
        case .progressIndicator(let progressIndicatorModel):
            return .progressIndicator(getProgressIndicatorUIModel(progressIndicatorModel))
        case .oneByOneDistribution(let oneByOneModel):
            return .oneByOne(getOneByOne(oneByOneModel: oneByOneModel))
        case .when(let whenModel):
            return .when(getWhenNode(children: transformChildren(whenModel.children, slot: slot),
                                     predicates: whenModel.predicates))
        case .staticLink(let staticLinkModel):
            return .staticLink(getStaticLink(src: staticLinkModel.src,
                                             open: staticLinkModel.open,
                                             styles: staticLinkModel.styles,
                                             children: transformChildren(staticLinkModel.children, slot: slot)))
        case .closeButton(let closeButtonModel):
            return .closeButton(getCloseButton(styles: closeButtonModel.styles,
                                               children: transformChildren(closeButtonModel.children, slot: slot)))
        case .carouselDistribution(let carouselModel):
            return .carousel(getCarousel(carouselModel: carouselModel))
        }
    }
    
    func transform(_ layout: CreativeResponseChildren, slot: SlotModel? = nil) -> LayoutSchemaUIModel {
        switch layout {
        case .row(let rowModel):
            return .row(getRow(rowModel.styles, children: transformChildren(rowModel.children, slot: slot)))
        case .column(let columnModel):
            return .column(getColumn(columnModel.styles,children: transformChildren(columnModel.children, slot: slot)))
        case .basicText(let basicTextModel): return .basicText(getBasicText(basicTextModel))
        case .staticImage(let imageModel): return .staticImage(getStaticImage(imageModel))
        case .dataImage(let imageModel): return .dataImage(getDataImage(imageModel, slot: slot))
        case .when(let whenModel):
            return .when(getWhenNode(children: transformChildren(whenModel.children, slot: slot),
                                     predicates: whenModel.predicates))
        }
    }
            
    func transform(_ layout: OverlayChildren, slot: SlotModel? = nil) -> LayoutSchemaUIModel {
        switch layout {
        case .row(let rowModel):
            return .row(getRow(rowModel.styles, children: transformChildren(rowModel.children, slot: slot)))
        case .column(let columnModel):
            return .column(getColumn(columnModel.styles,children: transformChildren(columnModel.children, slot: slot)))
        case .basicText(let basicTextModel): return .basicText(getBasicText(basicTextModel))
        case .staticImage(let imageModel): return .staticImage(getStaticImage(imageModel))
        case .richText(let richTextModel):
            return .richText(getRichText(richTextModel))
        case .progressIndicator(let progressIndicatorModel):
            return .progressIndicator(getProgressIndicatorUIModel(progressIndicatorModel))
        case .oneByOneDistribution(let oneByOneModel):
            return .oneByOne(getOneByOne(oneByOneModel: oneByOneModel))
        case .when(let whenModel):
            return .when(getWhenNode(children: transformChildren(whenModel.children, slot: slot),
                                     predicates: whenModel.predicates))
        case .staticLink(let staticLinkModel):
            return .staticLink(getStaticLink(src: staticLinkModel.src,
                                             open: staticLinkModel.open,
                                             styles: staticLinkModel.styles,
                                             children: transformChildren(staticLinkModel.children, slot: slot)))
        case .closeButton(let closeButtonModel):
            return .closeButton(getCloseButton(styles: closeButtonModel.styles,
                                               children: transformChildren(closeButtonModel.children, slot: slot)))
        case .carouselDistribution(let carouselModel):
            return .carousel(getCarousel(carouselModel: carouselModel))
        }
    }
    func transform(_ layout: BottomSheetChildren, slot: SlotModel? = nil) -> LayoutSchemaUIModel {
        switch layout {
        case .row(let rowModel):
            return .row(getRow(rowModel.styles, children: transformChildren(rowModel.children, slot: slot)))
        case .column(let columnModel):
            return .column(getColumn(columnModel.styles,children: transformChildren(columnModel.children, slot: slot)))
        case .basicText(let basicTextModel): return .basicText(getBasicText(basicTextModel))
        case .staticImage(let imageModel): return .staticImage(getStaticImage(imageModel))
        case .richText(let richTextModel):
            return .richText(getRichText(richTextModel))
        case .progressIndicator(let progressIndicatorModel):
            return .progressIndicator(getProgressIndicatorUIModel(progressIndicatorModel))
        case .oneByOneDistribution(let oneByOneModel):
            return .oneByOne(getOneByOne(oneByOneModel: oneByOneModel))
        case .when(let whenModel):
            return .when(getWhenNode(children: transformChildren(whenModel.children, slot: slot),
                                     predicates: whenModel.predicates))
        case .staticLink(let staticLinkModel):
            return .staticLink(getStaticLink(src: staticLinkModel.src,
                                             open: staticLinkModel.open,
                                             styles: staticLinkModel.styles,
                                             children: transformChildren(staticLinkModel.children, slot: slot)))
        case .closeButton(let closeButtonModel):
            return .closeButton(getCloseButton(styles: closeButtonModel.styles,
                                               children: transformChildren(closeButtonModel.children, slot: slot)))
        case .carouselDistribution(let carouselModel):
            return .carousel(getCarousel(carouselModel: carouselModel))
        }
    }
    
    func transform(_ layout: StaticLinkChildren, slot: SlotModel? = nil) -> LayoutSchemaUIModel {
        switch layout {
        case .row(let rowModel):
            return .row(getRow(rowModel.styles, children: transformChildren(rowModel.children, slot: slot)))
        case .column(let columnModel):
            return .column(getColumn(columnModel.styles,children: transformChildren(columnModel.children, slot: slot)))
        case .basicText(let basicTextModel): return .basicText(getBasicText(basicTextModel))
        case .staticImage(let imageModel): return .staticImage(getStaticImage(imageModel))
        }
    }
    
    func transform(_ layout: CloseButtonChildren, slot: SlotModel? = nil) -> LayoutSchemaUIModel {
        switch layout {
        case .row(let rowModel):
            return .row(getRow(rowModel.styles, children: transformChildren(rowModel.children, slot: slot)))
        case .column(let columnModel):
            return .column(getColumn(columnModel.styles,children: transformChildren(columnModel.children, slot: slot)))
        case .basicText(let basicTextModel): return .basicText(getBasicText(basicTextModel))
        case .staticImage(let imageModel): return .staticImage(getStaticImage(imageModel))
        }
    }
        
    func transformChildren<T: Codable>(_ layouts: [T]?, slot: SlotModel?) -> [LayoutSchemaUIModel]? {
        guard let layouts else { return nil }

        var children: [LayoutSchemaUIModel] = []

        layouts.forEach { layout in
            children.append(transform(layout, slot: slot))
        }

        return children
    }
    
    // attach inner layout into outer layout and transform to UI Model
    func getOneByOne(oneByOneModel: OneByOneDistributionModel) -> OneByOneUIModel {
        var children: [LayoutSchemaUIModel] = []

        layoutPlugin.slots.forEach { slot in
            if let innerLayout = slot.layoutVariant?.layoutVariantSchema {
                children.append(transform(innerLayout, slot: slot))
            }
        }

        return OneByOneUIModel(children: children,
                               defaultStyle: oneByOneModel.styles?.elements.own.first?.default,
                               transition: oneByOneModel.transition)
    }
    
    func getCarousel(carouselModel: CarouselDistributionModel) -> CarouselUIModel {
        var children: [LayoutSchemaUIModel] = []

        layoutPlugin.slots.forEach { slot in
            if let innerLayout = slot.layoutVariant?.layoutVariantSchema {
                children.append(transform(innerLayout, slot: slot))
            }
        }

        return CarouselUIModel(children: children,
                               defaultStyle: carouselModel.styles?.elements.own.first?.default,
                               viewableItems: carouselModel.settings.viewableItems,
                               peekThroughSize: carouselModel.settings.peekThroughSize
        )
    }
    
    //MARK: Component Models
    func getStaticImage(_ imageModel: StaticImageModel) -> StaticImageUIModel {
        return StaticImageUIModel(url: imageModel.url,
                                  alt: imageModel.alt,
                                  defaultStyle: imageModel.styles?.elements.own.first?.default,
                                  pressedStyle: imageModel.styles?.elements.own.first?.pressed,
                                  hoveredStyle: imageModel.styles?.elements.own.first?.hovered,
                                  disabledStyle: imageModel.styles?.elements.own.first?.disabled)
    }
    
    func getStaticLink(src: String,
                       open: LinkOpenTarget,
                       styles: LayoutStyle<StaticLinkElements>?,
                       children: [LayoutSchemaUIModel]?) -> StaticLinkUIModel {
        return StaticLinkUIModel(children: children,
                                 src: src,
                                 open: open,
                                 defaultStyle: styles?.elements.own.first?.default,
                                 pressedStyle: styles?.elements.own.first?.pressed,
                                 hoveredStyle: styles?.elements.own.first?.hovered,
                                 disabledStyle: styles?.elements.own.first?.disabled)
    }
    
    func getCloseButton(styles: LayoutStyle<CloseButtonElements>?,
                       children: [LayoutSchemaUIModel]?) -> CloseButtonUIModel {
        return CloseButtonUIModel(children: children,
                                 defaultStyle: styles?.elements.own.first?.default,
                                 pressedStyle: styles?.elements.own.first?.pressed,
                                 hoveredStyle: styles?.elements.own.first?.hovered,
                                 disabledStyle: styles?.elements.own.first?.disabled)
    }
        
    func getDataImage(_ imageModel: DataImageModel, slot: SlotModel?) -> DataImageUIModel {
        let creativeImage = slot?.offer?.creative.images?[imageModel.imageKey]
        return DataImageUIModel(image: creativeImage,
                                defaultStyle: imageModel.styles?.elements.own.first?.default,
                                pressedStyle: imageModel.styles?.elements.own.first?.pressed,
                                hoveredStyle: imageModel.styles?.elements.own.first?.hovered,
                                disabledStyle: imageModel.styles?.elements.own.first?.disabled)
    }
    
    func getBasicText(_ basicTextModel: BasicTextModel) -> BasicTextUIModel {
        return BasicTextUIModel(value: basicTextModel.value,
                                defaultStyle: basicTextModel.styles?.elements.own.first?.default,
                                pressedStyle: basicTextModel.styles?.elements.own.first?.pressed,
                                hoveredStyle: basicTextModel.styles?.elements.own.first?.hovered,
                                disabledStyle: basicTextModel.styles?.elements.own.first?.disabled)
    }
    
    func getRichText(_ richTextModel: RichTextModel) -> RichTextUIModel {
        return RichTextUIModel(value: richTextModel.value,
                               defaultStyle: richTextModel.styles?.elements.own.first?.default,
                               linkStyle: richTextModel.styles?.elements.link?.first?.default,
                               openLinks: richTextModel.openLinks)
    }
    
    func getColumn(_ styles: LayoutStyle<ColumnElements>?, children: [LayoutSchemaUIModel]?) -> ColumnUIModel {
        return ColumnUIModel(children: children,
                             defaultStyle: styles?.elements.own.first?.default,
                             pressedStyle: styles?.elements.own.first?.pressed,
                             hoveredStyle: styles?.elements.own.first?.hovered,
                             disabledStyle: styles?.elements.own.first?.disabled)
    }
    
    func getRow(_ styles: LayoutStyle<RowElements>?, children: [LayoutSchemaUIModel]?) -> RowUIModel {
        return RowUIModel(children: children,
                          defaultStyle: styles?.elements.own.first?.default,
                          pressedStyle: styles?.elements.own.first?.pressed,
                          hoveredStyle: styles?.elements.own.first?.hovered,
                          disabledStyle: styles?.elements.own.first?.disabled)
    }
    
    func getOverlay(_ styles: LayoutStyle<OverlayElements>?,
                    settings: OverlaySettings?,
                    children: [LayoutSchemaUIModel]?) -> OverlayUIModel {
        return OverlayUIModel(children:children,
                              settings: settings,
                              defaultStyle: styles?.elements.own.first?.default,
                              wrapperStyle: styles?.elements.wrapper.first?.default)
    }
    func getBottomSheet(_ styles: LayoutStyle<BottomSheetElements>?,
                    settings: BottomSheetSettings?,
                    children: [LayoutSchemaUIModel]?) -> BottomSheetUIModel {
        return BottomSheetUIModel(children:children,
                              settings: settings,
                              defaultStyle: styles?.elements.own.first?.default)
    }
    
    
    func getCreativeResponse(responseKey: String,
                             openLinks: LinkOpenTarget?,
                             styles: LayoutStyle<CreativeResponseElements>?,
                             children: [LayoutSchemaUIModel]?,
                             slot: SlotModel?) -> LayoutSchemaUIModel {
        guard let responseOptionsMap = slot?.offer?.creative.responseOptionsMap,
              (responseKey == BNFNamespace.CreativeResponseKey.positive.rawValue
               && responseOptionsMap.positive != nil)
                ||
                (responseKey == BNFNamespace.CreativeResponseKey.negative.rawValue
                 && responseOptionsMap.negative != nil)
        else {
            return .empty
        }

        return .creativeResponse(getCreativeResponseUIModel(responseKey: responseKey,
                                                            openLinks: openLinks,
                                                            styles: styles,
                                                            children: children,
                                                            slot: slot))
    }
    
    func getCreativeResponseUIModel(responseKey: String,
                             openLinks: LinkOpenTarget?,
                             styles: LayoutStyle<CreativeResponseElements>?,
                             children: [LayoutSchemaUIModel]?,
                             slot: SlotModel?) -> CreativeResponseUIModel {
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

        return CreativeResponseUIModel(children: children,
                                       responseKey: creativeResponseKey,
                                       responseOptions: responseOption,
                                       openLinks: openLinks,
                                       defaultStyle: styles?.elements.own.first?.default,
                                       pressedStyle: styles?.elements.own.first?.pressed,
                                       hoveredStyle: styles?.elements.own.first?.hovered,
                                       disabledStyle: styles?.elements.own.first?.disabled)
    }

    func getProgressIndicator(_ progressIndicatorModel: ProgressIndicatorModel) -> LayoutSchemaUIModel {
        let indicatorData = extractor.extractDataRepresentedBy(
            String.self,
            propertyChain: progressIndicatorModel.indicator,
            responseKey: nil,
            from: nil
        )

        guard case .state(let stateValue) = indicatorData,
              DataBindingStateKeys.isValidKey(stateValue)
        else { return .empty }

        return .progressIndicator(getProgressIndicatorUIModel(progressIndicatorModel))
    }
    
    func getProgressIndicatorUIModel(_ progressIndicatorModel: ProgressIndicatorModel) -> ProgressIndicatorUIModel {
        ProgressIndicatorUIModel(
            indicator: progressIndicatorModel.indicator,
            defaultStyle: progressIndicatorModel.styles?.elements.own.first?.default,
            indicatorStyle: progressIndicatorModel.styles?.elements.indicator.first?.default,
            activeIndicatorStyle: progressIndicatorModel.styles?.elements.activeIndicator?.first?.default,
            seenIndicatorStyle: progressIndicatorModel.styles?.elements.seenIndicator?.first?.default,
            settings: progressIndicatorModel.settings
        )
    }
    
    func getWhenNode(children: [LayoutSchemaUIModel]?,
                     predicates: [WhenPredicate]) -> WhenUIModel {
        return WhenUIModel(children: children,
                           predicates: predicates)
    }
}
