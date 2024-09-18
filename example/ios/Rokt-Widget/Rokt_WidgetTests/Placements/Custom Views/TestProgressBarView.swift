//
//  TestProgressBarView.swift
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

class TestProgressBarView: XCTestCase {
    let preOfferTopSpacing = CGFloat(10)
    func test_empty_page_indicator() {
        let progressBarElements = getProgressBarElements(nil)

        ProgressBarView.addProgressBarDots(progressBarElements)

        XCTAssertEqual(progressBarElements.progressContainer.height?.constant, 0)
        XCTAssertEqual(progressBarElements.progressContainer.spacingBottom?.constant, 0)
        XCTAssertEqual(progressBarElements.progressContainer.container.subviews.count, 0)
    }

    func test_valid_all_seen_page_indicator() {
        let pageIndicator = PageIndicatorViewData(type: .circle,
                                                  seenItems: 5,
                                                  unseenItems: 0,
                                                  backgroundSeen: [0: "#BBBBBB", 1: "#222222"],
                                                  backgroundUnseen: [0: "#999999", 1: "#333333"],
                                                  textViewDataSeen: nil,
                                                  textViewDataUnseen: nil,
                                                  paddingSize: 10,
                                                  diameter: 40,
                                                  startIndex: 1,
                                                  location: .beforeOffer,
                                                  dashesWidth: 32,
                                                  dashesHeight: 4,
                                                  margin: nil,
                                                  textBasedIndicatorViewData: nil)
        let progressBarElements = getProgressBarElements(pageIndicator)

        ProgressBarView.addProgressBarDots(progressBarElements)

        XCTAssertEqual(progressBarElements.progressContainer.container.subviews[0].subviews.count, 5)
        XCTAssertEqual(progressBarElements.progressContainer.height?.constant, 40)
        XCTAssertEqual(progressBarElements.progressContainer.spacingBottom?.constant, kProgressDotsBottomSpacing + preOfferTopSpacing)
        for i in 0...4 {
            let dot = progressBarElements.progressContainer.container.subviews[0].subviews[i] as! UILabel
            XCTAssertEqual(dot.backgroundColor?.cgColor, UIColor(hexString: "#BBBBBB").cgColor)
            XCTAssertEqual(dot.frame.width, 40)
            XCTAssertEqual(dot.frame.height, 40)
            XCTAssertEqual(dot.layer.cornerRadius, 40/2)
        }

    }

    func test_valid_all_unseen_page_indicator() {
        let pageIndicator = PageIndicatorViewData(type: .circle,
                                                  seenItems: 0,
                                                  unseenItems: 3,
                                                  backgroundSeen: [0: "#BBBBBB", 1: "#222222"],
                                                  backgroundUnseen: [0: "#999999", 1: "#333333"],
                                                  textViewDataSeen: nil,
                                                  textViewDataUnseen: nil,
                                                  paddingSize: 10,
                                                  diameter: 30,
                                                  startIndex: 1,
                                                  location: .beforeOffer,
                                                  dashesWidth: 32,
                                                  dashesHeight: 4,
                                                  margin: FrameAlignment(top: 10,
                                                                         right: 20,
                                                                         bottom: 30,
                                                                         left: 40),
                                                  textBasedIndicatorViewData: nil)
        let progressBarElements = getProgressBarElements(pageIndicator)

        ProgressBarView.addProgressBarDots(progressBarElements)

        XCTAssertEqual(progressBarElements.progressContainer.container.subviews[0].subviews.count, 3)
        XCTAssertEqual(progressBarElements.progressContainer.height?.constant, 30)
        XCTAssertEqual(progressBarElements.progressContainer.spacingTop?.constant, 10)
        XCTAssertEqual(progressBarElements.progressContainer.spacingRight?.constant, 20)
        XCTAssertEqual(progressBarElements.progressContainer.spacingBottom?.constant, 30 + preOfferTopSpacing)
        XCTAssertEqual(progressBarElements.progressContainer.spacingLeft?.constant, 40)
        for i in 0...2 {
            let dot = progressBarElements.progressContainer.container.subviews[0].subviews[i] as! UILabel
            XCTAssertEqual(dot.backgroundColor?.cgColor, UIColor(hexString: "#999999").cgColor)
            XCTAssertEqual(dot.frame.width, 30)
            XCTAssertEqual(dot.frame.height, 30)
            XCTAssertEqual(dot.layer.cornerRadius, 30/2)
        }

    }

