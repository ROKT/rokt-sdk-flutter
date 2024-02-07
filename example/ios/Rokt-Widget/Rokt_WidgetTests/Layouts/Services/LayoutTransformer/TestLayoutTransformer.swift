//
//  TestLayoutTransformer.swift
//  Rokt_WidgetTests
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import XCTest

@available(iOS 15, *)
final class TestLayoutTransformer: XCTestCase {
    
    func test_creative_response_includes_positive_response_option() throws {
        // Arrange
        guard let model = ModelTestData.CreativeResponseData.positive() else {
            XCTFail("Could not load the json")
            return
        }
        let responseOption = ResponseOption(id: "",
                                            action: .url,
                                            instanceGuid: "",
                                            signalType: .signalGatedResponse,
                                            shortLabel: "Yes please",
                                            longLabel: "Yes please",
                                            shortSuccessLabel: "",
                                            isPositive: true,
                                            url: "")
        let slot = get_slot(responseOptionList: ResponseOptionList(positive: responseOption,
                                                                   negative: nil))
        
        let layoutTransformer = LayoutTransformer(layoutPlugin: get_layout_plugin(layout: nil, slots: [slot]))
        
        // Act
        let transformedCreativeResponse = layoutTransformer.getCreativeResponseUIModel(responseKey: model.responseKey,
                                                                                       openLinks: nil,
                                                                                       styles: model.styles,
                                                                                       children: layoutTransformer.transformChildren(model.children, slot: slot),
                                                                                       slot: slot)
        
        // Assert
        XCTAssertEqual(transformedCreativeResponse.responseOptions, responseOption)
    }
    
    func test_creative_response_includes_negative_response_option() throws {
        // Arrange
        guard let model = ModelTestData.CreativeResponseData.negative() else {
            XCTFail("Could not load the json")
            return
        }
        let responseOption = ResponseOption(id: "",
                                            action: .url,
                                            instanceGuid: "",
                                            signalType: .signalResponse,
                                            shortLabel: "No Thanks",
                                            longLabel: "No Thanks",
                                            shortSuccessLabel: "",
                                            isPositive: false,
                                            url: "")
        let slot = get_slot(responseOptionList: ResponseOptionList(positive: nil,
                                                                   negative: responseOption))

        let layoutTransformer = LayoutTransformer(layoutPlugin: get_layout_plugin(layout: nil, slots: [slot]))
        
        // Act
        let transformedCreativeResponse = layoutTransformer.getCreativeResponseUIModel(responseKey: model.responseKey,
                                                                                       openLinks: nil,
                                                                                       styles: model.styles,
                                                                                       children: layoutTransformer.transformChildren(model.children, slot: slot),
                                                                                       slot: slot)
        
        // Assert
        XCTAssertEqual(transformedCreativeResponse.responseOptions, responseOption)
    }
    
    func test_creative_response_negative_not_presented() throws {
        // Arrange
        guard let model = ModelTestData.CreativeResponseData.negative() else {
            XCTFail("Could not load the json")
            return
        }
        let slot = get_slot(responseOptionList: nil)

        let layoutTransformer = LayoutTransformer(layoutPlugin: get_layout_plugin(layout: nil, slots: [slot]))
        
        // Act
        let transformedCreativeResponse = layoutTransformer.getCreativeResponse(responseKey: model.responseKey,
                                                                                openLinks: nil,
                                                                                styles: model.styles,
                                                                                children: layoutTransformer.transformChildren(model.children, slot: slot),
                                                                                slot: slot)
        
        // Assert
        XCTAssertEqual(transformedCreativeResponse, .empty)
    }
    
    func test_creative_response_neutral_not_presented() throws {
        // Arrange
        guard let model = ModelTestData.CreativeResponseData.neutral() else {
            XCTFail("Could not load the json")
            return
        }
        let positiveResponseOption = ResponseOption(id: "",
                                                    action: .url,
                                                    instanceGuid: "",
                                                    signalType: .signalGatedResponse,
                                                    shortLabel: "Yes please",
                                                    longLabel: "Yes please",
                                                    shortSuccessLabel: "",
                                                    isPositive: true,
                                                    url: "")
        let negativeResponseOption = ResponseOption(id: "",
                                                    action: .url,
                                                    instanceGuid: "",
                                                    signalType: .signalResponse,
                                                    shortLabel: "No Thanks",
                                                    longLabel: "No Thanks",
                                                    shortSuccessLabel: "",
                                                    isPositive: false,
                                                    url: "")
        let slot = get_slot(responseOptionList: ResponseOptionList(positive: positiveResponseOption,
                                                                   negative: negativeResponseOption))
        
        let layoutTransformer = LayoutTransformer(layoutPlugin: get_layout_plugin(layout: nil, slots: [slot]))
        
        // Act
        let transformedCreativeResponse = layoutTransformer.getCreativeResponse(responseKey: model.responseKey,
                                                                                openLinks: nil,
                                                                                styles: model.styles,
                                                                                children: layoutTransformer.transformChildren(model.children, slot: slot),
                                                                                slot: slot)
        
        // Assert
        XCTAssertEqual(transformedCreativeResponse, .empty)
    }

