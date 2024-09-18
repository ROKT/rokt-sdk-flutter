//
//  OfferButton.swift
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

class OfferButton: UIButton {
    private var buttonStyles: ButtonStylesViewData!
    private var parentTraitCollection: UITraitCollection!

    init(frame: CGRect, buttonStyles: ButtonStylesViewData, traitCollection: UITraitCollection) {
        self.buttonStyles = buttonStyles
        self.parentTraitCollection = traitCollection
        super.init(frame: frame)
        setBorder(style: buttonStyles.defaultStyle, traitCollection: traitCollection)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var isHighlighted: Bool {
        didSet {
            switch isHighlighted {
            case true:
                setBorder(style: buttonStyles.pressedStyle, traitCollection: traitCollection)
            case false:
                setBorder(style: buttonStyles.defaultStyle, traitCollection: traitCollection)
            }
        }
    }

    func updateButtons(text: String?) {
        set(text: text,
            styles: buttonStyles,
            traitCollection: parentTraitCollection)
    }

}
