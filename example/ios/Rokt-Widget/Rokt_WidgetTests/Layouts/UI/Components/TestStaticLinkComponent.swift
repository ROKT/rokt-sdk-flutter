//
//  TestStaticLinkComponent.swift
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
final class TestStaticLinkComponent: XCTestCase {
    func test_static_link() throws {
        let view = TestPlaceHolder(layout: LayoutSchemaUIModel.staticLink(try get_model()))
        
        let staticLink = try view.inspect().view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .vStack()[0]
            .view(LayoutSchemaComponent.self)
            .view(StaticLinkComponent.self)
            .actualView()
            .inspect()
            .hStack()
        
        // test custom modifier class
        let paddingModifier = try staticLink.modifier(PaddingModifier.self)
        XCTAssertEqual(try paddingModifier.actualView().padding, FrameAlignmentProperty(top: 13, right: 14, bottom: 15, left: 16))
        
        // test the effect of custom modifier
        let padding = try staticLink.padding()
        XCTAssertEqual(padding, EdgeInsets(top: 13.0, leading: 16.0, bottom: 15.0, trailing: 14.0))
    }
    
    func test_staticLink_computedProperties_usesModelProperties() throws {
        let view = TestPlaceHolder(layout: LayoutSchemaUIModel.staticLink(try get_model()))
        
        let sut = try view.inspect().view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .vStack()[0]
            .view(LayoutSchemaComponent.self)
            .view(StaticLinkComponent.self)
            .actualView()
        
        let model = sut.model
        
        XCTAssertEqual(sut.style, model.defaultStyle?[0])
        XCTAssertEqual(sut.dimensionStyle, model.defaultStyle?[0].dimension)
        XCTAssertEqual(sut.flexStyle, model.defaultStyle?[0].flexChild)
        XCTAssertEqual(sut.backgroundStyle, model.defaultStyle?[0].background)
        XCTAssertEqual(sut.spacingStyle, model.defaultStyle?[0].spacing)
        
        XCTAssertEqual(sut.verticalAlignment, .top)
        XCTAssertEqual(sut.horizontalAlignment, .center)
    }
    
    func test_tapGesture_shouldTriggerLinkhandler() throws {
        let view = TestPlaceHolder(layout: LayoutSchemaUIModel.staticLink(try get_model()))
        
        var sut = try view.inspect().view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .vStack()[0]
            .view(LayoutSchemaComponent.self)
            .view(StaticLinkComponent.self)
            .actualView()
        
        let mockHandler = MockLinkHandler()
        sut.linkInterceptor = mockHandler
        
        XCTAssertFalse(mockHandler.didTriggerStaticLink)
        
        try sut.inspect().find(ViewType.HStack.self).callOnTapGesture()
        
        XCTAssertTrue(mockHandler.didTriggerStaticLink)
    }
    
    func test_longPressGesture_shouldUpdatePressedStyle() throws {
        let view = TestPlaceHolder(layout: LayoutSchemaUIModel.staticLink(try get_model()))
        
        var sut = try view.inspect().view(TestPlaceHolder.self)
            .view(EmbeddedComponent.self)
            .vStack()[0]
            .view(LayoutSchemaComponent.self)
            .view(StaticLinkComponent.self)
            .actualView()
        
        let mockHandler = MockLinkHandler()
        sut.linkInterceptor = mockHandler
        
        let model = sut.model
        
        try sut.inspect().find(ViewType.HStack.self).callOnTapGesture()
        
        XCTAssertEqual(sut.style, model.pressedStyle?[0])
    }
    
    func get_model() throws -> StaticLinkUIModel {
        let transformer = LayoutTransformer(layoutPlugin: get_mock_layout_plugin())
        let model = ModelTestData.StaticLinkData.staticLink()
        return try transformer.getStaticLink(src: model.src,
                                             open: model.open,
                                             styles: model.styles,
                                             children: transformer.transformChildren(model.children, slot: nil))
        
    }
    
}

@available(iOS 15, *)
class MockLinkHandler: LinkInterceptor {
    var didTriggerStaticLink = false
    var didTriggerCreativeLink = false
    
    func staticLinkHandler(url: URL,
                           open: LinkOpenTarget,
                           sessionId: String) {
        didTriggerStaticLink = true
    }
    
    func creativeLinkHandler(url: URL,
                             viewModel: CreativeResponseViewModel,
                             callback: CreativeResponseComponent) {
        didTriggerCreativeLink = true
    }
}
