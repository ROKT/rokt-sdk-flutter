//
//  OfferButtonTemplates.swift
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

class OfferButtonsController {
    // in case more buttons are introduced
    private enum ButtonOrder {
        case positiveFirst
        case negativeFirst
    }

    var yesButton: OfferButton
    var noButton: OfferButton?

    private let totalHorizontalPadding: CGFloat = 8
    private let totalVerticalPadding: CGFloat = 8
    private let spacing: CGFloat = 15
    private let stackedSpacing: CGFloat = 15
    private let defaultFrame = CGRect(x: 0, y: 0, width: 100, height: 40)
    private var leadingPadding: CGFloat
    private var trailingPadding: CGFloat
    private let isNegativeButtonVisible: Bool

    private var buttons: [OfferButton] = []
    
    init(
        positiveButtonStyle: ButtonStylesViewData,
        negativeButtonStyle: ButtonStylesViewData?,
        traitCollection: UITraitCollection,
        needInitialPadding: Bool = false,
        isNegativeButtonVisible: Bool = true
    ) {
        if needInitialPadding {
            self.leadingPadding = spacing
            self.trailingPadding = spacing
        } else {
            self.leadingPadding = 0
            self.trailingPadding = 0
        }
        
        yesButton = OfferButton(frame: defaultFrame,
                                buttonStyles: positiveButtonStyle,
                                traitCollection: traitCollection)
        buttons.append(yesButton)

        if isNegativeButtonVisible, let negativeButtonStyle {
            noButton = OfferButton(frame: defaultFrame,
                                   buttonStyles: negativeButtonStyle,
                                   traitCollection: traitCollection)
        }

        if let noButton {
            buttons.append(noButton)
        }

        self.isNegativeButtonVisible = isNegativeButtonVisible
    }
    
    func addButtonsToView(_ parentView: UIView?,
                          positiveButtonFirst: Bool,
                          buttonStacked: Bool,
                          offerButtonsActions: OfferButtonsActions,
                          buttonsContainerHeight: NSLayoutConstraint) {
        attachButtons(parentView,
                      positiveButtonFirst: positiveButtonFirst,
                      buttonStacked: buttonStacked,
                      buttonsContainerHeight: buttonsContainerHeight)
        attachButtonAction(offerButtonsActions: offerButtonsActions)

        setContentHuggingAndCompressionResistanceForExpansionIn(buttons: buttons)
    }

    // ensures that a `button` that's nested inside a `UIStackView` with a `.fill` distribution
    // will expand/shrink the `UIStackView` based on its content
    private func setContentHuggingAndCompressionResistanceForExpansionIn(
        buttons: [UIButton],
        axis: NSLayoutConstraint.Axis = .vertical
    ) {
        buttons.forEach {
            $0.setContentHuggingPriority(.defaultHigh, for: axis)
            $0.setContentCompressionResistancePriority(.required, for: axis)
        }
    }
    
