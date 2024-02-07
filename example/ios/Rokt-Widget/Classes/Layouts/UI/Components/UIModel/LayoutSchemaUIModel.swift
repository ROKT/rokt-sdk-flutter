//
//  LayoutSchemaUIModel.swift
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
enum LayoutSchemaUIModel: Hashable {
    // top-level
    case overlay(OverlayUIModel)
    case bottomSheet(BottomSheetUIModel)
 
    case row(RowUIModel)
    case column(ColumnUIModel)
    case when(WhenUIModel)
    case oneByOne(OneByOneUIModel)
    case carousel(CarouselUIModel)

    case richText(RichTextUIModel)
    case basicText(BasicTextUIModel)
    case creativeResponse(CreativeResponseUIModel)
    case staticImage(StaticImageUIModel)
    case dataImage(DataImageUIModel)
    case progressIndicator(ProgressIndicatorUIModel)
    case closeButton(CloseButtonUIModel)
    case staticLink(StaticLinkUIModel)
    case empty
    
    static func == (lhs: LayoutSchemaUIModel, rhs: LayoutSchemaUIModel) -> Bool {
        switch(lhs, rhs){
        case (.richText(let lhsModel), .richText( let rhsModel)):
            return lhsModel == rhsModel
        case (.basicText(let lhsModel), .basicText( let rhsModel)):
            return lhsModel == rhsModel
        case (.column(let lhsModel), .column( let rhsModel)):
            return lhsModel == rhsModel
        case (.row(let lhsModel), .row( let rhsModel)):
            return lhsModel == rhsModel
        case (.creativeResponse(let lhsModel), .creativeResponse( let rhsModel)):
            return lhsModel == rhsModel
        case (.staticImage(let lhsModel), .staticImage( let rhsModel)):
            return lhsModel == rhsModel
        case (.dataImage(let lhsModel), .dataImage( let rhsModel)):
            return lhsModel == rhsModel
        case (.progressIndicator(let lhsModel), .progressIndicator( let rhsModel)):
            return lhsModel == rhsModel
        case (.oneByOne(let lhsModel), .oneByOne( let rhsModel)):
            return lhsModel == rhsModel
        case (.carousel(let lhsModel), .carousel( let rhsModel)):
            return lhsModel == rhsModel
        case (.when(let lhsModel), .when( let rhsModel)):
            return lhsModel == rhsModel
        case (.closeButton(let lhsModel), .closeButton( let rhsModel)):
            return lhsModel == rhsModel
        case (.staticLink(let lhsModel), .staticLink( let rhsModel)):
            return lhsModel == rhsModel
        case (.empty, .empty):
            return true
        default:
            return false
        }
    }
}
