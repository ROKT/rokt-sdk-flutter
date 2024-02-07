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

    let defaultStyle: ProgressIndicatorStyles?
    let indicatorStyle: IndicatorStyles?
    let activeIndicatorStyle: IndicatorStyles?
    let seenIndicatorStyle: IndicatorStyles?
    let settings: ProgressIndicatorSettings?

    init(
        indicator: String,
        defaultStyle: ProgressIndicatorStyles?,
        indicatorStyle: IndicatorStyles?,
        activeIndicatorStyle: IndicatorStyles?,
        seenIndicatorStyle: IndicatorStyles?,
        settings: ProgressIndicatorSettings?
    ) {
        self.indicator = indicator

        self.defaultStyle = defaultStyle
        self.indicatorStyle = indicatorStyle
        self.seenIndicatorStyle =
        StyleTransformer.getUpdatedStyle(self.indicatorStyle,
                                         newStyle: seenIndicatorStyle)
        // active falls back to seen (which then falls back to indicator)
        self.activeIndicatorStyle =
        StyleTransformer.getUpdatedStyle(self.seenIndicatorStyle,
                                         newStyle: activeIndicatorStyle)
        self.settings = settings
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
