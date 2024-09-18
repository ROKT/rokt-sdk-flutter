//
//  CGRectExtension.swift
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

internal extension CGRect {
    func intersectPercent(_ rect: CGRect) -> CGFloat {
        let rectArea = rect.width * rect.height

        guard intersects(rect),
              rectArea > 0
        else { return 0 }

        let intersection = intersection(rect)

        return (intersection.width * intersection.height)/rectArea
    }
}
