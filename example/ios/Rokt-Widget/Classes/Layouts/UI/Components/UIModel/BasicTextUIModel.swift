//
//  BasicTextUIModel.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import SwiftUI
import Combine

protocol DataBindingImplementable {
    associatedtype T: Hashable
    var dataBinding: DataBinding<T> { get }
    func updateDataBinding(dataBinding: DataBinding<T>)
}

@available(iOS 15, *)
class BasicTextUIModel: Hashable, Identifiable, ObservableObject, DataBindingImplementable {
    private var bag = Set<AnyCancellable>()

    let id: UUID = UUID()

    // `value` is used by our BNF transformer to update `dataBinding`
    private(set) var value: String?
    private(set) var dataBinding: DataBinding<String> = .value("")

    // extracted data from `dataBinding` that's published externally
    @Published var boundValue = ""

    @Published var styleState = StyleState.default
    var currentStylingProperties: BasicTextStyle? {
        switch styleState {
        case .hovered: return hoveredStyle
        case .pressed: return pressedStyle
        case .disabled: return disabledStyle
        default: return defaultStyle
        }
    }

    let defaultStyle: BasicTextStyle?
    let pressedStyle: BasicTextStyle?
    let hoveredStyle: BasicTextStyle?
    let disabledStyle: BasicTextStyle?

    // this closure performs the STATE-based data expansion (eg. progress indicator component owning a rich text child)
    private var stateDataExpansionClosure: ((String?) -> String?)?

    init(
        value: String?,
        defaultStyle: BasicTextStyle?,
        pressedStyle: BasicTextStyle?,
        hoveredStyle: BasicTextStyle?,
        disabledStyle: BasicTextStyle?,
        stateDataExpansionClosure: ((String?) -> String?)? = nil
    ) {
        self.value = value

        self.boundValue = value ?? ""

        self.defaultStyle = defaultStyle
        self.pressedStyle = StyleTransformer.getUpdatedStyle(defaultStyle, newStyle: pressedStyle)
        self.hoveredStyle = StyleTransformer.getUpdatedStyle(defaultStyle, newStyle: hoveredStyle)
        self.disabledStyle = StyleTransformer.getUpdatedStyle(defaultStyle, newStyle: disabledStyle)

        self.stateDataExpansionClosure = stateDataExpansionClosure

        performStyleStateBinding()
    }

    func updateDataBinding(dataBinding: DataBinding<String>) {
        self.dataBinding = dataBinding
        runDataExpansion()
    }

    private func runDataExpansion() {
        switch dataBinding {
        case .value(let data):
            boundValue = data
        case .state(let data):
            var isStateIndicatorPosition = false

            // if the input is `%^STATE.IndicatorPosition^%`, associated value `data` = `IndicatorPosition`
            if DataBindingStateKeys.isValidKey(data) {
                isStateIndicatorPosition = true
            }

            // if the input is `%^STATE.IndicatorPosition^%`, becomes `IndicatorPosition`
            // if the input is `Hello`, becomes `Hello`
            boundValue = data

            // perform data expansion on initialiser argument `value` if the DataBinding is STATE
            processStateValue(value, isStateIndicatorPosition: isStateIndicatorPosition)
        }

        updateBoundValueWithStyling()
    }

    // update the text to display if State changes
    private func performStyleStateBinding() {
        $styleState.sink { [weak self] _ in
            self?.updateBoundValueWithStyling()
        }
        .store(in: &bag)
    }

    // only runs if the DataBinding is STATE. this is where we do a STATE operation (eg. adding + 1)
    func processStateValue(_ value: String?, isStateIndicatorPosition: Bool) {
        guard isStateIndicatorPosition,
              let stateDataExpansionClosure,
              let expandedValue = stateDataExpansionClosure(value)
        else { return }

        boundValue = expandedValue
    }

    private func updateBoundValueWithStyling() {
        guard let transform = currentStylingProperties?.text?.textTransform else { return }

        switch transform {
        case .uppercase:
            boundValue = boundValue.uppercased()
        case .lowercase:
            boundValue = boundValue.lowercased()
        case .capitalize:
            boundValue = boundValue.capitalized
        default: break
        }
    }

}
