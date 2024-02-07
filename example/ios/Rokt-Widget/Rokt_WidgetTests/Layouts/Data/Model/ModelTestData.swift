//
//  ModelTestData.swift
//  Rokt-Widget
//
//  Copyright 2020 Rokt Pte Ltd
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/
import Foundation

class ModelTestData: NSObject {
    enum TextData {
        static func uppercase() -> RichTextModel {
            let data = toData(jsonFilename: "node_text_uppercase")
            return try! JSONDecoder().decode(RichTextModel.self, from: data)
        }

        static func lowercase() -> RichTextModel {
            let data = toData(jsonFilename: "node_text_lowercase")
            return try! JSONDecoder().decode(RichTextModel.self, from: data)
        }

        static func capitalize() -> RichTextModel {
            let data = toData(jsonFilename: "node_text_capitalize")
            return try! JSONDecoder().decode(RichTextModel.self, from: data)
        }

        static func none() -> RichTextModel {
            let data = toData(jsonFilename: "node_text_none")
            return try! JSONDecoder().decode(RichTextModel.self, from: data)
        }

        static func noValue() -> RichTextModel {
            let data = toData(jsonFilename: "node_text_no_value")
            return try! JSONDecoder().decode(RichTextModel.self, from: data)
        }

        static func superscriptTransform() -> RichTextModel {
            let data = toData(jsonFilename: "node_text_superscript")
            return try! JSONDecoder().decode(RichTextModel.self, from: data)
        }

        static func subscriptTransform() -> RichTextModel {
            let data = toData(jsonFilename: "node_text_subscript")
            return try! JSONDecoder().decode(RichTextModel.self, from: data)
        }
        
        static func basicText() -> BasicTextModel {
            let data = toData(jsonFilename: "node_text_none")
            return try! JSONDecoder().decode(BasicTextModel.self, from: data)
        }

        static func richTextHTML() -> RichTextModel {
            let data = toData(jsonFilename: "node_richtext_html")
            return try! JSONDecoder().decode(RichTextModel.self, from: data)
        }
    }
    
    enum CreativeResponseData {
        static func positive() -> CreativeResponseModel<CreativeResponseChildren>? {
            let data = toData(jsonFilename: "node_creative_response_positive")
            let layout = try! JSONDecoder().decode(LayoutVariantSchemaModel.self, from: data)
            guard case .creativeResponse(let model) = layout else { return nil }
            return model
        }
        
        static func negative() -> CreativeResponseModel<CreativeResponseChildren>? {
            let data = toData(jsonFilename: "node_creative_response_negative")
            let layout = try! JSONDecoder().decode(LayoutVariantSchemaModel.self, from: data)
            guard case .creativeResponse(let model) = layout else { return nil }
            return model
        }
                
        static func neutral() -> CreativeResponseModel<CreativeResponseChildren>? {
            let data = toData(jsonFilename: "node_creative_response_neutral")
            let layout = try! JSONDecoder().decode(LayoutVariantSchemaModel.self, from: data)
            guard case .creativeResponse(let model) = layout else { return nil }
            return model
        }
    }
    
    enum CloseButtonData {
        static func closeButton() -> CloseButtonModel<CloseButtonChildren> {
            let data = toData(jsonFilename: "node_close_button")
            return try! JSONDecoder().decode(CloseButtonModel<CloseButtonChildren>.self, from: data)
        }
    }
    
    enum RowData {
        static func rowWithBasicText() -> RowModel<CreativeResponseChildren> {
            let data = toData(jsonFilename: "node_row_with_basic_text")
            return try! JSONDecoder().decode(RowModel<CreativeResponseChildren>.self, from: data)
        }
    }
    enum ColumnData {
        static func columnWithBasicText() -> ColumnModel<CreativeResponseChildren> {
            let data = toData(jsonFilename: "node_column_with_basic_text")
            return try! JSONDecoder().decode(ColumnModel<CreativeResponseChildren>.self, from: data)
        }
        static func columnWithOverflow() -> ColumnModel<CreativeResponseChildren> {
            let data = toData(jsonFilename: "node_column_with_overflow_scroll")
            return try! JSONDecoder().decode(ColumnModel<CreativeResponseChildren>.self, from: data)
        }
    }
    
    enum OneByOneData {
        static func oneByOne() -> OneByOneDistributionModel? {
            let data = toData(jsonFilename: "node_onebyone")
            let layout = try! JSONDecoder().decode(LayoutSchemaModel.self, from: data)
            if case .oneByOneDistribution(let model) = layout {
                return model
            }
            return nil
        }
    }
    
    enum CarouselData {
        static func carousel() -> CarouselDistributionModel? {
            let data = toData(jsonFilename: "node_carousel")
            let layout = try! JSONDecoder().decode(LayoutSchemaModel.self, from: data)
            if case .carouselDistribution(let model) = layout {
                return model
            }
            return nil
        }
    }
    
    enum StaticLinkData {
        static func staticLink() -> StaticLinkModel<StaticLinkChildren> {
            let data = toData(jsonFilename: "node_static_link")
            return try! JSONDecoder().decode(StaticLinkModel<StaticLinkChildren>.self, from: data)
        }
    }
    
    enum DataImageData {
        static func dataImage() -> DataImageModel {
            let data = toData(jsonFilename: "node_data_image")
            return try! JSONDecoder().decode(DataImageModel.self, from: data)
        }
    }
    
    enum StaticImageData {
        static func staticImage() -> StaticImageModel {
            let data = toData(jsonFilename: "node_static_image")
            return try! JSONDecoder().decode(StaticImageModel.self, from: data)
        }
    }
    
    enum ProgressIndicatorData {
        static func progressIndicator() -> ProgressIndicatorModel {
            let data = toData(jsonFilename: "node_progress_indicator")
            return try! JSONDecoder().decode(ProgressIndicatorModel.self, from: data)
        }

        static func invalidDataExpansion() -> ProgressIndicatorModel {
            let data = toData(jsonFilename: "node_invalid_expansion_progress_indicator")
            return try! JSONDecoder().decode(ProgressIndicatorModel.self, from: data)
        }

        static func chainOfvaluesDataExpansion() -> ProgressIndicatorModel {
            let data = toData(jsonFilename: "node_data_expansion_chain")
            return try! JSONDecoder().decode(ProgressIndicatorModel.self, from: data)
        }
        
        static func startPosition() -> ProgressIndicatorModel {
            let data = toData(jsonFilename: "node_start_position_progress_indicator")
            return try! JSONDecoder().decode(ProgressIndicatorModel.self, from: data)
        }
    }

    enum OverlayData {
        static func singleTextOverlay() -> OverlayModel<RichTextModel> {
            let data = toData(jsonFilename: "overlay_test")
            return try! JSONDecoder().decode(OverlayModel.self, from: data)
        }
    }

    enum PageModelData {
        static func withBNF() -> PageModel {
            let data = toData(jsonFilename: "page_model")
            let experienceResponse = try! JSONDecoder().decode(ExperienceResponse.self, from: data)
            return experienceResponse.getPageModel()!
        }
    }

    static func toData(jsonFilename: String) -> Data {
        let bundle = Bundle(for: type(of: FakeObject().self))
        let url = bundle.url(forResource: jsonFilename, withExtension: "json")!

        return try! (Data(contentsOf: url))
    }
}

class FakeObject: NSObject {}
