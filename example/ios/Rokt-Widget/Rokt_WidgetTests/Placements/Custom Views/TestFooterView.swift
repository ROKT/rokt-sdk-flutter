//
//  TestFooterView.swift
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

class TestFooterView: XCTestCase {

    func test_footer_valid_empty_rokt_partner_pp() {
        let footerViewData = FooterViewData(backgroundColor: nil,
                                            roktPrivacyPolicy: nil,
                                            partnerPrivacyPolicy: nil,
                                            footerDivider: DividerViewDataWithDimensions(backgroundColor: nil,
                                                                                         isVisible: true,
                                                                                         height: 2,
                                                                                         margin: .zero),
                                            alignment: .end)
        let footerElements = getFooterElements(footerViewData: footerViewData)
        let roktPrivacy = LinkButton()
        let partnerPrivacy = LinkButton()
        FooterView.createView(footerElements, roktPrivacy: roktPrivacy, partnerPrivacy: partnerPrivacy)
        
        XCTAssertEqual(roktPrivacy.isHidden, true)
        XCTAssertNil(roktPrivacy.titleLabel?.text)
        XCTAssertEqual(partnerPrivacy.isHidden, true)
        XCTAssertNil(partnerPrivacy.titleLabel?.text)
        XCTAssertEqual(footerElements.footerHeight.constant, 0)
    }
    
    func test_footer_valid_background() {
        let footerViewData = FooterViewData(backgroundColor: [0: "#000000", 1: "#FFFFFF"],
                                            roktPrivacyPolicy: nil,
                                            partnerPrivacyPolicy: nil,
                                            footerDivider: DividerViewDataWithDimensions(backgroundColor: nil,
                                                                                         isVisible: true,
                                                                                         height: 2,
                                                                                         margin: .zero),
                                            alignment: .end)
        let footerElements = getFooterElements(footerViewData: footerViewData)
        
        let roktPrivacy = LinkButton()
        let partnerPrivacy = LinkButton()
        FooterView.createView(footerElements, roktPrivacy: roktPrivacy, partnerPrivacy: partnerPrivacy)
        
        XCTAssertEqual(footerElements.footerContainer.backgroundColor?.cgColor, UIColor(hexString: "#000000").cgColor)
    }
    
