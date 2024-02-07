//
//  ProgressBarView.swift
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

import UIKit
internal struct ProgressBarElements {
    let pageIndicator: PageIndicatorViewData?
    let progressContainer: ContainerProperties
    let lowerProgressContainer: ContainerProperties?
    let traitCollection: UITraitCollection
    let preOfferTopSpacing: CGFloat
    let footerDividerTopSpacing: CGFloat
}

private struct DotsElements {
    let backgroundColor: [Int: String]
    let textStyle: TextStyleViewData?
    let count: Int
    let diameter: Float
    let dashesWidth: Float
    let dashesHeight: Float
    let type: PageIndicatorType
    let traitCollection: UITraitCollection
}

private struct TextProgressBarElements {
    let textViewData: TextViewData
    let offerNumber: Int
    let totalOffers: Int
    let container: UIView
}

private struct DotsProgressBarElements {
    let pageIndicator: PageIndicatorViewData
    let totalDots: Int
    let container: UIView
    let traitCollection: UITraitCollection
}

private let defaultLineBreakMode: NSLineBreakMode = .byWordWrapping

internal class ProgressBarView {
    
    internal class func addProgressBarDots(_ elements: ProgressBarElements) {
        
        guard let container = setupLocationContainer(elements),
              let pageIndicator = elements.pageIndicator else {
            return
        }
        
        let totalDots = pageIndicator.seenItems + pageIndicator.unseenItems
        
        if pageIndicator.type == .text,
           let textViewData = pageIndicator.textBasedIndicatorViewData {
            createTextProgressBar(
                TextProgressBarElements(textViewData: textViewData,
                                        offerNumber: pageIndicator.seenItems,
                                        totalOffers: totalDots,
                                        container: container))
        } else {
            createDotsProgressBar(DotsProgressBarElements(pageIndicator: pageIndicator,
                                                          totalDots: totalDots,
                                                          container: container,
                                                          traitCollection: elements.traitCollection))
        }
    }
    
