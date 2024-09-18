//
//  RoktMockAPI.swift
//  Rokt_WidgetTests
//
//  Copyright 2020 Rokt Pte Ltd
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import XCTest

class TestTransformer: XCTestCase {
    func test_transforming_placement() throws {
        let placement = getDefaultPlacement()
        let transformer = getPlacementTransformer(placement)
        let placementViewData = try transformer.transformPlacement()
        XCTAssertNotNil(placementViewData)
    }

    func test_offer_exist() throws {
        let placement = getDefaultPlacement()
        let transformer = getPlacementTransformer(placement)
        let placementViewData = try transformer.transformPlacement()
        XCTAssert(placementViewData.offers.count > 0)
    }
    // MARK: utility getString
    func test_utility_getString_valid_string() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        let value = try transformer.getString("key", from: ["key": "value"])
        XCTAssertEqual(value, "value")
    }

    func test_utility_getString_invalid_keyNotFound() {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getString("key", from: ["Anotherkey": "value"])) { error in
            XCTAssertEqual(error as! TransformerError, TransformerError.KeyIsMissing(key: "key"))
        }
    }
    // MARK: property getString
    func test_property_getString_valid_string() throws {
        let placement = getSamplePlacement(["key": "value"])
        let transformer = getPlacementTransformer(placement)
        let value = try transformer.getString("key")
        XCTAssertEqual(value, "value")
    }

    func test_property_getString_invalid_keyNotFound() {
        let placement = getSamplePlacement(["Anotherkey": "value"])
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getString("key")) { error in
            XCTAssertEqual(error as! TransformerError, TransformerError.KeyIsMissing(key: "key"))
        }
    }

    func test_property_getString_emptyConfiguration_keyNotFound() {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getString("key")) { error in
            XCTAssertEqual(error as! TransformerError,
                           TransformerError.KeyIsMissing(key: transformer.placementConfigurableText))
        }
    }
    // MARK: property getOptionalString
    func test_property_getOptionalString_valid_nil() throws {
        let placement = getSamplePlacement(["Anotherkey": "value"])
        let transformer = getPlacementTransformer(placement)
        let value = try transformer.getOptionalString("key")
        XCTAssertNil(value)
    }

    func test_property_getOptionalString_valid_emptyConfigurables() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        let value = try transformer.getOptionalString("key")
        XCTAssertNil(value)
    }
    // MARK: utility getInt
    func test_utility_getInt_valid_int() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        let value = try transformer.getInt("key", from: ["key": "12"])
        XCTAssertEqual(value, 12)
    }

    func test_utility_getInt_invalid_keyNotFound() {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getInt("key", from: ["Anotherkey": "12"])) { error in
            XCTAssertEqual(error as! TransformerError, TransformerError.KeyIsMissing(key: "key"))
        }
    }

    func test_utility_getInt_invalid_TypeMissMath() {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getInt("key", from: ["key": "text"])) { error in
            XCTAssertEqual(error as! TransformerError, TransformerError.TypeMissMatch(key: "key"))
        }
    }
    // MARK: utility getOptionalInt
    func test_utility_getInt_valid_optionalKey() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        let value = try transformer.getOptionalInt("key", from: ["Anotherkey": "12"])
        XCTAssertNil(value)
    }

    func test_utility_getOptionalInt_invalid_TypeMissMath() {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getOptionalInt("key", from: ["key": "text"])) { error in
            XCTAssertEqual(error as! TransformerError, TransformerError.TypeMissMatch(key: "key"))
        }
    }
    // MARK: property getInt
    func test_property_getInt_valid_int() throws {
        let placement = getSamplePlacement(["key": "12"])
        let transformer = getPlacementTransformer(placement)
        let value = try transformer.getInt("key")
        XCTAssertEqual(value, 12)
    }

    func test_property_getInt_invalid_keyNotFound() {
        let placement = getSamplePlacement(["AnotherKey": "12"])
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getInt("key")) { error in
            XCTAssertEqual(error as! TransformerError, TransformerError.KeyIsMissing(key: "key"))
        }
    }

    func test_property_getInt_invalid_TypeMissMath() {
        let placement = getSamplePlacement(["key": "text"])
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getInt("key")) { error in
            XCTAssertEqual(error as! TransformerError, TransformerError.TypeMissMatch(key: "key"))
        }
    }
    // MARK: property getOptionalInt
    func test_property_getInt_valid_optionalKey() throws {
        let placement = getSamplePlacement(["AnotherKey": "text"])
        let transformer = getPlacementTransformer(placement)
        let value = try transformer.getOptionalInt("key")
        XCTAssertNil(value)
    }

    func test_property_getOptionalInt_invalid_TypeMissMath() {
        let placement = getSamplePlacement(["key": "text"])
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getOptionalInt("key")) { error in
            XCTAssertEqual(error as! TransformerError, TransformerError.TypeMissMatch(key: "key"))
        }
    }

    func test_property_getInt_emptyConfigurable_optionalKey() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getInt("key")) { error in
            XCTAssertEqual(error as! TransformerError,
                           TransformerError.KeyIsMissing(key: transformer.placementConfigurableText))
        }
    }

    func test_property_getOptionalInt_emptyConfigurable_optionalKey() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        let value = try transformer.getOptionalInt("key")
        XCTAssertNil(value)
    }

    // MARK: utility getFloat
    func test_utility_getFloat_valid_float() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        let value = try transformer.getFloat("key", from: ["key": "12.5"])
        XCTAssertEqual(value, 12.5)
    }

    func test_utility_getFloat_invalid_keyNotFound() {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getFloat("key", from: ["Anotherkey": "12"])) { error in
            XCTAssertEqual(error as! TransformerError, TransformerError.KeyIsMissing(key: "key"))
        }
    }

    func test_utility_getFloat_invalid_TypeMissMath() {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getFloat("key", from: ["key": "text"])) { error in
            XCTAssertEqual(error as! TransformerError, TransformerError.TypeMissMatch(key: "key"))
        }
    }
    // MARK: utility getOptionalFloat
    func test_utility_getOptionalFloat_invalid_TypeMissMath() {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getOptionalFloat("key", from: ["key": "text"])) { error in
            XCTAssertEqual(error as! TransformerError, TransformerError.TypeMissMatch(key: "key"))
        }
    }
    // MARK: property getFloat
    func test_property_getFloat_valid_float() throws {
        let placement = getSamplePlacement(["key": "12.5"])
        let transformer = getPlacementTransformer(placement)
        let value = try transformer.getFloat("key")
        XCTAssertEqual(value, 12.5)
    }

    func test_property_getFloat_invalid_keyNotFound() {
        let placement = getSamplePlacement(["AnotherKey": "12.5"])
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getFloat("key")) { error in
            XCTAssertEqual(error as! TransformerError, TransformerError.KeyIsMissing(key: "key"))
        }
    }

    func test_property_getFloat_invalid_TypeMissMath() {
        let placement = getSamplePlacement(["key": "text"])
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getFloat("key")) { error in
            XCTAssertEqual(error as! TransformerError, TransformerError.TypeMissMatch(key: "key"))
        }
    }

    func test_property_getFloat_emptyConfigurables_TypeMissMath() {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getFloat("key")) { error in
            XCTAssertEqual(error as! TransformerError,
                           TransformerError.KeyIsMissing(key: transformer.placementConfigurableText))
        }
    }
    // MARK: property getOptionalFloat
    func test_utility_getOptionalFloat_valid_nil() {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        XCTAssertNil(try transformer.getOptionalFloat("key"))
    }

    func test_property_getOptionalFloat_invalid_TypeMissMath() {
        let placement = getSamplePlacement(["key": "text"])
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getOptionalFloat("key")) { error in
            XCTAssertEqual(error as! TransformerError, TransformerError.TypeMissMatch(key: "key"))
        }
    }

    // MARK: utility getBool
    func test_utility_getBool_valid_Bool() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        let value = try transformer.getBool("key", from: ["key": "true"])
        XCTAssertEqual(value, true)
    }

    func test_utility_getBool_invalid_keyNotFound() {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getBool("key", from: ["Anotherkey": "false"])) { error in
            XCTAssertEqual(error as! TransformerError, TransformerError.KeyIsMissing(key: "key"))
        }
    }

    func test_utility_getBool_invalid_TypeMissMath() {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getBool("key", from: ["key": "text"])) { error in
            XCTAssertEqual(error as! TransformerError, TransformerError.TypeMissMatch(key: "key"))
        }
    }
    // MARK: utility getOptionalBool
    func test_utility_getOptionalBool_invalid_TypeMissMath() {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getOptionalBool("key", from: ["key": "text"])) { error in
            XCTAssertEqual(error as! TransformerError, TransformerError.TypeMissMatch(key: "key"))
        }
    }
    // MARK: property getBool
    func test_property_getBool_valid() throws {
        let placement = getSamplePlacement(["key": "false"])
        let transformer = getPlacementTransformer(placement)
        let value = try transformer.getBool("key")
        XCTAssertEqual(value, false)
    }

    func test_property_getBool_invalid_keyNotFound() {
        let placement = getSamplePlacement(["Anotherkey": "false"])
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getBool("key")) { error in
            XCTAssertEqual(error as! TransformerError, TransformerError.KeyIsMissing(key: "key"))
        }
    }

    func test_property_getBool_emptyConfigurable_keyNotFound() {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getBool("key")) { error in
            XCTAssertEqual(error as! TransformerError, TransformerError.KeyIsMissing(key: "Placement Configurable"))
        }
    }

    func test_property_getBool_invalid_TypeMissMath() {
        let placement = getSamplePlacement(["key": "text"])
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getBool("key")) { error in
            XCTAssertEqual(error as! TransformerError, TransformerError.TypeMissMatch(key: "key"))
        }
    }
    // MARK: property getOptionalBool
    func test_property_getOptionalBool_invalid_TypeMissMath() {
        let placement = getSamplePlacement(["key": "text"])
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.getOptionalBool("key")) { error in
            XCTAssertEqual(error as! TransformerError, TransformerError.TypeMissMatch(key: "key"))
        }
    }

    func test_property_getOptionalBool_valid_emptyConfig() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        let value = try transformer.getOptionalBool("key")
        XCTAssertNil(value)
    }
    // MARK: utility getColorMap
    func test_utility_getColorMap_valid_color() throws {
        let placement = getDefaultPlacement()
        let transformer = getPlacementTransformer(placement)
        let colorMap = try transformer.getColorMap(MobilePlacementTitleFontColorLight,
                                                   keyDark: MobilePlacementTitleFontColorDark)
        XCTAssertEqual(colorMap, [0: "#ffffff", 1: "#ffffff"])
    }

    func test_utility_getColorMap_invalid_LightColor() {
        let placement = getDefaultPlacement()
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(
            try transformer.getColorMap("invalid key",
                                        keyDark: MobilePlacementTitleFontColorDark)) { error in
                                            XCTAssertEqual(error as! TransformerError,
                                                           TransformerError.KeyIsMissing(key: "invalid key"))
                                        }
    }

    func test_utility_getColorMap_invalid_DarkColor() {
        let placement = getDefaultPlacement()
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(
            try transformer.getColorMap(MobilePlacementTitleFontColorLight,
                                        keyDark: "invalid dark key")) { error in
                                            XCTAssertEqual(error as! TransformerError,
                                                           TransformerError.KeyIsMissing(key: "invalid dark key"))
                                        }
    }
    // MARK: getOptionalColorMap
    func test_utility_getOptiobnalColorMap_valid_color() throws {
        let placement = getDefaultPlacement()
        let transformer = getPlacementTransformer(placement)
        let colorMap = try transformer.getOptionalColorMap(MobilePlacementTitleFontColorLight,
                                                           keyDark: MobilePlacementTitleFontColorDark)
        XCTAssertEqual(colorMap, [0: "#ffffff", 1: "#ffffff"])
    }

    func test_utility_getOptiobnalColorMap_invalid_LightColor() throws {
        let placement = getDefaultPlacement()
        let transformer = getPlacementTransformer(placement)
        let colorMap = try transformer.getOptionalColorMap("invalid dark key",
                                                           keyDark: MobilePlacementTitleFontColorDark)
        XCTAssertNil(colorMap)
    }

    func test_utility_getOptiobnalColorMap_invalid_DarkColor() throws {
        let placement = getDefaultPlacement()
        let transformer = getPlacementTransformer(placement)
        let colorMap = try transformer.getOptionalColorMap(MobilePlacementTitleFontColorLight,
                                                           keyDark: "invalid dark key")
        XCTAssertNil(colorMap)
    }

    // MARK: getAlignment
    func test_alignment_valid() throws {
        let placement = getSamplePlacement(["alignment1": "start", "alignment2": "center", "alignment3": "end"])
        let transformer = getPlacementTransformer(placement)
        let textAlignment1 = try transformer.getAlignment("alignment1")
        let textAlignment2 = try transformer.getAlignment("alignment2")
        let textAlignment3 = try transformer.getAlignment("alignment3")
        XCTAssertEqual(textAlignment1, ViewAlignment.start)
        XCTAssertEqual(textAlignment2, ViewAlignment.center)
        XCTAssertEqual(textAlignment3, ViewAlignment.end)
    }

    func test_alignment_invalid_returnToDefault() throws {
        let placement = getSamplePlacement(["alignment1": "somewhere", "alignment2": ""])
        let transformer = getPlacementTransformer(placement)
        let textAlignment1 = try transformer.getAlignment("alignment1")
        let textAlignment2 = try transformer.getAlignment("alignment2")
        let textAlignment3 = try transformer.getAlignment("alignment2")
        XCTAssertEqual(textAlignment1, ViewAlignment.start)
        XCTAssertEqual(textAlignment2, ViewAlignment.start)
        XCTAssertEqual(textAlignment3, ViewAlignment.start)
    }
    // MARK: getOptionalAlignment
    func test_optional_alignment_valid() throws {
        let placement = getSamplePlacement(["alignment1": "start", "alignment2": "center", "alignment3": "end"])
        let transformer = getPlacementTransformer(placement)
        let textAlignment1 = try transformer.getOptionalAlignment("alignment1")
        let textAlignment2 = try transformer.getOptionalAlignment("alignment2")
        let textAlignment3 = try transformer.getOptionalAlignment("alignment3")
        XCTAssertEqual(textAlignment1, ViewAlignment.start)
        XCTAssertEqual(textAlignment2, ViewAlignment.center)
        XCTAssertEqual(textAlignment3, ViewAlignment.end)
    }

    func test_optional_alignment_invalid_return_nil() throws {
        let placement = getSamplePlacement(["alignment1": "somewhere", "alignment2": ""])
        let transformer = getPlacementTransformer(placement)
        let textAlignment1 = try transformer.getOptionalAlignment("alignment1")
        let textAlignment2 = try transformer.getOptionalAlignment("alignment2")
        XCTAssertNil(textAlignment1)
        XCTAssertNil(textAlignment2)
    }

    // MARK: getFrameAlignment
    func test_frameAlignment_valid() throws {
        let placement = getSamplePlacement(["padding": "10 20 30 40"])
        let transformer = getPlacementTransformer(placement)
        let frameAlignment = try transformer.getFrameAlignment("padding")
        XCTAssertEqual(frameAlignment, FrameAlignment(top: 10, right: 20, bottom: 30, left: 40))
    }

    func test_frameAlignment_invalid() throws {
        let placement = getSamplePlacement(["padding": "0 0"])
        let transformer = getPlacementTransformer(placement)
        let frameAlignment = try transformer.getFrameAlignment("padding")
        XCTAssertEqual(frameAlignment, FrameAlignment(top: 0, right: 0, bottom: 0, left: 0))
    }

    func test_frameAlignment_invalid_types() throws {
        let placement = getSamplePlacement(["padding": "m m m m"])
        let transformer = getPlacementTransformer(placement)
        let frameAlignment = try transformer.getFrameAlignment("padding")
        XCTAssertEqual(frameAlignment, FrameAlignment(top: 0, right: 0, bottom: 0, left: 0))
    }

    func test_frameAlignment_invalid_keyMissing_retunToDefault() throws {
        let placement = getSamplePlacement([:])
        let transformer = getPlacementTransformer(placement)
        let frameAlignment = try transformer.getFrameAlignment("padding")
        XCTAssertEqual(frameAlignment, FrameAlignment(top: 0, right: 0, bottom: 0, left: 0))
    }
    // MARK: getOptionalFrameAlignment
    func test_optionalFrameAlignment_valid() throws {
        let placement = getSamplePlacement(["padding": "10 20 30 40"])
        let transformer = getPlacementTransformer(placement)
        let frameAlignment = try transformer.getOptionalFrameAlignment("padding")
        XCTAssertEqual(frameAlignment, FrameAlignment(top: 10, right: 20, bottom: 30, left: 40))
    }

    func test_optionalFrameAlignment_invalid() throws {
        let placement = getSamplePlacement(["padding": "10 10"])
        let transformer = getPlacementTransformer(placement)
        let frameAlignment = try transformer.getOptionalFrameAlignment("padding")
        XCTAssertNil(frameAlignment)
    }

    func test_optionalFrameAlignment_invalid_types() throws {
        let placement = getSamplePlacement(["padding": "m m m m"])
        let transformer = getPlacementTransformer(placement)
        let frameAlignment = try transformer.getOptionalFrameAlignment("padding")
        XCTAssertNil(frameAlignment)
    }

    func test_optionalFrameAlignment_invalid_keyMissing_retunToDefault() throws {
        let placement = getSamplePlacement([:])
        let transformer = getPlacementTransformer(placement)
        let frameAlignment = try transformer.getOptionalFrameAlignment("padding")
        XCTAssertNil(frameAlignment)
    }
    // MARK: getTextStyle
    func test_textStyle_valid_withAllItems() throws {
        let configurables = ["font": "font", "size": "12", "colorLight": "light",
                             "colorDark": "dark", "alignment": "start", "lineSpacing": "1",
                             "backgroundLight": "backLight", "backgroundDark": "backDark"]
        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)
        let textStyle = try transformer.getTextStyle(keyFontFamily: "font", keySize: "size",
                                                     keyColorLight: "colorLight",
                                                     keyColorDark: "colorDark",
                                                     keyAlignment: "alignment",
                                                     keyLineSpacing: "lineSpacing",
                                                     keyBackgroundColorLight: "backgroundLight",
                                                     keyBackgroundColorDark: "backgroundDark")

        XCTAssertEqual(textStyle,
                       TextStyleViewData(fontFamily: "font",
                                         fontSize: 12,
                                         fontColor: [0: "light", 1: "dark"],
                                         backgroundColor: [0: "backLight", 1: "backDark"],
                                         alignment: .start,
                                         lineSpacing: 1))
    }

    func test_textStyle_valid_withMinimumItem() throws {
        let configurables = ["font": "font", "size": "12", "colorLight": "light",
                             "colorDark": "dark"]
        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)
        let textStyle = try transformer.getTextStyle(keyFontFamily: "font", keySize: "size",
                                                     keyColorLight: "colorLight",
                                                     keyColorDark: "colorDark",
                                                     keyAlignment: "alignment",
                                                     keyLineSpacing: "lineSpacing",
                                                     keyBackgroundColorLight: "backgroundLight",
                                                     keyBackgroundColorDark: "backgroundDark")

        XCTAssertEqual(textStyle,
                       TextStyleViewData(fontFamily: "font",
                                         fontSize: 12,
                                         fontColor: [0: "light", 1: "dark"],
                                         backgroundColor: nil,
                                         alignment: .start,
                                         lineSpacing: 1))
    }

    func test_textStyle_invalid_keyMissing() throws {
        let configurables = ["font": "font", "colorLight": "light",
                             "colorDark": "dark"]
        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        XCTAssertThrowsError(
            try transformer.getTextStyle(keyFontFamily: "font", keySize: "size",
                                         keyColorLight: "colorLight",
                                         keyColorDark: "colorDark",
                                         keyAlignment: "alignment",
                                         keyLineSpacing: "lineSpacing",
                                         keyBackgroundColorLight: "backgroundLight",
                                         keyBackgroundColorDark: "backgroundDark")
        ) { error in
            XCTAssertEqual(error as! TransformerError,
                           TransformerError.KeyIsMissing(key: "size"))

        }
    }
    // MARK: getButtonStyle
    func test_buttonStyle_valid_withAllItems() throws {
        let configurables = ["font": "font", "size": "12", "colorLight": "light",
                             "colorDark": "dark", "lineSpacing": "1",
                             "backgroundLight": "backLight", "backgroundDark": "backDark",
                             "cornerRadius": "5", "borderThickness": "4",
                             "borderColorLight": "borderLight", "borderColorDark": "borderDark"]
        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)
        let buttonStyle = try transformer.getButtonStyle(keyFontFamily: "font",
                                                         keyFontWeight: "fontWeight",
                                                         keySize: "size",
                                                         keyColorLight: "colorLight",
                                                         keyColorDark: "colorDark",
                                                         keyCornerRadius: "cornerRadius",
                                                         keyBorderThickness: "borderThickness",
                                                         keyBorderColorLight: "borderColorLight",
                                                         keyBorderColorDark: "borderColorDark",
                                                         keyBackgroundColorLight: "backgroundLight",
                                                         keyBackgroundColorDark: "backgroundDark")

        XCTAssertEqual(buttonStyle,
                       ButtonStyleViewData(textStyleViewData:
                                            TextStyleViewData(fontFamily: "font",
                                                              fontSize: 12,
                                                              fontColor: [0: "light", 1: "dark"],
                                                              backgroundColor: [0: "backLight", 1: "backDark"],
                                                              alignment: .center,
                                                              lineSpacing: 1),
                                           cornerRadius: 5, borderThickness: 4,
                                           borderColor: [0: "borderLight", 1: "borderDark"])
        )
    }

    func test_buttonStyle_invalid_keyMissing() throws {
        let configurables = ["font": "font", "size": "12", "colorLight": "light",
                             "colorDark": "dark", "alignment": "start", "lineSpacing": "1",
                             "backgroundLight": "backLight", "backgroundDark": "backDark",
                             "borderThickness": "4",
                             "borderColorLight": "borderLight", "borderColorDark": "borderDark"]
        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        XCTAssertThrowsError(
            try transformer.getButtonStyle(keyFontFamily: "font",
                                           keyFontWeight: "fontWeight",
                                           keySize: "size",
                                           keyColorLight: "colorLight",
                                           keyColorDark: "colorDark",
                                           keyCornerRadius: "cornerRadius",
                                           keyBorderThickness: "borderThickness",
                                           keyBorderColorLight: "borderColorLight",
                                           keyBorderColorDark: "borderColorDark",
                                           keyBackgroundColorLight: "backgroundLight",
                                           keyBackgroundColorDark: "backgroundDark")) { error in
                                            XCTAssertEqual(error as! TransformerError,
                                                           TransformerError.KeyIsMissing(key: "cornerRadius"))

        }

    }

    // MARK: transform footer
    func test_footer_valid_both() throws {
        let configurables = [MobilePlacementFooterRoktPrivacyPolicyFontFamily: "font",
                             MobilePlacementFooterRoktPrivacyPolicyFontWeight: "bold",
                             MobilePlacementFooterRoktPrivacyPolicyFontSize: "12",
                             MobilePlacementFooterRoktPrivacyPolicyFontColorLight: "light",
                             MobilePlacementFooterRoktPrivacyPolicyFontColorDark: "dark",
                             MobilePlacementFooterRoktPrivacyPolicyAlignment: "start",
                             MobilePlacementFooterRoktPrivacyPolicyLineSpacing: "1",
                             MobilePlacementFooterRoktPrivacyPolicyBackgroundColorLight: "backLight",
                             MobilePlacementFooterRoktPrivacyPolicyBackgroundColorDark: "backDark",
                             MobilePlacementFooterRoktPrivacyPolicyContent: "rokt text",
                             MobilePlacementFooterRoktPrivacyPolicyLink: "rokt link",
                             MobilePlacementFooterPartnerPrivacyPolicyFontFamily: "font",
                             MobilePlacementFooterPartnerPrivacyPolicyFontWeight: "random",
                             MobilePlacementFooterPartnerPrivacyPolicyFontSize: "12",
                             MobilePlacementFooterPartnerPrivacyPolicyFontColorLight: "light",
                             MobilePlacementFooterPartnerPrivacyPolicyFontColorDark: "dark",
                             MobilePlacementFooterPartnerPrivacyPolicyAlignment: "start",
                             MobilePlacementFooterPartnerPrivacyPolicyLineSpacing: "1",
                             MobilePlacementFooterPartnerPrivacyPolicyBackgroundColorLight: "backLight",
                             MobilePlacementFooterPartnerPrivacyPolicyBackgroundColorDark: "backDark",
                             MobilePlacementFooterPartnerPrivacyPolicyContent: "partner text",
                             MobilePlacementFooterPartnerPrivacyPolicyLink: "partner link",

                             MobilePlacementFooterBackgroundColorLight: "footer back Light",
                             MobilePlacementFooterBackgroundColorDark: "footer back dark"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)
        let footer = FooterViewData(backgroundColor: [0: "footer back Light", 1: "footer back dark"],
                                    roktPrivacyPolicy:
                                        LinkViewData(text: "rokt text", link: "rokt link",
                                                     textStyleViewData:
                                                        TextStyleViewData(fontFamily: "font",
                                                                          fontWeight: .bold,
                                                                          fontSize: 12,
                                                                          fontColor: [0: "light", 1: "dark"],
                                                                          backgroundColor: [0: "backLight", 1: "backDark"],
                                                                          alignment: .start, lineSpacing: 1), underline: false),
                                    partnerPrivacyPolicy:
                                        LinkViewData(text: "partner text", link: "partner link",
                                                     textStyleViewData:
                                                        TextStyleViewData(fontFamily: "font",
                                                                          fontWeight: nil,
                                                                          fontSize: 12,
                                                                          fontColor: [0: "light", 1: "dark"],
                                                                          backgroundColor: [0: "backLight", 1: "backDark"],
                                                                          alignment: .start, lineSpacing: 1), underline: false),
                                    footerDivider: DividerViewDataWithDimensions(backgroundColor: nil,
                                                                                 isVisible: true,
                                                                                 height: 2,
                                                                                 margin: FrameAlignment(top: 10, right: 0, bottom: 0, left: 0)),
                                    alignment: .end)
        XCTAssertEqual(footer, try transformer.transformFooter())
    }

    func test_footer_valid_roktPrivacyPolicy() throws {
        let configurables = [MobilePlacementFooterRoktPrivacyPolicyFontFamily: "font",
                             MobilePlacementFooterRoktPrivacyPolicyFontSize: "12",
                             MobilePlacementFooterRoktPrivacyPolicyFontColorLight: "light",
                             MobilePlacementFooterRoktPrivacyPolicyFontColorDark: "dark",
                             MobilePlacementFooterRoktPrivacyPolicyAlignment: "start",
                             MobilePlacementFooterRoktPrivacyPolicyLineSpacing: "1",
                             MobilePlacementFooterRoktPrivacyPolicyBackgroundColorLight: "backLight",
                             MobilePlacementFooterRoktPrivacyPolicyBackgroundColorDark: "backDark",
                             MobilePlacementFooterRoktPrivacyPolicyContent: "rokt text",
                             MobilePlacementFooterRoktPrivacyPolicyLink: "rokt link",

                             MobilePlacementFooterBackgroundColorLight: "footer back Light",
                             MobilePlacementFooterBackgroundColorDark: "footer back dark"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)
        let footer = FooterViewData(backgroundColor: [0: "footer back Light", 1: "footer back dark"],
                                    roktPrivacyPolicy:
                                        LinkViewData(text: "rokt text", link: "rokt link",
                                                     textStyleViewData:
                                                        TextStyleViewData(fontFamily: "font", fontSize: 12,
                                                                          fontColor: [0: "light", 1: "dark"],
                                                                          backgroundColor: [0: "backLight", 1: "backDark"],
                                                                          alignment: .start, lineSpacing: 1), underline: false),
                                    partnerPrivacyPolicy: nil,
                                    footerDivider: DividerViewDataWithDimensions(backgroundColor: nil,
                                                                                 isVisible: true,
                                                                                 height: 2,
                                                                                 margin: FrameAlignment(top: 10, right: 0, bottom: 0, left: 0)),
                                    alignment: .end)
        XCTAssertEqual(footer, try transformer.transformFooter())
    }

    func test_footer_valid_partnerPrivacyPolicy_noBackground() throws {
        let configurables = [MobilePlacementFooterPartnerPrivacyPolicyFontFamily: "font",
                             MobilePlacementFooterPartnerPrivacyPolicyFontSize: "12",
                             MobilePlacementFooterPartnerPrivacyPolicyFontColorLight: "light",
                             MobilePlacementFooterPartnerPrivacyPolicyFontColorDark: "dark",
                             MobilePlacementFooterPartnerPrivacyPolicyAlignment: "start",
                             MobilePlacementFooterPartnerPrivacyPolicyLineSpacing: "1",
                             MobilePlacementFooterPartnerPrivacyPolicyBackgroundColorLight: "backLight",
                             MobilePlacementFooterPartnerPrivacyPolicyBackgroundColorDark: "backDark",
                             MobilePlacementFooterPartnerPrivacyPolicyContent: "partner text",
                             MobilePlacementFooterPartnerPrivacyPolicyLink: "partner link"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)
        let footer = FooterViewData(backgroundColor: nil,
                                    roktPrivacyPolicy: nil,
                                    partnerPrivacyPolicy:
                                        LinkViewData(text: "partner text", link: "partner link",
                                                     textStyleViewData:
                                                        TextStyleViewData(fontFamily: "font", fontSize: 12,
                                                                          fontColor: [0: "light", 1: "dark"],
                                                                          backgroundColor: [0: "backLight", 1: "backDark"],
                                                                          alignment: .start, lineSpacing: 1), underline: false),
                                    footerDivider: DividerViewDataWithDimensions(backgroundColor: nil,
                                                                                 isVisible: true,
                                                                                 height: 2,
                                                                                 margin: FrameAlignment(top: 10, right: 0, bottom: 0, left: 0)),
                                    alignment: .end)
        XCTAssertEqual(footer, try transformer.transformFooter())
    }

    func test_footer_invalid_keymissing() throws {
        let configurables = [MobilePlacementFooterPartnerPrivacyPolicyFontSize: "12",
                             MobilePlacementFooterPartnerPrivacyPolicyFontColorLight: "light",
                             MobilePlacementFooterPartnerPrivacyPolicyFontColorDark: "dark",
                             MobilePlacementFooterPartnerPrivacyPolicyAlignment: "start",
                             MobilePlacementFooterPartnerPrivacyPolicyLineSpacing: "1",
                             MobilePlacementFooterPartnerPrivacyPolicyBackgroundColorLight: "backLight",
                             MobilePlacementFooterPartnerPrivacyPolicyBackgroundColorDark: "backDark",
                             MobilePlacementFooterPartnerPrivacyPolicyContent: "partner text",
                             MobilePlacementFooterPartnerPrivacyPolicyLink: "partner link"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        XCTAssertThrowsError( try transformer.transformFooter()) { error in
            XCTAssertEqual(error as! TransformerError,
                           TransformerError.KeyIsMissing(key: MobilePlacementFooterPartnerPrivacyPolicyFontFamily))

        }

    }

    func test_footer_valid_divider() throws {
        let configurables = [MobilePlacementFooterDividerBackgroundColorLight: "light",
                             MobilePlacementFooterDividerBackgroundColorDark: "dark",
                             MobilePlacementFooterDividerShow: "true"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let divider = DividerViewData(backgroundColor: [0: "light", 1: "dark"],
                                      isVisible: true)
        XCTAssertEqual(divider, try transformer.transformFooterDivider())
    }

    func test_footer_valid_divider_default_values() throws {
        let placement = getSamplePlacement([:])
        let transformer = getPlacementTransformer(placement)
        let divider = DividerViewData(backgroundColor: nil,
                                      isVisible: true)
        XCTAssertEqual(divider, try transformer.transformFooterDivider())
    }

    func test_footer_valid_divider_false() throws {
        let configurables = [MobilePlacementFooterDividerBackgroundColorLight: "lightColor",
                              MobilePlacementFooterDividerBackgroundColorDark: "darkColor",
                                             MobilePlacementFooterDividerShow: "false"]
        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let divider = DividerViewData(backgroundColor: [0: "lightColor", 1: "darkColor"],
                                      isVisible: false)
        XCTAssertEqual(divider, try transformer.transformFooterDivider())
    }

    func test_footer_invalid_divider() throws {
        let configurables = [MobilePlacementFooterDividerBackgroundColorLight: "lightColor",
                              MobilePlacementFooterDividerBackgroundColorDark: "darkColor",
                                             MobilePlacementFooterDividerShow: "10"]
        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        XCTAssertThrowsError( try transformer.transformFooterDivider()) { error in
            XCTAssertEqual(error as! TransformerError,
                           TransformerError.TypeMissMatch(key: MobilePlacementFooterDividerShow))
        }
    }

    // MARK: transform buttonStyle
    func test_buttonStyle_valid_positiveButtonStyle() throws {
        let configurables = [MobileCreativePositiveButtonDefaultFontFamily: "font",
                             MobileCreativePositiveButtonDefaultFontWeight: "semibold",
                             MobileCreativePositiveButtonDefaultFontSize: "12",
                             MobileCreativePositiveButtonDefaultFontColorLight: "light",
                             MobileCreativePositiveButtonDefaultFontColorDark: "dark",
                             MobileCreativePositiveButtonDefaultCornerRadius: "5",
                             MobileCreativePositiveButtonDefaultBorderThickness: "4",
                             MobileCreativePositiveButtonDefaultBorderColorLight: "borderLight",
                             MobileCreativePositiveButtonDefaultBorderColorDark: "borderDark",
                             MobileCreativePositiveButtonDefaultBackgroundColorLight: "backLight",
                             MobileCreativePositiveButtonDefaultBackgroundColorDark: "backDark",

                             MobileCreativePositiveButtonPressedFontFamily: "font",
                             MobileCreativePositiveButtonPressedFontSize: "12",
                             MobileCreativePositiveButtonPressedFontColorLight: "light",
                             MobileCreativePositiveButtonPressedFontColorDark: "dark",
                             MobileCreativePositiveButtonPressedCornerRadius: "5",
                             MobileCreativePositiveButtonPressedBorderThickness: "4",
                             MobileCreativePositiveButtonPressedBorderColorLight: "borderLight",
                             MobileCreativePositiveButtonPressedBorderColorDark: "borderDark",
                             MobileCreativePositiveButtonPressedBackgroundColorLight: "backLight",
                             MobileCreativePositiveButtonPressedBackgroundColorDark: "backDark"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)
        let positiveButtonStyle = ButtonStylesViewData(defaultStyle:
                                                        ButtonStyleViewData(textStyleViewData:
                                                                                TextStyleViewData(fontFamily: "font",
                                                                                                  fontWeight: .semiBold,
                                                                                                  fontSize: 12,
                                                                                                  fontColor: [0: "light", 1: "dark"],
                                                                                                  backgroundColor: [0: "backLight", 1: "backDark"],
                                                                                                  alignment: .center, lineSpacing: 1),
                                                                            cornerRadius: 5, borderThickness: 4, borderColor: [0: "borderLight", 1: "borderDark"]),
                                                       pressedStyle:
                                                        ButtonStyleViewData(textStyleViewData:
                                                                                TextStyleViewData(fontFamily: "font", fontSize: 12, fontColor: [0: "light", 1: "dark"],
                                                                                                  backgroundColor: [0: "backLight", 1: "backDark"],
                                                                                                  alignment: .center, lineSpacing: 1),
                                                                            cornerRadius: 5, borderThickness: 4, borderColor: [0: "borderLight", 1: "borderDark"]))
        XCTAssertEqual(positiveButtonStyle, try transformer.transformPositiveButtonStyles())

    }

    func test_buttonStyle_invalid_positiveButtonStyle() throws {
        let configurables = [MobileCreativePositiveButtonDefaultFontFamily: "font",
                             MobileCreativePositiveButtonDefaultFontSize: "12",
                             MobileCreativePositiveButtonDefaultFontColorLight: "light",
                             MobileCreativePositiveButtonDefaultFontColorDark: "dark",
                             MobileCreativePositiveButtonDefaultCornerRadius: "5",
                             MobileCreativePositiveButtonDefaultBorderThickness: "4",
                             MobileCreativePositiveButtonDefaultBorderColorLight: "borderLight",
                             MobileCreativePositiveButtonDefaultBorderColorDark: "borderDark",
                             MobileCreativePositiveButtonDefaultBackgroundColorLight: "backLight",
                             MobileCreativePositiveButtonDefaultBackgroundColorDark: "backDark",

                             MobileCreativePositiveButtonPressedFontFamily: "font",
                             MobileCreativePositiveButtonPressedFontSize: "12",
                             MobileCreativePositiveButtonPressedFontColorLight: "light",
                             MobileCreativePositiveButtonPressedFontColorDark: "dark",
                             MobileCreativePositiveButtonPressedBorderThickness: "4",
                             MobileCreativePositiveButtonPressedBorderColorLight: "borderLight",
                             MobileCreativePositiveButtonPressedBorderColorDark: "borderDark",
                             MobileCreativePositiveButtonPressedBackgroundColorLight: "backLight",
                             MobileCreativePositiveButtonPressedBackgroundColorDark: "backDark"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError( try transformer.transformPositiveButtonStyles()) { error in
            XCTAssertEqual(error as! TransformerError,
                           TransformerError.KeyIsMissing(key: MobileCreativePositiveButtonPressedCornerRadius))
        }

    }

    func test_buttonStyle_valid_negativeButtonStyle() throws {
        let configurables = [MobileCreativeNegativeButtonDefaultFontFamily: "font",
                             MobileCreativeNegativeButtonDefaultFontWeight: "semibold",
                             MobileCreativeNegativeButtonDefaultFontSize: "12",
                             MobileCreativeNegativeButtonDefaultFontColorLight: "light",
                             MobileCreativeNegativeButtonDefaultFontColorDark: "dark",
                             MobileCreativeNegativeButtonDefaultCornerRadius: "5",
                             MobileCreativeNegativeButtonDefaultBorderThickness: "4",
                             MobileCreativeNegativeButtonDefaultBorderColorLight: "borderLight",
                             MobileCreativeNegativeButtonDefaultBorderColorDark: "borderDark",
                             MobileCreativeNegativeButtonDefaultBackgroundColorLight: "backLight",
                             MobileCreativeNegativeButtonDefaultBackgroundColorDark: "backDark",

                             MobileCreativeNegativeButtonPressedFontFamily: "font",
                             MobileCreativeNegativeButtonPressedFontSize: "12",
                             MobileCreativeNegativeButtonPressedFontColorLight: "light",
                             MobileCreativeNegativeButtonPressedFontColorDark: "dark",
                             MobileCreativeNegativeButtonPressedCornerRadius: "5",
                             MobileCreativeNegativeButtonPressedBorderThickness: "4",
                             MobileCreativeNegativeButtonPressedBorderColorLight: "borderLight",
                             MobileCreativeNegativeButtonPressedBorderColorDark: "borderDark",
                             MobileCreativeNegativeButtonPressedBackgroundColorLight: "backLight",
                             MobileCreativeNegativeButtonPressedBackgroundColorDark: "backDark"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)
        let positiveButtonStyle = ButtonStylesViewData(defaultStyle:
                                                        ButtonStyleViewData(textStyleViewData:
                                                                                TextStyleViewData(fontFamily: "font",
                                                                                                  fontWeight: .semiBold,
                                                                                                  fontSize: 12,
                                                                                                  fontColor: [0: "light", 1: "dark"],
                                                                                                  backgroundColor: [0: "backLight", 1: "backDark"],
                                                                                                  alignment: .center, lineSpacing: 1),
                                                                            cornerRadius: 5, borderThickness: 4, borderColor: [0: "borderLight", 1: "borderDark"]),
                                                       pressedStyle:
                                                        ButtonStyleViewData(textStyleViewData:
                                                                                TextStyleViewData(fontFamily: "font", fontSize: 12, fontColor: [0: "light", 1: "dark"],
                                                                                                  backgroundColor: [0: "backLight", 1: "backDark"],
                                                                                                  alignment: .center, lineSpacing: 1),
                                                                            cornerRadius: 5, borderThickness: 4, borderColor: [0: "borderLight", 1: "borderDark"]))
        XCTAssertEqual(positiveButtonStyle, try transformer.transformNegativeButtonStyles())

    }

    func test_buttonStyle_invalid_negativeButtonStyle() throws {
        let configurables = [MobileCreativeNegativeButtonDefaultFontFamily: "font"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError(try transformer.transformNegativeButtonStyles()) { error in
            XCTAssertEqual(error as! TransformerError,
                           TransformerError.KeyIsMissing(key: MobileCreativeNegativeButtonDefaultFontSize))
        }

    }

    // MARK: transform disclaimer
    func test_disclaimer_valid() throws {
        let configurables = [MobileCreativeDisclaimerFontFamily: "font",
                             MobileCreativeDisclaimerFontSize: "12",
                             MobileCreativeDisclaimerFontColorLight: "light",
                             MobileCreativeDisclaimerFontColorDark: "dark",
                             MobileCreativeDisclaimerLineSpacing: "4",
                             MobileCreativeDisclaimerBackgroundColorLight: "backLight",
                             MobileCreativeDisclaimerBackgroundColorDark: "backDark",
                             MobileCreativeDisclaimerMargin: "12 0 12 0"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let disclaimerText = TextViewData(text: "disclaimer",
                                          textStyleViewData:
                                            TextStyleViewData(fontFamily: "font",
                                                              fontSize: 12,
                                                              fontColor: [0: "light", 1: "dark"],
                                                              backgroundColor: [0: "backLight", 1: "backDark"],
                                                              lineSpacing: 4))
        let disclaimerMargin = FrameAlignment(top: 12, right: 0, bottom: 12, left: 0)
        let disclaimer = DisclaimerViewData(textViewData: disclaimerText,
                                            margin: disclaimerMargin)

        XCTAssertEqual(disclaimer, try transformer.transformDisclaimer(from: [CreativeDisclaimer: "disclaimer"]))

    }

    func test_disclaimer_empty() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)

        let nilDisclaimer = DisclaimerViewData(textViewData: nil, margin: nil)

        XCTAssertEqual(nilDisclaimer, try transformer.transformDisclaimer(from: nil))
    }

    // MARK: transform page indicator
    func test_pageIndicator_valid_pos1() throws {
        let configurables = [MobilePlacementPageIndicatorStartingPosition: "Position1",
                                         MobilePlacementPageIndicatorType: "circleWithText",
                               MobilePlacementPageIndicatorSeenFontFamily: "font",
                               MobilePlacementPageIndicatorSeenFontWeight: "semibold",
                                 MobilePlacementPageIndicatorSeenFontSize: "12",
                           MobilePlacementPageIndicatorSeenFontColorLight: "light",
                            MobilePlacementPageIndicatorSeenFontColorDark: "dark",
                             MobilePlacementPageIndicatorUnseenFontFamily: "font",
                             MobilePlacementPageIndicatorUnseenFontWeight: "extrabold",
                               MobilePlacementPageIndicatorUnseenFontSize: "12",
                         MobilePlacementPageIndicatorUnseenFontColorLight: "light",
                          MobilePlacementPageIndicatorUnseenFontColorDark: "dark",
                               MobilePlacementPageIndicatorSeenColorLight: "lightSeen",
                                MobilePlacementPageIndicatorSeenColorDark: "darkSeen",
                             MobilePlacementPageIndicatorUnseenColorLight: "lightUnSeen",
                              MobilePlacementPageIndicatorUnseenColorDark: "darkUnSeen",
                                      MobilePlacementPageIndicatorPadding: "10",
                                     MobilePlacementPageIndicatorDiameter: "30"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let pageIndicator = PageIndicatorViewData(type: .circleWithText,
                                                  seenItems: 1, unseenItems: 3,
                                                  backgroundSeen: [0: "lightSeen", 1: "darkSeen"],
                                                  backgroundUnseen: [0: "lightUnSeen", 1: "darkUnSeen"],
                                                  textViewDataSeen:
                                                    TextStyleViewData(fontFamily: "font",
                                                                      fontWeight: .semiBold,
                                                                      fontSize: 12,
                                                                      fontColor: [0: "light", 1: "dark"],
                                                                      backgroundColor: nil),
                                                  textViewDataUnseen:
                                                    TextStyleViewData(fontFamily: "font",
                                                                      fontWeight: .extraBold,
                                                                      fontSize: 12,
                                                                      fontColor: [0: "light", 1: "dark"],
                                                                      backgroundColor: nil),
                                                  paddingSize: 10,
                                                  diameter: 30,
                                                  startIndex: 1,
                                                  location: .beforeOffer,
                                                  dashesWidth: 32,
                                                  dashesHeight: 4,
                                                  margin: nil,
                                                  textBasedIndicatorViewData: nil)

        XCTAssertEqual(pageIndicator, try
                       transformer.transformPageIndicator(validIndex: 0, totalValidOffers: 4))
    }

    func test_pageIndicator_valid_pos2plus() throws {
        let configurables = [MobilePlacementPageIndicatorStartingPosition: "Position2+",
                                         MobilePlacementPageIndicatorType: "circleWithText",
                               MobilePlacementPageIndicatorSeenFontFamily: "font",
                                 MobilePlacementPageIndicatorSeenFontSize: "12",
                           MobilePlacementPageIndicatorSeenFontColorLight: "light",
                            MobilePlacementPageIndicatorSeenFontColorDark: "dark",
                             MobilePlacementPageIndicatorUnseenFontFamily: "font",
                               MobilePlacementPageIndicatorUnseenFontSize: "12",
                         MobilePlacementPageIndicatorUnseenFontColorLight: "light",
                          MobilePlacementPageIndicatorUnseenFontColorDark: "dark",
                               MobilePlacementPageIndicatorSeenColorLight: "lightSeen",
                                MobilePlacementPageIndicatorSeenColorDark: "darkSeen",
                             MobilePlacementPageIndicatorUnseenColorLight: "lightUnSeen",
                             MobilePlacementPageIndicatorUnseenColorDark: "darkUnSeen",
                             MobilePlacementPageIndicatorPadding: "10",
                             MobilePlacementPageIndicatorDiameter: "30",
                             MobilePlacementPageIndicatorStartNumberCounter: "2",
                             MobilePlacementPageIndicatorMargin: "10 20 30 40"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let pageIndicator = PageIndicatorViewData(type: .circleWithText,
                                                  seenItems: 1, unseenItems: 2,
                                                  backgroundSeen: [0: "lightSeen", 1: "darkSeen"],
                                                  backgroundUnseen: [0: "lightUnSeen", 1: "darkUnSeen"],
                                                  textViewDataSeen:
                                                    TextStyleViewData(fontFamily: "font",
                                                                      fontSize: 12,
                                                                      fontColor: [0: "light", 1: "dark"],
                                                                      backgroundColor: nil),
                                                  textViewDataUnseen:
                                                    TextStyleViewData(fontFamily: "font",
                                                                      fontSize: 12,
                                                                      fontColor: [0: "light", 1: "dark"],
                                                                      backgroundColor: nil),
                                                  paddingSize: 10,
                                                  diameter: 30,
                                                  startIndex: 2,
                                                  location: .beforeOffer,
                                                  dashesWidth: 32,
                                                  dashesHeight: 4,
                                                  margin: FrameAlignment(top: 10,
                                                                         right: 20,
                                                                         bottom: 30,
                                                                         left: 40),
                                                  textBasedIndicatorViewData: nil)

        XCTAssertEqual(pageIndicator, try
                       transformer.transformPageIndicator(validIndex: 1, totalValidOffers: 4))
    }

    // the number of seen indicators increases if countPos1 is true
    func test_pageIndicator_valid_pos2plus_countPos1_true() throws {
        let configurables = [MobilePlacementPageIndicatorStartingPosition: "Position2+",
                                         MobilePlacementPageIndicatorType: "circleWithText",
                               MobilePlacementPageIndicatorSeenFontFamily: "font",
                                 MobilePlacementPageIndicatorSeenFontSize: "12",
                           MobilePlacementPageIndicatorSeenFontColorLight: "light",
                            MobilePlacementPageIndicatorSeenFontColorDark: "dark",
                             MobilePlacementPageIndicatorUnseenFontFamily: "font",
                               MobilePlacementPageIndicatorUnseenFontSize: "12",
                         MobilePlacementPageIndicatorUnseenFontColorLight: "light",
                          MobilePlacementPageIndicatorUnseenFontColorDark: "dark",
                               MobilePlacementPageIndicatorSeenColorLight: "lightSeen",
                                MobilePlacementPageIndicatorSeenColorDark: "darkSeen",
                             MobilePlacementPageIndicatorUnseenColorLight: "lightUnSeen",
                             MobilePlacementPageIndicatorUnseenColorDark: "darkUnSeen",
                             MobilePlacementPageIndicatorPadding: "10",
                             MobilePlacementPageIndicatorDiameter: "30",
                             MobilePlacementPageIndicatorStartNumberCounter: "2",
                             MobilePlacementPageIndicatorCountPos1: "true",
                             MobilePlacementPageIndicatorMargin: "10 20 30 40"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let pageIndicator = PageIndicatorViewData(type: .circleWithText,
                                                  seenItems: 2, unseenItems: 2,
                                                  backgroundSeen: [0: "lightSeen", 1: "darkSeen"],
                                                  backgroundUnseen: [0: "lightUnSeen", 1: "darkUnSeen"],
                                                  textViewDataSeen:
                                                    TextStyleViewData(fontFamily: "font",
                                                                      fontSize: 12,
                                                                      fontColor: [0: "light", 1: "dark"],
                                                                      backgroundColor: nil),
                                                  textViewDataUnseen:
                                                    TextStyleViewData(fontFamily: "font",
                                                                      fontSize: 12,
                                                                      fontColor: [0: "light", 1: "dark"],
                                                                      backgroundColor: nil),
                                                  paddingSize: 10,
                                                  diameter: 30,
                                                  startIndex: 2,
                                                  location: .beforeOffer,
                                                  dashesWidth: 32,
                                                  dashesHeight: 4,
                                                  margin: FrameAlignment(top: 10,
                                                                         right: 20,
                                                                         bottom: 30,
                                                                         left: 40),
                                                  textBasedIndicatorViewData: nil)

        XCTAssertEqual(pageIndicator, try
                       transformer.transformPageIndicator(validIndex: 1, totalValidOffers: 4))
    }

    // the number of seen indicators remains the same if countPos1 is false
    func test_pageIndicator_valid_pos2plus_countPos1_false() throws {
        let configurables = [MobilePlacementPageIndicatorStartingPosition: "Position2+",
                                         MobilePlacementPageIndicatorType: "circleWithText",
                               MobilePlacementPageIndicatorSeenFontFamily: "font",
                                 MobilePlacementPageIndicatorSeenFontSize: "12",
                           MobilePlacementPageIndicatorSeenFontColorLight: "light",
                            MobilePlacementPageIndicatorSeenFontColorDark: "dark",
                             MobilePlacementPageIndicatorUnseenFontFamily: "font",
                               MobilePlacementPageIndicatorUnseenFontSize: "12",
                         MobilePlacementPageIndicatorUnseenFontColorLight: "light",
                          MobilePlacementPageIndicatorUnseenFontColorDark: "dark",
                               MobilePlacementPageIndicatorSeenColorLight: "lightSeen",
                                MobilePlacementPageIndicatorSeenColorDark: "darkSeen",
                             MobilePlacementPageIndicatorUnseenColorLight: "lightUnSeen",
                             MobilePlacementPageIndicatorUnseenColorDark: "darkUnSeen",
                             MobilePlacementPageIndicatorPadding: "10",
                             MobilePlacementPageIndicatorDiameter: "30",
                             MobilePlacementPageIndicatorStartNumberCounter: "2",
                             MobilePlacementPageIndicatorCountPos1: "false",
                             MobilePlacementPageIndicatorMargin: "10 20 30 40"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let pageIndicator = PageIndicatorViewData(type: .circleWithText,
                                                  seenItems: 1, unseenItems: 2,
                                                  backgroundSeen: [0: "lightSeen", 1: "darkSeen"],
                                                  backgroundUnseen: [0: "lightUnSeen", 1: "darkUnSeen"],
                                                  textViewDataSeen:
                                                    TextStyleViewData(fontFamily: "font",
                                                                      fontSize: 12,
                                                                      fontColor: [0: "light", 1: "dark"],
                                                                      backgroundColor: nil),
                                                  textViewDataUnseen:
                                                    TextStyleViewData(fontFamily: "font",
                                                                      fontSize: 12,
                                                                      fontColor: [0: "light", 1: "dark"],
                                                                      backgroundColor: nil),
                                                  paddingSize: 10,
                                                  diameter: 30,
                                                  startIndex: 2,
                                                  location: .beforeOffer,
                                                  dashesWidth: 32,
                                                  dashesHeight: 4,
                                                  margin: FrameAlignment(top: 10,
                                                                         right: 20,
                                                                         bottom: 30,
                                                                         left: 40),
                                                  textBasedIndicatorViewData: nil)

        XCTAssertEqual(pageIndicator, try
                       transformer.transformPageIndicator(validIndex: 1, totalValidOffers: 4))
    }

    func test_pageIndicator_valid_dashes_default() throws {
        let configurables = [MobilePlacementPageIndicatorStartingPosition: "Position2+",
                                         MobilePlacementPageIndicatorType: "dashes",
                               MobilePlacementPageIndicatorSeenFontFamily: "font",
                                 MobilePlacementPageIndicatorSeenFontSize: "12",
                           MobilePlacementPageIndicatorSeenFontColorLight: "light",
                            MobilePlacementPageIndicatorSeenFontColorDark: "dark",
                             MobilePlacementPageIndicatorUnseenFontFamily: "font",
                               MobilePlacementPageIndicatorUnseenFontSize: "12",
                         MobilePlacementPageIndicatorUnseenFontColorLight: "light",
                          MobilePlacementPageIndicatorUnseenFontColorDark: "dark",
                               MobilePlacementPageIndicatorSeenColorLight: "lightSeen",
                                MobilePlacementPageIndicatorSeenColorDark: "darkSeen",
                             MobilePlacementPageIndicatorUnseenColorLight: "lightUnSeen",
                             MobilePlacementPageIndicatorUnseenColorDark: "darkUnSeen",
                             MobilePlacementPageIndicatorPadding: "10",
                             MobilePlacementPageIndicatorDiameter: "30",
                             MobilePlacementPageIndicatorStartNumberCounter: "2"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let pageIndicator = PageIndicatorViewData(type: .dashes,
                                                  seenItems: 1, unseenItems: 2,
                                                  backgroundSeen: [0: "lightSeen", 1: "darkSeen"],
                                                  backgroundUnseen: [0: "lightUnSeen", 1: "darkUnSeen"],
                                                  textViewDataSeen: nil,
                                                  textViewDataUnseen: nil,
                                                  paddingSize: 10,
                                                  diameter: 30,
                                                  startIndex: 2,
                                                  location: .beforeOffer,
                                                  dashesWidth: 32,
                                                  dashesHeight: 4,
                                                  margin: nil,
                                                  textBasedIndicatorViewData: nil)

        XCTAssertEqual(pageIndicator, try
                       transformer.transformPageIndicator(validIndex: 1, totalValidOffers: 4))
    }

    func test_pageIndicator_valid_dashes_width_height() throws {
        let configurables = [MobilePlacementPageIndicatorStartingPosition: "Position2+",
                                         MobilePlacementPageIndicatorType: "dashes",
                               MobilePlacementPageIndicatorSeenFontFamily: "font",
                                 MobilePlacementPageIndicatorSeenFontSize: "12",
                           MobilePlacementPageIndicatorSeenFontColorLight: "light",
                            MobilePlacementPageIndicatorSeenFontColorDark: "dark",
                             MobilePlacementPageIndicatorUnseenFontFamily: "font",
                               MobilePlacementPageIndicatorUnseenFontSize: "12",
                         MobilePlacementPageIndicatorUnseenFontColorLight: "light",
                          MobilePlacementPageIndicatorUnseenFontColorDark: "dark",
                               MobilePlacementPageIndicatorSeenColorLight: "lightSeen",
                                MobilePlacementPageIndicatorSeenColorDark: "darkSeen",
                             MobilePlacementPageIndicatorUnseenColorLight: "lightUnSeen",
                             MobilePlacementPageIndicatorUnseenColorDark: "darkUnSeen",
                             MobilePlacementPageIndicatorPadding: "10",
                             MobilePlacementPageIndicatorDiameter: "30",
                             MobilePlacementPageIndicatorStartNumberCounter: "2",
                             MobilePlacementPageIndicatorDashesWidth: "20",
                             MobilePlacementPageIndicatorDashesHeight: "5",
                             MobilePlacementPageIndicatorMargin: "10 20 30 40"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let pageIndicator = PageIndicatorViewData(type: .dashes,
                                                  seenItems: 1, unseenItems: 2,
                                                  backgroundSeen: [0: "lightSeen", 1: "darkSeen"],
                                                  backgroundUnseen: [0: "lightUnSeen", 1: "darkUnSeen"],
                                                  textViewDataSeen: nil,
                                                  textViewDataUnseen: nil,
                                                  paddingSize: 10,
                                                  diameter: 30,
                                                  startIndex: 2,
                                                  location: .beforeOffer,
                                                  dashesWidth: 20,
                                                  dashesHeight: 5,
                                                  margin: FrameAlignment(top: 10,
                                                                         right: 20,
                                                                         bottom: 30,
                                                                         left: 40),
                                                  textBasedIndicatorViewData: nil)

        XCTAssertEqual(pageIndicator, try
                       transformer.transformPageIndicator(validIndex: 1, totalValidOffers: 4))
    }


    func test_pageIndicator_inValid_missingKey() throws {
        let configurables = [MobilePlacementPageIndicatorStartingPosition: "Position2+",
                                         MobilePlacementPageIndicatorType: "circleWithText",
                               MobilePlacementPageIndicatorSeenFontFamily: "font",
                                 MobilePlacementPageIndicatorSeenFontSize: "12",
                           MobilePlacementPageIndicatorSeenFontColorLight: "light",
                            MobilePlacementPageIndicatorSeenFontColorDark: "dark",
                             MobilePlacementPageIndicatorUnseenFontFamily: "font",
                               MobilePlacementPageIndicatorUnseenFontSize: "12",
                         MobilePlacementPageIndicatorUnseenFontColorLight: "light",
                          MobilePlacementPageIndicatorUnseenFontColorDark: "dark",
                               MobilePlacementPageIndicatorSeenColorLight: "lightSeen",
                                MobilePlacementPageIndicatorSeenColorDark: "darkSeen",
                             //                             MobilePlacementPageIndicatorUnseenColorLight: "lightUnSeen",
            MobilePlacementPageIndicatorUnseenColorDark: "darkUnSeen",
            MobilePlacementPageIndicatorPadding: "10",
            MobilePlacementPageIndicatorDiameter: "30"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        XCTAssertThrowsError( try transformer.transformPageIndicator(validIndex: 1, totalValidOffers: 4)) { error in
            XCTAssertEqual(error as! TransformerError,
                           TransformerError.KeyIsMissing(key: MobilePlacementPageIndicatorUnseenColorLight))
        }
    }

    // MARK: transform before offer
    func test_beforeOffer_valid_pos1() throws {
        let configurables = [MobilePlacementBeforeOfferCopyContent: "before offer",
                             MobilePlacementBeforeOfferCopyFontFamily: "font",
                             MobilePlacementBeforeOfferCopyFontWeight: "ultralight",
                             MobilePlacementBeforeOfferCopyFontSize: "12",
                             MobilePlacementBeforeOfferCopyFontColorLight: "light",
                             MobilePlacementBeforeOfferCopyFontColorDark: "dark",
                             MobilePlacementBeforeOfferCopyAlignment: "center",
                             MobilePlacementBeforeOfferCopyLineSpacing: "4",
                             MobilePlacementBeforeOfferShowPosition1: "true",
                             MobilePlacementBeforeOfferMargin: "0 0 15 0"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let beforeOffer = TextViewData(text: "before offer",
                                       textStyleViewData:
                                        TextStyleViewData(fontFamily: "font",
                                                          fontWeight: .ultraLight,
                                                          fontSize: 12,
                                                          fontColor: [0: "light", 1: "dark"],
                                                          backgroundColor: nil,
                                                          alignment: .center,
                                                          lineSpacing: 4),
                                       padding: FrameAlignment(top: 0, right: 0, bottom: 15, left: 0))

        XCTAssertEqual(beforeOffer, try transformer.transformBeforeOffer(validIndex: 0))
    }

    func test_beforeOffer_valid_pos2plus() throws {
        let configurables = [MobilePlacementBeforeOfferCopyContent: "before offer",
                             MobilePlacementBeforeOfferCopyFontFamily: "font",
                             MobilePlacementBeforeOfferCopyFontSize: "12",
                             MobilePlacementBeforeOfferCopyFontColorLight: "light",
                             MobilePlacementBeforeOfferCopyFontColorDark: "dark",
                             MobilePlacementBeforeOfferCopyAlignment: "center",
                             MobilePlacementBeforeOfferCopyLineSpacing: "4",
                             MobilePlacementBeforeOfferShowPosition2Plus: "true"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let beforeOffer = TextViewData(text: "before offer",
                                       textStyleViewData:
            TextStyleViewData(fontFamily: "font",
                              fontSize: 12,
                              fontColor: [0: "light", 1: "dark"],
                              backgroundColor: nil,
                              alignment: .center,
                              lineSpacing: 4))

        XCTAssertEqual(beforeOffer, try transformer.transformBeforeOffer(validIndex: 1))
    }

    func test_beforeOffer_empty_pos1() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)

        XCTAssertNil(try transformer.transformBeforeOffer(validIndex: 0))
    }

    func test_beforeOffer_empty_pos2plus() throws {
        let configurables = [MobilePlacementBeforeOfferCopyContent: "before offer",
                             MobilePlacementBeforeOfferCopyFontFamily: "font",
                             MobilePlacementBeforeOfferCopyFontSize: "12",
                             MobilePlacementBeforeOfferCopyFontColorLight: "light",
                             MobilePlacementBeforeOfferCopyFontColorDark: "dark",
                             MobilePlacementBeforeOfferCopyAlignment: "center",
                             MobilePlacementBeforeOfferCopyLineSpacing: "4",
                             MobilePlacementBeforeOfferShowPosition1: "true"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        XCTAssertNil(try transformer.transformBeforeOffer(validIndex: 1))
    }

    // MARK: transform confirmation message
    func test_confirmationMessage_valid_pos1() throws {
        let configurables = [MobileCreativeConfirmationMessageFontFamily: "font",
                             MobileCreativeConfirmationMessageFontSize: "12",
                             MobileCreativeConfirmationMessageFontColorLight: "light",
                             MobileCreativeConfirmationMessageFontColorDark: "dark",
                             MobileCreativeConfirmationMessageLineSpacing: "4",
                             MobileCreativeConfirmationMessageShowPosition1: "true",
                             MobileCreativeConfirmationMessageMargin: "0 0 15 0"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let textViewData = TextViewData(text: "ConfirmationMessage",
                                        textStyleViewData:
                                            TextStyleViewData(fontFamily: "font",
                                                              fontSize: 12,
                                                              fontColor: [0: "light", 1: "dark"],
                                                              backgroundColor: nil,
                                                              lineSpacing: 4))
        let margin = FrameAlignment(top: 0, right: 0, bottom: 15, left: 0)
        let confirmationMessage = ConfirmationMessageViewData(textViewData: textViewData, margin: margin)

        XCTAssertEqual(confirmationMessage, try
                       transformer.transformConfirmationMessage(validIndex: 0,
                                                                from: [CreativeConfirmationMessage: "ConfirmationMessage"
                                                                      ]))
    }

    func test_confirmationMessage_valid_pos2plus() throws {
        let configurables = [MobileCreativeConfirmationMessageFontFamily: "font",
                             MobileCreativeConfirmationMessageFontSize: "12",
                             MobileCreativeConfirmationMessageFontColorLight: "light",
                             MobileCreativeConfirmationMessageFontColorDark: "dark",
                             MobileCreativeConfirmationMessageLineSpacing: "4",
                             MobileCreativeConfirmationMessageShowPosition2Plus: "true"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)
        let textViewData = TextViewData(text: "ConfirmationMessage",
                                        textStyleViewData:
                                            TextStyleViewData(fontFamily: "font",
                                                              fontSize: 12,
                                                              fontColor: [0: "light", 1: "dark"],
                                                              backgroundColor: nil,
                                                              lineSpacing: 4))
        let confirmationMessage = ConfirmationMessageViewData(textViewData: textViewData)

        XCTAssertEqual(confirmationMessage, try
                       transformer.transformConfirmationMessage(validIndex: 1,
                                                                from: [CreativeConfirmationMessage: "ConfirmationMessage"
                                                                      ]))
    }

    func test_confirmationMessage_empty_pos1() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)

        XCTAssertNil(try transformer.transformConfirmationMessage(validIndex: 0, from: nil)?.textViewData)
    }

    func test_confirmationMessage_empty_pos2plus() throws {
        let configurables = [MobileCreativeConfirmationMessageFontFamily: "font",
                             MobileCreativeConfirmationMessageFontSize: "12",
                             MobileCreativeConfirmationMessageFontColorLight: "light",
                             MobileCreativeConfirmationMessageFontColorDark: "dark",
                             MobileCreativeConfirmationMessageLineSpacing: "4",
                             MobileCreativeConfirmationMessageShowPosition1: "true"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)
        XCTAssertNil( try
                      transformer.transformConfirmationMessage(validIndex: 1,
                                                               from: [CreativeConfirmationMessage: "ConfirmationMessage"
                                                                     ])?.textViewData)
    }

    // MARK: trnaform creative image show
    func test_creative_image_show_empty_pos1() throws {
        let configurables = [MobileCreativeImageShowPosition1:"false"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        XCTAssertNil( try transformer.transformCreativeImage(validIndex: 0, from: [MobileCreativeImageSrc : "https://example.com/image.png"]))
    }

    func test_creative_image_show_vaild_pos1() throws {
        let configurables = [MobileCreativeImageShowPosition1:"true"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)
        let url = "https://example.com/image.png"

        XCTAssertEqual(url, try transformer.transformCreativeImage(validIndex: 0, from: [MobileCreativeImageSrc : url]))
    }

    func test_creative_image_show_empty_pos2() throws {
         let configurables = [MobileCreativeImageShowPosition2Plus:"false"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        XCTAssertNil( try transformer.transformCreativeImage(validIndex: 1, from: [MobileCreativeImageSrc : "https://example.com/image.png"]))
    }

    func test_creative_image_show_vaild_pos2() throws {
        let configurables = [MobileCreativeImageShowPosition2Plus:"true"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)
        let url = "https://example.com/image.png"

        XCTAssertEqual(url, try transformer.transformCreativeImage(validIndex: 1, from: [MobileCreativeImageSrc : url]))
    }

    func test_creative_image_show_pos1_and_pos2() throws {
        let placement = getSamplePlacement([:] as? [String : String])
        let transformer = getPlacementTransformer(placement)
        let url = "https://example.com/image.png"

         XCTAssertEqual(url, try transformer.transformCreativeImage(validIndex: 0, from: [MobileCreativeImageSrc : url]))
        XCTAssertEqual(url, try transformer.transformCreativeImage(validIndex: 1, from: [MobileCreativeImageSrc : url]))
    }

    func test_creative_image_visibility_hidden() throws {
        let configurables = [MobileCreativeImageShowPosition1:"true",
                         MobileCreativeImageShowPosition2Plus:"true",
                                MobileCreativeImageVisibility: "Hidden"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)
        let url = "https://example.com/image.png"

        XCTAssertNil( try transformer.transformCreativeImage(validIndex: 0, from: [MobileCreativeImageSrc : url]))
        XCTAssertNil( try transformer.transformCreativeImage(validIndex: 1, from: [MobileCreativeImageSrc : url]))
    }

    // MARK: transform after offer
    func test_afterOffer_valid_position1() throws {
        let configurables = [MobilePlacementAfterOfferCopyPosition1Content: "after offer position1",
                             MobilePlacementAfterOfferShowPosition1: "true",
                             MobilePlacementAfterOfferCopyFontFamily: "font",
                             MobilePlacementAfterOfferCopyFontWeight: "semibold",
                             MobilePlacementAfterOfferCopyFontSize: "12",
                             MobilePlacementAfterOfferCopyFontColorLight: "light",
                             MobilePlacementAfterOfferCopyFontColorDark: "dark",
                             MobilePlacementAfterOfferCopyAlignment: "center",
                             MobilePlacementAfterOfferCopyLineSpacing: "4"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let afterOffer = TextViewData(text: "after offer position1",
                                      textStyleViewData:
            TextStyleViewData(fontFamily: "font",
                              fontWeight: .semiBold,
                              fontSize: 12,
                              fontColor: [0: "light", 1: "dark"],
                              backgroundColor: nil,
                              alignment: .center,
                              lineSpacing: 4))

        XCTAssertEqual(afterOffer, try transformer.transformAfterOffer(validIndex: 0))
    }

    func test_afterOffer_valid_position2_plus() throws {
        let configurables = [MobilePlacementAfterOfferCopyPosition1Content: "after offer position1",
                             MobilePlacementAfterOfferCopyPosition2PlusContent: "after offer position2+",
                             MobilePlacementAfterOfferShowPosition2Plus: "true",
                             MobilePlacementAfterOfferCopyFontFamily: "font",
                             MobilePlacementAfterOfferCopyFontSize: "12",
                             MobilePlacementAfterOfferCopyFontColorLight: "light",
                             MobilePlacementAfterOfferCopyFontColorDark: "dark",
                             MobilePlacementAfterOfferCopyAlignment: "center",
                             MobilePlacementAfterOfferCopyLineSpacing: "4",
                             MobilePlacementAfterOfferPadding: "10 20 30 40"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let afterOffer = TextViewData(text: "after offer position2+",
                                      textStyleViewData:
            TextStyleViewData(fontFamily: "font",
                              fontSize: 12,
                              fontColor: [0: "light", 1: "dark"],
                              backgroundColor: nil,
                              alignment: .center,
                              lineSpacing: 4), padding: FrameAlignment(top: 10, right: 20, bottom: 30, left: 40))

        XCTAssertEqual(afterOffer, try transformer.transformAfterOffer(validIndex: 1))
    }


    func test_afterOffer_empty() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)

        XCTAssertNil(try transformer.transformAfterOffer(validIndex: 0))
    }

    // MARK: transform after offer
    func test_endMessage_valid() throws {
        let configurables = [MobilePlacementEndMessageTitleContent: "title",
                          MobilePlacementEndMessageTitleFontFamily: "font",
                          MobilePlacementEndMessageTitleFontWeight: "extrabold",
                            MobilePlacementEndMessageTitleFontSize: "12",
                      MobilePlacementEndMessageTitleFontColorLight: "light",
                       MobilePlacementEndMessageTitleFontColorDark: "dark",
                           MobilePlacementEndMessageTitleAlignment: "center",
                         MobilePlacementEndMessageTitleLineSpacing: "4",
                              MobilePlacementEndMessageBodyContent: "body",
                           MobilePlacementEndMessageBodyFontFamily: "font",
                           MobilePlacementEndMessageBodyFontWeight: "ultralight",
                             MobilePlacementEndMessageBodyFontSize: "12",
                             MobilePlacementEndMessageBodyFontColorLight: "light",
                             MobilePlacementEndMessageBodyFontColorDark: "dark",
                             MobilePlacementEndMessageBodyAlignment: "center",
                             MobilePlacementEndMessageBodyLineSpacing: "4"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let endMessage = EndMessageViewData(title:
                                                TextViewData(text: "title",
                                                             textStyleViewData:
                                                                TextStyleViewData(fontFamily: "font",
                                                                                  fontWeight: .extraBold,
                                                                                  fontSize: 12,
                                                                                  fontColor: [0: "light", 1: "dark"],
                                                                                  backgroundColor: nil,
                                                                                  alignment: .center,
                                                                                  lineSpacing: 4)),
                                            content:
            TextViewData(text: "body",
                         textStyleViewData:
                TextStyleViewData(fontFamily: "font",
                                  fontWeight: .ultraLight,
                                  fontSize: 12,
                                  fontColor: [0: "light", 1: "dark"],
                                  backgroundColor: nil,
                                  alignment: .center,
                                  lineSpacing: 4)))

        XCTAssertEqual(endMessage, try transformer.transformEndMessage())
    }

    // MARK: transform title
    func test_title_valid() throws {
        let configurables = [MobilePlacementTitleContent: "after offer",
                             MobilePlacementTitleFontFamily: "font",
                             MobilePlacementTitleFontWeight: "extrabold",
                             MobilePlacementTitleFontSize: "12",
                             MobilePlacementTitleFontColorLight: "light",
                             MobilePlacementTitleFontColorDark: "dark",
                             MobilePlacementTitleAlignment: "center",
                             MobilePlacementTitleLineSpacing: "4",
                             MobilePlacementTitleBackgroundColorLight: "backLight",
                             MobilePlacementTitleBackgroundColorDark: "backDark",
                             MobilePlacementTitleCloseButtonColorLight: "closeLight",
                             MobilePlacementTitleCloseButtonColorDark: "closeDark",
                             MobilePlacementTitleCloseButtonCircleColorLight: "closeCircleLight",
                             MobilePlacementTitleCloseButtonCircleColorDark: "closeCircleDark"]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let title = TitleViewData(textViewData:
                                    TextViewData(text: "after offer",
                                                 textStyleViewData:
                                                    TextStyleViewData(fontFamily: "font",
                                                                      fontWeight: .extraBold,
                                                                      fontSize: 12,
                                                                      fontColor: [0: "light", 1: "dark"],
                                                                      backgroundColor: [0: "backLight", 1: "backDark"],
                                                                      alignment: .center,
                                                                      lineSpacing: 4)),
                                  backgroundColor: [0: "backLight", 1: "backDark"],
                                  closeButtonColor: [0: "closeLight", 1: "closeDark"],
                                  closeButtonCircleColor: [0: "closeCircleLight", 1: "closeCircleDark"],
                                  closeButtonThinVariant: false)

        XCTAssertEqual(title, try transformer.transformTitleView())

    }

    // MARK: transform positive button
    func test_positive_button_empty() throws {
        let placement = getSamplePlacement(nil)
        let offer = Offer(campaignId: "",
                          creative: Creative(referralCreativeId: "",
                                             instanceGuid: "",
                                             copy: [:],
                                             responseOptions: [],
                                             creativeJWTToken: "creative-token"))
        let transformer = getPlacementTransformer(placement)

        XCTAssertThrowsError( try transformer.transferPositiveButton(offer: offer)) { error in
            XCTAssertEqual(error as! TransformerError,
                           TransformerError.KeyIsMissing(key: kPositiveButton))
        }
    }

    func test_positive_button_valid() throws {
        let placement = getSamplePlacement(nil)
        let responseOption = ResponseOption(id: "id",
                                            action: .url,
                                            instanceGuid: "instanceGuid",
                                            signalType: .signalResponse,
                                            shortLabel: "shortLabel",
                                            longLabel: "longLabel",
                                            shortSuccessLabel: "shortSuccessLabel",
                                            isPositive: true,
                                            url: "url",
                                            responseJWTToken: "response-jwt")
        let offer = Offer(campaignId: "",
                          creative: Creative(referralCreativeId: "",
                                             instanceGuid: "",
                                             copy: [:],
                                             responseOptions: [responseOption],
                                             creativeJWTToken: "creative-token"))
        let transformer = getPlacementTransformer(placement)

        let positiveButton = ButtonViewData(text: "shortLabel",
                                            instanceGuid: "instanceGuid",
                                            action: .url,
                                            url: "url", eventType: try transformer.getEventType(responseOption.signalType),
                                            actionInExternalBrowser: false,
                                            closeOnPress: false,
                                            responseJWTToken: "response-jwt")

        XCTAssertEqual(positiveButton, try transformer.transferPositiveButton(offer: offer))
    }

    func test_positive_button_valid_title_case() throws {
        let placement = getSamplePlacement([MobileCreativePositiveButtonTextCaseOption: "TitleCase"])
        let responseOption = ResponseOption(id: "id",
                                            action: .url,
                                            instanceGuid: "instanceGuid",
                                            signalType: .signalResponse,
                                            shortLabel: "shortLabel",
                                            longLabel: "longLabel",
                                            shortSuccessLabel: "shortSuccessLabel",
                                            isPositive: true,
                                            url: "url",
                                            responseJWTToken: "response-token")
        let offer = Offer(campaignId: "",
                          creative: Creative(referralCreativeId: "",
                                             instanceGuid: "",
                                             copy: [:],
                                             responseOptions: [responseOption],
                                             creativeJWTToken: "creative-token"))
        let transformer = getPlacementTransformer(placement)

        let positiveButton = ButtonViewData(text: "ShortLabel",
                                            instanceGuid: "instanceGuid",
                                            action: .url,
                                            url: "url",
                                            eventType: try transformer.getEventType(responseOption.signalType),
                                            actionInExternalBrowser: false,
                                            closeOnPress: false,
                                            responseJWTToken: "response-token")

        XCTAssertEqual(positiveButton, try transformer.transferPositiveButton(offer: offer))
    }

    func test_positive_button_valid_upper_case() throws {
        let placement = getSamplePlacement([MobileCreativePositiveButtonTextCaseOption: "UpperCase"])
        let responseOption = ResponseOption(id: "id",
                                            action: .url,
                                            instanceGuid: "instanceGuid",
                                            signalType: .signalResponse,
                                            shortLabel: "shortLabel",
                                            longLabel: "longLabel",
                                            shortSuccessLabel: "shortSuccessLabel",
                                            isPositive: true,
                                            url: "url",
                                            responseJWTToken: "response-token")
        let offer = Offer(campaignId: "",
                          creative: Creative(referralCreativeId: "",
                                             instanceGuid: "",
                                             copy: [:],
                                             responseOptions: [responseOption],
                                             creativeJWTToken: "creative-token"))
        let transformer = getPlacementTransformer(placement)

        let positiveButton = ButtonViewData(text: "SHORTLABEL",
                                            instanceGuid: "instanceGuid",
                                            action: .url,
                                            url: "url",
                                            eventType: try transformer.getEventType(responseOption.signalType),
                                            actionInExternalBrowser: false,
                                            closeOnPress: false,
                                            responseJWTToken: "response-token")

        XCTAssertEqual(positiveButton, try transformer.transferPositiveButton(offer: offer))
    }

    func test_positive_button_default_browser() throws {
        let placement = getSamplePlacement([MobilePlacementActionDefaultMobileBrowser: "true"])
        let responseOption = ResponseOption(id: "id",
                                            action: .url,
                                            instanceGuid: "instanceGuid",
                                            signalType: .signalResponse,
                                            shortLabel: "shortLabel",
                                            longLabel: "longLabel",
                                            shortSuccessLabel: "shortSuccessLabel",
                                            isPositive: true,
                                            url: "url",
                                            responseJWTToken: "response-token")
        let offer = Offer(campaignId: "",
                          creative: Creative(referralCreativeId: "",
                                             instanceGuid: "",
                                             copy: [:],
                                             responseOptions: [responseOption],
                                             creativeJWTToken: "creative-token"))
        let transformer = getPlacementTransformer(placement)

        let positiveButton = ButtonViewData(text: "shortLabel",
                                            instanceGuid: "instanceGuid",
                                            action: .url,
                                            url: "url",
                                            eventType: try transformer.getEventType(responseOption.signalType),
                                            actionInExternalBrowser: true,
                                            closeOnPress: false,
                                            responseJWTToken: "response-token")

        XCTAssertEqual(positiveButton, try transformer.transferPositiveButton(offer: offer))
    }

    func test_positive_button_invalid_missing_url() throws {
        let placement = getSamplePlacement(nil)
        let responseOption = ResponseOption(id: "id",
                                            action: .url,
                                            instanceGuid: "instanceGuid",
                                            signalType: .signalResponse,
                                            shortLabel: "shortLabel",
                                            longLabel: "longLabel",
                                            shortSuccessLabel: "shortSuccessLabel",
                                            isPositive: true,
                                            url: nil,
                                            responseJWTToken: "response-jwt")
        let offer = Offer(campaignId: "",
                          creative: Creative(referralCreativeId: "",
                                             instanceGuid: "",
                                             copy: [:],
                                             responseOptions: [responseOption],
                                             creativeJWTToken: "creative-token"))
        let transformer = getPlacementTransformer(placement)

        XCTAssertThrowsError( try transformer.transferPositiveButton(offer: offer)) { error in
            XCTAssertEqual(error as! TransformerError,
                           TransformerError.KeyIsMissing(key: kUrlMission))
        }
    }

    func test_positive_button_invalid_missing_response_action() throws {
        let placement = getSamplePlacement(nil)
        let responseOption = ResponseOption(id: "id",
                                            action: nil,
                                            instanceGuid: "instanceGuid",
                                            signalType: .signalResponse,
                                            shortLabel: "shortLabel",
                                            longLabel: "longLabel",
                                            shortSuccessLabel: "shortSuccessLabel",
                                            isPositive: true,
                                            url: nil,
                                            responseJWTToken: "response-jwt")
        let offer = Offer(campaignId: "",
                          creative: Creative(referralCreativeId: "",
                                             instanceGuid: "",
                                             copy: [:],
                                             responseOptions: [responseOption],
                                             creativeJWTToken: "creative-token"))
        let transformer = getPlacementTransformer(placement)

        XCTAssertThrowsError( try transformer.transferPositiveButton(offer: offer)) { error in
            XCTAssertEqual(error as! TransformerError,
                           TransformerError.KeyIsMissing(key: kResponseOptionAction))
        }
    }

    func test_positive_button_invalid_unknown_response_action() throws {
        let placement = getSamplePlacement(nil)
        let responseOption = ResponseOption(id: "id",
                                            action: .unknown,
                                            instanceGuid: "instanceGuid",
                                            signalType: .signalResponse,
                                            shortLabel: "shortLabel",
                                            longLabel: "longLabel",
                                            shortSuccessLabel: "shortSuccessLabel",
                                            isPositive: true,
                                            url: nil,
                                            responseJWTToken: "response-token")
        let offer = Offer(campaignId: "",
                          creative: Creative(referralCreativeId: "",
                                             instanceGuid: "",
                                             copy: [:],
                                             responseOptions: [responseOption],
                                             creativeJWTToken: "creative-token"))
        let transformer = getPlacementTransformer(placement)

        XCTAssertThrowsError( try transformer.transferPositiveButton(offer: offer)) { error in
            XCTAssertEqual(error as! TransformerError,
                           TransformerError.NotSupported(key: kResponseOptionAction))
        }
    }

    // MARK: transform negative button
    func test_negative_button_empty() throws {
        let placement = getSamplePlacement(nil)
        let offer = Offer(campaignId: "",
                          creative: Creative(referralCreativeId: "",
                                             instanceGuid: "",
                                             copy: [:],
                                             responseOptions: [],
                                             creativeJWTToken: "creative-token"))
        let transformer = getPlacementTransformer(placement)

        XCTAssertThrowsError( try transformer.transferNegativeButton(offer: offer)) { error in
            XCTAssertEqual(error as! TransformerError,
                           TransformerError.KeyIsMissing(key: kNegativeButton))
        }
    }

    func test_negative_button_valid() throws {
        let placement = getSamplePlacement(nil)
        let responseOption = ResponseOption(id: "id",
                                            action: nil,
                                            instanceGuid: "instanceGuid",
                                            signalType: .signalResponse,
                                            shortLabel: "shortLabel",
                                            longLabel: "longLabel",
                                            shortSuccessLabel: "shortSuccessLabel",
                                            isPositive: false,
                                            url: nil,
                                            responseJWTToken: "response-jwt")
        let offer = Offer(campaignId: "",
                          creative: Creative(referralCreativeId: "",
                                             instanceGuid: "",
                                             copy: [:],
                                             responseOptions: [responseOption],
                                             creativeJWTToken: "creative-token"))
        let transformer = getPlacementTransformer(placement)

        let positiveButton = ButtonViewData(text: "shortLabel",
                                            instanceGuid: "instanceGuid",
                                            action: nil,
                                            url: nil,
                                            eventType: try transformer.getEventType(responseOption.signalType),
                                            actionInExternalBrowser: false,
                                            closeOnPress: false,
                                            responseJWTToken: "response-jwt")

        XCTAssertEqual(positiveButton, try transformer.transferNegativeButton(offer: offer))
    }

    func test_negative_button_valid_title_case() throws {
        let placement = getSamplePlacement([MobileCreativeNegativeButtonTextCaseOption: "TitleCase"])
        let responseOption = ResponseOption(id: "id",
                                            action: nil,
                                            instanceGuid: "instanceGuid",
                                            signalType: .signalResponse,
                                            shortLabel: "short label",
                                            longLabel: "longLabel",
                                            shortSuccessLabel: "shortSuccessLabel",
                                            isPositive: false,
                                            url: nil,
                                            responseJWTToken: "response-jwt")
        let offer = Offer(campaignId: "",
                          creative: Creative(referralCreativeId: "",
                                             instanceGuid: "",
                                             copy: [:],
                                             responseOptions: [responseOption],
                                             creativeJWTToken: "creative-token"))
        let transformer = getPlacementTransformer(placement)

        let positiveButton = ButtonViewData(text: "Short Label",
                                            instanceGuid: "instanceGuid",
                                            action: nil,
                                            url: nil,
                                            eventType: try transformer.getEventType(responseOption.signalType),
                                            actionInExternalBrowser: false,
                                            closeOnPress: false,
                                            responseJWTToken: "response-jwt")

        XCTAssertEqual(positiveButton, try transformer.transferNegativeButton(offer: offer))
    }

    func test_negative_button_valid_upper_case() throws {
        let placement = getSamplePlacement([MobileCreativeNegativeButtonTextCaseOption: "UpperCase"])
        let responseOption = ResponseOption(id: "id",
                                            action: nil,
                                            instanceGuid: "instanceGuid",
                                            signalType: .signalResponse,
                                            shortLabel: "short label",
                                            longLabel: "longLabel",
                                            shortSuccessLabel: "shortSuccessLabel",
                                            isPositive: false,
                                            url: nil,
                                            responseJWTToken: "response-jwt")
        let offer = Offer(campaignId: "",
                          creative: Creative(referralCreativeId: "",
                                             instanceGuid: "",
                                             copy: [:],
                                             responseOptions: [responseOption],
                                             creativeJWTToken: "creative-token"))
        let transformer = getPlacementTransformer(placement)

        let positiveButton = ButtonViewData(text: "SHORT LABEL",
                                            instanceGuid: "instanceGuid",
                                            action: nil,
                                            url: nil,
                                            eventType: try transformer.getEventType(responseOption.signalType),
                                            actionInExternalBrowser: false,
                                            closeOnPress: false,
                                            responseJWTToken: "response-jwt")

        XCTAssertEqual(positiveButton, try transformer.transferNegativeButton(offer: offer))
    }

    // MARK: transform button text

    func test_transfer_Button_text_default_astyped() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)

        let transformedText = try transformer.transformButtonText(text: "Yes please", key: "TextCaseOption")

        XCTAssertEqual(transformedText, "Yes please")
    }

    func test_transfer_Button_text_astyped() throws {
        let placement = getSamplePlacement(["TextCaseOption": "AsTyped"])
        let transformer = getPlacementTransformer(placement)

        let transformedText = try transformer.transformButtonText(text: "Yes please", key: "TextCaseOption")

        XCTAssertEqual(transformedText, "Yes please")
    }

    func test_transfer_Button_text_title_case() throws {
        let placement = getSamplePlacement(["TextCaseOption": "TitleCase"])
        let transformer = getPlacementTransformer(placement)

        let transformedText = try transformer.transformButtonText(text: "yes please", key: "TextCaseOption")

        XCTAssertEqual(transformedText, "Yes Please")
    }

    func test_transfer_Button_text_upper_case() throws {
        let placement = getSamplePlacement(["TextCaseOption": "UpperCase"])
        let transformer = getPlacementTransformer(placement)

        let transformedText = try transformer.transformButtonText(text: "yes please", key: "TextCaseOption")

        XCTAssertEqual(transformedText, "YES PLEASE")
    }

    // MARK: TextCaseOption
    func test_get_text_case_option_astyped() throws {
        let placement = getSamplePlacement(["TextCaseOption": "AsTyped"])
        let transformer = getPlacementTransformer(placement)

        let textCaseOption = try transformer.getTextCaseOption("TextCaseOption")
        XCTAssertEqual(textCaseOption, TextCaseOptions.asTyped)
    }

    func test_get_text_case_option_title_case() throws {
        let placement = getSamplePlacement(["TextCaseOption": "TitleCase"])
        let transformer = getPlacementTransformer(placement)

        let textCaseOption = try transformer.getTextCaseOption("TextCaseOption")
        XCTAssertEqual(textCaseOption, TextCaseOptions.titleCase)
    }

    func test_get_text_case_option_upper_case() throws {
        let placement = getSamplePlacement(["TextCaseOption": "UpperCase"])
        let transformer = getPlacementTransformer(placement)

        let textCaseOption = try transformer.getTextCaseOption("TextCaseOption")
        XCTAssertEqual(textCaseOption, TextCaseOptions.uppercase)
    }

    func test_get_text_case_option_nil_return_default() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)

        let textCaseOption = try transformer.getTextCaseOption("TextCaseOption")
        XCTAssertEqual(textCaseOption, TextCaseOptions.asTyped)
    }

    func test_get_text_case_option_nil_change_default_upper_case() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)

        let textCaseOption = try transformer.getTextCaseOption("TextCaseOption", defaultCaseOption: .uppercase)
        XCTAssertEqual(textCaseOption, TextCaseOptions.uppercase)
    }

    func test_get_text_case_option_invalid_return_default() throws {
        let placement = getSamplePlacement(["TextCaseOption": "Something"])
        let transformer = getPlacementTransformer(placement)

        let textCaseOption = try transformer.getTextCaseOption("TextCaseOption")
        XCTAssertEqual(textCaseOption, TextCaseOptions.asTyped)
    }


    // MARK: transferCreativeTitleImageArrangement
    func test_transfer_creative_title_image_arrangement_end() throws {
        let placement = getSamplePlacement(["MobileSdk.Creative.TitleWithImage.Arrangement": "end"])
        let transformer = getPlacementTransformer(placement)
        let arrangement = try transformer.transferCreativeTitleImageArrangement()
        XCTAssertEqual(arrangement, .end)
    }

    func test_transfer_creative_title_image_arrangement_start() throws {
        let placement = getSamplePlacement(["MobileSdk.Creative.TitleWithImage.Arrangement": "start"])
        let transformer = getPlacementTransformer(placement)
        let arrangement = try transformer.transferCreativeTitleImageArrangement()
        XCTAssertEqual(arrangement, .start)
    }

    func test_transfer_creative_title_image_arrangement_bottom() throws {
        let placement = getSamplePlacement(["MobileSdk.Creative.TitleWithImage.Arrangement": "bottom"])
        let transformer = getPlacementTransformer(placement)
        let arrangement = try transformer.transferCreativeTitleImageArrangement()
        XCTAssertEqual(arrangement, .bottom)
    }

    func test_transfer_creative_title_image_arrangement_default() throws {
        let placement = getSamplePlacement([:])
        let transformer = getPlacementTransformer(placement)
        let arrangement = try transformer.transferCreativeTitleImageArrangement()
        XCTAssertEqual(arrangement, .bottom)
    }

    // MARK: transferCreativeTitleImageAlignment
    func test_transfer_creative_title_image_alignment_top() throws {
        let placement = getSamplePlacement(["MobileSdk.Creative.TitleWithImage.Alignment": "top"])
        let transformer = getPlacementTransformer(placement)
        let arrangement = try transformer.transferCreativeTitleImageAlignment()
        XCTAssertEqual(arrangement, .top)
    }

    func test_transfer_creative_title_image_alignment_center() throws {
        let placement = getSamplePlacement(["MobileSdk.Creative.TitleWithImage.Alignment": "center"])
        let transformer = getPlacementTransformer(placement)
        let arrangement = try transformer.transferCreativeTitleImageAlignment()
        XCTAssertEqual(arrangement, .center)
    }

    func test_transfer_creative_title_image_alignment_bottom() throws {
        let placement = getSamplePlacement(["MobileSdk.Creative.TitleWithImage.Alignment": "bottom"])
        let transformer = getPlacementTransformer(placement)
        let arrangement = try transformer.transferCreativeTitleImageAlignment()
        XCTAssertEqual(arrangement, .bottom)
    }

    func test_transfer_creative_title_image_alignment_default() throws {
        let placement = getSamplePlacement([:])
        let transformer = getPlacementTransformer(placement)
        let arrangement = try transformer.transferCreativeTitleImageAlignment()
        XCTAssertEqual(arrangement, .center)
    }

    // MARK: Action Default Mobile Browser
    func test_transform_action_default_mobile_browser() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)

        let defaultMobileBrowser = try transformer.transformActionDefaultMobileBrowser()
        XCTAssertFalse(defaultMobileBrowser)
    }

    func test_transform_action_default_mobile_browser_true() throws {
        let placement = getSamplePlacement([MobilePlacementActionDefaultMobileBrowser: "true"])
        let transformer = getPlacementTransformer(placement)

        let defaultMobileBrowser = try transformer.transformActionDefaultMobileBrowser()
        XCTAssertTrue(defaultMobileBrowser)
    }

    func test_transform_action_default_mobile_browser_false() throws {
        let placement = getSamplePlacement([MobilePlacementActionDefaultMobileBrowser: "false"])
        let transformer = getPlacementTransformer(placement)

        let defaultMobileBrowser = try transformer.transformActionDefaultMobileBrowser()
        XCTAssertFalse(defaultMobileBrowser)
    }

    // MARK: Event Type
    func test_get_event_type_valid() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)

        XCTAssertEqual(try transformer.getEventType(.signalResponse), EventType.SignalResponse)
    }

    func test_get_event_type_valid_gatedResponse() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)

        XCTAssertEqual(try transformer.getEventType(.signalGatedResponse), EventType.SignalGatedResponse)
    }

    func test_get_event_type_missed() throws {
         let placement = getSamplePlacement(nil)
         let transformer = getPlacementTransformer(placement)
         XCTAssertThrowsError( try transformer.getEventType(nil)) { error in
             XCTAssertEqual(error as! TransformerError,
                            TransformerError.KeyIsMissing(key: "SignalType"))
         }
     }

    func test_get_event_type_invalid() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError( try transformer.getEventType(.unknown)) { error in
            XCTAssertEqual(error as! TransformerError,
                           TransformerError.NotSupported(key: "SignalType"))
        }
    }

    // MARK: PageIndicatorLocation
    func test_get_page_indicator_location_valid_default() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)

        XCTAssertEqual(try transformer.getPageIndicatorLocation(""), .beforeOffer)
    }

    func test_get_page_indicator_location_valid_before_offer() throws {
        let placement = getSamplePlacement([MobilePlacementPageIndicatorLocation: "beforeOffer"])
        let transformer = getPlacementTransformer(placement)

        XCTAssertEqual(try transformer.getPageIndicatorLocation(MobilePlacementPageIndicatorLocation),
                       .beforeOffer)
    }

    func test_get_page_indicator_location_valid_after_offer() throws {
        let placement = getSamplePlacement([MobilePlacementPageIndicatorLocation: "afterOffer"])
        let transformer = getPlacementTransformer(placement)

        XCTAssertEqual(try transformer.getPageIndicatorLocation(MobilePlacementPageIndicatorLocation),
                       .afterOffer)
    }

    // MARK: PageIndicatorType
    func test_get_page_indicator_type_valid_default() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)

        XCTAssertEqual(try transformer.getPageIndicatorType(""), .circle)
    }

    func test_get_page_indicator_type_valid_circle() throws {
        let placement = getSamplePlacement([MobilePlacementPageIndicatorType: "circle"])
        let transformer = getPlacementTransformer(placement)

        XCTAssertEqual(try transformer.getPageIndicatorType(MobilePlacementPageIndicatorType),
                       .circle)
    }

    func test_get_page_indicator_type_valid_circle_with_text() throws {
        let placement = getSamplePlacement([MobilePlacementPageIndicatorType: "circleWithText"])
        let transformer = getPlacementTransformer(placement)

        XCTAssertEqual(try transformer.getPageIndicatorType(MobilePlacementPageIndicatorType),
                       .circleWithText)
    }

    func test_get_page_indicator_type_valid_dashes() throws {
        let placement = getSamplePlacement([MobilePlacementPageIndicatorType: "dashes"])
        let transformer = getPlacementTransformer(placement)

        XCTAssertEqual(try transformer.getPageIndicatorType(MobilePlacementPageIndicatorType),
                       .dashes)
    }

    // MARK: transform terms and conditions button
    func test_transform_terms_and_conditions() throws {
        let offerCopy = [CreativeTermsAndConditionsLink: "/url",
                         CreativeTermsAndConditionsTitle: "title"]

        let placement = getSamplePlacement([String:String]())
        let transformer = getPlacementTransformer(placement)

        let termsAndConditions = LinkViewData(text: "title",
                                              link: kBaseURL + "/url",
                                              textStyleViewData: transformer.getEmptyTextStyle(),
                                              underline: true)
        XCTAssertEqual(termsAndConditions, try transformer.transformOfferTermsAndConditions(from: offerCopy))
    }

    func test_transform_terms_and_conditions_nil_url() throws {
        let offerCopy = [CreativeTermsAndConditionsTitle: "title"]
        let placement = getSamplePlacement([String:String]())
        let transformer = getPlacementTransformer(placement)
        XCTAssertNil(try transformer.transformOfferTermsAndConditions(from: offerCopy))
    }

    func test_transform_terms_and_conditions_empty_url() throws {
        let offerCopy = [CreativeTermsAndConditionsLink: "",
                         CreativeTermsAndConditionsTitle: "title"]

        let placement = getSamplePlacement([String:String]())

        let transformer = getPlacementTransformer(placement)
        XCTAssertNil(try transformer.transformOfferTermsAndConditions(from: offerCopy))
    }

    func test_transform_terms_and_conditions_invalid_title() throws {
        let offerCopy = [CreativeTermsAndConditionsLink: "/url"]
        let placement = getSamplePlacement([String:String]())

        let transformer = getPlacementTransformer(placement)

        XCTAssertThrowsError( try transformer.transformOfferTermsAndConditions(from: offerCopy)) { error in
            XCTAssertEqual(error as! TransformerError,
                           TransformerError.KeyIsMissing(key: CreativeTermsAndConditionsTitle))
        }
    }

    // MARK: transform offer privacy policy button
    func test_transform_offer_privacy_policy() throws {
        let configurables = [MobileCreativePrivacyPolicyButtonUnderline: "false"]
        let offerCopy = [CreativePrivacyPolicyLink: "/url",
                         CreativePrivacyPolicyTitle: "title"]

        let placement = getSamplePlacement(configurables)

        let transformer = getPlacementTransformer(placement)

        let termsAndConditions = LinkViewData(text: "title",
                                              link: kBaseURL + "/url",
                                              textStyleViewData: transformer.getEmptyTextStyle(),
                                              underline: false)
        XCTAssertEqual(termsAndConditions, try transformer.transformOfferPrivacyPolicy(from: offerCopy))
    }

    func test_transform_offer_privacy_policy_nil_url() throws {
        let offerCopy = [CreativePrivacyPolicyTitle: "title"]

        let placement = getSamplePlacement([String:String]())

        let transformer = getPlacementTransformer(placement)

        XCTAssertNil(try transformer.transformOfferPrivacyPolicy(from: offerCopy))
    }

    func test_transform_offer_privacy_policy_empty_url() throws {
        let offerCopy = [CreativePrivacyPolicyLink: "",
                         CreativePrivacyPolicyTitle: "title"]

        let placement = getSamplePlacement([String:String]())

        let transformer = getPlacementTransformer(placement)

        XCTAssertNil(try transformer.transformOfferPrivacyPolicy(from: offerCopy))
    }

    func test_transform_offer_privacy_policy_invalid_title() throws {
        let offerCopy = [CreativePrivacyPolicyLink: "/url"]

        let placement = getSamplePlacement([String:String]())

        let transformer = getPlacementTransformer(placement)

        XCTAssertThrowsError( try transformer.transformOfferPrivacyPolicy(from: offerCopy)) { error in
            XCTAssertEqual(error as! TransformerError,
                           TransformerError.KeyIsMissing(key: CreativePrivacyPolicyTitle))
        }
    }

    // MARK: offer legal link
    func test_get_offer_legal_link_valid() throws {
        let url = "/url"
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)

        let convertedUrl = transformer.getOfferLegalLinks(link: url)

        XCTAssertEqual(convertedUrl, kBaseURL + url)
    }

    func test_get_offer_legal_link_valid_no_change() throws {
        let url = "http://www.rokt.com/url"
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)

        let convertedUrl = transformer.getOfferLegalLinks(link: url)

        XCTAssertEqual(convertedUrl, url)
    }


    func test_get_offer_legal_link_valid_no_change_Uppercase() throws {
        let url = "HTTPS://www.rokt.com/url"
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)

        let convertedUrl = transformer.getOfferLegalLinks(link: url)

        XCTAssertEqual(convertedUrl, url)
    }

    // MARK: transform response order
    func test_response_order_empty() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)

        XCTAssertTrue(try transformer.transformResponseOrder(), "Default should be True")
    }

    func test_response_order() throws {
        let configurables = [MobileCreativeResponseOrder: "positiveFirst"]
        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        XCTAssertTrue(try transformer.transformResponseOrder())
    }

    func test_response_order_false() throws {
        let configurables = [MobileCreativeResponseOrder: "negativeFirst"]
        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        XCTAssertFalse(try transformer.transformResponseOrder())
    }

    // MARK: transform response button display
    func test_response_button_display_empty() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)

        XCTAssertTrue(try transformer.transformButtobStacked(), "Default should be true")
    }

    func test_response_button_display_stacked() throws {
        let configurables = [MobileCreativeButtonDisplay: "Stacked"]
        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        XCTAssertTrue(try transformer.transformButtobStacked())
    }

    func test_response_button_display_UnStacked() throws {
        let configurables = [MobileCreativeButtonDisplay: "UnStacked"]
        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        XCTAssertFalse(try transformer.transformButtobStacked())
    }

    // MARK: transfer offer content + contentTitle
    
    // dummy configurables to pass transformOffer()
    var placeholderConfigurables = [MobileCreativeFontFamily: "HelveticaNeue",
                                      MobileCreativeFontSize: "11",
                                MobileCreativeFontColorLight: "#000000",
                                 MobileCreativeFontColorDark: "#ffffff",
                             MobileOfferBackgroundColorLight: "#ffffff",
                              MobileOfferBackgroundColorDark: "#ffffff"]

    func test_offer_without_title() throws {
            let placement = getSamplePlacement(placeholderConfigurables)
            let slot = Slot(instanceGuid: "",
                            offer: Offer(campaignId: "",
                                         creative:
                                            Creative(referralCreativeId: "",
                                                     instanceGuid: "",
                                                     copy: [MobileCreativeCopy: "Content"],
                                                     responseOptions: [],
                                                     creativeJWTToken: "creative-token")),
                                        slotJWTToken: "slot-jwt")

            let transformer = getPlacementTransformer(placement)

            let content = try? transformer.transformOfferContent(slot: slot)
            XCTAssertNil(content?.title)
            XCTAssertEqual(content?.body?.text, "Content")
        }

    func test_offer_without_title_and_content() throws {
        let placement = getSamplePlacement(nil)
        let slot = Slot(instanceGuid: "",
                        offer: Offer(campaignId: "",
                                     creative:
                                        Creative(referralCreativeId: "",
                                                 instanceGuid: "",
                                                 copy: [:],
                                                 responseOptions: [],
                                                 creativeJWTToken: "creative-token")),
                        slotJWTToken: "slot-jwt")

        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError( try transformer.transferOfferContentText(slot: slot, title: nil)) { error in
            XCTAssertEqual(error as! TransformerError,
                           TransformerError.KeyIsMissing(key: MobileCreativeCopy))
        }
    }

    func test_offer_with_title_with_default_configuration() throws {
            let placement = getSamplePlacement(placeholderConfigurables)
            let slot = Slot(instanceGuid: "",
                            offer: Offer(campaignId: "",
                                         creative:
                                            Creative(referralCreativeId: "",
                                                     instanceGuid: "",
                                                     copy: [MobileCreativeCopy: "Content",
                                                            MobileCreativeTitle: "Title"],
                                                     responseOptions: [],
                                                     creativeJWTToken: "creative-token")),
                            slotJWTToken: "slot-token")

            let transformer = getPlacementTransformer(placement)

            let content = try transformer.transformOfferContent(slot: slot)
            XCTAssertNil(content.title)
            XCTAssertEqual(content.body?.text, "Title Content")
        }

    func test_offer_with_title_with_default_configuration_ends_with_dot() throws {
        let placement = getSamplePlacement(placeholderConfigurables)
        let slot = Slot(instanceGuid: "",
                        offer: Offer(campaignId: "",
                                     creative:
                                        Creative(referralCreativeId: "",
                                                 instanceGuid: "",
                                                 copy: [MobileCreativeCopy: "Content",
                                                       MobileCreativeTitle: "Title."],
                                                 responseOptions: [],
                                                 creativeJWTToken: "creative-jwt")),
                        slotJWTToken: "slot-jwt")

        let transformer = getPlacementTransformer(placement)

        let content = try transformer.transformOfferContent(slot: slot)
        XCTAssertNil(content.title)
        XCTAssertEqual(content.body?.text, "Title. Content")
    }

    func test_offer_with_title_inline() throws {
        placeholderConfigurables[MobileCreativeInLineCopyWithHeading] = "true"
        let placement = getSamplePlacement(placeholderConfigurables)
        let slot = Slot(instanceGuid: "",
                        offer: Offer(campaignId: "",
                                     creative:
                                        Creative(referralCreativeId: "",
                                                 instanceGuid: "",
                                                 copy: [MobileCreativeCopy: "Content",
                                                       MobileCreativeTitle: "Title."],
                                                 responseOptions: [],
                                                 creativeJWTToken: "creative-token")),
                        slotJWTToken: "slot-token")
        
        let transformer = getPlacementTransformer(placement)
        
        let content = try transformer.transformOfferContent(slot: slot)
        XCTAssertNil(content.title)
        XCTAssertEqual(content.body?.text, "Title. Content")
    }

    func test_offer_with_title_next_line() throws {
        placeholderConfigurables[MobileCreativeInLineCopyWithHeading] = "false"
        let placement = getSamplePlacement(placeholderConfigurables)
        let slot = Slot(instanceGuid: "",
                        offer: Offer(campaignId: "",
                                     creative:
                                        Creative(referralCreativeId: "",
                                                 instanceGuid: "",
                                                 copy: [MobileCreativeCopy: "Content",
                                                       MobileCreativeTitle: "Title."],
                                                 responseOptions: [],
                                                 creativeJWTToken: "creative-token")),
                        slotJWTToken: "slot-token")

        let transformer = getPlacementTransformer(placement)

        let content = try transformer.transformOfferContent(slot: slot)
        XCTAssertEqual(content.title?.text, "Title.")
        XCTAssertEqual(content.body?.text, "Content")
    }

    func test_offer_with_title_inline_with_two_dots() throws {
        placeholderConfigurables[MobileCreativeInLineCopyWithHeading] = "true"
        let placement = getSamplePlacement(placeholderConfigurables)
        let slot = Slot(instanceGuid: "",
                        offer: Offer(campaignId: "",
                                     creative:
                                        Creative(referralCreativeId: "",
                                                 instanceGuid: "",
                                                 copy: [MobileCreativeCopy: "Content",
                                                       MobileCreativeTitle: "Title. yes."],
                                                 responseOptions: [],
                                                 creativeJWTToken: "creative-token")),
                        slotJWTToken: "slot-token")

        let transformer = getPlacementTransformer(placement)

        let content = try transformer.transformOfferContent(slot: slot)
        XCTAssertNil(content.title)
        XCTAssertEqual(content.body?.text, "Title. yes. Content")
    }

    func test_offer_with_title_inline_dots_not_at_end() throws {
        placeholderConfigurables[MobileCreativeInLineCopyWithHeading] = "true"
        let placement = getSamplePlacement(placeholderConfigurables)
        let slot = Slot(instanceGuid: "",
                        offer: Offer(campaignId: "",
                                     creative:
                                        Creative(referralCreativeId: "",
                                                 instanceGuid: "",
                                                 copy: [MobileCreativeCopy: "Content",
                                                       MobileCreativeTitle: "Title. yes"],
                                                 responseOptions: [],
                                                 creativeJWTToken: "creative-token")),
                        slotJWTToken: "slot-token")

        let transformer = getPlacementTransformer(placement)

        let content = try transformer.transformOfferContent(slot: slot)
        XCTAssertNil(content.title)
        XCTAssertEqual(content.body?.text, "Title. yes Content")
    }

    func test_offer_content_font_weight() throws {
        var configurables = [
            MobileCreativeFontFamily: "HelveticaNeue",
            MobileCreativeFontSize: "11",
            MobileCreativeFontColorLight: "#000000",
            MobileCreativeFontColorDark: "#ffffff",
            MobileOfferBackgroundColorLight: "#ffffff",
            MobileOfferBackgroundColorDark: "#ffffff",
            MobileCreativeInLineCopyWithHeading: "false"
        ]

        configurables[MobileCreativeFontWeight] = "semibold"
        configurables[MobileCreativeTitleFontWeight] = "extrabold"

        let placement = getSamplePlacement(configurables)
        let slot = Slot(instanceGuid: "",
                        offer: Offer(campaignId: "",
                                     creative:
                                        Creative(referralCreativeId: "",
                                                 instanceGuid: "",
                                                 copy: [MobileCreativeCopy: "Content",
                                                       MobileCreativeTitle: "Title. yes"],
                                                 responseOptions: [],
                                                 creativeJWTToken: "creative-token")),
                        slotJWTToken: "slot-token")

        let transformer = getPlacementTransformer(placement)

        let content = try transformer.transformOfferContent(slot: slot)
        XCTAssertEqual(content.body?.textStyleViewData.fontWeight, .semiBold)
        XCTAssertEqual(content.title?.textStyleViewData.fontWeight, .extraBold)
    }

    // MARK: transform offers
    func test_offers_emptyOffers() throws {
        let placement = getSamplePlacement(nil)
        let transformer = getPlacementTransformer(placement)
        XCTAssertEqual([], try transformer.transformOffers())
    }

    func test_offers_invalid_offer_layout() throws {
        let placement = Placement(id: "",
                                  targetElementSelector: "",
                                  offerLayoutCode: "something",
                                  placementLayoutCode: .unknown,
                                  placementConfigurables: [MobilePlacementBackgroundColorLight:"",
                                                            MobilePlacementBackgroundColorDark: ""],
                                  instanceGuid: "",
                                  slots: nil,
                                  placementsJWTToken: "placements-token")

        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError( try transformer.transformOfferLayout()) { error in
            XCTAssertEqual(error as! TransformerError,
                           TransformerError.NotSupported(key: kOfferLayout + "something"))
        }
    }

    // MARK: Test LightBox
    func test_lightBox_layout() throws {
        var placementResponse: PlacementResponse?
        if let path = Bundle(for: Rokt.self).path(forResource: "placement_light_box", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let response = try JSONDecoder().decode(PlacementResponse.self, from: data)
                XCTAssertNotNil(response)
                placementResponse = response
            } catch {
                print(error)
                XCTFail("placement_light_box decode thrown exception") }
        } else {
            XCTFail("placement_light_box decode thrown exception")
        }
        let transformer = PlacementTransformer(placement: (placementResponse?.placements[0])!, pageInstanceGuid: "", startDate: Date(), responseReceivedDate: Date())
        let placementViewData = try transformer.transformPlacement()
        XCTAssert(placementViewData.offers.count > 0)
        XCTAssertEqual(placementViewData.placementsJWTToken, "placement-token")
    }

    func test_placement_type_invalid() throws {
        let placement = Placement(id: "",
                                  targetElementSelector: "",
                                  offerLayoutCode: "",
                                  placementLayoutCode: .unknown,
                                  placementConfigurables: [MobilePlacementBackgroundColorLight:"",
                                                            MobilePlacementBackgroundColorDark: ""],
                                  instanceGuid: "",
                                  slots: nil,
                                  placementsJWTToken: "placements-token")

        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError( try transformer.transformPlacement()) { error in
            XCTAssertEqual(error as! TransformerError,
                           TransformerError.NotSupported(key: kPlacementLayoutCode + "unknown"))
        }
    }

    func test_placement_type_missed() throws {
        let placement = Placement(id: "",
                                  targetElementSelector: "",
                                  offerLayoutCode: "",
                                  placementLayoutCode: nil,
                                  placementConfigurables: [MobilePlacementBackgroundColorLight:"",
                                                            MobilePlacementBackgroundColorDark: ""],
                                  instanceGuid: "",
                                  slots: nil,
                                  placementsJWTToken: "placements-token")

        let transformer = getPlacementTransformer(placement)
        XCTAssertThrowsError( try transformer.transformPlacement()) { error in
            XCTAssertEqual(error as! TransformerError,
                           TransformerError.NotSupported(key: kPlacementLayoutCode))
        }
    }

    func getSamplePlacement(_ configurables: [String: String]?) -> Placement {
        return Placement(id: "",
                         targetElementSelector: "",
                         offerLayoutCode: "",
                         placementLayoutCode: .embeddedLayout,
                         placementConfigurables: configurables,
                         instanceGuid: "",
                         slots: nil,
                         placementsJWTToken: "placements-token")
    }

    func getDefaultPlacement() -> Placement {
        if let path = Bundle(for: Rokt.self).path(forResource: "placement", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let placementResponse = try JSONDecoder().decode(PlacementResponse.self, from: data)
                XCTAssertNotNil(placementResponse)
                return placementResponse.placements[0]
            } catch {
                print(error)
                XCTFail("Placement decode thrown exception") }
        } else {
            XCTFail("Placement decode thrown exception")
        }

        return getSamplePlacement(nil)
    }

    func getPlacementTransformer(_ placement: Placement,
                                 pageInstanceGuid: String = "",
                                 startDate: Date = Date()) -> PlacementTransformer {
        return PlacementTransformer(placement: placement,
                                    pageInstanceGuid: pageInstanceGuid,
                                    startDate: startDate,
                                    responseReceivedDate: Date())
    }

    // MARK: - Title text linebreak mode
    func test_shouldWordWrapKeyDoesNotExist_shouldReturnByTruncatingTail() throws {
        try assertLineBreakMode(shouldWordWrap: nil, expectedLineBreakMode: .byTruncatingTail)
    }

    func test_shouldWordWrapIsTrue_shouldReturnByWordWrapping() throws {
        try assertLineBreakMode(shouldWordWrap: "true", expectedLineBreakMode: .byWordWrapping)
    }

    func test_shouldWordWrapIsFalse_shouldReturnByTruncatingTail() throws {
        try assertLineBreakMode(shouldWordWrap: "false", expectedLineBreakMode: .byTruncatingTail)
    }

    private func assertLineBreakMode(shouldWordWrap: String?, expectedLineBreakMode: NSLineBreakMode) throws {
        var configurables = [MobilePlacementTitleContent: "after offer",
                          MobilePlacementTitleFontFamily: "font",
                            MobilePlacementTitleFontSize: "12",
                      MobilePlacementTitleFontColorLight: "light",
                       MobilePlacementTitleFontColorDark: "dark",
                           MobilePlacementTitleAlignment: "center",
                         MobilePlacementTitleLineSpacing: "4",
                MobilePlacementTitleBackgroundColorLight: "backLight",
                 MobilePlacementTitleBackgroundColorDark: "backDark",
               MobilePlacementTitleCloseButtonColorLight: "closeLight",
                MobilePlacementTitleCloseButtonColorDark: "closeDark",
         MobilePlacementTitleCloseButtonCircleColorLight: "closeCircleLight",
          MobilePlacementTitleCloseButtonCircleColorDark: "closeCircleDark"]

        if let sWordWrap = shouldWordWrap {
            configurables[MobilePlacementTitleShouldWordWrap] = sWordWrap
        }

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let titleView = try transformer.transformTitleView()

        XCTAssertEqual(titleView.textViewData.textStyleViewData.lineBreakMode, expectedLineBreakMode)
    }

    private func getEmbeddedPlacementFrom(json: String) -> Placement {
        if let path = Bundle(for: Rokt.self).path(forResource: json, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let placementResponse = try JSONDecoder().decode(PlacementResponse.self, from: data)
                XCTAssertNotNil(placementResponse)
                return placementResponse.placements[0]
            } catch {
                XCTFail("Placement decode thrown exception: \(error)") }
        } else {
            XCTFail("Placement decode thrown exception")
        }

        return getSamplePlacement(nil)
    }

    // MARK: - Single Creative Response
    func test_getPlacement_forEmbeddedLayout_withMobileCreativeNegativeButtonShowEqualsFalse_shouldNotHaveNegativeButton() throws {
        let placement = getEmbeddedPlacementFrom(json: "embedded_no_negative")
        let transformer = getPlacementTransformer(placement)
        let placementData = try transformer.transformPlacement()

        XCTAssertFalse(placementData.isNegativeButtonVisible)
        XCTAssertNil(placementData.negativeButton)
    }

    // MARK: - Allow/Prevent Navigation to Next Offer
    func test_getPlacement_forEmbeddedLayout_withCanLoadNextOfferEqualToFalse_shouldPreventNavigation() throws {
        let placement = getEmbeddedPlacementFrom(json: "embedded_no_negative")
        let transformer = getPlacementTransformer(placement)
        let placementData = try transformer.transformPlacement()

        XCTAssertFalse(placementData.canLoadNextOffer)
    }

    func test_getPlacement_forEmbeddedLayout_withoutCanLoadNextOffer_shouldAllowNavigation() throws {
        let placement = getEmbeddedPlacementFrom(json: "placement")
        let transformer = getPlacementTransformer(placement)
        let placementData = try transformer.transformPlacement()

        XCTAssertTrue(placementData.canLoadNextOffer)
    }

    // MARK: - NavigateToButton Data
    func test_getPlacement_forOverlay_withNavigateToButton_shouldParseValues() throws {
        let configurables = [
            "MobileSdk.Placement.NavigateButton.Text.Content": "sTay On VINteD",
            "MobileSdk.Placement.NavigateButton.TextCaseOption": "UpperCase",
            "MobileSdk.Placement.NavigateButton.CloseOnPress": "false",
            "MobileSdk.Placement.NavigateButton.Show": "true"
        ]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let navigateButtonData = try transformer.getNavigateButtonData()

        XCTAssertEqual(navigateButtonData?.text, "STAY ON VINTED")
        XCTAssertEqual(navigateButtonData?.closeOnPress, false)
        XCTAssertEqual(navigateButtonData?.action, .captureOnly)
    }

    func test_getPlacement_forOverlayNavigateButtonData_withNavigateToButtonDefaults_shouldParseValues() throws {
        let configurables = [
            MobilePlacementNavigateButtonText: "sTay On VINteD",
            MobilePlacementNavigateButtonShow: "true",
            "MobileSdk.Placement.NavigateButton.Margin": "16 16 16 16",
            "MobileSdk.Placement.NavigateButton.Default.Font.Family": "EBGaramond-Regular",
            "MobileSdk.Placement.NavigateButton.Default.Font.Size": "16",
            "MobileSdk.Placement.NavigateButton.Default.Font.Color.Light": "#ffffff",
            "MobileSdk.Placement.NavigateButton.Default.Font.Color.Dark": "#ffffff",
            "MobileSdk.Placement.NavigateButton.Default.BackgroundColor.Light": "#007782",
            "MobileSdk.Placement.NavigateButton.Default.BackgroundColor.Dark": "#007782",
            "MobileSdk.Placement.NavigateButton.Default.CornerRadius": "0",
            "MobileSdk.Placement.NavigateButton.Default.BorderThickness": "0.0",
            "MobileSdk.Placement.NavigateButton.Default.BorderColor.Light": "#B4ACB1",
            "MobileSdk.Placement.NavigateButton.Default.BorderColor.Dark": "#B4ACB1",
            "MobileSdk.Placement.NavigateButton.Pressed.Font.Family": "EBGaramond-Bold",
            "MobileSdk.Placement.NavigateButton.Pressed.Font.Size": "15",
            "MobileSdk.Placement.NavigateButton.Pressed.Font.Color.Light": "#ffffff",
            "MobileSdk.Placement.NavigateButton.Pressed.Font.Color.Dark": "#ffffff",
            "MobileSdk.Placement.NavigateButton.Pressed.BackgroundColor.Light": "#B4ACB1",
            "MobileSdk.Placement.NavigateButton.Pressed.BackgroundColor.Dark": "#B4ACB1",
            "MobileSdk.Placement.NavigateButton.Pressed.CornerRadius": "1",
            "MobileSdk.Placement.NavigateButton.Pressed.BorderThickness": "0.0",
            "MobileSdk.Placement.NavigateButton.Pressed.BorderColor.Light": "#ff0011",
            "MobileSdk.Placement.NavigateButton.Pressed.BorderColor.Dark": "#ff0011",
            "MobileSdk.Placement.NavigateButton.Default.Font.Weight": "semibold",
            "MobileSdk.Placement.NavigateButton.Pressed.Font.Weight": "bold",
        ]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let navigateButtonData = try transformer.getNavigateButtonData()

        XCTAssertEqual(navigateButtonData?.text, "sTay On VINteD")
        XCTAssertEqual(navigateButtonData?.closeOnPress, true)
        XCTAssertEqual(navigateButtonData?.action, .captureOnly)

        let styling = try transformer.getNavigateButtonVisibilityAndStyle()

        XCTAssertEqual(styling.1?.defaultStyle.textStyleViewData.fontWeight?.asUIFontWeight, .semibold)
        XCTAssertEqual(styling.1?.pressedStyle.textStyleViewData.fontWeight?.asUIFontWeight, .bold)
    }

    func test_getPlacement_forOverlay_withNavigateToButton_withoutText_invalid_keyMissing() throws {
        let configurables = [
            "MobileSdk.Placement.NavigateButton.Show": "true"
        ]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        XCTAssertThrowsError( try transformer.getNavigateButtonData()) { error in
            XCTAssertEqual(error as! TransformerError,
                           TransformerError.KeyIsMissing(key: MobilePlacementNavigateButtonText))

        }
    }

    // MARK: - NavigateToButton Styles
    func test_getPlacement_forOverlayNavigateButtonStyle_withNavigateToButton_shouldParseValues() throws {
        let configurables = [
            // default
            "MobileSdk.Placement.NavigateButton.Default.Font.Family": "Arial",
            "MobileSdk.Placement.NavigateButton.Default.Font.Size": "15",
            "MobileSdk.Placement.NavigateButton.Default.Font.Color.Light": "#000000",
            "MobileSdk.Placement.NavigateButton.Default.Font.Color.Dark": "#AAAAAA",
            "MobileSdk.Placement.NavigateButton.Default.BackgroundColor.Light": "#00FF00",
            "MobileSdk.Placement.NavigateButton.Default.BackgroundColor.Dark": "#FF0000",
            "MobileSdk.Placement.NavigateButton.Default.CornerRadius": "1",
            "MobileSdk.Placement.NavigateButton.Default.BorderThickness": "3.0",
            "MobileSdk.Placement.NavigateButton.Default.BorderColor.Light": "#B4ACB1",
            "MobileSdk.Placement.NavigateButton.Default.BorderColor.Dark": "#BBCCDD",
            // pressed
            "MobileSdk.Placement.NavigateButton.Pressed.Font.Family": "HelveticaNeue",
            "MobileSdk.Placement.NavigateButton.Pressed.Font.Size": "16",
            "MobileSdk.Placement.NavigateButton.Pressed.Font.Color.Light": "#FF0000",
            "MobileSdk.Placement.NavigateButton.Pressed.Font.Color.Dark": "#FFFF00",
            "MobileSdk.Placement.NavigateButton.Pressed.BackgroundColor.Light": "#B4ACB1",
            "MobileSdk.Placement.NavigateButton.Pressed.BackgroundColor.Dark": "#A4ACB1",
            "MobileSdk.Placement.NavigateButton.Pressed.CornerRadius": "10",
            "MobileSdk.Placement.NavigateButton.Pressed.BorderThickness": "0.0",
            "MobileSdk.Placement.NavigateButton.Pressed.BorderColor.Light": "#ff0011",
            "MobileSdk.Placement.NavigateButton.Pressed.BorderColor.Dark": "#ff0011",
            // generic
            "MobileSdk.Placement.NavigateButton.Show": "true",
            "MobileSdk.Placement.NavigateButton.Margin": "0 16 17 18",
            "MobileSdk.Placement.NavigateButton.MinHeight": "100"
        ]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let visibilityMarginStyle = try transformer.getNavigateButtonVisibilityAndStyle()

        let visibility = visibilityMarginStyle.0
        XCTAssertEqual(visibility, true)

        let margin = visibilityMarginStyle.1?.margin
        XCTAssertEqual(margin?.top, 0)
        XCTAssertEqual(margin?.right, 16)
        XCTAssertEqual(margin?.bottom, 17)
        XCTAssertEqual(margin?.left, 18)

        XCTAssertEqual(visibilityMarginStyle.1?.minHeight, 100)

        let defaultStyle = visibilityMarginStyle.1?.defaultStyle
        let defaultTextData = TextStyleViewData(fontFamily: "Arial",
                                                fontSize: 15,
                                                fontColor: [0: "#000000", 1: "#AAAAAA"],
                                                backgroundColor: [0: "#00FF00", 1: "#FF0000"],
                                                alignment: .center,
                                                lineSpacing: kDefaultLineSpacing,
                                                lineBreakMode: .byTruncatingTail)

        XCTAssertEqual(defaultStyle?.textStyleViewData, defaultTextData)
        XCTAssertEqual(defaultStyle?.cornerRadius, 1)
        XCTAssertEqual(defaultStyle?.borderThickness, 3.0)
        XCTAssertEqual(defaultStyle?.borderColor, [0: "#B4ACB1", 1: "#BBCCDD"])

        let pressedStyle = visibilityMarginStyle.1?.pressedStyle
        let pressedTextData = TextStyleViewData(fontFamily: "HelveticaNeue",
                                                fontSize: 16,
                                                fontColor: [0: "#FF0000", 1: "#FFFF00"],
                                                backgroundColor: [0: "#B4ACB1", 1: "#A4ACB1"],
                                                alignment: .center,
                                                lineSpacing: kDefaultLineSpacing,
                                                lineBreakMode: .byTruncatingTail)

        XCTAssertEqual(pressedStyle?.textStyleViewData, pressedTextData)
        XCTAssertEqual(pressedStyle?.cornerRadius, 10)
        XCTAssertEqual(pressedStyle?.borderThickness, 0)
        XCTAssertEqual(pressedStyle?.borderColor, [0: "#ff0011", 1: "#ff0011"])
    }

    func test_getPlacement_forNavigateToButton_defaults_shouldParseValues() throws {
        let configurables = [
            "MobileSdk.Placement.NavigateButton.Text.Content": "sTay On VINteD",
        ]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let visibilityMarginStyle = try transformer.getNavigateButtonVisibilityAndStyle()

        let visibility = visibilityMarginStyle.0
        XCTAssertEqual(visibility, false)
    }

    func test_getPlacement_forNavigateToButtonStyle_defaults_shouldParseDefaultButtonHeight() throws {
        let configurables = [
            // default
            "MobileSdk.Placement.NavigateButton.Default.Font.Family": "Arial",
            "MobileSdk.Placement.NavigateButton.Default.Font.Size": "15",
            "MobileSdk.Placement.NavigateButton.Default.Font.Color.Light": "#000000",
            "MobileSdk.Placement.NavigateButton.Default.Font.Color.Dark": "#AAAAAA",
            "MobileSdk.Placement.NavigateButton.Default.BackgroundColor.Light": "#00FF00",
            "MobileSdk.Placement.NavigateButton.Default.BackgroundColor.Dark": "#FF0000",
            "MobileSdk.Placement.NavigateButton.Default.CornerRadius": "1",
            "MobileSdk.Placement.NavigateButton.Default.BorderThickness": "3.0",
            "MobileSdk.Placement.NavigateButton.Default.BorderColor.Light": "#B4ACB1",
            "MobileSdk.Placement.NavigateButton.Default.BorderColor.Dark": "#BBCCDD",
            // pressed
            "MobileSdk.Placement.NavigateButton.Pressed.Font.Family": "HelveticaNeue",
            "MobileSdk.Placement.NavigateButton.Pressed.Font.Size": "16",
            "MobileSdk.Placement.NavigateButton.Pressed.Font.Color.Light": "#FF0000",
            "MobileSdk.Placement.NavigateButton.Pressed.Font.Color.Dark": "#FFFF00",
            "MobileSdk.Placement.NavigateButton.Pressed.BackgroundColor.Light": "#B4ACB1",
            "MobileSdk.Placement.NavigateButton.Pressed.BackgroundColor.Dark": "#A4ACB1",
            "MobileSdk.Placement.NavigateButton.Pressed.CornerRadius": "10",
            "MobileSdk.Placement.NavigateButton.Pressed.BorderThickness": "0.0",
            "MobileSdk.Placement.NavigateButton.Pressed.BorderColor.Light": "#ff0011",
            "MobileSdk.Placement.NavigateButton.Pressed.BorderColor.Dark": "#ff0011",
            // generic
            "MobileSdk.Placement.NavigateButton.Show": "true",
        ]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let visibilityMarginStyle = try transformer.getNavigateButtonVisibilityAndStyle()

        let visibility = visibilityMarginStyle.0
        XCTAssertEqual(visibility, true)

        XCTAssertEqual(visibilityMarginStyle.1?.minHeight, kButtonsHeight)
    }

    // MARK: - NavigateToButtonDivider
    func test_getPlacement_forNavigateToDivider_shouldParseValues() throws {
        let configurables = [
            "MobileSdk.Placement.NavigateButton.Divider.Show": "true",
            "MobileSdk.Placement.NavigateButton.Divider.Height": "2",
            "MobileSdk.Placement.NavigateButton.Divider.BackgroundColor.Light":"#808080",
            "MobileSdk.Placement.NavigateButton.Divider.BackgroundColor.Dark":"#828282",
            "MobileSdk.Placement.NavigateButton.Divider.Margin": "16 17 18 19"
        ]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let divider = try transformer.transformNavigateButtonDivider()
        let expectedDividerData = DividerViewDataWithDimensions(
            backgroundColor: [0: "#808080", 1: "#828282"],
            isVisible: true,
            height: 2,
            margin: FrameAlignment(top: 16, right: 17, bottom: 18, left: 19)
        )

        XCTAssertEqual(divider, expectedDividerData)
    }

    func test_getPlacement_forNavigateToTitleDivider_shouldParseValues() throws {
        let configurables = [
            "MobileSdk.Placement.Title.Divider.Show": "true",
            "MobileSdk.Placement.Title.Divider.Height": "2",
        ]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let divider = try transformer.transformTitleDivider()
        let expectedDividerData = DividerViewDataWithDimensions(
            isVisible: true,
            height: 2,
            margin: FrameAlignment(top: 16, right: 0, bottom: 16, left: 0)
        )

        XCTAssertEqual(divider, expectedDividerData)
    }

    func test_getPlacement_forNavigateToTitleDividerDefaults_shouldParseValues() throws {
        let configurables = [
            "MobileSdk.Placement.Title.Divider.Height": "2",
        ]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let divider = try transformer.transformTitleDivider()
        let expectedDividerData = DividerViewDataWithDimensions(
            isVisible: false,
            height: 2,
            margin: FrameAlignment(top: 16, right: 0, bottom: 16, left: 0)
        )

        XCTAssertEqual(divider, expectedDividerData)
    }

    func test_getPlacement_forTitleDivider_shouldParseValues() throws {
        let configurables = [
            "MobileSdk.Placement.NavigateButton.Divider.Height": "2",
        ]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let divider = try transformer.transformNavigateButtonDivider()
        let expectedDividerData = DividerViewDataWithDimensions(
            isVisible: false,
            height: 2,
            margin: FrameAlignment(top: 16, right: 0, bottom: 0, left: 0)
        )

        XCTAssertEqual(divider, expectedDividerData)
    }

    func test_getPlacement_forFooterDivider_shouldParseValues() throws {
        let configurables = [
            "MobileSdk.Placement.Footer.Divider.Margin": "1 2 3 4",
            "MobileSdk.Placement.Footer.Divider.Height": "10"
        ]

        let placement = getSamplePlacement(configurables)
        let transformer = getPlacementTransformer(placement)

        let margin = try transformer.getOptionalFrameAlignment(MobilePlacementFooterDividerMargin)
        let height = try transformer.getOptionalFloat(MobilePlacementFooterDividerHeight)

        XCTAssertEqual(margin, FrameAlignment(top: 1, right: 2, bottom: 3, left: 4))
        XCTAssertEqual(height, 10)
    }

    // MARK: - Title Position and Margin
    func test_getPlacement_forTitlePositionAndMarginDefaults_shouldParseValues() throws {
        let lightBoxPlacement = try placementFromJSON(filename: "placement_light_box") as! LightBoxViewData

        XCTAssertEqual(lightBoxPlacement.titlePosition, .inline)
        XCTAssertEqual(lightBoxPlacement.titleMargin, FrameAlignment(top: 8, right: 10, bottom: 8, left: 16))
    }

    func test_getPlacement_forTitlePositionAndMargin_shouldParseValues() throws {
        let lightBoxPlacement = try placementFromJSON(filename: "placement_overlay_title_UNIT") as! LightBoxViewData

        XCTAssertEqual(lightBoxPlacement.titlePosition, .bottom)
        XCTAssertEqual(lightBoxPlacement.titleMargin, FrameAlignment(top: 64, right: 63, bottom: 62, left: 61))
    }
}

extension XCTestCase {
    func placementFromJSON(filename: String) throws -> PlacementViewData {
        var placementResponse: PlacementResponse? = nil

        if let path = Bundle(for: Rokt.self).path(forResource: filename, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let response = try JSONDecoder().decode(PlacementResponse.self, from: data)
                XCTAssertNotNil(response)

                placementResponse = response
            } catch {
                XCTFail("placement response decode thrown exception \(error)") }
        } else {
            XCTFail("json file does not exist")
        }

        let transformer = PlacementTransformer(placement: (placementResponse?.placements[0])!, pageInstanceGuid: "", startDate: Date(), responseReceivedDate: Date())
        let placementViewData = try transformer.transformPlacement()

        return placementViewData
    }
}