    func test_footer_valid_rokt_pp() {
        let footerViewData = FooterViewData(backgroundColor: nil,
                                            roktPrivacyPolicy:
            LinkViewData(text: "rokt",
                         link: "link",
                         textStyleViewData:
                TextStyleViewData(fontFamily: "Arial",
                                  fontSize: 11,
                                  fontColor: [0: "#000000", 1: "#FFFFFF"],
                                  backgroundColor: [0: "#FFFFFF", 1: "#000000"]),
                         underline: false),
                                            partnerPrivacyPolicy: nil,
                                            footerDivider: DividerViewDataWithDimensions(backgroundColor: nil,
                                                                                         isVisible: true,
                                                                                         height: 2,
                                                                                         margin: .zero),
                                            alignment: .end)
        let footerElements = getFooterElements(footerViewData: footerViewData)
        
        let roktPrivacy = LinkButton()
        let partnerPrivacy = LinkButton()
        FooterView.createView(footerElements, roktPrivacy: roktPrivacy, partnerPrivacy: partnerPrivacy)
        let exp = expectation(description: "Test after 0.1 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.1)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(footerElements.footerSectionDivider.isHidden, false)
            XCTAssertEqual(roktPrivacy.isHidden, false)
            XCTAssertEqual(roktPrivacy.titleLabel?.text, "rokt")
            XCTAssertEqual(roktPrivacy.titleLabel?.textColor.cgColor,
                           UIColor(hexString: "#000000").cgColor)
            XCTAssertEqual(roktPrivacy.titleLabel?.font.pointSize, 11)
            XCTAssertEqual(roktPrivacy.titleLabel?.font.familyName, "Arial")
            XCTAssertNil(partnerPrivacy.titleLabel?.text)
            XCTAssertEqual(partnerPrivacy.isHidden, true)
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    func test_footer_valid_partner_pp() {
        let footerViewData = FooterViewData(backgroundColor: nil,
                                            roktPrivacyPolicy: nil,
                                            partnerPrivacyPolicy:
            LinkViewData(text: "partner",
                         link: "link",
                         textStyleViewData:
                TextStyleViewData(fontFamily: "Arial",
                                  fontSize: 11,
                                  fontColor: [0: "#000000", 1: "#FFFFFF"],
                                  backgroundColor: [0: "#FFFFFF", 1: "#000000"]),
                         underline: false),
                                            footerDivider: DividerViewDataWithDimensions(backgroundColor: nil,
                                                                                         isVisible: true,
                                                                                         height: 2,
                                                                                         margin: .zero),
                                            alignment: .end)
        let footerElements = getFooterElements(footerViewData: footerViewData)
        
        let roktPrivacy = LinkButton()
        let partnerPrivacy = LinkButton()
        FooterView.createView(footerElements, roktPrivacy: roktPrivacy, partnerPrivacy: partnerPrivacy)
        let exp = expectation(description: "Test after 0.1 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.1)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(footerElements.footerSectionDivider.isHidden, false)
            XCTAssertEqual(partnerPrivacy.isHidden, false)
            XCTAssertEqual(partnerPrivacy.titleLabel?.text, "partner")
            XCTAssertEqual(partnerPrivacy.titleLabel?.textColor.cgColor,
                           UIColor(hexString: "#000000").cgColor)
            XCTAssertEqual(partnerPrivacy.titleLabel?.font.pointSize, 11)
            XCTAssertEqual(partnerPrivacy.titleLabel?.font.familyName, "Arial")
            XCTAssertNil(roktPrivacy.titleLabel?.text)
            XCTAssertEqual(roktPrivacy.isHidden, true)
        } else {
            XCTFail("Delay interrupted")
        }

    }
    
    func test_footer_divider_hide() {
        let textStyle = TextStyleViewData(fontFamily: "Arial",
                                                  fontSize: 11,
                                                  fontColor: [0: "#000000", 1: "#FFFFFF"],
                                                  backgroundColor: [0: "#FFFFFF", 1: "#000000"])

        let linkView = LinkViewData(text: "partner",
                                    link: "link",
                                    textStyleViewData: textStyle,
                                    underline: false)

        let footer = DividerViewDataWithDimensions(backgroundColor: nil,
                                                   isVisible: false,
                                                   height: 2,
                                                   margin: FrameAlignment(top: 10, right: 0, bottom: 0, left: 0))
        let footerViewData = FooterViewData(backgroundColor: nil,
                                            roktPrivacyPolicy: nil,
                                            partnerPrivacyPolicy: linkView,
                                            footerDivider: footer,
                                            alignment: .end)
        let footerElements = getFooterElements(footerViewData: footerViewData)
        
        let roktPrivacy = LinkButton()
        let partnerPrivacy = LinkButton()
        FooterView.createView(footerElements, roktPrivacy: roktPrivacy, partnerPrivacy: partnerPrivacy)
        let exp = expectation(description: "Test after 0.1 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.1)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(footerElements.footerSectionDivider.isHidden, true)
            XCTAssertEqual(footerElements.footerDividerHeight.constant, 0)
            XCTAssertEqual(footerElements.footerDividerTopSpacing.constant, 10)
        } else {
            XCTFail("Delay interrupted")
        }

    }
    
    func test_footer_divider_change_background_color() {
        let footerViewData = FooterViewData(backgroundColor: nil,
                                            roktPrivacyPolicy: nil,
                                            partnerPrivacyPolicy:
            LinkViewData(text: "partner",
                         link: "link",
                         textStyleViewData:
                TextStyleViewData(fontFamily: "Arial",
                                  fontSize: 11,
                                  fontColor: [0: "#000000", 1: "#FFFFFF"],
                                  backgroundColor: [0: "#FFFFFF", 1: "#000000"]),
                         underline: false),
                                            footerDivider: DividerViewDataWithDimensions(backgroundColor: [0: "#999999", 1: "#111111"],
                                                                                         isVisible: true,
                                                                                         height: 2,
                                                                                         margin: .zero),
                                            alignment: .end)
        let footerElements = getFooterElements(footerViewData: footerViewData)
        
        let roktPrivacy = LinkButton()
        let partnerPrivacy = LinkButton()
        FooterView.createView(footerElements, roktPrivacy: roktPrivacy, partnerPrivacy: partnerPrivacy)
        let exp = expectation(description: "Test after 0.1 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.1)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(footerElements.footerSectionDivider.backgroundColor?.cgColor,
                           UIColor(hexString: "#999999").cgColor)
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    func getFooterElements(footerViewData: FooterViewData) -> FooterElements {
        let footerContainer = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        let roktPrivacyButton = LinkButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        let partnerPrivacyButton = LinkButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        let footerSectionDivider = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 40))
        let footerHeight = NSLayoutConstraint()
        let footerDividerTopPadding = NSLayoutConstraint()
        let footerDividerHeight = NSLayoutConstraint()
        return FooterElements(footerViewData: footerViewData,
                              footerContainer: footerContainer,
                              footerSectionDivider: footerSectionDivider,
                              footerHeight: footerHeight,
                              footerDividerTopSpacing: footerDividerTopPadding,
                              footerDividerHeight: footerDividerHeight)
    }

}
