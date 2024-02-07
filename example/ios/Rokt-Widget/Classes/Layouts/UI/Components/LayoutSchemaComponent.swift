//
//  LayoutSchemaComponent.swift
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
struct LayoutSchemaComponent: View {
    let parent: ComponentParent
    let layout: LayoutSchemaUIModel
    let baseDI: BaseDependencyInjection
    
    @Binding var parentWidth: CGFloat?
    @Binding var parentHeight: CGFloat?
    @Binding var styleState: StyleState

    private(set) var parentVerticalAlignment: VerticalAlignment?
    private(set) var parentHorizontalAlignment: HorizontalAlignment?

    // to be used by `Shadow`
    private(set) var parentBackgroundStyle: BackgroundStylingProperties?

    let expandsToContainerOnSelfAlign: Bool

    init(
        parent: ComponentParent,
        layout: LayoutSchemaUIModel,
        baseDI: BaseDependencyInjection,
        parentWidth: Binding<CGFloat?>,
        parentHeight: Binding<CGFloat?>,
        styleState: Binding<StyleState>,
        parentVerticalAlignment: VerticalAlignment? = nil,
        parentHorizontalAlignment: HorizontalAlignment? = nil,
        parentBackgroundStyle: BackgroundStylingProperties? = nil,
        expandsToContainerOnSelfAlign: Bool = false
    ) {
        self.parent = parent
        self.layout = layout
        self.baseDI = baseDI
        self._parentWidth = parentWidth
        self._parentHeight = parentHeight
        self._styleState = styleState
        self.parentVerticalAlignment = parentVerticalAlignment
        self.parentHorizontalAlignment = parentHorizontalAlignment
        self.parentBackgroundStyle = parentBackgroundStyle
        self.expandsToContainerOnSelfAlign = expandsToContainerOnSelfAlign
    }
    
    var body: some View {
        switch(layout) {
        case .richText(let textModel):
            RichTextComponent(parent: parent,
                              model: textModel,
                              baseDI: baseDI,
                              parentWidth: $parentWidth,
                              parentHeight: $parentHeight,
                              parentVerticalAlignment: parentVerticalAlignment,
                              parentHorizontalAlignment: parentHorizontalAlignment,
                              borderStyle: nil)
        case .basicText(let basicTextModel):
            BasicTextComponent(parent: parent,
                               model: basicTextModel,
                               baseDI: baseDI,
                               parentWidth: $parentWidth,
                               parentHeight: $parentHeight,
                               styleState: $styleState,
                               parentVerticalAlignment: parentVerticalAlignment,
                               parentHorizontalAlignment: parentHorizontalAlignment,
                               expandsToContainerOnSelfAlign: expandsToContainerOnSelfAlign)
        case .column(let columnModel):
            ColumnComponent(parent: parent,
                            model: columnModel,
                            baseDI: baseDI,
                            parentWidth: $parentWidth,
                            parentHeight: $parentHeight,
                            styleState: $styleState,
                            parentVerticalAlignment: parentVerticalAlignment,
                            parentHorizontalAlignment: parentHorizontalAlignment,
                            parentBackgroundStyle: parentBackgroundStyle)
        case .row(let rowModel):
            RowComponent(parent: parent,
                         model: rowModel,
                         baseDI: baseDI,
                         parentWidth: $parentWidth,
                         parentHeight: $parentHeight,
                         styleState: $styleState,
                         parentVerticalAlignment: parentVerticalAlignment,
                         parentHorizontalAlignment: parentHorizontalAlignment,
                         parentBackgroundStyle: parentBackgroundStyle)
        case .creativeResponse(let creativeResponseModel):
            CreativeResponseComponent(parent: parent,
                                      model: creativeResponseModel,
                                      baseDI: baseDI,
                                      parentWidth: $parentWidth,
                                      parentHeight: $parentHeight,
                                      parentVerticalAlignment: parentVerticalAlignment,
                                      parentHorizontalAlignment: parentHorizontalAlignment,
                                      parentBackgroundStyle: parentBackgroundStyle)
        case .staticImage(let imageModel):
            StaticImageViewComponent(parent: parent,
                               model: imageModel,
                               parentWidth: $parentWidth,
                               parentHeight: $parentHeight,
                               styleState: $styleState,
                               parentVerticalAlignment: parentVerticalAlignment,
                               parentHorizontalAlignment: parentHorizontalAlignment,
                                     expandsToContainerOnSelfAlign: expandsToContainerOnSelfAlign)
        case .dataImage(let imageModel):
            DataImageViewComponent(parent: parent,
                               model: imageModel,
                               parentWidth: $parentWidth,
                               parentHeight: $parentHeight,
                               styleState: $styleState,
                               parentVerticalAlignment: parentVerticalAlignment,
                               parentHorizontalAlignment: parentHorizontalAlignment,
                                   expandsToContainerOnSelfAlign: expandsToContainerOnSelfAlign)
        case .progressIndicator(let progressIndicatorModel):
            ProgressIndicatorComponent(parent: parent,
                                       model: progressIndicatorModel,
                                       baseDI: baseDI,
                                       parentWidth: $parentWidth,
                                       parentHeight: $parentHeight,
                                       parentVerticalAlignment: parentVerticalAlignment,
                                       parentHorizontalAlignment: parentHorizontalAlignment,
                                       parentBackgroundStyle: parentBackgroundStyle)
        case .oneByOne(let oneByOneModel):
            OneByOneComponent(parent: parent,
                              model: oneByOneModel,
                              baseDI: baseDI,
                              parentWidth: $parentWidth,
                              parentHeight: $parentHeight,
                              styleState: $styleState,
                              parentVerticalAlignment: parentVerticalAlignment,
                              parentHorizontalAlignment: parentHorizontalAlignment,
                              parentBackgroundStyle: parentBackgroundStyle)
        case .carousel(let carouselModel):
            CarouselComponent(parent: parent,
                              model: carouselModel,
                              baseDI: baseDI,
                              parentWidth: $parentWidth,
                              parentHeight: $parentHeight,
                              styleState: $styleState,
                              parentVerticalAlignment: parentVerticalAlignment,
                              parentHorizontalAlignment: parentHorizontalAlignment,
                              parentBackgroundStyle: parentBackgroundStyle)
        case .when(let whenModel):
            WhenComponent(parent: parent,
                          model: whenModel,
                          baseDI: baseDI,
                          parentWidth: $parentWidth,
                          parentHeight: $parentHeight,
                          styleState: $styleState,
                          parentVerticalAlignment: parentVerticalAlignment,
                          parentHorizontalAlignment: parentHorizontalAlignment)
        case .closeButton(let closeButtonModel):
            CloseButtonComponent(parent: parent,
                                 model: closeButtonModel,
                                 baseDI: baseDI,
                                 parentWidth: $parentWidth,
                                 parentHeight: $parentHeight,
                                 parentVerticalAlignment: parentVerticalAlignment,
                                 parentHorizontalAlignment: parentHorizontalAlignment,
                                 parentBackgroundStyle: parentBackgroundStyle)
        case .staticLink(let staticLinkModel):
            StaticLinkComponent(parent: parent,
                                model: staticLinkModel,
                                baseDI: baseDI,
                                parentWidth: $parentWidth,
                                parentHeight: $parentHeight,
                                parentVerticalAlignment: parentVerticalAlignment,
                                parentHorizontalAlignment: parentHorizontalAlignment)
        default:
            // if LayoutSchemaUIModel = .empty
            EmptyView()
        }
    }
}

enum ComponentParent {
    case root
    case column
    case row
}
