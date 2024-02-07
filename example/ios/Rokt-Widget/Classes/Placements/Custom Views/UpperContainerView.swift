//
//  UpperContainerView.swift
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

struct OverlayUpperContainerViewElements {
    let backgroundWithoutFooterViewData: BackgroundWithoutFooterViewData
    let scrollView: UIScrollView
    let scrollContentView: UIView
    let buttonViewContainer: UIView
    let lowerProgressBar: UIView
}

struct EmbeddedUpperContainerViewElements {
    let backgroundWithoutFooterViewData: BackgroundWithoutFooterViewData
    let container: UIView
    let roktOfferView: RoktOfferView
    let lowerProgressBar: UIView
    let paddingTop: NSLayoutConstraint
    let paddingRight: NSLayoutConstraint
    let paddingBottom: NSLayoutConstraint
    let paddingLeft: NSLayoutConstraint
    let footerRealignElements: EmbeddedFooterRealignElements
}

struct EmbeddedFooterRealignElements {
    // footer elements that need to be realigned if padding adjusted
    let footerSectionDivider: UIView
    let footerSectionDividerLeftSpacing: NSLayoutConstraint
    let footerSectionDividerRightSpacing: NSLayoutConstraint
    let footerContainer: UIView
    let footerLeftSpacing: NSLayoutConstraint
    let footerRightSpacing: NSLayoutConstraint
}

struct UpperContainerViewElements {
    let backgroundWithoutFooterViewData: BackgroundWithoutFooterViewData
    let container: UIView
    let contentView: UIView
    let lowerProgressBar: UIView
    let padding: FrameAlignment?
}

class UpperContainerView {
    
    internal class func setUpEmbeddedUpperContainerView(
        _ elements: EmbeddedUpperContainerViewElements) {
        guard let padding = elements.backgroundWithoutFooterViewData.padding
        else {
            setUpUpperContainerView(UpperContainerViewElements(
                backgroundWithoutFooterViewData: elements.backgroundWithoutFooterViewData,
                container: elements.container,
                contentView: elements.roktOfferView,
                lowerProgressBar: elements.lowerProgressBar,
                padding: nil))
            return
        }
        // adjust embedded placement for padding
        elements.paddingTop.constant += CGFloat(padding.top)
        elements.paddingRight.constant += CGFloat(padding.right)
        elements.paddingBottom.constant += CGFloat(padding.bottom)
        elements.paddingLeft.constant += CGFloat(padding.left)
        let upperContainerView = setUpUpperContainerView(UpperContainerViewElements(
            backgroundWithoutFooterViewData: elements.backgroundWithoutFooterViewData,
            container: elements.container,
            contentView: elements.roktOfferView,
            lowerProgressBar: elements.lowerProgressBar,
            padding: padding))
        // if upper container padded, footer must be adjusted
        layoutFooter(upperContainerView: upperContainerView,
                     footerRealignElements: elements.footerRealignElements)
    }
    
    internal class func setUpOverlayUpperContainerView(
        _ elements: OverlayUpperContainerViewElements) {
        // setup for overlay views. padding not supported
        let scrollViewElements = UpperContainerViewElements(
            backgroundWithoutFooterViewData: elements.backgroundWithoutFooterViewData,
            container: elements.scrollView,
            contentView: elements.scrollContentView,
            lowerProgressBar: elements.lowerProgressBar,
            padding: nil)
        setUpUpperContainerView(scrollViewElements)
        
        let buttonViewContainerElements = UpperContainerViewElements(
            backgroundWithoutFooterViewData: elements.backgroundWithoutFooterViewData,
            container: elements.buttonViewContainer,
            contentView: elements.scrollContentView,
            lowerProgressBar: elements.lowerProgressBar,
            padding: nil)
        setUpUpperContainerView(buttonViewContainerElements)
    }
    
    private class func layoutFooter(upperContainerView: UIView,
                                    footerRealignElements: EmbeddedFooterRealignElements) {
        // use upper container anchors instead of offer view
        footerRealignElements.footerLeftSpacing.isActive = false
        footerRealignElements.footerRightSpacing.isActive = false
        footerRealignElements.footerSectionDividerLeftSpacing.isActive = false
        footerRealignElements.footerSectionDividerRightSpacing.isActive = false
        NSLayoutConstraint.activate([
            footerRealignElements.footerSectionDivider.topAnchor.constraint(
                equalTo: upperContainerView.bottomAnchor),
            footerRealignElements.footerSectionDivider.leadingAnchor.constraint(
                equalTo: upperContainerView.leadingAnchor),
            footerRealignElements.footerSectionDivider.trailingAnchor.constraint(
                equalTo: upperContainerView.trailingAnchor),
            footerRealignElements.footerContainer.leadingAnchor.constraint(
                equalTo: upperContainerView.leadingAnchor),
            footerRealignElements.footerContainer.trailingAnchor.constraint(
                equalTo: upperContainerView.trailingAnchor)
        ])
    }
    
    @discardableResult
    private class func setUpUpperContainerView(
        _ elements: UpperContainerViewElements) -> UIView {
        let upperContainerView = UIView(frame: elements.container.bounds)
        upperContainerView.translatesAutoresizingMaskIntoConstraints = false
        elements.container.clipsToBounds = true
        elements.container.addSubview(upperContainerView)
        let zeroPadding = FrameAlignment(top: 0, right: 0, bottom: 0, left: 0)
        layoutUpperContainerView(upperContainerView: upperContainerView,
                                 padding: elements.padding ?? zeroPadding,
                                 contentView: elements.contentView,
                                 lowerProgressBar: elements.lowerProgressBar)
        applyBackgroundWithoutFooterStyles(upperContainerView: upperContainerView,
                                          backgroundWithoutFooterViewData:
                                            elements.backgroundWithoutFooterViewData)
        elements.container.sendSubviewToBack(upperContainerView)
        return upperContainerView
    }
    
    private class func layoutUpperContainerView(upperContainerView: UIView,
                                                padding: FrameAlignment,
                                                contentView: UIView,
                                                lowerProgressBar: UIView) {
        NSLayoutConstraint.activate([
            upperContainerView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: CGFloat(-padding.top)),
            upperContainerView.bottomAnchor.constraint(
                equalTo: lowerProgressBar.bottomAnchor,
                constant: CGFloat(padding.bottom)),
            upperContainerView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: CGFloat(-padding.left)),
            upperContainerView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: CGFloat(padding.right))
        ])
    }
    
    private class func applyBackgroundWithoutFooterStyles(
        upperContainerView: UIView,
        backgroundWithoutFooterViewData: BackgroundWithoutFooterViewData) {
        if let backgroundColor = backgroundWithoutFooterViewData.backgroundColor {
            upperContainerView.backgroundColor = UIColor(
                colorMap: backgroundColor, upperContainerView.traitCollection)
        }
        upperContainerView.layer.cornerRadius = CGFloat(
            backgroundWithoutFooterViewData.cornerRadius ?? 0)
        upperContainerView.layer.borderWidth = CGFloat(
            backgroundWithoutFooterViewData.borderThickness ?? 0)
        if let borderColor = backgroundWithoutFooterViewData.borderColor {
            upperContainerView.layer.borderColor = UIColor(
                colorMap: borderColor, upperContainerView.traitCollection).cgColor
        }
    }
}