    private func attachButtons(_ optionalParentView: UIView?,
                               positiveButtonFirst: Bool,
                               buttonStacked: Bool,
                               buttonsContainerHeight: NSLayoutConstraint) {
        guard let parentView = optionalParentView else { return }

        parentView.subviews.forEach({ $0.removeFromSuperview() })
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let buttonOrder: ButtonOrder = positiveButtonFirst ? .positiveFirst : .negativeFirst
        let stackAxis: NSLayoutConstraint.Axis = buttonStacked ? .vertical : .horizontal

        if buttonStacked {
            fillStackedTemplateWithButtonOrder(
                stackView,
                axis: stackAxis,
                stackSpacing: spacing,
                buttonsContainerHeightConstraint: buttonsContainerHeight,
                buttonOrder: buttonOrder
            )
        } else {
            if positiveButtonFirst {
                templateUnStackedPositiveFirst(stackView: stackView, buttonsContainerHeight: buttonsContainerHeight)
            } else {
                templateUnStackedNegativeFirst(stackView: stackView, buttonsContainerHeight: buttonsContainerHeight)
            }
        }

        parentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: parentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: leadingPadding),
            stackView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -trailingPadding),
            stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: kButtonsHeight)

        ])

        if let noButton {
            yesButton.heightAnchor.constraint(equalTo: noButton.heightAnchor).isActive = true
        }

        bindButtonAndTitleConstraints(buttons: buttons)
    }

    // ensures that each `UIButton` will expand to accomodate its `title`'s text length
    // without this, the title will either truncate or spill out of the `UIButton`
    private func bindButtonAndTitleConstraints(buttons: [UIButton]) {
        buttons.forEach { button in
            // defensively code for `titleLabel`'s existence
            guard let titleLabel = button.titleLabel else { return }

            titleLabel.textAlignment = .center
            titleLabel.lineBreakMode = .byWordWrapping
            titleLabel.numberOfLines = 0

            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(
                    equalTo: titleLabel.heightAnchor,
                    constant: totalVerticalPadding
                ),
                button.widthAnchor.constraint(
                    equalTo: titleLabel.widthAnchor,
                    constant: totalHorizontalPadding
                )
            ])
        }
    }

    private func templateUnStackedPositiveFirst(stackView: UIStackView, buttonsContainerHeight: NSLayoutConstraint) {
        fillTemplate(stackView,
                     axis: .horizontal,
                     stackSpacing: spacing)
        buttonsContainerHeight.constant = kButtonsHeight
    }

    private func templateUnStackedNegativeFirst(stackView: UIStackView, buttonsContainerHeight: NSLayoutConstraint) {
        fillTemplate(stackView, axis: .horizontal,
                     stackSpacing: spacing,
                     reverseOrder: true)
        buttonsContainerHeight.constant = kButtonsHeight
    }

    private func templateStacked(
        stackView: UIStackView,
        buttonsContainerHeight: NSLayoutConstraint,
        positiveFirst: Bool
    ) {
        fillTemplate(
            stackView,
            axis: .vertical,
            stackSpacing: stackedSpacing,
            reverseOrder: positiveFirst ? false : true
        )

        let containerHeight = isNegativeButtonVisible ? kButtonsStackedTemplateHeight : kButtonsHeight
        buttonsContainerHeight.constant = containerHeight
    }
    
    private func fillTemplate(_ stackView: UIStackView,
                              axis: NSLayoutConstraint.Axis,
                              stackSpacing: CGFloat,
                              reverseOrder: Bool = false) {
        stackView.axis = axis

        // ensures that the buttons expand in the direction perpendicular their `UIStackView`'s axis
        // and are allocated equal space inside the `UIStackView`
        stackView.alignment = .fill
        stackView.distribution = .fillEqually

        stackView.spacing = stackSpacing

        if reverseOrder {
            if let noButton {
                stackView.addArrangedSubview(noButton)
            }

            stackView.addArrangedSubview(yesButton)
        } else {
            stackView.addArrangedSubview(yesButton)

            if let noButton {
                stackView.addArrangedSubview(noButton)
            }
        }
    }

    private func fillStackedTemplateWithButtonOrder(
        _ stackView: UIStackView,
        axis: NSLayoutConstraint.Axis,
        stackSpacing: CGFloat,
        buttonsContainerHeightConstraint: NSLayoutConstraint,
        buttonOrder: ButtonOrder = .positiveFirst
    ) {
        let containerHeightConstant = isNegativeButtonVisible ? kButtonsStackedTemplateHeight : kButtonsHeight
        buttonsContainerHeightConstraint.constant = containerHeightConstant

        stackView.axis = axis

        // ensures that the buttons expand in the direction perpendicular their `UIStackView`'s axis
        // and are allocated equal space inside the `UIStackView`
        stackView.alignment = .fill
        stackView.distribution = .fillEqually

        stackView.spacing = stackSpacing

        switch buttonOrder {
        case .positiveFirst:
            stackView.addArrangedSubview(yesButton)

            if let noButton {
                stackView.addArrangedSubview(noButton)
            }
        case .negativeFirst:
            if let noButton {
                stackView.addArrangedSubview(noButton)
            }

            stackView.addArrangedSubview(yesButton)
        }
    }
    
    private func attachButtonAction(offerButtonsActions: OfferButtonsActions) {
        yesButton.addTarget(offerButtonsActions, action: #selector(offerButtonsActions.yesAction), for: .touchUpInside)

        if let noButton {
            noButton.addTarget(
                offerButtonsActions,
                action: #selector(offerButtonsActions.noAction),
                for: .touchUpInside
            )
        }
    }
    
    func updateButtonsTitle(_ offer: OfferViewData) {
        yesButton.updateButtons(text: offer.positiveButtonLabel?.text)

        if let noButton {
            noButton.updateButtons(text: offer.negativeButtonLabel?.text)
        }
    }
}
