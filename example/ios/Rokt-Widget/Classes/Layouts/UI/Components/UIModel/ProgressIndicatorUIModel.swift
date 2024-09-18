//
//  ProgressIndicatorUIModel.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import SwiftUI

@available(iOS 15, *)
class ProgressIndicatorUIModel: Identifiable, Hashable {
    let id: UUID = UUID()

    let indicator: String
    private(set) var dataBinding: DataBinding = .value("")

    let defaultStyle: [ProgressIndicatorStyles]?
    let indicatorStyle: [IndicatorStyles]?
    let activeIndicatorStyle: [IndicatorStyles]?
    let seenIndicatorStyle: [IndicatorStyles]?
    let startPosition: Int32?
    let accessibilityHidden: Bool?

    init(
        indicator: String,
        defaultStyle: [ProgressIndicatorStyles]?,
        indicatorStyle: [IndicatorStyles]?,
        activeIndicatorStyle: [IndicatorStyles]?,
        seenIndicatorStyle: [IndicatorStyles]?,
        startPosition: Int32?,
        accessibilityHidden: Bool?
    ) {
        self.indicator = indicator

        self.defaultStyle = defaultStyle
        self.indicatorStyle = indicatorStyle
        self.seenIndicatorStyle = seenIndicatorStyle
        self.activeIndicatorStyle = activeIndicatorStyle
        self.startPosition = startPosition
        self.accessibilityHidden = accessibilityHidden
    }

    func updateDataBinding(dataBinding: DataBinding<String>) {
        self.dataBinding = dataBinding
    }

    static func performDataExpansion(value: String?) -> String? {
        guard let value,
              let valueAsInt = Int(value)
        else { return value }

        return "\(valueAsInt + 1)"
    }
}
