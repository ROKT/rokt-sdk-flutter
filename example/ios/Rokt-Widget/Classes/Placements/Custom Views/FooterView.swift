//
//  File.swift
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

struct FooterElements {
    let footerViewData: FooterViewData
    let footerContainer: UIView
    let footerSectionDivider: UIView
    let footerHeight: NSLayoutConstraint
    let footerDividerTopSpacing: NSLayoutConstraint
    let footerDividerHeight: NSLayoutConstraint
}

class FooterView {
    internal class func setUpFooter(_ footerElements: FooterElements,
                                    placementButtonActions: PlacementViewButtonActions) {
        let roktPrivacy = LinkButton()
        let partnerPrivacy = LinkButton()
        attachButtonAction(linkButton: roktPrivacy,
                           placementButtonActions: placementButtonActions)
        attachButtonAction(linkButton: partnerPrivacy,
                           placementButtonActions: placementButtonActions)
        createView(footerElements, roktPrivacy: roktPrivacy, partnerPrivacy: partnerPrivacy)
    }
    
    internal class func createView(_ footerElements: FooterElements,
                                   roktPrivacy: LinkButton,
                                   partnerPrivacy: LinkButton) {
        if let backgroundColor = footerElements.footerViewData.backgroundColor {
            footerElements.footerContainer.backgroundColor = UIColor(colorMap:
                backgroundColor, footerElements.footerContainer.traitCollection)
        }
        footerElements.footerContainer.subviews.forEach({ $0.removeFromSuperview() })
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = getStackViewAlignment(alignment: footerElements.footerViewData.alignment)
        roktPrivacy.titleLabel?.numberOfLines = 0
        setLinkButton(linkButton: roktPrivacy,
                      linkViewData: footerElements.footerViewData.roktPrivacyPolicy,
                      editingFinished: {
            resizeFooter(footerElements,
                         roktPrivacyButton: roktPrivacy,
                         partnerPrivacyButton: partnerPrivacy)})
        stackView.addArrangedSubview(roktPrivacy)
        partnerPrivacy.titleLabel?.numberOfLines = 0
        setLinkButton(linkButton: partnerPrivacy,
                      linkViewData: footerElements.footerViewData.partnerPrivacyPolicy,
                      editingFinished: {
            resizeFooter(footerElements,
                         roktPrivacyButton: roktPrivacy,
                         partnerPrivacyButton: partnerPrivacy)}
        )
        stackView.addArrangedSubview(partnerPrivacy)
        footerElements.footerContainer.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: footerElements.footerContainer.topAnchor,
                                           constant: CGFloat(kDefaultSeparation)),
            roktPrivacy.bottomAnchor.constraint(equalTo: partnerPrivacy.topAnchor,
                                                constant: CGFloat(-kDefaultSeparation)),
            stackView.leadingAnchor.constraint(equalTo: footerElements.footerContainer.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: footerElements.footerContainer.trailingAnchor)
        ])
        setupFooterDivider(footerElements)
    }
    
    private class func getStackViewAlignment(alignment: ViewAlignment) -> UIStackView.Alignment {
        switch alignment {
        case .start:
            return .leading
        case .center:
            return .center
        case .end:
            return .trailing
        default:
            return .trailing
        }
    }
    
    private class func setupFooterDivider(_ footerElements: FooterElements) {
        if let dividerBackgroundColor = footerElements.footerViewData.footerDivider.backgroundColor {
            footerElements.footerSectionDivider.backgroundColor =
            UIColor(colorMap: dividerBackgroundColor,
                    footerElements.footerSectionDivider.traitCollection)
            
        }
        if !footerElements.footerViewData.footerDivider.isVisible {
            footerElements.footerSectionDivider.isHidden = true
            footerElements.footerDividerTopSpacing.constant = 10
            footerElements.footerDividerHeight.constant = 0
        }
    }
    
    private class func resizeFooter(_ footerElements: FooterElements,
                                    roktPrivacyButton: LinkButton,
                                    partnerPrivacyButton: LinkButton) {
        if footerElements.footerViewData.roktPrivacyPolicy == nil &&
            footerElements.footerViewData.partnerPrivacyPolicy == nil {
            footerElements.footerSectionDivider.isHidden = true
            footerElements.footerContainer.isHidden = true
            footerElements.footerHeight.constant = 0
        } else {
            footerElements.footerContainer.setNeedsLayout()
            footerElements.footerContainer.layoutIfNeeded()
            
            var footerPadding = CGFloat(kDefaultSeparation) * 2
            
            if footerElements.footerViewData.partnerPrivacyPolicy != nil &&
                footerElements.footerViewData.roktPrivacyPolicy != nil {
                
                footerPadding = CGFloat(kDefaultSeparation) * 3
                footerElements.footerHeight.constant = (roktPrivacyButton.titleLabel?.frame.size.height
                    ?? 0) + (partnerPrivacyButton.titleLabel?.frame.size.height ?? 0) + footerPadding
               
            } else if footerElements.footerViewData.partnerPrivacyPolicy != nil {
                footerElements.footerHeight.constant =
                    (partnerPrivacyButton.titleLabel?.frame.size.height ?? 0) + footerPadding
            } else if footerElements.footerViewData.roktPrivacyPolicy != nil {
                footerElements.footerHeight.constant =
                    (roktPrivacyButton.titleLabel?.frame.size.height ?? 0) + footerPadding
            }
        }
    }
    
    private class func setLinkButton(linkButton: LinkButton, linkViewData: LinkViewData?,
                                     editingFinished: (() -> Void)? = nil) {
        if let privacy = linkViewData {
            linkButton.set(linkViewData: privacy, editingFinished: editingFinished)
        } else {
            linkButton.setTitle("", for: .normal)
            linkButton.isHidden = true
            linkButton.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
    }
    
    private class func attachButtonAction(linkButton: LinkButton,
                                          placementButtonActions: PlacementViewButtonActions) {
        linkButton.addTarget(placementButtonActions,
                             action: #selector(placementButtonActions.footerLinkButtonTapped),
                             for: .touchUpInside)
    }
}
