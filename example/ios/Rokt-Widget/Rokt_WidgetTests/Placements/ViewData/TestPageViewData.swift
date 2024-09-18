//
//  TestPageViewData.swift
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

class TestPageViewData: XCTestCase {
    func test_placement_set_start_page() throws {
        let page = PageViewData(pageId: "", sessionId: "", pageInstanceGuid: "", placementContextJWTToken: "placement-context-jwt", placements:
                                    [PlacementViewData(instanceGuid: "", pageInstanceGuid: "",
                                                       launchDelayMilliseconds: 0, placementLayoutCode: .lightboxLayout,
                                                       offerLayoutCode: "", backgroundColor: ColorMap(), offers: [], titleDivider: nil,
                                                       footerViewData:
                                                        FooterViewData(backgroundColor: nil, roktPrivacyPolicy: nil, partnerPrivacyPolicy: nil,
                                                                       footerDivider: DividerViewDataWithDimensions(isVisible: true,
                                                                                                                    height: 2,
                                                                                                                    margin: .zero),
                                                                       alignment: .end),
                                                       backgroundWithoutFooterViewData: BackgroundWithoutFooterViewData(backgroundColor: nil,
                                                                                                                        cornerRadius: nil,
                                                                                                                        borderThickness: nil,
                                                                                                                        borderColor: nil,
                                                                                                                        padding: nil),
                                                       positiveButton:
                                                        ButtonStylesViewData(defaultStyle:
                                                                                ButtonStyleViewData(textStyleViewData:
                                                                                                        TextStyleViewData(fontFamily: "", fontSize: 0.0,
                                                                                                                          fontColor: ColorMap(), backgroundColor: nil),
                                                                                                    cornerRadius: 0.0, borderThickness: 0.0, borderColor: ColorMap()),
                                                                             pressedStyle: ButtonStyleViewData(textStyleViewData:
                                                                                                                TextStyleViewData(fontFamily: "", fontSize: 0.0,
                                                                                                                                  fontColor: ColorMap(), backgroundColor: nil),
                                                                                                               cornerRadius: 0.0, borderThickness: 0.0, borderColor: ColorMap())),
                                                       negativeButton:
                                                        ButtonStylesViewData(defaultStyle:
                                                                                ButtonStyleViewData(textStyleViewData:
                                                                                                        TextStyleViewData(fontFamily: "", fontSize: 0.0,
                                                                                                                          fontColor: ColorMap(), backgroundColor: nil),
                                                                                                    cornerRadius: 0.0, borderThickness: 0.0, borderColor: ColorMap()),
                                                                             pressedStyle: ButtonStyleViewData(textStyleViewData:
                                                                                                                TextStyleViewData(fontFamily: "", fontSize: 0.0,
                                                                                                                                  fontColor: ColorMap(), backgroundColor: nil),
                                                                                                               cornerRadius: 0.0, borderThickness: 0.0, borderColor: ColorMap())),
                                                       navigateToButtonData: nil,
                                                       navigateToButtonStyles: nil,
                                                       navigateToDivider: nil,
                                                       positiveButtonFirst: true, buttonsStacked: true, margin: FrameAlignment(top: 0, right: 0, bottom: 0, left: 0),
                                                       startDate: Date(), responseReceivedDate: Date() ,urlInExternalBrowser: false, cornerRadius: 0, borderThickness: 0, borderColor: nil,
                                                       placementsJWTToken: "placements-token", 
                                                       placementId: "")])

        page.setStartDate(startDate: Date(timeIntervalSince1970: 0))
        
        XCTAssertEqual(page.placements?.first?.startDate.timeIntervalSince1970, 0)

        page.setStartDate(startDate: Date(timeIntervalSince1970: 0))

        XCTAssertEqual(page.placements?.first?.startDate.timeIntervalSince1970, 0)
        XCTAssertEqual(page.placementContextJWTToken, "placement-context-jwt")
    }
}