    func test_valid_mix_seen_unseen_page_indicator() {
        let pageIndicator = PageIndicatorViewData(type: .circle,
                                                  seenItems: 3,
                                                  unseenItems: 2,
                                                  backgroundSeen: [0: "#BBBBBB", 1: "#222222"],
                                                  backgroundUnseen: [0: "#999999", 1: "#333333"],
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
        let progressBarElements = getProgressBarElements(pageIndicator)

        ProgressBarView.addProgressBarDots(progressBarElements)

        XCTAssertEqual(progressBarElements.progressContainer.container.subviews[0].subviews.count, 5)
        XCTAssertEqual(progressBarElements.progressContainer.height?.constant, 30)
        XCTAssertEqual(progressBarElements.progressContainer.spacingBottom?.constant, kProgressDotsBottomSpacing + preOfferTopSpacing)
        for i in 0...2 {
            let dot = progressBarElements.progressContainer.container.subviews[0].subviews[i] as! UILabel
            XCTAssertEqual(dot.backgroundColor?.cgColor, UIColor(hexString: "#BBBBBB").cgColor)
            XCTAssertEqual(dot.frame.width, 30)
            XCTAssertEqual(dot.frame.height, 30)
            XCTAssertEqual(dot.layer.cornerRadius, 30/2)
        }
        for i in 3...4 {
            let dot = progressBarElements.progressContainer.container.subviews[0].subviews[i] as! UILabel
            XCTAssertEqual(dot.backgroundColor?.cgColor, UIColor(hexString: "#999999").cgColor)
            XCTAssertEqual(dot.frame.width, 30)
            XCTAssertEqual(dot.frame.height, 30)
            XCTAssertEqual(dot.layer.cornerRadius, 30/2)
        }

    }

    func test_valid_all_unseen_lower_progress_indicator() {
        let pageIndicator = PageIndicatorViewData(type: .circle,
                                                  seenItems: 0,
                                                  unseenItems: 3,
                                                  backgroundSeen: [0: "#BBBBBB", 1: "#222222"],
                                                  backgroundUnseen: [0: "#999999", 1: "#333333"],
                                                  textViewDataSeen: nil,
                                                  textViewDataUnseen: nil,
                                                  paddingSize: 10,
                                                  diameter: 30,
                                                  startIndex: 1,
                                                  location: .afterOffer,
                                                  dashesWidth: 32,
                                                  dashesHeight: 4,
                                                  margin: FrameAlignment(top: 10,
                                                                         right: 20,
                                                                         bottom: 30,
                                                                         left: 40),
                                                  textBasedIndicatorViewData: nil)
        let progressBarElements = getProgressBarElements(pageIndicator)

        ProgressBarView.addProgressBarDots(progressBarElements)

        XCTAssertEqual(progressBarElements.lowerProgressContainer?.container.subviews[0].subviews.count, 3)
        XCTAssertEqual(progressBarElements.lowerProgressContainer?.height?.constant, 30)
        XCTAssertEqual(progressBarElements.lowerProgressContainer?.spacingTop?.constant, 10)
        XCTAssertEqual(progressBarElements.lowerProgressContainer?.spacingRight?.constant, 20)
        XCTAssertEqual(progressBarElements.lowerProgressContainer?.spacingBottom?.constant, 30)
        XCTAssertEqual(progressBarElements.lowerProgressContainer?.spacingLeft?.constant, 40)
        for i in 0...2 {
            let dot = progressBarElements.lowerProgressContainer?.container.subviews[0].subviews[i] as! UILabel
            XCTAssertEqual(dot.backgroundColor?.cgColor, UIColor(hexString: "#999999").cgColor)
            XCTAssertEqual(dot.frame.width, 30)
            XCTAssertEqual(dot.frame.height, 30)
            XCTAssertEqual(dot.layer.cornerRadius, 30/2)
        }

    }

    func test_valid_mix_seen_unseen_lower_progress_indicator() {
        let pageIndicator = PageIndicatorViewData(type: .circle,
                                                  seenItems: 3,
                                                  unseenItems: 2,
                                                  backgroundSeen: [0: "#BBBBBB", 1: "#222222"],
                                                  backgroundUnseen: [0: "#999999", 1: "#333333"],
                                                  textViewDataSeen: nil,
                                                  textViewDataUnseen: nil,
                                                  paddingSize: 10,
                                                  diameter: 30,
                                                  startIndex: 2,
                                                  location: .afterOffer,
                                                  dashesWidth: 32,
                                                  dashesHeight: 4,
                                                  margin: nil,
                                                  textBasedIndicatorViewData: nil)
        let progressBarElements = getProgressBarElements(pageIndicator)

        ProgressBarView.addProgressBarDots(progressBarElements)

        XCTAssertEqual(progressBarElements.lowerProgressContainer?.container.subviews[0].subviews.count, 5)
        XCTAssertEqual(progressBarElements.lowerProgressContainer?.height?.constant, 30)
        XCTAssertEqual(progressBarElements.lowerProgressContainer?.spacingBottom?.constant, kProgressDotsBottomSpacing)
        for i in 0...2 {
            let dot = progressBarElements.lowerProgressContainer?.container.subviews[0].subviews[i] as! UILabel
            XCTAssertEqual(dot.backgroundColor?.cgColor, UIColor(hexString: "#BBBBBB").cgColor)
            XCTAssertEqual(dot.frame.width, 30)
            XCTAssertEqual(dot.frame.height, 30)
            XCTAssertEqual(dot.layer.cornerRadius, 30/2)
        }
        for i in 3...4 {
            let dot = progressBarElements.lowerProgressContainer?.container.subviews[0].subviews[i] as! UILabel
            XCTAssertEqual(dot.backgroundColor?.cgColor, UIColor(hexString: "#999999").cgColor)
            XCTAssertEqual(dot.frame.width, 30)
            XCTAssertEqual(dot.frame.height, 30)
            XCTAssertEqual(dot.layer.cornerRadius, 30/2)
        }
    }

    func test_valid_mix_seen_unseen_page_indicator_with_text() {
        let pageIndicator = PageIndicatorViewData(type: .circleWithText,
                                                  seenItems: 3,
                                                  unseenItems: 2,
                                                  backgroundSeen: [0: "#BBBBBB", 1: "#222222"],
                                                  backgroundUnseen: [0: "#999999", 1: "#333333"],
                                                  textViewDataSeen:
            TextStyleViewData(fontFamily: "Arial",
                              fontSize: 9,
                              fontColor: [0: "#FFFFFF", 1: "#000000"],
                              backgroundColor: [0: "#BBBBBB", 1: "#222222"]),
                                                  textViewDataUnseen:
            TextStyleViewData(fontFamily: "Arial",
            fontSize: 9,
            fontColor: [0: "#000000", 1: "#FFFFFF"],
            backgroundColor: [0: "#999999", 1: "#333333"]),
                                                  paddingSize: 10,
                                                  diameter: 30,
                                                  startIndex: 1,
                                                  location: .beforeOffer,
                                                  dashesWidth: 32,
                                                  dashesHeight: 4,
                                                  margin: nil,
                                                  textBasedIndicatorViewData: nil)
        let progressBarElements = getProgressBarElements(pageIndicator)

        ProgressBarView.addProgressBarDots(progressBarElements)

        XCTAssertEqual(progressBarElements.progressContainer.container.subviews[0].subviews.count, 5)
        XCTAssertEqual(progressBarElements.progressContainer.height?.constant, 30)
        XCTAssertEqual(progressBarElements.progressContainer.spacingBottom?.constant, kProgressDotsBottomSpacing + preOfferTopSpacing)
        for i in 0...2 {
            let dot = progressBarElements.progressContainer.container.subviews[0].subviews[i] as! UILabel
            XCTAssertEqual(dot.backgroundColor?.cgColor, UIColor(hexString: "#BBBBBB").cgColor)
            XCTAssertEqual(dot.frame.width, 30)
            XCTAssertEqual(dot.frame.height, 30)
            XCTAssertEqual(dot.layer.cornerRadius, 30/2)

            XCTAssertEqual(dot.text, "\(i+1)")
            XCTAssertEqual(dot.textColor.cgColor, UIColor(hexString: "#FFFFFF").cgColor)
        }
        for i in 3...4 {
            let dot = progressBarElements.progressContainer.container.subviews[0].subviews[i] as! UILabel
            XCTAssertEqual(dot.backgroundColor?.cgColor, UIColor(hexString: "#999999").cgColor)
            XCTAssertEqual(dot.frame.width, 30)
            XCTAssertEqual(dot.frame.height, 30)
            XCTAssertEqual(dot.layer.cornerRadius, 30/2)

            XCTAssertEqual(dot.text, "\(i+1)")
            XCTAssertEqual(dot.textColor.cgColor, UIColor(hexString: "#000000").cgColor)
        }

    }

    func test_valid_mix_seen_unseen_page_indicator_with_text_start_from_three() {
        let startIndex = 3
        let pageIndicator = PageIndicatorViewData(type: .circleWithText,
                                                  seenItems: 3,
                                                  unseenItems: 2,
                                                  backgroundSeen: [0: "#BBBBBB", 1: "#222222"],
                                                  backgroundUnseen: [0: "#999999", 1: "#333333"],
                                                  textViewDataSeen:
            TextStyleViewData(fontFamily: "Arial",
                              fontSize: 9,
                              fontColor: [0: "#FFFFFF", 1: "#000000"],
                              backgroundColor: [0: "#BBBBBB", 1: "#222222"]),
                                                  textViewDataUnseen:
            TextStyleViewData(fontFamily: "Arial",
            fontSize: 9,
            fontColor: [0: "#000000", 1: "#FFFFFF"],
            backgroundColor: [0: "#999999", 1: "#333333"]),
                                                  paddingSize: 10,
                                                  diameter: 30,
                                                  startIndex: startIndex,
                                                  location: .beforeOffer,
                                                  dashesWidth: 32,
                                                  dashesHeight: 4,
                                                  margin: FrameAlignment(top: 10,
                                                                         right: 20,
                                                                         bottom: 30,
                                                                         left: 40),
                                                  textBasedIndicatorViewData: nil)
        let progressBarElements = getProgressBarElements(pageIndicator)

        ProgressBarView.addProgressBarDots(progressBarElements)

        XCTAssertEqual(progressBarElements.progressContainer.container.subviews[0].subviews.count, 5)
        XCTAssertEqual(progressBarElements.progressContainer.height?.constant, 30)
        XCTAssertEqual(progressBarElements.progressContainer.spacingTop?.constant, 10)
        XCTAssertEqual(progressBarElements.progressContainer.spacingRight?.constant, 20)
        XCTAssertEqual(progressBarElements.progressContainer.spacingBottom?.constant, 30 + preOfferTopSpacing)
        XCTAssertEqual(progressBarElements.progressContainer.spacingLeft?.constant, 40)
        for i in 0...2 {
            let dot = progressBarElements.progressContainer.container.subviews[0].subviews[i] as! UILabel
            XCTAssertEqual(dot.backgroundColor?.cgColor, UIColor(hexString: "#BBBBBB").cgColor)
            XCTAssertEqual(dot.frame.width, 30)
            XCTAssertEqual(dot.frame.height, 30)
            XCTAssertEqual(dot.layer.cornerRadius, 30/2)

            XCTAssertEqual(dot.text, "\(i + startIndex)")
            XCTAssertEqual(dot.textColor.cgColor, UIColor(hexString: "#FFFFFF").cgColor)
        }
        for i in 3...4 {
            let dot = progressBarElements.progressContainer.container.subviews[0].subviews[i] as! UILabel
            XCTAssertEqual(dot.backgroundColor?.cgColor, UIColor(hexString: "#999999").cgColor)
            XCTAssertEqual(dot.frame.width, 30)
            XCTAssertEqual(dot.frame.height, 30)
            XCTAssertEqual(dot.layer.cornerRadius, 30/2)

            XCTAssertEqual(dot.text, "\(i + startIndex)")
            XCTAssertEqual(dot.textColor.cgColor, UIColor(hexString: "#000000").cgColor)
        }

    }

    func test_empty_page_indicator_on_second_call() {
        let pageIndicator = PageIndicatorViewData(type: .circle,
                                                  seenItems: 5,
                                                  unseenItems: 0,
                                                  backgroundSeen: [0: "#BBBBBB", 1: "#222222"],
                                                  backgroundUnseen: [0: "#999999", 1: "#333333"],
                                                  textViewDataSeen: nil,
                                                  textViewDataUnseen: nil,
                                                  paddingSize: 10,
                                                  diameter: 40,
                                                  startIndex: 1,
                                                  location: .beforeOffer,
                                                  dashesWidth: 32,
                                                  dashesHeight: 4,
                                                  margin: nil,
                                                  textBasedIndicatorViewData: nil)
        var progressBarElements = getProgressBarElements(pageIndicator)

        ProgressBarView.addProgressBarDots(progressBarElements)
        progressBarElements = getProgressBarElements(nil)

        ProgressBarView.addProgressBarDots(progressBarElements)

        XCTAssertEqual(progressBarElements.progressContainer.height?.constant, 0)
        XCTAssertEqual(progressBarElements.progressContainer.spacingBottom?.constant, 0)
        XCTAssertEqual(progressBarElements.progressContainer.container.subviews.count, 0)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func getProgressBarElements(_ pageIndicator: PageIndicatorViewData?) -> ProgressBarElements {
        let parentView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        let progressDotsHeight = NSLayoutConstraint()
        let progressDotsTopSpacing = NSLayoutConstraint()
        let progressDotsRightSpacing = NSLayoutConstraint()
        let progressDotsBottomSpacing = NSLayoutConstraint()
        let progressDotsLeftSpacing = NSLayoutConstraint()
        let traitCollection = parentView.traitCollection
        let lowerProgressView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        let lowerProgressHeight = NSLayoutConstraint()
        let lowerProgressTopSpacing = NSLayoutConstraint()
        let lowerProgressRightSpacing = NSLayoutConstraint()
        let lowerProgressBottomSpacing = NSLayoutConstraint()
        let lowerProgressLeftSpacing = NSLayoutConstraint()
        return ProgressBarElements(pageIndicator: pageIndicator,
                                   progressContainer:
                                    ContainerProperties (container: parentView,
                                                         height: progressDotsHeight,
                                                         spacingTop: progressDotsTopSpacing,
                                                         spacingRight: progressDotsRightSpacing,
                                                         spacingBottom: progressDotsBottomSpacing,
                                                         spacingLeft: progressDotsLeftSpacing),
                                   lowerProgressContainer:
                                    ContainerProperties (container: lowerProgressView,
                                                         height: lowerProgressHeight,
                                                         spacingTop: lowerProgressTopSpacing,
                                                         spacingRight: lowerProgressRightSpacing,
                                                         spacingBottom: lowerProgressBottomSpacing,
                                                         spacingLeft: lowerProgressLeftSpacing),
                                   traitCollection: traitCollection,
                                   preOfferTopSpacing: preOfferTopSpacing,
                                   footerDividerTopSpacing: 0)
    }

}