    private class func createTextProgressBar(_ elements: TextProgressBarElements) {
        let label = UILabel()
        label.numberOfLines = 0
        let replacedText = getReplacedText(text: elements.textViewData.text,
                                           offerNumber: elements.offerNumber,
                                           totalOffers: elements.totalOffers)
        label.set(textViewData:
                    TextViewData(text: replacedText,
                                 textStyleViewData: elements.textViewData.textStyleViewData,
                                 padding: elements.textViewData.padding),
                  lineBreakMode: defaultLineBreakMode)
        elements.container.addSubview(label)
        elements.container.layoutIfNeeded()
        elements.container.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(UILayoutPriority(1000), for: .vertical)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(
                equalTo: elements.container.leadingAnchor),
            label.trailingAnchor.constraint(
                equalTo: elements.container.trailingAnchor),
            label.topAnchor.constraint(
                equalTo: elements.container.topAnchor),
            elements.container.bottomAnchor.constraint(
                equalTo: label.bottomAnchor)
        ])
    }
    
    private class func getReplacedText(text: String, offerNumber: Int, totalOffers: Int) -> String {
        return text.replacingOccurrences(of: "[offer]", with: String(offerNumber))
            .replacingOccurrences(of: "[total]", with: String(totalOffers))
    }
    
    private class func createDotsProgressBar(_ elements: DotsProgressBarElements) {
        
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.distribution = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing = CGFloat(elements.pageIndicator.paddingSize)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        for i in 0..<elements.pageIndicator.seenItems {
            stackView.addArrangedSubview(
                // seen progress dots
                createProgressDot(DotsElements(backgroundColor: elements.pageIndicator.backgroundSeen,
                                               textStyle: elements.pageIndicator.textViewDataSeen,
                                               count: elements.pageIndicator.startIndex + i,
                                               diameter: elements.pageIndicator.diameter,
                                               dashesWidth: elements.pageIndicator.dashesWidth,
                                               dashesHeight: elements.pageIndicator.dashesHeight,
                                               type: elements.pageIndicator.type,
                                               traitCollection: elements.traitCollection)))
        }
        for i in elements.pageIndicator.seenItems..<elements.totalDots {
            stackView.addArrangedSubview(
                // unseen progress dots
                createProgressDot(DotsElements(backgroundColor: elements.pageIndicator.backgroundUnseen,
                                               textStyle: elements.pageIndicator.textViewDataUnseen,
                                               count: elements.pageIndicator.startIndex + i,
                                               diameter: elements.pageIndicator.diameter,
                                               dashesWidth: elements.pageIndicator.dashesWidth,
                                               dashesHeight: elements.pageIndicator.dashesHeight,
                                               type: elements.pageIndicator.type,
                                               traitCollection: elements.traitCollection)))
        }
        elements.container.addSubview(stackView)
        stackView.centerXAnchor.constraint(equalTo: elements.container.centerXAnchor).isActive = true
    }
    
    private class func createProgressDot(_ elements: DotsElements) -> UILabel {
        let dot = UILabel(frame: getDotsFrame(type: elements.type,
                                              diameter: elements.diameter,
                                              dashesWidth: elements.dashesWidth,
                                              dashesHeight: elements.dashesHeight))
        dot.backgroundColor = UIColor(colorMap: elements.backgroundColor, elements.traitCollection)
        dot.layer.masksToBounds = true
        dot.textAlignment = .center
        if let textStyle = elements.textStyle {
            dot.set(pageIndicatorStyle: textStyle, text: "\(elements.count)")
        }
        dot.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: CGFloat(dot.frame.width)),
            dot.heightAnchor.constraint(equalToConstant: CGFloat(dot.frame.height))
        ])
        
        if elements.type != .dashes {
            dot.layer.cornerRadius = CGFloat(dot.frame.width/2)
        }
        return dot
    }
    
    private class func getDotsFrame(type: PageIndicatorType,
                                    diameter: Float,
                                    dashesWidth: Float,
                                    dashesHeight: Float) -> CGRect {
        if type == .dashes {
            return CGRect(x: 0, y: 0, width: CGFloat(dashesWidth), height: CGFloat(dashesHeight))
        }
        return CGRect(x: 0, y: 0, width: CGFloat(diameter), height: CGFloat(diameter))
    }
    
    private class func setupLocationContainer(_ elements: ProgressBarElements) -> UIView? {
        elements.progressContainer.container.subviews.forEach({ $0.removeFromSuperview() })
        elements.lowerProgressContainer?.container.subviews.forEach({ $0.removeFromSuperview() })
        guard let pageIndicator = elements.pageIndicator else {
            elements.progressContainer.resizeToZero()
            elements.lowerProgressContainer?.resizeToZero()
            addFooterDividerTopSpacing(lowerProgressContainer: elements.lowerProgressContainer,
                                       footerDividerTopSpacing: elements.footerDividerTopSpacing)
            return nil
        }
        if elements.pageIndicator?.location == .afterOffer {
            elements.progressContainer.resizeToZero()
            if elements.pageIndicator?.type == .text {
                elements.lowerProgressContainer?.height?.isActive = false
            } else {
                elements.lowerProgressContainer?.resizeToHeight(newHeight: getHeight(pageIndicator))
            }
            // preoffer top spacing not applicable to lower progress
            setMargin(pageIndicator, container: elements.lowerProgressContainer, preOfferTopSpacing: 0)
            addFooterDividerTopSpacing(lowerProgressContainer: elements.lowerProgressContainer,
                                       footerDividerTopSpacing: elements.footerDividerTopSpacing)
            return elements.lowerProgressContainer?.container
            
        } else {
            elements.lowerProgressContainer?.resizeToZero()
            if elements.pageIndicator?.type == .text {
                elements.progressContainer.height?.isActive = false
            } else {
                elements.progressContainer.resizeToHeight(newHeight: getHeight(pageIndicator))
            }
            setMargin(pageIndicator,
                      container: elements.progressContainer,
                      preOfferTopSpacing: elements.preOfferTopSpacing)
            addFooterDividerTopSpacing(lowerProgressContainer: elements.lowerProgressContainer,
                                       footerDividerTopSpacing: elements.footerDividerTopSpacing)
            return elements.progressContainer.container
        }
    }
    
    private class func setMargin(_ pageIndicator: PageIndicatorViewData,
                                 container: ContainerProperties?,
                                 preOfferTopSpacing: CGFloat) {
        if let margin = pageIndicator.margin {
            container?.spacingTop?.constant = CGFloat(margin.top)
            container?.spacingRight?.constant = CGFloat(margin.right)
            container?.spacingBottom?.constant = CGFloat(margin.bottom) + preOfferTopSpacing
            container?.spacingLeft?.constant = CGFloat(margin.left)
        } else {
            container?.spacingBottom?.constant = kProgressDotsBottomSpacing + preOfferTopSpacing
        }
    }
    
    private class func getHeight(_ pageIndicator: PageIndicatorViewData) -> CGFloat {
        if pageIndicator.type == .dashes {
            return CGFloat(pageIndicator.dashesHeight)
        }
        return CGFloat(pageIndicator.diameter)
    }
    
    private class func addFooterDividerTopSpacing(lowerProgressContainer: ContainerProperties?,
                                                  footerDividerTopSpacing: CGFloat) {
        // Add footer divider's top margin value to lower progress container
        // This must apply even if there is no lower progress container
        lowerProgressContainer?.spacingBottom?.constant += footerDividerTopSpacing
    }
}
