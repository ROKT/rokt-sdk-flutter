//
//  TestStyleTransformer.swift
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
final class TestStyleTransformer: XCTestCase {
    
    func test_get_updated_style_styling_properties_model() throws {
        // Arrange
        let defaultStyle = StylingPropertiesModel(container: ContainerStylingProperties(justifyContent: .center,
                                                                                        alignItems: .center,
                                                                                        shadow: Shadow(offsetX: 0,
                                                                                                       offsetY: 0,
                                                                                                       blurRadius: 0,
                                                                                                       spreadRadius: 0,
                                                                                                       color: ThemeColor(light: "#111111", dark: nil)),
                                                                                        overflow: .scroll),
                                                  background: BackgroundStylingProperties(backgroundColor:
                                                                                            ThemeColor(light: "#111111", dark: nil),
                                                                                          backgroundImage: nil),
                                                  dimension: DimensionStylingProperties(minWidth: 0,
                                                                                        maxWidth: 0,
                                                                                        width: .fit(.wrapContent),
                                                                                        minHeight: 0,
                                                                                        maxHeight: 0,
                                                                                        height: .fixed(10)),
                                                  flexChild: FlexChildStylingProperties(weight: 0,
                                                                                        order: 0,
                                                                                        alignSelf: .center),
                                                  spacing: SpacingStylingProperties(padding: "0",
                                                                                    margin: "0",
                                                                                    offset: nil),
                                                  border: BorderStylingProperties(borderRadius: 10,
                                                                                  borderColor: ThemeColor(light: "#111111", dark: nil),
                                                                                  borderWidth: 2,
                                                                                  borderStyle: .solid))
        
        let pressed = StylingPropertiesModel(container: nil,
                                             background: BackgroundStylingProperties(backgroundColor:
                                                                                        ThemeColor(light: "#111112", dark: nil),
                                                                                     backgroundImage: nil),
                                             dimension: nil,
                                             flexChild: FlexChildStylingProperties(weight: nil,
                                                                                   order: 1,
                                                                                   alignSelf: nil),
                                             spacing: nil,
                                             border: nil)
        
        let expectedStyle = StylingPropertiesModel(container: ContainerStylingProperties(justifyContent: .center,
                                                                                         alignItems: .center,
                                                                                         shadow: Shadow(offsetX: 0,
                                                                                                        offsetY: 0,
                                                                                                        blurRadius: 0,
                                                                                                        spreadRadius: 0,
                                                                                                        color: ThemeColor(light: "#111111", dark: nil)),
                                                                                         overflow: .scroll),
                                                   background: BackgroundStylingProperties(backgroundColor:
                                                                                            ThemeColor(light: "#111112", dark: nil),
                                                                                           backgroundImage: nil),
                                                   dimension: DimensionStylingProperties(minWidth: 0,
                                                                                         maxWidth: 0,
                                                                                         width: .fit(.wrapContent),
                                                                                         minHeight: 0,
                                                                                         maxHeight: 0,
                                                                                         height: .fixed(10)),
                                                   flexChild: FlexChildStylingProperties(weight: 0,
                                                                                         order: 1,
                                                                                         alignSelf: .center),
                                                   spacing: SpacingStylingProperties(padding: "0",
                                                                                     margin: "0",
                                                                                     offset: nil),
                                                   border: BorderStylingProperties(borderRadius: 10,
                                                                                   borderColor: ThemeColor(light: "#111111", dark: nil),
                                                                                   borderWidth: 2,
                                                                                   borderStyle: .solid))
        
        // ACT
        let transformedStyle = StyleTransformer.getUpdatedStyle(defaultStyle, newStyle: pressed)
        
        // Assert
        XCTAssertEqual(transformedStyle?.container, expectedStyle.container)
        XCTAssertEqual(transformedStyle?.background, expectedStyle.background)
        XCTAssertEqual(transformedStyle?.dimension, expectedStyle.dimension)
        XCTAssertEqual(transformedStyle?.flexChild, expectedStyle.flexChild)
        XCTAssertEqual(transformedStyle?.spacing, expectedStyle.spacing)
        XCTAssertEqual(transformedStyle?.border, expectedStyle.border)
    }
    