    // MARK: - ProgressIndicatorTests
    func test_progressIndicator_withSingleDataExpansion_parsesUnexpandedData() {
        let model = ModelTestData.ProgressIndicatorData.progressIndicator()
        let layoutTransformer = LayoutTransformer(layoutPlugin: get_layout_plugin(layout: nil, slots: []))

        let layoutSchemaUIModel = layoutTransformer.getProgressIndicator(model)

        XCTAssertNotEqual(layoutSchemaUIModel, .empty)

        guard case .progressIndicator(let uiModel) = layoutSchemaUIModel
        else {
            XCTFail("Could not create progress indicator")
            return
        }

        XCTAssertEqual(uiModel.indicator, "%^STATE.IndicatorPosition^%")
    }

    func test_progressIndicator_withValidChainOfDataExpansion_parsesUnexpandedData() {
        let model = ModelTestData.ProgressIndicatorData.chainOfvaluesDataExpansion()
        let layoutTransformer = LayoutTransformer(layoutPlugin: get_layout_plugin(layout: nil, slots: []))

        let layoutSchemaUIModel = layoutTransformer.getProgressIndicator(model)

        XCTAssertNotEqual(layoutSchemaUIModel, .empty)

        guard case .progressIndicator(let uiModel) = layoutSchemaUIModel
        else {
            XCTFail("Could not create progress indicator")
            return
        }

        XCTAssertEqual(uiModel.indicator, "%^STATE.InitialWrongValue | STATE.IndicatorPosition^%")
    }

    func test_progressIndicator_withInvalidDataExpansion_shouldReturnEmpty() {
        let model = ModelTestData.ProgressIndicatorData.invalidDataExpansion()
        let layoutTransformer = LayoutTransformer(layoutPlugin: get_layout_plugin(layout: nil, slots: []))

        let uiModel = layoutTransformer.getProgressIndicator(model)

        XCTAssertEqual(uiModel, .empty)
    }

    func test_transform_onebyone() throws {
        // Arrange
        guard let model = ModelTestData.OneByOneData.oneByOne(),
              let response = ModelTestData.CreativeResponseData.negative() else {
            XCTFail("Could not load the json")
            return
        }
        let responseOption = ResponseOption(id: "",
                                            action: .url,
                                            instanceGuid: "",
                                            signalType: .signalResponse,
                                            shortLabel: "No Thanks",
                                            longLabel: "No Thanks",
                                            shortSuccessLabel: "",
                                            isPositive: false,
                                            url: "")
        let slot = get_slot(responseOptionList: ResponseOptionList(positive: nil,
                                                                   negative: responseOption),
                            layoutVariant: response)
        
        let layoutTransformer = LayoutTransformer(layoutPlugin: get_layout_plugin(layout: .oneByOneDistribution(model), slots: [slot]))

        // Act
        let transformedOneByOne = layoutTransformer.getOneByOne(oneByOneModel: model)

        // Assert
        
        // oneByOne loaded with children from slot
        XCTAssertEqual(transformedOneByOne.children?.count, 1)
    }
    
    func get_layout_plugin(layout: OuterLayoutSchemaModel?, slots: [SlotModel]) -> LayoutPlugin {
        return LayoutPlugin(pluginInstanceGuid: "", breakpoints: nil, layout: layout, slots: slots, targetElementSelector: "")
    }
    
    func get_slot(responseOptionList: ResponseOptionList?,
                  layoutVariant: CreativeResponseModel<CreativeResponseChildren>? = nil) -> SlotModel {
        return SlotModel(instanceGuid: "",
                         offer: OfferModel(campaignId: "",
                                           creative: CreativeModel(referralCreativeId: "",
                                                                   instanceGuid: "",
                                                                   copy: [:],
                                                                   images: nil,
                                                                   links: [:],
                                                                   responseOptionsMap: responseOptionList)),
                         layoutVariant: layoutVariant == nil ? nil : LayoutVariantModel(layoutVariantSchema: .creativeResponse(layoutVariant!), moduleName: ""))
    }
    
}
