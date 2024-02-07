//
//  TestBasicTextComponent.swift
//  Rokt_WidgetTests
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import XCTest
import SwiftUI
import ViewInspector

@available(iOS 15.0, *)
final class TestRichTextComponent: XCTestCase {
    func test_rich_text() throws {
        let view = TestPlaceHolder(layout: LayoutSchemaUIModel.richText(get_model()))

        let text = try view.inspect().view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .view(LayoutSchemaComponent.self)
            .view(RichTextComponent.self)
            .actualView()
            .inspect()
            .text()

        // test custom modifier class
        let paddingModifier = try text.modifier(PaddingModifier.self)
        XCTAssertEqual(try paddingModifier.actualView().padding, FrameAlignmentProperty(top: 1, right: 0, bottom: 1, left: 8))
        
        // test the effect of custom modifier
        let padding = try text.padding()
        XCTAssertEqual(padding, EdgeInsets(top: 1.0, leading: 8.0, bottom: 17.0, trailing: 0.0))
        
        let model = try view.inspect().view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .view(LayoutSchemaComponent.self)
            .view(RichTextComponent.self)
            .actualView()
            .model
        let attributedString  = model.attributedString

        let nsAttrString = NSAttributedString(attributedString)
        XCTAssertEqual(nsAttrString.string, "ORDER Number: Uk171359906")

        // space-agnostic colour comparison
        let foregroundColor = nsAttrString.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
        XCTAssertEqual(foregroundColor?.isEqualIgnoringSpaceContext(UIColor(hexString: "#AABBCC")), true)

        let font = nsAttrString.attribute(.font, at: 0, effectiveRange: nil) as? UIFont

        XCTAssertEqual(font?.fontDescriptor.symbolicTraits.contains(.traitBold), true)
        XCTAssertEqual(font?.fontDescriptor.symbolicTraits.contains(.traitItalic), true)

        let underlineRange = NSRange(location: 0, length: 5)
        let underlineText = nsAttrString.attributedSubstring(from: underlineRange)

        underlineText.enumerateAttributes(in: underlineRange, options: []) { (dict, _, _) in
            XCTAssertTrue(dict.keys.contains(.underlineStyle))
        }

        let strikeThroughRange = NSRange(location: 6, length: 6)
        let strikeThroughText = nsAttrString.attributedSubstring(from: strikeThroughRange)
        let strikeThroughTextRange = NSRange(location: 0, length: 6)

        strikeThroughText.enumerateAttributes(in: strikeThroughTextRange, options: []) { (dict, _, _) in
            XCTAssertTrue(dict.keys.contains(.strikethroughStyle))
        }
        
        // check min/max width/height
        let flexFrame = try text.flexFrame()
        XCTAssertEqual(flexFrame.minWidth, 10)
        XCTAssertEqual(flexFrame.maxWidth, 100)
        XCTAssertEqual(flexFrame.minHeight, 15)
        XCTAssertEqual(flexFrame.maxHeight, 150)

        // raw richtext
        let rawText = try view.inspect().view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .view(LayoutSchemaComponent.self)
            .view(RichTextComponent.self)
            .actualView()

        XCTAssertEqual(rawText.linkStyle, model.linkStyle?.text)

        XCTAssertEqual(rawText.horizontalAlignment, .start)

        XCTAssertNil(rawText.lineLimit)

        XCTAssertEqual(rawText.lineHeightPadding, 0)
        XCTAssertEqual(rawText.lineHeight, 0)
    }
    
    func get_model() -> RichTextUIModel {
        let layoutPlugin = LayoutPlugin(pluginInstanceGuid: "", breakpoints: nil, layout: nil, slots: [], targetElementSelector: "")
        let transformer = LayoutTransformer(layoutPlugin: layoutPlugin)
        let richText = transformer.getRichText(ModelTestData.TextData.richTextHTML())
        richText.transformValueToAttributedString()

        return richText
    }
}

extension UIColor {
    func isEqualIgnoringSpaceContext(_ otherColor: UIColor) -> Bool {
        guard let selfAsCGColor = self.cgColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil) else {
            XCTFail("Could not convert to cgColor \(self)")
            return false
        }

        guard let otherAsCGColor = otherColor.cgColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil) else {
            XCTFail("Could not convert to cgColor \(otherColor)")
            return false
        }

        return selfAsCGColor == otherAsCGColor
    }
}