    func test_get_updated_style_basic_text() throws {
        // Arrange
        let defaultStyle = BasicTextStyle(dimension: DimensionStylingProperties(minWidth: 10,
                                                                                maxWidth: 100,
                                                                                width: nil,
                                                                                minHeight: 10,
                                                                                maxHeight: 110,
                                                                                height: nil),
                                          flexChild: nil,
                                          spacing: SpacingStylingProperties(padding: "10",
                                                                            margin: nil,
                                                                            offset: nil),
                                          background: nil,
                                          text: TextStylingProperties(textColor: ThemeColor(light: "#123123", dark: nil),
                                                                      fontSize: 12,
                                                                      fontFamily: "Arial",
                                                                      fontWeight: .w400,
                                                                      lineHeight: 10,
                                                                      horizontalTextAlign: .center,
                                                                      baselineTextAlign: .none,
                                                                      fontStyle: .normal,
                                                                      textTransform: .lowercase,
                                                                      letterSpacing: 10,
                                                                      textDecoration: nil,
                                                                      lineLimit: 0))
        
        let pressed = BasicTextStyle(dimension: nil,
                                     flexChild: nil,
                                     spacing: nil,
                                     background: nil,
                                     text: TextStylingProperties(textColor: ThemeColor(light: "#000000", dark: nil),
                                                                 fontSize: 11,
                                                                 fontFamily: nil,
                                                                 fontWeight: nil,
                                                                 lineHeight: nil,
                                                                 horizontalTextAlign: nil,
                                                                 baselineTextAlign: nil,
                                                                 fontStyle: nil,
                                                                 textTransform: nil,
                                                                 letterSpacing: nil,
                                                                 textDecoration: nil,
                                                                 lineLimit: nil))
        
        let expectedStyle = BasicTextStyle(dimension: DimensionStylingProperties(minWidth: 10,
                                                                                 maxWidth: 100,
                                                                                 width: nil,
                                                                                 minHeight: 10,
                                                                                 maxHeight: 110,
                                                                                 height: nil),
                                           flexChild: nil,
                                           spacing: SpacingStylingProperties(padding: "10",
                                                                             margin: nil,
                                                                             offset: nil),
                                           background: nil,
                                           text: TextStylingProperties(textColor: ThemeColor(light: "#000000", dark: nil),
                                                                       fontSize: 11,
                                                                       fontFamily: "Arial",
                                                                       fontWeight: .w400,
                                                                       lineHeight: 10,
                                                                       horizontalTextAlign: .center,
                                                                       baselineTextAlign: .none,
                                                                       fontStyle: .normal,
                                                                       textTransform: .lowercase,
                                                                       letterSpacing: 10,
                                                                       textDecoration: nil,
                                                                       lineLimit: 0))
        
        // ACT
        let transformedStyle = StyleTransformer.getUpdatedStyle(defaultStyle, newStyle: pressed)
        
        // Assert
        XCTAssertEqual(transformedStyle?.background, expectedStyle.background)
        XCTAssertEqual(transformedStyle?.dimension, expectedStyle.dimension)
        XCTAssertEqual(transformedStyle?.flexChild, expectedStyle.flexChild)
        XCTAssertEqual(transformedStyle?.spacing, expectedStyle.spacing)
        XCTAssertEqual(transformedStyle?.text, expectedStyle.text)
    }
    
    func test_get_updated_style_data_image() throws {
        // Arrange
        let defaultStyle = DataImageStyles(background: nil,
                                           border: nil,
                                           dimension: DimensionStylingProperties(minWidth: nil,
                                                                                 maxWidth: nil,
                                                                                 width: .fit(.wrapContent),
                                                                                 minHeight: nil,
                                                                                 maxHeight: nil,
                                                                                 height: nil),
                                           flexChild: FlexChildStylingProperties(weight: 0, order: 0, alignSelf: nil),
                                           spacing: nil)
        
        let pressed = DataImageStyles(background: BackgroundStylingProperties(backgroundColor: ThemeColor(light: "#000000", dark: nil),
                                                                              backgroundImage: nil),
                                      border: nil, dimension: nil, flexChild: nil, spacing: nil)
        
        let expectedStyle = DataImageStyles(background: BackgroundStylingProperties(backgroundColor: ThemeColor(light: "#000000", dark: nil),
                                                                                    backgroundImage: nil),
                                            border: nil,
                                            dimension: DimensionStylingProperties(minWidth: nil,
                                                                                  maxWidth: nil,
                                                                                  width: .fit(.wrapContent),
                                                                                  minHeight: nil,
                                                                                  maxHeight: nil,
                                                                                  height: nil),
                                            flexChild: FlexChildStylingProperties(weight: 0, order: 0, alignSelf: nil),
                                            spacing: nil)
        
        // ACT
        let transformedStyle = StyleTransformer.getUpdatedStyle(defaultStyle, newStyle: pressed)
        
        // Assert
        XCTAssertEqual(transformedStyle?.background, expectedStyle.background)
        XCTAssertEqual(transformedStyle?.dimension, expectedStyle.dimension)
        XCTAssertEqual(transformedStyle?.flexChild, expectedStyle.flexChild)
        XCTAssertEqual(transformedStyle?.spacing, expectedStyle.spacing)
        XCTAssertEqual(transformedStyle?.border, expectedStyle.border)
    }
    
    func test_get_updated_style_empty_default_creative_response() throws {
        // Arrange
        let defaultStyle = CreativeResponseStyles(container: nil,
                                                  background: nil,
                                                  border: nil,
                                                  dimension: nil,
                                                  flexChild: nil,
                                                  spacing: nil)
        
        let pressed = CreativeResponseStyles(container: nil,
                                             background: nil,
                                             border: BorderStylingProperties(borderRadius: 12,
                                                                             borderColor: ThemeColor(light: "#FF0000", dark: "#FF0000"),
                                                                             borderWidth: 2,
                                                                             borderStyle: nil),
                                             dimension: nil,
                                             flexChild: nil,
                                             spacing: nil)
        
        let expectedStyle = CreativeResponseStyles(container: nil,
                                                   background: nil,
                                                   border: BorderStylingProperties(borderRadius: 12,
                                                                                   borderColor: ThemeColor(light: "#FF0000", dark: "#FF0000"),
                                                                                   borderWidth: 2,
                                                                                   borderStyle: nil),
                                                   dimension: nil,
                                                   flexChild: nil,
                                                   spacing: nil)
        
        // ACT
        let transformedStyle = StyleTransformer.getUpdatedStyle(defaultStyle, newStyle: pressed)
        
        // Assert
        XCTAssertEqual(transformedStyle?.container, expectedStyle.container)
        XCTAssertEqual(transformedStyle?.background, expectedStyle.background)
        XCTAssertEqual(transformedStyle?.dimension, expectedStyle.dimension)
        XCTAssertEqual(transformedStyle?.flexChild, expectedStyle.flexChild)
        XCTAssertEqual(transformedStyle?.spacing, expectedStyle.spacing)
        XCTAssertEqual(transformedStyle?.border, expectedStyle.border)
    }
    
}
