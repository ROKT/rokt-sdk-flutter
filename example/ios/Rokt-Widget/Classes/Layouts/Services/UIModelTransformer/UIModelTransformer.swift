////
////  UIModelTransformer.swift
////  Rokt-Widget
////
////  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
////  Version 2.0 (the "License");
////
////  You may not use this file except in compliance with the License.
////
////  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/
//
//import Foundation
//
//@available(iOS 15, *)
//struct UIModelTransformer {
//    static func transform(_ layout: LayoutSchemaModel) -> LayoutSchemaUIModel {
//        switch layout {
//        case .overlay(let overlayModel):
//            return .overlay(OverlayUIModel(children: transformChildren(overlayModel.children),
//                                           settings: overlayModel.node?.settings,
//                                           defaultStyle: overlayModel.node?.styles?.overlayDefaultStyle))
//            
//        case .bottomSheet(let bottomSheetModel):
//            return .bottomSheet(BottomSheetUIModel(children: transformChildren(bottomSheetModel.children),
//                                                   settings: bottomSheetModel.node?.settings,
//                                                   defaultStyle: bottomSheetModel.node?.styles?.bottomSheetDefaultStyle))
//            
//        case .row(let rowModel):
//            return .row(RowUIModel(children: transformChildren(rowModel.children),
//                                   defaultStyle: rowModel.node?.styles?.selfDefaultStyle,
//                                   pressedStyle: rowModel.node?.styles?.selfPressedStyle,
//                                   hoveredStyle: rowModel.node?.styles?.selfHoveredStyle,
//                                   disabledStyle: rowModel.node?.styles?.selfDisabledStyle))
//            
//        case .column(let columnModel):
//            return .column(ColumnUIModel(children: transformChildren(columnModel.children),
//                                         defaultStyle: columnModel.node?.styles?.selfDefaultStyle,
//                                         pressedStyle: columnModel.node?.styles?.selfPressedStyle,
//                                         hoveredStyle: columnModel.node?.styles?.selfHoveredStyle,
//                                         disabledStyle: columnModel.node?.styles?.selfDisabledStyle))
//            
//        case .when(let whenModel):
//            return .when(WhenUIModel(children: transformChildren(whenModel.children),
//                                     predicates: whenModel.predicates))
//        case .oneByOne(let oneByOneModel):
//            return .oneByOne(OneByOneUIModel(children: transformChildren(oneByOneModel.children)))
//        case .richText(let richTextModel):
//            return .richText(RichTextUIModel(value: richTextModel.node?.value,
//                                             defaultStyle: richTextModel.node?.styles?.textDefaultStyle))
//        case .basicText(let basicTextModel):
//            return .basicText(BasicTextUIModel(value: basicTextModel.node?.value,
//                                               defaultStyle: basicTextModel.node?.styles?.textDefaultStyle,
//                                               pressedStyle: basicTextModel.node?.styles?.textPressedStyle,
//                                               hoveredStyle: basicTextModel.node?.styles?.textHoveredStyle,
//                                               disabledStyle: basicTextModel.node?.styles?.textDisabledStyle))
//        case .creativeResponse(let creativeResponseModel):
//            return .creativeResponse(
//                CreativeResponseUIModel(children: transformChildren(creativeResponseModel.children),
//                                        defaultStyle: creativeResponseModel.node?.styles?.selfDefaultStyle,
//                                        pressedStyle: creativeResponseModel.node?.styles?.selfPressedStyle,
//                                        hoveredStyle: creativeResponseModel.node?.styles?.selfHoveredStyle,
//                                        disabledStyle: creativeResponseModel.node?.styles?.selfDisabledStyle))
//        case .closeButton(let closeButtonModel):
//            return .closeButton(
//                CloseButtonUIModel(children: transformChildren(closeButtonModel.children),
//                                   defaultStyle: closeButtonModel.node?.styles?.selfDefaultStyle,
//                                   pressedStyle: closeButtonModel.node?.styles?.selfPressedStyle,
//                                   hoveredStyle: closeButtonModel.node?.styles?.selfHoveredStyle,
//                                   disabledStyle: closeButtonModel.node?.styles?.selfDisabledStyle))
//        case .image(let imageModel):
//            return .image(ImageUIModel(url: imageModel.node?.url,
//                                       defaultStyle: imageModel.node?.styles?.imageDefaultStyle,
//                                       pressedStyle: imageModel.node?.styles?.imagePressedStyle,
//                                       hoveredStyle: imageModel.node?.styles?.imageHoveredStyle,
//                                       disabledStyle: imageModel.node?.styles?.imageDisabledStyle))
//        case .progressIndicator(let progressIndicatorModel):
//            return .progressIndicator(ProgressIndicatorUIModel(indicator: progressIndicatorModel.node.indicator,
//                                                                  defaultStyle: progressIndicatorModel.node.styles?.selfDefaultStyle,
//                                                                  indicatorStyle: progressIndicatorModel.node.styles?.indicatorDefaultStyle,
//                                                                  activeIndicatorStyle: progressIndicatorModel.node.styles?.activeIndicatorDefaultStyle))
//        }
//    }
//    
//    static func transformChildren(_ layouts: [LayoutSchemaModel]?) -> [LayoutSchemaUIModel]? {
//        guard let layouts else {return nil}
//        var children: [LayoutSchemaUIModel] = []
//        layouts.forEach{ layout in
//            children.append(transform(layout))
//        }
//        return children
//    }
//    
//}
